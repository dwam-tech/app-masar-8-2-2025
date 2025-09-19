import 'driver_model.dart';

class DeliveryOffer {
  final int id;
  final int deliveryRequestId;
  final int driverId;
  final double offeredPrice;
  final int estimatedArrivalTime; // بالدقائق
  final String status;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Driver? driver;

  DeliveryOffer({
    required this.id,
    required this.deliveryRequestId,
    required this.driverId,
    required this.offeredPrice,
    required this.estimatedArrivalTime,
    required this.status,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.driver,
  });

  factory DeliveryOffer.fromJson(Map<String, dynamic> json) {
    return DeliveryOffer(
      id: json['id'],
      deliveryRequestId: json['delivery_request_id'],
      driverId: json['driver_id'],
      offeredPrice: (json['offered_price'] ?? 0.0).toDouble(),
      estimatedArrivalTime: json['estimated_arrival_time'] ?? 0,
      status: json['status'] ?? 'pending',
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      driver: json['driver'] != null ? Driver.fromJson(json['driver']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'delivery_request_id': deliveryRequestId,
      'driver_id': driverId,
      'offered_price': offeredPrice,
      'estimated_arrival_time': estimatedArrivalTime,
      'status': status,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'driver': driver?.toJson(),
    };
  }

  // Helper methods
  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';
  bool get isCancelled => status == 'cancelled';

  String get formattedPrice => '${offeredPrice.toStringAsFixed(2)} ريال';
  
  String get estimatedArrivalText {
    if (estimatedArrivalTime < 60) {
      return '$estimatedArrivalTime دقيقة';
    } else {
      final hours = estimatedArrivalTime ~/ 60;
      final minutes = estimatedArrivalTime % 60;
      if (minutes == 0) {
        return '$hours ساعة';
      } else {
        return '$hours ساعة و $minutes دقيقة';
      }
    }
  }

  String get statusText {
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
        return status;
    }
  }
}

class DeliveryOffersResponse {
  final bool status;
  final List<DeliveryOffer> offers;
  final int count;
  final String? message;

  DeliveryOffersResponse({
    required this.status,
    required this.offers,
    required this.count,
    this.message,
  });

  factory DeliveryOffersResponse.fromJson(Map<String, dynamic> json) {
    return DeliveryOffersResponse(
      status: json['status'] ?? false,
      offers: json['offers'] != null
          ? (json['offers'] as List).map((offer) => DeliveryOffer.fromJson(offer)).toList()
          : [],
      count: json['count'] ?? 0,
      message: json['message'],
    );
  }
}