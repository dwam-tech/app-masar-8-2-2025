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
  static const String _baseUrl = 'http://192.168.1.7:8000'; // استبدل هذا بالـ URL الفعلي

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

  Future<void> _submitForm() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('يجب الموافقة على الشروط والأحكام')),
        );
        return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('كلمتا السر غير متطابقتين')));
      return;
    }
    
    // تأكد من رفع الصور المطلوبة (الهوية على الأقل)
    if (_profileImageUrl == null || _agentIdFrontImageUrl == null || _agentIdBackImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء رفع صورة الملف الشخصي وصور الهوية')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
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
      );

      if (result['status']) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إنشاء الحساب بنجاح'), backgroundColor: Colors.green),
          );
          context.go('/RealStateHomeScreen');
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'حدث خطأ أثناء التسجيل')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
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
      ),
      validator: (value) {
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
                  _buildFormField(hintText: 'كلمة السر', controller: _passwordController, obscureText: true),
                  const SizedBox(height: 16),
                  _buildFormField(hintText: 'تأكيد كلمة السر', controller: _confirmPasswordController, obscureText: true),
                  
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