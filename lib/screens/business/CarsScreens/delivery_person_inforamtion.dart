import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saba2v2/components/UI/section_title.dart';

class DeliveryPersonInformationScreen extends StatefulWidget {
  @override
  State<DeliveryPersonInformationScreen> createState() =>
      _DeliveryPersonInformationScreenState();
}

class _DeliveryPersonInformationScreenState
    extends State<DeliveryPersonInformationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _kiloCostController = TextEditingController();
  final TextEditingController _dailyDriverCostController = TextEditingController();
  final TextEditingController _maxKiloController = TextEditingController();

  // State for payment and renter type selections
  bool _cashSelected = false;
  bool _cardSelected = false;
  bool _driverSelected = false;
  bool _withoutDriverSelected = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _kiloCostController.dispose();
    _dailyDriverCostController.dispose();
    _maxKiloController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'البريد الإلكتروني مطلوب';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'البريد الإلكتروني غير صالح';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'رقم الهاتف مطلوب';
    if (!RegExp(r'^\+?[1-9]\d{9,14}$').hasMatch(value)) {
      return 'رقم الهاتف غير صالح (10-15 أرقام)';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'كلمة المرور مطلوبة';
    if (value.length < 8) return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    if (value != _confirmPasswordController.text) {
      return 'كلمات المرور غير متطابقة';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'تأكيد كلمة المرور مطلوب';
    if (value != _passwordController.text) {
      return 'كلمات المرور غير متطابقة';
    }
    return null;
  }

  String? _validateNumericField(String? value, String fieldName) {
    if (value == null || value.isEmpty) return '$fieldName مطلوب';
    if (int.tryParse(value) == null) return '$fieldName يجب أن يكون رقمًا';
    return null;
  }

  void _onNextPressed() {
    // if (_formKey.currentState!.validate()) {
    //   final data = {
    //     'account': {
    //       'name': _nameController.text,
    //       'email': _emailController.text,
    //       'phone': _phoneController.text,
    //       'password': _passwordController.text,
    //     },
    //     'paymentMethods': {
    //       'cash': _cashSelected,
    //       'card': _cardSelected,
    //     },
    //     'renterType': {
    //       'driver': _driverSelected,
    //       'withoutDriver': _withoutDriverSelected,
    //     },
    //     'kiloCost': _kiloCostController.text,
    //     'dailyDriverCost': _dailyDriverCostController.text,
    //     'maxKilo': _maxKiloController.text,
    //   };
    //   debugPrint('Submitted Data: $data');
    //   context.push('/driverCarInfo', extra: data);
    // }
    context.push('/DriverCarInfo');
  }

  Widget _buildCheckbox(String label, bool value, ValueChanged<bool?> onChanged) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.orange,
            checkColor: Colors.white,
          ),
          Flexible(child: Text(label, textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('معلومات السائق'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      backgroundColor: Colors.grey[200],
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Image and Edit Icon
                  SizedBox(
                    width: double.infinity,
                    child: Center(
                      child: Stack(
                        alignment: Alignment.bottomLeft,
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: Colors.grey[300],
                            child: const Icon(Icons.person, size: 35, color: Colors.grey),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 2,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Icon(Icons.edit_note, color: Colors.orange, size: 15),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Account Information
                  const SectionTitle(title: 'معلومات الحساب'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _nameController,
                    label: 'الاسم الكامل',
                    validator: (value) =>
                        value == null || value.isEmpty ? 'الاسم مطلوب' : null,
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _emailController,
                    label: 'البريد الإلكتروني',
                    validator: _validateEmail,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _phoneController,
                    label: 'رقم الهاتف',
                    validator: _validatePhone,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _passwordController,
                    label: 'كلمة المرور',
                    validator: _validatePassword,
                    keyboardType: TextInputType.visiblePassword,
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _confirmPasswordController,
                    label: 'تأكيد كلمة المرور',
                    validator: _validateConfirmPassword,
                    keyboardType: TextInputType.visiblePassword,
                  ),
                  const SizedBox(height: 16),
                  // Payment Methods
                  const SectionTitle(title: 'حدد طرق الدفع'),
                  const SizedBox(height: 8),
                  _buildCheckbox('كاش', _cashSelected,
                      (val) => setState(() => _cashSelected = val ?? false)),
                  const SizedBox(height: 8),
                  _buildCheckbox('بطاقة الدفع', _cardSelected,
                      (val) => setState(() => _cardSelected = val ?? false)),
                  const SizedBox(height: 16),
                  // Renter Type
                  const SectionTitle(title: 'حدد نوع التأجير'),
                  const SizedBox(height: 8),
                  _buildCheckbox(
                      'التأجير بسائق',
                      _driverSelected,
                      (val) => setState(() => _driverSelected = val ?? false)),
                  const SizedBox(height: 8),
                  _buildCheckbox(
                      'التاجر بدون سائق',
                      _withoutDriverSelected,
                      (val) => setState(() => _withoutDriverSelected = val ?? false)),
                  const SizedBox(height: 16),
                  // Kilometer Cost
                  const SectionTitle(title: 'تكلفة الكيلومتر'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _kiloCostController,
                    label: 'تكلفة الكيلومتر',
                    validator: (value) => _validateNumericField(value, 'تكلفة الكيلومتر'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8),
                  // Daily Driver Cost
                  const SectionTitle(title: 'تكلفة السائق في اليوم'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _dailyDriverCostController,
                    label: 'تكلفة السائق اليومية',
                    validator: (value) => _validateNumericField(value, 'تكلفة السائق اليومية'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8),
                  // Maximum Kilometers
                  const SectionTitle(title: 'أقصى عدد كيلومترات مسموح في اليوم'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _maxKiloController,
                    label: 'أقصى كيلومترات',
                    validator: (value) => _validateNumericField(value, 'أقصى كيلومترات'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  // Next Button
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewPadding.bottom + 16,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: _onNextPressed,
                        child: const Text(
                          'التالي',
                          style: TextStyle(color: Colors.white, fontSize: 16),
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
    );
  }
}