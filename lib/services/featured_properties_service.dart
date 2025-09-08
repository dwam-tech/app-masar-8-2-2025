// lib/services/featured_properties_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/featured_property.dart';
import '../utils/constants.dart';

class FeaturedPropertiesService {
  static const String baseUrl = Constants.baseUrl;

  /// جلب العقارات المميزة
  /// [page] رقم الصفحة (افتراضي: 1)
  static Future<FeaturedPropertiesResponse> getFeaturedProperties({
    int page = 1,
  }) async {
    try {
      final query = <String, String>{
        'the_best': '1',
        if (page > 1) 'page': page.toString(),
      };

      final url = Uri.parse('$baseUrl/api/public-properties')
          .replace(queryParameters: query);

      print('🏠 جلب العقارات المميزة من: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('📊 استجابة العقارات المميزة: ${response.statusCode}');
      print('📄 محتوى الاستجابة: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return FeaturedPropertiesResponse.fromJson(jsonData);
      } else {
        throw Exception('فشل في جلب العقارات المميزة: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ خطأ في جلب العقارات المميزة: $e');
      throw Exception('خطأ في الاتصال بالخادم: $e');
    }
  }

  /// جلب المزيد من العقارات المميزة (للتحميل التدريجي)
  static Future<List<FeaturedProperty>> loadMoreFeaturedProperties({
    required int page,
  }) async {
    try {
      final response = await getFeaturedProperties(page: page);
      return response.data;
    } catch (e) {
      print('❌ خطأ في تحميل المزيد من العقارات: $e');
      return [];
    }
  }
}