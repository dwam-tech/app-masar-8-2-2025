class Driver {
  final int id;
  final String name;
  final String? profileImage;
  final double rating;
  final int ratingCount;
  final String phone;
  final CarInfo? carInfo;
  final DriverDetails? driverDetails;
  final Location? location;

  Driver({
    required this.id,
    required this.name,
    this.profileImage,
    required this.rating,
    required this.ratingCount,
    required this.phone,
    this.carInfo,
    this.driverDetails,
    this.location,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'],
      name: json['name'] ?? '',
      profileImage: json['profile_image'],
      rating: (json['rating'] ?? 0.0).toDouble(),
      ratingCount: json['rating_count'] ?? 0,
      phone: json['phone'] ?? '',
      carInfo: json['car_info'] != null ? CarInfo.fromJson(json['car_info']) : null,
      driverDetails: json['driver_details'] != null ? DriverDetails.fromJson(json['driver_details']) : null,
      location: json['location'] != null ? Location.fromJson(json['location']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profile_image': profileImage,
      'rating': rating,
      'rating_count': ratingCount,
      'phone': phone,
      'car_info': carInfo?.toJson(),
      'driver_details': driverDetails?.toJson(),
      'location': location?.toJson(),
    };
  }
}

class CarInfo {
  final String? carType;
  final String? carModel;
  final String? carColor;
  final String? licensePlate;

  CarInfo({
    this.carType,
    this.carModel,
    this.carColor,
    this.licensePlate,
  });

  factory CarInfo.fromJson(Map<String, dynamic> json) {
    return CarInfo(
      carType: json['car_type'],
      carModel: json['car_model'],
      carColor: json['car_color'],
      licensePlate: json['license_plate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'car_type': carType,
      'car_model': carModel,
      'car_color': carColor,
      'license_plate': licensePlate,
    };
  }

  String get displayName {
    List<String> parts = [];
    if (carType != null && carType!.isNotEmpty) parts.add(carType!);
    if (carModel != null && carModel!.isNotEmpty) parts.add(carModel!);
    if (carColor != null && carColor!.isNotEmpty) parts.add(carColor!);
    return parts.join(' ');
  }
}

class DriverDetails {
  final double? costPerKm;
  final List<String>? paymentMethods;

  DriverDetails({
    this.costPerKm,
    this.paymentMethods,
  });

  factory DriverDetails.fromJson(Map<String, dynamic> json) {
    return DriverDetails(
      costPerKm: json['cost_per_km'] != null ? (json['cost_per_km']).toDouble() : null,
      paymentMethods: json['payment_methods'] != null 
          ? List<String>.from(json['payment_methods']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cost_per_km': costPerKm,
      'payment_methods': paymentMethods,
    };
  }
}

class Location {
  final double? latitude;
  final double? longitude;
  final String? currentAddress;

  Location({
    this.latitude,
    this.longitude,
    this.currentAddress,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      currentAddress: json['current_address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'current_address': currentAddress,
    };
  }
}