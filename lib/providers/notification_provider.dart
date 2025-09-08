import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

/// Provider لإدارة حالة الإشعارات في التطبيق
class NotificationProvider with ChangeNotifier {
  //============================================================================
  // 1. الخدمات والاعتماديات (Dependencies)
  //============================================================================
  final NotificationService _notificationService = NotificationService();

  //============================================================================
  // 2. متغيرات الحالة (State Variables)
  //============================================================================
  
  // قائمة الإشعارات
  List<NotificationModel> _notifications = [];
  
  // حالات التحميل والخطأ
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _errorMessage;
  
  // إحصائيات الإشعارات
  int _unreadCount = 0;

  //============================================================================
  // 3. Getters للوصول للحالة
  //============================================================================
  
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _unreadCount;
  bool get hasNotifications => _notifications.isNotEmpty;
  
  // فلترة الإشعارات
  List<NotificationModel> get unreadNotifications => 
      _notifications.where((notification) => !notification.isRead).toList();
  
  List<NotificationModel> get readNotifications => 
      _notifications.where((notification) => notification.isRead).toList();

  //============================================================================
  // 4. دوال إدارة الحالة
  //============================================================================
  
  /// تحديث حالة التحميل
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }
  
  /// تحديث حالة التحديث
  void _setRefreshing(bool refreshing) {
    if (_isRefreshing != refreshing) {
      _isRefreshing = refreshing;
      notifyListeners();
    }
  }
  
  /// تحديث رسالة الخطأ
  void _setError(String? error) {
    if (_errorMessage != error) {
      _errorMessage = error;
      notifyListeners();
    }
  }
  
  /// حساب عدد الإشعارات غير المقروءة
  void _updateUnreadCount() {
    final newCount = _notifications.where((n) => !n.isRead).length;
    if (_unreadCount != newCount) {
      _unreadCount = newCount;
      notifyListeners();
    }
  }

  //============================================================================
  // 5. دوال API الرئيسية
  //============================================================================
  
  /// جلب قائمة الإشعارات من الخادم
  Future<void> fetchNotifications({bool showLoading = true}) async {
    try {
      if (showLoading) {
        _setLoading(true);
      }
      _setError(null);
      
      // التحقق من وجود توكن صالح
      final hasToken = await _notificationService.hasValidToken();
      if (!hasToken) {
        throw Exception('يجب تسجيل الدخول أولاً');
      }
      
      final response = await _notificationService.getNotifications();
      
      if (response.status) {
        _notifications = response.notifications;
        _updateUnreadCount();
        debugPrint('تم جلب ${_notifications.length} إشعار بنجاح');
      } else {
        throw Exception('فشل في جلب الإشعارات');
      }
      
    } catch (e) {
      debugPrint('خطأ في جلب الإشعارات: $e');
      _setError(e.toString());
    } finally {
      if (showLoading) {
        _setLoading(false);
      }
    }
  }
  
  /// تحديث الإشعارات (Pull to Refresh)
  Future<void> refreshNotifications() async {
    try {
      _setRefreshing(true);
      await fetchNotifications(showLoading: false);
    } finally {
      _setRefreshing(false);
    }
  }
  
  /// تمييز إشعار كمقروء
  Future<bool> markNotificationAsRead(int notificationId) async {
    try {
      // البحث عن الإشعار في القائمة
      final notificationIndex = _notifications.indexWhere(
        (notification) => notification.id == notificationId,
      );
      
      if (notificationIndex == -1) {
        debugPrint('الإشعار غير موجود في القائمة');
        return false;
      }
      
      final notification = _notifications[notificationIndex];
      
      // إذا كان الإشعار مقروءاً بالفعل، لا نحتاج لعمل شيء
      if (notification.isRead) {
        return true;
      }
      
      // استدعاء API لتمييز الإشعار كمقروء
      final response = await _notificationService.markAsRead(notificationId);
      
      if (response.status) {
        // تحديث الإشعار في القائمة المحلية
        _notifications[notificationIndex] = notification.copyWith(isRead: true);
        _updateUnreadCount();
        debugPrint('تم تمييز الإشعار $notificationId كمقروء');
        return true;
      } else {
        throw Exception(response.message ?? 'فشل في تحديث الإشعار');
      }
      
    } catch (e) {
      debugPrint('خطأ في تمييز الإشعار كمقروء: $e');
      _setError('فشل في تحديث الإشعار: $e');
      return false;
    }
  }
  
  /// حذف إشعار
  Future<bool> deleteNotification(int notificationId) async {
    try {
      // البحث عن الإشعار في القائمة
      final notificationIndex = _notifications.indexWhere(
        (notification) => notification.id == notificationId,
      );
      
      if (notificationIndex == -1) {
        debugPrint('الإشعار غير موجود في القائمة');
        return false;
      }
      
      // استدعاء API لحذف الإشعار
      final response = await _notificationService.deleteNotification(notificationId);
      
      if (response.status) {
        // إزالة الإشعار من القائمة المحلية
        _notifications.removeAt(notificationIndex);
        _updateUnreadCount();
        debugPrint('تم حذف الإشعار $notificationId بنجاح');
        return true;
      } else {
        throw Exception(response.message ?? 'فشل في حذف الإشعار');
      }
      
    } catch (e) {
      debugPrint('خطأ في حذف الإشعار: $e');
      _setError('فشل في حذف الإشعار: $e');
      return false;
    }
  }
  
  /// تمييز جميع الإشعارات كمقروءة
  Future<void> markAllAsRead() async {
    final unreadNotifications = _notifications.where((n) => !n.isRead).toList();
    
    for (final notification in unreadNotifications) {
      await markNotificationAsRead(notification.id);
    }
  }
  
  /// حذف جميع الإشعارات المقروءة
  Future<void> deleteAllRead() async {
    final readNotifications = _notifications.where((n) => n.isRead).toList();
    
    for (final notification in readNotifications) {
      await deleteNotification(notification.id);
    }
  }

  //============================================================================
  // 6. دوال مساعدة
  //============================================================================
  
  /// الحصول على إشعار بواسطة ID
  NotificationModel? getNotificationById(int id) {
    try {
      return _notifications.firstWhere((notification) => notification.id == id);
    } catch (e) {
      return null;
    }
  }
  
  /// تنسيق وقت الإشعار
  String formatNotificationTime(DateTime dateTime) {
    return _notificationService.formatNotificationTime(dateTime);
  }
  
  /// مسح رسالة الخطأ
  void clearError() {
    _setError(null);
  }
  
  /// إعادة تعيين الحالة
  void reset() {
    _notifications.clear();
    _unreadCount = 0;
    _isLoading = false;
    _isRefreshing = false;
    _errorMessage = null;
    notifyListeners();
  }

  //============================================================================
  // 7. دوال التنظيف
  //============================================================================
  
  @override
  void dispose() {
    // تنظيف الموارد إذا لزم الأمر
    super.dispose();
  }
}