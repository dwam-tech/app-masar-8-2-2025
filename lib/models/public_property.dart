import 'package:flutter/foundation.dart';

class PublicProperty {
  final int id;
  final String address;
  final String type;
  final String price;
  final String description;
  final String imageUrl;
  final int bedrooms;
  final int bathrooms;
  final String view;
  final String paymentMethod;
  final String area;
  final bool isReady;
  final bool theBest;
  final String createdAt;
  final PropertyProvider? provider;

  PublicProperty({
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
    required this.theBest,
    required this.createdAt,
    this.provider,
  });

  factory PublicProperty.fromJson(Map<String, dynamic> json) {
    debugPrint('🔍 تحليل عقار عام: ${json['id']} - ${json['address']} - ${json['type']}');
    debugPrint('🖼️ رابط الصورة: ${json['image_url']}');
    
    return PublicProperty(
      id: json['id'] ?? 0,
      address: json['address'] ?? '',
      type: json['type'] ?? '',
      price: json['price']?.toString() ?? '0',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? json['image'] ?? '',
      bedrooms: json['bedrooms'] ?? 0,
      bathrooms: json['bathrooms'] ?? 0,
      view: json['view'] ?? '',
      paymentMethod: json['payment_method'] ?? '',
      area: json['area'] ?? '',
      isReady: json['is_ready'] == true || json['is_ready'] == 1,
      theBest: json['the_best'] == true || json['the_best'] == 1,
      createdAt: json['created_at'] ?? '',
      provider: json['provider'] != null 
          ? PropertyProvider.fromJson(json['provider']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address': address,
      'type': type,
      'price': price,
      'description': description,
      'image_url': imageUrl,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'view': view,
      'payment_method': paymentMethod,
      'area': area,
      'is_ready': isReady,
      'the_best': theBest,
      'created_at': createdAt,
      'provider': provider?.toJson(),
    };
  }
}

class PropertyProvider {
  final int id;
  final String name;
  final String phone;
  final String? email;
  final String? profileImage;
  final String? userType;

  PropertyProvider({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.profileImage,
    this.userType,
  });

  factory PropertyProvider.fromJson(Map<String, dynamic> json) {
    return PropertyProvider(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      profileImage: json['profile_image'],
      userType: json['user_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'profile_image': profileImage,
      'user_type': userType,
    };
  }
}