import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/flight_offer.dart';
import 'AmadeusAuthService.dart';

enum FlightErrorType {
  networkError,
  invalidLocation,
  invalidDate,
  invalidInput,
  authenticationError,
  noFlightsFound,
  rateLimitExceeded,
  serverError,
  dataParsingError,
  unknownError,
}

class FlightSearchException implements Exception {
  final String message;
  final FlightErrorType type;
  
  FlightSearchException(this.message, this.type);
  
  @override
  String toString() => message;
}

class AmadeusFlightService {
  final AmadeusAuthService authService = AmadeusAuthService();

  Future<List<FlightOffer>> searchFlights({
    required String origin,
    required String destination,
    required String departureDate,
    String? returnDate,
    required int adults,
    required String travelClass,
  }) async {
    try {
      final token = await authService.getToken();
      final uri = Uri.https('test.api.amadeus.com', '/v2/shopping/flight-offers', {
        'originLocationCode': origin,
        'destinationLocationCode': destination,
        'departureDate': departureDate,
        if (returnDate != null) 'returnDate': returnDate,
        'adults': adults.toString(),
        'travelClass': _classToApi(travelClass),
        'currencyCode': 'EGP',
        'max': '5',
      });

      final resp = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        return _parseOffers(data);
      } else {
        throw _handleApiError(resp.statusCode, resp.body);
      }
    } catch (e) {
      if (e is FlightSearchException) {
        rethrow;
      }
      throw FlightSearchException(
        'حدث خطأ في الاتصال بالخدمة. يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى.',
        FlightErrorType.networkError,
      );
    }
  }

  String _classToApi(String travelClass) {
    switch (travelClass) {
      case 'درجة رجال الأعمال':
        return 'BUSINESS';
      case 'الدرجة الأولى':
        return 'FIRST';
      default:
        return 'ECONOMY';
    }
  }

  FlightSearchException _handleApiError(int statusCode, String responseBody) {
    try {
      final errorData = jsonDecode(responseBody);
      final errors = errorData['errors'] as List?;
      
      if (errors != null && errors.isNotEmpty) {
        final firstError = errors[0];
        final errorCode = firstError['code']?.toString() ?? '';
        final errorDetail = firstError['detail']?.toString() ?? '';
        
        switch (statusCode) {
          case 400:
            if (errorCode.contains('INVALID_LOCATION')) {
              return FlightSearchException(
                'رمز المطار غير صحيح. يرجى التأكد من رموز المطارات المدخلة.',
                FlightErrorType.invalidLocation,
              );
            } else if (errorCode.contains('INVALID_DATE')) {
              return FlightSearchException(
                'التاريخ المدخل غير صحيح. يرجى اختيار تاريخ صحيح في المستقبل.',
                FlightErrorType.invalidDate,
              );
            } else {
              return FlightSearchException(
                'البيانات المدخلة غير صحيحة. يرجى مراجعة المعلومات والمحاولة مرة أخرى.',
                FlightErrorType.invalidInput,
              );
            }
          case 401:
            return FlightSearchException(
              'خطأ في التوثيق. يرجى المحاولة مرة أخرى.',
              FlightErrorType.authenticationError,
            );
          case 404:
            return FlightSearchException(
              'لا توجد رحلات متاحة للمسار والتاريخ المحددين. يرجى تجربة تواريخ أو وجهات أخرى.',
              FlightErrorType.noFlightsFound,
            );
          case 429:
            return FlightSearchException(
              'تم تجاوز الحد المسموح من الطلبات. يرجى الانتظار قليلاً والمحاولة مرة أخرى.',
              FlightErrorType.rateLimitExceeded,
            );
          case 500:
            return FlightSearchException(
              'خطأ في الخادم. يرجى المحاولة مرة أخرى لاحقاً.',
              FlightErrorType.serverError,
            );
          default:
            return FlightSearchException(
              'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.',
              FlightErrorType.unknownError,
            );
        }
      }
    } catch (e) {
      // في حالة فشل تحليل رسالة الخطأ
    }
    
    return FlightSearchException(
      'حدث خطأ في الخدمة. يرجى المحاولة مرة أخرى لاحقاً.',
      FlightErrorType.serverError,
    );
  }

  List<FlightOffer> _parseOffers(dynamic data) {
    try {
      final List<FlightOffer> offers = [];
      if (data['data'] != null && data['data'] is List) {
        for (var item in data['data']) {
          try {
            offers.add(
              FlightOffer(
                id: item['id'] ?? '',
                airline: item['itineraries'][0]['segments'][0]['carrierCode'] ?? '',
                flightNumber: item['itineraries'][0]['segments'][0]['number'] ?? '',
                departureTime: DateTime.parse(item['itineraries'][0]['segments'][0]['departure']['at']),
                arrivalTime: DateTime.parse(item['itineraries'][0]['segments'][0]['arrival']['at']),
                from: item['itineraries'][0]['segments'][0]['departure']['iataCode'],
                to: item['itineraries'][0]['segments'][0]['arrival']['iataCode'],
                fromCode: item['itineraries'][0]['segments'][0]['departure']['iataCode'] ?? '',
                toCode: item['itineraries'][0]['segments'][0]['arrival']['iataCode'] ?? '',
                price: double.tryParse(item['price']['total']) ?? 0,
                currency: item['price']['currency'] ?? 'EGP',
                duration: item['itineraries'][0]['duration'] ?? '',
                cabin: item['travelerPricings'][0]['fareDetailsBySegment'][0]['cabin'] ?? 'ECONOMY',
                availableSeats: item['numberOfBookableSeats'] ?? 9,
                aircraft: item['itineraries'][0]['segments'][0]['aircraft']['code'] ?? '',
                amenities: [],
                refundable: item['pricingOptions']['refundableFare'] ?? false,
                fareType: item['travelerPricings'][0]['fareOption'] ?? 'STANDARD',
                rawData: item,
              ),
            );
          } catch (e) {
            // تجاهل العناصر التي لا يمكن تحليلها
            continue;
          }
        }
      }
      
      if (offers.isEmpty) {
        throw FlightSearchException(
          'لا توجد رحلات متاحة للمسار والتاريخ المحددين.',
          FlightErrorType.noFlightsFound,
        );
      }
      
      return offers;
    } catch (e) {
      if (e is FlightSearchException) {
        rethrow;
      }
      throw FlightSearchException(
        'حدث خطأ في معالجة بيانات الرحلات.',
        FlightErrorType.dataParsingError,
      );
    }
  }
}
