// مسار الملف: lib/screens/ResturantScreens/ResturantInformation.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:saba2v2/components/UI/section_title.dart';
import 'package:saba2v2/screens/business/ResturantScreens/ResturantLawData.dart';
import '../../../config/constants.dart';

class RestaurantAccountInfo {
  final String username;
  final String phone;
  final String email;
  final String password;
  final String restaurantName;
  final String? restaurantLogo;
  final String? deliveryCostPerKm;
  final String? depositAmount;
  final String? maxPeople;
  final String? notes;
  final bool hasDeliveryService;
  final bool hasTableReservation;
  final bool wantsDeposit;
  final List<String> cuisineTypes;
  final List<Map<String, String>> branches;

  RestaurantAccountInfo({
    required this.username,
    required this.phone,
    required this.email,
    required this.password,
    required this.restaurantName,
    this.restaurantLogo,
    this.deliveryCostPerKm,
    this.depositAmount,
    this.maxPeople,
    this.notes,
    required this.hasDeliveryService,
    required this.hasTableReservation,
    required this.wantsDeposit,
    required this.cuisineTypes,
    required this.branches,
  });

  // داخل كلاس RestaurantAccountInfo

Map<String, dynamic> toJson() => {
    'username': username, // <<--- هذا هو التعديل الأهم
    'phone': phone,
    'email': email,
    'password': password,
    'restaurant_name': restaurantName,
    'restaurant_logo': restaurantLogo,
    'delivery_cost_per_km': deliveryCostPerKm,
    'deposit_amount': depositAmount,
    'max_people_per_reservation': maxPeople,
    'reservation_notes': notes,
    'delivery_available': hasDeliveryService,
    'table_reservation_available': hasTableReservation,
    'deposit_required': wantsDeposit,
    'cuisine_types': cuisineTypes,
    'branches': branches,
  };


}

class ResturantInformation extends StatefulWidget {
  final RestaurantLegalData legalData;
  const ResturantInformation({super.key, required this.legalData});
  @override
  State<ResturantInformation> createState() => _ResturantInformationState();
}

