import 'dart:io';
import 'package:flutter/material.dart';
import 'package:saba2v2/models/MenuSection.dart';
import 'package:saba2v2/models/MenuItem.dart';
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

  Future<bool> addSection({required int restaurantId, required String title}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final newSection = await _menuService.addSection(restaurantId: restaurantId, title: title);
      _sections.add(newSection);
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst("Exception: ", ""); // عرض رسالة خطأ أنظف
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSection({required int sectionId}) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _menuService.deleteSection(sectionId);
      _sections.removeWhere((s) => s.id == sectionId);
      _error = null;
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
  
  Future<bool> addMenuItem({
    required int sectionId,
    required String name,
    required String description,
    required double price,
    required File imageFile,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      // **التعديل هنا:** تم حذف استدعاء uploadImage لأنه يتم داخل الخدمة
      final newItem = await _menuService.addMenuItem(
        sectionId: sectionId,
        name: name,
        description: description,
        price: price,
        imageFile: imageFile,
      );

      final sectionIndex = _sections.indexWhere((s) => s.id == sectionId);
      if (sectionIndex != -1) {
        _sections[sectionIndex].items.add(newItem);
      }
      
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      // **التعديل الحاسم هنا:** عرض رسالة الخطأ التفصيلية القادمة من الخدمة
      _error = e.toString().replaceFirst("Exception: ", "");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  //=====================================================
  // UPDATE (تعديل وجبة) - دالة جديدة
  //=====================================================
  Future<bool> updateMenuItem({
    required int sectionId,
    required MenuItem originalMeal, // نحتاج للوجبة الأصلية للحصول على الصورة القديمة
    required String name,
    required String description,
    required double price,
    File? newImageFile, // الصورة الجديدة اختيارية
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String imageUrlToUpdate = originalMeal.imageUrl; // استخدم الصورة القديمة بشكل افتراضي
      if (newImageFile != null) {
        // إذا تم اختيار صورة جديدة، قم برفعها
        imageUrlToUpdate = await _imageUploadService.uploadImage(newImageFile);
      }
      
      // جهز البيانات للإرسال، مع مراعاة أسماء الحقول التي يطلبها الـ API
      final Map<String, dynamic> dataToUpdate = {
        'title': name,
        'description': description,
        'price': price,
        'image': imageUrlToUpdate, // الـ API يطلب "image" للتعديل
      };

      // استدعاء الخدمة للتعديل
      final updatedItem = await _menuService.updateMenuItem(originalMeal.id, dataToUpdate);

      // تحديث القائمة المحلية في التطبيق
      final sectionIndex = _sections.indexWhere((s) => s.id == sectionId);
      if (sectionIndex != -1) {
        final itemIndex = _sections[sectionIndex].items.indexWhere((item) => item.id == originalMeal.id);
        if (itemIndex != -1) {
          _sections[sectionIndex].items[itemIndex] = updatedItem;
        }
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = "فشل تعديل الوجبة: ${e.toString()}";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  //=====================================================
  // DELETE (حذف وجبة) - دالة جديدة
  //=====================================================
  Future<bool> deleteMenuItem({required int sectionId, required int itemId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _menuService.deleteMenuItem(itemId);

      // حذف الوجبة من القائمة المحلية في التطبيق
      final sectionIndex = _sections.indexWhere((s) => s.id == sectionId);
      if (sectionIndex != -1) {
        _sections[sectionIndex].items.removeWhere((item) => item.id == itemId);
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = "فشل حذف الوجبة: ${e.toString()}";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}



// // مسار الملف: lib/providers/menu_management_provider.dart

// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:saba2v2/models/MenuSection.dart';
// import 'package:saba2v2/services/image_upload_service.dart';
// import 'package:saba2v2/services/restaurant_menu_service.dart';

// class MenuManagementProvider with ChangeNotifier {
//   final RestaurantMenuService _menuService = RestaurantMenuService();
//   final ImageUploadService _imageUploadService = ImageUploadService();

//   List<MenuSection> _sections = [];
//   bool _isLoading = false;
//   String? _error;

//   List<MenuSection> get sections => _sections;
//   bool get isLoading => _isLoading;
//   String? get error => _error;

//   /// جلب قائمة الطعام الكاملة من الـ API (حقيقي)
//   Future<void> fetchMenu(int restaurantId) async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();
//     try {
//       _sections = await _menuService.getMenu(restaurantId);
//     } catch (e) {
//       _error = "فشل جلب قائمة الطعام: ${e.toString()}";
//       _sections = [];
//     }
//     _isLoading = false;
//     notifyListeners();
//   }

//   // =================================================================
//   // --- دالة إضافة القسم (تعمل بشكل محلي ومؤقت) ---
//   // =================================================================
//   Future<bool> addSection({required int restaurantId, required String title}) async {
//   // --- الآن نستخدم الكود الحقيقي الذي يتصل بالـ API مباشرة ---
//   _isLoading = true;
//   notifyListeners();
//   try {
//     // استدعاء الخدمة لإضافة القسم على الخادم
//     final newSection = await _menuService.addSection(restaurantId: restaurantId, title: title);
    
//     // في حال النجاح، قم بإضافة القسم الجديد إلى القائمة في التطبيق
//     _sections.add(newSection);
//     _isLoading = false;
//     _error = null; // مسح أي خطأ سابق
//     notifyListeners();
//     return true; // إرجاع "نجاح"
//   } catch (e) {
//     // في حال الفشل، قم بتخزين رسالة الخطأ
//     _error = "فشل إضافة القسم: ${e.toString()}";
//     _isLoading = false;
//     notifyListeners();
//     debugPrint(_error); // طباعة الخطأ في الكونسول للتشخيص
//     return false; // إرجاع "فشل"
//   }
// }
//   /// حذف قسم عبر الـ API (حقيقي)
//   Future<bool> deleteSection({required int sectionId}) async {
//     // إذا كان الـ ID سالبًا، فهذا يعني أنه قسم محلي، احذفه محليًا فقط
//     if (sectionId < 0) {
//       _sections.removeWhere((s) => s.id == sectionId);
//       notifyListeners();
//       debugPrint("Deleted local section with ID $sectionId");
//       return true;
//     }

//     // وإلا، احذفه من الـ API
//     _isLoading = true;
//     notifyListeners();
//     try {
//       await _menuService.deleteSection(sectionId);
//       _sections.removeWhere((s) => s.id == sectionId);
//       _isLoading = false;
//       notifyListeners();
//       return true;
//     } catch (e) {
//       _error = "فشل حذف القسم: $e";
//       _isLoading = false;
//       notifyListeners();
//       return false;
//     }
//   }
  
//   /// إضافة وجبة جديدة عبر الـ API (حقيقي)
//   Future<bool> addMenuItem({
//     required int sectionId,
//     required String name,
//     required String description,
//     required double price,
//     required File imageFile,
//   }) async {
//     // لا يمكن إضافة وجبة إلى قسم محلي (لأننا لا نملك ID حقيقي)
//     if (sectionId < 0) {
//       _error = "لا يمكن إضافة وجبة إلى قسم لم يتم حفظه على الخادم بعد.";
//       notifyListeners();
//       return false;
//     }
    
//     _isLoading = true;
//     notifyListeners();
//     try {
//       final imageUrl = await _imageUploadService.uploadImage(imageFile);
//       final newItem = await _menuService.addMenuItem(
//         sectionId: sectionId,
//         name: name,
//         description: description,
//         price: price,
//         imageUrl: imageUrl,
//         imageFile: imageFile,
//       );

//       final sectionIndex = _sections.indexWhere((s) => s.id == sectionId);
//       if (sectionIndex != -1) {
//         _sections[sectionIndex].items.add(newItem);
//       }
      
//       _isLoading = false;
//       notifyListeners();
//       return true;
//     } catch (e) {
//       _error = "فشل إضافة الوجبة: $e";
//       _isLoading = false;
//       notifyListeners();
//       return false;
//     }
//   }
// }