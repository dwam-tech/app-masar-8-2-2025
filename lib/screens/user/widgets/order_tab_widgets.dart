import 'package:flutter/material.dart';
import '../../../models/my_orders_model.dart';

class OrderTabWidgets {
  static Widget buildTabBar({
    required TabController tabController,
    required List<Map<String, dynamic>> tabCategories,
    required List<MyOrderModel> orders,
  }) {
    // Count orders by type
    final allCount = orders.length;
    final restaurantCount = orders.where((o) => o.type == 'restaurant_order').length;
    final propertyCount = orders.where((o) => o.type == 'property_appointment').length;
    final otherCount = orders.where((o) => o.type != 'restaurant_order' && o.type != 'property_appointment').length;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: const LinearGradient(
            colors: [Color(0xFFFC8700), Color(0xFFFFB347)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFC8700).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        tabs: [
          _buildTab(
            icon: Icons.all_inclusive_rounded,
            label: 'الكل',
            count: allCount,
            color: const Color(0xFFFC8700),
          ),
          _buildTab(
            icon: Icons.restaurant_rounded,
            label: 'المطاعم',
            count: restaurantCount,
            color: const Color(0xFFFF6B35),
          ),
          _buildTab(
            icon: Icons.home_work_rounded,
            label: 'المعاينات',
            count: propertyCount,
            color: const Color(0xFF3B82F6),
          ),
          _buildTab(
            icon: Icons.receipt_long_rounded,
            label: 'أخرى',
            count: otherCount,
            color: const Color(0xFFFC8700),
          ),
        ],
      ),
    );
  }

  static Widget _buildTab({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Tab(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static Widget buildTabBarView({
    required TabController tabController,
    required List<Map<String, dynamic>> tabCategories,
    required List<MyOrderModel> orders,
    required List<MyOrderModel> filteredOrders,
    required AnimationController cardAnimationController,
    required String? selectedStatus,
    required DateTimeRange? selectedDateRange,
    required Function(MyOrderModel) onOrderTap,
    required VoidCallback onClearFilters,
  }) {
    // Use the provided filteredOrders
    final restaurantOrders = filteredOrders.where((o) => o.type == 'restaurant_order').toList();
    final propertyOrders = filteredOrders.where((o) => o.type == 'property_appointment').toList();
    final otherOrders = filteredOrders.where((o) => o.type != 'restaurant_order' && o.type != 'property_appointment').toList();

    return TabBarView(
      controller: tabController,
      children: [
        _buildOrdersList(
          orders: filteredOrders,
          animationController: cardAnimationController,
          onOrderTap: onOrderTap,
          selectedStatus: selectedStatus,
          selectedDateRange: selectedDateRange,
          onClearFilters: onClearFilters,
          emptyMessage: 'لا توجد طلبات',
        ),
        _buildOrdersList(
          orders: restaurantOrders,
          animationController: cardAnimationController,
          onOrderTap: onOrderTap,
          selectedStatus: selectedStatus,
          selectedDateRange: selectedDateRange,
          onClearFilters: onClearFilters,
          emptyMessage: 'لا توجد طلبات مطاعم',
        ),
        _buildOrdersList(
          orders: propertyOrders,
          animationController: cardAnimationController,
          onOrderTap: onOrderTap,
          selectedStatus: selectedStatus,
          selectedDateRange: selectedDateRange,
          onClearFilters: onClearFilters,
          emptyMessage: 'لا توجد مواعيد معاينة',
        ),
        _buildOrdersList(
          orders: otherOrders,
          animationController: cardAnimationController,
          onOrderTap: onOrderTap,
          selectedStatus: selectedStatus,
          selectedDateRange: selectedDateRange,
          onClearFilters: onClearFilters,
          emptyMessage: 'لا توجد طلبات أخرى',
        ),
      ],
    );
  }

  static Widget _buildOrdersList({
    required List<MyOrderModel> orders,
    required AnimationController animationController,
    required Function(MyOrderModel) onOrderTap,
    required String? selectedStatus,
    required DateTimeRange? selectedDateRange,
    required VoidCallback onClearFilters,
    required String emptyMessage,
  }) {
    if (orders.isEmpty) {
      return _buildEmptyState(
        message: emptyMessage,
        selectedStatus: selectedStatus,
        selectedDateRange: selectedDateRange,
        onClearFilters: onClearFilters,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 100),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return GestureDetector(
          onTap: () => onOrderTap(order),
          child: _buildOrderCard(
            order: order,
            index: index,
            animationController: animationController,
          ),
        );
      },
    );
  }

  static Widget _buildOrderCard({
    required MyOrderModel order,
    required int index,
    required AnimationController animationController,
  }) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        // Safety check for animation controller
        if (!animationController.isAnimating && animationController.value == 0.0) {
          return const SizedBox.shrink();
        }
        
        // Ensure the base value is clamped first
        final baseValue = (animationController.value - (index * 0.1)).clamp(0.0, 1.0);
        final animationValue = Curves.easeOut.transform(baseValue);
        
        // Double-check opacity is within valid range
        final opacity = animationValue.clamp(0.0, 1.0);
        
        // Get order type specific styling
        final orderTypeColors = _getOrderTypeColors(order.type);
        // Derive a friendly title for this order card
        final String orderTitle = _getOrderCardTitle(order);
        
        return Transform.translate(
          offset: Offset(0, 50 * (1 - animationValue)),
          child: Opacity(
            opacity: opacity,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Card(
                elevation: 8,
                shadowColor: orderTypeColors['shadow']!.withOpacity(0.15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        begin: AlignmentDirectional.topStart,
                        end: AlignmentDirectional.bottomEnd,
                        colors: [
                          Colors.white,
                          orderTypeColors['background']!.withOpacity(0.02),
                        ],
                      ),
                      border: Border.all(
                        color: orderTypeColors['primary']!.withOpacity(0.1),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Header section with order type indicator
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: AlignmentDirectional.topStart,
                              end: AlignmentDirectional.bottomEnd,
                              colors: [
                                orderTypeColors['primary']!.withOpacity(0.08),
                                orderTypeColors['secondary']!.withOpacity(0.03),
                              ],
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                            ),
                          ),
                          child: Row(
                            children: [
                              // Order type icon with enhanced styling
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      orderTypeColors['primary']!,
                                      orderTypeColors['secondary']!,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: orderTypeColors['shadow']!.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _getOrderTypeIcon(order.type),
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              
                              // Order type and number
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getOrderTypeDisplayName(order.type),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: orderTypeColors['primary'],
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      order.orderNumber,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF64748B),
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Status badge with enhanced styling
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [order.statusColor, order.statusColor.withOpacity(0.8)],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: order.statusColor.withOpacity(0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  order.statusText,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Content section
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              // Order title with Arabic-friendly styling
                              if (orderTitle.isNotEmpty) ...[
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.grey.withOpacity(0.1),
                                    ),
                                  ),
                                  child: Text(
                                    orderTitle,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2D3748),
                                      height: 1.4,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                              
                              // Date and Price row
                              Row(
                                children: [
                                  // Date section
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.blue.withOpacity(0.08),
                                            Colors.blue.withOpacity(0.03),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.blue.withOpacity(0.15),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Icon(
                                              Icons.access_time_rounded,
                                              size: 18,
                                              color: Colors.blue[700],
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'تاريخ الطلب',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.blue[700],
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  _formatDate(order.createdAt),
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Color(0xFF2D3748),
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  
                                  if (order.totalPrice != null) ...[
                                    const SizedBox(width: 12),
                                    // Price section
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            const Color(0xFFFC8700),
                                            const Color(0xFFFF9500),
                                            const Color(0xFFFFB347),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(18),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFFC8700).withOpacity(0.4),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.payments_rounded,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${order.totalPrice?.toStringAsFixed(0) ?? '0'} ج.م',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _buildEmptyState({
    required String message,
    required String? selectedStatus,
    required DateTimeRange? selectedDateRange,
    required VoidCallback onClearFilters,
  }) {
    final hasActiveFilters = selectedStatus != null || selectedDateRange != null;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty state icon with animation
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.8 + (0.2 * value),
                  child: Opacity(
                    opacity: value,
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFFC8700).withOpacity(0.1),
                            const Color(0xFFFFB347).withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Icon(
                        hasActiveFilters 
                            ? Icons.filter_list_off_rounded
                            : Icons.receipt_long_rounded,
                        size: 80,
                        color: const Color(0xFFFC8700).withOpacity(0.7),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            
            // Empty state text
            Text(
              hasActiveFilters 
                  ? 'لا توجد طلبات تطابق الفلاتر المحددة'
                  : message,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            Text(
              hasActiveFilters 
                  ? 'جرب تغيير الفلاتر أو مسحها لرؤية المزيد من النتائج'
                  : 'ستظهر الطلبات هنا بمجرد إنشائها',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Action button
            if (hasActiveFilters)
              ElevatedButton.icon(
                onPressed: onClearFilters,
                icon: const Icon(Icons.clear_all_rounded),
                label: const Text('مسح جميع الفلاتر'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFC8700),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 4,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  static List<MyOrderModel> _filterOrders(
    List<MyOrderModel> orders,
    String? selectedStatus,
    DateTimeRange? selectedDateRange,
  ) {
    return orders.where((order) {
      // Status filter
      if (selectedStatus != null && order.status != selectedStatus) {
        return false;
      }
      
      // Date range filter
      if (selectedDateRange != null) {
        try {
          final orderDate = DateTime.parse(order.createdAt);
          if (orderDate.isBefore(selectedDateRange.start) || 
              orderDate.isAfter(selectedDateRange.end.add(const Duration(days: 1)))) {
            return false;
          }
        } catch (e) {
          // If date parsing fails, exclude the order
          return false;
        }
      }
      
      return true;
    }).toList();
  }

  static Map<String, Color> _getOrderTypeColors(String orderType) {
    switch (orderType) {
      case 'restaurant_order':
        return {
          'primary': const Color(0xFFFF6B35),
          'secondary': const Color(0xFFFF8C42),
          'background': const Color(0xFFFF6B35),
          'shadow': const Color(0xFFFF6B35),
        };
      case 'property_appointment':
        return {
          'primary': const Color(0xFF3B82F6),
          'secondary': const Color(0xFF60A5FA),
          'background': const Color(0xFF3B82F6),
          'shadow': const Color(0xFF3B82F6),
        };
      default:
        return {
          'primary': const Color(0xFFFC8700),
          'secondary': const Color(0xFFFFB347),
          'background': const Color(0xFFFC8700),
          'shadow': const Color(0xFFFC8700),
        };
    }
  }

  static IconData _getOrderTypeIcon(String orderType) {
    switch (orderType) {
      case 'restaurant_order':
        return Icons.restaurant_rounded;
      case 'property_appointment':
        return Icons.home_work_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  static String _getOrderTypeDisplayName(String orderType) {
    switch (orderType) {
      case 'restaurant_order':
        return 'طلب مطعم';
      case 'property_appointment':
        return 'موعد معاينة';
      default:
        return 'طلب عام';
    }
  }

  static String _getOrderCardTitle(MyOrderModel order) {
    switch (order.type) {
      case 'restaurant_order':
        final rn = order.details['restaurant_name'];
        if (rn is String && rn.trim().isNotEmpty) return rn;
        final items = order.details['items'];
        if (items is List && items.isNotEmpty) {
          final first = items.first;
          if (first is Map && first['title'] is String && (first['title'] as String).trim().isNotEmpty) {
            return first['title'] as String;
          }
        }
        return 'طلب مطعم';
      case 'property_appointment':
        final addr = order.details['property_address'];
        if (addr is String && addr.trim().isNotEmpty) return addr;
        return 'موعد معاينة';
      default:
        final t = order.details['title'];
        if (t is String && t.trim().isNotEmpty) return t;
        return order.orderTypeText;
    }
  }

  static String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}