class _ResturantInformationState extends State<ResturantInformation> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _restaurantNameController = TextEditingController();
  final _deliveryCostPerKmController = TextEditingController();
  final _depositAmountController = TextEditingController();
  final _maxPeopleController = TextEditingController();
  final _notesController = TextEditingController();

  String? _restaurantLogoPath;
  String? _restaurantLogoUrl;

  bool _hasDeliveryService = false;
  bool _hasTableReservation = false;
  bool _wantsDeposit = false;

  final List<String> _cuisineTypes = const ['غربي', 'ايطالي', 'شرقي', 'صيني', 'هندي'];
  List<bool> _selectedCuisineTypes = [false, false, false, false, false];
  
  static const String _baseUrl = AppConstants.baseUrl;
  static const Map<String, List<String>> _governorates = {
    'القاهرة': ['15 مايو', 'الازبكية', 'البساتين', 'التبين', 'الخليفة', 'الدراسة', 'الدرب الاحمر', 'الزاوية الحمراء', 'الزيتون', 'الساحل', 'السلام', 'السيدة زينب', 'الشرابية', 'مدينة الشروق', 'الظاهر', 'العتبة', 'القاهرة الجديدة', 'المرج', 'عزبة النخل', 'المطرية', 'المعادى', 'المعصرة', 'المقطم', 'المنيل', 'الموسكى', 'النزهة', 'الوايلى', 'باب الشعرية', 'بولاق', 'جاردن سيتى', 'حدائق القبة', 'حلوان', 'دار السلام', 'شبرا', 'طره', 'عابدين', 'عباسية', 'عين شمس', 'مدينة نصر', 'مصر الجديدة', 'مصر القديمة', 'منشية ناصر', 'مدينة بدر', 'مدينة العبور', 'وسط البلد', 'الزمالك', 'قصر النيل', 'الرحاب', 'القطامية', 'مدينتي', 'روض الفرج', 'شيراتون', 'الجمالية', 'العاشر من رمضان', 'الحلمية', 'النزهة الجديدة', 'العاصمة الإدارية'],
    'الجيزة': ['الجيزة', 'السادس من أكتوبر', 'الشيخ زايد', 'الحوامدية', 'البدرشين', 'الصف', 'أطفيح', 'العياط', 'الباويطي', 'منشأة القناطر', 'أوسيم', 'كرداسة', 'أبو النمرس', 'كفر غطاطي', 'منشأة البكاري', 'الدقى', 'العجوزة', 'الهرم', 'الوراق', 'امبابة', 'بولاق الدكرور', 'الواحات البحرية', 'العمرانية', 'المنيب', 'بين السرايات', 'الكيت كات', 'المهندسين', 'فيصل', 'أبو رواش', 'حدائق الأهرام', 'الحرانية', 'حدائق اكتوبر', 'صفط اللبن', 'القرية الذكية', 'ارض اللواء'],
    'الأسكندرية': ['ابو قير', 'الابراهيمية', 'الأزاريطة', 'الانفوشى', 'الدخيلة', 'السيوف', 'العامرية', 'اللبان', 'المفروزة', 'المنتزه', 'المنشية', 'الناصرية', 'امبروزو', 'باب شرق', 'برج العرب', 'ستانلى', 'سموحة', 'سيدى بشر', 'شدس', 'غيط العنب', 'فلمينج', 'فيكتوريا', 'كامب شيزار', 'كرموز', 'محطة الرمل', 'مينا البصل', 'العصافرة', 'العجمي', 'بكوس', 'بولكلي', 'كليوباترا', 'جليم', 'المعمورة', 'المندرة', 'محرم بك', 'الشاطبي', 'سيدي جابر', 'الساحل الشمالي', 'الحضرة', 'العطارين', 'سيدي كرير', 'الجمرك', 'المكس', 'مارينا'],
    'الدقهلية': ['المنصورة', 'طلخا', 'ميت غمر', 'دكرنس', 'أجا', 'منية النصر', 'السنبلاوين', 'الكردي', 'بني عبيد', 'المنزلة', 'تمي الأمديد', 'الجمالية', 'شربين', 'المطرية', 'بلقاس', 'ميت سلسيل', 'جمصة', 'محلة دمنة', 'نبروه'],
    'البحر الأحمر': ['الغردقة', 'رأس غارب', 'سفاجا', 'القصير', 'مرسى علم', 'الشلاتين', 'حلايب', 'الدهار'],
    'البحيرة': ['دمنهور', 'كفر الدوار', 'رشيد', 'إدكو', 'أبو المطامير', 'أبو حمص', 'الدلنجات', 'المحمودية', 'الرحمانية', 'إيتاي البارود', 'حوش عيسى', 'شبراخيت', 'كوم حمادة', 'بدر', 'وادي النطرون', 'النوبارية الجديدة', 'النوبارية'],
    'الفيوم': ['الفيوم', 'الفيوم الجديدة', 'طامية', 'سنورس', 'إطسا', 'إبشواي', 'يوسف الصديق', 'الحادقة', 'اطسا', 'الجامعة', 'السيالة'],
    'الغربية': ['طنطا', 'المحلة الكبرى', 'كفر الزيات', 'زفتى', 'السنطة', 'قطور', 'بسيون', 'سمنود'],
    'الإسماعلية': ['حي اول', 'حي ثان', 'حي ثالث', 'فايد', 'القنطرة شرق', 'القنطرة غرب', 'التل الكبير', 'أبو صوير', 'القصاصين الجديدة', 'نفيشة'],
    'المنوفية': ['شبين الكوم', 'مدينة السادات', 'منوف', 'سرس الليان', 'أشمون', 'الباجور', 'قويسنا', 'بركة السبع', 'تلا', 'الشهداء'],
    'المنيا': ['المنيا', 'المنيا الجديدة', 'العدوة', 'مغاغة', 'بني مزار', 'مطاي', 'سمالوط', 'المدينة الفكرية', 'ملوي', 'دير مواس', 'ابو قرقاص', 'ارض سلطان'],
    'القليوبية': ['بنها', 'قليوب', 'شبرا الخيمة', 'القناطر الخيرية', 'الخانكة', 'كفر شكر', 'طوخ', 'قها', 'العبور', 'الخصوص', 'شبين القناطر', 'مسطرد'],
    'الوادي الجديد': ['الخارجة', 'باريس', 'موط', 'الفرافرة', 'بلاط', 'الداخلة'],
    'السويس': ['السويس', 'الجناين', 'عتاقة', 'العين السخنة', 'فيصل'],
    'اسوان': ['أسوان', 'أسوان الجديدة', 'دراو', 'كوم أمبو', 'نصر النوبة', 'كلابشة', 'إدفو', 'الرديسية', 'البصيلية', 'السباعية', 'ابوسمبل السياحية', 'مرسى علم'],
    'اسيوط': ['أسيوط', 'أسيوط الجديدة', 'ديروط', 'منفلوط', 'القوصية', 'أبنوب', 'أبو تيج', 'الغنايم', 'ساحل سليم', 'البداري', 'صدفا'],
    'بني سويف': ['بني سويف', 'بني سويف الجديدة', 'الواسطى', 'ناصر', 'إهناسيا', 'ببا', 'الفشن', 'سمسطا', 'الاباصيرى', 'مقبل'],
    'بورسعيد': ['بورسعيد', 'بورفؤاد', 'العرب', 'حى الزهور', 'حى الشرق', 'حى الضواحى', 'حى المناخ', 'حى مبارك'],
    'دمياط': ['دمياط', 'دمياط الجديدة', 'رأس البر', 'فارسكور', 'الزرقا', 'السرو', 'الروضة', 'كفر البطيخ', 'عزبة البرج', 'ميت أبو غالب', 'كفر سعد'],
    'الشرقية': ['الزقازيق', 'العاشر من رمضان', 'منيا القمح', 'بلبيس', 'مشتول السوق', 'القنايات', 'أبو حماد', 'القرين', 'ههيا', 'أبو كبير', 'فاقوس', 'الصالحية الجديدة', 'الإبراهيمية', 'ديرب نجم', 'كفر صقر', 'أولاد صقر', 'الحسينية', 'صان الحجر القبلية', 'منشأة أبو عمر'],
    'جنوب سيناء': ['الطور', 'شرم الشيخ', 'دهب', 'نويبع', 'طابا', 'سانت كاترين', 'أبو رديس', 'أبو زنيمة', 'رأس سدر'],
    'كفر الشيخ': ['كفر الشيخ', 'وسط البلد كفر الشيخ', 'دسوق', 'فوه', 'مطوبس', 'برج البرلس', 'بلطيم', 'مصيف بلطيم', 'الحامول', 'بيلا', 'الرياض', 'سيدي سالم', 'قلين', 'سيدي غازي'],
    'مطروح': ['مرسى مطروح', 'الحمام', 'العلمين', 'الضبعة', 'النجيلة', 'سيدي براني', 'السلوم', 'سيوة', 'مارينا', 'الساحل الشمالى'],
    'الأقصر': ['الأقصر', 'الأقصر الجديدة', 'إسنا', 'طيبة الجديدة', 'الزينية', 'البياضية', 'القرنة', 'أرمنت', 'الطود'],
    'قنا': ['قنا', 'قنا الجديدة', 'ابو طشت', 'نجع حمادي', 'دشنا', 'الوقف', 'قفط', 'نقادة', 'فرشوط', 'قوص'],
    'شمال سيناء': ['العريش', 'الشيخ زويد', 'نخل', 'رفح', 'بئر العبد', 'الحسنة'],
    'سوهاج': ['سوهاج', 'سوهاج الجديدة', 'أخميم', 'أخميم الجديدة', 'البلينا', 'المراغة', 'المنشأة', 'دار السلام', 'جرجا', 'جهينة الغربية', 'ساقلته', 'طما', 'طهطا', 'الكوثر']
  };

  String? _selectedGovernorate;
  String? _selectedArea;
  final List<Map<String, String>> _branches = [];
  final Set<String> _selectedAreas = {};

  @override
  void dispose() {
    [ _usernameController, _phoneController, _emailController, _passwordController, _confirmPasswordController, _restaurantNameController, _deliveryCostPerKmController, _depositAmountController, _maxPeopleController, _notesController ].forEach((c) => c.dispose());
    super.dispose();
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

  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'يجب إدخال اسم المستخدم';
    }
    if (value.trim().length < 3 || value.trim().length > 20) {
      return 'اسم المستخدم يجب أن يكون بين 3-20 حرف';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value.trim())) {
      return 'اسم المستخدم يجب أن يحتوي على أحرف وأرقام فقط';
    }
    return null;
  }

  String? _validateRestaurantName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'يجب إدخال اسم المطعم';
    }
    if (value.trim().length < 2 || value.trim().length > 50) {
      return 'اسم المطعم يجب أن يكون بين 2-50 حرف';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'يجب إدخال البريد الإلكتروني';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
      return 'البريد الإلكتروني غير صحيح';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'يجب إدخال رقم الهاتف';
    }
    String phone = value.trim().replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (phone.startsWith('+2')) {
      phone = phone.substring(2);
    } else if (phone.startsWith('002')) {
      phone = phone.substring(3);
    }
    if (!RegExp(r'^(010|011|012|015)\d{8}$').hasMatch(phone)) {
      return 'رقم الهاتف غير صحيح (يجب أن يبدأ بـ 010, 011, 012, أو 015)';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'يجب إدخال كلمة المرور';
    }
    if (value.length < 8) {
      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    }
    if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)').hasMatch(value)) {
      return 'كلمة المرور يجب أن تحتوي على أحرف وأرقام';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'يجب تأكيد كلمة المرور';
    }
    if (value != _passwordController.text) {
      return 'كلمات المرور غير متطابقة';
    }
    return null;
  }

  String? _validateDeliveryCost(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    final cost = double.tryParse(value.trim());
    if (cost == null || cost < 0) {
      return 'يجب إدخال رقم صحيح أكبر من أو يساوي صفر';
    }
    return null;
  }

  String? _validateDepositAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    final amount = double.tryParse(value.trim());
    if (amount == null || amount < 0) {
      return 'يجب إدخال رقم صحيح أكبر من أو يساوي صفر';
    }
    return null;
  }

  String? _validateMaxPeople(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    final people = int.tryParse(value.trim());
    if (people == null || people < 1) {
      return 'يجب إدخال رقم صحيح أكبر من صفر';
    }
    return null;
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

  Future<void> _pickLogo() async {
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
      return;
    }

    final path = result.files.single.path;
    if (path != null) {
      setState(() => _restaurantLogoPath = path);
      final url = await _uploadFile(path);
      if (url != null) {
        setState(() => _restaurantLogoUrl = url);
      }
    }
  }

  void _submitForm() {
    // Unfocus all fields
    FocusScope.of(context).unfocus();

    // Validate form
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى تصحيح الأخطاء في النموذج'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    // Check branches
    if (_branches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب إضافة فرع واحد على الأقل'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    // Check restaurant logo
    if (_restaurantLogoUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء اختيار شعار المطعم'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    // Check cuisine types selection
    if (!_selectedCuisineTypes.any((selected) => selected)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب اختيار نوع مطبخ واحد على الأقل'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    // Check delivery service validation
    if (_hasDeliveryService && _deliveryCostPerKmController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب إدخال تكلفة التوصيل عند تفعيل خدمة التوصيل'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    // Check deposit validation
    if (_wantsDeposit && _depositAmountController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب إدخال مبلغ العربون عند تفعيل خيار العربون'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    // Check max people validation
    if (_hasTableReservation && _maxPeopleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب إدخال الحد الأقصى للأفراد عند تفعيل حجز الطاولات'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    try {
      final accountInfo = RestaurantAccountInfo(
        username: _usernameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        restaurantName: _restaurantNameController.text.trim(),
        restaurantLogo: _restaurantLogoUrl,
        deliveryCostPerKm: _deliveryCostPerKmController.text.trim().isEmpty ? null : _deliveryCostPerKmController.text.trim(),
        depositAmount: _depositAmountController.text.trim().isEmpty ? null : _depositAmountController.text.trim(),
        maxPeople: _maxPeopleController.text.trim().isEmpty ? null : _maxPeopleController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        hasDeliveryService: _hasDeliveryService,
        hasTableReservation: _hasTableReservation,
        wantsDeposit: _wantsDeposit,
        cuisineTypes: _cuisineTypes.asMap().entries.where((e) => _selectedCuisineTypes[e.key]).map((e) => e.value).toList(),
        branches: _branches,
      );

      debugPrint('Legal Data (Passed): ${widget.legalData.toJson()}');
      debugPrint('Account Info (Collected): ${accountInfo.toJson()}');

      context.push('/ResturantWorkTime', extra: {
        'legal_data': widget.legalData,
        'account_info': accountInfo,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ غير متوقع: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
  
  Widget _buildRestaurantNameField() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'معلومات المطعم'),
          const SizedBox(height: 16),
          TextFormField(
            key: const ValueKey('restaurantName'),
            controller: _restaurantNameController,
            decoration: InputDecoration(
              hintText: 'اسم المطعم',
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
            ),
            validator: _validateRestaurantName,
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantLogo() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: InkWell(
        onTap: _pickLogo,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _LogoIcon(hasImage: _restaurantLogoPath != null),
              Text(
                _restaurantLogoPath == null ? 'شعار المطعم' : 'تم اختيار الشعار بنجاح',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountInfoFields() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'معلومات الحساب'),
          const SizedBox(height: 16),
          TextFormField(
            key: const ValueKey('username'),
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: 'اسم المستخدم',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: _validateUsername,
          ),
          const SizedBox(height: 16),
          TextFormField(
            key: const ValueKey('phone'),
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'رقم الهاتف',
              prefixIcon: const Icon(Icons.phone),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: _validatePhone,
          ),
          const SizedBox(height: 16),
          TextFormField(
            key: const ValueKey('email'),
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'البريد الإلكتروني',
              prefixIcon: const Icon(Icons.email),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: _validateEmail,
          ),
          const SizedBox(height: 16),
          TextFormField(
            key: const ValueKey('password'),
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'كلمة المرور',
              prefixIcon: const Icon(Icons.lock),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: _validatePassword,
          ),
          const SizedBox(height: 16),
          TextFormField(
            key: const ValueKey('confirmPassword'),
            controller: _confirmPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'تأكيد كلمة المرور',
              prefixIcon: const Icon(Icons.lock_outline),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: _validateConfirmPassword,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCuisineTypes() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text('قم بتحديد نوع المطبخ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500), textAlign: TextAlign.right),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _cuisineTypes.length,
            itemBuilder: (context, index) => _CuisineTypeTile(
              key: ValueKey('cuisine_$index'),
              title: _cuisineTypes[index],
              isSelected: _selectedCuisineTypes[index],
              onChanged: (value) => setState(() => _selectedCuisineTypes[index] = value ?? false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryServiceToggle() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text('هل تتوفر لديك خدمة توصيل؟', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500), textAlign: TextAlign.right),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ToggleOption(label: 'لا', isActive: !_hasDeliveryService, onTap: () => setState(() => _hasDeliveryService = false)),
              const SizedBox(width: 12),
              _ToggleOption(label: 'نعم', isActive: _hasDeliveryService, onTap: () => setState(() => _hasDeliveryService = true)),
            ],
          ),
          if (_hasDeliveryService) ...[
            const SizedBox(height: 16),
            TextFormField(
              key: const ValueKey('deliveryCost'),
              controller: _deliveryCostPerKmController,
              decoration: const InputDecoration(labelText: 'سعر التوصيل لكل كيلومتر', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16)),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: _hasDeliveryService ? _validateDeliveryCost : null,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTableReservationSection() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text('هل تتوفر لديك خدمة حجز طاولات؟', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500), textAlign: TextAlign.right),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ToggleOption(label: 'لا', isActive: !_hasTableReservation, onTap: () => setState(() { _hasTableReservation = false; _wantsDeposit = false; })),
              const SizedBox(width: 12),
              _ToggleOption(label: 'نعم', isActive: _hasTableReservation, onTap: () => setState(() => _hasTableReservation = true)),
            ],
          ),
          if (_hasTableReservation) ...[
            const SizedBox(height: 24),
            const Text('هل ترغب في أخذ عربون للحجز؟', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500), textAlign: TextAlign.right),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ToggleOption(label: 'لا', isActive: !_wantsDeposit, onTap: () => setState(() => _wantsDeposit = false)),
                const SizedBox(width: 12),
                _ToggleOption(label: 'نعم', isActive: _wantsDeposit, onTap: () => setState(() => _wantsDeposit = true)),
              ],
            ),
            if (_wantsDeposit) ...[
              const SizedBox(height: 16),
              TextFormField(
                key: const ValueKey('depositAmount'),
                controller: _depositAmountController,
                decoration: const InputDecoration(labelText: 'مبلغ العربون', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16)),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: _wantsDeposit ? _validateDepositAmount : null,
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              key: const ValueKey('maxPeople'),
              controller: _maxPeopleController,
              decoration: const InputDecoration(labelText: 'الحد الأقصى للأفراد', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16)),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: _hasTableReservation ? _validateMaxPeople : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const ValueKey('notes'),
              controller: _notesController,
              decoration: InputDecoration(labelText: 'ملاحظات للإدارة', border: const OutlineInputBorder(), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), suffixIcon: Icon(Icons.edit, color: Colors.grey.shade600)),
              maxLines: 3,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBranchesSection() {
    final availableAreas = _selectedGovernorate != null ? _governorates[_selectedGovernorate]!.where((area) => !_selectedAreas.contains(area)).toList() : <String>[];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'فروع المطعم'),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            key: const ValueKey('governorate'),
            value: _selectedGovernorate,
            decoration: InputDecoration(
              labelText: 'اختر المحافظة', 
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            items: _governorates.keys.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
            onChanged: (value) => setState(() { _selectedGovernorate = value; _selectedArea = null; }),
            validator: (value) => _branches.isEmpty && _selectedGovernorate == null ? 'يجب إضافة فرع واحد على الأقل' : null,
          ),
          if (_selectedGovernorate != null) ...[
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              key: ValueKey('area_$_selectedGovernorate'),
              value: _selectedArea,
              decoration: InputDecoration(
                labelText: 'اختر المنطقة', 
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              items: availableAreas.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
              onChanged: (value) => setState(() => _selectedArea = value),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: const EdgeInsets.symmetric(vertical: 12)),
                onPressed: () {
                  if (_selectedGovernorate != null && _selectedArea != null) {
                    setState(() {
                      _branches.add({'governorate': _selectedGovernorate!, 'area': _selectedArea!});
                      _selectedAreas.add(_selectedArea!);
                      _selectedGovernorate = null;
                      _selectedArea = null;
                    });
                  }
                },
                child: const Text('إضافة فرع', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
          if (_branches.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _branches.asMap().entries.map((entry) {
                final branch = entry.value;
                return Chip(
                  key: ValueKey('branch_${entry.key}'),
                  label: Text('${branch['governorate']} - ${branch['area']}'),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () => setState(() { _selectedAreas.remove(branch['area']); _branches.remove(branch); }),
                  backgroundColor: Colors.grey[200],
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildToggleOption(String label, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(color: isActive ? Colors.orange : Colors.grey[200], border: Border.all(color: isActive ? Colors.orange : Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
            alignment: Alignment.center,
            child: Text(label, style: TextStyle(color: isActive ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('معلومات المطعم والحساب'),
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
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAccountInfoFields(),
                    _buildRestaurantNameField(),
                    const SizedBox(height: 24),
                    _buildRestaurantLogo(),
                    _buildCuisineTypes(),
                    _buildBranchesSection(),
                    _buildDeliveryServiceToggle(),
                    _buildTableReservationSection(),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: const Text('التالي', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
    );
  }
}

class _LogoIcon extends StatelessWidget {
  final bool hasImage;
  const _LogoIcon({this.hasImage = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Icon(hasImage ? Icons.check_circle : Icons.image_outlined, color: hasImage ? Colors.green : Colors.orange),
    );
  }
}

class _CuisineTypeTile extends StatelessWidget {
  final String title;
  final bool isSelected;
  final ValueChanged<bool?>? onChanged;
  const _CuisineTypeTile({Key? key, required this.title, required this.isSelected, required this.onChanged}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4)),
      child: CheckboxListTile(
        title: Text(title, textAlign: TextAlign.right),
        value: isSelected,
        onChanged: onChanged,
        activeColor: Colors.orange,
        checkColor: Colors.white,
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _ToggleOption({required this.label, required this.isActive, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(color: isActive ? Colors.orange : Colors.grey[200], border: Border.all(color: isActive ? Colors.orange : Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
            alignment: Alignment.center,
            child: Text(label, style: TextStyle(color: isActive ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}