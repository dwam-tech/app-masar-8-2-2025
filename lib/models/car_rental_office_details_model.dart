// lib/models/car_rental_office_details_model.dart

class CarRentalOfficeDetails {
  final int id;
  final String officeName;
  final bool isAvailableForDelivery;
  final bool isAvailableForRent;
  // أضف أي حقول أخرى قد تحتاجها من الـ API

  CarRentalOfficeDetails({
    required this.id,
    required this.officeName,
    required this.isAvailableForDelivery,
    required this.isAvailableForRent,
  });

  factory CarRentalOfficeDetails.fromJson(Map<String, dynamic> json) {
    return CarRentalOfficeDetails(
      id: json['id'] ?? 0,
      officeName: json['office_name'] ?? 'N/A',
      isAvailableForDelivery: (json['is_available_for_delivery'] == 1 || json['is_available_for_delivery'] == true),
      isAvailableForRent: (json['is_available_for_rent'] == 1 || json['is_available_for_rent'] == true),
    );
  }
}