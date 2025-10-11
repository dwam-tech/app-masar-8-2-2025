import 'package:flutter/foundation.dart';

class FeaturedProperty {
  final int id;
  final int realEstateId;
  final int userId;
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
  final bool isFeatured;
  final String createdAt;
  final PropertyProvider provider;

  FeaturedProperty({
    required this.id,
    required this.realEstateId,
    required this.userId,
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
    required this.isFeatured,
    required this.createdAt,
    required this.provider,
  });

  factory FeaturedProperty.fromJson(Map<String, dynamic> json) {
    // إضافة تسجيل للتشخيص
    debugPrint('🔍 تحليل عقار: ${json['id']} - ${json['address']} - ${json['type']}');
    
    return FeaturedProperty(
      id: json['id'] ?? 0,
      realEstateId: json['real_estate_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      address: json['address'] ?? '',
      type: json['type'] ?? '',
      price: json['price']?.toString() ?? '0',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      bedrooms: json['bedrooms'] ?? 0,
      bathrooms: json['bathrooms'] ?? 0,
      view: json['view'] ?? '',
      paymentMethod: json['payment_method'] ?? '',
      area: json['area'] ?? '',
      isReady: json['is_ready'] ?? false,
      isFeatured: json['is_featured'] ?? false,
      createdAt: json['created_at'] ?? '',
      provider: PropertyProvider.fromJson(json['provider'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'real_estate_id': realEstateId,
      'user_id': userId,
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
      'is_featured': isFeatured,
      'created_at': createdAt,
      'provider': provider.toJson(),
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

class FeaturedPropertiesResponse {
  final bool status;
  final List<FeaturedProperty> data;
  final PaginationLinks links;
  final PaginationMeta meta;

  FeaturedPropertiesResponse({
    required this.status,
    required this.data,
    required this.links,
    required this.meta,
  });

  factory FeaturedPropertiesResponse.fromJson(Map<String, dynamic> json) {
    // يدعم كلا التنسيقين: {data, links, meta} و {properties, pagination}
    if (json.containsKey('data')) {
      return FeaturedPropertiesResponse(
        status: json['status'] ?? false,
        data: (json['data'] as List<dynamic>?)
                ?.map((item) => FeaturedProperty.fromJson(item))
                .toList() ?? [],
        links: PaginationLinks.fromJson(json['links'] ?? {}),
        meta: PaginationMeta.fromJson(json['meta'] ?? {}),
      );
    }

    final properties = (json['properties'] as List<dynamic>?)
            ?.map((item) => FeaturedProperty.fromJson(item))
            .toList() ?? [];
    final pagination = (json['pagination'] as Map<String, dynamic>? ?? {});

    return FeaturedPropertiesResponse(
      status: json['status'] ?? false,
      data: properties,
      links: PaginationLinks(),
      meta: PaginationMeta(
        currentPage: pagination['current_page'] ?? 1,
        lastPage: pagination['last_page'] ?? 1,
        perPage: pagination['per_page'] ?? properties.length,
        total: pagination['total'] ?? properties.length,
      ),
    );
  }
}

class PaginationLinks {
  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  PaginationLinks({
    this.first,
    this.last,
    this.prev,
    this.next,
  });

  factory PaginationLinks.fromJson(Map<String, dynamic> json) {
    return PaginationLinks(
      first: json['first'],
      last: json['last'],
      prev: json['prev'],
      next: json['next'],
    );
  }
}

class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 0,
      total: json['total'] ?? 0,
    );
  }
}