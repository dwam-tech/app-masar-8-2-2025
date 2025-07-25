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
  static const String _baseUrl = 'http://192.168.1.8:8000';

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
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null || result.files.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لم يتم اختيار أي صورة')));
      }
      return;
    }
    final path = result.files.single.path;
    if (path != null) {
      setState(() => _profileImagePath = path);
      final url = await _uploadFile(path);
      if (url != null) {
        setState(() => _profileImageUrl = url);
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل رفع الصورة: $e')));
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

  Future<void> _submitForm() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;
    if (!_paymentSelections.contains(true) || !_rentalSelections.contains(true)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يجب تحديد طريقة دفع ونوع تأجير')));
      return;
    }
    if (_profileImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء اختيار صورة شخصية')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
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
      if (result['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تسجيل السائق بنجاح'), backgroundColor: Colors.green));
        context.go('/delivery-homescreen');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] ?? 'فشل التسجيل')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('حدث خطأ فادح: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String? _validateRequiredField(String? value, String fieldName) { if (value == null || value.isEmpty) return '$fieldName مطلوب'; return null; }
  String? _validateEmail(String? value) { if (value == null || value.isEmpty) return 'البريد الإلكتروني مطلوب'; if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'البريد الإلكتروني غير صالح'; return null; }
  String? _validatePhone(String? value) { if (value == null || value.isEmpty) return 'رقم الهاتف مطلوب'; if (value.length < 10) return 'رقم الهاتف غير صالح'; return null; }
  String? _validatePassword(String? value) { if (value == null || value.isEmpty) return 'كلمة المرور مطلوبة'; if (value.length < 6) return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل'; return null; }
  String? _validateConfirmPassword(String? value) { if (value == null || value.isEmpty) return 'تأكيد كلمة المرور مطلوب'; if (value != _passwordController.text) return 'كلمات المرور غير متطابقة'; return null; }
  String? _validateNumericField(String? value, String fieldName) { if (value == null || value.isEmpty) return '$fieldName مطلوب'; if (double.tryParse(value) == null) return '$fieldName يجب أن يكون رقمًا'; return null; }

  Widget _buildTextField({ required TextEditingController controller, required String label, required String? Function(String?) validator, TextInputType keyboardType = TextInputType.text, bool obscureText = false, }) { 
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), 
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), 
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
                      _buildTextField(controller: _passwordController, label: 'كلمة المرور', validator: _validatePassword, obscureText: true), 
                      _buildTextField(controller: _confirmPasswordController, label: 'تأكيد كلمة المرور', validator: _validateConfirmPassword, obscureText: true), 
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