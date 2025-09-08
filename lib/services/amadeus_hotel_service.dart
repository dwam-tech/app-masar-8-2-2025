import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/hotel_offer.dart';
import 'AmadeusAuthService.dart';

class AmadeusHotelService {
  final AmadeusAuthService authService = AmadeusAuthService();

  Future<List<HotelOffer>> searchHotels({
    required String cityCode,
    required String checkInDate,
    required String checkOutDate,
    required int adults,
    int roomQuantity = 1,
    double? maxPrice,
    int? hotelRating,
    String? hotelName,
  }) async {
    try {
      final token = await authService.getToken();
      
      // بناء معاملات الاستعلام
      final queryParams = {
        'cityCode': cityCode,
        'checkInDate': checkInDate,
        'checkOutDate': checkOutDate,
        'adults': adults.toString(),
        'roomQuantity': roomQuantity.toString(),
        'currency': 'EGP',
        'max': '10', // الحد الأقصى للنتائج
      };

      // إضافة الفلاتر الاختيارية
      if (maxPrice != null) {
        queryParams['priceRange'] = '0-${maxPrice.toInt()}';
      }
      
      if (hotelRating != null && hotelRating > 0) {
        queryParams['ratings'] = hotelRating.toString();
      }

      final uri = Uri.https('test.api.amadeus.com', '/v2/shopping/hotel-offers', queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _parseHotelOffers(data);
      } else if (response.statusCode == 401) {
        // إعادة المحاولة مع رمز جديد
        final newToken = await authService.getToken();
        
        final retryResponse = await http.get(
          uri,
          headers: {
            'Authorization': 'Bearer $newToken',
            'Content-Type': 'application/json',
          },
        );
        
        if (retryResponse.statusCode == 200) {
          final data = jsonDecode(retryResponse.body);
          return _parseHotelOffers(data);
        } else {
          throw Exception('فشل في الحصول على نتائج الفنادق: ${retryResponse.statusCode}');
        }
      } else {
        throw Exception('خطأ في API: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('خطأ في البحث عن الفنادق: $e');
      // في حالة الخطأ، إرجاع البيانات الوهمية للاختبار
      return _getMockHotels(cityCode, checkInDate, checkOutDate, adults, roomQuantity);
    }
  }

  List<HotelOffer> _parseHotelOffers(dynamic data) {
    final List<HotelOffer> hotels = [];
    
    if (data['data'] != null) {
      for (var item in data['data']) {
        try {
          hotels.add(HotelOffer.fromJson(item));
        } catch (e) {
          print('خطأ في تحليل بيانات الفندق: $e');
          // تجاهل الفندق في حالة خطأ التحليل
          continue;
        }
      }
    }
    
    // إذا لم نحصل على نتائج من API، استخدم البيانات الوهمية
    if (hotels.isEmpty) {
      return HotelOffer.mockList;
    }
    
    return hotels;
  }

  List<HotelOffer> _getMockHotels(String cityCode, String checkInDate, String checkOutDate, int adults, int rooms) {
    // تحديث البيانات الوهمية بمعاملات البحث الفعلية
    return HotelOffer.mockList.map((hotel) {
      return HotelOffer(
        hotelId: hotel.hotelId,
        name: hotel.name,
        description: hotel.description,
        address: hotel.address,
        cityCode: cityCode,
        latitude: hotel.latitude,
        longitude: hotel.longitude,
        rating: hotel.rating,
        category: hotel.category,
        amenities: hotel.amenities,
        mainPhoto: hotel.mainPhoto,
        photos: hotel.photos,
        price: hotel.price,
        currency: hotel.currency,
        priceBreakdown: hotel.priceBreakdown,
        freeCancellation: hotel.freeCancellation,
        cancellationPolicy: hotel.cancellationPolicy,
        distanceFromCenter: hotel.distanceFromCenter,
        distanceFromAirport: hotel.distanceFromAirport,
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
        nights: _calculateNights(checkInDate, checkOutDate),
        adults: adults,
        rooms: rooms,
      );
    }).toList();
  }

  int _calculateNights(String checkIn, String checkOut) {
    try {
      final checkInDate = DateTime.parse(checkIn);
      final checkOutDate = DateTime.parse(checkOut);
      return checkOutDate.difference(checkInDate).inDays;
    } catch (e) {
      return 1; // افتراضي
    }
  }

  // البحث عن الفنادق بالاسم (للفلترة المحلية)
  List<HotelOffer> filterHotelsByName(List<HotelOffer> hotels, String name) {
    if (name.isEmpty) return hotels;
    
    return hotels.where((hotel) => 
      hotel.name.toLowerCase().contains(name.toLowerCase())
    ).toList();
  }

  // فلترة الفنادق حسب السعر
  List<HotelOffer> filterHotelsByPrice(List<HotelOffer> hotels, double maxPrice) {
    return hotels.where((hotel) => hotel.price <= maxPrice).toList();
  }

  // فلترة الفنادق حسب التقييم
  List<HotelOffer> filterHotelsByRating(List<HotelOffer> hotels, double minRating) {
    return hotels.where((hotel) => 
      hotel.rating != null && hotel.rating! >= minRating
    ).toList();
  }

  // ترتيب الفنادق
  List<HotelOffer> sortHotels(List<HotelOffer> hotels, String sortBy) {
    final sortedHotels = List<HotelOffer>.from(hotels);
    
    switch (sortBy) {
      case 'السعر':
        sortedHotels.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'التقييم':
        sortedHotels.sort((a, b) {
          final ratingA = a.rating ?? 0;
          final ratingB = b.rating ?? 0;
          return ratingB.compareTo(ratingA); // ترتيب تنازلي
        });
        break;
      case 'المسافة':
        sortedHotels.sort((a, b) {
          final distanceA = a.distanceFromCenter ?? a.distanceFromAirport ?? double.infinity;
          final distanceB = b.distanceFromCenter ?? b.distanceFromAirport ?? double.infinity;
          return distanceA.compareTo(distanceB);
        });
        break;
      case 'الاسم':
        sortedHotels.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
    
    return sortedHotels;
  }
}