// lib/services/public_properties_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/featured_property.dart';
import '../utils/constants.dart';

class PublicPropertiesService {
  static const String baseUrl = Constants.baseUrl;

  /// جلب جميع العقارات العامة
  /// [page] رقم الصفحة (افتراضي: 1)
  static Future<FeaturedPropertiesResponse> getAllPublicProperties({
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
        return FeaturedPropertiesResponse.fromJson(jsonData);
      } else {
        throw Exception('فشل في جلب العقارات العامة: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ خطأ في جلب العقارات العامة: $e');
      throw Exception('خطأ في الاتصال بالخادم: $e');
    }
  }

  /// جلب المزيد من العقارات العامة (للتحميل التدريجي)
  static Future<List<FeaturedProperty>> loadMorePublicProperties({
    required int page,
  }) async {
    try {
      final response = await getAllPublicProperties(page: page);
      return response.data;
    } catch (e) {
      print('❌ خطأ في تحميل المزيد من العقارات العامة: $e');
      return [];
    }
  }
}