import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:saba2v2/models/order_model.dart';
import 'package:saba2v2/services/auth_service.dart';
import '../config/constants.dart';

class OrderService {
  final String _baseUrl = AppConstants.baseUrl;
  final AuthService _authService = AuthService();

  /// جلب جميع الطلبات
  Future<List<OrderModel>> getOrders() async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('User not authenticated.');

    final uri = Uri.parse('$_baseUrl/api/orders');
    debugPrint("OrderService: Fetching orders from $uri");

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    debugPrint("OrderService: Response status: ${response.statusCode}");
    debugPrint("OrderService: Response body: ${response.body}");

    if (response.statusCode == 200) {
      try {
        final responseData = jsonDecode(response.body);
        final List<dynamic> ordersJson = responseData['orders'] ?? [];

        debugPrint(
            "OrderService: Successfully fetched ${ordersJson.length} orders.");
        return ordersJson.map((json) => OrderModel.fromJson(json)).toList();
      } catch (e) {
        debugPrint("OrderService: JSON parsing error: $e");
        throw Exception('خطأ في تحليل استجابة الخادم: ${e.toString()}');
      }
    } else {
      debugPrint(
          "API ERROR (getOrders): Status ${response.statusCode}, Body: ${response.body}");

      String errorMessage = 'فشل في جلب الطلبات';

      if (response.headers['content-type']?.contains('application/json') ==
          true) {
        try {
          final errorBody = jsonDecode(response.body);
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (e) {
          debugPrint("OrderService: Error parsing error response: $e");
        }
      } else {
        if (response.body.contains('<!DOCTYPE html>')) {
          errorMessage =
              'الخادم أرجع صفحة HTML بدلاً من JSON. تحقق من الـ URL والتوثيق.';
        }
      }

      throw Exception(
          'خطأ في جلب الطلبات (${response.statusCode}): $errorMessage');
    }
  }

  /// جلب طلبات المطعم المحدد مع إمكانية التصفية حسب الحالة
  Future<List<OrderModel>> getRestaurantOrders({String? status}) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('User not authenticated.');

    var uri = Uri.parse('$_baseUrl/api/restaurant/orders');
    if (status != null) {
      uri = uri.replace(queryParameters: {'status': status});
    }

    debugPrint("OrderService: Fetching restaurant orders from $uri");

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    debugPrint("OrderService: Response status: ${response.statusCode}");
    debugPrint("OrderService: Response body: ${response.body}");

    if (response.statusCode == 200) {
      try {
        final responseData = jsonDecode(response.body);
        final List<dynamic> ordersJson = responseData['orders'] ?? [];

        debugPrint(
            "OrderService: Successfully fetched ${ordersJson.length} restaurant orders.");
        return ordersJson.map((json) => OrderModel.fromJson(json)).toList();
      } catch (e) {
        debugPrint("OrderService: JSON parsing error: $e");
        throw Exception('خطأ في تحليل استجابة الخادم: ${e.toString()}');
      }
    } else {
      debugPrint(
          "API ERROR (getRestaurantOrders): Status ${response.statusCode}, Body: ${response.body}");

      String errorMessage = 'فشل في جلب طلبات المطعم';

      if (response.headers['content-type']?.contains('application/json') ==
          true) {
        try {
          final errorBody = jsonDecode(response.body);
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (e) {
          debugPrint("OrderService: Error parsing error response: $e");
        }
      } else {
        if (response.body.contains('<!DOCTYPE html>')) {
          errorMessage =
              'الخادم أرجع صفحة HTML بدلاً من JSON. تحقق من الـ URL والتوثيق.';
        }
      }

      throw Exception(
          'خطأ في جلب طلبات المطعم (${response.statusCode}): $errorMessage');
    }
  }

