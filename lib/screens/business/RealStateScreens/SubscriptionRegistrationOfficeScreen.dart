import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:saba2v2/components/UI/image_picker_row.dart';
import 'package:saba2v2/components/UI/section_title.dart';
import 'package:saba2v2/providers/auth_provider.dart';

class SubscriptionRegistrationOfficeScreen extends StatefulWidget {
  const SubscriptionRegistrationOfficeScreen({super.key});

  @override
  State<SubscriptionRegistrationOfficeScreen> createState() =>
      _SubscriptionRegistrationOfficeScreenState();
}

class _SubscriptionRegistrationOfficeScreenState
    extends State<SubscriptionRegistrationOfficeScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _includesVat = false;

  // Controllers for text fields
  final TextEditingController _officeNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _ConfirmPasswordController = TextEditingController();

  // State for local image paths and uploaded URLs
  String? _officeLogoPath;
  String? _ownerIdFrontPath;
  String? _ownerIdBackPath;
  String? _officePhotoFrontPath;
  String? _crPhotoFrontPath;
  String? _crPhotoBackPath;

  String? _officeLogoUrl;
  String? _ownerIdFrontImageUrl;
  String? _ownerIdBackImageUrl;
  String? _officeImageUrl;
  String? _commercialRegisterFrontImageUrl;
  String? _commercialRegisterBackImageUrl;

  String? _selectedCity;
  final List<String> _cities = [
    'الرياض',
    'جدة',
    'مكة المكرمة',
    'المدينة المنورة',
    'الدمام',
    'الخبر',
    'تبوك',
    'أبها',
    'القصيم',
    'حائل',
  ];

  // Base URL for the Laravel API
  static const String _baseUrl = 'http://192.168.1.7:8000'; // Replace with your actual API base URL

  Future<void> _pickFile(String fieldName) async {
    PermissionStatus status = await Permission.photos.request();

    if (!status.isGranted && Platform.isAndroid) {
      status = await Permission.storage.request();
    }

    if (!status.isGranted) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء منح صلاحية الوصول للصور')),
        );
      }
      return;
    }

    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null || result.files.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('لم يتم العثور على صور. تأكد من وجود صور على الجهاز')),
        );
      }
      return;
    }

    final path = result.files.single.path;
    if (path != null) {
      setState(() {
        switch (fieldName) {
          case 'officeLogo':
            _officeLogoPath = path;
            break;
          case 'ownerIdFront':
            _ownerIdFrontPath = path;
            break;
          case 'ownerIdBack':
            _ownerIdBackPath = path;
            break;
          case 'officePhotoFront':
            _officePhotoFrontPath = path;
            break;
          case 'crPhotoFront':
            _crPhotoFrontPath = path;
            break;
          case 'crPhotoBack':
            _crPhotoBackPath = path;
            break;
        }
      });

      // Upload the image immediately
      final url = await _uploadFile(path, fieldName);
      if (url != null) {
        setState(() {
          switch (fieldName) {
            case 'officeLogo':
              _officeLogoUrl = url;
              break;
            case 'ownerIdFront':
              _ownerIdFrontImageUrl = url;
              break;
            case 'ownerIdBack':
              _ownerIdBackImageUrl = url;
              break;
            case 'officePhotoFront':
              _officeImageUrl = url;
              break;
            case 'crPhotoFront':
              _commercialRegisterFrontImageUrl = url;
              break;
            case 'crPhotoBack':
              _commercialRegisterBackImageUrl = url;
              break;
          }
        });
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل رفع الصورة: $fieldName. الرجاء المحاولة مرة أخرى')),
          );
        }
      }
    }
  }

  Future<String?> _uploadFile(String filePath, String fieldName) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/api/upload'));
      request.files.add(await http.MultipartFile.fromPath('image', filePath));
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseData);
        return jsonResponse['imageUrl'] as String?; // Assuming API returns { "imageUrl": "url" }
      } else {
        return null;
      }
    } catch (e) {
      print('Upload error for $fieldName: $e');
      return null;
    }
  }

  void _removeFile(String fieldName) {
    setState(() {
      switch (fieldName) {
        case 'officeLogo':
          _officeLogoPath = null;
          _officeLogoUrl = null;
          break;
        case 'ownerIdFront':
          _ownerIdFrontPath = null;
          _ownerIdFrontImageUrl = null;
          break;
        case 'ownerIdBack':
          _ownerIdBackPath = null;
          _ownerIdBackImageUrl = null;
          break;
        case 'officePhotoFront':
          _officePhotoFrontPath = null;
          _officeImageUrl = null;
          break;
        case 'crPhotoFront':
          _crPhotoFrontPath = null;
          _commercialRegisterFrontImageUrl = null;
          break;
        case 'crPhotoBack':
          _crPhotoBackPath = null;
          _commercialRegisterBackImageUrl = null;
          break;
      }
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _ConfirmPasswordController.text) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('كلمتا السر غير متطابقتين')));
      return;
    }

    if ([
      _officeLogoUrl,
      _ownerIdFrontImageUrl,
      _ownerIdBackImageUrl,
      _officeImageUrl,
      _commercialRegisterFrontImageUrl,
      _commercialRegisterBackImageUrl
    ].any((url) => url == null)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('الرجاء رفع جميع الصور')));
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.registerRealstateOffice(
      username: _officeNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      phone: _phoneController.text.trim(),
      city: _selectedCity!,
      address: _addressController.text.trim(),
      vat: _includesVat,
      officeLogoPath: _officeLogoUrl!,
      ownerIdFrontPath: _ownerIdFrontImageUrl!,
      ownerIdBackPath: _ownerIdBackImageUrl!,
      officeImagePath: _officeImageUrl!,
      commercialCardFrontPath: _commercialRegisterFrontImageUrl!,
      commercialCardBackPath: _commercialRegisterBackImageUrl!,
    );

    if (result['status']) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إنشاء الحساب بنجاح'), backgroundColor: Colors.green));
      if (mounted) {
        context.go('/RealStateHomeScreen');
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result['message'])));
    }
  }

  Widget _buildFormField({
    required String hintText,
    required TextEditingController controller,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        hintText: hintText,
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
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'هذا الحقل مطلوب';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المستندات المطلوبة'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                child: const SectionTitle(title: 'هوية المكتب'),
              ),
              const SizedBox(height: 16),
              _buildFormField(
                hintText: 'اسم المكتب',
                controller: _officeNameController,
              ),
              const SizedBox(height: 16),
              _buildFormField(
                hintText: 'عنوان المكتب',
                controller: _addressController,
              ),
              const SizedBox(height: 16),
              _buildFormField(
                hintText: 'رقم الهاتف',
                controller: _phoneController,
              ),
              const SizedBox(height: 16),
              Directionality(
                textDirection: TextDirection.rtl,
                child: DropdownButtonFormField<String>(
                  value: _selectedCity,
                  alignment: AlignmentDirectional.centerEnd,
                  decoration: InputDecoration(
                    labelText: 'المحافظة',
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
                  validator: (value) => value == null ? 'الرجاء اختيار المحافظة' : null,
                ),
              ),
              const SizedBox(height: 16),
              _buildFormField(
                hintText: 'البريد الإلكتروني',
                controller: _emailController,
              ),
              const SizedBox(height: 16),
              _buildFormField(
                hintText: 'كلمة السر',
                controller: _passwordController,
                obscureText: true,
              ),
              const SizedBox(height: 16),
              _buildFormField(
                hintText: 'تأكيد كلمة السر',
                controller: _ConfirmPasswordController,
                obscureText: true,
              ),
              const SizedBox(height: 24),
              ImagePickerRow(
                label: 'اختيار شعار المكتب',
                icon: Icons.image_outlined,
                fieldIdentifier: 'officeLogo',
                onTap: () => _pickFile('officeLogo'),
                imagePath: _officeLogoPath,
                onRemove: () => _removeFile('officeLogo'),
              ),

              Container(
                width: double.infinity,
                child: const SectionTitle(title: 'صور هوية المالك'),
              ),
              const SizedBox(height: 16),
              ImagePickerRow(
                label: 'صورة أمامية',
                icon: Icons.image_outlined,
                fieldIdentifier: 'ownerIdFront',
                onTap: () => _pickFile('ownerIdFront'),
                imagePath: _ownerIdFrontPath,
                onRemove: () => _removeFile('ownerIdFront'),
              ),
              const SizedBox(height: 12),
              ImagePickerRow(
                label: 'صورة خلفية',
                icon: Icons.image_outlined,
                fieldIdentifier: 'ownerIdBack',
                onTap: () => _pickFile('ownerIdBack'),
                imagePath: _ownerIdBackPath,
                onRemove: () => _removeFile('ownerIdBack'),
              ),

              Container(
                width: double.infinity,
                child: const SectionTitle(title: 'صورة المكتب'),
              ),
              const SizedBox(height: 16),
              ImagePickerRow(
                label: 'صورة أمامية',
                icon: Icons.image_outlined,
                fieldIdentifier: 'officePhotoFront',
                onTap: () => _pickFile('officePhotoFront'),
                imagePath: _officePhotoFrontPath,
                onRemove: () => _removeFile('officePhotoFront'),
              ),

              Container(
                width: double.infinity,
                child: const SectionTitle(title: 'صور السجل التجاري'),
              ),
              const SizedBox(height: 16),
              ImagePickerRow(
                label: 'صورة أمامية',
                icon: Icons.image_outlined,
                fieldIdentifier: 'crPhotoFront',
                onTap: () => _pickFile('crPhotoFront'),
                imagePath: _crPhotoFrontPath,
                onRemove: () => _removeFile('crPhotoFront'),
              ),
              const SizedBox(height: 12),
              ImagePickerRow(
                label: 'صورة خلفية',
                icon: Icons.image_outlined,
                fieldIdentifier: 'crPhotoBack',
                onTap: () => _pickFile('crPhotoBack'),
                imagePath: _crPhotoBackPath,
                onRemove: () => _removeFile('crPhotoBack'),
              ),

              Container(
                width: double.infinity,
                child: const SectionTitle(title: 'الضريبة'),
              ),
              const SizedBox(height: 16),
              Directionality(
                textDirection: TextDirection.rtl,
                child: SwitchListTile(
                  title: const Text('هل تشمل الأسعار ضريبة القيمة المضافة؟'),
                  value: _includesVat,
                  onChanged: (value) => setState(() => _includesVat = value),
                  activeColor: Colors.orange,
                  contentPadding: EdgeInsets.zero,
                ),
              ),

              const SizedBox(height: 32),
              Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewPadding.bottom + 16,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'التالي',
                      style: TextStyle(
                        fontSize: 18,
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
    );
  }

  @override
  void dispose() {
    _officeNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _ConfirmPasswordController.dispose();
    super.dispose();
  }
}