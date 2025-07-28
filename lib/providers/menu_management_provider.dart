// مسار الملف: lib/providers/menu_management_provider.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:saba2v2/models/MenuSection.dart';
import 'package:saba2v2/services/image_upload_service.dart';
import 'package:saba2v2/services/restaurant_menu_service.dart';

class MenuManagementProvider with ChangeNotifier {
  final RestaurantMenuService _menuService = RestaurantMenuService();
  final ImageUploadService _imageUploadService = ImageUploadService();

  List<MenuSection> _sections = [];
  bool _isLoading = false;
  String? _error;

  List<MenuSection> get sections => _sections;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// جلب قائمة الطعام الكاملة من الـ API (حقيقي)
  Future<void> fetchMenu(int restaurantId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _sections = await _menuService.getMenu(restaurantId);
    } catch (e) {
      _error = "فشل جلب قائمة الطعام: ${e.toString()}";
      _sections = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  // =================================================================
  // --- دالة إضافة القسم (تعمل بشكل محلي ومؤقت) ---
  // =================================================================
  Future<bool> addSection({required int restaurantId, required String title}) async {
    // --- بداية المنطق المحلي ---
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300)); // محاكاة وقت الشبكة

    // التحقق من عدم وجود قسم بنفس الاسم
    if (_sections.any((s) => s.title.trim().toLowerCase() == title.trim().toLowerCase())) {
      _error = "هذا القسم موجود بالفعل";
      _isLoading = false;
      notifyListeners();
      return false; // فشل لأن القسم مكرر
    }

    // إنشاء قسم جديد بـ ID مؤقت (سالب لتمييزه)
    final newSection = MenuSection(
      id: -DateTime.now().millisecondsSinceEpoch, // ID سالب ومؤقت
      title: title,
      items: [],
    );
    _sections.add(newSection);

    _isLoading = false;
    notifyListeners();
    debugPrint("Added section '${title}' locally for testing.");
    return true; // نجاح العملية محليًا
    // --- نهاية المنطق المحلي ---

    /* 
    // --- الكود الحقيقي الذي سنعود إليه بعد إصلاح الـ API ---
    _isLoading = true;
    notifyListeners();
    try {
      final newSection = await _menuService.addSection(restaurantId: restaurantId, title: title);
      _sections.add(newSection);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = "فشل إضافة القسم: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
    */
  }

  /// حذف قسم عبر الـ API (حقيقي)
  Future<bool> deleteSection({required int sectionId}) async {
    // إذا كان الـ ID سالبًا، فهذا يعني أنه قسم محلي، احذفه محليًا فقط
    if (sectionId < 0) {
      _sections.removeWhere((s) => s.id == sectionId);
      notifyListeners();
      debugPrint("Deleted local section with ID $sectionId");
      return true;
    }

    // وإلا، احذفه من الـ API
    _isLoading = true;
    notifyListeners();
    try {
      await _menuService.deleteSection(sectionId);
      _sections.removeWhere((s) => s.id == sectionId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = "فشل حذف القسم: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  /// إضافة وجبة جديدة عبر الـ API (حقيقي)
  Future<bool> addMenuItem({
    required int sectionId,
    required String name,
    required String description,
    required double price,
    required File imageFile,
  }) async {
    // لا يمكن إضافة وجبة إلى قسم محلي (لأننا لا نملك ID حقيقي)
    if (sectionId < 0) {
      _error = "لا يمكن إضافة وجبة إلى قسم لم يتم حفظه على الخادم بعد.";
      notifyListeners();
      return false;
    }
    
    _isLoading = true;
    notifyListeners();
    try {
      final imageUrl = await _imageUploadService.uploadImage(imageFile);
      final newItem = await _menuService.addMenuItem(
        sectionId: sectionId,
        name: name,
        description: description,
        price: price,
        imageUrl: imageUrl,
        imageFile: imageFile,
      );

      final sectionIndex = _sections.indexWhere((s) => s.id == sectionId);
      if (sectionIndex != -1) {
        _sections[sectionIndex].items.add(newItem);
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = "فشل إضافة الوجبة: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}