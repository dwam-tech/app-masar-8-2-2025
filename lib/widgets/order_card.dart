import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:saba2v2/models/order_model.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final Function(OrderModel) onViewDetails;

  const OrderCard({
    super.key,
    required this.order,
    required this.onViewDetails,
  });

  // الحصول على لون حالة الطلب
  Color _getStatusColor(String status) {
    switch (status) {
      case "pending":
        return Colors.grey;
      case "accepted_by_admin":
        return Colors.orange;
      case "processing":
        return Colors.blue;
      case "completed":
        return Colors.green;
      case "rejected_by_admin":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // ترجمة حالة الطلب للعرض
  String _getStatusDisplayText(String status) {
    switch (status) {
      case "pending":
        return "معلق";
      case "accepted_by_admin":
        return "معتمد من الإدارة";
      case "processing":
        return "قيد المعالجة";
      case "completed":
        return "مكتمل";
      case "rejected_by_admin":
        return "مرفوض من الإدارة";
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // معلومات الطلب - حالة الطلب والوقت
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // حالة الطلب على الشمال
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getStatusDisplayText(order.status),
                    style: TextStyle(
                      color: _getStatusColor(order.status),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // الوقت على اليمين
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('dd/MM/yyyy - hh:mm a').format(order.orderTime),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  ],
                ),
              ],
            ),
          ),

          // السعر
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "${order.totalAmount.toStringAsFixed(0)} ج.م",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.money, size: 16, color: Colors.amber),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // معلومات العميل
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    order.customerName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 16,
                  backgroundImage: AssetImage(order.customerImage),
                  onBackgroundImageError: (exception, stackTrace) {
                    // معالجة خطأ تحميل الصورة
                  },
                  child: const Icon(Icons.person, size: 16, color: Colors.grey),
                ),
              ],
            ),
          ),

          // رقم الطلب
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "#${order.orderNumber}",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  "رقم الطلب",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // زر عرض الطلب
          InkWell(
            onTap: () => onViewDetails(order),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            child: Container(
              height: 45,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "عرض الطلب",
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.orange,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}