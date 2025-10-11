import 'package:saba2v2/components/realeState/property_form.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' as intl;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:saba2v2/models/appointment_model.dart';
import 'dart:io';
import 'dart:developer';

import 'package:saba2v2/models/property_model.dart';
import 'package:saba2v2/providers/auth_provider.dart';
import 'package:saba2v2/screens/conversations_list_screen.dart';
import 'package:saba2v2/screens/location_picker_screen.dart';
import 'package:saba2v2/components/realeState/appointment_card.dart';
import 'package:saba2v2/components/realeState/property_card.dart';
import 'package:saba2v2/components/realeState/delete_property_dialog.dart';
import 'package:saba2v2/components/realeState/enhanced_field.dart';
import 'package:saba2v2/screens/business/RealStateScreens/add_property_screen.dart';

import 'package:saba2v2/screens/business/RealStateScreens/add_property_screen.dart';
//==============================================================================
// تم نقل AppointmentCard إلى components/realeState/appointment_card.dart
//==============================================================================

//==============================================================================
// تم نقل PropertyCard إلى components/realeState/property_card.dart
//==============================================================================

//==============================================================================
// تم نقل DeletePropertyDialog إلى components/realeState/delete_property_dialog.dart
//==============================================================================

class RealStateHomeScreen extends StatefulWidget {
  const RealStateHomeScreen({super.key});

  @override
  State<RealStateHomeScreen> createState() => _RealStateHomeScreenState();
}

