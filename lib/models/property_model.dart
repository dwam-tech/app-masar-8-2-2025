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
  // في ملف: lib/models/property_model.dart

// استبدل هذه الدالة بالكامل
factory Property.fromJson(Map<String, dynamic> json) {
  // دالة مساعدة لتحويل آمن إلى int
  int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value.split('.').first) ?? 0;
    return 0;
  }

  // دالة مساعدة لتحويل آمن إلى bool
  bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }

  return Property(
    // نقوم بالتحويل الآمن لكل حقل رقمي
    id: _parseInt(json['id']),
    price: _parseInt(json['price']),
    bedrooms: _parseInt(json['bedrooms']),
    bathrooms: _parseInt(json['bathrooms']),
    
    // نقوم بالتحويل الآمن للحقل المنطقي
    isReady: _parseBool(json['is_ready']),

    // الحقول النصية تبقى كما هي (مع التحقق من null)
    address: json['address'] ?? '',
    type: json['type'] ?? '',
    description: json['description'] ?? '',
    imageUrl: json['image_url'] ?? '',
    view: json['view'] ?? '',
    paymentMethod: json['payment_method'] ?? '',
    area: json['area'] ?? '',
    
    // هذه الحقول قد لا تأتي مع كل استدعاء، لذلك نعطيها قيمًا افتراضية
    // submittedBy: json['submitted_by'] ?? 'N/A',
    // submittedPrice: json['submitted_price']?.toString() ?? '0',
  
  
  );
}


Map<String, dynamic> toJson() {
    return {
      'address': address,
      'type': type,
      'price': price,
      'description': description,
      'image_url': imageUrl, // قد تحتاج لتعديل الصورة بشكل منفصل
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'view': view,
      'payment_method': paymentMethod,
      'area': area,
      'is_ready': isReady,
    };
  }

}