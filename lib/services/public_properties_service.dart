// lib/services/public_properties_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/public_property.dart';
import '../utils/constants.dart';

class PublicPropertiesService {
  static const String baseUrl = Constants.baseUrl;

  /// جلب جميع العقارات العامة
  /// [page] رقم الصفحة (افتراضي: 1)
  static Future<List<PublicProperty>> getAllPublicProperties({
    int page = 1,
  }) async {
    try {
      final query = <String, String>{
        if (page > 1) 'page': page.toString(),
      };

      final url = Uri.parse('$baseUrl/api/public-properties')
          .replace(queryParameters: query);

      print('🏠 جلب جميع العقارات العامة من: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('📊 استجابة العقارات العامة: ${response.statusCode}');
      print('📄 محتوى الاستجابة: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        // التحقق من وجود البيانات في التنسيق الصحيح
        if (jsonData is Map<String, dynamic> && jsonData.containsKey('data')) {
          final List<dynamic> propertiesData = jsonData['data'] as List<dynamic>;
          final List<PublicProperty> properties = [];
          
          for (var item in propertiesData) {
            try {
              properties.add(PublicProperty.fromJson(item as Map<String, dynamic>));
            } catch (e) {
              print('❌ خطأ في تحويل العقار: $e');
            }
          }
          
          return properties;
        } else {
          // إذا كانت البيانات في تنسيق مختلف، نحاول التعامل معها
          final List<dynamic> propertiesData = jsonData is List ? jsonData : [];
          final List<PublicProperty> properties = [];
          
          for (var item in propertiesData) {
            try {
              properties.add(PublicProperty.fromJson(item as Map<String, dynamic>));
            } catch (e) {
              print('❌ خطأ في تحليل عقار: $e');
            }
          }
          
          return properties;
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'فشل في جلب العقارات العامة: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ خطأ في جلب العقارات العامة: $e');
      throw Exception('خطأ في الاتصال بالخادم: $e');
    }
  }

  /// جلب المزيد من العقارات العامة (للتحميل التدريجي)
  static Future<List<PublicProperty>> loadMorePublicProperties({
    required int page,
  }) async {
    try {
      final response = await getAllPublicProperties(page: page);
      return response;
    } catch (e) {
      print('❌ خطأ في تحميل المزيد من العقارات العامة: $e');
      return [];
    }
  }
}