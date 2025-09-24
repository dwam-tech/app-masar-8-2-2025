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
        
        // التحقق من وجود البيانات في التنسيق الصحيح
        if (jsonData is Map<String, dynamic> && jsonData.containsKey('data')) {
          return FeaturedPropertiesResponse.fromJson(jsonData);
        } else {
          // إذا كانت البيانات في تنسيق مختلف، نحاول التعامل معها
          final List<dynamic> propertiesData = jsonData is List ? jsonData : [];
          final List<FeaturedProperty> properties = [];
          
          for (var item in propertiesData) {
            try {
              properties.add(FeaturedProperty.fromJson(item as Map<String, dynamic>));
            } catch (e) {
              print('❌ خطأ في تحليل عقار: $e');
            }
          }
          
          return FeaturedPropertiesResponse(
            status: true,
            data: properties,
            links: PaginationLinks(
              first: null,
              last: null,
              prev: null,
              next: null,
            ),
            meta: PaginationMeta(
              currentPage: page,
              total: properties.length,
            ),
          );
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