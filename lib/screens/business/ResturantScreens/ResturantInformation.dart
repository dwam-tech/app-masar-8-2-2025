import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:saba2v2/components/UI/section_title.dart';
import 'package:saba2v2/screens/business/ResturantScreens/ResturantLawData.dart';

class RestaurantAccountInfo {
  final String username;
  final String phone;
  final String email;
  final String password;
  final String restaurantName;
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

  Map<String, dynamic> toJson() => {
        'phone': phone,
        'email': email,
        'password': password,
        'restaurant_name': restaurantName,
        'delivery_cost_per_km': deliveryCostPerKm,
        'deposit_amount': depositAmount,
        'max_people': maxPeople,
        'notes': notes,
        'has_delivery_service': hasDeliveryService,
        'has_table_reservation': hasTableReservation,
        'wants_deposit': wantsDeposit,
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
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _restaurantNameController =
      TextEditingController();
  final TextEditingController _deliveryCostPerKmController =
      TextEditingController();
  final TextEditingController _depositAmountController =
      TextEditingController();
  final TextEditingController _maxPeopleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String? _restaurantLogo;
  bool _hasDeliveryService = false;
  bool _hasTableReservation = false;
  bool _wantsDeposit = false;

  final List<String> _cuisineTypes = const [
    'غربي',
    'ايطالي',
    'شرقي',
    'صيني',
    'هندي'
  ];
  final List<bool> _selectedCuisineTypes = [false, false, false, false, false];

  // Static governorates map for performance
  static const Map<String, List<String>> _governorates = {
    'القاهرة': [
      '15 مايو',
      'الازبكية',
      'البساتين',
      'التبين',
      'الخليفة',
      'الدراسة',
      'الدرب الاحمر',
      'الزاوية الحمراء',
      'الزيتون',
      'الساحل',
      'السلام',
      'السيدة زينب',
      'الشرابية',
      'مدينة الشروق',
      'الظاهر',
      'العتبة',
      'القاهرة الجديدة',
      'المرج',
      'عزبة النخل',
      'المطرية',
      'المعادى',
      'المعصرة',
      'المقطم',
      'المنيل',
      'الموسكى',
      'النزهة',
      'الوايلى',
      'باب الشعرية',
      'بولاق',
      'جاردن سيتى',
      'حدائق القبة',
      'حلوان',
      'دار السلام',
      'شبرا',
      'طره',
      'عابدين',
      'عباسية',
      'عين شمس',
      'مدينة نصر',
      'مصر الجديدة',
      'مصر القديمة',
      'منشية ناصر',
      'مدينة بدر',
      'مدينة العبور',
      'وسط البلد',
      'الزمالك',
      'قصر النيل',
      'الرحاب',
      'القطامية',
      'مدينتي',
      'روض الفرج',
      'شيراتون',
      'الجمالية',
      'العاشر من رمضان',
      'الحلمية',
      'النزهة الجديدة',
      'العاصمة الإدارية'
    ],
    'الجيزة': [
      'الجيزة',
      'السادس من أكتوبر',
      'الشيخ زايد',
      'الحوامدية',
      'البدرشين',
      'الصف',
      'أطفيح',
      'العياط',
      'الباويطي',
      'منشأة القناطر',
      'أوسيم',
      'كرداسة',
      'أبو النمرس',
      'كفر غطاطي',
      'منشأة البكاري',
      'الدقى',
      'العجوزة',
      'الهرم',
      'الوراق',
      'امبابة',
      'بولاق الدكرور',
      'الواحات البحرية',
      'العمرانية',
      'المنيب',
      'بين السرايات',
      'الكيت كات',
      'المهندسين',
      'فيصل',
      'أبو رواش',
      'حدائق الأهرام',
      'الحرانية',
      'حدائق اكتوبر',
      'صفط اللبن',
      'القرية الذكية',
      'ارض اللواء'
    ],
    'الأسكندرية': [
      'ابو قير',
      'الابراهيمية',
      'الأزاريطة',
      'الانفوشى',
      'الدخيلة',
      'السيوف',
      'العامرية',
      'اللبان',
      'المفروزة',
      'المنتزه',
      'المنشية',
      'الناصرية',
      'امبروزو',
      'باب شرق',
      'برج العرب',
      'ستانلى',
      'سموحة',
      'سيدى بشر',
      'شدس',
      'غيط العنب',
      'فلمينج',
      'فيكتوريا',
      'كامب شيزار',
      'كرموز',
      'محطة الرمل',
      'مينا البصل',
      'العصافرة',
      'العجمي',
      'بكوس',
      'بولكلي',
      'كليوباترا',
      'جليم',
      'المعمورة',
      'المندرة',
      'محرم بك',
      'الشاطبي',
      'سيدي جابر',
      'الساحل الشمالي',
      'الحضرة',
      'العطارين',
      'سيدي كرير',
      'الجمرك',
      'المكس',
      'مارينا'
    ],
    'الدقهلية': [
      'المنصورة',
      'طلخا',
      'ميت غمر',
      'دكرنس',
      'أجا',
      'منية النصر',
      'السنبلاوين',
      'الكردي',
      'بني عبيد',
      'المنزلة',
      'تمي الأمديد',
      'الجمالية',
      'شربين',
      'المطرية',
      'بلقاس',
      'ميت سلسيل',
      'جمصة',
      'محلة دمنة',
      'نبروه'
    ],
    'البحر الأحمر': [
      'الغردقة',
      'رأس غارب',
      'سفاجا',
      'القصير',
      'مرسى علم',
      'الشلاتين',
      'حلايب',
      'الدهار'
    ],
    'البحيرة': [
      'دمنهور',
      'كفر الدوار',
      'رشيد',
      'إدكو',
      'أبو المطامير',
      'أبو حمص',
      'الدلنجات',
      'المحمودية',
      'الرحمانية',
      'إيتاي البارود',
      'حوش عيسى',
      'شبراخيت',
      'كوم حمادة',
      'بدر',
      'وادي النطرون',
      'النوبارية الجديدة',
      'النوبارية'
    ],
    'الفيوم': [
      'الفيوم',
      'الفيوم الجديدة',
      'طامية',
      'سنورس',
      'إطسا',
      'إبشواي',
      'يوسف الصديق',
      'الحادقة',
      'اطسا',
      'الجامعة',
      'السيالة'
    ],
    'الغربية': [
      'طنطا',
      'المحلة الكبرى',
      'كفر الزيات',
      'زفتى',
      'السنطة',
      'قطور',
      'بسيون',
      'سمنود'
    ],
    'الإسماعلية': [
      'حي اول',
      'حي ثان',
      'حي ثالث',
      'فايد',
      'القنطرة شرق',
      'القنطرة غرب',
      'التل الكبير',
      'أبو صوير',
      'القصاصين الجديدة',
      'نفيشة',
    ],
    'المنوفية': [
      'شبين الكوم',
      'مدينة السادات',
      'منوف',
      'سرس الليان',
      'أشمون',
      'الباجور',
      'قويسنا',
      'بركة السبع',
      'تلا',
      'الشهداء'
    ],
    'المنيا': [
      'المنيا',
      'المنيا الجديدة',
      'العدوة',
      'مغاغة',
      'بني مزار',
      'مطاي',
      'سمالوط',
      'المدينة الفكرية',
      'ملوي',
      'دير مواس',
      'ابو قرقاص',
      'ارض سلطان'
    ],
    'القليوبية': [
      'بنها',
      'قليوب',
      'شبرا الخيمة',
      'القناطر الخيرية',
      'الخانكة',
      'كفر شكر',
      'طوخ',
      'قها',
      'العبور',
      'الخصوص',
      'شبين القناطر',
      'مسطرد'
    ],
    'الوادي الجديد': ['الخارجة', 'باريس', 'موط', 'الفرافرة', 'بلاط', 'الداخلة'],
    'السويس': ['السويس', 'الجناين', 'عتاقة', 'العين السخنة', 'فيصل'],
    'اسوان': [
      'أسوان',
      'أسوان الجديدة',
      'دراو',
      'كوم أمبو',
      'نصر النوبة',
      'كلابشة',
      'إدفو',
      'الرديسية',
      'البصيلية',
      'السباعية',
      'ابوسمبل السياحية',
      'مرسى علم'
    ],
    'اسيوط': [
      'أسيوط',
      'أسيوط الجديدة',
      'ديروط',
      'منفلوط',
      'القوصية',
      'أبنوب',
      'أبو تيج',
      'الغنايم',
      'ساحل سليم',
      'البداري',
      'صدفا'
    ],
    'بني سويف': [
      'بني سويف',
      'بني سويف الجديدة',
      'الواسطى',
      'ناصر',
      'إهناسيا',
      'ببا',
      'الفشن',
      'سمسطا',
      'الاباصيرى',
      'مقبل'
    ],
    'بورسعيد': [
      'بورسعيد',
      'بورفؤاد',
      'العرب',
      'حى الزهور',
      'حى الشرق',
      'حى الضواحى',
      'حى المناخ',
      'حى مبارك'
    ],
    'دمياط': [
      'دمياط',
      'دمياط الجديدة',
      'رأس البر',
      'فارسكور',
      'الزرقا',
      'السرو',
      'الروضة',
      'كفر البطيخ',
      'عزبة البرج',
      'ميت أبو غالب',
      'كفر سعد'
    ],
    'الشرقية': [
      'الزقازيق',
      'العاشر من رمضان',
      'منيا القمح',
      'بلبيس',
      'مشتول السوق',
      'القنايات',
      'أبو حماد',
      'القرين',
      'ههيا',
      'أبو كبير',
      'فاقوس',
      'الصالحية الجديدة',
      'الإبراهيمية',
      'ديرب نجم',
      'كفر صقر',
      'أولاد صقر',
      'الحسينية',
      'صان الحجر القبلية',
      'منشأة أبو عمر'
    ],
    'جنوب سيناء': [
      'الطور',
      'شرم الشيخ',
      'دهب',
      'نويبع',
      'طابا',
      'سانت كاترين',
      'أبو رديس',
      'أبو زنيمة',
      'رأس سدر'
    ],
    'كفر الشيخ': [
      'كفر الشيخ',
      'وسط البلد كفر الشيخ',
      'دسوق',
      'فوه',
      'مطوبس',
      'برج البرلس',
      'بلطيم',
      'مصيف بلطيم',
      'الحامول',
      'بيلا',
      'الرياض',
      'سيدي سالم',
      'قلين',
      'سيدي غازي'
    ],
    'مطروح': [
      'مرسى مطروح',
      'الحمام',
      'العلمين',
      'الضبعة',
      'النجيلة',
      'سيدي براني',
      'السلوم',
      'سيوة',
      'مارينا',
      'الساحل الشمالى'
    ],
    'الأقصر': [
      'الأقصر',
      'الأقصر الجديدة',
      'إسنا',
      'طيبة الجديدة',
      'الزينية',
      'البياضية',
      'القرنة',
      'أرمنت',
      'الطود'
    ],
    'قنا': [
      'قنا',
      'قنا الجديدة',
      'ابو طشت',
      'نجع حمادي',
      'دشنا',
      'الوقف',
      'قفط',
      'نقادة',
      'فرشوط',
      'قوص'
    ],
    'شمال سيناء': ['العريش', 'الشيخ زويد', 'نخل', 'رفح', 'بئر العبد', 'الحسنة'],
    'سوهاج': [
      'سوهاج',
      'سوهاج الجديدة',
      'أخميم',
      'أخميم الجديدة',
      'البلينا',
      'المراغة',
      'المنشأة',
      'دار السلام',
      'جرجا',
      'جهينة الغربية',
      'ساقلته',
      'طما',
      'طهطا',
      'الكوثر'
    ]
  };
  String? _selectedGovernorate;
  String? _selectedArea;
  final List<Map<String, String>> _branches = [];
  final Set<String> _selectedAreas =
      {}; // Track selected areas to prevent duplicates

  @override
  void dispose() {
    // Dispose controllers efficiently
    [
      _usernameController,
      _phoneController,
      _emailController,
      _passwordController,
      _confirmPasswordController,
      _restaurantNameController,
      _deliveryCostPerKmController,
      _depositAmountController,
      _maxPeopleController,
      _notesController
    ].forEach((controller) => controller.dispose());
    super.dispose();
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'يجب إدخال كلمة المرور';
    if (value.length < 8) return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    if (value != _confirmPasswordController.text) {
      return 'كلمات المرور غير متطابقة';
    }
    return null;
  }

  Widget _buildRestaurantNameField() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title: 'معلومات المطعم'),
          SizedBox(height: 16),
          TextFormField(
            key: ValueKey('restaurantName'),
            controller: _restaurantNameController,
            decoration: InputDecoration(
              hintText: 'اسم المطعم',
              filled: true,
              fillColor: Color(0xFFF5F5F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
            ),
            validator: (value) =>
                value!.isEmpty ? 'يجب إدخال اسم المطعم' : null,
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
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _LogoIcon(),
              Text(
                'شعار المطعم',
                style: TextStyle(fontSize: 16),
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
          SectionTitle(title: 'معلومات الحساب'),
          SizedBox(height: 16),
          TextFormField(
            key: ValueKey('username'),
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: 'اسم المستخدم',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) =>
                value!.isEmpty? 'يجب إدخال اسم المستخدم' : null,
          ),
          SizedBox(height: 16),
          TextFormField(
            key: ValueKey('phone'),
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'رقم الهاتف',
              prefixIcon: Icon(Icons.phone),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) =>
                value!.isEmpty ? 'يجب إدخال رقم الهاتف' : null,
          ),
          SizedBox(height: 16),
          TextFormField(
            key: ValueKey('email'),
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'البريد الإلكتروني',
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) =>
                value!.contains('@') ? null : 'بريد إلكتروني غير صالح',
          ),
          SizedBox(height: 16),
          TextFormField(
            key: ValueKey('password'),
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'كلمة المرور',
              prefixIcon: Icon(Icons.lock),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: _validatePassword,
          ),
          SizedBox(height: 16),
          TextFormField(
            key: ValueKey('confirmPassword'),
            controller: _confirmPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'تأكيد كلمة المرور',
              prefixIcon: Icon(Icons.lock_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: _validatePassword,
          ),
          SizedBox(height: 24),
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
          SizedBox(height: 24),
          Text(
            'قم بتحديد نوع المطبخ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            textAlign: TextAlign.right,
          ),
          SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _cuisineTypes.length,
            itemBuilder: (context, index) => _CuisineTypeTile(
              isFirst: index == 0,
              key: ValueKey('cuisine_$index'),
              title: _cuisineTypes[index],
              isSelected: _selectedCuisineTypes[index],
              onChanged: (value) =>
                  setState(() => _selectedCuisineTypes[index] = value ?? false),
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
          SizedBox(height: 24),
          Text(
            'هل تتوفر لديك خدمة توصيل؟',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            textAlign: TextAlign.right,
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ToggleOption(
                label: 'لا',
                isActive: !_hasDeliveryService,
                onTap: () => setState(() => _hasDeliveryService = false),
              ),
              SizedBox(width: 12),
              _ToggleOption(
                label: 'نعم',
                isActive: _hasDeliveryService,
                onTap: () => setState(() => _hasDeliveryService = true),
              ),
            ],
          ),
          if (_hasDeliveryService) ...[
            SizedBox(height: 16),
            TextFormField(
              key: ValueKey('deliveryCost'),
              controller: _deliveryCostPerKmController,
              decoration: InputDecoration(
                labelText: 'سعر التوصيل لكل كيلومتر',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) =>
                  _hasDeliveryService && value!.isEmpty ? 'مطلوب' : null,
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
          const Text(
            'هل تتوفر لديك خدمة حجز طاولات؟',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ToggleOption(
                label: 'لا',
                isActive: !_hasTableReservation,
                onTap: () => setState(() {
                  _hasTableReservation = false;
                  _wantsDeposit = false;
                }),
              ),
              SizedBox(width: 12),
              _ToggleOption(
                label: 'نعم',
                isActive: _hasTableReservation,
                onTap: () => setState(() => _hasTableReservation = true),
              ),
            ],
          ),
          if (_hasTableReservation) ...[
            const SizedBox(height: 24),
            const Text(
              'هل ترغب في أخذ عربون للحجز؟',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ToggleOption(
                  label: 'لا',
                  isActive: !_wantsDeposit,
                  onTap: () => setState(() => _wantsDeposit = false),
                ),
                SizedBox(width: 12),
                _ToggleOption(
                  label: 'نعم',
                  isActive: _wantsDeposit,
                  onTap: () => setState(() => _wantsDeposit = true),
                ),
              ],
            ),
            if (_wantsDeposit) ...[
              const SizedBox(height: 16),
              TextFormField(
                key: ValueKey('depositAmount'),
                controller: _depositAmountController,
                decoration: const InputDecoration(
                  labelText: 'مبلغ العربون',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) =>
                    _wantsDeposit && value!.isEmpty ? 'مطلوب' : null,
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              key: const ValueKey('maxPeople'),
              controller: _maxPeopleController,
              decoration: const InputDecoration(
                labelText: 'الحد الأقصى للأفراد',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) =>
                  _hasTableReservation && value!.isEmpty ? 'مطلوب' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: ValueKey('notes'),
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'ملاحظات للإدارة',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                suffixIcon: Icon(Icons.edit, color: Colors.grey.shade600),
              ),
              maxLines: 3,
              validator: (value) =>
                  _hasTableReservation && value!.isEmpty ? 'مطلوب' : null,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBranchesSection() {
    // Filter available areas based on selected branches
    final availableAreas = _selectedGovernorate != null
        ? _governorates[_selectedGovernorate]!
            .where((area) => !_selectedAreas.contains(area))
            .toList()
        : <String>[];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'فروع المطعم'),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            key: ValueKey('governorate'),
            value: _selectedGovernorate,
            decoration: InputDecoration(
              labelText: 'اختر المحافظة',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: _governorates.keys.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedGovernorate = value;
                _selectedArea = null;
              });
            },
            validator: (value) =>
                _branches.isEmpty ? 'يجب إضافة فرع واحد على الأقل' : null,
          ),
          if (_selectedGovernorate != null) ...[
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              key: ValueKey('area_$_selectedGovernorate'),
              value: _selectedArea,
              decoration: InputDecoration(
                labelText: 'اختر المنطقة',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: availableAreas.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedArea = value);
              },
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  if (_selectedGovernorate != null && _selectedArea != null) {
                    setState(() {
                      _branches.add({
                        'governorate': _selectedGovernorate!,
                        'area': _selectedArea!,
                      });
                      _selectedAreas.add(_selectedArea!); // Track selected area
                      _selectedGovernorate = null;
                      _selectedArea = null;
                    });
                  }
                },
                child: const Text('إضافة فرع',
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
          if (_branches.isNotEmpty) ...[
            SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _branches.asMap().entries.map((entry) {
                final branch = entry.value;
                return Chip(
                  key: ValueKey('branch_${entry.key}'),
                  label: Text('${branch['governorate']} - ${branch['area']}'),
                  deleteIcon: Icon(Icons.close, size: 18),
                  onDeleted: () {
                    setState(() {
                      _selectedAreas
                          .remove(branch['area']); // Remove from selected areas
                      _branches.remove(branch);
                    });
                  },
                  backgroundColor: Colors.grey[200],
                );
              }).toList(),
            ),
          ],
          SizedBox(height: 24),
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
            padding: EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isActive ? Colors.orange : Colors.grey[200],
              border: Border.all(
                  color: isActive ? Colors.orange : Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _pickLogo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('سيتم إضافة وظيفة اختيار الشعار قريباً')),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_branches.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يجب إضافة فرع واحد على الأقل')),
        );
        return;
      }

      final accountInfo = RestaurantAccountInfo(
        username: _usernameController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        password: _passwordController.text,
        restaurantName: _restaurantNameController.text,
        deliveryCostPerKm: _deliveryCostPerKmController.text.isEmpty
            ? null
            : _deliveryCostPerKmController.text,
        depositAmount: _depositAmountController.text.isEmpty
            ? null
            : _depositAmountController.text,
        maxPeople: _maxPeopleController.text.isEmpty
            ? null
            : _maxPeopleController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        hasDeliveryService: _hasDeliveryService,
        hasTableReservation: _hasTableReservation,
        wantsDeposit: _wantsDeposit,
        cuisineTypes: _cuisineTypes
            .asMap()
            .entries
            .where((entry) => _selectedCuisineTypes[entry.key])
            .map((entry) => entry.value)
            .toList(),
        branches: _branches,
      );

      debugPrint('Legal Data: ${widget.legalData.toJson()}');
      debugPrint('Account Info: ${accountInfo.toJson()}');

      context.push('/ResturantWorkTime', extra: {
        'legal_data': widget.legalData,
        'account_info': accountInfo,
      });
    }

  }
  void _TestSubmitForm(){
    final accountInfo = RestaurantAccountInfo(
      username: "tasty_egypt",
      phone: "01012345678",
      email: "test.restaurant@email.com",
      password: "MySecurePass123",
      restaurantName: "مطعم العمدة",
      deliveryCostPerKm: "10",
      depositAmount: "100",
      maxPeople: "8",
      notes: "يفضل الحجز قبل الوصول بساعتين.",
      hasDeliveryService: true,
      hasTableReservation: true,
      wantsDeposit: true,
      cuisineTypes: [
        "شرقي",
        "ايطالي"
      ],
      branches: [
        {
          "governorate": "القاهرة",
          "area": "مدينة نصر"
        },
        {
          "governorate": "الجيزة",
          "area": "الدقي"
        },
      ],
    );

    context.push('/ResturantWorkTime', extra: {
      'legal_data': widget.legalData,
      'account_info': accountInfo,
    });
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
      body: Form(
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
                    onPressed: _TestSubmitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('التالي',style: TextStyle(color: Colors.white),),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoIcon extends StatelessWidget {
  const _LogoIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Icon(
        Icons.image_outlined,
        color: Colors.orange,
      ),
    );
  }
}

class _CuisineTypeTile extends StatelessWidget {
  final String title;
  final bool isSelected;
  final bool isFirst; // This can be removed if no longer needed
  final ValueChanged<bool?>? onChanged;

  const _CuisineTypeTile({
    required Key key,
    required this.title,
    required this.isSelected,
    required this.isFirst,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: CheckboxListTile(
        title: Text(title, textAlign: TextAlign.right),
        value: isSelected,
        onChanged: onChanged, // Always use the provided onChanged callback
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

  const _ToggleOption({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isActive ? Colors.orange : Colors.grey[200],
              border: Border.all(
                  color: isActive ? Colors.orange : Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
