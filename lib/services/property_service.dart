// lib/services/property_service.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:saba2v2/models/property_model.dart';
import 'package:saba2v2/services/auth_service.dart'; // سنحتاجها لجلب التوكن

class PropertyService {
  final String _baseUrl = 'http://192.168.1.7:8000'; // نفس الـ Base URL
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

    final response = await http.post(
      Uri.parse('$_baseUrl/api/properties'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
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
  final realEstateId = await _authService.getRealEstateId();

  if (token == null || realEstateId == null) {
    throw Exception('User is not authenticated or missing Real Estate ID');
  }

  final uri = Uri.parse('$_baseUrl/api/properties?real_estate_id=$realEstateId');
  
  final response = await http.get(
    uri,
    headers: { 'Accept': 'application/json', 'Authorization': 'Bearer $token' },
  );

  if (response.statusCode == 200) {
    final responseData = jsonDecode(response.body);

    // ==========================================================
    // --- هذا هو التعديل الوحيد المطلوب ---
    // السطر القديم:
    // final List<dynamic> propertiesJson = responseData; 

    // السطر الجديد الصحيح:
    // نخبر الكود أن يستخرج القائمة من مفتاح "properties"
    final List<dynamic> propertiesJson = responseData['properties'];
    // ==========================================================
    
    return propertiesJson.map((json) => Property.fromJson(json)).toList();
  } else {
    final errorData = jsonDecode(response.body);
    throw Exception(errorData['message'] ?? 'Failed to fetch properties');
  }
}


// في ملف: lib/services/property_service.dart

Future<Property> updateProperty(int propertyId, Map<String, dynamic> propertyData) async {
  final token = await _authService.getToken();
  if (token == null) throw Exception('User is not authenticated');

  final uri = Uri.parse('$_baseUrl/api/properties/$propertyId');

  final response = await http.put(
    uri,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(propertyData),
  );

  if (response.statusCode == 200) {
    final responseData = jsonDecode(response.body);
    return Property.fromJson(responseData['property'] ?? responseData);
  } else {
    final errorData = jsonDecode(response.body);
    throw Exception(errorData['message'] ?? 'Failed to update property');
  }
}
 
 
 
  /// دالة لحذف عقار عبر الـ API
  Future<void> deleteProperty(int propertyId) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('User is not authenticated');
    }

    // الـ Endpoint الخاص بالحذف عادة ما يكون DELETE ويحتوي على ID العقار
    final uri = Uri.parse('$_baseUrl/api/properties/$propertyId');

    final response = await http.delete(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    // عادة ما يعيد الـ API استجابة 204 No Content أو 200 OK عند النجاح
    if (response.statusCode != 200 && response.statusCode != 204) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to delete property');
    }
  }


}