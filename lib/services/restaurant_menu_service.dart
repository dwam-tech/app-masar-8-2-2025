import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:saba2v2/models/MenuSection.dart';
import 'package:saba2v2/models/MenuItem.dart';
import 'package:saba2v2/services/auth_service.dart';
import 'package:saba2v2/services/image_upload_service.dart';
import '../config/constants.dart';

class RestaurantMenuService {
  final String _baseUrl = AppConstants.baseUrl;
  final AuthService _authService = AuthService();
  final ImageUploadService _imageUploadService = ImageUploadService();

  /// ====================================================================
  /// جلب الأقسام (النسخة النهائية المصححة بالمسار الصحيح)
  /// ====================================================================
  Future<List<MenuSection>> getMenu(int restaurantId) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('User not authenticated');

    // **التصحيح النهائي والحاسم: استخدام المسار الصحيح الذي يدعم GET**
    final uri = Uri.parse('$_baseUrl/api/restaurants/$restaurantId/menu-sections');
    debugPrint("MenuService GET_SECTIONS: Fetching from FINAL CORRECT endpoint: $uri");

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      // بناءً على كود الخادم، الاستجابة هي كائن يحتوي على مفتاح "sections"
      final responseData = jsonDecode(response.body);
      final List<dynamic> sectionsJson = responseData['sections'] ?? [];
      return sectionsJson.map((json) => MenuSection.fromJson(json)).toList();
    } else {
      debugPrint("API ERROR (getMenu): Status ${response.statusCode}, Body: ${response.body}");
      throw Exception('Failed to fetch menu sections. Status: ${response.statusCode}');
    }
  }
  
  // ... (بقية دوال الخدمة صحيحة تمامًا ولا تحتاج لأي تعديل) ...
  Future<MenuSection> addSection({required int restaurantId, required String title}) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('User not authenticated');
    final uri = Uri.parse('$_baseUrl/api/menu-sections');
    final response = await http.post(uri, headers: {'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer $token'}, body: jsonEncode({'restaurant_id': restaurantId, 'title': title}));
    if (response.statusCode == 201 || response.statusCode == 200) { return MenuSection.fromJson(jsonDecode(response.body)['section']); } 
    else { throw Exception('Failed to add section.'); }
  }

  Future<MenuItem> addMenuItem({required int sectionId, required String name, required String description, required double price, required File imageFile}) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('User not authenticated');
    final restaurantId = await _authService.getRestaurantId();
    if (restaurantId == null) throw Exception("Could not find restaurant ID.");
    final imageUrl = await _imageUploadService.uploadImage(imageFile);
    final uri = Uri.parse('$_baseUrl/api/menu-items');
    final body = {"restaurant_id": restaurantId, "section_id": sectionId, "title": name, "description": description, "price": price, "image": imageUrl, "is_available": true};
    final response = await http.post(uri, headers: {'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer $token'}, body: jsonEncode(body));
    if (response.statusCode == 201 || response.statusCode == 200) {
      debugPrint("SUCCESS: Menu item added successfully!");
      return MenuItem.fromJson(jsonDecode(response.body)['item']);
    } else {
      debugPrint("API VALIDATION ERROR: Status ${response.statusCode}, Body: ${response.body}");
      throw Exception('فشل إضافة الوجبة. تحقق من الكونسول.');
    }
  }

  Future<void> deleteSection(int sectionId) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('User not authenticated');
    final uri = Uri.parse('$_baseUrl/api/menu-sections/$sectionId');
    final response = await http.delete(uri, headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'});
    if (response.statusCode != 200 && response.statusCode != 204) { throw Exception('Failed to delete section.'); }
  }

  //=====================================================
  // UPDATE (تعديل وجبة) - دالة جديدة
  //=====================================================
  Future<MenuItem> updateMenuItem(int itemId, Map<String, dynamic> data) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('User not authenticated');

    final uri = Uri.parse('$_baseUrl/api/menu-items/$itemId');
    debugPrint("MenuService UPDATE_ITEM: Sending PUT to $uri with body: ${jsonEncode(data)}");

    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      debugPrint("SUCCESS: Menu item updated successfully!");
      return MenuItem.fromJson(jsonDecode(response.body)['item']);
    } else {
      debugPrint("API ERROR (updateMenuItem): Status ${response.statusCode}, Body: ${response.body}");
      throw Exception('Failed to update menu item.');
    }
  }

  //=====================================================
  // DELETE (حذف وجبة) - دالة جديدة
  //=====================================================
  Future<void> deleteMenuItem(int itemId) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('User not authenticated');

    final uri = Uri.parse('$_baseUrl/api/menu-items/$itemId');
    debugPrint("MenuService DELETE_ITEM: Sending DELETE to $uri");

    final response = await http.delete(
      uri,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      debugPrint("API ERROR (deleteMenuItem): Status ${response.statusCode}, Body: ${response.body}");
      throw Exception('Failed to delete menu item.');
    }
     debugPrint("SUCCESS: Menu item deleted successfully!");
  }
  
}