// lib/models/property_model.dart

class Property {
  final int id;
  final String address;
  final String type;
  final int price;
  final String description;
  final String imageUrl;
  final int bedrooms;
  final int bathrooms;
  final String view;
  final String paymentMethod;
  final String area;
  final bool isReady;

  Property({
    required this.id,
    required this.address,
    required this.type,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.bedrooms,
    required this.bathrooms,
    required this.view,
    required this.paymentMethod,
    required this.area,
    required this.isReady,
  });

  // دالة لتحويل JSON القادم من الـ API إلى كائن Property
  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'],
      address: json['address'],
      type: json['type'],
      price: json['price'],
      description: json['description'],
      imageUrl: json['image_url'],
      bedrooms: json['bedrooms'],
      bathrooms: json['bathrooms'],
      view: json['view'] ?? '', // التعامل مع القيم التي قد تكون null
      paymentMethod: json['payment_method'],
      area: json['area'],
      isReady: json['is_ready'],
    );
  }
}