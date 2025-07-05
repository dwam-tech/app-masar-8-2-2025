import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
      "location": "التجمع الخامس - القاهرة الجديدة",
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
      "location": "التجمع الخامس - القاهرة الجديدة",
      "status": "قيد الانتظار",
      "price": 2800,
      "canPropose": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(65),
          child: _buildAppBar(context, isTablet),
        ),
        body: SafeArea(
          child: Column(
            children: [
              _buildSwitchesSection(isTablet),
              _buildTabsSection(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  children: [
                    ...requests.where((req) => selectedTab == 0 ? req['status'] == "قيد الانتظار" : req['status'] == "منتهية").map((req) =>
                        _buildRequestCard(req, isTablet)).toList(),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNav(isTablet),
      ),
    );
  }

  // ----------------- APP BAR -----------------
  Widget _buildAppBar(BuildContext context, bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 10, vertical: 8),
      child: Row(
        children: [
          // أيقونة الرسائل
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: SvgPicture.asset(
                  "assets/icons/message.svg",
                  width: 26,
                  colorFilter: const ColorFilter.mode(Colors.orange, BlendMode.srcIn),
                ),
                onPressed: () {},
              ),
              Positioned(
                top: 2,
                right: 2,
                child: _badge(count: 3),
              ),
            ],
          ),
          // أيقونة الإشعارات
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: SvgPicture.asset(
                  "assets/icons/notification.svg",
                  width: 26,
                  colorFilter: const ColorFilter.mode(Colors.orange, BlendMode.srcIn),
                ),
                onPressed: () {},
              ),
              Positioned(
                top: 2,
                right: 2,
                child: _badge(count: 5),
              ),
            ],
          ),
          const Spacer(),
          const Text(
            'الرئيسية',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _badge({required int count}) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: Colors.red,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 2),
    ),
    child: Text(
      count.toString(),
      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
    ),
  );

  // ------------- SWITCHES -------------
  Widget _buildSwitchesSection(bool isTablet) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
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
            children: [
              Switch(
                value: isDeliveryEnabled,
                activeColor: Colors.orange,
                onChanged: (val) => setState(() => isDeliveryEnabled = val),
              ),
              const SizedBox(width: 6),
              const Text(
                "هل أنت متاح لاستقبال طلبات التوصيل",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Switch(
                value: isRentalEnabled,
                activeColor: Colors.orange,
                onChanged: (val) => setState(() => isRentalEnabled = val),
              ),
              const SizedBox(width: 6),
              const Text(
                "هل أنت متاح لاستقبال طلبات التأجير",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ------------- TABS -------------
  Widget _buildTabsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8),
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
              ),
              child: const Text('قيد الانتظار', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
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
              ),
              child: const Text('منتهية', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // ------------- REQUEST CARD -------------
  Widget _buildRequestCard(Map<String, dynamic> req, bool isTablet) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // النوع والزمن
            Row(
              children: [
                Icon(Icons.local_taxi, color: Colors.orange[700], size: 20),
                const SizedBox(width: 6),
                Text(
                  req['type'] ?? "",
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const Spacer(),
                Icon(Icons.access_time, color: Colors.grey, size: 17),
                const SizedBox(width: 2),
                Text(req['since'] ?? "", style: const TextStyle(fontSize: 13, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 5),
            // العميل والعرض
            Row(
              children: [
                Icon(Icons.person, color: Colors.grey[600], size: 18),
                const SizedBox(width: 3),
                Text(req['client'] ?? "", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                const Spacer(),
                Icon(Icons.local_offer, color: Colors.green[700], size: 18),
                const SizedBox(width: 3),
                Text(req['offer'] ?? "", style: const TextStyle(fontSize: 14, color: Colors.green)),
              ],
            ),
            const SizedBox(height: 3),
            // العنوان
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.orange, size: 18),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    req['location'] ?? "",
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // السعر وزر القبول
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${req['price']} جم",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: req['canPropose']
                      ? Text(
                    'يمكنك تقديم عرض سعر',
                    style: TextStyle(color: Colors.orange[700], fontWeight: FontWeight.bold, fontSize: 14),
                  )
                      : const SizedBox(),
                ),
                ElevatedButton(
                  onPressed: () {
                    // قبول الطلب (ممكن تفتح Dialog أو Snackbar)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم قبول العرض!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("قبول العرض", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ------------- BOTTOM NAV -------------
  Widget _buildBottomNav(bool isTablet) {
    final navIcons = [
      {"svg": "assets/icons/home.svg", "label": "الرئيسية"},
      {"svg": "assets/icons/orders.svg", "label": "الطلبات"},
      {"svg": "assets/icons/more.svg", "label": "المزيد"},
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: isTablet ? 13 : 8,
              horizontal: isTablet ? 24 : 6,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: navIcons.map((item) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      item["svg"]!,
                      width: isTablet ? 32 : 27,
                      colorFilter: ColorFilter.mode(
                        item["label"] == "الرئيسية" ? Colors.orange : Colors.grey[600]!,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item["label"]!,
                      style: TextStyle(
                        fontSize: isTablet ? 15 : 12,
                        fontWeight: item["label"] == "الرئيسية" ? FontWeight.bold : FontWeight.normal,
                        color: item["label"] == "الرئيسية" ? Colors.orange : Colors.grey[600],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
