import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:saba2v2/screens/conversations_list_screen.dart';
import 'package:saba2v2/services/driver_service.dart';
import 'package:saba2v2/models/delivery_request_model.dart';
import 'package:saba2v2/providers/driver_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'submit_offer_screen.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  // خدمات وبيانات
  DriverService? _driverService;
  DriverState? _driverProvider;
  String? _userType;

  // متغير حالة لتتبع الطلب الذي يتم التفاعل معه
  int? _processingRequestId;

  // متغيرات حالة المفاتيح
  bool isAvailableForDelivery = false;

  // متغيرات حالة التحميل
  bool isLoadingPage = true;
  bool isUpdatingAvailability = false;

  // متغيرات حالة الواجهة
  int selectedTab = 0;

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('ar', timeago.ArMessages());
    _loadInitialData();
  }
  
  @override
  void dispose() {
    _driverProvider?.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userJsonString = prefs.getString('user_data');

      if (token == null || token.isEmpty || userJsonString == null || userJsonString.isEmpty) {
        throw Exception("بيانات المستخدم غير مكتملة.");
      }

      _driverService = DriverService(token: token);
      _driverProvider = DriverState(service: _driverService!);
      
      final userMap = jsonDecode(userJsonString);
      _userType = userMap['user_type'];

      if (_userType == 'driver') {
        // Initialize availability from user data
        isAvailableForDelivery = (userMap['is_available'] == true || userMap['is_available'] == 1);
      }
      
      await _driverProvider?.fetchAllRequests();
      _driverProvider?.startAutoRefresh();

    } catch (e) {
      if (mounted) {
        debugPrint("خطأ في تهيئة البيانات: $e");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("خطأ: $e"),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) {
        setState(() => isLoadingPage = false);
      }
    }
  }

  Future<void> _submitOffer(DeliveryRequestModel request) async {
    if (_driverProvider == null) return;
    
    // التنقل إلى صفحة تقديم العرض
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubmitOfferScreen(deliveryRequest: request),
      ),
    );
    
    // إذا تم تقديم العرض بنجاح، قم بتحديث القائمة
    if (result == true) {
      await _driverProvider?.fetchAllRequests();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final screenWidth = MediaQuery.of(context).size.width;

    if (_driverProvider == null || isLoadingPage) {
      return const Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return ChangeNotifierProvider.value(
      value: _driverProvider!,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          body: SafeArea(
            child: Column(
              children: [
                _buildAppBar(context, isTablet),
                if (_userType == 'driver')
                  _buildAvailabilitySection(isTablet, screenWidth),
                _buildTabsSection(screenWidth),
                Expanded(
                  child: Consumer<DriverState>(
                    builder: (context, provider, child) {
                      if (provider.isLoading && provider.allRequests.isEmpty) {
                        return const Center(child: CircularProgressIndicator(color: Colors.orange));
                      }
                      if (provider.error != null && provider.allRequests.isEmpty) {
                        return Center(child: Text("خطأ: ${provider.error}"));
                      }
                      return _buildRequestsList(isTablet, screenWidth);
                    },
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomNavigationBar(context, isTablet),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isTablet) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))]),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isTablet ? 32.0 : 16.0, vertical: isTablet ? 20.0 : 8.0),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text("طلبات التوصيل", style: TextStyle(fontSize: isTablet ? 24.0 : 20.0, fontWeight: FontWeight.bold, color: const Color(0xFF1F2937))),
           Row(
              children: [
                _buildActionButton(
                    icon: Icons.message_outlined,
                    badge: "",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ConversationsListScreen(),
                        ),
                      );
                    },
                    isTablet: isTablet),
                SizedBox(width: isTablet ? 16.0 : 12.0),
                _buildActionButton(
                    icon: Icons.notifications_outlined,
                    badge: "3",
                    onTap: () => context.push("/NotificationsScreen"),
                    isTablet: isTablet),
              ],
            ),
        ]
        )
        ,
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String badge, required VoidCallback onTap, required bool isTablet}) {
    return Stack(clipBehavior: Clip.none, children: [
      Container(width: isTablet ? 48.0 : 44.0, height: isTablet ? 48.0 : 44.0, decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12)), child: Material(color: Colors.transparent, child: InkWell(borderRadius: BorderRadius.circular(12), onTap: onTap, child: Icon(icon, size: isTablet ? 24.0 : 20.0, color: const Color(0xFF6B7280))))),
      if (badge.isNotEmpty) Positioned(top: -2, right: -2, child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), constraints: const BoxConstraints(minWidth: 18, minHeight: 18), child: Text(badge, style: TextStyle(color: Colors.white, fontSize: isTablet ? 12.0 : 10.0, fontWeight: FontWeight.bold), textAlign: TextAlign.center))),
    ]);
  }

  Widget _buildAvailabilitySection(bool isTablet, double screenWidth) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: screenWidth * 0.02),
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: screenWidth * 0.04),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 10)]),
      child: _buildSwitchRow(
        label: "متاح لاستقبال طلبات التوصيل",
        value: isAvailableForDelivery,
        isLoading: isUpdatingAvailability,
        onChanged: (newValue) async {
          if (_driverService == null) return;
          setState(() => isUpdatingAvailability = true);
          try {
            final success = await _driverService!.updateAvailability(
              isAvailable: newValue,
            );
            if (success && mounted) {
              setState(() => isAvailableForDelivery = newValue);
            } else if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("فشل تحديث الحالة"),
                backgroundColor: Colors.red,
              ));
            }
          } catch (e) {
            if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("فشل تحديث الحالة: $e"), backgroundColor: Colors.red));
          } finally {
            if(mounted) setState(() => isUpdatingAvailability = false);
          }
        },
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
    final List<String> tabTitles = ["طلبات متاحة", "عروضي المقدمة", "طلبات منتهية"];
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.03, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8)]
      ),
      child: Row(
        children: List.generate(tabTitles.length, (index) {
          final isSelected = selectedTab == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedTab = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.orange : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tabTitles[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 14
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildRequestsList(bool isTablet, double screenWidth) {
    return Consumer<DriverState>(
      builder: (context, provider, child) {
        List<DeliveryRequestModel> currentList;
        String emptyMessage;

        switch (selectedTab) {
          case 0:
            currentList = provider.availableRequests;
            emptyMessage = "طلبات متاحة";
            break;
          case 1:
            currentList = provider.myOffers;
            emptyMessage = "عروضي المقدمة";
            break;
          case 2:
            currentList = provider.completedRequests;
            emptyMessage = "طلبات منتهية";
            break;
          default:
            currentList = [];
            emptyMessage = "";
        }

        if (currentList.isEmpty) {
          return Center(child: Text("لا توجد طلبات في قسم '$emptyMessage' حاليًا", style: const TextStyle(fontSize: 16, color: Colors.grey)));
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02, vertical: 8),
          itemCount: currentList.length,
          itemBuilder: (context, index) {
            final deliveryRequest = currentList[index];
            return _buildRequestCard(deliveryRequest, isTablet, screenWidth);
          },
        );
      },
    );
  }

  Widget _buildRequestCard(DeliveryRequestModel request, bool isTablet, double screenWidth) {
    String typeText = "طلب توصيل #${request.id}";
    String clientText = "العميل: ${request.driver?.name ?? 'غير محدد'}";
    String governorateText = "المحافظة: غير محدد";
    String distanceText = "المسافة: - كم";
    String durationText = "الوقت المتوقع: - دقيقة";
    String priceText = "السعر المطلوب: ${request.requestedPrice?.toStringAsFixed(0) ?? '-'} جنيه";
    String serviceTypeText = "نوع الخدمة: ${request.tripType}";
    String fromText = request.fromLocation ?? '-';
    String toText = request.toLocation ?? '-';

    return Container(
      margin: EdgeInsets.only(bottom: screenWidth * 0.03),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))]),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header with request ID and time
          Row(children: [
            Icon(Icons.local_shipping, color: Colors.orange[700], size: isTablet ? 22 : 18), 
            SizedBox(width: screenWidth * 0.02), 
            Text(typeText, style: TextStyle(fontWeight: FontWeight.w600, fontSize: isTablet ? 16 : 14)), 
            const Spacer(), 
            Icon(Icons.access_time, color: Colors.grey, size: isTablet ? 18 : 15), 
            SizedBox(width: screenWidth * 0.01), 
            Text(timeago.format(request.createdAt, locale: 'ar'), style: TextStyle(fontSize: isTablet ? 14 : 12, color: Colors.grey))
          ]),
          SizedBox(height: screenWidth * 0.03),
          
          // Client and governorate info
          Row(children: [
            Icon(Icons.person, color: Colors.grey[600], size: isTablet ? 19 : 16), 
            SizedBox(width: screenWidth * 0.02), 
            Expanded(child: Text(clientText, style: TextStyle(fontSize: isTablet ? 15 : 13, fontWeight: FontWeight.w500))),
          ]),
          SizedBox(height: screenWidth * 0.02),
          Row(children: [
            Icon(Icons.location_city, color: Colors.blue[700], size: isTablet ? 19 : 16), 
            SizedBox(width: screenWidth * 0.02), 
            Expanded(child: Text(governorateText, style: TextStyle(fontSize: isTablet ? 15 : 13, color: Colors.blue))),
          ]),
          SizedBox(height: screenWidth * 0.02),
          
          // Service details in a card
          Container(
            padding: EdgeInsets.all(screenWidth * 0.03),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!)
            ),
            child: Column(children: [
              Row(children: [
                Icon(Icons.straighten, color: Colors.green[700], size: isTablet ? 19 : 16), 
                SizedBox(width: screenWidth * 0.02), 
                Text(distanceText, style: TextStyle(fontSize: isTablet ? 14 : 12, color: Colors.green, fontWeight: FontWeight.w500)), 
                const Spacer(), 
                Icon(Icons.timer, color: Colors.purple[700], size: isTablet ? 19 : 16), 
                SizedBox(width: screenWidth * 0.02), 
                Text(durationText, style: TextStyle(fontSize: isTablet ? 14 : 12, color: Colors.purple, fontWeight: FontWeight.w500))
              ]),
              SizedBox(height: screenWidth * 0.02),
              Row(children: [
                Icon(Icons.attach_money, color: Colors.orange[700], size: isTablet ? 19 : 16), 
                SizedBox(width: screenWidth * 0.02), 
                Text(priceText, style: TextStyle(fontSize: isTablet ? 14 : 12, color: Colors.orange[700], fontWeight: FontWeight.bold)), 
                const Spacer(), 
                Icon(Icons.build, color: Colors.indigo[700], size: isTablet ? 19 : 16), 
                SizedBox(width: screenWidth * 0.02), 
                Expanded(child: Text(serviceTypeText, style: TextStyle(fontSize: isTablet ? 14 : 12, color: Colors.indigo[700], fontWeight: FontWeight.w500)))
              ]),
            ]),
          ),
          SizedBox(height: screenWidth * 0.03),
          
          // Route information
          Container(
            padding: EdgeInsets.all(screenWidth * 0.03),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!)
            ),
            child: Column(children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20)
                  ),
                  child: Icon(Icons.my_location, color: Colors.white, size: isTablet ? 16 : 14)
                ),
                SizedBox(width: screenWidth * 0.03), 
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [
                    Text("نقطة الانطلاق", style: TextStyle(fontSize: isTablet ? 13 : 11, color: Colors.green[700], fontWeight: FontWeight.bold)), 
                    Text(fromText, style: TextStyle(fontSize: isTablet ? 14 : 12, color: Colors.black87, fontWeight: FontWeight.w500), maxLines: 2, overflow: TextOverflow.ellipsis)
                  ]
                ))
              ]),
              SizedBox(height: screenWidth * 0.02),
              Container(
                height: 2,
                margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green, Colors.red],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight
                  )
                ),
              ),
              SizedBox(height: screenWidth * 0.02),
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20)
                  ),
                  child: Icon(Icons.location_on, color: Colors.white, size: isTablet ? 16 : 14)
                ),
                SizedBox(width: screenWidth * 0.03), 
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [
                    Text("الوجهة النهائية", style: TextStyle(fontSize: isTablet ? 13 : 11, color: Colors.red[700], fontWeight: FontWeight.bold)), 
                    Text(toText, style: TextStyle(fontSize: isTablet ? 14 : 12, color: Colors.black87, fontWeight: FontWeight.w500), maxLines: 2, overflow: TextOverflow.ellipsis)
                  ]
                ))
              ]),
            ]),
          ),
          SizedBox(height: screenWidth * 0.03),

          if (selectedTab == 0)
            _buildActionButtonForCard(title: "تقديم عرض", price: request.requestedPrice, color: Colors.green, isLoading: _processingRequestId == request.id, onPressed: () => _submitOffer(request)),
            
          if (selectedTab == 1)
            Center(child: Text('تم تقديم عرض لهذا الطلب', style: TextStyle(color: Colors.blue[600], fontWeight: FontWeight.bold, fontSize: isTablet ? 15 : 13))),
            
          if (selectedTab == 2)
             Center(child: Text('تم الانتهاء من هذا الطلب', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: isTablet ? 15 : 13))),
        ]),
      ),
    );
  }

  Widget _buildActionButtonForCard({required String title, double? price, required Color color, required bool isLoading, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  if (price != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      "(${price.toStringAsFixed(0)} جنيه)",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 32.0 : 16.0,
            vertical: isTablet ? 16.0 : 8.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home,
                label: "الرئيسية",
                isSelected: true,
                onTap: () {},
                isTablet: isTablet,
              ),
              _buildNavItem(
                icon: Icons.list_alt,
                label: "طلباتي",
                isSelected: false,
                onTap: () => context.push("/driver/requests"),
                isTablet: isTablet,
              ),
              _buildNavItem(
                icon: Icons.person,
                label: "الملف الشخصي",
                isSelected: false,
                onTap: () => context.push("/profile"),
                isTablet: isTablet,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isTablet,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.orange : Colors.grey,
            size: isTablet ? 28.0 : 24.0,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.orange : Colors.grey,
              fontSize: isTablet ? 14.0 : 12.0,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}