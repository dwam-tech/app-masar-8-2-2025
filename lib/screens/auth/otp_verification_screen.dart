import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'dart:async';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final String? userName;
  final String purpose;
  
  const OtpVerificationScreen({
    super.key,
    required this.email,
    this.userName,
    this.purpose = 'email_verification',
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen>
    with TickerProviderStateMixin {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  
  bool _isLoading = false;
  bool _isResending = false;
  int _resendCountdown = 0;
  Timer? _timer;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  
  // للـ Auto-fill
  StreamSubscription<String>? _clipboardSubscription;
  Timer? _clipboardCheckTimer;
  String _lastClipboardContent = '';
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();
    _startResendCountdown();
    _startClipboardMonitoring();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _timer?.cancel();
    _clipboardCheckTimer?.cancel();
    _clipboardSubscription?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  // مراقبة الحافظة للـ Auto-fill
  void _startClipboardMonitoring() {
    _clipboardCheckTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      try {
        final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
        final clipboardText = clipboardData?.text ?? '';
        
        if (clipboardText != _lastClipboardContent && 
            clipboardText.isNotEmpty && 
            _isValidOtpCode(clipboardText) &&
            _getOtpCode().isEmpty) {
          _lastClipboardContent = clipboardText;
          _showAutoFillDialog(clipboardText);
        }
      } catch (e) {
        // تجاهل أخطاء الحافظة
      }
    });
  }

  bool _isValidOtpCode(String text) {
    // تحقق من أن النص يحتوي على 6 أرقام فقط
    final RegExp otpRegex = RegExp(r'^\d{6}$');
    return otpRegex.hasMatch(text.trim());
  }

  void _showAutoFillDialog(String otpCode) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.auto_fix_high, color: Colors.blue[600]),
            const SizedBox(width: 8),
            const Text('ملء تلقائي', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: Text(
          'تم العثور على رمز التحقق في الحافظة:\n$otpCode\n\nهل تريد استخدامه؟',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('لا', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _autoFillOtp(otpCode);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('نعم', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _autoFillOtp(String otpCode) {
    for (int i = 0; i < 6 && i < otpCode.length; i++) {
      _controllers[i].text = otpCode[i];
    }
    setState(() {});
    
    // تحقق تلقائي بعد التعبئة
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_isOtpComplete() && !_isLoading) {
        _verifyOtp();
      }
    });
  }

  void _startResendCountdown() {
    setState(() {
      _resendCountdown = 60;
    });
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  String _getOtpCode() {
    return _controllers.map((controller) => controller.text).join();
  }

  bool _isOtpComplete() {
    return _getOtpCode().length == 6;
  }

  void _onOtpChanged(String value, int index) {
    print('DEBUG OTP: Field $index changed to: "$value"');
    
    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
        print('DEBUG OTP: Moving focus to field ${index + 1}');
      }
    }
    
    if (_isOtpComplete() && !_isLoading) {
      print('DEBUG OTP: Auto-verifying complete OTP: ${_getOtpCode()}');
      // تأخير بسيط للتأكد من اكتمال الإدخال
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_isOtpComplete() && !_isLoading) {
          _verifyOtp();
        }
      });
    }
  }

  void _onBackspace(int index) {
    print('DEBUG OTP: Backspace on field $index');
    if (index > 0 && _controllers[index].text.isEmpty) {
      _focusNodes[index - 1].requestFocus();
      print('DEBUG OTP: Moving focus back to field ${index - 1}');
    }
  }

  Future<void> _verifyOtp() async {
    final otpCode = _getOtpCode();
    print('DEBUG OTP: Starting verification process');
    print('DEBUG OTP: Email: ${widget.email}');
    print('DEBUG OTP: OTP Code: "$otpCode"');
    print('DEBUG OTP: OTP Length: ${otpCode.length}');
    
    if (!_isOtpComplete()) {
      print('DEBUG OTP: OTP incomplete, showing error message');
      _showMessage('الرجاء إدخال الكود كاملاً', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      print('DEBUG OTP: Calling authProvider.verifyEmailOtp');
      
      final result = await authProvider.verifyEmailOtp(
        email: widget.email,
        otp: otpCode,
      );
      
      print('DEBUG OTP: API Response: $result');

      if (!mounted) return;

      if (result['status'] == true) {
        print('DEBUG OTP: Verification successful');
        _showMessage('تم تأكيد البريد الإلكتروني بنجاح!');
        if (widget.purpose == 'password_reset') {
          context.goNamed('ResetProfilePassword', extra: {'email': widget.email});
        } else {
          context.go('/login');
        }
      } else {
        print('DEBUG OTP: Verification failed - ${result['message']}');
        _showMessage(result['message'] ?? 'رمز التحقق غير صحيح', isError: true);
        _clearOtp();
      }
    } catch (e) {
      print('DEBUG OTP: Exception during verification: $e');
      _showMessage('حدث خطأ أثناء التحقق من الرمز', isError: true);
      _clearOtp();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendOtp() async {
    if (_resendCountdown > 0) return;

    print('DEBUG OTP: Starting resend process for email: ${widget.email}');
    
    setState(() {
      _isResending = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
-      final result = await authProvider.resendEmailOtp(email: widget.email);
+      final result = widget.purpose == 'password_reset'
+          ? await authProvider.sendPasswordResetOtp(email: widget.email)
+          : await authProvider.resendEmailOtp(email: widget.email);
      
      print('DEBUG OTP: Resend API Response: $result');

      if (!mounted) return;

      if (result['status'] == true) {
        print('DEBUG OTP: Resend successful');
        _showMessage('تم إعادة إرسال رمز التحقق');
        _startResendCountdown();
        _clearOtp();
      } else {
        print('DEBUG OTP: Resend failed - ${result['message']}');
        _showMessage(result['message'] ?? 'فشل في إعادة إرسال الرمز', isError: true);
      }
    } catch (e) {
      print('DEBUG OTP: Exception during resend: $e');
      _showMessage('حدث خطأ أثناء إعادة الإرسال', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  void _clearOtp() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
        backgroundColor: isError ? Colors.red[600] : Colors.green[600],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height - 
                          MediaQuery.of(context).padding.top - 
                          MediaQuery.of(context).padding.bottom - 
                          kToolbarHeight - 48,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        _buildHeader(),
                        const SizedBox(height: 40),
                        _buildOtpInputs(),
                        const SizedBox(height: 30),
                        _buildVerifyButton(),
                        const SizedBox(height: 20),
                        _buildResendSection(),
                        const SizedBox(height: 40),
                        _buildBackToLoginButton(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue[400]!,
                Colors.blue[600]!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            size: 50,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'تأكيد البريد الإلكتروني',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'أدخل الرمز المرسل إلى',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Text(
            widget.email,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.blue[800],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildOtpInputs() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.security, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              const Text(
                'رمز التحقق',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // تحسين ترتيب الحقول - من الشمال لليمين
          Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) => _buildOtpField(index)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                'سيتم التحقق تلقائياً عند الانتهاء',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOtpField(int index) {
    final isActive = _controllers[index].text.isNotEmpty;
    final screenWidth = MediaQuery.of(context).size.width;
    final fieldSize = (screenWidth - 100) / 7; // حساب حجم مناسب للشاشة
    
    return Container(
      width: fieldSize.clamp(40.0, 55.0),
      height: fieldSize.clamp(50.0, 65.0),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        gradient: isActive
            ? LinearGradient(
                colors: [Colors.blue[50]!, Colors.blue[100]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isActive ? null : Colors.grey[50],
        border: Border.all(
          color: isActive ? Colors.blue[400]! : Colors.grey[300]!,
          width: isActive ? 2.5 : 1.5,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (RawKeyEvent event) {
          if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
            if (_controllers[index].text.isEmpty && index > 0) {
              _focusNodes[index - 1].requestFocus();
              _controllers[index - 1].clear();
            }
          }
        },
        child: TextFormField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: screenWidth > 400 ? 24 : 20,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.blue[800] : Colors.black87,
          ),
          keyboardType: TextInputType.number,
          maxLength: 1,
          decoration: const InputDecoration(
            border: InputBorder.none,
            counterText: '',
            contentPadding: EdgeInsets.zero,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          onChanged: (value) {
            if (value.length > 1) {
              _controllers[index].text = value.substring(0, 1);
              _controllers[index].selection = TextSelection.fromPosition(
                TextPosition(offset: 1),
              );
              value = _controllers[index].text;
            }
            _onOtpChanged(value, index);
            setState(() {});
          },
          onEditingComplete: () {
            if (index < 5 && _controllers[index].text.isNotEmpty) {
              _focusNodes[index + 1].requestFocus();
            }
          },
          onTap: () {
            _controllers[index].selection = TextSelection.fromPosition(
              TextPosition(offset: _controllers[index].text.length),
            );
          },
          onFieldSubmitted: (value) {
            if (index < 5 && value.isNotEmpty) {
              _focusNodes[index + 1].requestFocus();
            } else if (index == 5 && _isOtpComplete()) {
              _verifyOtp();
            }
          },
        ),
      ),
    );
  }

  Widget _buildVerifyButton() {
    final isComplete = _isOtpComplete();
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading || !isComplete ? null : _verifyOtp,
        style: ElevatedButton.styleFrom(
          backgroundColor: isComplete ? Colors.blue[600] : Colors.grey[400],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: isComplete ? 4 : 0,
          shadowColor: Colors.blue.withOpacity(0.3),
        ),
        child: _isLoading
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'جاري التحقق...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified_user, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'تأكيد الرمز',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildResendSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Text(
            'لم تستلم الرمز؟',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          if (_resendCountdown > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timer, size: 16, color: Colors.orange[600]),
                  const SizedBox(width: 6),
                  Text(
                    'إعادة الإرسال خلال $_resendCountdown ثانية',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.orange[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          else
            ElevatedButton.icon(
              onPressed: _isResending ? null : _resendOtp,
              icon: _isResending
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.refresh, size: 18),
              label: Text(
                _isResending ? 'جاري الإرسال...' : 'إعادة إرسال الرمز',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBackToLoginButton() {
    return TextButton.icon(
      onPressed: () => context.go('/login'),
      icon: Icon(
        Icons.arrow_back,
        size: 18,
        color: Colors.grey[600],
      ),
      label: Text(
        'العودة إلى تسجيل الدخول',
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}