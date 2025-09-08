import 'package:flutter/material.dart';
import 'dart:io';
import '../models/flight_offer.dart';
import '../services/amadeus_flight_service.dart';

class FlightSearchProvider extends ChangeNotifier {
  bool isLoading = false;
  String? error;
  List<FlightOffer> results = [];
  List<FlightOffer> _originalResults = [];

  // حفظ آخر بحث
  String? lastSearchOrigin;
  String? lastSearchDestination;
  String? lastSearchDepartureDate;
  String? lastSearchReturnDate;
  int? lastSearchAdults;
  String? lastSearchTravelClass;

  final AmadeusFlightService _service = AmadeusFlightService();

  Future<void> searchFlights({
    required String origin,
    required String destination,
    required String departureDate,
    String? returnDate,
    required int adults,
    required String travelClass,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    // حفظ معايير البحث
    lastSearchOrigin = origin;
    lastSearchDestination = destination;
    lastSearchDepartureDate = departureDate;
    lastSearchReturnDate = returnDate;
    lastSearchAdults = adults;
    lastSearchTravelClass = travelClass;

    try {
      results = await _service.searchFlights(
        origin: origin,
        destination: destination,
        departureDate: departureDate,
        returnDate: returnDate,
        adults: adults,
        travelClass: travelClass,
      );
      _originalResults = List.from(results);
    } catch (e) {
      if (e is FlightSearchException) {
        error = e.message;
      } else if (e is SocketException) {
        error = 'مشكلة في الاتصال بالإنترنت. يرجى التحقق من اتصالك وإعادة المحاولة.';
      } else if (e.toString().contains('ClientException') || 
                 e.toString().contains('connection abort')) {
        error = 'تم قطع الاتصال مع الخدمة. يرجى التحقق من اتصال الإنترنت وإعادة المحاولة.';
      } else if (e.toString().contains('timeout')) {
        error = 'انتهت مهلة الاتصال. يرجى إعادة المحاولة بعد قليل.';
      } else {
        error = 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.';
      }
    }
    isLoading = false;
    notifyListeners();
  }

  void sortResults(String sortBy) {
    switch (sortBy) {
      case 'السعر':
        results.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'الوقت':
        results.sort((a, b) => a.departureTime.compareTo(b.departureTime));
        break;
      case 'المدة':
        results.sort((a, b) {
          // استخراج الساعات من نص المدة (مثل "2h 30m")
          int getDurationInMinutes(String duration) {
            int totalMinutes = 0;
            final hourMatch = RegExp(r'(\d+)h').firstMatch(duration);
            final minuteMatch = RegExp(r'(\d+)m').firstMatch(duration);
            
            if (hourMatch != null) {
              totalMinutes += int.parse(hourMatch.group(1)!) * 60;
            }
            if (minuteMatch != null) {
              totalMinutes += int.parse(minuteMatch.group(1)!);
            }
            
            return totalMinutes;
          }
          
          return getDurationInMinutes(a.duration).compareTo(getDurationInMinutes(b.duration));
        });
        break;
    }
    notifyListeners();
  }

  void filterResults({
    double? maxPrice,
    String? airline,
    String? departureTimeRange,
  }) {
    results = List.from(_originalResults);
    
    if (maxPrice != null) {
      results = results.where((offer) => offer.price <= maxPrice).toList();
    }
    
    if (airline != null && airline.isNotEmpty) {
      results = results.where((offer) => offer.airline.contains(airline)).toList();
    }
    
    if (departureTimeRange != null) {
      // يمكن إضافة منطق فلترة الوقت هنا
    }
    
    notifyListeners();
  }

  void resetFilters() {
    results = List.from(_originalResults);
    notifyListeners();
  }
}
