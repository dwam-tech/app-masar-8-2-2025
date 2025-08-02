import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saba2v2/models/order_model.dart';
import 'package:saba2v2/providers/restaurant_order_provider.dart';
import 'package:saba2v2/screens/business/ResturantScreens/order_details_screen.dart';

class RestaurantOrdersScreen extends StatefulWidget {
  const RestaurantOrdersScreen({Key? key}) : super(key: key);

  @override
  State<RestaurantOrdersScreen> createState() => _RestaurantOrdersScreenState();
}

class _RestaurantOrdersScreenState extends State<RestaurantOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // جلب الطلبات عند تحميل الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<RestaurantOrderProvider>();
      provider.fetchOrders();
      // 🔄 بدء التحديث التلقائي
      provider.startAutoRefresh();
    });
  }

  @override
  void dispose() {
    // 🛑 إيقاف التحديث التلقائي عند مغادرة الصفحة
    context.read<RestaurantOrderProvider>().stopAutoRefresh();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'إدارة الطلبات',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(0xFF2E7D32),
          elevation: 0,
          actions: [
            // 🔄 زر التحكم في التحديث التلقائي
            Consumer<RestaurantOrderProvider>(
              builder: (context, provider, child) {
                return IconButton(
                  onPressed: () => provider.toggleAutoRefresh(),
                  icon: Icon(
                    provider.isAutoRefreshEnabled 
                        ? Icons.sync 
                        : Icons.sync_disabled,
                    color: provider.isAutoRefreshEnabled 
                        ? Colors.white 
                        : Colors.white70,
                  ),
                  tooltip: provider.isAutoRefreshEnabled 
                      ? 'إيقاف التحديث التلقائي' 
                      : 'تفعيل التحديث التلقائي',
                );
              },
            ),
            // زر التحديث اليدوي
            IconButton(
              onPressed: () {
                context.read<RestaurantOrderProvider>().fetchOrders();
              },
              icon: const Icon(Icons.refresh, color: Colors.white),
              tooltip: 'تحديث الطلبات',
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            tabs: const [
              Tab(text: 'طلبات جديدة'),
              Tab(text: 'قيد التنفيذ'),
              Tab(text: 'المنتهية'),
            ],
          ),
        ),
        body: Column(
          children: [
            // 🔄 مؤشر حالة التحديث التلقائي
            Consumer<RestaurantOrderProvider>(
              builder: (context, provider, child) {
                if (!provider.isAutoRefreshEnabled) return const SizedBox.shrink();
                
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  color: Colors.green[50],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.green[600]!),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'التحديث التلقائي مفعل (كل 30 ثانية)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            // محتوى التبويبات
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  OrderListView(status: 'accepted_by_admin'),
                  OrderListView(status: 'processing'),
                  OrderListView(status: 'completed'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderListView extends StatelessWidget {
  final String status;

  const OrderListView({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<RestaurantOrderProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
            ),
          );
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'حدث خطأ في تحميل الطلبات',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  provider.error!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.fetchOrders(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                  ),
                  child: const Text(
                    'إعادة المحاولة',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }

        final filteredOrders = provider.getOrdersByStatus(status);

        if (filteredOrders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getEmptyStateIcon(status),
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  _getEmptyStateMessage(status),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchOrders(),
          color: const Color(0xFF2E7D32),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredOrders.length,
            itemBuilder: (context, index) {
              final order = filteredOrders[index];
              return OrderCard(order: order);
            },
          ),
        );
      },
    );
  }

  IconData _getEmptyStateIcon(String status) {
    switch (status) {
      case 'accepted_by_admin':
        return Icons.assignment_outlined;
      case 'processing':
        return Icons.hourglass_empty;
      case 'completed':
        return Icons.check_circle_outline;
      default:
        return Icons.inbox_outlined;
    }
  }

  String _getEmptyStateMessage(String status) {
    switch (status) {
      case 'accepted_by_admin':
        return 'لا توجد طلبات جديدة';
      case 'processing':
        return 'لا توجد طلبات قيد التنفيذ';
      case 'completed':
        return 'لا توجد طلبات منتهية';
      default:
        return 'لا توجد طلبات';
    }
  }
}

class OrderCard extends StatelessWidget {
  final OrderModel order;

  const OrderCard({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailsScreen(order: order),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'طلب #${order.orderNumber}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusDisplayText(order.status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'العميل: ${order.customerName}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'المجموع: ${order.totalAmount.toStringAsFixed(2)} ريال',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatOrderTime(order.orderTime),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'accepted_by_admin':
        return Colors.blue;
      case 'processing':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'rejected_by_admin':
        return Colors.red;
      case 'pending':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getStatusDisplayText(String status) {
    switch (status) {
      case 'accepted_by_admin':
        return 'جديد';
      case 'processing':
        return 'قيد التنفيذ';
      case 'completed':
        return 'مكتمل';
      case 'rejected_by_admin':
        return 'مرفوض';
      case 'pending':
        return 'معلق';
      default:
        return 'غير معروف';
    }
  }

  String _formatOrderTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }
}