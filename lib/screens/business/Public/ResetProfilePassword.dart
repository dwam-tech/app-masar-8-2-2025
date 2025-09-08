import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:saba2v2/providers/auth_provider.dart';

class ResetProfilePassword extends StatefulWidget {
  final String email;
  const ResetProfilePassword({super.key, required this.email});

  @override
  State<ResetProfilePassword> createState() => _ResetProfilePasswordState();
}

class _ResetProfilePasswordState extends State<ResetProfilePassword> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();
  bool _isObscureNew = true;
  bool _isObscureConfirm = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _otpController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final result = await authProvider.resetPasswordWithOtp(
        email: widget.email.trim(),
        otp: _otpController.text.trim(),
        password: _newPassController.text,
        passwordConfirmation: _confirmPassController.text,
      );

      if (!mounted) return;

      if (result['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'تم تعيين كلمة المرور بنجاح!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        // إعادة التوجيه إلى شاشة تسجيل الدخول
        context.goNamed('login');
      } else {
        final message = result['message'] ?? 'فشل في إعادة تعيين كلمة المرور';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث خطأ أثناء العملية. يرجى المحاولة لاحقًا'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إعادة تعيين كلمة المرور', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? screenWidth * 0.28 : 22,
              vertical: 28,
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'سيتم إرسال الرمز إلى: ${widget.email}',
                        textAlign: TextAlign.right,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'رمز التحقق (OTP)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'يرجى إدخال رمز التحقق';
                        }
                        if (val.trim().length < 4) {
                          return 'الرمز يجب أن يكون 4 أرقام على الأقل';
                        }
                        return null;
                      },
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 18),
                    _PasswordField(
                      controller: _newPassController,
                      label: 'كلمة المرور الجديدة',
                      isObscure: _isObscureNew,
                      onToggle: () => setState(() => _isObscureNew = !_isObscureNew),
                    ),
                    const SizedBox(height: 18),
                    _PasswordField(
                      controller: _confirmPassController,
                      label: 'تأكيد كلمة المرور الجديدة',
                      isObscure: _isObscureConfirm,
                      onToggle: () => setState(() => _isObscureConfirm = !_isObscureConfirm),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'يرجى ملء هذا الحقل';
                        if (val.length < 6) return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                        if (val != _newPassController.text) return 'كلمات المرور غير متطابقة';
                        return null;
                      },
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFC8700),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _isSubmitting ? null : _submit,
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text(
                                'حفظ كلمة المرور الجديدة',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isObscure;
  final VoidCallback onToggle;
  final String? Function(String?)? validator;

  const _PasswordField({
    required this.controller,
    required this.label,
    required this.isObscure,
    required this.onToggle,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: IconButton(
          icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
          onPressed: onToggle,
        ),
      ),
      validator: validator ??
          (val) {
            if (val == null || val.isEmpty) return 'يرجى ملء هذا الحقل';
            if (val.length < 6) return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
            return null;
          },
      textAlign: TextAlign.right,
    );
  }
}
