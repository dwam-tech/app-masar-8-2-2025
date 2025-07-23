import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CarRentalDataEdit extends StatefulWidget {
  const CarRentalDataEdit({super.key});

  @override
  State<CarRentalDataEdit> createState() => _CarRentalDataEditState();
}

class _CarRentalDataEditState extends State<CarRentalDataEdit> {
  bool isEditMode = false;
  bool _isLoading = false;

  // بيانات المكتب الافتراضية (تبدل لاحقاً بالبيانات الحقيقية)
  String officeName = "مكتب النجاح العقاري";
  String address = "عنوان المكتب الحالي";
  String city = "القاهرة";
  String phone = "01012345678";
  String email = "office@email.com";

  // كنترولرز
  late final TextEditingController officeNameController;
  late final TextEditingController addressController;
  late final TextEditingController phoneController;
  late final TextEditingController emailController;

  // المدن المتاحةz
  final List<String> _governorates = [
    'القاهرة',
    'الجيزة',
    'الإسكندرية',
    'الدقهلية',
    'البحر الأحمر',
    'البحيرة',
    'الفيوم',
    'الغربية',
    'الإسماعيلية',
    'المنوفية',
    'المنيا',
    'القليوبية',
    'الوادي الجديد',
    'السويس',
    'أسوان',
    'أسيوط',
    'بني سويف',
    'بورسعيد',
    'دمياط',
    'جنوب سيناء',
    'كفر الشيخ',
    'مطروح',
    'الأقصر',
    'قنا',
    'شمال سيناء',
    'سوهاج',
  ];


  @override
  void initState() {
    super.initState();
    officeNameController = TextEditingController(text: officeName);
    addressController = TextEditingController(text: address);
    phoneController = TextEditingController(text: phone);
    emailController = TextEditingController(text: email);
  }

  @override
  void dispose() {
    officeNameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> _saveData() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      officeName = officeNameController.text;
      address = addressController.text;
      phone = phoneController.text;
      email = emailController.text;
      isEditMode = false;
      _isLoading = false;
    });

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
        onPressed: () => context.pop(),
        style: IconButton.styleFrom(
          foregroundColor:  Colors.orange,
        ),
      ),
      title: const Text(
        'بيانات المكتب العقاري',
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
                  _SectionTitle(
                    title: "معلومات المكتب العقاري",
                    icon: Icons.business,
                  ),
                  const SizedBox(height: 20),
                  _buildField(
                    "اسم المكتب",
                    officeName,
                    controller: officeNameController,
                    icon: Icons.home_work_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    "عنوان المكتب",
                    address,
                    controller: addressController,
                    icon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildCityField(),
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
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
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

  Widget _buildCityField() {
    return Container(
      decoration: BoxDecoration(
        color: isEditMode ? Colors.grey.shade50 : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isEditMode
            ? Border.all(color: Colors.grey.shade300)
            : Border.all(color: Colors.transparent),
      ),
      child: isEditMode
          ? DropdownButtonFormField<String>(
        value: city,
        alignment: AlignmentDirectional.centerEnd,
        decoration: InputDecoration(
          labelText: 'المدينة',
          prefixIcon: Icon(Icons.location_city_outlined, color: const Color(0xFFFF6B35)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15.0,
            horizontal: 20.0,
          ),
          labelStyle: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        icon: const Padding(
          padding: EdgeInsets.only(left: 12.0),
          child: Icon(Icons.keyboard_arrow_down),
        ),
        iconSize: 28,
        iconEnabledColor: Colors.grey[600],
        items: _governorates.map((String cityName) {
          return DropdownMenuItem<String>(
            value: cityName,
            alignment: AlignmentDirectional.centerEnd,
            child: Text(
              cityName,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 16),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() => city = newValue!);
        },
      )
          : Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.location_city_outlined,
                color: Color(0xFFFF6B35),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "المدينة",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    city.isNotEmpty ? city : "غير محدد",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: city.isNotEmpty
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
