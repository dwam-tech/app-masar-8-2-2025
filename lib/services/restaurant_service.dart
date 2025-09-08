import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:saba2v2/services/auth_service.dart';
import 'package:saba2v2/models/public_restaurant.dart';
import 'package:saba2v2/models/MenuSection.dart';
import '../config/constants.dart';

class RestaurantService {
  final String _baseUrl = AppConstants.apiBaseUrl;
  final AuthService _authService = AuthService();

  /// جلب أفضل المطاعم المعتمدة
  Future<Map<String, dynamic>> getBestRestaurants({int page = 1}) async {
    print('🔍 [RestaurantService] Starting getBestRestaurants - Page: $page');
    
    final uri = Uri.parse('$_baseUrl/public-restaurants').replace(
      queryParameters: {
        'the_best': '1',
        if (page > 1) 'page': page.toString(),
      },
    );

    print('🌐 [RestaurantService] API URL: $uri');
    print('📤 [RestaurantService] Request Headers: Accept: application/json, Content-Type: application/json');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      print('📥 [RestaurantService] Response Status Code: ${response.statusCode}');
      print('📥 [RestaurantService] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('✅ [RestaurantService] JSON Decoded Successfully');
        print('📊 [RestaurantService] Response Data Keys: ${responseData.keys.toList()}');
        
        // Check if response has data field (successful response structure)
        if (responseData.containsKey('data')) {
          print('✅ [RestaurantService] API Response: Success');
          print('📊 [RestaurantService] Data Count: ${responseData['data']?.length ?? 0}');
          return responseData;
        } else if (responseData['status'] == false) {
          // Handle error response with status field
          print('❌ [RestaurantService] API Status: Failed - ${responseData['message']}');
          throw Exception(responseData['message'] ?? 'Failed to parse best restaurants.');
        } else {
          // Handle unexpected response structure
          print('❌ [RestaurantService] Unexpected response structure');
          throw Exception('Unexpected response structure from API.');
        }
      } else {
        print('❌ [RestaurantService] HTTP Error: ${response.statusCode}');
        print('❌ [RestaurantService] Error Body: ${response.body}');
        throw Exception('Failed to load best restaurants. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 [RestaurantService] Exception: $e');
      rethrow;
    }
  }

  /// جلب جميع المطاعم المتاحة
  Future<Map<String, dynamic>> getAllRestaurants({int page = 1}) async {
    print('🔍 [RestaurantService] Starting getAllRestaurants - Page: $page');
    
    final uri = Uri.parse('$_baseUrl/public-restaurants').replace(
      queryParameters: {
        if (page > 1) 'page': page.toString(),
      },
    );

    print('🌐 [RestaurantService] API URL: $uri');
    print('📤 [RestaurantService] Request Headers: Accept: application/json, Content-Type: application/json');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      print('📥 [RestaurantService] Response Status Code: ${response.statusCode}');
      print('📥 [RestaurantService] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('✅ [RestaurantService] JSON Decoded Successfully');
        print('📊 [RestaurantService] Response Data Keys: ${responseData.keys.toList()}');
        
        // Check if response has data field (successful response structure)
        if (responseData.containsKey('data')) {
          print('✅ [RestaurantService] API Response: Success');
          print('📊 [RestaurantService] Data Count: ${responseData['data']?.length ?? 0}');
          return responseData;
        } else if (responseData['status'] == false) {
          // Handle error response with status field
          print('❌ [RestaurantService] API Status: Failed - ${responseData['message']}');
          throw Exception(responseData['message'] ?? 'Failed to parse restaurants.');
        } else {
          // Handle unexpected response structure
          print('❌ [RestaurantService] Unexpected response structure');
          throw Exception('Unexpected response structure from API.');
        }
      } else {
        print('❌ [RestaurantService] HTTP Error: ${response.statusCode}');
        print('❌ [RestaurantService] Error Body: ${response.body}');
        throw Exception('Failed to load restaurants. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 [RestaurantService] Exception: $e');
      rethrow;
    }
  }

