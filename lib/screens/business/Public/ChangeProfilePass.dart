import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChangeProfilePass extends StatefulWidget {
  const ChangeProfilePass({super.key});

  @override
  State<ChangeProfilePass> createState() => _ChangeProfilePassState();
}

class _ChangeProfilePassState extends State<ChangeProfilePass> {
  final _formKey = GlobalKey<FormState>();
  final _currentPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();
  bool _isObscureCurrent = true;
  bool _isObscureNew = true;
  bool _isObscureConfirm = true;

  @override
  void dispose() {
    _currentPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // منطق الحفظ (يمكن ربطه بالباك ايند لاحقًا)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تغيير كلمة المرور بنجاح!')),
      );
      context.push('/restaurant-home');
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
          title: const Text('تغيير كلمة المرور', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? screenWidth * 0.25 : 18,
              vertical: 24,
            ),
            child: Container(
              padding: const EdgeInsets.all(18),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PasswordField(
                      controller: _currentPassController,
                      label: 'كلمة المرور الحالية',
                      isObscure: _isObscureCurrent,
                      onToggle: () => setState(() => _isObscureCurrent = !_isObscureCurrent),
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
                        if (val == null || val.isEmpty) return 'أدخل تأكيد كلمة المرور الجديدة';
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
                        onPressed: _submit,
                        child: const Text(
                          'حفظ كلمة المرور',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () => context.push('/ForgotProfilePassword'),
                        child: const Text(
                          'نسيت كلمة المرور؟',
                          style: TextStyle(
                            color: Color(0xFFFC8700),
                            fontWeight: FontWeight.w600,
                          ),
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
