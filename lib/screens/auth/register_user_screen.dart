import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:saba2v2/providers/auth_provider.dart';

import '../../providers/auth_provider.dart'; // Replace with your actual path

class RegisterUserScreen extends StatefulWidget {
  const RegisterUserScreen({super.key});

  @override
  State<RegisterUserScreen> createState() => _RegisterUserScreenState();
}

class _RegisterUserScreenState extends State<RegisterUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _selectedCity;
  bool _acceptTerms = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  // قائمة المدن المصرية
  static const List<String> _cities = [
    'القاهرة',
    'الجيزة',
    'الإسكندرية',
    'الدقهلية',
    'البحر الأحمر',
    'البحيرة',
    'الفيوم',
    'الغربية',
    'الإسماعيلية',
    'المنوفية',
    'المنيا',
    'القليوبية',
    'الوادي الجديد',
    'السويس',
    'أسوان',
    'أسيوط',
    'بني سويف',
    'بورسعيد',
    'دمياط',
    'الشرقية',
    'جنوب سيناء',
    'كفر الشيخ',
    'مطروح',
    'الأقصر',
    'قنا',
    'شمال سيناء',
    'سوهاج',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // التحقق من صحة البريد الإلكتروني
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // التحقق من صحة رقم الهاتف المصري
  bool _isValidEgyptianPhone(String phone) {
    phone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    return RegExp(r'^(010|011|012|015)\d{8}$').hasMatch(phone) ||
        RegExp(r'^(\+2010|\+2011|\+2012|\+2015)\d{8}$').hasMatch(phone) ||
        RegExp(r'^(0020010|0020011|0020012|0020015)\d{8}$').hasMatch(phone);
  }

  // التحقق من قوة كلمة المرور
  String? _validatePassword(String password) {
    if (password.length < 8) {
      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'كلمة المرور يجب أن تحتوي على حرف كبير واحد على الأقل';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'كلمة المرور يجب أن تحتوي على حرف صغير واحد على الأقل';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'كلمة المرور يجب أن تحتوي على رقم واحد على الأقل';
    }
    return null;
  }

  // عرض رسالة
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

  // تسجيل المستخدم
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showMessage('كلمتا المرور غير متطابقتين', isError: true);
      return;
    }

    if (!_acceptTerms) {
      _showMessage('يجب الموافقة على الشروط والأحكام', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final result = await authProvider.registerNormalUser(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim(),
        governorate: _selectedCity!,
      );

      if (result['status']) {
        _showMessage('تم إكمال تسجيل الحساب بنجاح');
        if (mounted) {
          context.go('/UserHomeScreen'); // Navigate to home screen after successful registration
        }
      } else {
        _showMessage(result['message'], isError: true);
      }
    } catch (e) {
      _showMessage('حدث خطأ أثناء إنشاء الحساب: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 22),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      _buildHeader(),
                      const SizedBox(height: 40),
                      _buildFullForm(),
                      const SizedBox(height: 30),
                      _buildRegisterButton(),
                      const SizedBox(height: 20),
                      _buildLoginLink(),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // بناء النموذج كاملاً
  Widget _buildFullForm() {
    return Column(
      children: [
        _buildNameField(),
        const SizedBox(height: 20),
        _buildEmailField(),
        const SizedBox(height: 20),
        _buildPhoneField(),
        const SizedBox(height: 20),
        _buildCityDropdown(),
        const SizedBox(height: 20),
        _buildPasswordField(),
        const SizedBox(height: 20),
        _buildConfirmPasswordField(),
        const SizedBox(height: 20),
        _buildTermsCheckbox(),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Text(
          'إنشاء الحساب',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      textDirection: TextDirection.rtl,
      decoration: _buildInputDecoration(
        label: 'الاسم الكامل',
        icon: Icons.person_outline,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'الرجاء إدخال الاسم الكامل';
        }
        if (value.trim().length < 2) {
          return 'الاسم يجب أن يحتوي على حرفين على الأقل';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
      decoration: _buildInputDecoration(
        label: 'البريد الإلكتروني',
        icon: Icons.email_outlined,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'الرجاء إدخال البريد الإلكتروني';
        }
        if (!_isValidEmail(value.trim())) {
          return 'الرجاء إدخال بريد إلكتروني صحيح';
        }
        return null;
      },
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
      decoration: _buildInputDecoration(
        label: 'رقم الهاتف',
        icon: Icons.phone_outlined,
        hint: '01xxxxxxxxx',
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'الرجاء إدخال رقم الهاتف';
        }
        if (!_isValidEgyptianPhone(value.trim())) {
          return 'الرجاء إدخال رقم هاتف مصري صحيح';
        }
        return null;
      },
    );
  }

  Widget _buildCityDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCity,
      decoration: _buildInputDecoration(
        label: 'اختر المحافظة',
        icon: Icons.location_city_outlined,
      ),
      isExpanded: true,
      items: _cities.map((String city) {
        return DropdownMenuItem<String>(
          value: city,
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              city,
              textDirection: TextDirection.rtl,
            ),
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedCity = newValue;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'الرجاء اختيار المحافظة';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
      decoration: _buildInputDecoration(
        label: 'كلمة المرور',
        icon: Icons.lock_outline,
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'الرجاء إدخال كلمة المرور';
        }
        return _validatePassword(value);
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: !_isConfirmPasswordVisible,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
      decoration: _buildInputDecoration(
        label: 'تأكيد كلمة المرور',
        icon: Icons.lock_outline,
        suffixIcon: IconButton(
          icon: Icon(
            _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'الرجاء تأكيد كلمة المرور';
        }
        if (value != _passwordController.text) {
          return 'كلمتا المرور غير متطابقتين';
        }
        return null;
      },
    );
  }

  Widget _buildTermsCheckbox() {
    return InkWell(
      onTap: () {
        setState(() {
          _acceptTerms = !_acceptTerms;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _acceptTerms ? Colors.orange : Colors.transparent,
                border: Border.all(
                  color: _acceptTerms ? Colors.orange : Colors.grey,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: _acceptTerms
                  ? const Icon(
                Icons.check,
                size: 16,
                color: Colors.white,
              )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Wrap(
                children: [
                  const Text(
                    'أوافق على ',
                    style: TextStyle(fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () {
                      _showTermsDialog();
                    },
                    child: const Text(
                      'الشروط والأحكام',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Text(
                    ' وسياسة الخصوصية',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _register,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
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
        'إنشاء حساب',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'لديك حساب بالفعل؟',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            context.go('/login');
          },
          child: const Text(
            'تسجيل الدخول',
            style: TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.grey[600]),
      suffixIcon: suffixIcon,
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
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('الشروط والأحكام'),
            content: const SingleChildScrollView(
              child: Text(
                'هنا يمكنك إضافة نص الشروط والأحكام وسياسة الخصوصية الخاصة بالتطبيق...',
                textAlign: TextAlign.right,
              ),
            ),
            actions: [
              TextButton(
                child: const Text('إغلاق'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}