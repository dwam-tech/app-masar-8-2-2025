import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:saba2v2/services/ar_rental_office_service.dart';
import 'package:saba2v2/models/service_request_model.dart';
import 'package:saba2v2/providers/service_provider_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

class CarRentalHomeScreen extends StatefulWidget {
  const CarRentalHomeScreen({super.key});

  @override
  State<CarRentalHomeScreen> createState() => _CarRentalHomeScreenState();
}

class _CarRentalHomeScreenState extends State<CarRentalHomeScreen> {
  // خدمات وبيانات
  CarRentalOfficeService? _officeService;
  ServiceProviderState? _serviceProvider;
  int? _officeDetailId;
  String? _userType;

  // متغير حالة لتتبع الطلب الذي يتم التفاعل معه
  int? _processingRequestId;

  // متغيرات حالة المفاتيح
  bool isDeliveryEnabled = false;
  bool isRentalEnabled = false;

  // متغيرات حالة التحميل
  bool isLoadingPage = true;
  bool isUpdatingDelivery = false;
  bool isUpdatingRental = false;

  // متغيرات حالة الواجهة
  int selectedTab = 0; // 0: انتظار, 1: تنفيذ, 2: منتهية

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('ar', timeago.ArMessages());
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userJsonString = prefs.getString('user_data');

      if (token == null || token.isEmpty || userJsonString == null || userJsonString.isEmpty) {
        throw Exception("بيانات المستخدم غير مكتملة.");
      }

      _officeService = CarRentalOfficeService(token: token);
      _serviceProvider = ServiceProviderState(service: _officeService!);
      
      final userMap = jsonDecode(userJsonString);
      _userType = userMap['user_type'];

      if (_userType == 'car_rental_office') {
        final officeDetail = userMap['car_rental']?['office_detail'];
        if (officeDetail != null) {
          _officeDetailId = officeDetail['id'];
          isDeliveryEnabled = (officeDetail['is_available_for_delivery'] == true || officeDetail['is_available_for_delivery'] == 1);
          isRentalEnabled = (officeDetail['is_available_for_rent'] == true || officeDetail['is_available_for_rent'] == 1);
        }
      }
      
      // جلب بيانات كل الطلبات باستخدام الـ Provider الجديد
      await _serviceProvider?.fetchAllRequests();
      _serviceProvider?.startAutoRefresh();

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

