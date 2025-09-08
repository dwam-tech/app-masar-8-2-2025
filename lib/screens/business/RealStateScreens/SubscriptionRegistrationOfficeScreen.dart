
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // Added for debugPrint
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:saba2v2/components/UI/image_picker_row.dart';
import 'package:saba2v2/components/UI/section_title.dart';
import 'package:saba2v2/providers/auth_provider.dart';
import '../../../config/constants.dart';

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
  bool _isLoadingLocation = false; // Added for location loading state
  bool _isPasswordVisible = true; // Password visibility toggle
  bool _isConfirmPasswordVisible = true; // Confirm password visibility toggle

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
    'القاهرة', 'الجيزة', 'الإسكندرية', 'الدقهلية', 'البحر الأحمر',
    'البحيرة', 'الفيوم', 'الغربية', 'الإسماعيلية', 'المنوفية', 'المنيا',
    'القليوبية', 'الوادي الجديد', 'السويس', 'أسوان', 'أسيوط', 'بني سويف',
    'بورسعيد', 'دمياط', 'الشرقية', 'جنوب سيناء', 'كفر الشيخ', 'مطروح',
    'الأقصر', 'قنا', 'شمال سيناء', 'سوهاج'
  ];

  // Base URL for the Laravel API
  static const String _baseUrl = AppConstants.baseUrl; // Replace with your actual API base URL

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

  // وظيفة للتحقق من صلاحيات الموقع
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // التحقق من تفعيل خدمة الموقع
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خدمة الموقع غير مفعلة. الرجاء تفعيلها من الإعدادات')),
        );
      }
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم رفض صلاحية الوصول للموقع')),
          );
        }
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('صلاحية الموقع مرفوضة نهائياً. الرجاء تفعيلها من إعدادات التطبيق')),
        );
      }
      return false;
    }

    return true;
  }

  // وظيفة للحصول على الموقع الحالي
  Future<void> _getCurrentLocation() async {
    if (_isLoadingLocation || _isLoading) return;

    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    setState(() => _isLoadingLocation = true);

    try {
      // الحصول على الموقع الحالي
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      debugPrint('Current Position: ${position.latitude}, ${position.longitude}');

      // تحويل الإحداثيات إلى عنوان
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        
        // تكوين العنوان
        String address = '';
        if (place.street != null && place.street!.isNotEmpty) {
          address += place.street!;
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          if (address.isNotEmpty) address += '، ';
          address += place.subLocality!;
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          if (address.isNotEmpty) address += '، ';
          address += place.locality!;
        }
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          if (address.isNotEmpty) address += '، ';
          address += place.administrativeArea!;
        }
        if (place.country != null && place.country!.isNotEmpty) {
          if (address.isNotEmpty) address += '، ';
          address += place.country!;
        }

        // إذا لم نحصل على عنوان مفصل، نستخدم الإحداثيات
        if (address.isEmpty) {
          address = 'خط العرض: ${position.latitude.toStringAsFixed(6)}، خط الطول: ${position.longitude.toStringAsFixed(6)}';
        }

        setState(() {
          _addressController.text = address;
        });

        debugPrint('Address: $address');

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم الحصول على الموقع بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // في حالة عدم وجود عنوان، نستخدم الإحداثيات
        String coordinates = 'خط العرض: ${position.latitude.toStringAsFixed(6)}، خط الطول: ${position.longitude.toStringAsFixed(6)}';
        setState(() {
          _addressController.text = coordinates;
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم الحصول على الإحداثيات بنجاح'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في الحصول على الموقع: $e')),
        );
      }
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _submitForm() async {
    if (_isLoading) return; // Prevent multiple submissions

    // إلغاء التركيز من جميع الحقول
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء تعبئة كل الحقول المطلوبة بشكل صحيح'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    // التحقق من تطابق كلمة المرور
    if (_passwordController.text != _ConfirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('كلمتا المرور غير متطابقتين'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    // التحقق من اختيار المحافظة
    if (_selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء اختيار المحافظة'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    // التحقق من رفع جميع الصور المطلوبة
    if ([
      _officeLogoUrl,
      _ownerIdFrontImageUrl,
      _ownerIdBackImageUrl,
      _officeImageUrl,
      _commercialRegisterFrontImageUrl,
      _commercialRegisterBackImageUrl
    ].any((url) => url == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء رفع جميع الصور المطلوبة'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // التحقق من وجود AuthProvider
      if (authProvider == null) {
        throw Exception('خدمة المصادقة غير متاحة');
      }
      
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
      ).timeout(const Duration(seconds: 30), onTimeout: () {
        throw Exception('انتهت مهلة الاتصال. تأكد من اتصالك بالإنترنت');
      });

      if (!mounted) return;

      // التحقق من صحة الاستجابة
      if (result == null) {
        throw Exception('لم يتم استلام استجابة من الخادم');
      }

      if (result['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تسجيل المكتب بنجاح'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        context.go('/login');
      } else {
        final errorMessage = result['message'] ?? 'فشل التسجيل';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } on SocketException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('خطأ في الاتصال بالإنترنت. الرجاء المحاولة مرة أخرى'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } on FormatException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تنسيق البيانات: ${e.message}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ غير متوقع، الرجاء المحاولة مرة أخرى'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // دوال validation محسنة
  String? _validateRequiredField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName مطلوب';
    if (value.trim().length > 100) return '$fieldName طويل جداً (الحد الأقصى 100 حرف)';
    return null;
  }

  String? _validateOfficeName(String? value) {
    if (value == null || value.trim().isEmpty) return 'اسم المكتب مطلوب';
    if (value.trim().length < 2) return 'اسم المكتب يجب أن يكون حرفين على الأقل';
    if (value.trim().length > 50) return 'اسم المكتب طويل جداً (الحد الأقصى 50 حرف)';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'البريد الإلكتروني مطلوب';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) return 'البريد الإلكتروني غير صالح';
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'رقم الهاتف مطلوب';
    final cleanPhone = value.replaceAll(RegExp(r'[^0-9+]'), '');
    
    // Egyptian mobile number patterns (010, 011, 012, 015)
    final patterns = [
      RegExp(r'^01[0125][0-9]{8}$'), // Normal format: 01xxxxxxxxx
      RegExp(r'^\+2001[0125][0-9]{8}$'), // With country code: +20xxxxxxxxxx
      RegExp(r'^002001[0125][0-9]{8}$'), // With full country code: 00201xxxxxxxxx
    ];
    
    bool isValid = patterns.any((pattern) => pattern.hasMatch(cleanPhone));
    if (!isValid) return 'رقم الهاتف غير صحيح يجب ان يبدأ ب 010,011,012,015';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'كلمة المرور مطلوبة';
    if (value.length < 8) return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*[0-9])').hasMatch(value)) {
      return 'كلمة المرور يجب أن تحتوي على أحرف وأرقام';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'تأكيد كلمة المرور مطلوب';
    if (value != _passwordController.text) return 'كلمات المرور غير متطابقة';
    return null;
  }

  String? _validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) return 'العنوان مطلوب';
    if (value.trim().length < 10) return 'العنوان قصير جداً (الحد الأدنى 10 أحرف)';
    if (value.trim().length > 200) return 'العنوان طويل جداً (الحد الأقصى 200 حرف)';
    return null;
  }

  Widget _buildFormField({
    required String hintText,
    required TextEditingController controller,
    bool obscureText = false,
    bool isPassword = false,
    VoidCallback? onToggleVisibility,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      textAlign: TextAlign.right,
      keyboardType: keyboardType,
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
        suffixIcon: isPassword ? IconButton(
          icon: Icon(
            obscureText ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey[600],
          ),
          onPressed: onToggleVisibility,
        ) : null,
      ),
      validator: validator ?? (value) {
        if (value == null || value.trim().isEmpty) {
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
                    validator: _validateOfficeName,
                  ),
                  const SizedBox(height: 16),
                  // حقل عنوان المكتب مع زر الموقع
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _addressController,
                        textAlign: TextAlign.right,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'عنوان المكتب',
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
                          suffixIcon: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: IconButton(
                              onPressed: (_isLoading || _isLoadingLocation) ? null : _getCurrentLocation,
                              icon: _isLoadingLocation 
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.my_location, color: Colors.blue),
                              tooltip: 'الحصول على الموقع الحالي',
                            ),
                          ),
                        ),
                        validator: _validateAddress,
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          'اضغط على أيقونة الموقع للحصول على موقعك الحالي تلقائياً',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildFormField(
                    hintText: 'رقم الهاتف',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    validator: _validatePhone,
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
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 16),
                  _buildFormField(
                    hintText: 'كلمة السر',
                    controller: _passwordController,
                    obscureText: _isPasswordVisible,
                    isPassword: true,
                    onToggleVisibility: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 16),
                  _buildFormField(
                    hintText: 'تأكيد كلمة السر',
                    controller: _ConfirmPasswordController,
                    obscureText: _isConfirmPasswordVisible,
                    isPassword: true,
                    onToggleVisibility: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                    validator: _validateConfirmPassword,
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
                          'إنشاء حساب',
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