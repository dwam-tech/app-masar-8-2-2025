import 'package:flutter/material.dart';
import 'package:saba2v2/models/order_model.dart';

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

  // Responsive breakpoints
  static const double _tabletBreakpoint = 768.0;
  static const double _desktopBreakpoint = 1024.0;

  @override
  void initState() {
    super.initState();
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
                        "#${widget.order.id}",
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
            _buildBackButton(context, isTablet),
          ],
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
    Color statusColor;
    Color backgroundColor;

    switch (widget.order.status) {
      case "قيد الانتظار":
        statusColor = Colors.orange;
        backgroundColor = Colors.orange.withOpacity(0.1);
        break;
      case "قيد التنفيذ":
        statusColor = Colors.blue;
        backgroundColor = Colors.blue.withOpacity(0.1);
        break;
      case "منتهية":
        statusColor = Colors.green;
        backgroundColor = Colors.green.withOpacity(0.1);
        break;
      default:
        statusColor = Colors.grey;
        backgroundColor = Colors.grey.withOpacity(0.1);
    }

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
        widget.order.status,
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
                      widget.order.customerName,
                      style: TextStyle(
                        fontSize: isTablet ? 20.0 : 18.0,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F2937),
                        fontFamily: 'Cairo',
                      ),
                    ),
                    SizedBox(height: isTablet ? 6.0 : 4.0),
                    Text(
                      _formatOrderTime(widget.order.orderTime),
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
            _formatOrderTime(widget.order.orderTime),
            isTablet,
          ),
          SizedBox(height: isTablet ? 12.0 : 8.0),
          _buildInfoRow(
            "حالة الطلب",
            widget.order.status,
            isTablet,
            valueColor: _getStatusColor(widget.order.status),
          ),
          SizedBox(height: isTablet ? 12.0 : 8.0),
          _buildInfoRow(
            "عدد الأصناف",
            "${widget.order.items.length} صنف",
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
          ...widget.order.items.asMap().entries.map((entry) {
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
                    child: _buildOrderItem(item, isTablet, index == widget.order.items.length - 1),
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
          _buildSummaryRow("المجموع الفرعي", "${widget.order.totalAmount}", isTablet),
          SizedBox(height: isTablet ? 12.0 : 8.0),
          _buildSummaryRow("رسوم التوصيل", "20", isTablet),
          SizedBox(height: isTablet ? 12.0 : 8.0),
          _buildSummaryRow("الضرائب", "15", isTablet),
          SizedBox(height: isTablet ? 16.0 : 12.0),
          Divider(color: Colors.grey.shade300),
          SizedBox(height: isTablet ? 16.0 : 12.0),
          _buildSummaryRow(
            "المجموع النهائي",
            "${widget.order.totalAmount + 35}",
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
    if (widget.order.status == "منتهية") {
      return const SizedBox.shrink(); // No buttons for completed orders
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
          child: widget.order.status == "قيد الانتظار"
              ? _buildPendingButtons(context, isTablet)
              : _buildInProgressButtons(context, isTablet),
        ),
      ),
    );
  }

  Widget _buildPendingButtons(BuildContext context, bool isTablet) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            text: "رفض الطلب",
            color: Colors.red,
            backgroundColor: Colors.red.withOpacity(0.1),
            onPressed: () => _handleRejectOrder(context),
            isTablet: isTablet,
          ),
        ),
        SizedBox(width: isTablet ? 16.0 : 12.0),
        Expanded(
          child: _buildActionButton(
            text: "قبول الطلب",
            color: Colors.white,
            backgroundColor: Colors.green,
            onPressed: () => _handleAcceptOrder(context),
            isTablet: isTablet,
          ),
        ),
      ],
    );
  }

  Widget _buildInProgressButtons(BuildContext context, bool isTablet) {
    return SizedBox(
      width: double.infinity,
      child: _buildActionButton(
        text: "تسليم الطلب",
        color: Colors.white,
        backgroundColor: Colors.orange,
        onPressed: () => _handleDeliverOrder(context),
        isTablet: isTablet,
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required Color color,
    required Color backgroundColor,
    required VoidCallback onPressed,
    required bool isTablet,
  }) {
    return Container(
      height: isTablet ? 56.0 : 48.0,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: color,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? SizedBox(
          width: isTablet ? 24.0 : 20.0,
          height: isTablet ? 24.0 : 20.0,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        )
            : Text(
          text,
          style: TextStyle(
            fontSize: isTablet ? 18.0 : 16.0,
            fontWeight: FontWeight.w600,
            fontFamily: 'Cairo',
          ),
        ),
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
      case "قيد الانتظار":
        return Colors.orange;
      case "قيد التنفيذ":
        return Colors.blue;
      case "منتهية":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Future<void> _handleAcceptOrder(BuildContext context) async {
    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => _isLoading = false);
      _showSuccessDialog(context, "تم قبول الطلب بنجاح");
    }
  }

  Future<void> _handleRejectOrder(BuildContext context) async {
    final confirmed = await _showConfirmationDialog(
      context,
      "تأكيد رفض الطلب",
      "هل أنت متأكد من رفض هذا الطلب؟",
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() => _isLoading = false);
        _showSuccessDialog(context, "تم رفض الطلب");
      }
    }
  }

  Future<void> _handleDeliverOrder(BuildContext context) async {
    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => _isLoading = false);
      _showSuccessDialog(context, "تم تسليم الطلب بنجاح");
    }
  }

  Future<bool?> _showConfirmationDialog(BuildContext context, String title, String message) {
    return showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(
            title,
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
          content: Text(
            message,
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                "إلغاء",
                style: TextStyle(fontFamily: 'Cairo'),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                "تأكيد",
                style: TextStyle(color: Colors.white, fontFamily: 'Cairo'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          contentPadding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Color(0xFFFC8700), size: 48),
              const SizedBox(height: 12),
              const Text(
                "تم بنجاح",
                style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 120,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Go back to previous screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFC8700),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "موافق",
                    style: TextStyle(color: Colors.white, fontFamily: 'Cairo', fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

}