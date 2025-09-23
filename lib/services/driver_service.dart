import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/driver_model.dart';
import '../models/delivery_offer_model.dart';
import '../models/delivery_request_model.dart';
import '../utils/constants.dart';
import '../utils/auth_helper.dart';

class DriverService {
  final String token;
  static const String baseUrl = '${Constants.baseUrl}/api';
  
  DriverService({required this.token});

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  /// جلب جميع طلبات التوصيل المتاحة للسائق
  Future<List<DeliveryRequestModel>> fetchAvailableRequests() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/delivery/available-requests'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> requestsJson = data['data'];
          return requestsJson
              .map((json) => DeliveryRequestModel.fromJson(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('خطأ في جلب الطلبات المتاحة: $e');
      return [];
    }
  }

  /// جلب العروض المقدمة من السائق
  Future<List<DeliveryRequestModel>> fetchMyOffers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/delivery/my-offers'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> requestsJson = data['data'];
          return requestsJson
              .map((json) => DeliveryRequestModel.fromJson(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('خطأ في جلب عروضي: $e');
      return [];
    }
  }

  /// جلب الطلبات المنتهية للسائق
  Future<List<DeliveryRequestModel>> fetchCompletedRequests() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/delivery/completed-requests'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> requestsJson = data['data'];
          return requestsJson
              .map((json) => DeliveryRequestModel.fromJson(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('خطأ في جلب الطلبات المنتهية: $e');
      return [];
    }
  }

  /// تقديم عرض على طلب توصيل
  Future<bool> submitOffer({
    required int requestId,
    required double offeredPrice,
    String? notes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/driver/submit-offer'),
        headers: _headers,
        body: json.encode({
          'delivery_request_id': requestId,
          'offered_price': offeredPrice,
          'notes': notes,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('خطأ في تقديم العرض: $e');
      return false;
    }
  }

  /// تحديث حالة توفر السائق
  Future<bool> updateAvailability({required bool isAvailable}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/driver/update-availability'),
        headers: _headers,
        body: json.encode({
          'is_available': isAvailable,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('خطأ في تحديث حالة التوفر: $e');
      return false;
    }
  }

  /// تحديث موقع السائق
  Future<bool> updateDriverLocation({
    required double latitude,
    required double longitude,
    String? governorate,
    String? city,
    String? currentAddress,
    bool locationSharingEnabled = true,
  }) async {
    try {
      print('محاولة تحديث الموقع: lat=$latitude, lng=$longitude, gov=$governorate, city=$city');
      
      final requestBody = {
        'latitude': latitude,
        'longitude': longitude,
        'governorate': governorate,
        'city': city,
        'current_address': currentAddress,
        'location_sharing_enabled': locationSharingEnabled,
      };
      
      print('بيانات الطلب: ${json.encode(requestBody)}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/driver/update-location'),
        headers: _headers,
        body: json.encode(requestBody),
      );

      print('رمز الاستجابة: ${response.statusCode}');
      print('محتوى الاستجابة: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final success = data['status'] == true;
        print('نتيجة التحديث: $success');
        return success;
      } else {
        print('فشل الطلب برمز: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('خطأ في تحديث الموقع: $e');
      return false;
    }
  }

  // الحصول على قائمة السائقين المتاحين (الوظيفة الأصلية)
  static Future<List<Driver>> getAvailableDrivers({
    double? latitude,
    double? longitude,
    double? radius,
  }) async {
    try {
      final token = await AuthHelper.getToken();
      if (token == null) {
        throw Exception('لم يتم العثور على رمز المصادقة');
      }

      final Map<String, String> queryParams = {};
      if (latitude != null) queryParams['latitude'] = latitude.toString();
      if (longitude != null) queryParams['longitude'] = longitude.toString();
      if (radius != null) queryParams['radius'] = radius.toString();

      final uri = Uri.parse('$baseUrl/drivers/available')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == true) {
          final List<dynamic> driversJson = data['drivers'] ?? [];
          return driversJson.map((json) => Driver.fromJson(json)).toList();
        } else {
          throw Exception(data['message'] ?? 'فشل في جلب السائقين');
        }
      } else {
        throw Exception('خطأ في الخادم: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في جلب السائقين: $e');
    }
  }

  // الحصول على بيانات سائق محدد
  static Future<Driver?> getDriverProfile(int driverId) async {
    try {
      final token = await AuthHelper.getToken();
      if (token == null) {
        throw Exception('لم يتم العثور على رمز المصادقة');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/drivers/$driverId/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == true) {
          return Driver.fromJson(data['driver']);
        } else {
          throw Exception(data['message'] ?? 'فشل في جلب بيانات السائق');
        }
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('خطأ في الخادم: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في جلب بيانات السائق: $e');
    }
  }

  // تحديث تقييم السائق
  static Future<bool> updateDriverRating(int driverId, double rating) async {
    try {
      final token = await AuthHelper.getToken();
      if (token == null) {
        throw Exception('لم يتم العثور على رمز المصادقة');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/drivers/$driverId/rating'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'rating': rating,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['status'] == true;
      } else {
        final Map<String, dynamic> data = json.decode(response.body);
        throw Exception(data['message'] ?? 'فشل في تحديث التقييم');
      }
    } catch (e) {
      throw Exception('خطأ في تحديث التقييم: $e');
    }
  }

  // الحصول على العروض لطلب توصيل محدد
  static Future<List<DeliveryOffer>> getOffersForDeliveryRequest(int deliveryRequestId) async {
    try {
      final token = await AuthHelper.getToken();
      if (token == null) {
        throw Exception('لم يتم العثور على رمز المصادقة');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/delivery/requests/$deliveryRequestId/offers'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == true) {
          final List<dynamic> offersJson = data['offers'] ?? [];
          return offersJson.map((json) => DeliveryOffer.fromJson(json)).toList();
        } else {
          throw Exception(data['message'] ?? 'فشل في جلب العروض');
        }
      } else {
        throw Exception('خطأ في الخادم: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في جلب العروض: $e');
    }
  }

  // قبول عرض من سائق
  static Future<bool> acceptOffer(int deliveryRequestId, int offerId) async {
    try {
      final token = await AuthHelper.getToken();
      if (token == null) {
        throw Exception('لم يتم العثور على رمز المصادقة');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/delivery/requests/$deliveryRequestId/offers/$offerId/accept'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['status'] == true;
      } else {
        final Map<String, dynamic> data = json.decode(response.body);
        throw Exception(data['message'] ?? 'فشل في قبول العرض');
      }
    } catch (e) {
      throw Exception('خطأ في قبول العرض: $e');
    }
  }


}