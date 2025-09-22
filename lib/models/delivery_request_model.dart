import 'offer_model.dart';

class DeliveryRequestModel {
  final int id;
  final String fromLocation;
  final String toLocation;
  final String fromLocationUrl;
  final String toLocationUrl;
  final double requestedPrice;
  final int passengers;
  final String tripType;
  final String deliveryTime;
  final String carCategory;
  final String paymentMethod;
  final String? notes;
  final String status;
  final DateTime createdAt;
  final List<OfferModel> offers;
  final DriverModel? driver;

  DeliveryRequestModel({
    required this.id,
    required this.fromLocation,
    required this.toLocation,
    required this.fromLocationUrl,
    required this.toLocationUrl,
    required this.requestedPrice,
    required this.passengers,
    required this.tripType,
    required this.deliveryTime,
    required this.carCategory,
    required this.paymentMethod,
    this.notes,
    required this.status,
    required this.createdAt,
    this.offers = const [],
    this.driver,
  });

  factory DeliveryRequestModel.fromJson(Map<String, dynamic> json) {
    return DeliveryRequestModel(
      id: json['id'] ?? 0,
      fromLocation: json['from_location'] ?? '',
      toLocation: json['to_location'] ?? '',
      fromLocationUrl: json['from_location_url'] ?? '',
      toLocationUrl: json['to_location_url'] ?? '',
      requestedPrice: double.tryParse(json['requested_price']?.toString() ?? '0') ?? 0.0,
      passengers: json['passengers'] ?? 1,
      tripType: json['trip_type'] ?? 'ذهاب فقط',
      deliveryTime: json['delivery_time'] ?? 'توصيل الآن',
      carCategory: json['car_category'] ?? 'اقتصادية',
      paymentMethod: json['payment_method'] ?? 'كاش',
      notes: json['notes'],
      status: json['status'] ?? 'pending',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      offers: (json['offers'] as List<dynamic>?)
          ?.map((offerJson) => OfferModel.fromJson(offerJson))
          .toList() ?? [],
      driver: json['driver'] != null ? DriverModel.fromJson(json['driver']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from_location': fromLocation,
      'to_location': toLocation,
      'from_location_url': fromLocationUrl,
      'to_location_url': toLocationUrl,
      'requested_price': requestedPrice,
      'passengers': passengers,
      'trip_type': tripType,
      'delivery_time': deliveryTime,
      'car_category': carCategory,
      'payment_method': paymentMethod,
      'notes': notes,
      'status': status,
    };
  }

  // دالة لتحويل الحالة إلى نص عربي
  String get statusTranslated {
    switch (status) {
      case 'pending':
        return 'في الانتظار';
      case 'accepted':
        return 'مقبول';
      case 'in_progress':
        return 'قيد التنفيذ';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغي';
      default:
        return 'غير محدد';
    }
  }
}

class DriverModel {
  final int id;
  final String name;
  final String? phone;
  final String? profileImage;
  final double? rating;
  final String? carModel;
  final String? carColor;
  final String? plateNumber;

  DriverModel({
    required this.id,
    required this.name,
    this.phone,
    this.profileImage,
    this.rating,
    this.carModel,
    this.carColor,
    this.plateNumber,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'سائق',
      phone: json['phone'],
      profileImage: json['profile_image'],
      rating: double.tryParse(json['rating']?.toString() ?? '0'),
      carModel: json['car_model'],
      carColor: json['car_color'],
      plateNumber: json['plate_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'profile_image': profileImage,
      'rating': rating,
      'car_model': carModel,
      'car_color': carColor,
      'plate_number': plateNumber,
    };
  }
}