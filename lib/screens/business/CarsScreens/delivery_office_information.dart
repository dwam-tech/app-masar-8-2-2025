import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:saba2v2/components/UI/image_picker_row.dart';
import 'package:saba2v2/components/UI/section_title.dart';
import 'package:saba2v2/providers/auth_provider.dart';
import '../../../config/constants.dart';

class DeliveryOfficeInformation extends StatefulWidget {
  const DeliveryOfficeInformation({super.key});

  @override
  State<DeliveryOfficeInformation> createState() =>
      _DeliveryOfficeInformationState();
}

class _DeliveryOfficeInformationState extends State<DeliveryOfficeInformation> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _officeNameController = TextEditingController();
  final _deliveryCostPerKmController = TextEditingController();
  final _driverCostController = TextEditingController();
  final _maxKmPerDayController = TextEditingController();

  // Image paths and URLs
  String? _logoPath;
  String? _commercialFrontPath;
  String? _commercialBackPath;
  String? _logoUrl;
  String? _commercialFrontUrl;
  String? _commercialBackUrl;
  String? _selectedCity;
  final List<String> _cities = [
    'القاهرة', 'الجيزة', 'الإسكندرية', 'الدقهلية', 'البحر الأحمر',
    'البحيرة', 'الفيوم', 'الغربية', 'الإسماعيلية', 'المنوفية', 'المنيا',
    'القليوبية', 'الوادي الجديد', 'السويس', 'أسوان', 'أسيوط', 'بني سويف',
    'بورسعيد', 'دمياط', 'الشرقية', 'جنوب سيناء', 'كفر الشيخ', 'مطروح',
    'الأقصر', 'قنا', 'شمال سيناء', 'سوهاج'
  ];
  // Selection Lists
  final List<String> _paymentMethods = ['كاش', 'بطاقة الدفع'];
  List<bool> _selectedPaymentMethods = [false, false];
  final List<String> _rentalTypes = ['تأجير بسائق', 'تأجير بدون سائق'];
  List<bool> _selectedRentalTypes = [false, false];

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  static const String _baseUrl = AppConstants.baseUrl; // استبدلي هذا بالـ URL الفعلي

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

   Future<void> _pickFile(String fieldName) async {
    // 1. منع اختيار صورة جديدة أثناء تحميل صورة أخرى
    if (_isLoading) return;

    // 2. طلب صلاحية الوصول للمعرض/الصور
    // هذا الجزء مطابق تمامًا للكود المرجعي للتعامل مع Android و iOS
    PermissionStatus status = await Permission.photos.request();
    if (!status.isGranted && Platform.isAndroid) {
      status = await Permission.storage.request();
    }

    // 3. التحقق من أن الصلاحية قد تم منحها
    if (!status.isGranted) {
      if (context.mounted) {
        debugPrint('Permission Denied: الرجاء منح صلاحية الوصول للصور');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء منح صلاحية الوصول للصور')),
        );
      }
      return;
    }

    // 4. فتح مدير الملفات لاختيار صورة
    final result = await FilePicker.platform.pickFiles(type: FileType.image);

    // 5. التحقق مما إذا كان المستخدم قد اختار صورة أم لا
    if (result == null || result.files.isEmpty) {
      if (context.mounted) {
        debugPrint('No File Selected: لم يتم اختيار أي صورة.');
        // يمكن إظهار رسالة هنا إذا أردتِ، ولكن عادةً لا نفعل شيئًا إذا ألغى المستخدم العملية
      }
      return;
    }

    // 6. الحصول على المسار المحلي للصورة التي تم اختيارها
    final path = result.files.single.path;
    if (path != null) {
      // 7. تحديث الواجهة فورًا لعرض المسار المحلي
      setState(() {
        switch (fieldName) {
          case 'logo':
            _logoPath = path;
            break;
          case 'commercial_front':
            _commercialFrontPath = path;
            break;
          case 'commercial_back':
            _commercialBackPath = path;
            break;
        }
      });

      // 8. استدعاء دالة الرفع لتحميل الصورة على السيرفر
      final url = await _uploadFile(path, fieldName);

      // 9. إذا نجح الرفع وتم استلام رابط، يتم حفظه
      if (url != null) {
        setState(() {
          switch (fieldName) {
            case 'logo':
              _logoUrl = url;
              break;
            case 'commercial_front':
              _commercialFrontUrl = url;
              break;
            case 'commercial_back':
              _commercialBackUrl = url;
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
      request.headers['Accept'] = 'application/json';
      request.files.add(await http.MultipartFile.fromPath('files[]', filePath));

      var response = await request.send().timeout(const Duration(seconds: 45));
      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseData);
        if (jsonResponse['status'] == true && jsonResponse['files'] != null && jsonResponse['files'].isNotEmpty) {
          return jsonResponse['files'][0] as String;
        } else {
          throw Exception(jsonResponse['message'] ?? 'فشل رفع الصورة من السيرفر');
        }
      } else {
        throw Exception('فشل رفع الصورة. رمز الحالة: ${response.statusCode}');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل رفع الصورة: $e')));
      }
      return null;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _removeFile(String fieldName) {
    if (_isLoading) return;
    setState(() {
      switch (fieldName) {
        case 'logo': _logoPath = null; _logoUrl = null; break;
        case 'commercial_front': _commercialFrontPath = null; _commercialFrontUrl = null; break;
        case 'commercial_back': _commercialBackPath = null; _commercialBackUrl = null; break;
      }
    });
  }

  List<String> _getSelectedItems(List<String> items, List<bool> selections) {
    List<String> selectedItems = [];
    for (int i = 0; i < items.length; i++) {
      if (selections[i]) selectedItems.add(items[i]);
    }
    return selectedItems;
  }

  Future<void> _onSubmit() async {
    if (_isLoading) return;

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
    
    if (!_selectedPaymentMethods.contains(true)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب اختيار طريقة دفع واحدة على الأقل'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    if (!_selectedRentalTypes.contains(true)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب اختيار نوع تأجير واحد على الأقل'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    if (_logoUrl == null || _commercialFrontUrl == null || _commercialBackUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء رفع شعار المكتب وصور السجل التجاري'),
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

      final result = await authProvider.registerDeliveryOffice(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim(),
        officeName: _officeNameController.text.trim(),
        logoImageUrl: _logoUrl!,
        governorate: _selectedCity!,
        commercialFrontImageUrl: _commercialFrontUrl!,
        commercialBackImageUrl: _commercialBackUrl!,
        paymentMethods: _getSelectedItems(_paymentMethods, _selectedPaymentMethods),
        rentalTypes: _getSelectedItems(_rentalTypes, _selectedRentalTypes),
        costPerKm: double.parse(_deliveryCostPerKmController.text),
        driverCost: double.parse(_driverCostController.text),
        maxKmPerDay: int.parse(_maxKmPerDayController.text),
      );

      if (!mounted) return;

      // التحقق من صحة الاستجابة
      if (result == null) {
        throw Exception('لم يتم استلام استجابة من الخادم');
      }

      if (result['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إنشاء الحساب بنجاح'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        context.go('/login');
      } else {
        final errorMessage = result['message'] ?? 'حدث خطأ أثناء التسجيل';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
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

  String? _validateRequiredField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName مطلوب';
    if (value.trim().length > 100) return '$fieldName يجب أن يكون أقل من 100 حرف';
    return null;
  }

  String? _validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) return 'الاسم الكامل مطلوب';
    if (value.trim().length < 2) return 'الاسم يجب أن يكون حرفين على الأقل';
    if (value.trim().length > 50) return 'الاسم يجب أن يكون أقل من 50 حرف';
    final nameRegex = RegExp(r'^[\u0600-\u06FF\s]+$');
    if (!nameRegex.hasMatch(value.trim())) return 'الاسم يجب أن يحتوي على أحرف عربية فقط';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'البريد الإلكتروني مطلوب';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) return 'يرجى إدخال بريد إلكتروني صحيح';
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
      return 'يرجى إدخال رقم هاتف مصري صحيح';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'كلمة المرور مطلوبة';
    if (value.length < 8) return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    if (value.length > 50) return 'كلمة المرور يجب أن تكون أقل من 50 حرف';
    if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)').hasMatch(value)) {
      return 'كلمة المرور يجب أن تحتوي على أحرف وأرقام';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'تأكيد كلمة المرور مطلوب';
    if (value != _passwordController.text) return 'كلمتا المرور غير متطابقتين';
    return null;
  }

  String? _validateNumberField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName مطلوب';
    final number = double.tryParse(value.trim());
    if (number == null) return '$fieldName يجب أن يكون رقماً صحيحاً';
    if (number < 0) return '$fieldName يجب أن يكون رقماً موجباً';
    if (number > 10000) return '$fieldName كبير جداً';
    return null;
  }

  String? _validatePositiveNumberField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName مطلوب';
    final number = double.tryParse(value.trim());
    if (number == null) return '$fieldName يجب أن يكون رقماً صحيحاً';
    if (number <= 0) return '$fieldName يجب أن يكون أكبر من صفر';
    if (number > 10000) return '$fieldName كبير جداً';
    return null;
  }

  String? _validateIntegerField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName مطلوب';
    final number = int.tryParse(value.trim());
    if (number == null) return '$fieldName يجب أن يكون رقماً صحيحاً';
    if (number < 1) return '$fieldName يجب أن يكون أكبر من صفر';
    if (number > 1000) return '$fieldName كبير جداً';
    return null;
  }

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
                onChanged: _isLoading ? null : (bool? value) {
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
          title: const Text('تسجيل مكتب توصيل'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
        ),
        backgroundColor: Colors.grey[50],
        body: Stack(
          children: [
            Form(
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
                        validator: _validateFullName,
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
                 
                     
                     SizedBox(height: 5,),
                      _buildTextField(
                        controller: _passwordController,
                        hintText: 'كلمة المرور',
                        validator: _validatePassword,
                        obscureText: !_isPasswordVisible,
                        suffixIcon: IconButton(
                          icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                        ),
                      ),
                        
                      _buildTextField(
                        controller: _confirmPasswordController,
                        hintText: 'تأكيد كلمة المرور',
                        validator: _validateConfirmPassword,
                        obscureText: !_isConfirmPasswordVisible,
                        suffixIcon: IconButton(
                          icon: Icon(_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
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
                      
                      ImagePickerRow(
                        label: 'شعار المكتب',
                        icon: Icons.business_center_outlined,
                        fieldIdentifier: 'logo',
                        onTap: () => _pickFile('logo'),
                        imagePath: _logoPath,
                        onRemove: () => _removeFile('logo'),
                      ),
                      const SizedBox(height: 16),
                      
                      const SectionTitle(title: 'صور السجل التجاري'),
                      const SizedBox(height: 8),
                      ImagePickerRow(
                        label: 'صورة أمامية',
                        icon: Icons.credit_card_outlined,
                        fieldIdentifier: 'commercial_front',
                        onTap: () => _pickFile('commercial_front'),
                        imagePath: _commercialFrontPath,
                        onRemove: () => _removeFile('commercial_front'),
                      ),
                      const SizedBox(height: 12),
                      ImagePickerRow(
                        label: 'صورة خلفية',
                        icon: Icons.credit_card_outlined,
                        fieldIdentifier: 'commercial_back',
                        onTap: () => _pickFile('commercial_back'),
                        imagePath: _commercialBackPath,
                        onRemove: () => _removeFile('commercial_back'),
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
                        validator: (value) => _validatePositiveNumberField(value, 'تكلفة الكيلو متر'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                      ),
                      _buildTextField(
                        controller: _driverCostController,
                        hintText: 'تكلفة السائق في اليوم',
                        validator: (value) => _validateNumberField(value, 'تكلفة السائق'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                      ),
                      _buildTextField(
                        controller: _maxKmPerDayController,
                        hintText: 'أقصى عدد كيلو مترات مسموح في اليوم',
                        validator: (value) => _validateIntegerField(value, 'أقصى عدد كيلو مترات'),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      Padding(
                        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom + 16),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _onSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('انشاء الحساب', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.orange),
                ),
              ),
          ],
        ),
      ),
    );
  }
}