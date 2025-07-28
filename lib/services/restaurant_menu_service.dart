// مسار الملف: lib/services/restaurant_menu_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:saba2v2/models/MenuSection.dart'; // تأكدي من أن المسار صحيح
import 'package:saba2v2/models/MenuItem.dart';     // تأكدي من أن المسار صحيح
import 'package:saba2v2/services/auth_service.dart';
import 'package:saba2v2/services/image_upload_service.dart';

class RestaurantMenuService {
  final String _baseUrl = 'http://192.168.1.7:8000'; // تأكدي أن هذا هو الـ IP الصحيح
  final AuthService _authService = AuthService();
  final ImageUploadService _imageUploadService = ImageUploadService();

  //=====================================================
  // READ (جلب البيانات)
  //=====================================================
  /// جلب قائمة الطعام الكاملة (الأقسام والوجبات) لمطعم معين
  Future<List<MenuSection>> getMenu(int restaurantId) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('User not authenticated');

    final uri = Uri.parse('$_baseUrl/api/menu-sections?restaurant_id=$restaurantId');
    
    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      var sectionsList = (responseData['sections'] as List<dynamic>?) ?? [];
      List<MenuSection> sections = sectionsList.map((s) => MenuSection.fromJson(s)).toList();
      return sections;
    } else {
      throw Exception('Failed to fetch menu. Status: ${response.statusCode}');
    }
  }

  //=====================================================
  // CREATE (إضافة بيانات جديدة)
  //=====================================================
  /// إضافة قسم جديد
  Future<MenuSection> addSection({required int restaurantId, required String title}) async {
  final token = await _authService.getToken();
  if (token == null) throw Exception('User not authenticated');

  final uri = Uri.parse('$_baseUrl/api/menu-sections');
  
  debugPrint("MenuService ADD_SECTION: Sending POST request to $uri");
  debugPrint("MenuService ADD_SECTION: Body: ${jsonEncode({'restaurant_id': restaurantId, 'title': title})}");

  final response = await http.post(
    uri,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      'restaurant_id': restaurantId,
      'title': title,
    }),
  );

  // --- التحقق من الاستجابة ---
  if (response.statusCode == 201 || response.statusCode == 200) {
    debugPrint("MenuService ADD_SECTION: Success! Status: ${response.statusCode}");
    final responseData = jsonDecode(response.body);
    return MenuSection.fromJson(responseData['section']);
  } else {
    // --- هنا سنطبع الخطأ الحقيقي ---
    debugPrint("=================== API ERROR ===================");
    debugPrint("MenuService ADD_SECTION: FAILED!");
    debugPrint("STATUS CODE: ${response.statusCode}");
    debugPrint("RESPONSE BODY: ${response.body}");
    debugPrint("===============================================");
    throw Exception('Failed to add section. See debug console for details.');
  }
}
  /// إضافة وجبة جديدة
  Future<MenuItem> addMenuItem({
    required int sectionId,
    required String name,
    required String description,
    required double price,
    required File imageFile,
    required String imageUrl,  // نستقبل الملف
  }) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('User not authenticated');
    
    // 1. ارفع الصورة أولاً
    final imageUrl = await _imageUploadService.uploadImage(imageFile);

    // 2. أضف الوجبة مع رابط الصورة
    final uri = Uri.parse('$_baseUrl/api/menu-items');
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'menu_section_id': sectionId,
        'name': name,
        'description': description,
        'price': price,
        'image_url': imageUrl, // نستخدم الرابط
        'is_available': true, // قيمة افتراضية عند الإضافة
      }),
    );
    
    if (response.statusCode == 201 || response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return MenuItem.fromJson(responseData['item']);
    } else {
      throw Exception('Failed to add menu item. Status: ${response.statusCode}');
    }
  }

  //=====================================================
  // DELETE (حذف بيانات)
  //=====================================================
  /// حذف قسم
  Future<void> deleteSection(int sectionId) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('User not authenticated');

    final uri = Uri.parse('$_baseUrl/api/menu-sections/$sectionId');
    final response = await http.delete(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete section. Status: ${response.statusCode}');
    }
  }
}