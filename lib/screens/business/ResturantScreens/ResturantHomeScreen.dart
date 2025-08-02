import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:saba2v2/models/order_model.dart';
import 'package:saba2v2/providers/restaurant_order_provider.dart';
import 'package:saba2v2/widgets/restaurant_availability_switch.dart';
import 'package:saba2v2/widgets/order_card.dart';
import 'package:saba2v2/screens/business/ResturantScreens/order_details_screen.dart';

class ResturantHomeScreen extends StatefulWidget {
  const ResturantHomeScreen({super.key});

  @override
  State<ResturantHomeScreen> createState() => _ResturantHomeScreenState();
}

class _ResturantHomeScreenState extends State<ResturantHomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isAvailableForOrders = true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RestaurantOrderProvider>(context, listen: false).fetchOrders();
    });
  }

  void _initializeControllers() {
    _tabController = TabController(length: 3, vsync: this);
    _fadeController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));
    _tabController.addListener(_onTabChanged);
    _fadeController.forward();
  }

  void _onTabChanged() {
    if (mounted) {
      setState(() {});
      _fadeController.reset();
      _fadeController.forward();
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // **التعديل الحاسم: بناء Scaffold أولاً**
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(context),
      body: SafeArea(
        // **استخدام Builder للحصول على context صحيح داخل الـ Scaffold**
        child: Builder(
          builder: (scaffoldContext) {
            return _buildMainContent(scaffoldContext);
          }
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 768.0;
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      shadowColor: Colors.black.withOpacity(0.05),
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: isTablet ? 32.0 : 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildActionButtons(context, isTablet),
            _buildTitle(isTablet),
          ],
        ),
      ),
      toolbarHeight: isTablet ? 80 : 70,
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isTablet) {
    return Row(
      children: [
       
        _buildActionButton(icon: Icons.message_outlined, badge: "", onTap: () => context.push("/conversations"), isTablet: isTablet),
        SizedBox(width: isTablet ? 16.0 : 12.0),
        _buildActionButton(icon: Icons.notifications_outlined, badge: "3", onTap: () => context.push("/NotificationsScreen"), isTablet: isTablet),
      ],
    );
  }

  Widget _buildActionButton({required IconData icon, required String badge, required VoidCallback onTap, required bool isTablet}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: isTablet ? 48.0 : 44.0, height: isTablet ? 48.0 : 44.0,
          decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12)),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onTap,
              child: Icon(icon, size: isTablet ? 24.0 : 20.0, color: const Color(0xFF6B7280)),
            ),
          ),
        ),
        if (badge.isNotEmpty)
          Positioned(
            top: -2, right: -2,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(badge, style: TextStyle(color: Colors.white, fontSize: isTablet ? 12.0 : 10.0, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            ),
          ),
      ],
    );
  }

  Widget _buildTitle(bool isTablet) {
    return Text("الرئيسية", style: TextStyle(fontSize: isTablet ? 24.0 : 20.0, fontWeight: FontWeight.bold, color: const Color(0xFF1F2937)));
  }

  Widget _buildMainContent(BuildContext context) {
    final orderProvider = Provider.of<RestaurantOrderProvider>(context);
    final isTablet = MediaQuery.of(context).size.width >= 768.0;
    
    return Column(
      children: [
        RestaurantAvailabilitySwitch(isAvailable: _isAvailableForOrders, onChanged: (value) => setState(() => _isAvailableForOrders = value)),
        _buildTabBar(isTablet),
        Expanded(
          child: orderProvider.isLoading
              ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.orange)))
              : _buildTabBarView(context, isTablet, orderProvider),
        ),
      ],
    );
  }

  Widget _buildTabBar(bool isTablet) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isTablet ? 24.0 : 16.0, vertical: isTablet ? 16.0 : 6.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(12)),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF6B7280),
        labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: isTablet ? 16.0 : 14.0),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: isTablet ? 16.0 : 14.0),
        tabs: const [Tab(text: "طلبات جديدة"), Tab(text: "قيد التنفيذ"), Tab(text: "منتهية")],
      ),
    );
  }
  
  Widget _buildTabBarView(BuildContext context, bool isTablet, RestaurantOrderProvider orderProvider) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024.0;
    return FadeTransition(
      opacity: _fadeAnimation,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildOrdersList(orderProvider.getOrdersByStatus('accepted_by_admin'), isTablet, isDesktop),
          _buildOrdersList(orderProvider.getOrdersByStatus('processing'), isTablet, isDesktop),
          _buildOrdersList(orderProvider.getOrdersByStatus('completed'), isTablet, isDesktop),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<OrderModel> orders, bool isTablet, bool isDesktop) {
    if (orders.isEmpty) return _buildEmptyState(isTablet);

    return ListView.builder(
      padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
      itemCount: orders.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) => OrderCard(order: orders[index], onViewDetails: _showOrderDetails),
    );
  }

  Widget _buildEmptyState(bool isTablet) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: isTablet ? 80.0 : 64.0, color: const Color(0xFFD1D5DB)),
          SizedBox(height: isTablet ? 24.0 : 16.0),
          Text("لا توجد طلبات", style: TextStyle(fontSize: isTablet ? 20.0 : 18.0, color: const Color(0xFF6B7280), fontWeight: FontWeight.w600)),
          SizedBox(height: isTablet ? 12.0 : 8.0),
          Text("ستظهر الطلبات الجديدة هنا", style: TextStyle(fontSize: isTablet ? 16.0 : 14.0, color: const Color(0xFF9CA3AF))),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 768.0;
    int currentIndex = 0; // دائماً الرئيسية في هذه الشاشة

    void onItemTapped(int index) {
      if (index == currentIndex) return; // لا تفعل شيئًا إذا كانت نفس الصفحة
      switch (index) {
        case 0: context.go('/restaurant-home'); break;
        case 1: context.go('/Menu'); break;
        case 2: context.go('/RestaurantAnalysisScreen'); break;
        case 3: context.go('/SettingsProvider'); break;
      }
    }

    final navItems = [
      {"svg": "assets/icons/home_icon_provider.svg", "label": "الرئيسية"},
      {"svg": "assets/icons/Nav_Menu_provider.svg", "label": "القائمة"},
      {"svg": "assets/icons/Nav_Analysis_provider.svg", "label": "الإحصائيات"},
      {"svg": "assets/icons/Settings.svg", "label": "الإعدادات"},
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.orange,
        unselectedItemColor: const Color(0xFF6B7280),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        items: navItems.map((item) => BottomNavigationBarItem(
          icon: Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: SvgPicture.asset(item["svg"]!, height: isTablet ? 28 : 24, colorFilter: const ColorFilter.mode(Color(0xFF6B7280), BlendMode.srcIn)),
          ),
          activeIcon: Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: SvgPicture.asset(item["svg"]!, height: isTablet ? 28 : 24, colorFilter: const ColorFilter.mode(Colors.orange, BlendMode.srcIn)),
          ),
          label: item["label"]!,
        )).toList(),
      ),
    );
  }

  void _showOrderDetails(OrderModel order) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OrderDetailsScreen(order: order)),
    );
  }
}