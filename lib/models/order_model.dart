class OrderModel {
  final int id; // تغيير من String إلى int للـ ID الرقمي الفعلي
  final String orderNumber; // إضافة خاصية منفصلة لرقم الطلب
  final String customerName;
  final String customerImage;
  final DateTime orderTime;
  final double totalAmount;
  final String status;
  final List<OrderItem> items;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.customerImage,
    required this.orderTime,
    required this.totalAmount,
    required this.status,
    required this.items,
  });

  // دالة لتحويل الـ JSON إلى كائن OrderModel
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? 0, // استخدام الـ ID الرقمي الفعلي
      orderNumber: json['order_number'] ?? 'N/A', // رقم الطلب المقروء
      customerName: json['user']?['name'] ?? 'زبون',
      customerImage: json['user']?['profile_image'] ?? "assets/images/user_avatar.jpg",
      orderTime: DateTime.parse(json['created_at']),
      totalAmount: double.tryParse(json['total_price'].toString()) ?? 0.0,
      status: json['status'] ?? 'pending', // الاحتفاظ بالحالة الإنجليزية للمعالجة الداخلية
      items: (json['items'] as List<dynamic>?)
              ?.map((itemJson) => OrderItem.fromJson(itemJson))
              .toList() ?? [],
    );
  }
}

class OrderItem {
  final String name;
  final String image;
  final double price;
  final int quantity;

  OrderItem({
    required this.name,
    required this.image,
    required this.price,
    required this.quantity,
  });

  // دالة لتحويل الـ JSON إلى كائن OrderItem
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      name: json['title'] ?? '',
      image: json['image'] ?? "assets/images/pizza.jpg", // صورة افتراضية
      price: double.tryParse(json['unit_price'].toString()) ?? 0.0,
      quantity: json['quantity'] ?? 0,
    );
  }
}