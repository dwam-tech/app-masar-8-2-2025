// مسار الملف: lib/services/laravel_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart'; // تمت إضافته من أجل debugPrint
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Base URL for the Laravel API
const String baseUrl = 'http://192.168.1.8:8000';

class LaravelService {

  Future<Map<String, dynamic>> registerNormalUser({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String governorate,
    required String userType,
  }) async {
    try {
      final Map<String, String> body = {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'governorate': governorate,
        'user_type': userType,
        'is_approved': "1"
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/register'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['user'] != null && responseData['user']['token'] != null) {
          await _saveToken(responseData['user']['token']);
        }
        return {
          'status': responseData['status'] ?? true,
          'message': responseData['message'] ?? 'Registration successful',
          'user': responseData['user'],
        };
      } else {
        // طباعة رسالة الخطأ من السيرفر
        debugPrint('API Validation Error (NormalUser): ${response.body}');
        throw Exception(responseData['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Error during registration: $e');
    }
  }

  // --- هذه هي الدالة المعدلة ---
  Future<Map<String, dynamic>> registerRealstateOffice({
    required String username,
    required String email,
    required String password,
    required String phone,
    required String city,
    required String address,
    required bool vat,
    required String officeLogoPath,
    required String ownerIdFrontPath,
    required String ownerIdBackPath,
    required String officeImagePath,
    required String commercialCardFrontPath,
    required String commercialCardBackPath,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'name': username,
        'email': email,
        'password': password,
        'phone': phone,
        'governorate': city,
        'user_type': 'real_estate_office',
        'office_name': username,
        'office_address': address,
        'office_phone': phone,
        'logo_image': officeLogoPath,
        'owner_id_front_image': ownerIdFrontPath,
        'owner_id_back_image': ownerIdBackPath,
        'office_image': officeImagePath,
        'commercial_register_front_image': commercialCardFrontPath,
        'commercial_register_back_image': commercialCardBackPath,
        'tax_enabled': vat,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/register'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['user'] != null && responseData['user']['token'] != null) {
          await _saveToken(responseData['user']['token']);
        }
        return {
          'status': responseData['status'] ?? true,
          'message': responseData['message'] ?? 'Registration successful',
          'user': responseData['user'],
        };
      } else {
        // <<<<<<<<<<<<<<<< هذا هو التعديل الأهم >>>>>>>>>>>>>>>>
        // هذا السطر سيطبع لك "فاتورة الأخطاء" من السيرفر
        debugPrint('API Validation Error (RealstateOffice): ${response.body}');
        throw Exception(responseData['message'] ?? 'Registration failed');
      }
    } catch (e) {
      // طباعة أي أخطاء أخرى (مثل أخطاء الشبكة)
      debugPrint('A NETWORK or CONNECTION error occurred in registerRealstateOffice: $e');
      throw Exception('Error during registration: $e');
    }
  }

  Future<Map<String, dynamic>> login({
    required String email, // تم تحديثه ليكون email بدلاً من identifier
    required String password,
  }) async {
    try {
      final Map<String, String> body = {
        'email': email,
        'password': password,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        
        // التحقق من وجود التوكن وبيانات المستخدم قبل الحفظ
        if (responseData['token'] != null && responseData['user'] != null) {
          await _saveToken(responseData['token']);
          await _saveUserData(responseData['user']);
        }
        
        return {
          'status': responseData['status'] ?? true,
          'message': responseData['message'] ?? 'Login successful',
          'user': responseData['user'],
        };
      } else {
        // طباعة رسالة الخطأ التفصيلية من السيرفر
        debugPrint('API Login Error: ${response.body}');
        final responseData = jsonDecode(response.body);
        throw Exception(responseData['message'] ?? 'Login failed');
      }
    } catch (e) {
      debugPrint('A NETWORK or CONNECTION error occurred during login: $e');
      throw Exception('Error during login: $e');
    }
  

  // ... (باقي الدوال مثل _saveToken, _saveUserData, etc.)
}
 
 
 
 Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    try {
      await http.post(
        Uri.parse('$baseUrl/api/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      await prefs.remove('token');
      await prefs.remove('user_data');
    } catch (e) {
      // حتى لو فشل الطلب، قم بتسجيل الخروج محليًا
      await prefs.remove('token');
      await prefs.remove('user_data');
      throw Exception('Error during logout: $e');
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(userData));
  }
  
  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');
    return userDataString != null ? jsonDecode(userDataString) : null;
  }
}