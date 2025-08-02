import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:saba2v2/services/auth_service.dart';

class RestaurantService {
  final String _baseUrl = 'http://192.168.1.7:8000/api';
  final AuthService _authService = AuthService();

  /// جلب تفاصيل المطعم المسجل دخوله حاليًا
  /// ملاحظة: لم نعد بحاجة لـ restaurantId لأن الـ API يحدد المطعم من التوكن
  Future<Map<String, dynamic>> getRestaurantDetails() async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('User is not authenticated.');
    }

    final uri = Uri.parse('$_baseUrl/restaurant/details');
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['status'] == true && responseData['data'] != null) {
        // الـ API يعيد بيانات المستخدم وبداخلها restaurantDetail
        return responseData['data'] as Map<String, dynamic>;
      } else {
        throw Exception(responseData['message'] ?? 'Failed to parse restaurant details.');
      }
    } else {
      // التعامل مع أخطاء مثل 403 (غير مصرح)
      throw Exception('Failed to load restaurant details. Status: ${response.statusCode}');
    }
  }

  /// تحديث تفاصيل المطعم المسجل دخوله حاليًا
  Future<Map<String, dynamic>> updateRestaurantDetails(Map<String, dynamic> data) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('User is not authenticated.');
    }

    final uri = Uri.parse('$_baseUrl/restaurant/details/update');
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );

    // الرد إما يكون ناجحًا أو يحتوي على رسائل خطأ
    final responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      if (responseData['status'] == true) {
        return responseData; // {"status": true, "message": "...", "data": {...}}
      } else {
        // حالة نجاح 200 ولكن status: false
        throw Exception(responseData['message'] ?? 'An unknown error occurred.');
      }
    } else {
      // التعامل مع أخطاء التحقق 422 أو أخطاء الخادم الأخرى
      throw Exception(responseData['message'] ?? 'Failed to update details. Status: ${response.statusCode}');
    }
  }
}