class _RealStateHomeScreenState extends State<RealStateHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
    log('[RealStateHomeScreen] initState: RealStateHomeScreen initialized. Starting data fetch.');

    // --- جلب بيانات العقارات والمواعيد عند بدء تشغيل الشاشة ---
    Future.microtask(() {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.fetchMyProperties();
      authProvider.fetchAppointments();
      // بدء الريفريش اللحظي للمواعيد
      authProvider.startAppointmentsAutoRefresh();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    
    // إيقاف الريفريش اللحظي عند الخروج من الشاشة
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.stopAppointmentsAutoRefresh();
    
    super.dispose();
  }

  void _handleTabSelection() {
    // إذا تم التبديل إلى تبويب المواعيد (index 0)
    if (_tabController.index == 0) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      // إجبار ريفريش فوري للمواعيد
      authProvider.forceRefreshAppointments();
    }
    log('[RealStateHomeScreen] _handleTabSelection: Tab selected: ${_tabController.index}');
    setState(() {});
  }

  void _addProperty(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userData = authProvider.userData;
    final isApproved =
        userData?['is_approved'] == 1 || userData?['is_approved'] == true;
    if (!isApproved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يستلزم قبول الإدمن للحساب لإضافة عقار جديد'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    log('[RealStateHomeScreen] _addProperty: Showing PropertyForm dialog.');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const PropertyForm(),
    );
  }

  void _editProperty(BuildContext context, Property propertyToEdit) {
    log('[RealStateHomeScreen] _editProperty: Edit property pressed for ID ${propertyToEdit.id}. Showing dialog...');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PropertyForm(property: propertyToEdit),
    );
  }
                              

  void _deleteProperty(BuildContext context, Property property) async {
    log('[RealStateHomeScreen] _deleteProperty: Delete button pressed for ID ${property.id}.');
    showDeletePropertyDialog(
      context,
      onConfirm: () async {
        log('[RealStateHomeScreen] _deleteProperty: Confirmed delete for ID ${property.id}.');
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final success = await authProvider.deleteProperty(property.id);

        if (context.mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('تم حذف العقار بنجاح!'),
                  backgroundColor: Colors.green),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('فشل حذف العقار'), backgroundColor: Colors.red),
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final paddingBottom = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, _isTablet(context)),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(25)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: _buildCustomTab(
                        icon: Icons.calendar_today,
                        text: 'مواعيدي',
                        isSelected: _tabController.index == 0,
                        onTap: () => setState(() => _tabController.animateTo(0))),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildCustomTab(
                        icon: Icons.home_work_outlined,
                        text: 'عقاراتي',
                        isSelected: _tabController.index == 1,
                        onTap: () => setState(() => _tabController.animateTo(1))),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // --- START: "مواعيدي" Tab ---
                  Consumer<AuthProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoadingAppointments) {
                        return const Center(child: CircularProgressIndicator(color: Colors.orange));
                      }

                      if (provider.appointmentsError != null) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text('حدث خطأ: ${provider.appointmentsError}', textAlign: TextAlign.center),
                          ),
                        );
                      }

                      if (provider.appointments.isEmpty) {
                        return const Center(
                          child: Text(
                            'لا توجد مواعيد مقترحة حاليًا.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          // إجبار الريفريش الفوري
                          await provider.forceRefreshAppointments();
                          // ثم جلب البيانات الكاملة
                          await provider.fetchAppointments();
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          itemCount: provider.appointments.length,
                          itemBuilder: (context, index) {
                            final appointment = provider.appointments[index];
                            return AppointmentCard(
        // استخدم ValueKey مع id الموعد لتعطيه هوية فريدة
        key: ValueKey(appointment.id), 
        appointment: appointment,
      );
                          },
                        ),
                      );
                    },
                  ),
                  // --- END: "مواعيدي" Tab ---

                  // --- START: "عقاراتي" Tab ---
                  Stack(
                    children: [
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          if (authProvider.isLoading &&
                              authProvider.properties.isEmpty) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (authProvider.properties.isEmpty) {
                            return const Center(
                                child: Text('لم تقم بإضافة أي عقارات بعد'));
                          }
                          return RefreshIndicator(
                            onRefresh: () => authProvider.fetchMyProperties(),
                            child: ListView.builder(
                              padding: EdgeInsets.only(
                                  top: 8,
                                  bottom: 80 + paddingBottom,
                                  left: 16,
                                  right: 16),
                              itemCount: authProvider.properties.length,
                              itemBuilder: (context, index) {
                                final property = authProvider.properties[index];
                                return PropertyCard(
                                  property: property,
                                  onEdit: () => _editProperty(context, property),
                                  onDelete: () =>
                                      _deleteProperty(context, property),
                                );
                              },
                            ),
                          );
                        },
                      ),
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 16,
                        child: ElevatedButton(
                          onPressed: () {
                            log('[RealStateHomeScreen] onPressed: Add property button pressed. Navigating to AddPropertyScreen...');
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const AddPropertyScreen(),
                              ),
                            ).then((result) {
                              if (result == true) {
                                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                authProvider.fetchMyProperties();
                              }
                            });
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12))),
                          child: const Text('إضافة عقار',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                  // --- END: "عقاراتي" Tab ---
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          _buildBottomNavigationBar(context, _isTablet(context)),
    );
  }

  bool _isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 768;

  

  Widget _buildAppBar(BuildContext context, bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 32.0 : 16.0,
            vertical: isTablet ? 20.0 : 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
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
           
            Text("الرئيسية",
                style: TextStyle(
                    fontSize: isTablet ? 24.0 : 20.0,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937))),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      {required IconData icon,
      required String badge,
      required VoidCallback onTap,
      required bool isTablet}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: isTablet ? 48.0 : 44.0,
          height: isTablet ? 48.0 : 44.0,
          decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12)),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onTap,
              child: Icon(icon,
                  size: isTablet ? 24.0 : 20.0, color: const Color(0xFF6B7280)),
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
                  color: Colors.red, shape: BoxShape.circle),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(badge,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 12.0 : 10.0,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
            ),
          ),
      ],
    );
  }

  Widget _buildCustomTab(
      {required IconData icon,
      required String text,
      required bool isSelected,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: isSelected ? Colors.white : Colors.grey[600], size: 20),
            const SizedBox(width: 8),
            Text(text,
                style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[800],
                    fontSize: 15,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, bool isTablet) {
    int currentIndex = 0;
    void onItemTapped(int index) {
      switch (index) {
        case 0:
          context.go('/RealStateHomeScreen');
          break;
        case 1:
          context.go('/RealStateAnalysisScreen');
          break;
        case 2:
          context.go('/RealStateSettingsProvider');
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
                offset: const Offset(0, -4))
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
                vertical: isTablet ? 16 : 10, horizontal: isTablet ? 20 : 8),
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
                        vertical: isTablet ? 12 : 10),
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
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w500,
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


