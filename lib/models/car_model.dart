class Car {
  final int id;
  final int carRentalId;
  final String ownerType;
  final String licenseFrontImage;
  final String licenseBackImage;
  final String carLicenseFront;
  final String carLicenseBack;
  final String carImageFront;
  final String carImageBack;
  final String carType;
  final String carModel;
  final String carColor;
  final String carPlateNumber;
  final String governorate;
  final double price;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isReviewed;

  Car({
    required this.id,
    required this.carRentalId,
    required this.ownerType,
    required this.licenseFrontImage,
    required this.licenseBackImage,
    required this.carLicenseFront,
    required this.carLicenseBack,
    required this.carImageFront,
    required this.carImageBack,
    required this.carType,
    required this.carModel,
    required this.carColor,
    required this.carPlateNumber,
    required this.governorate,
    required this.price,
    required this.createdAt,
    required this.updatedAt,
    required this.isReviewed,
  });

  static String _safeUrl(dynamic url) {
    final str = url?.toString() ?? '';
    if (str.startsWith('http')) return str;
    return '';
  }

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id'] ?? 0,
      carRentalId: json['car_rental_id'] ?? 0,
      ownerType: json['owner_type']?.toString() ?? '',
      licenseFrontImage: _safeUrl(json['license_front_image']),
      licenseBackImage: _safeUrl(json['license_back_image']),
      carLicenseFront: _safeUrl(json['car_license_front']),
      carLicenseBack: _safeUrl(json['car_license_back']),
      carImageFront: _safeUrl(json['car_image_front']),
      carImageBack: _safeUrl(json['car_image_back']),
      carType: json['car_type']?.toString() ?? 'N/A',
      carModel: json['car_model']?.toString() ?? 'N/A',
      carColor: json['car_color']?.toString() ?? 'غير محدد',
      carPlateNumber: json['car_plate_number']?.toString() ?? 'N/A',
      governorate: json['governorate']?.toString() ?? 'غير محدد',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
      isReviewed: (json['is_reviewed'] == true || json['is_reviewed'] == 1) ? true : false,
    );
  }
}
