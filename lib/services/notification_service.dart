import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';
import '../models/notification_model.dart';

const String baseUrl = AppConstants.baseUrl;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();
  // الحصول على التوكن من SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // إنشاء headers مع التوكن
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  // جلب قائمة الإشعارات
  Future<NotificationsResponse> getNotifications() async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/notifications'),
        headers: headers,
      );

      debugPrint('Notifications API Response: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return NotificationsResponse.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'فشل في جلب الإشعارات');
      }
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      throw Exception('خطأ في الاتصال بالخادم: $e');
    }
  }

  // تمييز إشعار كمقروء
  Future<NotificationActionResponse> markAsRead(int notificationId) async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.put(
        Uri.parse('$baseUrl/api/notifications/$notificationId/read'),
        headers: headers,
      );

      debugPrint('Mark as Read API Response: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return NotificationActionResponse.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'فشل في تحديث الإشعار');
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      throw Exception('خطأ في تحديث الإشعار: $e');
    }
  }

  // حذف إشعار
  Future<NotificationActionResponse> deleteNotification(int notificationId) async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.delete(
        Uri.parse('$baseUrl/api/notifications/$notificationId'),
        headers: headers,
      );

      debugPrint('Delete Notification API Response: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return NotificationActionResponse.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'فشل في حذف الإشعار');
      }
    } catch (e) {
      debugPrint('Error deleting notification: $e');
      throw Exception('خطأ في حذف الإشعار: $e');
    }
  }

  // دالة مساعدة لتنسيق الوقت
  String formatNotificationTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays == 1) {
      return 'الأمس';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  // دالة للتحقق من وجود التوكن
  Future<bool> hasValidToken() async {
    final token = await _getToken();
    return token != null && token.isNotEmpty;
  }

  /// حوار تأكيد قبول العرض
  static Future<bool> showAcceptOfferConfirmation({
    required BuildContext context,
    required String driverName,
    required String price,
    required String estimatedTime,
  }) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'تأكيد قبول العرض',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'هل تريد قبول عرض السائق "$driverName"?\n\nالسعر: $price ريال\nالوقت المقدر: $estimatedTime دقيقة',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('قبول العرض'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  /// حوار تأكيد إلغاء الطلب
  static Future<bool> showCancelRequestConfirmation({
    required BuildContext context,
    String? customMessage,
  }) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'تأكيد إلغاء الطلب',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            customMessage ?? 'هل أنت متأكد من إلغاء طلب التوصيل?\nسيتم إشعار جميع السائقين بالإلغاء.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('العودة'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('إلغاء الطلب'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  /// حوار معلومات العرض
  static Future<void> showOfferDetailsDialog({
    required BuildContext context,
    required String driverName,
    required String driverPhone,
    required String price,
    required String estimatedTime,
    required double rating,
    String? notes,
    String? vehicleInfo,
  }) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'تفاصيل العرض',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('اسم السائق:', driverName),
                _buildDetailRow('رقم الهاتف:', driverPhone),
                _buildDetailRow('السعر:', '$price ريال'),
                _buildDetailRow('الوقت المقدر:', '$estimatedTime دقيقة'),
                Row(
                  children: [
                    const Text('التقييم: ', style: TextStyle(fontWeight: FontWeight.w600)),
                    ...List.generate(5, (index) {
                      return Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 20,
                      );
                    }),
                    Text(' ($rating)', style: const TextStyle(fontSize: 14)),
                  ],
                ),
                if (vehicleInfo != null) ...[
                  const SizedBox(height: 8),
                  _buildDetailRow('معلومات السيارة:', vehicleInfo),
                ],
                if (notes != null && notes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildDetailRow('ملاحظات:', notes),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }

  static Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  /// إشعار بوصول عرض جديد
  static void showNewOfferNotification(String driverName, String price) {
    HapticFeedback.heavyImpact();
    debugPrint('عرض جديد من $driverName بسعر $price ريال');
  }

  /// إشعار بتغيير حالة الطلب
  static void showRequestStatusUpdate(String status) {
    HapticFeedback.mediumImpact();
    debugPrint('تم تحديث حالة الطلب إلى: $status');
  }

  /// إظهار رسالة خطأ
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// إظهار رسالة نجاح
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// إظهار رسالة معلومات
  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// إظهار حوار تحميل
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Text(message ?? 'جاري التحميل...'),
            ],
          ),
        );
      },
    );
  }

  /// إخفاء حوار التحميل
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }
}