class RestaurantDetail {
  final int id;
  final int userId;
  final String? profileImage;
  final String restaurantName;
  final String? logoImage;
  final String? ownerIdFrontImage;
  final String? ownerIdBackImage;
  final String? licenseFrontImage;
  final String? licenseBackImage;
  final String? commercialRegisterFrontImage;
  final String? commercialRegisterBackImage;
  final bool vatIncluded;
  final String? vatImageFront;
  final String? vatImageBack;
  final List<String> cuisineTypes;
  final List<Map<String, String>> branches;
  final bool deliveryAvailable;
  final String deliveryCostPerKm;
  final bool tableReservationAvailable;
  final int maxPeoplePerReservation;
  final String? reservationNotes;
  final bool depositRequired;
  final String? depositAmount;
  final List<Map<String, String>> workingHours;
  final bool theBest;
  final bool isAvailableForOrders;
  final String createdAt;
  final String updatedAt;

  RestaurantDetail({
    required this.id,
    required this.userId,
    required this.profileImage,
    required this.restaurantName,
    required this.logoImage,
    required this.ownerIdFrontImage,
    required this.ownerIdBackImage,
    required this.licenseFrontImage,
    required this.licenseBackImage,
    required this.commercialRegisterFrontImage,
    required this.commercialRegisterBackImage,
    required this.vatIncluded,
    required this.vatImageFront,
    required this.vatImageBack,
    required this.cuisineTypes,
    required this.branches,
    required this.deliveryAvailable,
    required this.deliveryCostPerKm,
    required this.tableReservationAvailable,
    required this.maxPeoplePerReservation,
    required this.reservationNotes,
    required this.depositRequired,
    required this.depositAmount,
    required this.workingHours,
    required this.theBest,
    required this.isAvailableForOrders,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RestaurantDetail.fromJson(Map<String, dynamic> json) {
    return RestaurantDetail(
      id: json['id'],
      userId: json['user_id'],
      profileImage: json['profile_image'],
      restaurantName: json['restaurant_name'],
      logoImage: json['logo_image'],
      ownerIdFrontImage: json['owner_id_front_image'],
      ownerIdBackImage: json['owner_id_back_image'],
      licenseFrontImage: json['license_front_image'],
      licenseBackImage: json['license_back_image'],
      commercialRegisterFrontImage: json['commercial_register_front_image'],
      commercialRegisterBackImage: json['commercial_register_back_image'],
      vatIncluded: json['vat_included'] == 1 || json['vat_included'] == true,
      vatImageFront: json['vat_image_front'],
      vatImageBack: json['vat_image_back'],
      cuisineTypes: List<String>.from(json['cuisine_types'] ?? []),
      branches: List<Map<String, String>>.from((json['branches'] ?? []).map((b) => {
        'name': b['name'],
        'address': b['address'],
      })),
      deliveryAvailable: json['delivery_available'] == 1 || json['delivery_available'] == true,
      deliveryCostPerKm: json['delivery_cost_per_km']?.toString() ?? '',
      tableReservationAvailable: json['table_reservation_available'] == 1 || json['table_reservation_available'] == true,
      maxPeoplePerReservation: json['max_people_per_reservation'] ?? 0,
      reservationNotes: json['reservation_notes'],
      depositRequired: json['deposit_required'] == 1 || json['deposit_required'] == true,
      depositAmount: json['deposit_amount']?.toString(),
      workingHours: List<Map<String, String>>.from((json['working_hours'] ?? []).map((w) => {
        'day': w['day'],
        'from': w['from'],
        'to': w['to'],
      })),
      theBest: json['the_best'] == 1 || json['the_best'] == true,
      isAvailableForOrders: json['is_available_for_orders'] == 1 || json['is_available_for_orders'] == true,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'profile_image': profileImage,
      'restaurant_name': restaurantName,
      'logo_image': logoImage,
      'owner_id_front_image': ownerIdFrontImage,
      'owner_id_back_image': ownerIdBackImage,
      'license_front_image': licenseFrontImage,
      'license_back_image': licenseBackImage,
      'commercial_register_front_image': commercialRegisterFrontImage,
      'commercial_register_back_image': commercialRegisterBackImage,
      'vat_included': vatIncluded ? 1 : 0,
      'vat_image_front': vatImageFront,
      'vat_image_back': vatImageBack,
      'cuisine_types': cuisineTypes,
      'branches': branches,
      'delivery_available': deliveryAvailable ? 1 : 0,
      'delivery_cost_per_km': deliveryCostPerKm,
      'table_reservation_available': tableReservationAvailable ? 1 : 0,
      'max_people_per_reservation': maxPeoplePerReservation,
      'reservation_notes': reservationNotes,
      'deposit_required': depositRequired ? 1 : 0,
      'deposit_amount': depositAmount,
      'working_hours': workingHours,
      'the_best': theBest ? 1 : 0,
      'is_available_for_orders': isAvailableForOrders ? 1 : 0,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}