  /// جلب تفاصيل طلب واحد (حل بديل - استخراج من قائمة الطلبات)
  Future<OrderModel> getOrderById(int orderId) async {
    debugPrint("OrderService: Fetching order details for order $orderId using alternative method");
    
    try {
      // 🔄 الحل البديل: جلب جميع الطلبات والبحث عن الطلب المطلوب
      final allOrders = await getRestaurantOrders();
      
      // البحث عن الطلب المطلوب في القائمة
      final targetOrder = allOrders.firstWhere(
        (order) => order.id == orderId,
        orElse: () => throw Exception('الطلب رقم $orderId غير موجود'),
      );
      
      debugPrint("OrderService: Successfully found order $orderId in orders list");
      return targetOrder;
      
    } catch (e) {
      debugPrint("OrderService: Error fetching order $orderId: $e");
      
      // إذا فشل الحل البديل، جرب الـ endpoint الأصلي كمحاولة أخيرة
      debugPrint("OrderService: Trying direct endpoint as fallback...");
      
      final token = await _authService.getToken();
      if (token == null) throw Exception('User not authenticated.');

      // جرب endpoints مختلفة محتملة
      final possibleEndpoints = [
        '$_baseUrl/api/orders/$orderId',
        '$_baseUrl/api/restaurant/order/$orderId',
        '$_baseUrl/api/order/$orderId',
      ];
      
      for (String endpoint in possibleEndpoints) {
        try {
          debugPrint("OrderService: Trying endpoint: $endpoint");
          
          final uri = Uri.parse(endpoint);
          final response = await http.get(
            uri,
            headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
          );

          debugPrint("OrderService: Response status: ${response.statusCode}");
          
          if (response.statusCode == 200) {
            final responseData = jsonDecode(response.body);
            
            if (responseData['status'] == true && responseData['order'] != null) {
              debugPrint("OrderService: Successfully fetched order $orderId from $endpoint");
              return OrderModel.fromJson(responseData['order']);
            }
          }
        } catch (endpointError) {
          debugPrint("OrderService: Endpoint $endpoint failed: $endpointError");
          continue; // جرب الـ endpoint التالي
        }
      }
      
      // إذا فشلت جميع المحاولات
      throw Exception('فشل في جلب تفاصيل الطلب $orderId. الطلب غير موجود أو الـ API غير متاح.');
    }
  }

