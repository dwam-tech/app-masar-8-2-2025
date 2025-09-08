import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';
import '../models/notification_model.dart';

const String baseUrl = AppConstants.baseUrl;

class NotificationService {
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
}