import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/driver_model.dart';
import '../models/delivery_offer_model.dart';
import '../utils/constants.dart';
import '../utils/auth_helper.dart';

class DriverService {
  static const String baseUrl = '${Constants.baseUrl}/api';

  // الحصول على قائمة السائقين المتاحين
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