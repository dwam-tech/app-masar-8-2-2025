import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:saba2v2/services/ar_rental_office_service.dart';

class CarRentalDataEdit extends StatefulWidget {
  const CarRentalDataEdit({super.key});

  @override
  State<CarRentalDataEdit> createState() => _CarRentalDataEditState();
}

class _CarRentalDataEditState extends State<CarRentalDataEdit> {
  bool isEditMode = false;
  bool _isLoading = false;
  bool _isInitializing = true;

  late CarRentalOfficeService _officeService;
  int? _userId;

  String officeName = "", address = "", city = "القاهرة", phone = "", email = "";
  late TextEditingController officeNameController, addressController, phoneController, emailController;

  final List<String> _governorates = [
    'القاهرة', 'الجيزة', 'الإسكندرية', 'الدقهلية', 'البحر الأحمر', 'البحيرة', 'الفيوم', 'الغربية', 'الإسماعيلية', 'المنوفية', 'المنيا', 'القليوبية', 'الوادي الجديد', 'السويس', 'أسوان', 'أسيوط', 'بني سويف', 'بورسعيد', 'دمياط', 'جنوب سيناء', 'كفر الشيخ', 'مطروح', 'الأقصر', 'قنا', 'شمال سيناء', 'سوهاج',
  ];

  @override
  void initState() {
    super.initState();
    officeNameController = TextEditingController();
    addressController = TextEditingController();
    phoneController = TextEditingController();
    emailController = TextEditingController();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userJsonString = prefs.getString('user_data');
      if (token == null || userJsonString == null) throw Exception("بيانات المستخدم غير موجودة.");
      
      _officeService = CarRentalOfficeService(token: token);
      final userMap = jsonDecode(userJsonString);
      
      if (userMap['user_type'] == 'car_rental_office') {
        final officeDetail = userMap['car_rental']?['office_detail'];
        if (officeDetail == null) throw Exception("تفاصيل المكتب غير موجودة.");

        setState(() {
          _userId = userMap['id'];
          officeName = officeDetail['office_name'] ?? "";
          address = userMap['car_rental']?['address'] ?? officeDetail['address'] ?? "";
          city = userMap['governorate'] ?? "القاهرة";
          phone = userMap['phone'] ?? "";
          email = userMap['email'] ?? "";
          if (!_governorates.contains(city)) city = 'القاهرة';

          officeNameController.text = officeName;
          addressController.text = address;
          phoneController.text = phone;
          emailController.text = email;
        });
      } else {
        throw Exception("هذه الصفحة متاحة فقط لمكاتب تأجير السيارات.");
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isInitializing = false);
    }
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
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("خطأ: معرّف المستخدم غير موجود."), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final dataToUpdate = {
        'name': officeNameController.text,
        'office_name': officeNameController.text,
        'address': addressController.text,
        'governorate': city,
        'phone': phoneController.text,
        'email': emailController.text,
      };
      
      final result = await _officeService.updateUserProfile(
        userId: _userId!,
        data: dataToUpdate,
      );
      
      if (result['status'] == true && mounted) {
        setState(() {
          officeName = officeNameController.text; address = addressController.text;
          phone = phoneController.text; email = emailController.text;
          isEditMode = false;
        });

        final prefs = await SharedPreferences.getInstance();
        if (result['user'] != null) {
          await prefs.setString('user_data', jsonEncode(result['user']));
          debugPrint("SharedPreferences updated with new user data from server.");
        }
        
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message']), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll("Exception: ", "")), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: _buildAppBar(),
        body: _isInitializing ? const Center(child: CircularProgressIndicator(color: Colors.orange)) : _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded), onPressed: () => context.pop(), style: IconButton.styleFrom(foregroundColor: Colors.orange)),
      title: const Text('بيانات المكتب', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20, color: Colors.orange)),
      backgroundColor: Colors.white,
      elevation: 0.5,
      actions: [
        Container(
          margin: const EdgeInsets.only(left: 16),
          child: _isLoading ? const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.orange)))
              : IconButton(
                  icon: Icon(isEditMode ? Icons.save_rounded : Icons.edit_rounded, color: Colors.orange),
                  tooltip: isEditMode ? 'حفظ' : 'تعديل',
                  onPressed: () async {
                    if (isEditMode) {
                      await _saveData();
                    } else {
                      setState(() => isEditMode = true);
                    }
                  },
              ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 768;
        double horizontalPadding = isTablet ? constraints.maxWidth * 0.15 : 16;
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isTablet ? 32 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle(title: "معلومات المكتب", icon: Icons.business),
                  const SizedBox(height: 20),
                  _buildField("اسم المكتب", officeName, controller: officeNameController, icon: Icons.home_work_outlined),
                  const SizedBox(height: 16),
                  _buildField("عنوان المكتب", address, controller: addressController, icon: Icons.location_on_outlined),
                  const SizedBox(height: 16),
                  _buildCityField(),
                  const SizedBox(height: 16),
                  _buildField("رقم الهاتف", phone, controller: phoneController, keyboard: TextInputType.phone, icon: Icons.phone_outlined),
                  const SizedBox(height: 16),
                  _buildField("البريد الإلكتروني", email, controller: emailController, keyboard: TextInputType.emailAddress, icon: Icons.email_outlined),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildField(String label, String value, {TextEditingController? controller, TextInputType? keyboard, int maxLines = 1, IconData? icon}) {
    return isEditMode
        ? TextFormField(
            controller: controller,
            keyboardType: keyboard,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF2D3748)),
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: icon != null ? Icon(icon, color: const Color(0xFFFF6B35), size: 22) : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              labelStyle: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
            ),
          )
        : Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: const Color(0xFFFF6B35).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Icon(icon, color: const Color(0xFFFF6B35), size: 18),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.grey.shade600)),
                      const SizedBox(height: 4),
                      Text(
                        value.isNotEmpty ? value : "غير محدد",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: value.isNotEmpty ? const Color(0xFF2D3748) : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildCityField() {
    return isEditMode
        ? DropdownButtonFormField<String>(
            value: city,
            decoration: InputDecoration(
              labelText: 'المدينة',
              prefixIcon: const Icon(Icons.location_city_outlined, color: Color(0xFFFF6B35)),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none),
            ),
            items: _governorates.map((String cityName) {
              return DropdownMenuItem<String>(value: cityName, child: Text(cityName, style: const TextStyle(fontSize: 16)));
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) setState(() => city = newValue);
            },
          )
        : Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFFFF6B35).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.location_city_outlined, color: Color(0xFFFF6B35), size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("المدينة", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.grey.shade600)),
                      const SizedBox(height: 4),
                      Text(
                        city.isNotEmpty ? city : "غير محدد",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: city.isNotEmpty ? const Color(0xFF2D3748) : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFFF6B35), Color(0xFFFF8F50)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.5), blurRadius: 8, offset: const Offset(0, 4))],
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF2D3748)),
        ),
      ],
    );
  }
}