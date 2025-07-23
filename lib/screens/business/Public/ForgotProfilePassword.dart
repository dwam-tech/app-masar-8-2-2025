import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ForgotProfilePassword extends StatefulWidget {
  const ForgotProfilePassword({super.key});

  @override
  State<ForgotProfilePassword> createState() => _ForgotProfilePasswordState();
}

class _ForgotProfilePasswordState extends State<ForgotProfilePassword> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _submit() {
    // منطق التحقق (سيتم الربط مع الباك ايند لاحقًا)
    if (_codeController.text.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال رمز مكون من 4 أرقام أو أكثر')),
      );
      return;
    }
    context.push('/ResetProfilePassword');
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
              child: Column(
                children: [
                  const Text(
                    'يرجى إدخال رمز التحقق المرسل إلى هاتفك أو بريدك الإلكتروني لاستعادة كلمة المرور.',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'رمز التحقق',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.key, color: Color(0xFFFC8700)),
                    ),
                    textAlign: TextAlign.center,
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
                      onPressed: _submit,
                      child: const Text(
                        'تأكيد الرمز',
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
    );
  }
}