  /// جلب تفاصيل المطعم المسجل دخوله حاليًا
  /// ملاحظة: لم نعد بحاجة لـ restaurantId لأن الـ API يحدد المطعم من التوكن
  Future<Map<String, dynamic>> getRestaurantDetails() async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('User is not authenticated.');
    }

    final uri = Uri.parse('$_baseUrl/user');
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['status'] == true && responseData['data'] != null) {
        // الـ API يعيد بيانات المستخدم وبداخلها restaurantDetail
        return responseData['data'] as Map<String, dynamic>;
      } else {
        throw Exception(responseData['message'] ?? 'Failed to parse restaurant details.');
      }
    } else {
      // التعامل مع أخطاء مثل 403 (غير مصرح)
      throw Exception('Failed to load restaurant details. Status: ${response.statusCode}');
    }
  }

  /// تحديث تفاصيل المطعم المسجل دخوله حاليًا
  Future<Map<String, dynamic>> updateRestaurantDetails(Map<String, dynamic> data) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('User is not authenticated.');
    }

    final uri = Uri.parse('$_baseUrl/users/4');
    final response = await http.put(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );

    // الرد إما يكون ناجحًا أو يحتوي على رسائل خطأ
    final responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      if (responseData['status'] == true) {
        return responseData; // {"status": true, "message": "...", "data": {...}}
      } else {
        // حالة نجاح 200 ولكن status: false
        throw Exception(responseData['message'] ?? 'An unknown error occurred.');
      }
    } else {
      // التعامل مع أخطاء التحقق 422 أو أخطاء الخادم الأخرى
      throw Exception(responseData['message'] ?? 'Failed to update details. Status: ${response.statusCode}');
    }
  }

  /// جلب تفاصيل مطعم واحد للعرض العام
  Future<PublicRestaurant> getPublicRestaurantById(String restaurantId) async {
    print('🔍 [RestaurantService] Starting getPublicRestaurantById - ID: $restaurantId');
    
    final uri = Uri.parse('$_baseUrl/public-restaurants/$restaurantId');

    print('🌐 [RestaurantService] API URL: $uri');
    print('📤 [RestaurantService] Request Headers: Accept: application/json, Content-Type: application/json');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      print('📥 [RestaurantService] Response Status Code: ${response.statusCode}');
      print('📥 [RestaurantService] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('✅ [RestaurantService] JSON Decoded Successfully');
        print('📊 [RestaurantService] Response Data Keys: ${responseData.keys.toList()}');
        
        // Check if response has data field (successful response structure)
        if (responseData.containsKey('data') && responseData['status'] == true) {
          print('✅ [RestaurantService] API Response: Success');
          return PublicRestaurant.fromJson(responseData['data']);
        } else if (responseData['status'] == false) {
          // Handle error response with status field
          print('❌ [RestaurantService] API Status: Failed - ${responseData['message']}');
          throw Exception(responseData['message'] ?? 'Failed to load restaurant details.');
        } else {
          // Handle unexpected response structure
          print('❌ [RestaurantService] Unexpected response structure');
          throw Exception('Unexpected response structure from API.');
        }
      } else if (response.statusCode == 404) {
        print('❌ [RestaurantService] Restaurant not found');
        final responseData = json.decode(response.body);
        throw Exception(responseData['message'] ?? 'Restaurant not found or not approved.');
      } else {
        print('❌ [RestaurantService] HTTP Error: ${response.statusCode}');
        print('❌ [RestaurantService] Error Body: ${response.body}');
        throw Exception('Failed to load restaurant details. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 [RestaurantService] Exception: $e');
      rethrow;
    }
  }

  /// جلب قائمة الطعام لمطعم معين
  Future<List<MenuSection>> getRestaurantMenuSections(String restaurantId) async {
    print('🔍 [RestaurantService] Starting getRestaurantMenuSections - ID: $restaurantId');
    
    // استخدام الـ endpoint الصحيح الذي اختبرته في Postman
    final uri = Uri.parse('$_baseUrl/restaurants/$restaurantId/menu-sections');

    print('🌐 [RestaurantService] API URL: $uri');
    print('📤 [RestaurantService] Request Headers: Accept: application/json, Content-Type: application/json');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      print('📥 [RestaurantService] Response Status Code: ${response.statusCode}');
      print('📥 [RestaurantService] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('✅ [RestaurantService] JSON Decoded Successfully');
        print('📊 [RestaurantService] Response Data Keys: ${responseData.keys.toList()}');
        
        // Check if response has sections field (successful response structure)
        if (responseData.containsKey('sections') && responseData['status'] == true) {
          print('✅ [RestaurantService] API Response: Success');
          final sectionsData = responseData['sections'] as List;
          print('📊 [RestaurantService] Sections Count: ${sectionsData.length}');
          
          return sectionsData.map((section) => MenuSection.fromJson(section)).toList();
        } else if (responseData['status'] == false) {
          // Handle error response with status field
          print('❌ [RestaurantService] API Status: Failed - ${responseData['message']}');
          throw Exception(responseData['message'] ?? 'Failed to load restaurant menu.');
        } else {
          // Handle unexpected response structure
          print('❌ [RestaurantService] Unexpected response structure');
          throw Exception('Unexpected response structure from API.');
        }
      } else if (response.statusCode == 404) {
        print('❌ [RestaurantService] Menu not found');
        final responseData = json.decode(response.body);
        throw Exception(responseData['message'] ?? 'Menu not found for this restaurant.');
      } else {
        print('❌ [RestaurantService] HTTP Error: ${response.statusCode}');
        print('❌ [RestaurantService] Error Body: ${response.body}');
        throw Exception('Failed to load restaurant menu. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 [RestaurantService] Exception: $e');
      rethrow;
    }
  }

  /// جلب جميع أقسام القوائم المتاحة (Menu Sections)
  Future<List<String>> getAllMenuSections() async {
    print('🔍 [RestaurantService] Starting getAllMenuSections');
    final uri = Uri.parse('$_baseUrl/public-menu-sections');
    print('🌐 [RestaurantService] API URL: $uri');
    try {
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );
      print('📥 [RestaurantService] Response Status Code: \${response.statusCode}');
      print('📥 [RestaurantService] Response Body: \${response.body}');
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == true && responseData['data'] != null) {
          final List<String> sections = List<String>.from(responseData['data']);
          print('✅ [RestaurantService] Sections: \$sections');
          return sections;
        } else {
          throw Exception(responseData['message'] ?? 'Failed to load menu sections.');
        }
      } else {
        throw Exception('Failed to load menu sections. Status: \${response.statusCode}');
      }
    } catch (e) {
      print('💥 [RestaurantService] Exception: \$e');
      rethrow;
    }
  }

  /// جلب المطاعم مع فلترة حسب قسم القائمة (Menu Section)
  Future<Map<String, dynamic>> getRestaurantsByMenuSection(String menuSection, {int page = 1}) async {
    print('🔍 [RestaurantService] Starting getRestaurantsByMenuSection - Section: $menuSection, Page: $page');
    final uri = Uri.parse('$_baseUrl/public-restaurants').replace(
      queryParameters: {
        'menu_section': menuSection,
        if (page > 1) 'page': page.toString(),
      },
    );
    print('🌐 [RestaurantService] API URL: $uri');
    try {
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );
      print('📥 [RestaurantService] Response Status Code: \${response.statusCode}');
      print('📥 [RestaurantService] Response Body: \${response.body}');
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData.containsKey('data')) {
          print('✅ [RestaurantService] API Response: Success');
          return responseData;
        } else {
          throw Exception(responseData['message'] ?? 'Failed to load filtered restaurants.');
        }
      } else {
        throw Exception('Failed to load filtered restaurants. Status: \${response.statusCode}');
      }
    } catch (e) {
      print('💥 [RestaurantService] Exception: \$e');
      rethrow;
    }
  }
}