import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:saba2v2/services/ar_rental_office_service.dart'; // تأكد من صحة المسار
import 'package:shared_preferences/shared_preferences.dart';

class CarRentalHomeScreen extends StatefulWidget {
  const CarRentalHomeScreen({super.key});

  @override
  State<CarRentalHomeScreen> createState() => _CarRentalHomeScreenState();
}

class _CarRentalHomeScreenState extends State<CarRentalHomeScreen> {
  // متغيرات الخدمة والبيانات
  late CarRentalOfficeService _officeService;
  int? _officeDetailId;

  // متغيرات حالة المفاتيح
  bool isDeliveryEnabled = false;
  bool isRentalEnabled = false;

  // متغيرات حالة التحميل
  bool isLoadingPage = true; // للتحميل الأولي الكامل للشاشة
  bool isUpdatingDelivery = false; // لتحديث مفتاح التوصيل فقط
  bool isUpdatingRental = false; // لتحديث مفتاح التأجير فقط

  // متغيرات حالة الواجهة
  int selectedTab = 0; // 0: قيد الانتظار, 1: منتهية

  // بيانات الطلبات (يمكنك استبدالها ببيانات من الـ API لاحقًا)
  List<Map<String, dynamic>> requests = [
    {"id": "1", "type": "نوع الطلب: توصيل", "client": "عبدالله حمد", "since": "منذ دقيقة", "offer": "العرض المقدم: 23", "FromLocation": "التجمع الخامس", "ToLocation": "الزمالك", "status": "قيد الانتظار", "price": 2800, "canPropose": true},
    {"id": "3", "type": "نوع الطلب: توصيل", "client": "محمد أحمد", "since": "منذ ساعتين", "offer": "العرض المقدم: 15", "FromLocation": "مدينة نصر", "ToLocation": "وسط البلد", "status": "منتهية", "price": 2000, "canPropose": false},
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  /// دالة مركزية لجلب البيانات الأولية عند بدء تشغيل الشاشة
  Future<void> _loadInitialData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userJsonString = prefs.getString('user_data');

      if (token == null || token.isEmpty || userJsonString == null || userJsonString.isEmpty) {
        throw Exception("بيانات المستخدم غير مكتملة، يرجى إعادة تسجيل الدخول.");
      }

      _officeService = CarRentalOfficeService(token: token);

      final userMap = jsonDecode(userJsonString);
      final officeDetail = userMap['car_rental']?['office_detail'];

      if (officeDetail != null) {
        if (mounted) {
          setState(() {
            _officeDetailId = officeDetail['id'];
            isDeliveryEnabled = (officeDetail['is_available_for_delivery'] == true || officeDetail['is_available_for_delivery'] == 1);
            isRentalEnabled = (officeDetail['is_available_for_rent'] == true || officeDetail['is_available_for_rent'] == 1);
            isLoadingPage = false;
          });
        }
      } else {
        throw Exception("لا توجد تفاصيل للمكتب مرتبطة بهذا الحساب.");
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoadingPage = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("خطأ في تهيئة البيانات: $e"),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final screenWidth = MediaQuery.of(context).size.width;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: SafeArea(
          child: isLoadingPage
              ? const Center(child: CircularProgressIndicator())
              : Column(
            children: [
              _buildAppBar(context, isTablet),
              _buildSwitchesSection(isTablet, screenWidth),
              _buildTabsSection(screenWidth),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02, vertical: 8),
                  itemCount: requests.where((req) => (selectedTab == 0 ? req['status'] == "قيد الانتظار" : req['status'] == "منتهية")).length,
                  itemBuilder: (context, index) {
                    final filteredRequests = requests.where((req) => (selectedTab == 0 ? req['status'] == "قيد الانتظار" : req['status'] == "منتهية")).toList();
                    return _buildRequestCard(filteredRequests[index], isTablet, screenWidth);
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(context, isTablet),
      ),
    );
  }

  // ودجات بناء الواجهة الفرعية (Builders)

  Widget _buildAppBar(BuildContext context, bool isTablet) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))]),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isTablet ? 32.0 : 16.0, vertical: isTablet ? 20.0 : 8.0),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text("الرئيسية", style: TextStyle(fontSize: isTablet ? 24.0 : 20.0, fontWeight: FontWeight.bold, color: const Color(0xFF1F2937))),
          Row(children: [
            _buildActionButton(icon: Icons.message_outlined, badge: "5", onTap: () {}, isTablet: isTablet),
            SizedBox(width: isTablet ? 16.0 : 12.0),
            _buildActionButton(icon: Icons.notifications_outlined, badge: "3", onTap: () => context.push("/NotificationsScreen"), isTablet: isTablet),
          ]),
        ]),
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String badge, required VoidCallback onTap, required bool isTablet}) {
    return Stack(clipBehavior: Clip.none, children: [
      Container(width: isTablet ? 48.0 : 44.0, height: isTablet ? 48.0 : 44.0, decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12)), child: Material(color: Colors.transparent, child: InkWell(borderRadius: BorderRadius.circular(12), onTap: onTap, child: Icon(icon, size: isTablet ? 24.0 : 20.0, color: const Color(0xFF6B7280))))),
      if (badge.isNotEmpty) Positioned(top: -2, right: -2, child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), constraints: const BoxConstraints(minWidth: 18, minHeight: 18), child: Text(badge, style: TextStyle(color: Colors.white, fontSize: isTablet ? 12.0 : 10.0, fontWeight: FontWeight.bold), textAlign: TextAlign.center))),
    ]);
  }

  Widget _buildSwitchesSection(bool isTablet, double screenWidth) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: screenWidth * 0.02),
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: screenWidth * 0.04),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 10)]),
      child: Column(
        children: [
          _buildSwitchRow(
            label: "متاح لاستقبال طلبات التوصيل",
            value: isDeliveryEnabled,
            isLoading: isUpdatingDelivery,
            onChanged: (newValue) async {
              if (_officeDetailId == null) return;
              setState(() => isUpdatingDelivery = true);
              try {
                await _officeService.updateAvailability(officeDetailId: _officeDetailId!, isAvailableForDelivery: newValue);
                if(mounted) setState(() => isDeliveryEnabled = newValue);
              } catch (e) {
                if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("فشل تحديث الحالة: $e"), backgroundColor: Colors.red));
              } finally {
                if(mounted) setState(() => isUpdatingDelivery = false);
              }
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16, thickness: 0.5),
          _buildSwitchRow(
            label: "متاح لاستقبال طلبات التأجير",
            value: isRentalEnabled,
            isLoading: isUpdatingRental,
            onChanged: (newValue) async {
              if (_officeDetailId == null) return;
              setState(() => isUpdatingRental = true);
              try {
                await _officeService.updateAvailability(officeDetailId: _officeDetailId!, isAvailableForRent: newValue);
                if(mounted) setState(() => isRentalEnabled = newValue);
              } catch (e) {
                if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("فشل تحديث الحالة: $e"), backgroundColor: Colors.red));
              } finally {
                if(mounted) setState(() => isUpdatingRental = false);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow({required String label, required bool value, required bool isLoading, required ValueChanged<bool> onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        Transform.scale(
          scale: 0.9,
          child: Row(children: [
            if (isLoading) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5)),
            if (isLoading) const SizedBox(width: 12),
            Switch(value: value, activeColor: Colors.green, onChanged: isLoading ? null : onChanged),
          ]),
        ),
      ]),
    );
  }

  Widget _buildTabsSection(double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color.fromRGBO(222, 220, 217, 1), width: 1)),
        child: Row(children: [
          Expanded(child: ElevatedButton(onPressed: () => setState(() => selectedTab = 0), style: ElevatedButton.styleFrom(backgroundColor: selectedTab == 0 ? Colors.orange : Colors.white, foregroundColor: selectedTab == 0 ? Colors.white : Colors.orange, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Colors.orange, width: 1.2)), padding: const EdgeInsets.symmetric(vertical: 10)), child: const Text('قيد الانتظار', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)))),
          SizedBox(width: screenWidth * 0.02),
          Expanded(child: ElevatedButton(onPressed: () => setState(() => selectedTab = 1), style: ElevatedButton.styleFrom(backgroundColor: selectedTab == 1 ? Colors.orange : Colors.white, foregroundColor: selectedTab == 1 ? Colors.white : Colors.orange, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Colors.orange, width: 1.2)), padding: const EdgeInsets.symmetric(vertical: 10)), child: const Text('منتهية', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)))),
        ]),
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> req, bool isTablet, double screenWidth) {
    bool isFinished = req['status'] == "منتهية";
    return Container(
      margin: EdgeInsets.only(bottom: screenWidth * 0.03),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))]),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(Icons.directions_car, color: Colors.orange[700], size: isTablet ? 22 : 18), SizedBox(width: screenWidth * 0.01), Text(req['type'] ?? "", style: TextStyle(fontWeight: FontWeight.w600, fontSize: isTablet ? 16 : 14)), const Spacer(), Icon(Icons.access_time, color: Colors.grey, size: isTablet ? 18 : 15), SizedBox(width: screenWidth * 0.01), Text(req['since'] ?? "", style: TextStyle(fontSize: isTablet ? 14 : 12, color: Colors.grey))]),
          SizedBox(height: screenWidth * 0.02),
          Row(children: [Icon(Icons.person, color: Colors.grey[600], size: isTablet ? 19 : 16), SizedBox(width: screenWidth * 0.01), Text(req['client'] ?? "", style: TextStyle(fontSize: isTablet ? 16 : 14, fontWeight: FontWeight.w500)), const Spacer(), Icon(Icons.local_offer, color: Colors.green[700], size: isTablet ? 19 : 16), SizedBox(width: screenWidth * 0.01), Text(req['offer'] ?? "", style: TextStyle(fontSize: isTablet ? 15 : 13, color: Colors.green))]),
          Divider(color: Colors.grey[300], thickness: 1, height: 24, indent: 16, endIndent: 16),
          Row(children: [Icon(Icons.location_on, color: Colors.orange, size: isTablet ? 19 : 16), SizedBox(width: screenWidth * 0.01), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("من", style: TextStyle(fontSize: isTablet ? 15 : 13, color: Colors.black54)), Text(req['ToLocation'] ?? "", style: TextStyle(fontSize: isTablet ? 15 : 13, color: Colors.black, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)]))]),
          SizedBox(height: screenWidth * 0.02),
          Row(children: [Icon(Icons.location_on, color: Colors.orange, size: isTablet ? 19 : 16), SizedBox(width: screenWidth * 0.01), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("إلى", style: TextStyle(fontSize: isTablet ? 15 : 13, color: Colors.black54)), Text(req['FromLocation'] ?? "", style: TextStyle(fontSize: isTablet ? 15 : 13, color: Colors.black, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)]))]),
          SizedBox(height: screenWidth * 0.03),
          if (!isFinished) ...[
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => context.push("/OrderDetails"), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 13), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 1), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20.0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("قبول العرض", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Row(children: [Text("${req['price']}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)), const Text(" ج.م", style: TextStyle(fontSize: 14))])])))),
            const SizedBox(height: 10),
            Center(child: req['canPropose'] ? Text('يمكنك تقديم عرض سعر', style: TextStyle(color: Colors.orange[700], fontWeight: FontWeight.bold, fontSize: isTablet ? 15 : 13, decoration: TextDecoration.underline, decorationColor: Colors.orange[700], decorationThickness: 2)) : const SizedBox()),
          ],
          if (isFinished) Center(child: Text('تم الانتهاء من الطلب', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: isTablet ? 15 : 13))),
        ]),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, bool isTablet) {
    int currentIndex = 0;
    void onItemTapped(int index) {
      if (index == currentIndex) return;
      switch (index) {
        case 0: context.go('/CarRentalHomeScreen'); break;
        case 1: context.go('/AddCarRental'); break;
        case 2: context.go('/CarRentalAnalysisScreen'); break;
        case 3: context.go('/CarRentalSettingsProvider'); break;
      }
    }

    final List<Map<String, String>> navIcons = [
      {"svg": "assets/icons/home_icon_provider.svg", "label": "الرئيسية"},
      {"svg": "assets/icons/Nav_Menu_provider.svg", "label": "إضافة سيارة"},
      {"svg": "assets/icons/Nav_Analysis_provider.svg", "label": "الإحصائيات"},
      {"svg": "assets/icons/Settings.svg", "label": "الإعدادات"},
    ];

    return Container(
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, -4))]),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: isTablet ? 12 : 8, horizontal: isTablet ? 20 : 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(navIcons.length, (idx) {
              final item = navIcons[idx];
              final selected = idx == currentIndex;
              Color mainColor = selected ? Colors.orange : const Color(0xFF6B7280);
              return Expanded(
                child: InkWell(
                  onTap: () => onItemTapped(idx),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      SvgPicture.asset(item["svg"]!, height: isTablet ? 26 : 22, colorFilter: ColorFilter.mode(mainColor, BlendMode.srcIn)),
                      const SizedBox(height: 5),
                      Text(item["label"]!, style: TextStyle(fontSize: isTablet ? 13 : 11, fontWeight: selected ? FontWeight.bold : FontWeight.normal, color: mainColor)),
                    ]),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}