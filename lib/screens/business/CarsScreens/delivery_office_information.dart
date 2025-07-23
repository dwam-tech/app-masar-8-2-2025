import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:saba2v2/components/UI/section_title.dart';

class DeliveryOfficeInformation extends StatefulWidget {
  const DeliveryOfficeInformation({super.key});

  @override
  State<DeliveryOfficeInformation> createState() =>
      _DeliveryOfficeInformationState();
}

class _DeliveryOfficeInformationState extends State<DeliveryOfficeInformation> {
  final _formKey = GlobalKey<FormState>();

  // Personal Information Controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Office Information Controllers
  final TextEditingController _officeNameController = TextEditingController();
  final TextEditingController _deliveryCostPerKmController = TextEditingController();
  final TextEditingController _driverCostController = TextEditingController();
  final TextEditingController _maxKmPerDayController = TextEditingController();

  // Images Paths
  String? _logoImagePath;
  String? _commercialRegistrationFrontPath;
  String? _commercialRegistrationBackPath;

  // Selection Lists
  final List<String> _paymentMethods = ['كاش', 'بطاقة الدفع'];
  List<bool> _selectedPaymentMethods = [false, false];

  final List<String> _rentalTypes = ['تأجير بسائق', 'تأجير بدون سائق'];
  List<bool> _selectedRentalTypes = [false, false];