  Future<void> _acceptRequest(ServiceRequest request) async {
    if (_serviceProvider == null) return;
    
    setState(() => _processingRequestId = request.id);
    try {
      final success = await _serviceProvider!.acceptRequest(request.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("تم قبول الطلب بنجاح"),
          backgroundColor: Colors.green,
        ));
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("فشل في قبول الطلب: ${_serviceProvider?.error ?? 'خطأ غير معروف'}"),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("خطأ: ${e.toString().replaceAll("Exception: ", "")}"),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _processingRequestId = null);
    }
  }

  Future<void> _completeRequest(ServiceRequest request) async {
    if (_serviceProvider == null) return;
    
    setState(() => _processingRequestId = request.id);
    try {
      final success = await _serviceProvider!.completeRequest(request.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("تم إنهاء الطلب بنجاح"),
          backgroundColor: Colors.green,
        ));
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("فشل في إنهاء الطلب: ${_serviceProvider?.error ?? 'خطأ غير معروف'}"),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("خطأ: ${e.toString().replaceAll("Exception: ", "")}"),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _processingRequestId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final screenWidth = MediaQuery.of(context).size.width;

    // إذا لم يتم تهيئة الـ Provider بعد، عرض شاشة التحميل
    if (_serviceProvider == null) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          body: const SafeArea(
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      );
    }

    return ChangeNotifierProvider.value(
      value: _serviceProvider!,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          body: SafeArea(
            child: isLoadingPage
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      _buildAppBar(context, isTablet),
                      if (_userType == 'car_rental_office')
                        _buildSwitchesSection(isTablet, screenWidth),
                      _buildTabsSection(screenWidth),
                      Expanded(
                        child: Consumer<ServiceProviderState>(
                          builder: (context, provider, child) {
                            if (provider.isLoading && provider.allRequests.isEmpty) {
                              return const Center(child: CircularProgressIndicator(color: Colors.orange));
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

  // --- ودجات بناء الواجهة الفرعية ---

  
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
              if (_officeDetailId == null || _serviceProvider == null) return;
              setState(() => isUpdatingDelivery = true);
              try {
                final success = await _serviceProvider!.updateAvailability(
                  officeDetailId: _officeDetailId!,
                  isAvailableForDelivery: newValue,
                );
                if (success && mounted) {
                  setState(() => isDeliveryEnabled = newValue);
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("فشل تحديث الحالة: ${_serviceProvider?.error ?? 'خطأ غير معروف'}"),
                    backgroundColor: Colors.red,
                  ));
                }
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
              if (_officeDetailId == null || _serviceProvider == null) return;
              setState(() => isUpdatingRental = true);
              try {
                final success = await _serviceProvider!.updateAvailability(
                  officeDetailId: _officeDetailId!,
                  isAvailableForRent: newValue,
                );
                if (success && mounted) {
                  setState(() => isRentalEnabled = newValue);
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("فشل تحديث الحالة: ${_serviceProvider?.error ?? 'خطأ غير معروف'}"),
                    backgroundColor: Colors.red,
                  ));
                }
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


  /// --- [تم تعديل هذه الدالة بالكامل] ---
  Widget _buildTabsSection(double screenWidth) {
    final List<String> tabTitles = ["قيد الانتظار", "قيد التنفيذ", "منتهية"];
    
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

  /// --- [تم تعديل هذه الدالة بالكامل] ---
  Widget _buildRequestsList(bool isTablet, double screenWidth) {
    return Consumer<ServiceProviderState>(
      builder: (context, provider, child) {
        // اختيار القائمة الصحيحة بناءً على التبويب المختار
        List<ServiceRequest> currentList;
        String emptyMessage;

        switch (selectedTab) {
          case 0:
            currentList = provider.pendingRequests;
            emptyMessage = "قيد الانتظار";
            break;
          case 1:
            currentList = provider.acceptedRequests;
            emptyMessage = "قيد التنفيذ";
            break;
          case 2:
            currentList = provider.completedRequests;
            emptyMessage = "منتهية";
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
            final serviceRequest = currentList[index];
            return _buildRequestCard(serviceRequest, isTablet, screenWidth);
          },
        );
      },
    );
  }

  /// --- [تم تعديل هذه الدالة بالكامل] ---
  Widget _buildRequestCard(ServiceRequest request, bool isTablet, double screenWidth) {
    bool isRentRequest = request.type == "rent";

    // تحديد البيانات بناءً على نوع الطلب
    String typeText = isRentRequest ? "نوع الطلب: تأجير" : "نوع الطلب: توصيل";
    String clientText = isRentRequest ? "موديل: ${request.requestData.carModel ?? 'غير محدد'}" : "طلب توصيل #${request.id}";
    String offerText = isRentRequest ? "الفئة: ${request.requestData.carCategory ?? 'غير محدد'}" : "المحافظة: ${request.governorate}";
    String fromText = isRentRequest ? "من تاريخ: ${request.requestData.fromDate ?? '-'}" : request.requestData.fromLocation ?? '-';
    String toText = isRentRequest ? "إلى تاريخ: ${request.requestData.toDate ?? '-'}" : request.requestData.toLocation ?? '-';

    return Container(
      margin: EdgeInsets.only(bottom: screenWidth * 0.03),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))]),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(Icons.directions_car, color: Colors.orange[700], size: isTablet ? 22 : 18), SizedBox(width: screenWidth * 0.01), Text(typeText, style: TextStyle(fontWeight: FontWeight.w600, fontSize: isTablet ? 16 : 14)), const Spacer(), Icon(Icons.access_time, color: Colors.grey, size: isTablet ? 18 : 15), SizedBox(width: screenWidth * 0.01), Text(timeago.format(request.createdAt, locale: 'ar'), style: TextStyle(fontSize: isTablet ? 14 : 12, color: Colors.grey))]),
          SizedBox(height: screenWidth * 0.02),
          Row(children: [Icon(Icons.person, color: Colors.grey[600], size: isTablet ? 19 : 16), SizedBox(width: screenWidth * 0.01), Text(clientText, style: TextStyle(fontSize: isTablet ? 16 : 14, fontWeight: FontWeight.w500)), const Spacer(), Icon(Icons.local_offer, color: Colors.green[700], size: isTablet ? 19 : 16), SizedBox(width: screenWidth * 0.01), Text(offerText, style: TextStyle(fontSize: isTablet ? 15 : 13, color: Colors.green))]),
          Divider(color: Colors.grey[300], thickness: 1, height: 24, indent: 16, endIndent: 16),
          Row(children: [Icon(Icons.location_on, color: Colors.orange, size: isTablet ? 19 : 16), SizedBox(width: screenWidth * 0.01), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("من", style: TextStyle(fontSize: isTablet ? 15 : 13, color: Colors.black54)), Text(fromText, style: TextStyle(fontSize: isTablet ? 15 : 13, color: Colors.black, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)]))]),
          SizedBox(height: screenWidth * 0.02),
          Row(children: [Icon(Icons.location_on, color: Colors.orange, size: isTablet ? 19 : 16), SizedBox(width: screenWidth * 0.01), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("إلى", style: TextStyle(fontSize: isTablet ? 15 : 13, color: Colors.black54)), Text(toText, style: TextStyle(fontSize: isTablet ? 15 : 13, color: Colors.black, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)]))]),
          SizedBox(height: screenWidth * 0.03),

          // --- [الجزء الأهم: الزر الديناميكي] ---
          if (selectedTab == 0) // تبويب قيد الانتظار
            _buildActionButtonForCard(
              title: "قبول الطلب",
              price: request.requestData.price,
              color: Colors.green,
              isLoading: _processingRequestId == request.id,
              onPressed: () => _acceptRequest(request),
            ),
            
          if (selectedTab == 1) // تبويب قيد التنفيذ
            _buildActionButtonForCard(
              title: "إنهاء الطلب",
              price: request.requestData.price,
              color: Colors.red,
              isLoading: _processingRequestId == request.id,
              onPressed: () => _completeRequest(request),
            ),
            
          if (selectedTab == 2) // تبويب منتهية
             Center(child: Text('تم الانتهاء من هذا الطلب', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: isTablet ? 15 : 13))),

        ]),
      ),
    );
  }

  /// ودجت مساعدة لبناء زر الكارت
  Widget _buildActionButtonForCard({
    required String title,
    int? price,
    required Color color,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 1
        ),
        child: isLoading
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    if (price != null)
                      Row(children: [
                        Text("$price", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        const Text(" ج.م", style: TextStyle(fontSize: 14))
                      ])
                  ],
                ),
              ),
      )
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

  @override
  void dispose() {
    _serviceProvider?.dispose();
    super.dispose();
  }
}