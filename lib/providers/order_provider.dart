import 'package:flutter/material.dart';
import 'package:saba2v2/models/order_model.dart';
import 'package:saba2v2/services/order_service.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _orderService = OrderService();

  List<OrderModel> _allOrders = [];
  bool _isLoading = false;
  String? _error;

  List<OrderModel> get allOrders => _allOrders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // قوائم مفلترة لتسهيل الوصول إليها من الواجهة
  List<OrderModel> get pendingOrders => _allOrders.where((order) => order.status == 'قيد الانتظار').toList();
  List<OrderModel> get processingOrders => _allOrders.where((order) => order.status == 'قيد التنفيذ').toList();
  List<OrderModel> get completedOrders => _allOrders.where((order) => order.status == 'منتهية').toList();

  Future<void> fetchOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _allOrders = await _orderService.getOrders();
    } catch (e) {
      _error = e.toString().replaceFirst("Exception: ", "");
      _allOrders = [];
    }
    _isLoading = false;
    notifyListeners();
  }
}