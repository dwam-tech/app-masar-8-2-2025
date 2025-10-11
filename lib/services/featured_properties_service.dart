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
        'page': page.toString(),
      };

      final url = Uri.parse('$baseUrl/api/properties/featured')
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

        // التنسيق الرسمي من لارافيل: { status, properties: [], pagination: { current_page, last_page, per_page, total } }
        if (jsonData is Map<String, dynamic> && jsonData.containsKey('properties')) {
          final List<dynamic> propertiesData = jsonData['properties'] as List<dynamic>? ?? [];
          final List<FeaturedProperty> properties = propertiesData
              .map((item) => FeaturedProperty.fromJson(item as Map<String, dynamic>))
              .toList();

          final pagination = (jsonData['pagination'] as Map<String, dynamic>? ?? {});

          return FeaturedPropertiesResponse(
            status: jsonData['status'] == true,
            data: properties,
            links: PaginationLinks(
              first: null,
              last: null,
              prev: null,
              next: (pagination['current_page'] ?? 1) < (pagination['last_page'] ?? 1)
                  ? '$baseUrl/api/properties/featured?page=${(pagination['current_page'] ?? 1) + 1}'
                  : null,
            ),
            meta: PaginationMeta(
              currentPage: pagination['current_page'] ?? page,
              lastPage: pagination['last_page'] ?? 1,
              perPage: pagination['per_page'] ?? 20,
              total: pagination['total'] ?? properties.length,
            ),
          );
        }

        // دعم تنسيقات بديلة تاريخية { data, links, meta } أو قائمة مباشرة
        if (jsonData is Map<String, dynamic> && jsonData.containsKey('data')) {
          return FeaturedPropertiesResponse.fromJson(jsonData);
        }

        // تنسيق احتياطي إذا كانت الاستجابة قائمة مباشرة
        final List<dynamic> propertiesData = jsonData is List ? jsonData : [];
        final List<FeaturedProperty> properties = [];
        for (var item in propertiesData) {
          try {
            properties.add(FeaturedProperty.fromJson(item as Map<String, dynamic>));
          } catch (e) {
            print('❌ خطأ في تحليل عقار مميز: $e');
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
            lastPage: 1,
            perPage: properties.length,
            total: properties.length,
          ),
        );
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'فشل في جلب العقارات المميزة: ${response.statusCode}');
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