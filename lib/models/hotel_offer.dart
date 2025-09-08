class HotelOffer {
  final String hotelId;
  final String name;
  final String? description;
  final String? address;
  final String? cityCode;
  final double? latitude;
  final double? longitude;
  final double? rating;
  final String? category;
  final List<String> amenities;
  final String? mainPhoto;
  final List<String> photos;
  final double price;
  final String currency;
  final String? priceBreakdown;
  final bool freeCancellation;
  final String? cancellationPolicy;
  final double? distanceFromCenter;
  final double? distanceFromAirport;
  final String checkInDate;
  final String checkOutDate;
  final int nights;
  final int adults;
  final int rooms;
  final String? contactPhone;
  final String? contactEmail;
  final String? website;
  final List<String> roomTypes;
  final Map<String, dynamic>? roomDetails;
  final List<String> nearbyAttractions;
  final String? checkInTime;
  final String? checkOutTime;
  final List<String> languages;
  final bool petFriendly;
  final bool smokingAllowed;
  final String? offerId;

  HotelOffer({
    required this.hotelId,
    required this.name,
    this.description,
    this.address,
    this.cityCode,
    this.latitude,
    this.longitude,
    this.rating,
    this.category,
    this.amenities = const [],
    this.mainPhoto,
    this.photos = const [],
    required this.price,
    required this.currency,
    this.priceBreakdown,
    this.freeCancellation = false,
    this.cancellationPolicy,
    this.distanceFromCenter,
    this.distanceFromAirport,
    required this.checkInDate,
    required this.checkOutDate,
    required this.nights,
    required this.adults,
    required this.rooms,
    this.contactPhone,
    this.contactEmail,
    this.website,
    this.roomTypes = const [],
    this.roomDetails,
    this.nearbyAttractions = const [],
    this.checkInTime,
    this.checkOutTime,
    this.languages = const [],
    this.petFriendly = false,
    this.smokingAllowed = false,
    this.offerId,
  });

  factory HotelOffer.fromJson(Map<String, dynamic> json) {
    final hotel = json['hotel'] ?? {};
    final offers = json['offers'] as List? ?? [];
    final firstOffer = offers.isNotEmpty ? offers[0] : {};
    final price = firstOffer['price'] ?? {};
    final policies = firstOffer['policies'] ?? {};
    final cancellation = policies['cancellation'] ?? {};

    return HotelOffer(
      hotelId: hotel['hotelId'] ?? '',
      name: hotel['name'] ?? 'فندق غير محدد',
      description: hotel['description']?['text'],
      address: hotel['address']?['lines']?.join(', '),
      cityCode: hotel['address']?['cityCode'],
      latitude: hotel['geoCode']?['latitude']?.toDouble(),
      longitude: hotel['geoCode']?['longitude']?.toDouble(),
      rating: hotel['rating']?.toDouble(),
      category: hotel['hotelCategory'],
      amenities: (hotel['amenities'] as List?)?.cast<String>() ?? [],
      mainPhoto: hotel['media']?.isNotEmpty == true ? hotel['media'][0]['uri'] : null,
      photos: (hotel['media'] as List?)?.map<String>((m) => m['uri'] as String).toList() ?? [],
      price: double.tryParse(price['total']?.toString() ?? '0') ?? 0,
      currency: price['currency'] ?? 'EGP',
      priceBreakdown: price['base']?.toString(),
      freeCancellation: cancellation['type'] == 'FREE_CANCELLATION',
      cancellationPolicy: cancellation['description']?['text'],
      distanceFromCenter: hotel['distanceFromCenter']?.toDouble(),
      distanceFromAirport: hotel['distanceFromAirport']?.toDouble(),
      checkInDate: firstOffer['checkInDate'] ?? '',
      checkOutDate: firstOffer['checkOutDate'] ?? '',
      nights: firstOffer['nights'] ?? 1,
      adults: firstOffer['guests']?['adults'] ?? 1,
      rooms: firstOffer['room']?['quantity'] ?? 1,
      contactPhone: hotel['contact']?['phone'],
      contactEmail: hotel['contact']?['email'],
      website: hotel['contact']?['website'],
      roomTypes: (firstOffer['room']?['typeEstimated']?['category'] != null) 
          ? [firstOffer['room']['typeEstimated']['category']] 
          : [],
      roomDetails: firstOffer['room']?['typeEstimated'],
      nearbyAttractions: (hotel['nearbyAttractions'] as List?)?.cast<String>() ?? [],
      checkInTime: policies['checkInOut']?['checkIn']?['description']?['text'],
      checkOutTime: policies['checkInOut']?['checkOut']?['description']?['text'],
      languages: (hotel['contact']?['languages'] as List?)?.cast<String>() ?? ['العربية', 'English'],
      petFriendly: hotel['amenities']?.contains('PET_FRIENDLY') ?? false,
      smokingAllowed: hotel['amenities']?.contains('SMOKING_ALLOWED') ?? false,
      offerId: firstOffer['id'],
    );
  }

  // MOCK DATA للاختبار
  static List<HotelOffer> mockList = [
    HotelOffer(
      hotelId: "HOTEL001",
      name: "فندق النيل الذهبي",
      description: "فندق فاخر على ضفاف النيل مع إطلالة رائعة",
      address: "شارع النيل، وسط البلد، القاهرة",
      cityCode: "CAI",
      rating: 4.5,
      category: "5 نجوم",
      amenities: ["واي فاي مجاني", "مسبح", "سبا", "مطعم"],
      mainPhoto: "https://example.com/hotel1.jpg",
      price: 2500,
      currency: "ج.م",
      freeCancellation: true,
      distanceFromCenter: 2.5,
      distanceFromAirport: 25.0,
      checkInDate: "2025-01-15",
      checkOutDate: "2025-01-17",
      nights: 2,
      adults: 2,
      rooms: 1,
      contactPhone: "+20 2 1234 5678",
      contactEmail: "info@goldennile.com",
      website: "www.goldennile.com",
      roomTypes: ["جناح ملكي", "غرفة ديلوكس", "غرفة عادية"],
      nearbyAttractions: ["المتحف المصري", "خان الخليلي", "قلعة صلاح الدين"],
      checkInTime: "3:00 مساءً",
      checkOutTime: "12:00 ظهراً",
      languages: ["العربية", "English", "Français"],
      petFriendly: true,
      smokingAllowed: false,
      offerId: "OFFER001",
    ),
    HotelOffer(
      hotelId: "HOTEL002",
      name: "فندق الأهرام الملكي",
      description: "فندق متميز بالقرب من الأهرامات",
      address: "طريق الأهرام، الجيزة",
      cityCode: "CAI",
      rating: 4.2,
      category: "4 نجوم",
      amenities: ["واي فاي مجاني", "مطعم", "موقف سيارات"],
      mainPhoto: "https://example.com/hotel2.jpg",
      price: 1800,
      currency: "ج.م",
      freeCancellation: false,
      distanceFromCenter: 15.0,
      distanceFromAirport: 35.0,
      checkInDate: "2025-01-15",
      checkOutDate: "2025-01-17",
      nights: 2,
      adults: 2,
      rooms: 1,
      contactPhone: "+20 2 9876 5432",
      contactEmail: "reservations@pyramidsroyal.com",
      website: "www.pyramidsroyal.com",
      roomTypes: ["غرفة بإطلالة الأهرام", "غرفة عادية"],
      nearbyAttractions: ["أهرامات الجيزة", "أبو الهول", "المتحف الكبير"],
      checkInTime: "2:00 مساءً",
      checkOutTime: "11:00 صباحاً",
      languages: ["العربية", "English"],
      petFriendly: false,
      smokingAllowed: true,
      offerId: "OFFER002",
    ),
    HotelOffer(
      hotelId: "HOTEL003",
      name: "فندق المدينة الحديثة",
      description: "فندق عصري في قلب المدينة",
      address: "شارع التحرير، وسط البلد، القاهرة",
      cityCode: "CAI",
      rating: 4.0,
      category: "4 نجوم",
      amenities: ["واي فاي مجاني", "مركز أعمال", "جيم"],
      mainPhoto: "https://example.com/hotel3.jpg",
      price: 1500,
      currency: "ج.م",
      freeCancellation: true,
      distanceFromCenter: 1.0,
      distanceFromAirport: 20.0,
      checkInDate: "2025-01-15",
      checkOutDate: "2025-01-17",
      nights: 2,
      adults: 2,
      rooms: 1,
      contactPhone: "+20 2 5555 1234",
      contactEmail: "info@modernhotel.com",
      website: "www.modernhotel.com",
      roomTypes: ["غرفة تنفيذية", "غرفة عادية"],
      nearbyAttractions: ["ميدان التحرير", "دار الأوبرا", "جامعة القاهرة"],
      checkInTime: "3:00 مساءً",
      checkOutTime: "12:00 ظهراً",
      languages: ["العربية", "English", "Deutsch"],
      petFriendly: true,
      smokingAllowed: false,
      offerId: "OFFER003",
    ),
  ];

  String get formattedPrice => "${price.toStringAsFixed(0)} $currency";
  
  String get ratingDisplay => rating != null ? "${rating!.toStringAsFixed(1)} ⭐" : "غير مقيم";
  
  String get distanceDisplay {
    if (distanceFromCenter != null) {
      return "${distanceFromCenter!.toStringAsFixed(1)} كم من المركز";
    } else if (distanceFromAirport != null) {
      return "${distanceFromAirport!.toStringAsFixed(1)} كم من المطار";
    }
    return "";
  }
}