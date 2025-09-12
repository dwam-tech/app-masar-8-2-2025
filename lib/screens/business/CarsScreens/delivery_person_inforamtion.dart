// مسار الملف: lib/screens/delivery_person_information_screen.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:saba2v2/components/UI/section_title.dart';
import 'package:saba2v2/providers/auth_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import '../../../config/constants.dart';

class DeliveryPersonInformationScreen extends StatefulWidget {
  const DeliveryPersonInformationScreen({super.key});
  @override
  State<DeliveryPersonInformationScreen> createState() => _DeliveryPersonInformationScreenState();
}

class _DeliveryPersonInformationScreenState extends State<DeliveryPersonInformationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _kiloCostController = TextEditingController();
  final _dailyDriverCostController = TextEditingController();
  final _maxKiloController = TextEditingController();
  String? _profileImagePath, _profileImageUrl;
  String? _selectedCity;
  final List<String> _cities = ['القاهرة', 'الجيزة', 'الإسكندرية', 'الدقهلية', 'البحر الأحمر', 'البحيرة', 'الفيوم', 'الغربية', 'الإسماعيلية', 'المنوفية', 'المنيا', 'القليوبية', 'الوادي الجديد', 'السويس', 'أسوان', 'أسيوط', 'بني سويف', 'بورسعيد', 'دمياط', 'الشرقية', 'جنوب سيناء', 'كفر الشيخ', 'مطروح', 'الأقصر', 'قنا', 'شمال سيناء', 'سوهاج'];
  final List<String> _paymentMethodLabels = ['كاش', 'بطاقة الدفع'];
  List<bool> _paymentSelections = [false, false];
  final List<String> _rentalTypeLabels = ['تأجير بسائق', 'تأجير بدون سائق'];
  List<bool> _rentalSelections = [false, false];
  
  // Password visibility toggles
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  static const String _baseUrl = AppConstants.baseUrl;

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

  Future<void> _pickFile() async {
    if (_isLoading) return;
    PermissionStatus status = await Permission.photos.request();
    if (!status.isGranted && Platform.isAndroid) {
      status = await Permission.storage.request();
    }
    if (!status.isGranted) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء منح صلاحية الوصول للصور')));
      }
      return;
    }
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: false,
      );
      
      if (result == null || result.files.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('لم يتم اختيار أي صورة'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }
      
      final file = result.files.single;
      
      // التحقق من حجم الملف (أقل من 5 ميجابايت)
      if (file.size > 5 * 1024 * 1024) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('حجم الصورة كبير جداً، يجب أن يكون أقل من 5 ميجابايت'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );
        }
        return;
      }
      
      final path = file.path;
      if (path != null) {
        setState(() => _profileImagePath = path);
        final url = await _uploadFile(path);
        if (url != null) {
          setState(() => _profileImageUrl = url);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في اختيار الصورة: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<String?> _uploadFile(String filePath) async {
    setState(() => _isLoading = true);
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/api/upload'));
      request.headers['Accept'] = 'application/json';
      request.files.add(await http.MultipartFile.fromPath('files[]', filePath));
      var response = await request.send().timeout(const Duration(seconds: 45));
      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseData);
        return jsonResponse['files'][0] as String;
      } else {
        throw Exception('فشل رفع الصورة');
      }
    } catch (e) {
      if (context.mounted) {
        String errorMessage = 'فشل رفع الصورة';
        
        if (e.toString().contains('SocketException') || e.toString().contains('TimeoutException')) {
          errorMessage = 'فشل رفع الصورة: تأكد من اتصالك بالإنترنت';
        } else if (e.toString().contains('413')) {
          errorMessage = 'فشل رفع الصورة: حجم الصورة كبير جداً';
        } else if (e.toString().contains('415')) {
          errorMessage = 'فشل رفع الصورة: نوع الملف غير مدعوم';
        } else if (e.toString().contains('500')) {
          errorMessage = 'فشل رفع الصورة: خطأ في الخادم';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'إعادة المحاولة',
              textColor: Colors.white,
              onPressed: () => _pickFile(),
            ),
          ),
        );
      }
      return null;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<String> _getSelectedItems(List<String> labels, List<bool> selections) { 
    List<String> selected = [];
    for (int i = 0; i < labels.length; i++) {
      if (selections[i]) selected.add(labels[i]);
    }
    return selected;
  }

  String? _getFirstErrorField() {
    if (_validateFullName(_nameController.text) != null) return 'الاسم الكامل';
    if (_validateEmail(_emailController.text) != null) return 'البريد الإلكتروني';
    if (_validatePhone(_phoneController.text) != null) return 'رقم الهاتف';
    if (_validatePassword(_passwordController.text) != null) return 'كلمة المرور';
    if (_validateConfirmPassword(_confirmPasswordController.text) != null) return 'تأكيد كلمة المرور';
    if (_validateNumericField(_kiloCostController.text, 'تكلفة الكيلو') != null) return 'تكلفة الكيلو';
    if (_validateNumericField(_dailyDriverCostController.text, 'تكلفة السائق اليومية') != null) return 'تكلفة السائق اليومية';
    if (_validateIntegerField(_maxKiloController.text, 'أقصى كيلو يومياً') != null) return 'أقصى كيلو يومياً';
    return null;
  }

  Future<void> _submitForm() async {
    if (_isLoading) return;

    // إلغاء التركيز من جميع الحقول
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      // البحث عن أول حقل يحتوي على خطأ والتركيز عليه
      final firstErrorField = _getFirstErrorField();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(firstErrorField != null 
            ? 'خطأ في حقل: $firstErrorField'
            : 'الرجاء تعبئة كل الحقول المطلوبة بشكل صحيح'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'موافق',
            textColor: Colors.white,
            onPressed: () {},
          ),
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

    if (!_paymentSelections.contains(true) || !_rentalSelections.contains(true)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب تحديد طريقة دفع ونوع تأجير'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    if (_profileImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء اختيار صورة شخصية'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // إظهار رسالة تحميل
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 16),
            Text('جاري تسجيل البيانات...'),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 30),
      ),
    );

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // التحقق من وجود AuthProvider
      if (authProvider == null) {
        throw Exception('خدمة المصادقة غير متاحة');
      }

      final result = await authProvider.registerDeliveryPerson(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim(),
        governorate: _selectedCity!,
        profileImageUrl: _profileImageUrl!,
        paymentMethods: _getSelectedItems(_paymentMethodLabels, _paymentSelections),
        rentalTypes: _getSelectedItems(_rentalTypeLabels, _rentalSelections),
        costPerKm: double.parse(_kiloCostController.text),
        driverCost: double.parse(_dailyDriverCostController.text),
        maxKmPerDay: int.parse(_maxKiloController.text),
      );

      if (!mounted) return;

      // التحقق من صحة الاستجابة
      if (result == null) {
        throw Exception('لم يتم استلام استجابة من الخادم');
      }

      if (result['status'] == true) {
        // إخفاء رسالة التحميل
        ScaffoldMessenger.of(context).clearSnackBars();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 16),
                Text('تم تسجيل السائق بنجاح! يرجى التحقق من بريدك الإلكتروني.'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        
        // تأخير قصير قبل الانتقال للصفحة التالية
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            context.go('/otp-verification', extra: _emailController.text);
          }
        });
      } else {
          // إخفاء رسالة التحميل
          ScaffoldMessenger.of(context).clearSnackBars();
          
          // معالجة أخطاء التحقق من الخادم
          if (result['errors'] != null && result['errors'] is Map) {
          final errors = result['errors'] as Map<String, dynamic>;
          String errorMessage = 'خطأ في التحقق من البيانات:\n';
          
          if (errors['email'] != null) {
            errorMessage += '• البريد الإلكتروني مستخدم مسبقاً\n';
          }
          if (errors['phone'] != null) {
            errorMessage += '• رقم الهاتف مستخدم مسبقاً\n';
          }
          if (errors['name'] != null) {
            errorMessage += '• خطأ في الاسم\n';
          }
          
          // إضافة أي أخطاء أخرى
          errors.forEach((key, value) {
            if (key != 'email' && key != 'phone' && key != 'name') {
              if (value is List && value.isNotEmpty) {
                errorMessage += '• ${value.first}\n';
              }
            }
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage.trim()),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 6),
              action: SnackBarAction(
                label: 'موافق',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        } else {
            final errorMessage = result['message'] ?? 'فشل التسجيل';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.white),
                    const SizedBox(width: 16),
                    Expanded(child: Text(errorMessage)),
                  ],
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
                action: SnackBarAction(
                  label: 'موافق',
                  textColor: Colors.white,
                  onPressed: () {},
                ),
              ),
            );
          }
      }
    } on FormatException catch (e) {
      if (mounted) {
        // إخفاء رسالة التحميل
        ScaffoldMessenger.of(context).clearSnackBars();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تنسيق البيانات: ${e.message}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'موافق',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        // إخفاء رسالة التحميل
        ScaffoldMessenger.of(context).clearSnackBars();
        
        String errorMessage = e.toString().replaceAll('Exception: ', '');
        
        // معالجة خاصة لأخطاء الشبكة
        if (errorMessage.contains('SocketException') || errorMessage.contains('TimeoutException')) {
          errorMessage = 'خطأ في الاتصال بالإنترنت، تأكد من اتصالك وحاول مرة أخرى';
        } else if (errorMessage.contains('FormatException')) {
          errorMessage = 'خطأ في تنسيق البيانات المستلمة من الخادم';
        } else if (errorMessage.contains('HttpException')) {
          errorMessage = 'خطأ في الخادم، الرجاء المحاولة لاحقاً';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'إعادة المحاولة',
              textColor: Colors.white,
              onPressed: () => _submitForm(),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // إخفاء رسالة التحميل
        ScaffoldMessenger.of(context).clearSnackBars();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('حدث خطأ غير متوقع، الرجاء المحاولة مرة أخرى'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'إعادة المحاولة',
              textColor: Colors.white,
              onPressed: () => _submitForm(),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String? _validateRequiredField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName مطلوب';
    if (value.trim().length > 100) return '$fieldName طويل جداً (الحد الأقصى 100 حرف)';
    return null;
  }

  String? _validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) return 'الاسم الكامل مطلوب';
    if (value.trim().length < 2) return 'الاسم يجب أن يكون حرفين على الأقل';
    if (value.trim().length > 50) return 'الاسم طويل جداً (الحد الأقصى 50 حرف)';
    if (!RegExp(r'^[\u0600-\u06FFa-zA-Z\s]+$').hasMatch(value.trim())) {
      return 'الاسم يجب أن يحتوي على أحرف عربية أو إنجليزية فقط';
    }
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
    final cleanPhone = value.trim().replaceAll(RegExp(r'[\s\-\(\)]'), '');
    final phoneRegex = RegExp(r'^(010|011|012|015)\d{8}$');
    final phoneWithCountryCode = RegExp(r'^(\+2010|\+2011|\+2012|\+2015)\d{8}$');
    final phoneWithZeros = RegExp(r'^(0020010|0020011|0020012|0020015)\d{8}$');
    
    if (!phoneRegex.hasMatch(cleanPhone) && 
        !phoneWithCountryCode.hasMatch(cleanPhone) && 
        !phoneWithZeros.hasMatch(cleanPhone)) {
      return 'رقم الهاتف غير صحيح يجب ان يبدأ ب 010,011,012,015';
    }
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

  String? _validateNumericField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName مطلوب';
    final numValue = double.tryParse(value.trim());
    if (numValue == null) return '$fieldName يجب أن يكون رقماً صالحاً';
    if (numValue <= 0) return '$fieldName يجب أن يكون أكبر من الصفر';
    if (numValue > 10000) return '$fieldName كبير جداً';
    return null;
  }

  String? _validateIntegerField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName مطلوب';
    final intValue = int.tryParse(value.trim());
    if (intValue == null) return '$fieldName يجب أن يكون رقماً صحيحاً';
    if (intValue <= 0) return '$fieldName يجب أن يكون أكبر من الصفر';
    if (intValue > 1000) return '$fieldName كبير جداً';
    return null;
  }

  Widget _buildTextField({ 
    required TextEditingController controller, 
    required String label, 
    required String? Function(String?) validator, 
    TextInputType keyboardType = TextInputType.text, 
    bool obscureText = false,
    bool isPassword = false,
    VoidCallback? onToggleVisibility,
  }) { 
    return Padding( 
      padding: const EdgeInsets.only(bottom: 12.0), 
      child: TextFormField( 
        controller: controller, 
        keyboardType: keyboardType, 
        obscureText: obscureText, 
        textAlign: TextAlign.right, 
        decoration: InputDecoration( 
          hintText: label, 
          filled: true, 
          fillColor: Colors.grey[100], 
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), 
            borderSide: BorderSide.none
          ), 
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: isPassword ? IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey[600],
            ),
            onPressed: onToggleVisibility,
          ) : null,
        ), 
        validator: validator, 
      ), 
    ); 
  }

  Widget _buildCheckbox(String label, bool value, ValueChanged<bool?> onChanged) { 
    return Container( 
      margin: const EdgeInsets.only(bottom: 8), 
      decoration: BoxDecoration( 
        border: Border.all(color: Colors.grey.shade300), 
        borderRadius: BorderRadius.circular(12), 
      ), 
      child: CheckboxListTile( 
        title: Text(label), 
        value: value, 
        onChanged: _isLoading ? null : onChanged, 
        activeColor: Colors.orange, 
        controlAffinity: ListTileControlAffinity.trailing, 
      ), 
    ); 
  }

  @override
  Widget build(BuildContext context) { 
    return Scaffold( 
      appBar: AppBar( 
        title: const Text('تسجيل سائق جديد'), 
        backgroundColor: Colors.white, 
        foregroundColor: Colors.black, 
        elevation: 1, 
      ), 
      backgroundColor: Colors.grey[50], 
      body: Directionality( 
        textDirection: TextDirection.rtl, 
        child: Stack( 
          children: [ 
            Form( 
              key: _formKey, 
              child: SingleChildScrollView( 
                padding: const EdgeInsets.all(16), 
                child: Container( 
                  padding: const EdgeInsets.all(16), 
                  decoration: BoxDecoration( 
                    color: Colors.white, 
                    borderRadius: BorderRadius.circular(16), 
                  ), 
                  child: Column( 
                    crossAxisAlignment: CrossAxisAlignment.start, 
                    children: [ 
                      Center( 
                        child: GestureDetector( 
                          onTap: _pickFile, 
                          child: Stack( 
                            alignment: Alignment.bottomRight, 
                            children: [ 
                              CircleAvatar( 
                                radius: 45, 
                                backgroundColor: Colors.grey[200], 
                                backgroundImage: _profileImagePath != null ? FileImage(File(_profileImagePath!)) : null, 
                                child: _profileImagePath == null ? Icon(Icons.person, size: 45, color: Colors.grey[400]) : null, 
                              ), 
                              Positioned( 
                                bottom: 0, 
                                right: 0, 
                                child: Container( 
                                  decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle), 
                                  child: const Padding( 
                                    padding: EdgeInsets.all(6.0), 
                                    child: Icon(Icons.edit, color: Colors.white, size: 20), 
                                  ), 
                                ), 
                              ), 
                            ], 
                          ), 
                        ), 
                      ), 
                      const SizedBox(height: 24), 
                      const SectionTitle(title: 'معلومات الحساب'), 
                      const SizedBox(height: 16), 
                      _buildTextField(controller: _nameController, label: 'الاسم الكامل', validator: (v) => _validateRequiredField(v, 'الاسم')), 
                      _buildTextField(controller: _emailController, label: 'البريد الإلكتروني', validator: _validateEmail, keyboardType: TextInputType.emailAddress), 
                      _buildTextField(controller: _phoneController, label: 'رقم الهاتف', validator: _validatePhone, keyboardType: TextInputType.phone), 
                      Padding( 
                        padding: const EdgeInsets.only(bottom: 12.0), 
                        child: DropdownButtonFormField<String>( 
                          value: _selectedCity, 
                          decoration: InputDecoration( 
                            hintText: 'المحافظة', 
                            filled: true, 
                            fillColor: Colors.grey[100], 
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), 
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), 
                          ), 
                          items: _cities.map((String city) => DropdownMenuItem<String>(value: city, child: Text(city))).toList(), 
                          onChanged: (newValue) => setState(() => _selectedCity = newValue), 
                          validator: (value) => value == null ? 'الرجاء اختيار المحافظة' : null, 
                        ), 
                      ), 
                      _buildTextField(
                        controller: _passwordController, 
                        label: 'كلمة المرور', 
                        validator: _validatePassword, 
                        obscureText: !_isPasswordVisible, 
                        isPassword: true,
                        onToggleVisibility: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                      ), 
                      _buildTextField(
                        controller: _confirmPasswordController, 
                        label: 'تأكيد كلمة المرور', 
                        validator: _validateConfirmPassword, 
                        obscureText: !_isConfirmPasswordVisible, 
                        isPassword: true,
                        onToggleVisibility: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                      ), 
                      const SizedBox(height: 16), 
                      const SectionTitle(title: 'حدد طرق الدفع'), 
                      const SizedBox(height: 8), 
                      _buildCheckbox('كاش', _paymentSelections[0], (val) => setState(() => _paymentSelections[0] = val ?? false)), 
                      _buildCheckbox('بطاقة الدفع', _paymentSelections[1], (val) => setState(() => _paymentSelections[1] = val ?? false)), 
                      const SizedBox(height: 16), 
                      const SectionTitle(title: 'حدد نوع التأجير'), 
                      const SizedBox(height: 8), 
                      _buildCheckbox('تأجير بسائق', _rentalSelections[0], (val) => setState(() => _rentalSelections[0] = val ?? false)), 
                      _buildCheckbox('تأجير بدون سائق', _rentalSelections[1], (val) => setState(() => _rentalSelections[1] = val ?? false)), 
                      const SizedBox(height: 16), 
                      const SectionTitle(title: 'معلومات التسعير'), 
                      const SizedBox(height: 16), 
                      _buildTextField(controller: _kiloCostController, label: 'تكلفة الكيلومتر', validator: (v) => _validateNumericField(v, 'تكلفة الكيلومتر'), keyboardType: TextInputType.number), 
                      _buildTextField(controller: _dailyDriverCostController, label: 'تكلفة السائق اليومية', validator: (v) => _validateNumericField(v, 'تكلفة السائق'), keyboardType: TextInputType.number), 
                      _buildTextField(controller: _maxKiloController, label: 'أقصى كيلومترات في اليوم', validator: (v) => _validateNumericField(v, 'أقصى الكيلومترات'), keyboardType: TextInputType.number), 
                      const SizedBox(height: 24), 
                      Padding( 
                        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom + 16), 
                        child: SizedBox( 
                          width: double.infinity, 
                          child: ElevatedButton( 
                            style: ElevatedButton.styleFrom( 
                              backgroundColor: Colors.orange, 
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), 
                              padding: const EdgeInsets.symmetric(vertical: 16), 
                            ), 
                            onPressed: _isLoading ? null : _submitForm, 
                            child: const Text('إنشاء الحساب', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), 
                          ), 
                        ), 
                      ), 
                    ], 
                  ), 
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
      ), 
    ); 
  }
}