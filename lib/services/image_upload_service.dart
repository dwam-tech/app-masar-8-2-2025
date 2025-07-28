// مسار الملف: lib/services/image_upload_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:saba2v2/services/auth_service.dart';
import 'package:http/http.dart' as http;

class ImageUploadService {
  final String _baseUrl = 'http://192.168.1.7:8000';
  final AuthService _authService = AuthService();

  /// ترفع ملف صورة إلى السيرفر وتعيد رابط الصورة كنص
  /// هذا الكود مبني على الدالة القوية التي أرسلتها
  Future<String> uploadImage(File imageFile) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('User is not authenticated. Cannot upload image.');
      }

      // المسار الصحيح كما هو مستنتج من الكود الذي أرسلته
      final uri = Uri.parse('$_baseUrl/api/upload');
      
      var request = http.MultipartRequest('POST', uri);

      // إضافة الهيدرز الضرورية
      request.headers['Authorization'] = 'Bearer $token'; // <-- هيدر التوثيق
      request.headers['Accept'] = 'application/json';

      // إضافة الملف بالاسم الصحيح للحقل
      // 'files[]' هو اسم الحقل الذي يتوقعه الـ Backend
      request.files.add(
        await http.MultipartFile.fromPath('files[]', imageFile.path)
      );

      // إرسال الطلب مع مهلة زمنية
      var streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      var response = await http.Response.fromStream(streamedResponse);

      // التحقق من نجاح الطلب
      if (response.statusCode != 200 && response.statusCode != 201) {
        debugPrint('Image Upload Error Body: ${response.body}');
        throw Exception('Failed to upload image. Status code: ${response.statusCode}');
      }

      // التحقق من نوع الاستجابة وتحليلها
      if (response.headers['content-type']?.contains('application/json') ?? false) {
        var jsonResponse = jsonDecode(response.body);

        // التحقق من حقل 'status' في الاستجابة
        if (jsonResponse['status'] == true) {
          // التحقق من وجود قائمة الملفات وأنها ليست فارغة
          if (jsonResponse['files'] != null && jsonResponse['files'] is List && jsonResponse['files'].isNotEmpty) {
            // إرجاع الرابط الأول من القائمة
            return jsonResponse['files'][0] as String;
          } else {
            throw Exception('API response is missing the "files" array.');
          }
        } else {
          throw Exception('API returned status false: ${jsonResponse['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Unexpected server response: Not a JSON content type.');
      }

    } on SocketException {
      // خطأ في الاتصال بالشبكة
      throw Exception('Network error: Please check your internet connection.');
    } on Exception catch (e) {
      // إعادة رمي الخطأ ليتم التقاطه في الـ Provider
      debugPrint('An exception occurred in ImageUploadService: $e');
      rethrow;
    }
  }
}