  /// [النسخة التشخيصية] بدء معالجة الطلب
  Future<OrderModel> startProcessingOrder(int orderId) async {
    // ==========================================================
    //                ▼▼▼ START OF DEBUG BLOCK ▼▼▼
    // ==========================================================
    
    final token = await _authService.getToken();

    print('--- 🕵️‍♂️ ADVANCED DEBUG: Preparing to Process Order 🕵️‍♂️ ---');
    
    if (token == null) {
      print('❌ FATAL: Token is NULL. Cannot proceed.');
      throw Exception('User not authenticated.');
    }

    final uri = Uri.parse('$_baseUrl/api/restaurant/orders/$orderId/process');
    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    // طباعة كل معلومة على حدة لمقارنتها بـ Postman
    print('   1. Order ID   : $orderId');
    print('   2. HTTP Method: POST');
    print('   3. Full URL   : $uri');
    print('   4. Token Used : Bearer ${token.substring(0, 15)}... (partial for security)');
    print('   5. Headers Sent: $headers');
    print('---------------------------------------------------------');

    // ==========================================================
    //                ▲▲▲  END OF DEBUG BLOCK  ▲▲▲
    // ==========================================================
    
    try {
      final response = await http.post(uri, headers: headers);

      print('✅ RESPONSE RECEIVED:');
      print('   - Status Code: ${response.statusCode}');
      print('   - Response Body: ${response.body.substring(0, response.body.length > 300 ? 300 : response.body.length)}...'); // Print first 300 chars

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == true && responseData['order'] != null) {
          return OrderModel.fromJson(responseData['order']);
        } else {
          throw Exception('API returned success but data was malformed.');
        }
      } else {
        // حاول تحليل رسالة الخطأ من الـ JSON إذا أمكن
        try {
          final errorBody = jsonDecode(response.body);
          throw Exception(errorBody['message'] ?? 'Failed with status code ${response.statusCode}');
        } catch(_) {
          // إذا فشل تحليل الـ JSON (لأنه HTML مثلاً)
          throw Exception('Request failed with status code ${response.statusCode}. Response is not valid JSON.');
        }
      }
    } catch(e) {
      print('❌ EXCEPTION CAUGHT during API call: ${e.toString()}');
      rethrow; // أعد إطلاق الخطأ ليتم التعامل معه في الـ Provider
    }
  }

  /// إكمال الطلب (النسخة المصححة)
  Future<OrderModel> completeOrder(int orderId) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('User not authenticated.');

    final uri = Uri.parse('$_baseUrl/api/restaurant/orders/$orderId/complete');
    debugPrint("OrderService: Completing order $orderId at URL: $uri");

    final response = await http.post(
      uri,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    debugPrint("OrderService: Response status: ${response.statusCode}");
    debugPrint("OrderService: Response headers: ${response.headers}");
    debugPrint("OrderService: Response body: ${response.body}");

    if (response.statusCode == 200) {
      try {
        final responseData = jsonDecode(response.body);

        if (responseData['status'] == true && responseData['order'] != null) {
          debugPrint("OrderService: Successfully completed order $orderId");
          return OrderModel.fromJson(responseData['order']);
        } else {
          throw Exception(
              'API returned success but order data is missing in the response.');
        }
      } catch (e) {
        debugPrint("OrderService: JSON parsing error: $e");
        throw Exception('خطأ في تحليل استجابة الخادم: ${e.toString()}');
      }
    } else {
      debugPrint(
          "API ERROR (completeOrder): Status ${response.statusCode}, Body: ${response.body}");

      String errorMessage = 'فشل في إكمال الطلب';

      if (response.headers['content-type']?.contains('application/json') ==
          true) {
        try {
          final errorBody = jsonDecode(response.body);
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (e) {
          debugPrint("OrderService: Error parsing error response: $e");
        }
      } else {
        if (response.body.contains('<!DOCTYPE html>')) {
          errorMessage =
              'الخادم أرجع صفحة HTML بدلاً من JSON. تحقق من الـ URL والتوثيق.';
        }
      }

      throw Exception(
          'خطأ في إكمال الطلب (${response.statusCode}): $errorMessage');
    }
  }

   Future<Map<String, dynamic>> createOrder({
    required int restaurantId,
    required List<Map<String, dynamic>> items,
    required String deliveryAddress,
    String? notes,
  }) async {
    print('🛒 [OrderService] بدء إنشاء طلب جديد للمطعم: $restaurantId');
    
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('المستخدم غير مسجل الدخول');
    }

    final uri = Uri.parse('$_baseUrl/api/orders');
    final requestBody = {
      'restaurant_id': restaurantId,
      'items': items,
      'delivery_address': deliveryAddress,
      'notes': notes ?? '',
    };

    print('🛒 [OrderService] URL: $uri');
    print('🛒 [OrderService] Request Body: ${jsonEncode(requestBody)}');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('🛒 [OrderService] Response Status: ${response.statusCode}');
      print('🛒 [OrderService] Response Body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['status'] == true) {
          print('✅ [OrderService] تم إنشاء الطلب بنجاح');
          return responseData;
        } else {
          throw Exception(responseData['message'] ?? 'فشل في إنشاء الطلب');
        }
      } else if (response.statusCode == 422) {
        // خطأ في التحقق من صحة البيانات
        final errors = responseData['errors'] ?? {};
        final errorMessages = <String>[];
        
        errors.forEach((field, messages) {
          if (messages is List) {
            errorMessages.addAll(messages.cast<String>());
          } else {
            errorMessages.add(messages.toString());
          }
        });
        
        throw Exception('خطأ في البيانات: ${errorMessages.join(', ')}');
      } else {
        throw Exception(responseData['message'] ?? 'فشل في إنشاء الطلب. رمز الخطأ: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [OrderService] خطأ في إنشاء الطلب: $e');
      rethrow;
    }
  }
}
