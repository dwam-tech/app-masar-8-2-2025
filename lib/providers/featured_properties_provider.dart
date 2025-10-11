// lib/providers/featured_properties_provider.dart

import 'package:flutter/material.dart';
import '../models/featured_property.dart';
import '../services/featured_properties_service.dart';

class FeaturedPropertiesProvider with ChangeNotifier {
  List<FeaturedProperty> _featuredProperties = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  int _currentPage = 1;
  bool _hasMoreData = true;
  int _totalProperties = 0;

  // Getters
  List<FeaturedProperty> get featuredProperties => _featuredProperties;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  bool get hasMoreData => _hasMoreData;
  int get totalProperties => _totalProperties;

  /// جلب العقارات المميزة (الصفحة الأولى)
  Future<void> fetchFeaturedProperties() async {
    if (_isLoading) return;

    _setLoading(true);
    _hasError = false;
    _errorMessage = '';

    try {
      final response = await FeaturedPropertiesService.getFeaturedProperties(page: 1);
      
      _featuredProperties = response.data;
      _currentPage = response.meta.currentPage;
      _totalProperties = response.meta.total;
      // تحديد وجود صفحات إضافية بناءً على lastPage
      _hasMoreData = response.meta.currentPage < response.meta.lastPage;

      print('✅ تم جلب ${_featuredProperties.length} عقار مميز');
      
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
      print('❌ خطأ في جلب العقارات المميزة: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// تحميل المزيد من العقارات المميزة
  Future<void> loadMoreFeaturedProperties() async {
    if (_isLoading || !_hasMoreData) return;

    _setLoading(true);

    try {
      final nextPage = _currentPage + 1;
      final response = await FeaturedPropertiesService.getFeaturedProperties(page: nextPage);
      
      _featuredProperties.addAll(response.data);
      _currentPage = response.meta.currentPage;
      _hasMoreData = response.meta.currentPage < response.meta.lastPage;

      print('✅ تم تحميل ${response.data.length} عقار إضافي');
      
    } catch (e) {
      print('❌ خطأ في تحميل المزيد من العقارات: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// إعادة تحميل العقارات المميزة
  Future<void> refreshFeaturedProperties() async {
    _currentPage = 1;
    _hasMoreData = true;
    _featuredProperties.clear();
    await fetchFeaturedProperties();
  }

  /// تنظيف البيانات
  void clearData() {
    _featuredProperties.clear();
    _currentPage = 1;
    _hasMoreData = true;
    _totalProperties = 0;
    _hasError = false;
    _errorMessage = '';
    notifyListeners();
  }

  /// تعيين حالة التحميل
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// الحصول على عقار مميز بالمعرف
  FeaturedProperty? getFeaturedPropertyById(int id) {
    try {
      return _featuredProperties.firstWhere((property) => property.id == id);
    } catch (e) {
      return null;
    }
  }

  /// فلترة العقارات حسب النوع
  List<FeaturedProperty> getPropertiesByType(String type) {
    return _featuredProperties.where((property) => 
        property.type.toLowerCase().contains(type.toLowerCase())).toList();
  }

  /// الحصول على أول 3 عقارات للعرض في الصفحة الرئيسية
  List<FeaturedProperty> getTopFeaturedProperties({int limit = 3}) {
    if (_featuredProperties.length <= limit) {
      return _featuredProperties;
    }
    return _featuredProperties.take(limit).toList();
  }
}