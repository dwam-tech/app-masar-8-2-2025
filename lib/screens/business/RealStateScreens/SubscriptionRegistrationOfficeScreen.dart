
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // Added for debugPrint
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
  bool _isLoading = false; // Added for loading state

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
  static const String _baseUrl = 'http://192.168.1.8:8000'; // Replace with your actual API base URL

  Future<void> _pickFile(String fieldName) async {
    if (_isLoading) return; // Prevent picking new image during loading

    PermissionStatus status = await Permission.photos.request();

    if (!status.isGranted && Platform.isAndroid) {
      status = await Permission.storage.request();
    }

    if (!status.isGranted) {
      if (context.mounted) {
        debugPrint('Permission Denied: الرجاء منح صلاحية الوصول للصور');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء منح صلاحية الوصول للصور')),
        );
      }
      return;
    }

    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null || result.files.isEmpty) {
      if (context.mounted) {
        debugPrint('No File Selected: لم يتم العثور على صور. تأكد من وجود صور على الجهاز');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لم يتم العثور على صور. تأكد من وجود صور على الجهاز')),
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
      }
    }
  }

  Future<String?> _uploadFile(String filePath, String fieldName) async {
    setState(() => _isLoading = true);
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/api/upload'));
      request.headers['Content-Type'] = 'multipart/form-data'; // Required header
      request.headers['Accept'] = 'application/json'; // Added as requested
      
      // ======================= التعديل هنا =======================
      // تم تغيير اسم الحقل من 'image' إلى 'files[]' ليتطابق مع ما يتوقعه السيرفر
      request.files.add(await http.MultipartFile.fromPath('files[]', filePath));
      // ==========================================================

      var response = await request.send().timeout(Duration(seconds: 30), onTimeout: () {
        throw Exception('انتهت مهلة الاتصال. تأكد من اتصالك بالإنترنت');
      });

      var responseStatus = await response.statusCode;
      // الآن يجب أن لا يظهر خطأ 422
      if (responseStatus != 201 && responseStatus != 200) {
        var responseBody = await response.stream.bytesToString();
        // طباعة جسم الاستجابة للمساعدة في تصحيح الأخطاء
        debugPrint('Error Body: $responseBody');
        throw Exception('فشل الطلب: رمز الحالة $responseStatus');
      }

      var responseData = await response.stream.bytesToString();
      debugPrint('Response Data: $responseData');

      if (response.headers['content-type']?.contains('application/json') ?? false) {
        var jsonResponse = jsonDecode(responseData);

        if (jsonResponse['status'] == true) {
          if (jsonResponse['files'] != null && jsonResponse['files'].isNotEmpty) {
            return jsonResponse['files'][0] as String; // Return the first file URL
          } else {
            throw Exception('لم يتم استرجاع روابط الملفات من الخادم');
          }
        } else {
          throw Exception('فشل رفع الصورة: ${jsonResponse['message'] ?? 'خطأ غير معروف'}');
        }
      } else {
        throw Exception('استجابة غير متوقعة: السيرفر رجع HTML بدل JSON. التحقق من الـ URL.');
      }
    } on SocketException {
      if (context.mounted) {
        debugPrint('SocketException: خطأ في الاتصال بالإنترنت. الرجاء المحاولة مرة أخرى');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في الاتصال بالإنترنت. الرجاء المحاولة مرة أخرى')),
        );
      }
      return null;
    } on FormatException catch (e) {
      if (context.mounted) {
        debugPrint('FormatException: فشل تحليل الاستجابة ($fieldName): $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل تحليل الاستجابة ($fieldName): خطأ في صيغة البيانات')),
        );
      }
      return null;
    } on Exception catch (e) {
      if (context.mounted) {
        debugPrint('Exception: فشل رفع الصورة ($fieldName): $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل رفع الصورة ($fieldName): $e')),
        );
      }
      return null;
    } finally {
      setState(() => _isLoading = false);
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
    if (_isLoading) return; // Prevent multiple submissions

    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _ConfirmPasswordController.text) {
      if (context.mounted) {
        debugPrint('Password Mismatch: كلمتا السر غير متطابقتين');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('كلمتا السر غير متطابقتين')),
        );
      }
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
      if (context.mounted) {
        debugPrint('Missing Images: الرجاء رفع جميع الصور');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء رفع جميع الصور')),
        );
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final result = await authProvider.registerRealstateOffice(
        username: _officeNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim(),
        city: _selectedCity!,
        address: _addressController.text.trim(),
        vat: true,
        officeLogoPath: _officeLogoUrl!,
        ownerIdFrontPath: _ownerIdFrontImageUrl!,
        ownerIdBackPath: _ownerIdBackImageUrl!,
        officeImagePath: _officeImageUrl!,
        commercialCardFrontPath: _commercialRegisterFrontImageUrl!,
        commercialCardBackPath: _commercialRegisterBackImageUrl!,
      ).timeout(Duration(seconds: 30), onTimeout: () {
        throw Exception('انتهت مهلة الاتصال. تأكد من اتصالك بالإنترنت');
      });

      if (result['status']) {
        if (context.mounted) {
          debugPrint('Success: تم إنشاء الحساب بنجاح');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إنشاء الحساب بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        }
        if (mounted) {
          context.go('/RealStateHomeScreen');
        }
      } else {
        if (context.mounted) {
          debugPrint('Failure: ${result['message'] ?? 'حدث خطأ أثناء التسجيل'}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'حدث خطأ أثناء التسجيل')),
          );
        }
      }
    } on SocketException {
      if (context.mounted) {
        debugPrint('SocketException: خطأ في الاتصال بالإنترنت. الرجاء المحاولة مرة أخرى');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطأ في الاتصال بالإنترنت. الرجاء المحاولة مرة أخرى')),
        );
      }
    } on Exception catch (e) {
      if (context.mounted) {
        debugPrint('Exception: حدث خطأ: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
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
      body: Stack(
        children: [
          Form(
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
                      onChanged: _isLoading ? (_) {} : (String? newValue) {
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
                    onTap: _isLoading ? () {} : () => _pickFile('officeLogo'),
                    imagePath: _officeLogoPath,
                    onRemove: _isLoading ? () {} : () => _removeFile('officeLogo'),
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
                    onTap: _isLoading ? () {} : () => _pickFile('ownerIdFront'),
                    imagePath: _ownerIdFrontPath,
                    onRemove: _isLoading ? () {} : () => _removeFile('ownerIdFront'),
                  ),
                  const SizedBox(height: 12),
                  ImagePickerRow(
                    label: 'صورة خلفية',
                    icon: Icons.image_outlined,
                    fieldIdentifier: 'ownerIdBack',
                    onTap: _isLoading ? () {} : () => _pickFile('ownerIdBack'),
                    imagePath: _ownerIdBackPath,
                    onRemove: _isLoading ? () {} : () => _removeFile('ownerIdBack'),
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
                    onTap: _isLoading ? () {} : () => _pickFile('officePhotoFront'),
                    imagePath: _officePhotoFrontPath,
                    onRemove: _isLoading ? () {} : () => _removeFile('officePhotoFront'),
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
                    onTap: _isLoading ? () {} : () => _pickFile('crPhotoFront'),
                    imagePath: _crPhotoFrontPath,
                    onRemove: _isLoading ? () {} : () => _removeFile('crPhotoFront'),
                  ),
                  const SizedBox(height: 12),
                  ImagePickerRow(
                    label: 'صورة خلفية',
                    icon: Icons.image_outlined,
                    fieldIdentifier: 'crPhotoBack',
                    onTap: _isLoading ? () {} : () => _pickFile('crPhotoBack'),
                    imagePath: _crPhotoBackPath,
                    onRemove: _isLoading ? () {} : () => _removeFile('crPhotoBack'),
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
                      onChanged: _isLoading ? (_) {} : (value) => setState(() => _includesVat = value),
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
                        onPressed: _isLoading ? null : _submitForm,
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
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.orange,
                ),
              ),
            ),
        ],
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