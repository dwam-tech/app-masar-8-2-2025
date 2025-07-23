import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saba2v2/components/UI/image_picker_row.dart';
import 'package:saba2v2/components/UI/section_title.dart';
import 'package:saba2v2/components/UI/radio_group.dart';

class DriverCarInfo extends StatefulWidget {
  const DriverCarInfo({super.key});

  @override
  State<DriverCarInfo> createState() => _DriverCarInfoState();
}

class _DriverCarInfoState extends State<DriverCarInfo> {
  final _formKey = GlobalKey<FormState>();

  // Car Type
  String? _carType = 'اقتصادي';

  // Text Field Controllers
  final TextEditingController _carModelController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _plateNumberController = TextEditingController();

  // Image Paths
  String? _licenseFrontImagePath;
  String? _licenseBackImagePath;
  String? _carRegistrationFrontImagePath;
  String? _carRegistrationBackImagePath;
  String? _carFrontImagePath;
  String? _carBackImagePath;

  @override
  void dispose() {
    _carModelController.dispose();
    _colorController.dispose();
    _plateNumberController.dispose();
    super.dispose();
  }

  // Validation Methods
  String? _validateRequiredField(String? value, String fieldName) {
    if (value == null || value.isEmpty) return '$fieldName مطلوب';
    return null;
  }

  String? _validateImage(String? imagePath, String fieldName) {
    if (imagePath == null) return 'صورة $fieldName مطلوبة';
    return null;
  }

  // Image Picking Simulation
  void _pickImage(String fieldIdentifier) {
    final simulatedImagePath = '/path/to/$fieldIdentifier.jpg';
    setState(() {
      switch (fieldIdentifier) {
        case 'license_front':
          _licenseFrontImagePath = simulatedImagePath;
          break;
        case 'license_back':
          _licenseBackImagePath = simulatedImagePath;
          break;
        case 'car_registration_front':
          _carRegistrationFrontImagePath = simulatedImagePath;
          break;
        case 'car_registration_back':
          _carRegistrationBackImagePath = simulatedImagePath;
          break;
        case 'car_front':
          _carFrontImagePath = simulatedImagePath;
          break;
        case 'car_back':
          _carBackImagePath = simulatedImagePath;
          break;
      }
    });
  }

  void _removeImage(String fieldIdentifier) {
    setState(() {
      switch (fieldIdentifier) {
        case 'license_front':
          _licenseFrontImagePath = null;
          break;
        case 'license_back':
          _licenseBackImagePath = null;
          break;
        case 'car_registration_front':
          _carRegistrationFrontImagePath = null;
          break;
        case 'car_registration_back':
          _carRegistrationBackImagePath = null;
          break;
        case 'car_front':
          _carFrontImagePath = null;
          break;
        case 'car_back':
          _carBackImagePath = null;
          break;
      }
    });
  }

  // Form Submission
  void _onSubmit() {
    // if (_formKey.currentState!.validate()) {
    //   final data = {
    //     'drivingLicenseImages': {
    //       'frontImage': _licenseFrontImagePath,
    //       'backImage': _licenseBackImagePath,
    //     },
    //     'carRegistrationImages': {
    //       'frontImage': _carRegistrationFrontImagePath,
    //       'backImage': _carRegistrationBackImagePath,
    //     },
    //     'carImages': {
    //       'frontImage': _carFrontImagePath,
    //       'backImage': _carBackImagePath,
    //     },
    //     'carInfo': {
    //       'carType': _carType,
    //       'carModel': _carModelController.text,
    //       'color': _colorController.text,
    //       'plateNumber': _plateNumberController.text,
    //     },
    //   };
    //
    //   debugPrint('Submitted Car Info: $data');
    //   context.push('/confirmation', extra: data);
    // }
    context.go('/RealStateHomeScreen');
  }

  // Reusable Widgets
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildImagePicker({
    required String label,
    required String fieldIdentifier,
    required String? imagePath,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ImagePickerRow(
              label: label,
              icon: Icons.camera_alt,
              fieldIdentifier: fieldIdentifier,
              onTap: () => _pickImage(fieldIdentifier),
              imagePath: imagePath,
              onRemove: () => _removeImage(fieldIdentifier),
            ),
            if (validator(imagePath) != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0, right: 12.0),
                child: Text(
                  validator(imagePath)!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل السيارة'),
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
                  // Driving License Images Section
                  const SectionTitle(title: 'صور رخصة القيادة سارية'),
                  const SizedBox(height: 8),
                  _buildImagePicker(
                    label: 'صورة أمامية',
                    fieldIdentifier: 'license_front',
                    imagePath: _licenseFrontImagePath,
                    validator: (value) => _validateImage(value, 'رخصة القيادة (الأمام)'),
                  ),
                  _buildImagePicker(
                    label: 'صورة خلفية',
                    fieldIdentifier: 'license_back',
                    imagePath: _licenseBackImagePath,
                    validator: (value) => _validateImage(value, 'رخصة القيادة (الخلف)'),
                  ),
                  const SizedBox(height: 16),
        
                  // Car Registration Images Section
                  const SectionTitle(title: 'صور رخصة السيارة سارية'),
                  const SizedBox(height: 8),
                  _buildImagePicker(
                    label: 'صورة أمامية',
                    fieldIdentifier: 'car_registration_front',
                    imagePath: _carRegistrationFrontImagePath,
                    validator: (value) => _validateImage(value, 'رخصة السيارة (الأمام)'),
                  ),
                  _buildImagePicker(
                    label: 'صورة خلفية',
                    fieldIdentifier: 'car_registration_back',
                    imagePath: _carRegistrationBackImagePath,
                    validator: (value) => _validateImage(value, 'رخصة السيارة (الخلف)'),
                  ),
                  const SizedBox(height: 16),
        
                  // Car Images Section
                  const SectionTitle(title: 'صور أمامية وخلفية للسيارة'),
                  const SizedBox(height: 8),
                  _buildImagePicker(
                    label: 'صورة أمامية',
                    fieldIdentifier: 'car_front',
                    imagePath: _carFrontImagePath,
                    validator: (value) => _validateImage(value, 'السيارة (الأمام)'),
                  ),
                  _buildImagePicker(
                    label: 'صورة خلفية',
                    fieldIdentifier: 'car_back',
                    imagePath: _carBackImagePath,
                    validator: (value) => _validateImage(value, 'السيارة (الخلف)'),
                  ),
                  RadioGroup(
                    title: 'نوع السيارة',
                    options: const {
                      'اقتصادي': 'اقتصادي',
                      'مميز': 'مميز',
                    },
                    groupValue: _carType,
                    onChanged: (value) => setState(() => _carType = value),
                  ),
                  const SizedBox(height: 16),
        
                  // Car Information Section
                  const SectionTitle(title: 'معلومات السيارة'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _carModelController,
                    label: 'موديل السيارة',
                    validator: (value) => _validateRequiredField(value, 'موديل السيارة'),
                  ),
                  _buildTextField(
                    controller: _colorController,
                    label: 'لون السيارة',
                    validator: (value) => _validateRequiredField(value, 'لون السيارة'),
                  ),
                  _buildTextField(
                    controller: _plateNumberController,
                    label: 'رقم اللوحة',
                    validator: (value) => _validateRequiredField(value, 'رقم اللوحة'),
                  ),
                  const SizedBox(height: 24),
        
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _onSubmit,
                      child: const Text(
                        'إرسال',
                        style: TextStyle(color: Colors.white, fontSize: 16),
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