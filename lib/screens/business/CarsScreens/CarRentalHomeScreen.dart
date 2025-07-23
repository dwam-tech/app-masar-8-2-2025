import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class CarRentalHomeScreen extends StatefulWidget {
  const CarRentalHomeScreen({super.key});

  @override
  State<CarRentalHomeScreen> createState() => _CarRentalHomeScreenState();
}

class _CarRentalHomeScreenState extends State<CarRentalHomeScreen> {
  bool isDeliveryEnabled = true;
  bool isRentalEnabled = false;
  int selectedTab = 0; // 0: قيد الانتظار, 1: منتهية

  // بيانات طلبات تجريبية
  List<Map<String, dynamic>> requests = [
    {
      "id": "1",
      "type": "نوع الطلب: توصيل",
      "client": "عبدالله حمد",
      "since": "منذ دقيقة",
      "offer": "العرض المقدمة: 23",
      "FromLocation": "التجمع الخامس - القاهرة الجديدة",
      "ToLocation": "الزمالك - القاهرة الجديدة",
      "status": "قيد الانتظار",
      "price": 2800,
      "canPropose": true,
    },
    {
      "id": "2",
      "type": "نوع الطلب: تأجير مع سائق",
      "client": "عبدالله حمد",
      "since": "منذ دقيقة",
      "offer": "العرض المقدمة: 23",
      "FromLocation": "التجمع الخامس - القاهرة الجديدة",
      "ToLocation": "الزمالك - القاهرة الجديدة",
      "status": "قيد الانتظار",
      "price": 2800,
      "canPropose": true,
    },
    // أمثلة طلبات منتهية
    {
      "id": "3",
      "type": "نوع الطلب: توصيل",
      "client": "محمد أحمد",
      "since": "منذ ساعتين",
      "offer": "العرض المقدمة: 15",
      "FromLocation": "مدينة نصر - القاهرة",
      "ToLocation": "وسط البلد - القاهرة",
      "status": "منتهية",
      "price": 2000,
      "canPropose": false,
    },
    {
      "id": "4",
      "type": "نوع الطلب: تأجير يومي",
      "client": "محمود علي",
      "since": "منذ يوم",
      "offer": "العرض المقدمة: 5",
      "FromLocation": "المعادي - القاهرة",
      "ToLocation": "الشيخ زايد - الجيزة",
      "status": "منتهية",
      "price": 3500,
      "canPropose": false,
    },
    {
      "id": "5",
      "type": "نوع الطلب: توصيل",
      "client": "سارة خالد",
      "since": "منذ 4 ساعات",
      "offer": "العرض المقدمة: 8",
      "FromLocation": "مدينة بدر - القاهرة",
      "ToLocation": "حدائق الأهرام - الجيزة",
      "status": "منتهية",
      "price": 1500,
      "canPropose": false,
    },
  ];
  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardPadding = EdgeInsets.symmetric(horizontal: screenWidth * 0.02, vertical: 8);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: SafeArea(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              children: [
                _buildAppBar(context, isTablet),
                _buildSwitchesSection(isTablet, screenWidth),
                _buildTabsSection(screenWidth),
                Expanded(
                  child: ListView(
                    padding: cardPadding,
                    children: [
                      ...requests.where((req) => selectedTab == 0 ? req['status'] == "قيد الانتظار" : req['status'] == "منتهية").map((req) =>
                          _buildRequestCard(req, isTablet, screenWidth)).toList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(context, isTablet),
      ),
    );
  }

  // ----------------- APP BAR -----------------
  Widget _buildAppBar(BuildContext context, bool isTablet) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 32.0 : 16.0,
            vertical: isTablet ? 20.0 : 8.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "الرئيسية",
                style: TextStyle(
                  fontSize: isTablet ? 24.0 : 20.0,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
              Row(
                children: [
                  _buildActionButton(
                    icon: Icons.message_outlined,
                    badge: "5",
                    onTap: () {},
                    isTablet: isTablet,
                  ),
                  SizedBox(width: isTablet ? 16.0 : 12.0),
                  _buildActionButton(
                    icon: Icons.notifications_outlined,
                    badge: "3",
                    onTap: () => context.push("/NotificationsScreen"),
                    isTablet: isTablet,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String badge,
    required VoidCallback onTap,
    required bool isTablet,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: isTablet ? 48.0 : 44.0,
          height: isTablet ? 48.0 : 44.0,
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onTap,
              child: Icon(
                icon,
                size: isTablet ? 24.0 : 20.0,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
        ),
        if (badge.isNotEmpty)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Text(
                badge,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet ? 12.0 : 10.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  // ------------- SWITCHES -------------
  Widget _buildSwitchesSection(bool isTablet, double screenWidth) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: screenWidth * 0.02),
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "هل أنت متاح لاستقبال طلبات التوصيل",
                style: TextStyle(fontSize: isTablet ? 16 : 14, fontWeight: FontWeight.w500),
              ),

              const SizedBox(width: 6),
              Switch(
                value: isDeliveryEnabled,
                activeColor: Colors.green,
                onChanged: (val) => setState(() => isDeliveryEnabled = val),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "هل أنت متاح لاستقبال طلبات التأجير",
                style: TextStyle(fontSize: isTablet ? 16 : 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 6),

              Switch(
                value: isRentalEnabled,
                activeColor: Colors.green,
                onChanged: (val) => setState(() => isRentalEnabled = val),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ------------- TABS -------------
  Widget _buildTabsSection(double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03, vertical: 1),
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color.fromRGBO(222, 220, 217, 1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => setState(() => selectedTab = 0),
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedTab == 0 ? Colors.orange : Colors.white,
                  foregroundColor: selectedTab == 0 ? Colors.white : Colors.orange,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Colors.orange, width: 1.2),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 10),
                ),
                child: Text('قيد الانتظار', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
            SizedBox(width: screenWidth * 0.02),
            Expanded(
              child: ElevatedButton(
                onPressed: () => setState(() => selectedTab = 1),
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedTab == 1 ? Colors.orange : Colors.white,
                  foregroundColor: selectedTab == 1 ? Colors.white : Colors.orange,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Colors.orange, width: 1.2),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 10),
                ),
                child: Text('منتهية', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------- REQUEST CARD -------------
  Widget _buildRequestCard(Map<String, dynamic> req, bool isTablet, double screenWidth) {
    bool isFinished = req['status'] == "منتهية";

    return Container(
      margin: EdgeInsets.only(bottom: screenWidth * 0.03),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.directions_car, color: Colors.orange[700], size: isTablet ? 22 : 18),
                SizedBox(width: screenWidth * 0.01),
                Text(
                  req['type'] ?? "",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: isTablet ? 16 : 14),
                ),
                const Spacer(),
                Icon(Icons.access_time, color: Colors.grey, size: isTablet ? 18 : 15),
                SizedBox(width: screenWidth * 0.01),
                Text(req['since'] ?? "", style: TextStyle(fontSize: isTablet ? 14 : 12, color: Colors.grey)),
              ],
            ),
            SizedBox(height: screenWidth * 0.02),
            Row(
              children: [
                Icon(Icons.person, color: Colors.grey[600], size: isTablet ? 19 : 16),
                SizedBox(width: screenWidth * 0.01),
                Text(req['client'] ?? "", style: TextStyle(fontSize: isTablet ? 16 : 14, fontWeight: FontWeight.w500)),
                const Spacer(),
                Icon(Icons.local_offer, color: Colors.green[700], size: isTablet ? 19 : 16),
                SizedBox(width: screenWidth * 0.01),
                Text(req['offer'] ?? "", style: TextStyle(fontSize: isTablet ? 15 : 13, color: Colors.green)),
              ],
            ),
            Divider(
              color: Colors.grey[400],
              thickness: 1,
              height: 24,
              indent: 16,
              endIndent: 16,
            ),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.orange, size: isTablet ? 19 : 16),
                SizedBox(width: screenWidth * 0.01),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "من",
                      style: TextStyle(fontSize: isTablet ? 15 : 13, color: Colors.black54),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      req['ToLocation'] ?? "",
                      style: TextStyle(fontSize: isTablet ? 15 : 13, color: Colors.black, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: screenWidth * 0.02),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.orange, size: isTablet ? 19 : 16),
                SizedBox(width: screenWidth * 0.01),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "من",
                      style: TextStyle(fontSize: isTablet ? 15 : 13, color: Colors.black54),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      req['FromLocation'] ?? "",
                      style: TextStyle(fontSize: isTablet ? 15 : 13, color: Colors.black, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: screenWidth * 0.03),
            if (!isFinished) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.push("/OrderDetails");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 1,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20.0, left: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "قبول العرض",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Row(
                          children: [
                            Text(
                              "${req['price']}",
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const Text(" ج.م", style: TextStyle(fontSize: 14)),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: req['canPropose']
                    ? Text(
                  'يمكنك تقديم عرض سعر',
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 15 : 13,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.orange[700],
                    decorationThickness: 2,
                  ),
                )
                    : const SizedBox(),
              ),
            ],
            if (isFinished)
              Center(
                child: Text(
                  'تم الانتهاء من الطلب',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 15 : 13,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ------------- BOTTOM NAV -------------
  Widget _buildBottomNavigationBar(BuildContext context, bool isTablet) {
    int currentIndex = 0; // القائمة

    void onItemTapped(int index) {
      switch (index) {
        case 0:
          context.go('/RealStateHomeScreen');
          break;
        case 1:
          context.go('/CarRentalAnalysisScreen');
          break;
        case 2:
          context.go('/CarRentalSettingsProvider');
          break;

      }
    }

    final List<Map<String, String>> navIcons = [
      {"svg": "assets/icons/home_icon_provider.svg", "label": "الرئيسية"},
      {"svg": "assets/icons/Nav_Analysis_provider.svg", "label": "الإحصائيات"},
      {"svg": "assets/icons/Settings.svg", "label": "الإعدادات"},
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: isTablet ? 16 : 5,
              horizontal: isTablet ? 20 : 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(navIcons.length, (idx) {
                final item = navIcons[idx];
                final selected = idx == currentIndex;
                Color mainColor =
                selected ? Colors.orange : const Color(0xFF6B7280);

                return InkWell(
                  onTap: () => onItemTapped(idx),
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 20 : 16,
                      vertical: isTablet ? 12 : 5,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.orange.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          item["svg"]!,
                          height: isTablet ? 28 : 24,
                          width: isTablet ? 28 : 24,
                          colorFilter:
                          ColorFilter.mode(mainColor, BlendMode.srcIn),
                        ),
                        SizedBox(height: isTablet ? 8 : 6),
                        Text(
                          item["label"]!,
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 12,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: mainColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}