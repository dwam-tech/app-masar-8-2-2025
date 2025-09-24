import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';

class SecurityPermitService {
  
  /// الحصول على بيانات النموذج (الدول، الجنسيات، الرسوم)
  static Future<Map<String, dynamic>> getFormData() async {
    final uri = Uri.parse('${AppConstants.apiBaseUrl}/security-permits/form-data');
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.userTokenKey);

    if (token == null) {
      throw Exception('User is not authenticated.');
    }

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final responseData = json.decode(response.body);

    if (response.statusCode == 200 && responseData['status'] == true) {
      return responseData['data'];
    } else {
      throw Exception(responseData['message'] ?? 'Failed to load form data');
    }
  }

  /// إرسال طلب تصريح أمني جديد مع الصور
  static Future<Map<String, dynamic>> submitPermit({
    required String travelDate,
    required int nationalityId,
    required int peopleCount,
    required int countryId,
    required File passportImage,
    List<File>? residenceImages,
    required String paymentMethod,
    String? notes,
  }) async {
    final uri = Uri.parse('${AppConstants.apiBaseUrl}/security-permits');
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.userTokenKey);

    if (token == null) {
      throw Exception('User is not authenticated.');
    }

    var request = http.MultipartRequest('POST', uri);
    
    // إضافة الهيدرز
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    // إضافة البيانات النصية
    request.fields['travel_date'] = travelDate;
    request.fields['nationality_id'] = nationalityId.toString();
    request.fields['people_count'] = peopleCount.toString();
    request.fields['country_id'] = countryId.toString();
    request.fields['payment_method'] = paymentMethod;
    if (notes != null && notes.isNotEmpty) {
      request.fields['notes'] = notes;
    }

    // إضافة صورة الجواز
    request.files.add(await http.MultipartFile.fromPath(
      'passport_image',
      passportImage.path,
    ));

    // إضافة صور الإقامة إن وجدت
    if (residenceImages != null && residenceImages.isNotEmpty) {
      for (int i = 0; i < residenceImages.length; i++) {
        request.files.add(await http.MultipartFile.fromPath(
          'residence_images[]',
          residenceImages[i].path,
        ));
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final responseData = json.decode(response.body);

    if (response.statusCode == 201 && responseData['status'] == true) {
      return responseData;
    } else {
      throw Exception(responseData['message'] ?? 'Failed to submit permit request');
    }
  }

  /// الحصول على طلبات المستخدم
  static Future<Map<String, dynamic>> getMyPermits({
    String status = 'all',
    String paymentStatus = 'all',
    int page = 1,
  }) async {
    final uri = Uri.parse('${AppConstants.apiBaseUrl}/security-permits/my?status=$status&payment_status=$paymentStatus&page=$page');
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.userTokenKey);

    if (token == null) {
      throw Exception('User is not authenticated.');
    }

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final responseData = json.decode(response.body);

    if (response.statusCode == 200 && responseData['status'] == true) {
      return responseData;
    } else {
      throw Exception(responseData['message'] ?? 'Failed to load permits');
    }
  }

  /// الحصول على تفاصيل طلب محدد
  static Future<Map<String, dynamic>> getPermitDetails(int permitId) async {
    final uri = Uri.parse('${AppConstants.apiBaseUrl}/security-permits/$permitId');
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.userTokenKey);

    if (token == null) {
      throw Exception('User is not authenticated.');
    }

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final responseData = json.decode(response.body);

    if (response.statusCode == 200 && responseData['status'] == true) {
      return responseData;
    } else {
      throw Exception(responseData['message'] ?? 'Failed to load permit details');
    }
  }

  /// تحديث طريقة الدفع
  static Future<Map<String, dynamic>> updatePaymentMethod(int permitId, String paymentMethod) async {
    final uri = Uri.parse('${AppConstants.apiBaseUrl}/security-permits/$permitId/payment-method');
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.userTokenKey);

    if (token == null) {
      throw Exception('User is not authenticated.');
    }

    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'payment_method': paymentMethod,
      }),
    );

    final responseData = json.decode(response.body);

    if (response.statusCode == 200 && responseData['status'] == true) {
      return responseData;
    } else {
      throw Exception(responseData['message'] ?? 'Failed to update payment method');
    }
  }

  /// إلغاء طلب
  static Future<Map<String, dynamic>> cancelPermit(int permitId) async {
    final uri = Uri.parse('${AppConstants.apiBaseUrl}/security-permits/$permitId');
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.userTokenKey);

    if (token == null) {
      throw Exception('User is not authenticated.');
    }

    final response = await http.delete(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final responseData = json.decode(response.body);

    if (response.statusCode == 200 && responseData['status'] == true) {
      return responseData;
    } else {
      throw Exception(responseData['message'] ?? 'Failed to cancel permit');
    }
  }
}