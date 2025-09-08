import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:saba2v2/models/order_model.dart';
import 'package:saba2v2/services/order_service.dart';

class RestaurantOrderProvider with ChangeNotifier {
  final OrderService _orderService = OrderService();
  
  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _error;
  
  // 🔄 نظام التحديث التلقائي
  Timer? _refreshTimer;
  bool _isAutoRefreshEnabled = false;
  static const Duration _refreshInterval = Duration(seconds: 30); // كل 30 ثانية

  // Getters
  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAutoRefreshEnabled => _isAutoRefreshEnabled;

  // 🔄 بدء التحديث التلقائي
  void startAutoRefresh() {
    if (_isAutoRefreshEnabled) return; // تجنب التكرار
    
    _isAutoRefreshEnabled = true;
    debugPrint("RestaurantOrderProvider: Auto-refresh started (every ${_refreshInterval.inSeconds}s)");
    
    _refreshTimer = Timer.periodic(_refreshInterval, (timer) {
      if (_isAutoRefreshEnabled) {
        debugPrint("RestaurantOrderProvider: Auto-refreshing orders...");
        fetchOrders(silent: true); // تحديث صامت بدون loading indicator
      }
    });
    
    notifyListeners();
  }

  // 🛑 إيقاف التحديث التلقائي
  void stopAutoRefresh() {
    if (!_isAutoRefreshEnabled) return;
    
    _isAutoRefreshEnabled = false;
    _refreshTimer?.cancel();
    _refreshTimer = null;
    debugPrint("RestaurantOrderProvider: Auto-refresh stopped");
    
    notifyListeners();
  }

  // 🔄 تبديل حالة التحديث التلقائي
  void toggleAutoRefresh() {
    if (_isAutoRefreshEnabled) {
      stopAutoRefresh();
    } else {
      startAutoRefresh();
    }
  }

  // جلب طلبات المطعم مع إمكانية التصفية حسب الحالة
  Future<void> fetchOrders({String? status, bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      final newOrders = await _orderService.getRestaurantOrders(status: status);
      
      // 🔍 مقارنة الطلبات الجديدة مع الحالية للكشف عن التغييرات
      final hasChanges = _hasOrdersChanged(_orders, newOrders);
      
      _orders = newOrders;
      
      if (hasChanges && silent) {
        debugPrint("RestaurantOrderProvider: Orders updated! Found ${_orders.length} orders");
      } else if (!silent) {
        debugPrint("RestaurantOrderProvider: Fetched ${_orders.length} orders with status: $status");
      }
      
    } catch (e) {
      debugPrint("RestaurantOrderProvider Error: $e");
      
      if (!silent) {
        // معالجة أنواع مختلفة من الأخطاء
        if (e is SocketException || e.toString().contains('NetworkException')) {
          _error = 'تعذر الاتصال بالخادم. يرجى التحقق من اتصال الإنترنت';
        } else if (e is TimeoutException) {
          _error = 'انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى';
        } else if (e is FormatException) {
          _error = 'خطأ في تنسيق البيانات المستلمة';
        } else {
          _error = 'حدث خطأ أثناء جلب الطلبات: ${e.toString()}';
        }
      }
    } finally {
      if (!silent) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  // 🔍 فحص ما إذا كانت الطلبات قد تغيرت
  bool _hasOrdersChanged(List<OrderModel> oldOrders, List<OrderModel> newOrders) {
    if (oldOrders.length != newOrders.length) return true;
    
    for (int i = 0; i < oldOrders.length; i++) {
      if (oldOrders[i].id != newOrders[i].id || 
          oldOrders[i].status != newOrders[i].status ||
          oldOrders[i].orderTime != newOrders[i].orderTime) {
        return true;
      }
    }
    
    return false;
  }

  // بدء معالجة الطلب
  Future<bool> startProcessingOrder(int orderId) async {
    try {
      final updatedOrder = await _orderService.startProcessingOrder(orderId);
      
      // تحديث الطلب في القائمة المحلية
      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        _orders[index] = updatedOrder;
        notifyListeners();
      }
      
      // 🔄 تحديث فوري للطلبات بعد تغيير الحالة
      await fetchOrders(silent: true);
      
      debugPrint("RestaurantOrderProvider: Successfully started processing order $orderId");
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint("RestaurantOrderProvider Error (startProcessingOrder): $e");
      notifyListeners();
      return false;
    }
  }

  // إكمال الطلب
  Future<bool> completeOrder(int orderId) async {
    try {
      final updatedOrder = await _orderService.completeOrder(orderId);
      
      // تحديث الطلب في القائمة المحلية
      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        _orders[index] = updatedOrder;
        notifyListeners();
      }
      
      // 🔄 تحديث فوري للطلبات بعد تغيير الحالة
      await fetchOrders(silent: true);
      
      debugPrint("RestaurantOrderProvider: Successfully completed order $orderId");
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint("RestaurantOrderProvider Error (completeOrder): $e");
      notifyListeners();
      return false;
    }
  }

  // تصفية الطلبات حسب الحالة محلياً
  List<OrderModel> getOrdersByStatus(String status) {
    return _orders.where((order) => order.status == status).toList();
  }

  // إعادة تعيين الأخطاء
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // تحديث طلب محدد في القائمة
  void updateOrder(OrderModel updatedOrder) {
    final index = _orders.indexWhere((order) => order.id == updatedOrder.id);
    if (index != -1) {
      _orders[index] = updatedOrder;
      notifyListeners();
    }
  }

  // 🧹 تنظيف الموارد عند إغلاق الـ Provider
  @override
  void dispose() {
    stopAutoRefresh(); // إيقاف Timer قبل الإغلاق
    super.dispose();
  }
}