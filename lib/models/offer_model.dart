class OfferModel {
  final int id;
  final int deliveryRequestId;
  final int driverId;
  final String driverName;
  final String driverImage;
  final double driverRating;
  final String carModel;
  final String carColor;
  final String plateNumber;
  final double offeredPrice;
  final double originalPrice;
  final int estimatedDuration; // بالدقائق
  final String status; // pending, accepted, rejected, cancelled
  final DateTime createdAt;
  final String? notes;
  final String? driverPhone;
  final bool isCounterOffer; // هل هو عرض مضاد من السائق

  OfferModel({
    required this.id,
    required this.deliveryRequestId,
    required this.driverId,
    required this.driverName,
    required this.driverImage,
    required this.driverRating,
    required this.carModel,
    required this.carColor,
    required this.plateNumber,
    required this.offeredPrice,
    required this.originalPrice,
    required this.estimatedDuration,
    required this.status,
    required this.createdAt,
    this.notes,
    this.driverPhone,
    this.isCounterOffer = false,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
      id: json['id'] ?? 0,
      deliveryRequestId: json['delivery_request_id'] ?? 0,
      driverId: json['driver_id'] ?? 0,
      driverName: json['driver']?['name'] ?? 'سائق',
      driverImage: json['driver']?['profile_image'] ?? 'assets/images/driver_avatar.jpg',
      driverRating: double.tryParse(json['driver']?['rating']?.toString() ?? '0') ?? 0.0,
      carModel: json['driver']?['car_model'] ?? 'غير محدد',
      carColor: json['driver']?['car_color'] ?? 'غير محدد',
      plateNumber: json['driver']?['plate_number'] ?? 'غير محدد',
      offeredPrice: double.tryParse(json['offered_price']?.toString() ?? '0') ?? 0.0,
      originalPrice: double.tryParse(json['original_price']?.toString() ?? '0') ?? 0.0,
      estimatedDuration: json['estimated_duration'] ?? 0,
      status: json['status'] ?? 'pending',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      notes: json['notes'],
      driverPhone: json['driver']?['phone'],
      isCounterOffer: json['is_counter_offer'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'delivery_request_id': deliveryRequestId,
      'driver_id': driverId,
      'offered_price': offeredPrice,
      'original_price': originalPrice,
      'estimated_duration': estimatedDuration,
      'status': status,
      'notes': notes,
      'is_counter_offer': isCounterOffer,
    };
  }

  // دالة لحساب الفرق في السعر
  double get priceDifference => offeredPrice - originalPrice;

  // دالة لمعرفة إذا كان العرض أفضل من السعر الأصلي
  bool get isBetterPrice => offeredPrice <= originalPrice;

  // دالة لتحويل المدة إلى نص مقروء
  String get formattedDuration {
    if (estimatedDuration < 60) {
      return '$estimatedDuration دقيقة';
    } else {
      final hours = estimatedDuration ~/ 60;
      final minutes = estimatedDuration % 60;
      if (minutes == 0) {
        return '$hours ساعة';
      } else {
        return '$hours ساعة و $minutes دقيقة';
      }
    }
  }

  // دالة لتحويل الحالة إلى نص عربي
  String get statusInArabic {
    switch (status) {
      case 'pending':
        return 'في الانتظار';
      case 'accepted':
        return 'مقبول';
      case 'rejected':
        return 'مرفوض';
      case 'cancelled':
        return 'ملغي';
      default:
        return 'غير محدد';
    }
  }

  // خصائص إضافية للتوافق مع الكود الموجود
  double get price => offeredPrice;
  int? get estimatedTime => estimatedDuration;
}