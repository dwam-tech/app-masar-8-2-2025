// lib/services/property_service.dart

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:saba2v2/models/property_model.dart';
import 'package:saba2v2/services/auth_service.dart'; // سنحتاجها لجلب التوكن
import '../config/constants.dart';

class PropertyService {
  final String _baseUrl = AppConstants.baseUrl; // نفس الـ Base URL
  final AuthService _authService = AuthService(); // للوصول للتوكن

  // دالة لإضافة عقار جديد باستخدام Multipart ليتوافق مع Laravel CreatePropertyRequest
  Future<Property> addProperty({
    required String address,
    required String type,
    required int price,
    required String description,
    required File imageFile,
    required int bedrooms,
    required int bathrooms,
    required String view,
    required String paymentMethod,
    required String area,
    required bool isReady,
    String? contactPhone,
    required String currency,
    required String ownershipType,
    required double latitude,
    required double longitude,
  }) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('User is not authenticated');
    }

    // التحويل الآمن لمساحة العقار إلى رقم بالمتر المربع
    int sizeInSqm;
    try {
      sizeInSqm = int.tryParse(area.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
      if (sizeInSqm < 1) sizeInSqm = 1;
    } catch (_) {
      sizeInSqm = 1;
    }

    // تحضير الطلب متعدد الأجزاء
    final uri = Uri.parse('$_baseUrl/api/properties');
    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    log('[PropertyService] addProperty: Calling POST to ${uri.path}');
    log('[PropertyService] addProperty: Headers - ${request.headers.toString()}');

    // الحقول المطلوبة في Laravel
    request.fields.addAll({
      'title': address, // نستخدم العنوان كعنوان
      'ownership_type': ownershipType,
      'property_price': price.toString(),
      'currency': currency,
      'advertiser_type': 'owner',
      'address': address,
      'bedrooms': bedrooms.toString(),
      'bathrooms': bathrooms.toString(),
      'size_in_sqm': sizeInSqm.toString(),
      'property_status': isReady ? 'available' : 'available', // القيمة الافتراضية
      'property_type': type, // يجب أن يكون من: apartment,villa,townhouse,office,shop
      'description': description,
      'payment_method': paymentMethod,
      'overlooking': view,
      'readiness_status': isReady ? 'ready_to_move' : 'under_construction',
    });

    // حقول مصفوفة متداخلة
    final phoneValue = (contactPhone ?? '').trim();
    request.fields['contact_info[phone]'] = phoneValue.isNotEmpty ? phoneValue : '0000000000';
    // الحقول الاختيارية للبريد والواتساب يمكن إضافتها لاحقاً عند توفرها

    // الموقع الجغرافي
    request.fields['location[latitude]'] = latitude.toString();
    request.fields['location[longitude]'] = longitude.toString();
    request.fields['location[formatted_address]'] = address;

    // إضافة ملف الصورة الرئيسية
    final imageStream = http.ByteStream(imageFile.openRead());
    final imageLength = await imageFile.length();
    final multipartFile = http.MultipartFile(
      'main_image',
      imageStream,
      imageLength,
      filename: imageFile.path.split(Platform.pathSeparator).last,
    );
    request.files.add(multipartFile);

    // تنفيذ الطلب
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    log('[PropertyService] addProperty: Received response with Status Code: ${response.statusCode} | Body: ${response.body}');

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      return Property.fromJson(responseData['property']);
    } else {
      // استخراج رسائل التحقق التفصيلية وطباعتها للطرفية
      String message;
      try {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        if (errorData.containsKey('errors') && errorData['errors'] is Map) {
          final errorsMap = errorData['errors'] as Map<String, dynamic>;
          final messages = <String>[];
          errorsMap.forEach((field, errs) {
            if (errs is List) {
              for (final msg in errs) {
                messages.add('$field: $msg');
              }
            } else if (errs is String) {
              messages.add('$field: $errs');
            }
          });
          message = messages.isNotEmpty
              ? messages.join(' | ')
              : (errorData['message']?.toString() ?? 'Validation failed');
        } else {
          // ضمّن تفاصيل الخطأ الداخلي إن وجدت (حالات 500)
          final baseMsg = errorData['message']?.toString() ?? 'Failed to add property';
          final internalErr = errorData['error']?.toString();
          message = internalErr != null && internalErr.isNotEmpty
              ? '$baseMsg | error: $internalErr'
              : baseMsg;
        }
      } catch (_) {
        // في حال فشل فكّ JSON اطبع النص الخام
        message = 'Failed to add property (status ${response.statusCode}) - Raw: ${response.body}';
      }

      // اطبع النص الخام للاستجابة لمزيد من التشخيص
      debugPrint('[PropertyService] addProperty RAW ${response.statusCode}: ${response.body}');
      debugPrint('[PropertyService] addProperty ERROR ${response.statusCode}: $message');
      throw Exception(message);
    }
  }

  // دالة لجلب عقارات المستخدم الحالي
 Future<List<Property>> getMyProperties() async {
  final token = await _authService.getToken();
  if (token == null) {
    throw Exception('User is not authenticated');
  }

  // استخدم الـ endpoint الجديد الآمن الذي يعيد فقط عقاراتي
  final uri = Uri.parse('$_baseUrl/api/my/properties');
  final headers = { 'Accept': 'application/json', 'Authorization': 'Bearer $token' };
  log('[PropertyService] getMyProperties: Calling GET to ${uri.path}');
  log('[PropertyService] getMyProperties: Headers - ${headers.toString()}');
  final response = await http.get(uri, headers: headers);
  log('[PropertyService] getMyProperties: Received response with Status Code: ${response.statusCode} | Body: ${response.body}');

  if (response.statusCode == 200) {
    final responseData = jsonDecode(response.body);

    // استخرج القائمة من مفتاح "properties"
    final List<dynamic> propertiesJson = responseData['properties'] ?? [];
    
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
  log('[PropertyService] updateProperty: Calling PUT to ${uri.path}');
  log('[PropertyService] updateProperty: Payload - ${propertyData.toString()}');
  final response = await http.put(
    uri,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(propertyData),
  );
  log('[PropertyService] updateProperty: Headers - {Content-Type: application/json, Accept: application/json, Authorization: Bearer ***}');
  log('[PropertyService] updateProperty: Received response with Status Code: ${response.statusCode} | Body: ${response.body}');

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
    log('[PropertyService] deleteProperty: Calling DELETE to ${uri.path}');

    final response = await http.delete(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    log('[PropertyService] deleteProperty: Headers - {Accept: application/json, Authorization: Bearer ***}');
    log('[PropertyService] deleteProperty: Received response with Status Code: ${response.statusCode} | Body: ${response.body}');

    // عادة ما يعيد الـ API استجابة 204 No Content أو 200 OK عند النجاح
    if (response.statusCode != 200 && response.statusCode != 204) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to delete property');
    }
  }


}