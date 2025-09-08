import 'package:flutter/material.dart';

class MyOrderModel {
  final int id;
  final String orderNumber;
  final String type;
  final String status;
  final String createdAt;
  final Map<String, dynamic> details;
  final double? totalPrice;

  MyOrderModel({
    required this.id,
    required this.orderNumber,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.details,
    this.totalPrice,
  });

  factory MyOrderModel.fromJson(Map<String, dynamic> json) {
    return MyOrderModel(
      id: json['id'] ?? 0,
      orderNumber: json['order_number'] ?? '',
      type: json['order_type'] ?? json['type'] ?? '', // استخدام order_type أولاً ثم type كبديل
      status: json['status'] ?? '',
      createdAt: json['date'] ?? json['created_at'] ?? '', // استخدام date أولاً ثم created_at كبديل
      details: json['details'] ?? {},
      totalPrice: (json['total_price'] ?? 0).toDouble(),
    );
  }

  // Helper getters
  String get statusText {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'قيد الانتظار';
      case 'approved':
        return 'مقبول';
      case 'rejected':
        return 'مرفوض';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }

  String get orderTypeText {
    switch (type.toLowerCase()) {
      case 'security_permit':
        return 'تصريح أمني';
      case 'restaurant_order':
        return 'طلب مطعم';
      case 'property_appointment':
        return 'موعد عقار';
      case 'car_rental':
        return 'تأجير سيارة';
      case 'delivery_request':
        return 'طلب توصيل';
      default:
        return type;
    }
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData get orderTypeIcon {
    switch (type.toLowerCase()) {
      case 'security_permit':
        return Icons.security;
      case 'restaurant_order':
        return Icons.restaurant;
      case 'property_appointment':
        return Icons.home;
      case 'car_rental':
        return Icons.car_rental;
      case 'delivery_request':
        return Icons.delivery_dining;
      default:
        return Icons.receipt;
    }
  }
}

class MyOrdersResponse {
  final bool status;
  final String message;
  final List<MyOrderModel> orders;

  MyOrdersResponse({
    required this.status,
    required this.message,
    required this.orders,
  });

  factory MyOrdersResponse.fromJson(Map<String, dynamic> json) {
    // إذا كانت البيانات في json['data'] (قائمة)
    if (json['data'] is List) {
      return MyOrdersResponse(
        status: json['status'] ?? false,
        message: json['message'] ?? '',
        orders: (json['data'] as List<dynamic>)
                .map((orderJson) => MyOrderModel.fromJson(orderJson))
                .toList(),
      );
    }
    // إذا كانت البيانات مباشرة في json (قائمة)
    else if (json is List) {
      return MyOrdersResponse(
        status: true,
        message: 'success',
        orders: (json as List<dynamic>)
                .map((orderJson) => MyOrderModel.fromJson(orderJson))
                .toList(),
      );
    }
    // إذا لم توجد بيانات
    else {
      return MyOrdersResponse(
        status: json['status'] ?? false,
        message: json['message'] ?? 'لا توجد بيانات',
        orders: [],
      );
    }
  }
}