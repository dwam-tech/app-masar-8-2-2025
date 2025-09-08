// مسار الملف: lib/services/laravel_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart'; // تمت إضافته من أجل debugPrint
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Base URL for the Laravel API
import '../config/constants.dart';

const String baseUrl = AppConstants.baseUrl;

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
      } else if (response.statusCode == 422 || response.statusCode == 400) {
        // معالجة أخطاء التحقق من البيانات المكررة
        String errorMessage = 'Registration failed';
        
        if (responseData['errors'] != null) {
          Map<String, dynamic> errors = responseData['errors'];
          List<String> errorMessages = [];
          
          if (errors['email'] != null) {
            errorMessages.add('البريد الإلكتروني مستخدم بالفعل');
          }
          if (errors['phone'] != null) {
            errorMessages.add('رقم الهاتف مستخدم بالفعل');
          }
          if (errors['name'] != null) {
            errorMessages.add('الاسم مستخدم بالفعل');
          }
          
          if (errorMessages.isNotEmpty) {
            errorMessage = errorMessages.join('\n');
          } else if (responseData['message'] != null) {
            errorMessage = responseData['message'];
          }
        } else if (responseData['message'] != null) {
          errorMessage = responseData['message'];
        }
        
        throw Exception(errorMessage);
      } else {
        // طباعة رسالة الخطأ من السيرفر
        debugPrint('API Validation Error (NormalUser): ${response.body}');
        throw Exception(responseData['message'] ?? 'Registration failed');
      }
    } catch (e) {
      // إذا كان الخطأ يحتوي على رسالة مخصصة، لا نضيف بادئة إضافية
      if (e.toString().contains('البريد الإلكتروني مستخدم بالفعل') || 
          e.toString().contains('رقم الهاتف مستخدم بالفعل') || 
          e.toString().contains('الاسم مستخدم بالفعل')) {
        rethrow;
      }
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
  }

  /// التحقق من رمز OTP للبريد الإلكتروني
  Future<Map<String, dynamic>> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final Map<String, String> body = {
        'email': email,
        'verification_code': otp,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/otp/verify-email'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'status': responseData['success'] ?? true,
          'message': responseData['message'] ?? 'تم التحقق من البريد الإلكتروني بنجاح',
        };
      } else {
        debugPrint('OTP Verification Error: ${response.body}');
        throw Exception(responseData['message'] ?? 'فشل في التحقق من الرمز');
      }
    } catch (e) {
      debugPrint('Network error during OTP verification: $e');
      throw Exception('خطأ في الشبكة أثناء التحقق من الرمز: $e');
    }
  }

  /// إعادة إرسال رمز OTP للبريد الإلكتروني
  Future<Map<String, dynamic>> resendEmailOtp({
    required String email,
  }) async {
    print('DEBUG LaravelService: resendEmailOtp called');
    print('DEBUG LaravelService: Email: "$email"');
    print('DEBUG LaravelService: API URL: $baseUrl/api/otp/resend-email-verification');
    
    try {
      final requestBody = {
        'email': email,
      };
      print('DEBUG LaravelService: Request body: $requestBody');
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/otp/resend-email-verification'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );
      
      print('DEBUG LaravelService: Resend response status: ${response.statusCode}');
      print('DEBUG LaravelService: Resend response body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'status': responseData['success'] ?? true,
          'message': responseData['message'] ?? 'تم إعادة إرسال رمز التحقق',
        };
      } else {
        debugPrint('OTP Resend Error: ${response.body}');
        throw Exception(responseData['message'] ?? 'فشل في إعادة إرسال الرمز');
      }
    } catch (e) {
      debugPrint('Network error during OTP resend: $e');
      throw Exception('خطأ في الشبكة أثناء إعادة إرسال الرمز: $e');
    }
  }

  // New: Send Password Reset OTP
  Future<Map<String, dynamic>> sendPasswordResetOtp({required String email}) async {
    print('DEBUG LaravelService: sendPasswordResetOtp called');
    print('DEBUG LaravelService: Email: "$email"');
    print('DEBUG LaravelService: API URL: $baseUrl/api/otp/send-password-reset');

    try {
      final requestBody = {
        'email': email,
      };
      print('DEBUG LaravelService: Request body: $requestBody');

      final response = await http.post(
        Uri.parse('$baseUrl/api/otp/send-password-reset'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('DEBUG LaravelService: sendPasswordResetOtp status: ${response.statusCode}');
      print('DEBUG LaravelService: sendPasswordResetOtp body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'status': responseData['success'] ?? true,
          'message': responseData['message'] ?? 'تم إرسال رمز إعادة التعيين بنجاح',
          'data': responseData,
        };
      } else if (response.statusCode == 422 || response.statusCode == 429) {
        return {
          'status': false,
          'message': responseData['message'] ?? 'تعذر إرسال رمز إعادة التعيين',
          'errors': responseData['errors'],
          'data': responseData,
        };
      } else {
        return {
          'status': false,
          'message': responseData['message'] ?? 'فشل إرسال رمز إعادة التعيين',
          'data': responseData,
        };
      }
    } catch (e) {
      debugPrint('sendPasswordResetOtp Error: $e');
      return {
        'status': false,
        'message': 'خطأ في الشبكة أثناء إرسال الرمز',
        'data': null,
      };
    }
  }

  // إضافة: إعادة تعيين كلمة المرور باستخدام رمز OTP
  Future<Map<String, dynamic>> resetPasswordWithOtp({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    print('DEBUG LaravelService: resetPasswordWithOtp called');
    print('DEBUG LaravelService: Email: "$email"');
    print('DEBUG LaravelService: OTP: "$otp"');
    print('DEBUG LaravelService: API URL: $baseUrl/api/otp/reset-password');

    try {
      final requestBody = {
        'email': email,
        'otp': otp,
        'password': password,
        'password_confirmation': passwordConfirmation,
      };
      print('DEBUG LaravelService: Request body: $requestBody');

      final response = await http.post(
        Uri.parse('$baseUrl/api/otp/reset-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('DEBUG LaravelService: resetPasswordWithOtp status: ${response.statusCode}');
      print('DEBUG LaravelService: resetPasswordWithOtp body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'status': responseData['success'] ?? true,
          'message': responseData['message'] ?? 'تم إعادة تعيين كلمة المرور بنجاح',
          'data': responseData,
        };
      } else if (response.statusCode == 422) {
        return {
          'status': false,
          'message': responseData['message'] ?? 'البيانات المدخلة غير صحيحة',
          'errors': responseData['errors'],
          'data': responseData,
        };
      } else {
        return {
          'status': false,
          'message': responseData['message'] ?? 'فشل في إعادة تعيين كلمة المرور',
          'data': responseData,
        };
      }
    } catch (e) {
      debugPrint('resetPasswordWithOtp Error: $e');
      return {
        'status': false,
        'message': 'خطأ في الشبكة أثناء إعادة تعيين كلمة المرور',
        'data': null,
      };
    }
  }

  // =============================
  // Helpers for token and storage
  // =============================

  /// جلب التوكن المخزن من SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// حفظ التوكن
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  /// حفظ بيانات المستخدم
  Future<void> _saveUserData(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(user));
  }

  /// تنفيذ تسجيل الخروج (ينظف التخزين المحلي ويحاول إبلاغ السيرفر)
  Future<void> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        final url = Uri.parse('$baseUrl/api/logout');
        await http.post(
          url,
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      }
    } catch (e) {
      debugPrint('Logout request error: $e');
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('user_data');
    }
  }

  // =============================
  // Static HTTP helpers (used across app)
  // =============================

  /// طلب GET عام مع Authorization Bearer Token
  static Future<Map<String, dynamic>> get(String path, {required String token}) async {
    final url = Uri.parse('$baseUrl/api$path');
    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final data = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'status': data['status'] ?? true,
          'message': data['message'],
          'data': data,
        };
      } else {
        return {
          'status': false,
          'message': data['message'] ?? 'فشل الطلب',
          'data': data,
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'خطأ في الشبكة: $e',
        'data': null,
      };
    }
  }

  /// طلب POST عام مع Authorization Bearer Token
  static Future<Map<String, dynamic>> post(
    String path, {
    required String token,
    Map<String, dynamic>? data,
  }) async {
    final url = Uri.parse('$baseUrl/api$path');
    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data ?? {}),
      );
      final res = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'status': res['status'] ?? true,
          'message': res['message'],
          'data': res,
        };
      } else {
        return {
          'status': false,
          'message': res['message'] ?? 'فشل الطلب',
          'data': res,
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'خطأ في الشبكة: $e',
        'data': null,
      };
    }
  }

  /// جلب بيانات المستخدم المخزنة محليًا
  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('user_data');
    if (data == null) return null;
    try {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (_) {
      return null;
    }
  }
}