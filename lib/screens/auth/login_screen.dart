import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <-- استورد الحزمة هنا
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:saba2v2/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    // if (!_formKey.currentState!.validate()) {
    //   return;
    // }
    //
    // setState(() {
    //   _isLoading = true;
    // });
    //
    // try {
    //   final result = await context.read<AuthProvider>().login(
    //     _emailController.text.trim(),
    //     _passwordController.text,
    //   );
    //
    //   if (result['success']) {
    //     String? userType = result['type'];
    //     if (userType == null) {
    //       _showMessage('لم يتم تحديد نوع المستخدم', isError: true);
    //       return;
    //     }
    //
    //     if (userType == 'user') {
    //       context.go('/UserHomeScreen');
    //     } else if (userType == 'realtor') {
    //       context.go('/RealStateHomeScreen');
    //     } else if (userType == 'restaurant') {
    //       context.go('/restaurant-home');
    //     } else {
    //       _showMessage('نوع المستخدم غير مدعوم', isError: true);
    //     }
    //   } else {
    //     _showMessage(result['message'], isError: true);
    //   }
    // } catch (e) {
    //   _showMessage('حدث خطأ أثناء تسجيل الدخول. يرجى المحاولة لاحقًا', isError: true);
    // } finally {
    //   if (mounted) {
    //     setState(() {
    //       _isLoading = false;
    //     });
    //   }
    // }
    context.go('/UserHomeScreen');
  }


  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showAccountTypeBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const AccountTypeBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // هنا بنخلي النوتيفيكيشن بار أبيض والأيقونات سودا
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white, // خلفية بيضاء
        statusBarIconBrightness: Brightness.dark, // أيقونات سوداء (أندرويد)
        statusBarBrightness: Brightness.light, // أيقونات سوداء (iOS)
      ),
    );

    final media = MediaQuery.of(context).size;
    final horizontal = media.width * 0.06;
    final cardPadding = EdgeInsets.symmetric(
      horizontal: horizontal < 20 ? 20 : horizontal,
      vertical: media.height * 0.10,
    );
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            child: Padding(
              padding: cardPadding,
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 420),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 8),
                        const Text(
                          'تسجيل الدخول',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.phone,
                          textDirection: TextDirection.ltr,
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            labelText: 'البريد الألكتروني',
                            prefixIcon: Icon(Icons.mail_outline, color: Colors.grey[600]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.orange, width: 2),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'الرجاء إدخال رقم الهاتف';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textDirection: TextDirection.ltr,
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            labelText: 'كلمة المرور',
                            prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[600]),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.grey[600],
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.orange, width: 2),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال كلمة المرور';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        // زر تسجيل الدخول الأساسي
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 1.2,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                                : const Text(
                              'تسجيل دخول',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        // أزرار السوشيال
                        Row(
                          children: [
                            // زر فيسبوك
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: Image.asset(
                                  'assets/icons/facebook.png',
                                  width: 22,
                                  height: 22,
                                ),
                                label: const Text(
                                  'فيس بوك',
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.blue,
                                  side: const BorderSide(color: Color(0xFF0072FF),width: 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // زر جوجل
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: Image.asset(
                                  'assets/icons/google.png',
                                  width: 22,
                                  height: 22,
                                ),
                                label: const Text(
                                  'جوجل',
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Color(0xFFEA4335),
                                  side: const BorderSide(color: Color(0xFFEA4335),width: 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        // نسيت كلمة المرور
                        Center(
                          child: TextButton(
                            onPressed: () => context.push('/forgotPassword'),
                            child: const Text(
                              'نسيت كلمة المرور',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: Colors.black,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                        // زر إنشاء حساب - محدث لاستدعاء BottomSheet
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _showAccountTypeBottomSheet,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.orange, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                            ),
                            child: const Text(
                              'إنشاء حساب',
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// BottomSheet جديد لاختيار نوع الحساب
class AccountTypeBottomSheet extends StatelessWidget {
  const AccountTypeBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle للسحب
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // العنوان
            Text(
              'اختر نوع الحساب',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),

            // الخيارات
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // خيار المستخدم
                  _buildAccountTypeOption(
                    context: context,
                    icon: Icons.person_outline,
                    title: 'حساب مستخدم',
                    subtitle: 'للأشخاص الذين يبحثون عن الخدمات',
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFA640), Color(0xFFFC8700)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/register-user');
                    },
                  ),
                  const SizedBox(height: 16),

                  // خيار مقدم الخدمة
                  _buildAccountTypeOption(
                    context: context,
                    icon: Icons.business_center_outlined,
                    title: 'حساب مقدم خدمة',
                    subtitle: 'للشركات ومقدمي الخدمات المختلفة',
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFA640), Color(0xFFFC8700)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/register-provider');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // زر الإلغاء
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'إلغاء',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountTypeOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // الأيقونة
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),

            // النص
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            // سهم
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.8),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
