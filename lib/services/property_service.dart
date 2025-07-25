// lib/services/property_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:saba2v2/models/property_model.dart';
import 'package:saba2v2/services/auth_service.dart'; // سنحتاجها لجلب التوكن

class PropertyService {
  final String _baseUrl = 'http://192.168.1.8:8000'; // نفس الـ Base URL
  final AuthService _authService = AuthService(); // للوصول للتوكن

  // دالة لإضافة عقار جديد
  Future<Property> addProperty({
    required String address,
    required String type,
    required int price,
    required String description,
    required String imageUrl,
    required int bedrooms,
    required int bathrooms,
    required String view,
    required String paymentMethod,
    required String area,
    required bool isReady,
  }) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('User is not authenticated');
    }

    // نحاول الحصول على معرف مكتب/وكيل العقارات المسجل
    final userData = await _authService.getUserData();
    final realEstateId =
        userData?['real_estate_id'] ?? userData?['id']; // احتياطي في حال اختلف الاسم
    if (realEstateId == null) {
      throw Exception('Real estate ID not found');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/api/properties'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'real_estate_id': realEstateId,
        'address': address,
        'type': type,
        'price': price,
        'description': description,
        'image_url': imageUrl,
        'bedrooms': bedrooms,
        'bathrooms': bathrooms,
        'view': view,
        'payment_method': paymentMethod,
        'area': area,
        'is_ready': isReady,
      }),
    );

    if (response.statusCode == 201) { // 201 Created
      final responseData = jsonDecode(response.body);
      // عادة ما يعيد الـ API بيانات العنصر الذي تم إنشاؤه
      return Property.fromJson(responseData['property']);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to add property');
    }
  }

  // دالة لجلب عقارات المستخدم الحالي
  Future<List<Property>> getMyProperties() async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/api/my-properties'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final List<dynamic> propertiesJson = responseData['properties'];
      
      // تحويل قائمة الـ JSON إلى قائمة من كائنات Property
      return propertiesJson.map((json) => Property.fromJson(json)).toList();
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to fetch properties');
    }
  }
}