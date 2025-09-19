import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/offer_model.dart';
import 'laravel_service.dart';

class OffersService {
  static const String baseUrl = 'http://192.168.1.100:8000/api';

  // الحصول على العروض لطلب توصيل معين
  static Future<List<OfferModel>> getOffersForRequest(int requestId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        throw Exception('لم يتم العثور على رمز المصادقة');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/delivery-requests/$requestId/offers'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> offersJson = data['data'] ?? [];
        return offersJson.map((json) => OfferModel.fromJson(json)).toList();
      } else {
        throw Exception('فشل في جلب العروض: ${response.statusCode}');
      }
    } catch (e) {
      print('خطأ في جلب العروض: $e');
      throw Exception('حدث خطأ أثناء جلب العروض');
    }
  }

  // قبول عرض معين
  static Future<bool> acceptOffer(int offerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        throw Exception('لم يتم العثور على رمز المصادقة');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/offers/$offerId/accept'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('فشل في قبول العرض: ${response.statusCode}');
      }
    } catch (e) {
      print('خطأ في قبول العرض: $e');
      throw Exception('حدث خطأ أثناء قبول العرض');
    }
  }

  // رفض عرض معين
  static Future<bool> rejectOffer(int offerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        throw Exception('لم يتم العثور على رمز المصادقة');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/offers/$offerId/reject'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('فشل في رفض العرض: ${response.statusCode}');
      }
    } catch (e) {
      print('خطأ في رفض العرض: $e');
      throw Exception('حدث خطأ أثناء رفض العرض');
    }
  }

  // إنشاء عرض مضاد
  static Future<bool> createCounterOffer(int offerId, double newPrice, String? notes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        throw Exception('لم يتم العثور على رمز المصادقة');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/offers/$offerId/counter'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: json.encode({
          'new_price': newPrice,
          'notes': notes,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception('فشل في إنشاء العرض المضاد: ${response.statusCode}');
      }
    } catch (e) {
      print('خطأ في إنشاء العرض المضاد: $e');
      throw Exception('حدث خطأ أثناء إنشاء العرض المضاد');
    }
  }

  // الحصول على تفاصيل طلب التوصيل مع العروض
  static Future<DeliveryRequestModel?> getDeliveryRequestWithOffers(int requestId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        throw Exception('لم يتم العثور على رمز المصادقة');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/delivery-requests/$requestId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return DeliveryRequestModel.fromJson(data['data']);
      } else {
        throw Exception('فشل في جلب تفاصيل الطلب: ${response.statusCode}');
      }
    } catch (e) {
      print('خطأ في جلب تفاصيل الطلب: $e');
      return null;
    }
  }

  // إلغاء طلب التوصيل
  static Future<bool> cancelDeliveryRequest(int requestId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        throw Exception('لم يتم العثور على رمز المصادقة');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/delivery-requests/$requestId/cancel'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('فشل في إلغاء الطلب: ${response.statusCode}');
      }
    } catch (e) {
      print('خطأ في إلغاء الطلب: $e');
      throw Exception('حدث خطأ أثناء إلغاء الطلب');
    }
  }
}