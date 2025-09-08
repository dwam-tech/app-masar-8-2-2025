import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/MenuItem.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];
  int? _restaurantId;

  List<CartItem> get items => List.unmodifiable(_items);
  int? get restaurantId => _restaurantId;

  int get totalItems {
    return _items.fold(0, (total, item) => total + item.quantity);
  }

  double get totalPrice {
    return _items.fold(0.0, (total, item) => total + item.totalPrice);
  }

  bool get isEmpty => _items.isEmpty;

  void addItem(MenuItem menuItem, int restaurantId) {
    print('🛒 [CartProvider] إضافة عنصر: ${menuItem.name} للمطعم: $restaurantId');
    
    // إذا كان المطعم مختلف، امسح السلة أولاً
    if (_restaurantId != null && _restaurantId != restaurantId) {
      print('🛒 [CartProvider] تغيير المطعم من $_restaurantId إلى $restaurantId - مسح السلة');
      clearCart();
    }
    
    _restaurantId = restaurantId;
    
    // البحث عن العنصر في السلة
    final existingIndex = _items.indexWhere((item) => item.menuItemId == menuItem.id);
    
    if (existingIndex >= 0) {
      // زيادة الكمية إذا كان العنصر موجود
      _items[existingIndex].quantity++;
      print('🛒 [CartProvider] زيادة كمية ${menuItem.name} إلى ${_items[existingIndex].quantity}');
    } else {
      // إضافة عنصر جديد
      _items.add(CartItem(
        menuItemId: menuItem.id,
        name: menuItem.name,
        price: menuItem.price,
        imageUrl: menuItem.imageUrl,
        quantity: 1,
      ));
      print('🛒 [CartProvider] إضافة عنصر جديد: ${menuItem.name}');
    }
    
    print('🛒 [CartProvider] إجمالي العناصر: $totalItems، إجمالي السعر: $totalPrice');
    notifyListeners();
  }

  void removeItem(int menuItemId) {
    print('🛒 [CartProvider] إزالة/تقليل عنصر: $menuItemId');
    
    final existingIndex = _items.indexWhere((item) => item.menuItemId == menuItemId);
    
    if (existingIndex >= 0) {
      if (_items[existingIndex].quantity > 1) {
        // تقليل الكمية
        _items[existingIndex].quantity--;
        print('🛒 [CartProvider] تقليل كمية ${_items[existingIndex].name} إلى ${_items[existingIndex].quantity}');
      } else {
        // إزالة العنصر نهائياً
        final removedItem = _items.removeAt(existingIndex);
        print('🛒 [CartProvider] إزالة ${removedItem.name} نهائياً');
        
        // إذا أصبحت السلة فارغة، امسح معرف المطعم
        if (_items.isEmpty) {
          _restaurantId = null;
          print('🛒 [CartProvider] السلة فارغة - مسح معرف المطعم');
        }
      }
      
      print('🛒 [CartProvider] إجمالي العناصر: $totalItems، إجمالي السعر: $totalPrice');
      notifyListeners();
    }
  }

  void updateItemQuantity(int menuItemId, int newQuantity) {
    print('🛒 [CartProvider] تحديث كمية العنصر $menuItemId إلى $newQuantity');
    
    if (newQuantity <= 0) {
      removeItem(menuItemId);
      return;
    }
    
    final existingIndex = _items.indexWhere((item) => item.menuItemId == menuItemId);
    
    if (existingIndex >= 0) {
      _items[existingIndex].quantity = newQuantity;
      print('🛒 [CartProvider] تم تحديث كمية ${_items[existingIndex].name} إلى $newQuantity');
      print('🛒 [CartProvider] إجمالي العناصر: $totalItems، إجمالي السعر: $totalPrice');
      notifyListeners();
    }
  }

  int getItemQuantity(int menuItemId) {
    final item = _items.firstWhere(
      (item) => item.menuItemId == menuItemId,
      orElse: () => CartItem(menuItemId: -1, name: '', price: 0, quantity: 0),
    );
    return item.menuItemId == -1 ? 0 : item.quantity;
  }

  void clearCart() {
    print('🛒 [CartProvider] مسح السلة بالكامل');
    _items.clear();
    _restaurantId = null;
    notifyListeners();
  }

  Map<String, dynamic> toOrderJson({
    required String deliveryAddress,
    String? notes,
  }) {
    if (_restaurantId == null || _items.isEmpty) {
      throw Exception('السلة فارغة أو لا يوجد مطعم محدد');
    }

    return {
      'restaurant_id': _restaurantId,
      'items': _items.map((item) => item.toJson()).toList(),
      'delivery_address': deliveryAddress,
      'notes': notes ?? '',
    };
  }
}