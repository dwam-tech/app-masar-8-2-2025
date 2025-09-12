import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:saba2v2/components/UI/image_picker_row.dart';
import 'package:saba2v2/components/UI/section_title.dart';
import 'package:saba2v2/providers/auth_provider.dart'; // تأكد من وجود هذا الـ Provider
import '../../../config/constants.dart';


class SubscriptionRegistrationSingleScreen extends StatefulWidget {
  const SubscriptionRegistrationSingleScreen({super.key});

  @override
  State<SubscriptionRegistrationSingleScreen> createState() =>
      _SubscriptionRegistrationSingleScreenState();
}

class _SubscriptionRegistrationSingleScreenState
    extends State<SubscriptionRegistrationSingleScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _acceptTerms = false;

  // Controllers for text fields
  final TextEditingController _agentNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Password visibility toggles
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // State for local image paths and uploaded URLs
  String? _profileImagePath;
  String? _agentIdFrontPath;
  String? _agentIdBackPath;
  String? _taxCardFrontPath;
  String? _taxCardBackPath;

  String? _profileImageUrl;
  String? _agentIdFrontImageUrl;
  String? _agentIdBackImageUrl;
  String? _taxCardFrontImageUrl;
  String? _taxCardBackImageUrl;

  String? _selectedCity;
  final List<String> _cities = [
    'القاهرة', 'الجيزة', 'الإسكندرية', 'الدقهلية', 'البحر الأحمر',
    'البحيرة', 'الفيوم', 'الغربية', 'الإسماعيلية', 'المنوفية', 'المنيا',
    'القليوبية', 'الوادي الجديد', 'السويس', 'أسوان', 'أسيوط', 'بني سويف',
    'بورسعيد', 'دمياط', 'الشرقية', 'جنوب سيناء', 'كفر الشيخ', 'مطروح',
    'الأقصر', 'قنا', 'شمال سيناء', 'سوهاج'
  ];

  // Base URL for the Laravel API
  static const String _baseUrl = AppConstants.baseUrl; // استبدل هذا بالـ URL الفعلي

  Future<void> _pickFile(String fieldName) async {
    if (_isLoading) return;

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
    if (result == null || result.files.isEmpty) return;

    final path = result.files.single.path;
    if (path != null) {
      setState(() {
        switch (fieldName) {
          case 'profileImage': _profileImagePath = path; break;
          case 'agentIdFront': _agentIdFrontPath = path; break;
          case 'agentIdBack': _agentIdBackPath = path; break;
          case 'taxCardFront': _taxCardFrontPath = path; break;
          case 'taxCardBack': _taxCardBackPath = path; break;
        }
      });

      final url = await _uploadFile(path, fieldName);
      if (url != null) {
        setState(() {
          switch (fieldName) {
            case 'profileImage': _profileImageUrl = url; break;
            case 'agentIdFront': _agentIdFrontImageUrl = url; break;
            case 'agentIdBack': _agentIdBackImageUrl = url; break;
            case 'taxCardFront': _taxCardFrontImageUrl = url; break;
            case 'taxCardBack': _taxCardBackImageUrl = url; break;
          }
        });
      }
    }
  }

  Future<String?> _uploadFile(String filePath, String fieldName) async {
    setState(() => _isLoading = true);
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/api/upload'));
      request.headers['Content-Type'] = 'multipart/form-data';
      request.headers['Accept'] = 'application/json';
      request.files.add(await http.MultipartFile.fromPath('files[]', filePath));

      var response = await request.send().timeout(const Duration(seconds: 30));
      var responseStatus = response.statusCode;

      if (responseStatus != 201 && responseStatus != 200) {
        var responseBody = await response.stream.bytesToString();
        debugPrint('Error Body: $responseBody');
        throw Exception('فشل الطلب: رمز الحالة $responseStatus');
      }

      var responseData = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseData);

      if (jsonResponse['status'] == true && jsonResponse['files'] != null && jsonResponse['files'].isNotEmpty) {
        return jsonResponse['files'][0] as String;
      } else {
        throw Exception(jsonResponse['message'] ?? 'فشل رفع الصورة');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل رفع الصورة: $e')));
      }
      return null;
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _removeFile(String fieldName) {
    setState(() {
      switch (fieldName) {
        case 'profileImage': _profileImagePath = null; _profileImageUrl = null; break;
        case 'agentIdFront': _agentIdFrontPath = null; _agentIdFrontImageUrl = null; break;
        case 'agentIdBack': _agentIdBackPath = null; _agentIdBackImageUrl = null; break;
        case 'taxCardFront': _taxCardFrontPath = null; _taxCardFrontImageUrl = null; break;
        case 'taxCardBack': _taxCardBackPath = null; _taxCardBackImageUrl = null; break;
      }
    });
  }

  // Validation functions
  String? _validateRequiredField(String? value, {int maxLength = 100}) {
    if (value == null || value.trim().isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    if (value.trim().length > maxLength) {
      return 'يجب ألا يتجاوز النص $maxLength حرف';
    }
    return null;
  }

  String? _validateAgentName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'اسم الوسيط مطلوب';
    }
    if (value.trim().length < 2 || value.trim().length > 50) {
      return 'يجب أن يكون اسم الوسيط بين 2 و 50 حرف';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'يرجى إدخال بريد إلكتروني صحيح';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'رقم الهاتف مطلوب';
    }
    // Egyptian phone number patterns
    final phoneRegex = RegExp(r'^(\+20|0020|20)?1[0125][0-9]{8}$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[\s-]'), ''))) {
      return 'يرجى إدخال رقم هاتف مصري صحيح';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }
    if (value.length < 8) {
      return 'يجب أن تكون كلمة المرور 8 أحرف على الأقل';
    }
    if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*[0-9])').hasMatch(value)) {
      return 'يجب أن تحتوي كلمة المرور على أحرف وأرقام';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'تأكيد كلمة المرور مطلوب';
    }
    if (value != _passwordController.text) {
      return 'كلمتا المرور غير متطابقتين';
    }
    return null;
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
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('كلمتا المرور غير متطابقتين'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    // التحقق من الموافقة على الشروط
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب الموافقة على الشروط والأحكام'),
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
    
    // التحقق من رفع الصور المطلوبة
    if (_profileImageUrl == null || _agentIdFrontImageUrl == null || _agentIdBackImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء رفع صورة الملف الشخصي وصور الهوية'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // التحقق من توفر AuthProvider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider == null) {
        throw Exception('خدمة المصادقة غير متوفرة');
      }

      // استدعاء الدالة الجديدة من الـ Provider
      final result = await authProvider.registerIndividualAgent(
        name: _agentNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim(),
        governorate: _selectedCity!,
        profileImage: _profileImageUrl!,
        agentIdFrontImage: _agentIdFrontImageUrl!,
        agentIdBackImage: _agentIdBackImageUrl!,
        // الصور الاختيارية
        taxCardFrontImage: _taxCardFrontImageUrl,
        taxCardBackImage: _taxCardBackImageUrl,
      ).timeout(const Duration(seconds: 30));

      // التحقق من صحة الاستجابة
      if (result == null) {
        throw Exception('لم يتم الحصول على استجابة من الخادم');
      }

      if (result['status'] == true) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إنشاء الحساب بنجاح! يرجى التحقق من بريدك الإلكتروني.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
          context.go('/otp-verification', extra: _emailController.text);
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'حدث خطأ أثناء التسجيل'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } on SocketException {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لا يوجد اتصال بالإنترنت'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } on FormatException {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('خطأ في تنسيق البيانات المستلمة من الخادم'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } on Exception catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ غير متوقع'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _agentNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Widget _buildFormField({
    required String hintText,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool isPassword = false,
    VoidCallback? onToggleVisibility,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey[600],
                ),
                onPressed: onToggleVisibility,
              )
            : null,
      ),
      validator: validator ?? (value) {
        if (value == null || value.isEmpty) return 'هذا الحقل مطلوب';
        if (hintText == 'البريد الإلكتروني' && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'بريد إلكتروني غير صحيح';
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
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle(title: 'معلومات الوسيط'),
                  const SizedBox(height: 16),
                  _buildFormField(hintText: 'اسم الوسيط العقاري', controller: _agentNameController),
                  const SizedBox(height: 16),
                  _buildFormField(hintText: 'البريد الإلكتروني', controller: _emailController, keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 16),
                  _buildFormField(hintText: 'رقم الهاتف', controller: _phoneController, keyboardType: TextInputType.phone),
                  const SizedBox(height: 16),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: DropdownButtonFormField<String>(
                      value: _selectedCity,
                      decoration: InputDecoration(
                        labelText: 'المحافظة',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none),
                      ),
                      items: _cities.map((String city) => DropdownMenuItem<String>(value: city, child: Text(city, textAlign: TextAlign.right))).toList(),
                      onChanged: _isLoading ? null : (v) => setState(() => _selectedCity = v),
                      validator: (v) => v == null ? 'الرجاء اختيار المحافظة' : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFormField(
                    hintText: 'كلمة السر', 
                    controller: _passwordController, 
                    obscureText: !_isPasswordVisible,
                    isPassword: true,
                    onToggleVisibility: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ),
                  const SizedBox(height: 16),
                  _buildFormField(
                    hintText: 'تأكيد كلمة السر', 
                    controller: _confirmPasswordController, 
                    obscureText: !_isConfirmPasswordVisible,
                    isPassword: true,
                    onToggleVisibility: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                  ),
                  
                  const SizedBox(height: 24),
                  const SectionTitle(title: 'صورة الملف الشخصي'),
                  const SizedBox(height: 16),
                  ImagePickerRow(
                    label: 'اختيار صورة',
                    icon: Icons.person_outline,
                    fieldIdentifier: 'profileImage',
                    onTap: () => _pickFile('profileImage'),
                    imagePath: _profileImagePath,
                    onRemove: () => _removeFile('profileImage'),
                  ),

                  const SectionTitle(title: 'هوية الوسيط العقاري'),
                  const SizedBox(height: 16),
                  ImagePickerRow(
                    label: 'الهوية الأمامية',
                    icon: Icons.credit_card,
                    fieldIdentifier: 'agentIdFront',
                    onTap: () => _pickFile('agentIdFront'),
                    imagePath: _agentIdFrontPath,
                    onRemove: () => _removeFile('agentIdFront'),
                  ),
                  const SizedBox(height: 12),
                  ImagePickerRow(
                    label: 'الهوية الخلفية',
                    icon: Icons.credit_card,
                    fieldIdentifier: 'agentIdBack',
                    onTap: () => _pickFile('agentIdBack'),
                    imagePath: _agentIdBackPath,
                    onRemove: () => _removeFile('agentIdBack'),
                  ),

                  const SectionTitle(title: 'بطاقة ضريبية (إن وجدت)'),
                  const SizedBox(height: 16),
                  ImagePickerRow(
                    label: 'الوجه الأمامي للبطاقة',
                    icon: Icons.receipt_long,
                    fieldIdentifier: 'taxCardFront',
                    onTap: () => _pickFile('taxCardFront'),
                    imagePath: _taxCardFrontPath,
                    onRemove: () => _removeFile('taxCardFront'),
                  ),
                  const SizedBox(height: 12),
                  ImagePickerRow(
                    label: 'الوجه الخلفي للبطاقة',
                    icon: Icons.receipt_long,
                    fieldIdentifier: 'taxCardBack',
                    onTap: () => _pickFile('taxCardBack'),
                    imagePath: _taxCardBackPath,
                    onRemove: () => _removeFile('taxCardBack'),
                  ),

                  const SizedBox(height: 24),
                   Directionality(
                    textDirection: TextDirection.rtl,
                    child: CheckboxListTile(
                      title: TextButton(
                          onPressed: () => showTermsDialog(context),
                          child: const Text('أوافق على الشروط والأحكام'),
                        ),
                      value: _acceptTerms,
                      onChanged: (v) => setState(() => _acceptTerms = v ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: Colors.orange,
                    ),
                  ),

                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('إنشاء الحساب', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator(color: Colors.orange)),
            ),
        ],
      ),
    );
  }

  void showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('الشروط والأحكام'),
        content: const SingleChildScrollView(child: Text('...نص الشروط والأحكام هنا...')),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('موافق'))],
      ),
    );
  }
}