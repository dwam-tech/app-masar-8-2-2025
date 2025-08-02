// lib/providers/restaurant_profile_provider.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:saba2v2/services/restaurant_service.dart';
import 'package:saba2v2/services/image_upload_service.dart';

class RestaurantProfileProvider with ChangeNotifier {
  final RestaurantService _restaurantService = RestaurantService();
  final ImageUploadService _imageUploadService = ImageUploadService();

  Map<String, dynamic>? _restaurantData;
  Map<String, dynamic>? get restaurantData => _restaurantData;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // --- Core Methods ---

  Future<void> fetchDetails() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _restaurantData = await _restaurantService.getRestaurantDetails();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> uploadDocument(String fieldKey, File imageFile) async {
    // تقوم بتحديث الحالة فقط ولا تقوم بالحفظ الفعلي
    if (_restaurantData == null) return;
    
    // Optimistic UI: Update local path for preview
    final localTempUrl = imageFile.path; // Show local file immediately
    _restaurantData!['restaurant_detail'][fieldKey] = localTempUrl;
    notifyListeners();

    _isLoading = true;
    notifyListeners();
    try {
      final imageUrl = await _imageUploadService.uploadImage(imageFile);
      // Update with the real network URL after successful upload
      _restaurantData!['restaurant_detail'][fieldKey] = imageUrl;
      _error = null;
    } catch (e) {
      _error = "فشل رفع الصورة: ${e.toString().replaceFirst('Exception: ', '')}";
      // Revert to original or show placeholder if upload fails
      // (For simplicity, we'll let the user retry by tapping again)
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// **النسخة المحدثة والمصححة من saveChanges**
  Future<bool> saveChanges() async {
    if (_restaurantData == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // --- !! هذا هو الجزء الجديد والمهم !! ---
      // بناء حمولة (Payload) تحتوي فقط على البيانات القابلة للتعديل
      final Map<String, dynamic> dataToUpdate = {};
      
      // 1. أضف الحقول من بيانات المستخدم الأساسية
      if (_restaurantData!['name'] != null) dataToUpdate['name'] = _restaurantData!['name'];
      if (_restaurantData!['phone'] != null) dataToUpdate['phone'] = _restaurantData!['phone'];
      if (_restaurantData!['governorate'] != null) dataToUpdate['governorate'] = _restaurantData!['governorate'];

      // 2. أضف الحقول من تفاصيل المطعم
      final details = _restaurantData!['restaurant_detail'];
      if (details != null) {
        // حقول الصور التي قمنا بتحديثها
        dataToUpdate['owner_id_front_image'] = details['owner_id_front_image'];
        dataToUpdate['owner_id_back_image'] = details['owner_id_back_image'];
        dataToUpdate['license_front_image'] = details['license_front_image'];
        dataToUpdate['license_back_image'] = details['license_back_image'];
        dataToUpdate['commercial_register_front_image'] = details['commercial_register_front_image'];
        dataToUpdate['commercial_register_back_image'] = details['commercial_register_back_image'];
        dataToUpdate['vat_image_front'] = details['vat_image_front'];
        dataToUpdate['vat_image_back'] = details['vat_image_back'];
        
        // حقل VAT
        dataToUpdate['vat_included'] = details['vat_included'];
        
        // يمكنك إضافة أي حقول نصية أخرى قابلة للتعديل هنا
        // dataToUpdate['restaurant_name'] = details['restaurant_name'];
      }
      // ---------------------------------------------
      
      final result = await _restaurantService.updateRestaurantDetails(dataToUpdate);
      
      if (result['status'] == true) {
         _restaurantData = result['data']; // تحديث البيانات المحلية بالبيانات الجديدة من الخادم
         return true;
      } else {
        _error = result['message'] ?? 'Failed to save changes.';
        return false;
      }
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// **Generic method to update any restaurant profile data**
  Future<bool> updateRestaurantProfile(Map<String, dynamic> dataToUpdate) async {
    if (_restaurantData == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final result = await _restaurantService.updateRestaurantDetails(dataToUpdate);
      
      if (result['status'] == true) {
        // Update local data with the new data from server
        _restaurantData = result['data'];
        return true;
      } else {
        _error = result['message'] ?? 'Failed to update restaurant profile.';
        return false;
      }
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}