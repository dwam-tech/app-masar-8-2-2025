import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import '../models/hotel_offer.dart';
import '../services/amadeus_hotel_service.dart';

class HotelSearchProvider extends ChangeNotifier {
  bool isLoading = false;
  String? error;
  List<HotelOffer> results = [];
  List<HotelOffer> _originalResults = [];

  // حفظ آخر بحث
  String? lastSearchCityCode;
  String? lastSearchCheckInDate;
  String? lastSearchCheckOutDate;
  int? lastSearchAdults;
  int? lastSearchRooms;
  double? lastSearchMaxPrice;
  int? lastSearchHotelRating;
  String? lastSearchHotelName;

  final AmadeusHotelService _service = AmadeusHotelService();

  Future<void> searchHotels({
    required String cityCode,
    required String checkInDate,
    required String checkOutDate,
    required int adults,
    int roomQuantity = 1,
    double? maxPrice,
    int? hotelRating,
    String? hotelName,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    // حفظ معايير البحث
    lastSearchCityCode = cityCode;
    lastSearchCheckInDate = checkInDate;
    lastSearchCheckOutDate = checkOutDate;
    lastSearchAdults = adults;
    lastSearchRooms = roomQuantity;
    lastSearchMaxPrice = maxPrice;
    lastSearchHotelRating = hotelRating;
    lastSearchHotelName = hotelName;

    try {
      results = await _service.searchHotels(
        cityCode: cityCode,
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
        adults: adults,
        roomQuantity: roomQuantity,
        maxPrice: maxPrice,
        hotelRating: hotelRating,
        hotelName: hotelName,
      );
      _originalResults = List.from(results);
      
      if (results.isEmpty) {
        error = 'لا توجد فنادق متاحة للمعايير المحددة';
      }
    } catch (e) {
      debugPrint('HotelSearchProvider searchHotels Error: $e');
      
      // معالجة أنواع مختلفة من الأخطاء
      if (e is SocketException || e.toString().contains('NetworkException')) {
        error = 'تعذر الاتصال بالخادم. يرجى التحقق من اتصال الإنترنت';
      } else if (e is TimeoutException) {
        error = 'انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى';
      } else if (e is FormatException) {
        error = 'خطأ في تنسيق البيانات المستلمة';
      } else {
        error = 'حدث خطأ أثناء البحث: ${e.toString()}';
      }
      
      results = [];
      _originalResults = [];
    }
    
    isLoading = false;
    notifyListeners();
  }

  void sortResults(String sortBy) {
    results = _service.sortHotels(results, sortBy);
    notifyListeners();
  }

  void filterResults({
    double? maxPrice,
    double? minRating,
    String? hotelName,
    bool? freeCancellation,
  }) {
    results = List.from(_originalResults);
    
    if (maxPrice != null) {
      results = _service.filterHotelsByPrice(results, maxPrice);
    }
    
    if (minRating != null) {
      results = _service.filterHotelsByRating(results, minRating);
    }
    
    if (hotelName != null && hotelName.isNotEmpty) {
      results = _service.filterHotelsByName(results, hotelName);
    }
    
    if (freeCancellation == true) {
      results = results.where((hotel) => hotel.freeCancellation).toList();
    }
    
    notifyListeners();
  }

  void resetFilters() {
    results = List.from(_originalResults);
    notifyListeners();
  }

  // الحصول على قائمة المدن المتاحة (يمكن توسيعها لاحقاً)
  List<Map<String, String>> getAvailableCities() {
    return [
      {'name': 'القاهرة', 'code': 'CAI'},
      {'name': 'الإسكندرية', 'code': 'ALY'},
      {'name': 'الأقصر', 'code': 'LXR'},
      {'name': 'أسوان', 'code': 'ASW'},
      {'name': 'شرم الشيخ', 'code': 'SSH'},
      {'name': 'الغردقة', 'code': 'HRG'},
      {'name': 'دبي', 'code': 'DXB'},
      {'name': 'أبو ظبي', 'code': 'AUH'},
      {'name': 'الرياض', 'code': 'RUH'},
      {'name': 'جدة', 'code': 'JED'},
      {'name': 'الدوحة', 'code': 'DOH'},
      {'name': 'الكويت', 'code': 'KWI'},
      {'name': 'بيروت', 'code': 'BEY'},
      {'name': 'عمان', 'code': 'AMM'},
      {'name': 'الدار البيضاء', 'code': 'CMN'},
      {'name': 'تونس', 'code': 'TUN'},
      {'name': 'اسطنبول', 'code': 'IST'},
      {'name': 'لندن', 'code': 'LON'},
      {'name': 'باريس', 'code': 'PAR'},
      {'name': 'روما', 'code': 'ROM'},
    ];
  }

  // البحث في قائمة المدن
  List<Map<String, String>> searchCities(String query) {
    if (query.isEmpty) return getAvailableCities();
    
    return getAvailableCities().where((city) =>
      city['name']!.contains(query) || 
      city['code']!.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  // الحصول على اسم المدينة من الكود
  String getCityNameFromCode(String code) {
    final city = getAvailableCities().firstWhere(
      (city) => city['code'] == code,
      orElse: () => {'name': code, 'code': code},
    );
    return city['name']!;
  }

  // التحقق من صحة التواريخ
  String? validateDates(DateTime? checkIn, DateTime? checkOut) {
    if (checkIn == null || checkOut == null) {
      return 'يرجى تحديد تواريخ الدخول والخروج';
    }
    
    if (checkIn.isBefore(DateTime.now().subtract(Duration(days: 1)))) {
      return 'تاريخ الدخول لا يمكن أن يكون في الماضي';
    }
    
    if (checkOut.isBefore(checkIn)) {
      return 'تاريخ الخروج يجب أن يكون بعد تاريخ الدخول';
    }
    
    if (checkOut.difference(checkIn).inDays > 30) {
      return 'مدة الإقامة لا يمكن أن تزيد عن 30 يوماً';
    }
    
    return null;
  }

  // حساب عدد الليالي
  int calculateNights(DateTime checkIn, DateTime checkOut) {
    return checkOut.difference(checkIn).inDays;
  }

  // الحصول على إحصائيات النتائج
  Map<String, dynamic> getResultsStats() {
    if (results.isEmpty) {
      return {
        'totalHotels': 0,
        'averagePrice': 0.0,
        'priceRange': {'min': 0.0, 'max': 0.0},
        'averageRating': 0.0,
        'freeCancellationCount': 0,
      };
    }

    final prices = results.map((h) => h.price).toList();
    final ratings = results.where((h) => h.rating != null).map((h) => h.rating!).toList();
    
    return {
      'totalHotels': results.length,
      'averagePrice': prices.reduce((a, b) => a + b) / prices.length,
      'priceRange': {
        'min': prices.reduce((a, b) => a < b ? a : b),
        'max': prices.reduce((a, b) => a > b ? a : b),
      },
      'averageRating': ratings.isNotEmpty ? ratings.reduce((a, b) => a + b) / ratings.length : 0.0,
      'freeCancellationCount': results.where((h) => h.freeCancellation).length,
    };
  }
}