import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/my_orders_model.dart';

class OrderCardWidget extends StatelessWidget {
  final MyOrderModel order;
  final int index;
  final AnimationController animationController;
  final VoidCallback onTap;

  const OrderCardWidget({
    Key? key,
    required this.order,
    required this.index,
    required this.animationController,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  onTap: onTap,
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

  // Helper method to get order type colors
  Map<String, Color> _getOrderTypeColors(String orderType) {
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

  // Helper method to get order type icon
  IconData _getOrderTypeIcon(String orderType) {
    switch (orderType) {
      case 'restaurant_order':
        return Icons.restaurant_rounded;
      case 'property_appointment':
        return Icons.home_work_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  // Helper method to get order type display name
  String _getOrderTypeDisplayName(String orderType) {
    switch (orderType) {
      case 'restaurant_order':
        return 'طلب مطعم';
      case 'property_appointment':
        return 'موعد معاينة';
      default:
        return 'طلب عام';
    }
  }

  // Helper method to compute a friendly order card title
  String _getOrderCardTitle(MyOrderModel order) {
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

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy', 'ar').format(date);
    } catch (e) {
      return dateString;
    }
  }
}