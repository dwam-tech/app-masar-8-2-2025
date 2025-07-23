import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ResDataEdit extends StatefulWidget {
  const ResDataEdit({super.key});

  @override
  State<ResDataEdit> createState() => _ResDataEditState();
}

class _ResDataEditState extends State<ResDataEdit> {
  bool isEditMode = false;
  bool _isLoading = false;

  // بيانات وهمية (تستبدلها ببيانات حقيقية لاحقاً)
  String username = "tasty_egypt";
  String phone = "01012345678";
  String email = "test.restaurant@email.com";
  String restaurantName = "مطعم العمدة";
  String logoUrl = "";
  List<String> cuisineTypes = ["شرقي", "إيطالي"];
  List<Map<String, String>> branches = [
    {"governorate": "القاهرة", "area": "مدينة نصر"},
    {"governorate": "الجيزة", "area": "الدقي"}
  ];
  bool hasDelivery = true;
  String deliveryCost = "10";
  bool hasTableReservation = true;
  bool wantsDeposit = true;
  String depositAmount = "100";
  String maxPeople = "8";
  String notes = "يفضل الحجز قبل الوصول بساعتين.";

  // كنترولرز لوضع التعديل
  late final TextEditingController usernameController;
  late final TextEditingController phoneController;
  late final TextEditingController emailController;
  late final TextEditingController restaurantNameController;
  late final TextEditingController deliveryCostController;
  late final TextEditingController depositAmountController;
  late final TextEditingController maxPeopleController;
  late final TextEditingController notesController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    usernameController = TextEditingController(text: username);
    phoneController = TextEditingController(text: phone);
    emailController = TextEditingController(text: email);
    restaurantNameController = TextEditingController(text: restaurantName);
    deliveryCostController = TextEditingController(text: deliveryCost);
    depositAmountController = TextEditingController(text: depositAmount);
    maxPeopleController = TextEditingController(text: maxPeople);
    notesController = TextEditingController(text: notes);
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    usernameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    restaurantNameController.dispose();
    deliveryCostController.dispose();
    depositAmountController.dispose();
    maxPeopleController.dispose();
    notesController.dispose();
  }

  // دالة لحفظ البيانات
  Future<void> _saveData() async {
    setState(() => _isLoading = true);

    // محاكاة عملية الحفظ
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      username = usernameController.text;
      phone = phoneController.text;
      email = emailController.text;
      restaurantName = restaurantNameController.text;
      deliveryCost = deliveryCostController.text;
      depositAmount = depositAmountController.text;
      maxPeople = maxPeopleController.text;
      notes = notesController.text;
      isEditMode = false;
      _isLoading = false;
    });

    // عرض رسالة نجاح
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم حفظ البيانات بنجاح'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded),
        onPressed: () => context.go("/RestaurantEditProfile"),
        style: IconButton.styleFrom(
          foregroundColor:  Colors.orange ,
        ),
      ),
      title: const Text(
        'بيانات المطعم',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 20,
          color: Colors.orange,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      shadowColor: Colors.black12,
      surfaceTintColor: Colors.transparent,
      actions: [
        Container(
          margin: const EdgeInsets.only(left: 16),
          child: _isLoading
              ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.orange,
            ),
          )
              : IconButton(
            icon: Icon(
              isEditMode ? Icons.save_rounded : Icons.edit_rounded,
              color: Colors.orange,
            ),
            tooltip: isEditMode ? 'حفظ' : 'تعديل',
            onPressed: () async {
              if (isEditMode) {
                await _saveData();
              } else {
                setState(() => isEditMode = true);
              }
            },
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35).withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(44, 44),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 768;
        final isDesktop = constraints.maxWidth > 1200;

        double horizontalPadding;
        if (isDesktop) {
          horizontalPadding = constraints.maxWidth * 0.25;
        } else if (isTablet) {
          horizontalPadding = constraints.maxWidth * 0.15;
        } else {
          horizontalPadding = 16;
        }

        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isTablet ? 32 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAccountSection(),
                  _buildDivider(),
                  _buildRestaurantInfoSection(),
                  _buildDivider(),
                  _buildCuisineTypesSection(),
                  _buildDivider(),
                  _buildBranchesSection(),
                  _buildDivider(),
                  _buildServicesSection(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 32),
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.grey.shade300,
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: "معلومات الحساب",
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 20),
        _buildField(
          "اسم المستخدم",
          username,
          controller: usernameController,
          icon: Icons.alternate_email_rounded,
        ),
        const SizedBox(height: 16),
        _buildField(
          "رقم الهاتف",
          phone,
          controller: phoneController,
          keyboard: TextInputType.phone,
          icon: Icons.phone_outlined,
        ),
        const SizedBox(height: 16),
        _buildField(
          "البريد الإلكتروني",
          email,
          controller: emailController,
          keyboard: TextInputType.emailAddress,
          icon: Icons.email_outlined,
        ),
      ],
    );
  }

  Widget _buildRestaurantInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: "معلومات المطعم",
          icon: Icons.restaurant_outlined,
        ),
        const SizedBox(height: 20),
        _buildField(
          "اسم المطعم",
          restaurantName,
          controller: restaurantNameController,
          icon: Icons.storefront_outlined,
        ),
        const SizedBox(height: 20),
        _buildLogoSection(),
      ],
    );
  }

  Widget _buildCuisineTypesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: "أنواع المطبخ",
          icon: Icons.restaurant_menu_outlined,
        ),
        const SizedBox(height: 16),
        _buildCuisineChips(),
      ],
    );
  }

  Widget _buildBranchesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: "فروع المطعم",
          icon: Icons.location_on_outlined,
        ),
        const SizedBox(height: 16),
        _buildBranches(),
      ],
    );
  }

  Widget _buildServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: "خدمات المطعم",
          icon: Icons.room_service_outlined,
        ),
        const SizedBox(height: 20),
        _buildDeliverySection(),
        const SizedBox(height: 24),
        _buildReservationSection(),
      ],
    );
  }

  Widget _buildField(
      String label,
      String value, {
        TextEditingController? controller,
        TextInputType? keyboard,
        int maxLines = 1,
        IconData? icon,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: isEditMode ? Colors.grey.shade50 : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isEditMode
            ? Border.all(color: Colors.grey.shade300)
            : Border.all(color: Colors.transparent),
      ),
      child: isEditMode
          ? TextField(
        controller: controller,
        keyboardType: keyboard,
        maxLines: maxLines,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF2D3748),
        ),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null
              ? Icon(icon, color: const Color(0xFFFF6B35), size: 22)
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          labelStyle: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      )
          : Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFFFF6B35),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value.isNotEmpty ? value : "غير محدد",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: value.isNotEmpty
                          ? const Color(0xFF2D3748)
                          : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFFF6B35).withOpacity(0.3),
                width: 2,
              ),
              image: logoUrl.isNotEmpty
                  ? DecorationImage(
                image: NetworkImage(logoUrl),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: logoUrl.isEmpty
                ? const Icon(
              Icons.image_outlined,
              color: Color(0xFFFF6B35),
              size: 32,
            )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "شعار المطعم",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  logoUrl.isNotEmpty ? "تم رفع الشعار" : "لم يتم رفع شعار",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (isEditMode)
            ElevatedButton.icon(
              icon: const Icon(Icons.upload_file_rounded, size: 18),
              label: const Text("تغيير"),
              onPressed: () {
                // هنا كود رفع الشعار الفعلي
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCuisineChips() {
    final allCuisines = ["شرقي", "إيطالي", "غربي", "هندي", "صيني", "مكسيكي", "تايلاندي"];

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: isEditMode
          ? allCuisines.map((type) {
        final isSelected = cuisineTypes.contains(type);
        return FilterChip(
          label: Text(type),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                cuisineTypes.add(type);
              } else {
                cuisineTypes.remove(type);
              }
            });
          },
          backgroundColor: Colors.white,
          selectedColor: const Color(0xFFFF6B35).withOpacity(0.1),
          checkmarkColor: const Color(0xFFFF6B35),
          side: BorderSide(
            color: isSelected
                ? const Color(0xFFFF6B35)
                : Colors.grey.shade300,
          ),
          labelStyle: TextStyle(
            color: isSelected
                ? const Color(0xFFFF6B35)
                : Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }).toList()
          : cuisineTypes.map((type) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFF6B35).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFFF6B35).withOpacity(0.3),
            ),
          ),
          child: Text(
            type,
            style: const TextStyle(
              color: Color(0xFFFF6B35),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBranches() {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: branches.map((branch) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                "${branch['governorate']} - ${branch['area']}",
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              if (isEditMode) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      branches.remove(branch);
                    });
                  },
                  child: Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: Colors.red.shade400,
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDeliverySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: hasDelivery
            ? const Color(0xFFFF6B35).withOpacity(0.05)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasDelivery
              ? const Color(0xFFFF6B35).withOpacity(0.2)
              : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          _buildSwitchRow(
            "خدمة التوصيل",
            hasDelivery,
            isEditMode,
                (val) => setState(() => hasDelivery = val),
            icon: Icons.delivery_dining_outlined,
          ),
          if (hasDelivery) ...[
            const SizedBox(height: 16),
            _buildField(
              "سعر التوصيل (جنيه/كيلومتر)",
              deliveryCost,
              controller: deliveryCostController,
              keyboard: TextInputType.number,
              icon: Icons.payments_outlined,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReservationSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: hasTableReservation
            ? const Color(0xFFFF6B35).withOpacity(0.05)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasTableReservation
              ? const Color(0xFFFF6B35).withOpacity(0.2)
              : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          _buildSwitchRow(
            "حجز الطاولات",
            hasTableReservation,
            isEditMode,
                (val) => setState(() {
              hasTableReservation = val;
              if (!val) wantsDeposit = false;
            }),
            icon: Icons.table_restaurant_outlined,
          ),
          if (hasTableReservation) ...[
            const SizedBox(height: 20),
            _buildSwitchRow(
              "يتم أخذ عربون؟",
              wantsDeposit,
              isEditMode,
                  (val) => setState(() => wantsDeposit = val),
              icon: Icons.account_balance_wallet_outlined,
            ),
            if (wantsDeposit) ...[
              const SizedBox(height: 16),
              _buildField(
                "مبلغ العربون (جنيه)",
                depositAmount,
                controller: depositAmountController,
                keyboard: TextInputType.number,
                icon: Icons.monetization_on_outlined,
              ),
            ],
            const SizedBox(height: 16),
            _buildField(
              "الحد الأقصى للأفراد",
              maxPeople,
              controller: maxPeopleController,
              keyboard: TextInputType.number,
              icon: Icons.groups_outlined,
            ),
            const SizedBox(height: 16),
            _buildField(
              "ملاحظات للإدارة",
              notes,
              controller: notesController,
              maxLines: 3,
              icon: Icons.note_outlined,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSwitchRow(
      String label,
      bool value,
      bool canEdit,
      ValueChanged<bool> onChanged, {
        IconData? icon,
      }) {
    return Row(
      children: [
        if (icon != null) ...[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: value
                  ? const Color(0xFFFF6B35).withOpacity(0.1)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: value
                  ? const Color(0xFFFF6B35)
                  : Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Color(0xFF2D3748),
            ),
          ),
        ),
        canEdit
            ? Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFFFF6B35),
          activeTrackColor: const Color(0xFFFF6B35).withOpacity(0.3),
          inactiveThumbColor: Colors.grey.shade400,
          inactiveTrackColor: Colors.grey.shade300,
        )
            : Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: value ? Colors.green.shade50 : Colors.red.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: value ? Colors.green.shade200 : Colors.red.shade200,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                value ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: value ? Colors.green.shade600 : Colors.red.shade600,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                value ? 'مفعل' : 'غير مفعل',
                style: TextStyle(
                  color: value ? Colors.green.shade700 : Colors.red.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B35), Color(0xFFFF8F50)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.orange,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D3748),
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}