import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/featured_property.dart';

class PropertySearchService {
  static const String baseUrl = AppConstants.apiBaseUrl;

  /// البحث الذكي في العقارات
  static Future<Map<String, dynamic>> searchProperties({
    String? search,
    String? type,
    String? governorate,
    String? city,
    double? minPrice,
    double? maxPrice,
    int? bedrooms,
    int? bathrooms,
    double? minArea,
    double? maxArea,
    String? paymentMethod,
    String? view,
    bool? isReady,
    bool? theBest,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    int page = 1,
    int perPage = 15,
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
      
      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }
      
      if (governorate != null && governorate.isNotEmpty) {
        queryParams['governorate'] = governorate;
      }
      
      if (city != null && city.isNotEmpty) {
        queryParams['city'] = city;
      }
      
      if (minPrice != null) {
        queryParams['min_price'] = minPrice.toString();
      }
      
      if (maxPrice != null) {
        queryParams['max_price'] = maxPrice.toString();
      }
      
      if (bedrooms != null) {
        queryParams['bedrooms'] = bedrooms.toString();
      }
      
      if (bathrooms != null) {
        queryParams['bathrooms'] = bathrooms.toString();
      }
      
      if (minArea != null) {
        queryParams['min_area'] = minArea.toString();
      }
      
      if (maxArea != null) {
        queryParams['max_area'] = maxArea.toString();
      }
      
      if (paymentMethod != null && paymentMethod.isNotEmpty) {
        queryParams['payment_method'] = paymentMethod;
      }
      
      if (view != null && view.isNotEmpty) {
        queryParams['view'] = view;
      }
      
      if (isReady != null) {
        queryParams['is_ready'] = isReady ? '1' : '0';
      }
      
      if (theBest != null) {
        queryParams['the_best'] = theBest ? '1' : '0';
      }

      final uri = Uri.parse('$baseUrl/public-properties/search')
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
        
        // تحويل البيانات إلى قائمة من FeaturedProperty
        final List<FeaturedProperty> properties = [];
        if (data['data'] != null) {
          for (var item in data['data']) {
            try {
              properties.add(FeaturedProperty.fromJson(item));
            } catch (e) {
              print('Error parsing property: $e');
            }
          }
        }
        
        return {
          'success': true,
          'data': properties,
          'pagination': data['pagination'] ?? {},
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch properties',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error in property search: $e',
      };
    }
  }

  /// الحصول على جميع العقارات العامة (الطريقة الأساسية)
  static Future<List<FeaturedProperty>> getPublicProperties({
    bool? theBest,
    String? type,
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final Map<String, String> queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (theBest != null) {
        queryParams['the_best'] = theBest ? '1' : '0';
      }
      
      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }

      final uri = Uri.parse('$baseUrl/public-properties')
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
        
        final List<FeaturedProperty> properties = [];
        if (data['data'] != null) {
          for (var item in data['data']) {
            try {
              properties.add(FeaturedProperty.fromJson(item));
            } catch (e) {
              print('Error parsing property: $e');
            }
          }
        }
        
        return properties;
      }
      
      return [];
    } catch (e) {
      print('Error in get public properties: $e');
      return [];
    }
  }
}