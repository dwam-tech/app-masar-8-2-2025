import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saba2v2/components/UI/image_picker_row.dart';
import 'package:saba2v2/components/UI/section_title.dart';

class SubscriptionRegistrationSingleScreen extends StatefulWidget {
  const SubscriptionRegistrationSingleScreen({super.key});

  @override
  State<SubscriptionRegistrationSingleScreen> createState() =>
      _SubscriptionRegistrationSingleScreenState();
}

class _SubscriptionRegistrationSingleScreenState
    extends State<SubscriptionRegistrationSingleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _brokerNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _selectedCity;
  bool _acceptTerms = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // قائمة المدن للاختيار
  final List<String> _cities = [
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
    'سوهاج'
  ];

  @override
  void dispose() {
    _brokerNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() {
    // if (_formKey.currentState!.validate() && _acceptTerms) {
    //   if (_passwordController.text != _confirmPasswordController.text) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(content: Text('كلمتا المرور غير متطابقتين')),
    //     );
    //     return;
    //   }
    //
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('تم تسجيل الوسيط العقاري بنجاح')),
    //   );
    // } else if (!_acceptTerms) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('يجب الموافقة على الشروط والأحكام')),
    //   );
    // }
    context.go('/RealStateHomeScreen');
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool obscureText = false,
    bool showVisibilityToggle = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        hintText: label,
        hintStyle: TextStyle(
          color: Colors.grey[600],
        ),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18.0,
          horizontal: 20.0,
        ),
        suffixIcon: showVisibilityToggle
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey[600],
                ),
                onPressed: () {
                  setState(() {
                    if (label.contains('المرور')) {
                      _isPasswordVisible = !_isPasswordVisible;
                    } else {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    }
                  });
                },
              )
            : null,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'هذا الحقل مطلوب';
        }
        if (label == 'البريد الإلكتروني' &&
            !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'بريد إلكتروني غير صحيح';
        }
        if (label.contains('المرور') && value.length < 6) {
          return 'يجب أن تكون 6 أحرف على الأقل';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل وسيط عقاري'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  child: const SectionTitle(title: 'معلومات الوسيط'),
                ),
                // الحقول النصية
                _buildFormField(
                  label: 'اسم الوسيط العقاري',
                  controller: _brokerNameController,
                ),
                const SizedBox(height: 16),
                _buildFormField(
                  label: 'البريد الإلكتروني',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _buildFormField(
                  label: 'رقم الهاتف',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
               Directionality(
                textDirection: TextDirection.rtl,
                 child: DropdownButtonFormField<String>(
                    value: _selectedCity,
                    alignment: AlignmentDirectional.centerEnd,
                    decoration: InputDecoration(
                      labelText: 'المدينة',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 15.0,
                        horizontal: 20.0,
                      ),
                    ),
                    icon: const Padding(
                      padding: EdgeInsets.only(left: 12.0),
                      child: Icon(Icons.keyboard_arrow_down),
                    ),
                    iconSize: 28,
                    iconEnabledColor: Colors.grey[600],
                    items: _cities.map((String city) {
                      return DropdownMenuItem<String>(
                        value: city,
                        alignment: AlignmentDirectional.centerEnd,
                        child: Text(
                          city,
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() => _selectedCity = newValue);
                    },
                    validator: (value) => value == null ? 'الرجاء اختيار المدينة' : null,
                  ),
               ),
                const SizedBox(height: 16),

                _buildFormField(
                  label: 'كلمة المرور',
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  showVisibilityToggle: true,
                ),
                const SizedBox(height: 16),
                _buildFormField(
                  label: 'تأكيد كلمة المرور',
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  showVisibilityToggle: true,
                ),

                // هوية الوسيط
                Container(
                  width: double.infinity,
                  child: const SectionTitle(title: 'هوية الوسيط العقاري'),
                ),
                const SizedBox(height: 15),
                ImagePickerRow(
                  label: 'الهوية الأمامية',
                  icon: Icons.credit_card,
                  fieldIdentifier: 'idFront',
                  onTap: () => _pickFile('idFront'),
                ),
                const SizedBox(height: 12),
                ImagePickerRow(
                  label: 'الهوية الخلفية',
                  icon: Icons.credit_card,
                  fieldIdentifier: 'idBack',
                  onTap: () => _pickFile('idBack'),
                ),

                // البطاقة الضريبية
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  child:  const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                     Text("إذا وجدت"),
                      SizedBox(width: 8),
                      Text(
                        'بطاقة ضريبية',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                ImagePickerRow(
                  label: 'الوجه الأمامي للبطاقة',
                  icon: Icons.receipt_long,
                  fieldIdentifier: 'taxFront',
                  onTap: () => _pickFile('taxFront'),
                ),
                const SizedBox(height: 12),
                ImagePickerRow(
                  label: 'الوجه الخلفي للبطاقة',
                  icon: Icons.receipt_long,
                  fieldIdentifier: 'taxBack',
                  onTap: () => _pickFile('taxBack'),
                ),


                // الشروط والأحكام
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => showTermsDialog(context),
                      child: const Text('الشروط والأحكام'),
                    ),
                    Transform.scale(
                      scale: 1.2,
                      child: Checkbox(
                        value: _acceptTerms,
                        onChanged: (v) => setState(() => _acceptTerms = v ?? false),
                        activeColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),

                // زر التسجيل
                const SizedBox(height: 32),
                Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewPadding.bottom + 16,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                      child: const Text(
                        'إنشاء الحساب',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),  
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('الشروط والأحكام'),
        content: const SingleChildScrollView(
          child: Text('...نص الشروط والأحكام هنا'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFile(String fieldName) async {
    // TODO: Implement file picking logic
  }
}