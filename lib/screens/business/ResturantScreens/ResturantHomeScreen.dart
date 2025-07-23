import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:saba2v2/models/order_model.dart';
import 'package:saba2v2/widgets/restaurant_availability_switch.dart';
import 'package:saba2v2/widgets/order_card.dart';
import 'package:saba2v2/screens/business/ResturantScreens/order_details_screen.dart';

class ResturantHomeScreen extends StatefulWidget {
  const ResturantHomeScreen({super.key});

  @override
  State<ResturantHomeScreen> createState() => _ResturantHomeScreenState();
}

class _ResturantHomeScreenState extends State<ResturantHomeScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  bool _isAvailableForOrders = true;
  bool _isLoading = false;
  late List<OrderModel> _orders;

  // Track the current selected navigation item
  int _currentIndex = 0;

  // Responsive breakpoints
  static const double _tabletBreakpoint = 768.0;
  static const double _desktopBreakpoint = 1024.0;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadOrders();
  }

  void _initializeControllers() {
    _tabController = TabController(length: 3, vsync: this);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

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

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    _orders = [
      // قيد الانتظار
      OrderModel(
        id: "377",
        customerName: "كريم محمد",
        customerImage: "assets/images/user_avatar.jpg",
        orderTime: DateTime.now().subtract(const Duration(minutes: 15)),
        totalAmount: 2800,
        status: "قيد الانتظار",
        items: [
          OrderItem(
            name: "بيتزا مشروم 2x",
            image: "assets/images/pizza.jpg",
            price: 1800,
            quantity: 2,
          ),
          OrderItem(
            name: "بيتزا بيبروني 2x",
            image: "assets/images/pizza.jpg",
            price: 1000,
            quantity: 2,
          ),
        ],
      ),
      OrderModel(
        id: "376",
        customerName: "أحمد علي",
        customerImage: "assets/images/user_avatar.jpg",
        orderTime: DateTime.now().subtract(const Duration(minutes: 30)),
        totalAmount: 1500,
        status: "قيد الانتظار",
        items: [
          OrderItem(
            name: "برجر لحم",
            image: "assets/images/burger.png",
            price: 1500,
            quantity: 1,
          ),
        ],
      ),
      OrderModel(
        id: "375",
        customerName: "سارة أحمد",
        customerImage: "assets/images/user_avatar.jpg",
        orderTime: DateTime.now().subtract(const Duration(minutes: 45)),
        totalAmount: 3200,
        status: "قيد الانتظار",
        items: [
          OrderItem(
            name: "دجاج مشوي",
            image: "assets/images/chicken.jpg",
            price: 2200,
            quantity: 1,
          ),
          OrderItem(
            name: "سلطة خضراء",
            image: "assets/images/salad.jpg",
            price: 500,
            quantity: 1,
          ),
          OrderItem(
            name: "عصير برتقال",
            image: "assets/images/juice.jpg",
            price: 500,
            quantity: 1,
          ),
        ],
      ),
      // قيد التنفيذ
      OrderModel(
        id: "374",
        customerName: "محمد حسن",
        customerImage: "assets/images/user_avatar.jpg",
        orderTime: DateTime.now().subtract(const Duration(hours: 1)),
        totalAmount: 4500,
        status: "قيد التنفيذ",
        items: [
          OrderItem(
            name: "مشاوي مشكلة",
            image: "assets/images/grill.jpg",
            price: 3500,
            quantity: 1,
          ),
          OrderItem(
            name: "أرز بخاري",
            image: "assets/images/rice.jpg",
            price: 1000,
            quantity: 1,
          ),
        ],
      ),
      OrderModel(
        id: "373",
        customerName: "فاطمة محمود",
        customerImage: "assets/images/user_avatar.jpg",
        orderTime: DateTime.now().subtract(const Duration(hours: 1, minutes: 15)),
        totalAmount: 2000,
        status: "قيد التنفيذ",
        items: [
          OrderItem(
            name: "كريب دجاج",
            image: "assets/images/crepe.jpg",
            price: 1200,
            quantity: 1,
          ),
          OrderItem(
            name: "كريب لحم",
            image: "assets/images/crepe.jpg",
            price: 800,
            quantity: 1,
          ),
        ],
      ),
      // منتهية
      OrderModel(
        id: "372",
        customerName: "عمر خالد",
        customerImage: "assets/images/user_avatar.jpg",
        orderTime: DateTime.now().subtract(const Duration(hours: 3)),
        totalAmount: 1800,
        status: "منتهية",
        items: [
          OrderItem(
            name: "شاورما دجاج",
            image: "assets/images/shawarma.jpg",
            price: 1200,
            quantity: 1,
          ),
          OrderItem(
            name: "بطاطس",
            image: "assets/images/fries.jpg",
            price: 600,
            quantity: 1,
          ),
        ],
      ),
      OrderModel(
        id: "371",
        customerName: "ليلى سعيد",
        customerImage: "assets/images/user_avatar.jpg",
        orderTime: DateTime.now().subtract(const Duration(hours: 4)),
        totalAmount: 3500,
        status: "منتهية",
        items: [
          OrderItem(
            name: "بيتزا سوبريم",
            image: "assets/images/pizza.jpg",
            price: 2500,
            quantity: 1,
          ),
          OrderItem(
            name: "كوكا كولا",
            image: "assets/images/coke.jpg",
            price: 500,
            quantity: 2,
          ),
        ],
      ),
      OrderModel(
        id: "370",
        customerName: "يوسف أحمد",
        customerImage: "assets/images/user_avatar.jpg",
        orderTime: DateTime.now().subtract(const Duration(hours: 5)),
        totalAmount: 2700,
        status: "منتهية",
        items: [
          OrderItem(
            name: "برجر دجاج",
            image: "assets/images/burger.png",
            price: 1200,
            quantity: 1,
          ),
          OrderItem(
            name: "برجر لحم",
            image: "assets/images/burger.png",
            price: 1500,
            quantity: 1,
          ),
        ],
      ),
    ];

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isTablet = screenWidth >= _tabletBreakpoint;
        final isDesktop = screenWidth >= _desktopBreakpoint;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          body: SafeArea(
            child: Column(
              children: [
                _buildAppBar(context, isTablet),
                Expanded(
                  child: _buildMainContent(context, isTablet, isDesktop),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomNavigationBar(context, isTablet),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, bool isTablet) {
    return Container(
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
          vertical: isTablet ? 20.0 : 16.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildActionButtons(context, isTablet),
            _buildTitle(isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isTablet) {
    return Row(
      children: [
        _buildActionButton(
          icon: Icons.message_outlined,
          badge: "5",
          onTap: () {
            // Navigate to messages
          },
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

  Widget _buildTitle(bool isTablet) {
    return Text(
      "الرئيسية",
      style: TextStyle(
        fontSize: isTablet ? 24.0 : 20.0,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1F2937),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, bool isTablet, bool isDesktop) {
    return Column(
      children: [
        _buildAvailabilitySection(isTablet),
        _buildTabBar(isTablet),
        Expanded(
          child: _isLoading
              ? _buildLoadingIndicator()
              : _buildTabBarView(context, isTablet, isDesktop),
        ),
      ],
    );
  }

  Widget _buildAvailabilitySection(bool isTablet) {
    return RestaurantAvailabilitySwitch(
      isAvailable: _isAvailableForOrders,
      onChanged: (value) {
        setState(() {
          _isAvailableForOrders = value;
        });
      },
    );
  }

  Widget _buildTabBar(bool isTablet) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? 24.0 : 16.0,
        vertical: isTablet ? 16.0 : 6.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF6B7280),
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: isTablet ? 16.0 : 14.0,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: isTablet ? 16.0 : 14.0,
        ),
        tabs: [
          _buildTab("قيد الانتظار", 0, isTablet),
          _buildTab("قيد التنفيذ", 1, isTablet),
          _buildTab("منتهية", 2, isTablet),
        ],
      ),
    );
  }

  Widget _buildTab(String text, int index, bool isTablet) {
    final isSelected = _tabController.index == index;
    return Tab(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 20.0 : 16.0,
          vertical: isTablet ? 12.0 : 10.0,
        ),
        child: Text(text),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
      ),
    );
  }

  Widget _buildTabBarView(BuildContext context, bool isTablet, bool isDesktop) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildOrdersList(
            _orders.where((order) => order.status == "قيد الانتظار").toList(),
            isTablet,
            isDesktop,
          ),
          _buildOrdersList(
            _orders.where((order) => order.status == "قيد التنفيذ").toList(),
            isTablet,
            isDesktop,
          ),
          _buildOrdersList(
            _orders.where((order) => order.status == "منتهية").toList(),
            isTablet,
            isDesktop,
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<OrderModel> orders, bool isTablet, bool isDesktop) {
    if (orders.isEmpty) {
      return _buildEmptyState(isTablet);
    }

    final crossAxisCount = isDesktop ? 2 : 1;
    final padding = isTablet ? 24.0 : 16.0;

    if (crossAxisCount == 1) {
      return ListView.builder(
        padding: EdgeInsets.all(padding),
        itemCount: orders.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return _buildOrderItem(orders[index], index, isTablet);
        },
      );
    } else {
      return GridView.builder(
        padding: EdgeInsets.all(padding),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 1.2,
        ),
        itemCount: orders.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return _buildOrderItem(orders[index], index, isTablet);
        },
      );
    }
  }

  Widget _buildOrderItem(OrderModel order, int index, bool isTablet) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: EdgeInsets.only(bottom: isTablet ? 16.0 : 12.0),
              child: OrderCard(
                order: order,
                onViewDetails: _showOrderDetails,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isTablet) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: isTablet ? 80.0 : 64.0,
            color: const Color(0xFFD1D5DB),
          ),
          SizedBox(height: isTablet ? 24.0 : 16.0),
          Text(
            "لا توجد طلبات",
            style: TextStyle(
              fontSize: isTablet ? 20.0 : 18.0,
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: isTablet ? 12.0 : 8.0),
          Text(
            "ستظهر الطلبات الجديدة هنا",
            style: TextStyle(
              fontSize: isTablet ? 16.0 : 14.0,
              color: const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, bool isTablet) {
    int currentIndex = 0; // القائمة

    void onItemTapped(int index) {
      switch (index) {
        case 0:
          context.go('/restaurant-home');
          break;
        case 1:
          context.go('/Menu');
          break;
        case 2:
          context.go('/RestaurantAnalysisScreen');
          break;
        case 3:
          context.go('/SettingsProvider');
          break;
      }
    }

    final List<Map<String, String>> navIcons = [
      {"svg": "assets/icons/home_icon_provider.svg", "label": "الرئيسية"},
      {"svg": "assets/icons/Nav_Menu_provider.svg", "label": "القائمة"},
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
              vertical: isTablet ? 16 : 10,
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
                      vertical: isTablet ? 12 : 10,
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
  void _showOrderDetails(OrderModel order) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            OrderDetailsScreen(order: order),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                  .chain(CurveTween(curve: Curves.easeInOut)),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}