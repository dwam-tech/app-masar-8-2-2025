class PublicRestaurant {
  final int id;
  final String name;
  final String email;
  final String? profileImage;
  final String phone;
  final String governorate;
  final bool isApproved;
  final bool theBest;
  final DateTime createdAt;
  final DateTime updatedAt;
  final PublicRestaurantDetail? restaurantDetail;

  PublicRestaurant({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    required this.phone,
    required this.governorate,
    required this.isApproved,
    required this.theBest,
    required this.createdAt,
    required this.updatedAt,
    this.restaurantDetail,
  });

  factory PublicRestaurant.fromJson(Map<String, dynamic> json) {
    return PublicRestaurant(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profileImage: json['profile_image'],
      phone: json['phone'] ?? '',
      governorate: json['governorate'] ?? '',
      isApproved: json['is_approved'] == 1,
      theBest: json['the_best'] == 1,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      restaurantDetail: json['restaurant_detail'] != null 
          ? PublicRestaurantDetail.fromJson(json['restaurant_detail'])
          : null,
    );
  }
}

class PublicRestaurantDetail {
  final int id;
  final int userId;
  final String? profileImage;
  final String restaurantName;
  final String? logoImage;
  final List<String> cuisineTypes;
  final List<RestaurantBranch> branches;
  final bool deliveryAvailable;
  final String deliveryCostPerKm;
  final bool tableReservationAvailable;
  final int maxPeoplePerReservation;
  final String? reservationNotes;
  final bool depositRequired;
  final String? depositAmount;
  final List<WorkingHour> workingHours;
  final bool theBest;
  final bool isAvailableForOrders;
  final DateTime createdAt;
  final DateTime updatedAt;

  PublicRestaurantDetail({
    required this.id,
    required this.userId,
    this.profileImage,
    required this.restaurantName,
    this.logoImage,
    required this.cuisineTypes,
    required this.branches,
    required this.deliveryAvailable,
    required this.deliveryCostPerKm,
    required this.tableReservationAvailable,
    required this.maxPeoplePerReservation,
    this.reservationNotes,
    required this.depositRequired,
    this.depositAmount,
    required this.workingHours,
    required this.theBest,
    required this.isAvailableForOrders,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PublicRestaurantDetail.fromJson(Map<String, dynamic> json) {
    return PublicRestaurantDetail(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      profileImage: json['profile_image'],
      restaurantName: json['restaurant_name'] ?? '',
      logoImage: json['logo_image'],
      cuisineTypes: List<String>.from(json['cuisine_types'] ?? []),
      branches: (json['branches'] as List? ?? [])
          .map((branch) => RestaurantBranch.fromJson(branch))
          .toList(),
      deliveryAvailable: json['delivery_available'] == 1 || json['delivery_available'] == true,
      deliveryCostPerKm: json['delivery_cost_per_km']?.toString() ?? '0',
      tableReservationAvailable: json['table_reservation_available'] == 1 || json['table_reservation_available'] == true,
      maxPeoplePerReservation: json['max_people_per_reservation'] ?? 0,
      reservationNotes: json['reservation_notes'],
      depositRequired: json['deposit_required'] == 1 || json['deposit_required'] == true,
      depositAmount: json['deposit_amount']?.toString(),
      workingHours: (json['working_hours'] as List? ?? [])
          .map((hour) => WorkingHour.fromJson(hour))
          .toList(),
      theBest: json['the_best'] == 1 || json['the_best'] == true,
      isAvailableForOrders: json['is_available_for_orders'] == 1 || json['is_available_for_orders'] == true,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class RestaurantBranch {
  final String name;
  final String address;
  final String? phone;
  final double? latitude;
  final double? longitude;

  RestaurantBranch({
    required this.name,
    required this.address,
    this.phone,
    this.latitude,
    this.longitude,
  });

  factory RestaurantBranch.fromJson(Map<String, dynamic> json) {
    return RestaurantBranch(
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }
}

class WorkingHour {
  final String day;
  final String from;
  final String to;
  final bool isOpen;

  WorkingHour({
    required this.day,
    required this.from,
    required this.to,
    this.isOpen = true,
  });

  factory WorkingHour.fromJson(Map<String, dynamic> json) {
    return WorkingHour(
      day: json['day'] ?? '',
      from: json['from'] ?? '',
      to: json['to'] ?? '',
      isOpen: json['is_open'] ?? true,
    );
  }
}