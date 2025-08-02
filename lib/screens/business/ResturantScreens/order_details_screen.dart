import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saba2v2/models/order_model.dart';
import 'package:saba2v2/services/order_service.dart';
import 'package:saba2v2/providers/restaurant_order_provider.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderModel order;

  const OrderDetailsScreen({
    super.key,
    required this.order,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  bool _isLoading = false;
  final OrderService _orderService = OrderService();
  late OrderModel _currentOrder; // لتتبع الطلب المحدث

  // Responsive breakpoints
  static const double _tabletBreakpoint = 768.0;
  static const double _desktopBreakpoint = 1024.0;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order; // تهيئة الطلب الحالي
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutQuart,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: LayoutBuilder(
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
                    child: _buildBody(context, isTablet, isDesktop),
                  ),
                  _buildActionButtons(context, isTablet),
                ],
              ),
            ),
          );
        },
      ),
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
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "تفاصيل الطلب",
                    style: TextStyle(
                      fontSize: isTablet ? 24.0 : 20.0,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                      fontFamily: 'Cairo', // يفضل استخدام خط عربي
                    ),
                  ),
                  SizedBox(height: isTablet ? 6.0 : 4.0),
                  Row(
                    children: [
                      Text(
                        "رقم الطلب: ",
                        style: TextStyle(
                          fontSize: isTablet ? 16.0 : 14.0,
                          color: const Color(0xFF6B7280),
                          fontFamily: 'Cairo',
                        ),
                      ),
                      Text(
                        "#${_currentOrder.orderNumber}",
                        style: TextStyle(
                          fontSize: isTablet ? 16.0 : 14.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: isTablet ? 20.0 : 16.0),
            _buildStatusChip(isTablet),
            SizedBox(width: isTablet ? 20.0 : 16.0),
            _buildRefreshButton(context, isTablet),
            SizedBox(width: isTablet ? 12.0 : 8.0),
            _buildBackButton(context, isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildRefreshButton(BuildContext context, bool isTablet) {
    return Container(
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
          onTap: _isLoading ? null : () => _refreshOrderData(context),
          child: Icon(
            Icons.refresh,
            size: isTablet ? 22.0 : 18.0,
            color: _isLoading ? Colors.grey : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context, bool isTablet) {
    return Container(
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
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_forward_ios, // تغيير الأيقونة للاتجاه العربي
            size: isTablet ? 22.0 : 18.0,
            color: const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool isTablet) {
    Color statusColor = _getStatusColor(_currentOrder.status);
    Color backgroundColor = statusColor.withOpacity(0.1);
    String statusText = _getStatusDisplayText(_currentOrder.status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 16.0 : 12.0,
        vertical: isTablet ? 8.0 : 6.0,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: isTablet ? 14.0 : 12.0,
          fontWeight: FontWeight.w600,
          color: statusColor,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, bool isTablet, bool isDesktop) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: isDesktop
              ? _buildDesktopLayout(context, isTablet, isDesktop)
              : _buildMobileLayout(context, isTablet),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, bool isTablet) {
    final padding = isTablet ? 24.0 : 16.0;

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCustomerInfo(isTablet),
          SizedBox(height: isTablet ? 24.0 : 20.0),
          _buildOrderInfo(isTablet),
          SizedBox(height: isTablet ? 24.0 : 20.0),
          _buildOrderItems(isTablet),
          SizedBox(height: isTablet ? 24.0 : 20.0),
          _buildOrderSummary(isTablet),
          SizedBox(height: isTablet ? 100.0 : 80.0), // Space for action buttons
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, bool isTablet, bool isDesktop) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCustomerInfo(true),
                const SizedBox(height: 24.0),
                _buildOrderInfo(true),
                const SizedBox(height: 24.0),
                _buildOrderItems(true),
              ],
            ),
          ),
          const SizedBox(width: 32.0),
          Expanded(
            flex: 1,
            child: _buildOrderSummary(true),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo(bool isTablet) {
    return _buildCard(
      isTablet: isTablet,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("معلومات العميل", isTablet),
          SizedBox(height: isTablet ? 16.0 : 12.0),
          Row(
            children: [
              Container(
                width: isTablet ? 60.0 : 50.0,
                height: isTablet ? 60.0 : 50.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade200,
                ),
                child: Icon(
                  Icons.person,
                  size: isTablet ? 30.0 : 25.0,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(width: isTablet ? 16.0 : 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentOrder.customerName,
                      style: TextStyle(
                        fontSize: isTablet ? 20.0 : 18.0,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F2937),
                        fontFamily: 'Cairo',
                      ),
                    ),
                    SizedBox(height: isTablet ? 6.0 : 4.0),
                    Text(
                      _formatOrderTime(_currentOrder.orderTime),
                      style: TextStyle(
                        fontSize: isTablet ? 16.0 : 14.0,
                        color: const Color(0xFF6B7280),
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfo(bool isTablet) {
    return _buildCard(
      isTablet: isTablet,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("معلومات الطلب", isTablet),
          SizedBox(height: isTablet ? 16.0 : 12.0),
          _buildInfoRow(
            "وقت الطلب",
            _formatOrderTime(_currentOrder.orderTime),
            isTablet,
          ),
          SizedBox(height: isTablet ? 12.0 : 8.0),
          _buildInfoRow(
            "حالة الطلب",
            _getStatusDisplayText(_currentOrder.status),
            isTablet,
            valueColor: _getStatusColor(_currentOrder.status),
          ),
          SizedBox(height: isTablet ? 12.0 : 8.0),
          _buildInfoRow(
            "عدد الأصناف",
            "${_currentOrder.items.length} صنف",
            isTablet,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItems(bool isTablet) {
    return _buildCard(
      isTablet: isTablet,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("تفاصيل الطلب", isTablet),
          SizedBox(height: isTablet ? 16.0 : 12.0),
          ..._currentOrder.items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 300 + (index * 100)),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(-20 * (1 - value), 0), // تغيير الاتجاه للعربية
                  child: Opacity(
                    opacity: value,
                    child: _buildOrderItem(item, isTablet, index == _currentOrder.items.length - 1),
                  ),
                );
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item, bool isTablet, bool isLast) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : (isTablet ? 16.0 : 12.0)),
      child: Row(
        children: [
          Container(
            width: isTablet ? 60.0 : 50.0,
            height: isTablet ? 60.0 : 50.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade200,
            ),
            child: Icon(
              Icons.fastfood,
              size: isTablet ? 30.0 : 25.0,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(width: isTablet ? 16.0 : 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: isTablet ? 18.0 : 16.0,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                    fontFamily: 'Cairo',
                  ),
                ),
                SizedBox(height: isTablet ? 6.0 : 4.0),
                Text(
                  "الكمية: ${item.quantity}",
                  style: TextStyle(
                    fontSize: isTablet ? 14.0 : 12.0,
                    color: const Color(0xFF6B7280),
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
          Text(
            "${item.price} جنيه",
            style: TextStyle(
              fontSize: isTablet ? 18.0 : 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(bool isTablet) {
    return _buildCard(
      isTablet: isTablet,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("ملخص الطلب", isTablet),
          SizedBox(height: isTablet ? 16.0 : 12.0),
          _buildSummaryRow("المجموع الفرعي", "${_currentOrder.totalAmount}", isTablet),
          SizedBox(height: isTablet ? 12.0 : 8.0),
          _buildSummaryRow("رسوم التوصيل", "20", isTablet),
          SizedBox(height: isTablet ? 12.0 : 8.0),
          _buildSummaryRow("الضرائب", "15", isTablet),
          SizedBox(height: isTablet ? 16.0 : 12.0),
          Divider(color: Colors.grey.shade300),
          SizedBox(height: isTablet ? 16.0 : 12.0),
          _buildSummaryRow(
            "المجموع النهائي",
            "${_currentOrder.totalAmount + 35}",
            isTablet,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required bool isTablet, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
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
      child: child,
    );
  }

  Widget _buildSectionTitle(String title, bool isTablet) {
    return Text(
      title,
      style: TextStyle(
        fontSize: isTablet ? 20.0 : 18.0,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1F2937),
        fontFamily: 'Cairo',
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isTablet, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTablet ? 16.0 : 14.0,
            color: const Color(0xFF6B7280),
            fontFamily: 'Cairo',
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTablet ? 16.0 : 14.0,
            fontWeight: FontWeight.w600,
            color: valueColor ?? const Color(0xFF1F2937),
            fontFamily: 'Cairo',
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, bool isTablet, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTablet ? (isTotal ? 18.0 : 16.0) : (isTotal ? 16.0 : 14.0),
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? const Color(0xFF1F2937) : const Color(0xFF6B7280),
            fontFamily: 'Cairo',
          ),
        ),
        Text(
          "$value جنيه",
          style: TextStyle(
            fontSize: isTablet ? (isTotal ? 18.0 : 16.0) : (isTotal ? 16.0 : 14.0),
            fontWeight: FontWeight.bold,
            color: isTotal ? Colors.orange : const Color(0xFF1F2937),
            fontFamily: 'Cairo',
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isTablet) {
    // Don't show buttons for completed, rejected, or pending orders
    if (_currentOrder.status == "completed" || 
        _currentOrder.status == "rejected_by_admin" || 
        _currentOrder.status == "pending") {
      if (_currentOrder.status == "completed") {
        return Container(
          padding: EdgeInsets.all(isTablet ? 20.0 : 16.0),
          child: Text(
            "تم إكمال الطلب بنجاح",
            style: TextStyle(
              fontSize: isTablet ? 18.0 : 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
            textAlign: TextAlign.center,
          ),
        );
      }
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(isTablet ? 20.0 : 16.0),
      child: Column(
        children: [
          if (_currentOrder.status == "accepted_by_admin") ...[
            SizedBox(
              width: double.infinity,
              height: isTablet ? 56.0 : 48.0,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _handleStartProcessing(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: isTablet ? 24.0 : 20.0,
                        width: isTablet ? 24.0 : 20.0,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        "بدء معالجة الطلب",
                        style: TextStyle(
                          fontSize: isTablet ? 16.0 : 14.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ] else if (_currentOrder.status == "processing") ...[
            SizedBox(
              width: double.infinity,
              height: isTablet ? 56.0 : 48.0,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _handleCompleteOrder(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: isTablet ? 24.0 : 20.0,
                        width: isTablet ? 24.0 : 20.0,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        "إكمال الطلب",
                        style: TextStyle(
                          fontSize: isTablet ? 16.0 : 14.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }



  String _formatOrderTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return "منذ ${difference.inMinutes} دقيقة";
    } else if (difference.inHours < 24) {
      return "منذ ${difference.inHours} ساعة";
    } else {
      return "منذ ${difference.inDays} يوم";
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "accepted_by_admin":
        return Colors.orange;
      case "processing":
        return Colors.blue;
      case "completed":
        return Colors.green;
      case "rejected_by_admin":
        return Colors.red;
      case "pending":
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getStatusDisplayText(String status) {
    switch (status) {
      case "accepted_by_admin":
        return "معتمد من الإدارة";
      case "processing":
        return "قيد المعالجة";
      case "completed":
        return "مكتمل";
      case "rejected_by_admin":
        return "مرفوض من الإدارة";
      case "pending":
        return "معلق";
      default:
        return status;
    }
  }

  Future<void> _refreshOrderData(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final refreshedOrder = await _orderService.getOrderById(_currentOrder.id);
      setState(() {
        _currentOrder = refreshedOrder;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("تم تحديث بيانات الطلب بنجاح"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("خطأ في تحديث بيانات الطلب: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleStartProcessing(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // تحديث بيانات الطلب أولاً للحصول على أحدث حالة
      final refreshedOrder = await _orderService.getOrderById(_currentOrder.id);
      setState(() {
        _currentOrder = refreshedOrder;
      });

      // التحقق من حالة الطلب بعد التحديث
      if (_currentOrder.status != "accepted_by_admin") {
        setState(() {
          _isLoading = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("لا يمكن بدء معالجة الطلب. الحالة الحالية: ${_getStatusDisplayText(_currentOrder.status)}"),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final updatedOrder = await _orderService.startProcessingOrder(_currentOrder.id);
      setState(() {
        _currentOrder = updatedOrder;
        _isLoading = false;
      });

      // 🔄 تحديث قائمة الطلبات في Provider
      if (mounted) {
        final orderProvider = context.read<RestaurantOrderProvider>();
        orderProvider.fetchOrders(silent: true);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("تم بدء معالجة الطلب بنجاح"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("خطأ في بدء معالجة الطلب: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleCompleteOrder(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // تحديث بيانات الطلب أولاً للحصول على أحدث حالة
      final refreshedOrder = await _orderService.getOrderById(_currentOrder.id);
      setState(() {
        _currentOrder = refreshedOrder;
      });

      // التحقق من حالة الطلب بعد التحديث
      if (_currentOrder.status != "processing") {
        setState(() {
          _isLoading = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("لا يمكن إكمال الطلب. الحالة الحالية: ${_getStatusDisplayText(_currentOrder.status)}"),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final updatedOrder = await _orderService.completeOrder(_currentOrder.id);
      setState(() {
        _currentOrder = updatedOrder;
        _isLoading = false;
      });

      // 🔄 تحديث قائمة الطلبات في Provider
      if (mounted) {
        final orderProvider = context.read<RestaurantOrderProvider>();
        orderProvider.fetchOrders(silent: true);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("تم إكمال الطلب بنجاح"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("خطأ في إكمال الطلب: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

}