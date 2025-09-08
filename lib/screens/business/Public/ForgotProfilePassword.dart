import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:saba2v2/providers/auth_provider.dart';

class ForgotProfilePassword extends StatefulWidget {
  const ForgotProfilePassword({super.key});

  @override
  State<ForgotProfilePassword> createState() => _ForgotProfilePasswordState();
}

class _ForgotProfilePasswordState extends State<ForgotProfilePassword> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetCode() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    setState(() => _submitting = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final result = await authProvider.sendPasswordResetOtp(email: email);

      if (!mounted) return;

      if (result['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'تم إرسال رمز إعادة التعيين بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        context.goNamed('otpVerification', extra: {'email': email, 'purpose': 'password_reset'});
      } else {
        final message = result['message'] ?? 'تعذر إرسال رمز إعادة التعيين';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث خطأ أثناء إرسال الرمز. يرجى المحاولة لاحقًا'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
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
          title: const Text('نسيت كلمة المرور', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    const Text(
                      'أدخل بريدك الإلكتروني لإرسال رمز إعادة تعيين كلمة المرور.',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'البريد الإلكتروني',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.email, color: Color(0xFFFC8700)),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'يرجى إدخال البريد الإلكتروني';
                        if (!RegExp(r'^.+@.+\..+').hasMatch(val.trim())) {
                          // Fallback simple email check
                          return 'صيغة البريد الإلكتروني غير صحيحة';
                        }
                        return null;
                      },
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFC8700),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _submitting ? null : _sendResetCode,
                        child: _submitting
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text(
                                'إرسال الرمز',
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
