import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class MenuSearchService {
  static const String baseUrl = ApiConfig.baseUrl;

  /// البحث السريع في الوجبات بالأحرف الأولى
  static Future<List<Map<String, dynamic>>> quickSearchMenuItems({
    required String search,
    int? restaurantId,
  }) async {
    try {
      final Map<String, String> queryParams = {
        'search': search,
      };
      
      if (restaurantId != null) {
        queryParams['restaurant_id'] = restaurantId.toString();
      }

      final uri = Uri.parse('$baseUrl/menu-items/quick-search')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['data'] ?? []);
        }
      }
      
      return [];
    } catch (e) {
      print('Error in quick search menu items: $e');
      return [];
    }
  }

  /// البحث المتقدم في الوجبات
  static Future<Map<String, dynamic>> searchMenuItems({
    String? search,
    int? restaurantId,
    int? sectionId,
    double? minPrice,
    double? maxPrice,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final Map<String, String> queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
        'sort_by': sortBy,
        'sort_order': sortOrder,
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      
      if (restaurantId != null) {
        queryParams['restaurant_id'] = restaurantId.toString();
      }
      
      if (sectionId != null) {
        queryParams['section_id'] = sectionId.toString();
      }
      
      if (minPrice != null) {
        queryParams['min_price'] = minPrice.toString();
      }
      
      if (maxPrice != null) {
        queryParams['max_price'] = maxPrice.toString();
      }

      final uri = Uri.parse('$baseUrl/menu-items/search')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return {
            'success': true,
            'data': data['data']['data'] ?? [],
            'pagination': {
              'current_page': data['data']['current_page'] ?? 1,
              'last_page': data['data']['last_page'] ?? 1,
              'per_page': data['data']['per_page'] ?? perPage,
              'total': data['data']['total'] ?? 0,
            }
          };
        }
      }
      
      return {
        'success': false,
        'data': [],
        'pagination': {
          'current_page': 1,
          'last_page': 1,
          'per_page': perPage,
          'total': 0,
        }
      };
    } catch (e) {
      print('Error in search menu items: $e');
      return {
        'success': false,
        'data': [],
        'pagination': {
          'current_page': 1,
          'last_page': 1,
          'per_page': perPage,
          'total': 0,
        }
      };
    }
  }
}