import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:saba2v2/models/my_orders_model.dart';
import 'package:saba2v2/services/laravel_service.dart';
import 'package:intl/intl.dart';
import '../../widgets/my_bottom_nav_bar.dart';
import 'widgets/order_card_widget.dart';
import 'widgets/order_details_dialogs.dart';
import 'widgets/order_filter_widgets.dart';
import 'widgets/order_tab_widgets.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> with TickerProviderStateMixin {
  List<MyOrderModel> orders = [];
  List<MyOrderModel> filteredOrders = [];
  bool isLoading = true;
  String? errorMessage;

  // Tab Controller
  late TabController _tabController;
  
  // Filter variables
  String? selectedStatus = 'الكل';
  String searchQuery = '';
  DateTimeRange? selectedDateRange;

  // Animation controllers
  late AnimationController _filterAnimationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _filterAnimation;
  
  bool showFilters = false;

  final List<String> orderStatuses = ['الكل', 'قيد الانتظار', 'مقبول', 'مرفوض', 'مكتمل', 'ملغي'];
  
  // Tab categories
  final List<Map<String, dynamic>> tabCategories = [
    {'name': 'الكل', 'type': 'all'},
    {'name': 'المطاعم', 'type': 'restaurant_order'},
    {'name': 'العقارات', 'type': 'property_appointment'},
    {'name': 'أخرى', 'type': 'other'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabCategories.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    
    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _filterAnimation = CurvedAnimation(
      parent: _filterAnimationController,
      curve: Curves.easeInOut,
    );
    _fetchOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _filterAnimationController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }
  
  void _onTabChanged() {
    setState(() {
      _applyFilters();
    });
  }

  Future<void> _fetchOrders() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
      final _laravelService = LaravelService();
      final token = await _laravelService.getToken();
      if (token == null) {
        setState(() {
          errorMessage = 'يرجى تسجيل الدخول أولاً';
          isLoading = false;
        });
        return;
      }

      final response = await LaravelService.get('/my-orders/all', token: token);
      
      if (response['status'] == true) {
        try {
          final ordersResponse = MyOrdersResponse.fromJson(response['data']);
          setState(() {
            orders = ordersResponse.orders;
            _applyFilters();
            isLoading = false;
          });
          _cardAnimationController.forward();
        } catch (parseError) {
          setState(() {
            errorMessage = 'خطأ في تحليل البيانات المستلمة من الخادم';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = response['message'] ?? 'فشل في جلب الطلبات';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        if (e.toString().contains('FormatException')) {
          errorMessage = 'خطأ في تنسيق التاريخ المستلم من الخادم';
        } else if (e.toString().contains('SocketException')) {
          errorMessage = 'خطأ في الاتصال بالخادم';
        } else {
          errorMessage = 'حدث خطأ أثناء جلب الطلبات: ${e.toString()}';
        }
        isLoading = false;
      });
    }
  }

  void _applyFilters() {
    filteredOrders = orders.where((order) {
      // Tab filter
      final currentTab = tabCategories[_tabController.index];
      final tabType = currentTab['type'] as String;
      if (tabType != 'all') {
        switch (tabType) {
          case 'restaurant_order':
            if (order.type != 'restaurant_order') return false;
            break;
          case 'property_appointment':
            if (order.type != 'property_appointment') return false;
            break;
          case 'other':
            if (order.type == 'restaurant_order' || order.type == 'property_appointment') return false;
            break;
        }
      }
      
      // Status filter
      if (selectedStatus != 'الكل' && order.statusText != selectedStatus) {
        return false;
      }

      // Search filter
      if (searchQuery.isNotEmpty) {
        final searchLower = searchQuery.toLowerCase();
        if (!order.orderNumber.toLowerCase().contains(searchLower) &&
            !order.orderTypeText.toLowerCase().contains(searchLower)) {
          return false;
        }
      }

      // Date range filter
      if (selectedDateRange != null && order.createdAt != null) {
        final orderDate = _parseDate(order.createdAt!);
        if (orderDate != null) {
          if (orderDate.isBefore(selectedDateRange!.start) ||
              orderDate.isAfter(selectedDateRange!.end.add(const Duration(days: 1)))) {
            return false;
          }
        }
      }

      return true;
    }).toList();

    // Sort by date (newest first)
    filteredOrders.sort((a, b) {
      if (a.createdAt == null && b.createdAt == null) return 0;
      if (a.createdAt == null) return 1;
      if (b.createdAt == null) return -1;
      
      final dateA = _parseDate(a.createdAt!);
      final dateB = _parseDate(b.createdAt!);
      
      if (dateA != null && dateB != null) {
        return dateB.compareTo(dateA);
      } else if (dateA == null && dateB == null) {
        // If both dates are invalid, fall back to string comparison
        return b.createdAt!.compareTo(a.createdAt!);
      } else if (dateA == null) {
        return 1; // Put invalid dates at the end
      } else {
        return -1; // Put invalid dates at the end
      }
    });
  }

  void _toggleFilters() {
    setState(() {
      showFilters = !showFilters;
      if (showFilters) {
        _filterAnimationController.forward();
      } else {
        _filterAnimationController.reverse();
      }
    });
  }

  DateTime? _parseDate(String dateString) {
    try {
      // Try different date formats
      final formats = [
        'yyyy-MM-dd HH:mm:ss',
        'yyyy-MM-dd',
        'dd/MM/yyyy',
        'MM/dd/yyyy',
        'yyyy-MM-ddTHH:mm:ss.SSSZ',
        'yyyy-MM-ddTHH:mm:ssZ',
      ];
      
      for (final format in formats) {
        try {
          return DateFormat(format).parse(dateString);
        } catch (e) {
          continue;
        }
      }
      
      // If all formats fail, try DateTime.parse as last resort
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  void _clearFilters() {
    setState(() {
      selectedStatus = 'الكل';
      searchQuery = '';
      selectedDateRange = null;
      _applyFilters();
    });
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: selectedDateRange,
      locale: const Locale('ar'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: const Color(0xFFFC8700),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        selectedDateRange = picked;
        _applyFilters();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'طلباتي',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFFFC8700),
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        actions: [
          IconButton(
            icon: Icon(
              showFilters ? Icons.filter_list_off : Icons.filter_list,
              color: const Color(0xFFFC8700),
            ),
            onPressed: _toggleFilters,
          ),
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Color(0xFFFC8700),
            ),
            onPressed: _fetchOrders,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                  _applyFilters();
                });
              },
              decoration: InputDecoration(
                hintText: 'البحث في الطلبات...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFFFC8700)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFC8700), width: 2),
                ),
                filled: true,
                fillColor: const Color(0xFFF8F9FA),
              ),
            ),
          ),
          
          // Filters
          AnimatedBuilder(
            animation: _filterAnimation,
            builder: (context, child) {
              return SizeTransition(
                sizeFactor: _filterAnimation,
                child: OrderFilterWidgets.buildFilterChips(
                  selectedStatus: selectedStatus,
                  selectedDateRange: selectedDateRange,
                  onStatusChanged: (status) {
                    setState(() {
                      selectedStatus = status;
                      _applyFilters();
                    });
                  },
                  onDateRangeChanged: (dateRange) {
                    setState(() {
                      selectedDateRange = dateRange;
                      _applyFilters();
                    });
                  },
                  onClearFilters: _clearFilters,
                ),
              );
            },
          ),
          
          // Tab Bar
          OrderTabWidgets.buildTabBar(
            tabController: _tabController,
            tabCategories: tabCategories,
            orders: orders,
          ),
          
          // Content
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFFC8700),
                    ),
                  )
                : errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              errorMessage!,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _fetchOrders,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFC8700),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('إعادة المحاولة'),
                            ),
                          ],
                        ),
                      )
                    : OrderTabWidgets.buildTabBarView(
                        tabController: _tabController,
                        tabCategories: tabCategories,
                        orders: orders,
                        filteredOrders: filteredOrders,
                        cardAnimationController: _cardAnimationController,
                        selectedStatus: selectedStatus,
                        selectedDateRange: selectedDateRange,
                        onOrderTap: (order) {
                          showOrderDetails(context, order);
                        },
                        onClearFilters: _clearFilters,
                      ),
          ),
        ],
      ),
      bottomNavigationBar: const MyBottomNavBar(
        currentIndex: 1,
        routes: ['/UserHomeScreen', '/my-orders', '/cart', '/SettingsUser'],
      ),
    );
  }
}