  // Password visibility
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _officeNameController.dispose();
    _deliveryCostPerKmController.dispose();
    _driverCostController.dispose();
    _maxKmPerDayController.dispose();
    super.dispose();
  }

  // Validation Methods
  String? _validateRequiredField(String? value, String fieldName) {
    if (value == null || value.isEmpty) return '$fieldName مطلوب';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'البريد الإلكتروني مطلوب';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'يرجى إدخال بريد إلكتروني صحيح';
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'رقم الهاتف مطلوب';
    if (value.length < 10) return 'رقم الهاتف يجب أن يكون على الأقل 10 أرقام';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'كلمة المرور مطلوبة';
    if (value.length < 6) return 'كلمة المرور يجب أن تكون على الأقل 6 أحرف';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'تأكيد كلمة المرور مطلوب';
    if (value != _passwordController.text) return 'كلمة المرور غير متطابقة';
    return null;
  }

  String? _validateNumberField(String? value, String fieldName) {
    if (value == null || value.isEmpty) return '$fieldName مطلوب';
    if (int.tryParse(value) == null) return '$fieldName يجب أن يكون رقماً';
    return null;
  }

  String? _validateSelectionList(List<bool> selections, String fieldName) {
    if (!selections.contains(true)) return 'يجب اختيار $fieldName واحد على الأقل';
    return null;
  }

  // Image Picking Methods
  void _pickImage(String imageType) {
    final simulatedImagePath = '/path/to/$imageType.jpg';
    setState(() {
      switch (imageType) {
        case 'logo':
          _logoImagePath = simulatedImagePath;
          break;
        case 'commercial_front':
          _commercialRegistrationFrontPath = simulatedImagePath;
          break;
        case 'commercial_back':
          _commercialRegistrationBackPath = simulatedImagePath;
          break;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم اختيار صورة $imageType')),
    );
  }

  // Form Submission
  void _onSubmit() {
    // Validate selection lists
    // final paymentMethodsError = _validateSelectionList(_selectedPaymentMethods, 'طريقة دفع');
    // final rentalTypesError = _validateSelectionList(_selectedRentalTypes, 'نوع تأجير');
    //
    // if (_formKey.currentState!.validate() &&
    //     paymentMethodsError == null &&
    //     rentalTypesError == null) {
    //
    //   final data = {
    //     'personalInfo': {
    //       'fullName': _fullNameController.text,
    //       'email': _emailController.text,
    //       'phone': _phoneController.text,
    //       'password': _passwordController.text,
    //     },
    //     'officeInfo': {
    //       'officeName': _officeNameController.text,
    //       'logoImage': _logoImagePath,
    //       'commercialRegistrationFront': _commercialRegistrationFrontPath,
    //       'commercialRegistrationBack': _commercialRegistrationBackPath,
    //       'deliveryCostPerKm': _deliveryCostPerKmController.text,
    //       'driverCostPerDay': _driverCostController.text,
    //       'maxKmPerDay': _maxKmPerDayController.text,
    //     },
    //     'services': {
    //       'paymentMethods': _getSelectedItems(_paymentMethods, _selectedPaymentMethods),
    //       'rentalTypes': _getSelectedItems(_rentalTypes, _selectedRentalTypes),
    //     },
    //   };
    //
    //   debugPrint('Office Registration Data: $data');
    //   context.go('/delivery-homescreen');
    // } else {
    //   // Show errors for selection lists
    //   if (paymentMethodsError != null) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text(paymentMethodsError)),
    //     );
    //   }
    //   if (rentalTypesError != null) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text(rentalTypesError)),
    //     );
    //   }
    // }
    context.go('/delivery-homescreen');
  }

  List<String> _getSelectedItems(List<String> items, List<bool> selections) {
    List<String> selectedItems = [];
    for (int i = 0; i < items.length; i++) {
      if (selections[i]) {
        selectedItems.add(items[i]);
      }
    }
    return selectedItems;
  }

  // Reusable Widgets
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        textAlign: TextAlign.right,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
          suffixIcon: suffixIcon,
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildImagePicker({
    required String label,
    required String imageType,
    required String? imagePath,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () => _pickImage(imageType),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  imagePath != null ? Icons.check_circle : Icons.image_outlined,
                  color: imagePath != null ? Colors.green : Colors.orange,
                ),
              ),
              Text(label, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckboxList({
    required String title,
    required List<String> items,
    required List<bool> selections,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: title),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
              child: CheckboxListTile(
                title: Text(items[index], textAlign: TextAlign.right),
                value: selections[index],
                onChanged: (bool? value) {
                  setState(() {
                    selections[index] = value ?? false;
                  });
                },
                activeColor: Colors.orange,
                checkColor: Colors.white,
                controlAffinity: ListTileControlAffinity.trailing,
              ),
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('معلومات المكتب'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
        ),
        backgroundColor: Colors.grey[50],
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Personal Information Section
                  const SectionTitle(title: 'معلومات الحساب'),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _fullNameController,
                    hintText: 'الاسم كامل',
                    validator: (value) => _validateRequiredField(value, 'الاسم'),
                  ),
                  _buildTextField(
                    controller: _emailController,
                    hintText: 'البريد الإلكتروني',
                    validator: _validateEmail,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  _buildTextField(
                    controller: _phoneController,
                    hintText: 'رقم الهاتف',
                    validator: _validatePhone,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  _buildTextField(
                    controller: _passwordController,
                    hintText: 'كلمة المرور',
                    validator: _validatePassword,
                    obscureText: !_isPasswordVisible,
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
                  _buildTextField(
                    controller: _confirmPasswordController,
                    hintText: 'تأكيد كلمة المرور',
                    validator: _validateConfirmPassword,
                    obscureText: !_isConfirmPasswordVisible,
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
                  
                  // Office Information Section
                  const SectionTitle(title: 'معلومات المكتب'),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _officeNameController,
                    hintText: 'اسم المكتب',
                    validator: (value) => _validateRequiredField(value, 'اسم المكتب'),
                  ),
                  
                  // Office Images Section
                  _buildImagePicker(
                    label: 'شعار المكتب',
                    imageType: 'logo',
                    imagePath: _logoImagePath,
                  ),
                  const SizedBox(height: 16),
                  
                  const SectionTitle(title: 'صور السجل التجاري'),
                  const SizedBox(height: 8),
                  _buildImagePicker(
                    label: 'صورة أمامية',
                    imageType: 'commercial_front',
                    imagePath: _commercialRegistrationFrontPath,
                  ),
                  _buildImagePicker(
                    label: 'صورة خلفية',
                    imageType: 'commercial_back',
                    imagePath: _commercialRegistrationBackPath,
                  ),
                  const SizedBox(height: 16),
                  
                  // Services Section
                  _buildCheckboxList(
                    title: 'حدد طرق الدفع',
                    items: _paymentMethods,
                    selections: _selectedPaymentMethods,
                  ),
                  _buildCheckboxList(
                    title: 'حدد نوع التأجير',
                    items: _rentalTypes,
                    selections: _selectedRentalTypes,
                  ),
                  
                  // Pricing Section
                  const SectionTitle(title: 'معلومات التسعير'),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _deliveryCostPerKmController,
                    hintText: 'تكلفة الكيلو متر',
                    validator: (value) => _validateNumberField(value, 'تكلفة الكيلو متر'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  _buildTextField(
                    controller: _driverCostController,
                    hintText: 'تكلفة السائق في اليوم',
                    validator: (value) => _validateNumberField(value, 'تكلفة السائق'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  _buildTextField(
                    controller: _maxKmPerDayController,
                    hintText: 'أقصى عدد كيلو مترات مسموح في اليوم',
                    validator: (value) => _validateNumberField(value, 'أقصى عدد كيلو مترات'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Submit Button
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewPadding.bottom + 16,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _onSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'انشاء الحساب',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
      ),
    );
  }
}