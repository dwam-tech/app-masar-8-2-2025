// lib/providers/public_properties_provider.dart

import 'package:flutter/foundation.dart';
import '../models/featured_property.dart';
import '../services/public_properties_service.dart';

class PublicPropertiesProvider with ChangeNotifier {
  List<FeaturedProperty> _publicProperties = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  int _currentPage = 1;
  bool _hasMoreData = true;

  // Getters
  List<FeaturedProperty> get publicProperties => _publicProperties;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  bool get hasMoreData => _hasMoreData;
  int get currentPage => _currentPage;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// جلب العقارات العامة (الصفحة الأولى)
  Future<void> fetchPublicProperties() async {
    if (_isLoading) return;

    _setLoading(true);
    _hasError = false;
    _errorMessage = '';

    try {
      final response = await PublicPropertiesService.getAllPublicProperties(page: 1);
      
      _publicProperties = response.data;
      _currentPage = response.meta.currentPage;
      _hasMoreData = response.links.next != null;

      print('✅ تم جلب ${_publicProperties.length} عقار عام');
      
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
      print('❌ خطأ في جلب العقارات العامة: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// تحميل المزيد من العقارات العامة
  Future<void> loadMorePublicProperties() async {
    if (_isLoading || !_hasMoreData) return;

    _setLoading(true);

    try {
      final nextPage = _currentPage + 1;
      final response = await PublicPropertiesService.getAllPublicProperties(page: nextPage);
      
      _publicProperties.addAll(response.data);
      _currentPage = response.meta.currentPage;
      _hasMoreData = response.links.next != null;

      print('✅ تم تحميل ${response.data.length} عقار إضافي');
      
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
      print('❌ خطأ في تحميل المزيد من العقارات العامة: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// إعادة تحميل العقارات العامة
  Future<void> refreshPublicProperties() async {
    _currentPage = 1;
    _hasMoreData = true;
    _publicProperties.clear();
    await fetchPublicProperties();
  }

  /// البحث في العقارات العامة
  List<FeaturedProperty> searchProperties(String query) {
    if (query.isEmpty) return _publicProperties;
    
    return _publicProperties.where((property) =>
        property.address.toLowerCase().contains(query.toLowerCase()) ||
        property.type.toLowerCase().contains(query.toLowerCase()) ||
        property.description.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  /// فلترة العقارات حسب النوع
  List<FeaturedProperty> getPropertiesByType(String type) {
    return _publicProperties.where((property) => 
        property.type.toLowerCase().contains(type.toLowerCase())).toList();
  }

  /// فلترة العقارات حسب النطاق السعري
  List<FeaturedProperty> getPropertiesByPriceRange(double minPrice, double maxPrice) {
    return _publicProperties.where((property) {
      try {
        final propertyPrice = double.parse(property.price);
        return propertyPrice >= minPrice && propertyPrice <= maxPrice;
      } catch (e) {
        // في حالة فشل تحويل السعر، نتجاهل هذا العقار
        return false;
      }
    }).toList();
  }

  /// الحصول على أفضل العقارات
  List<FeaturedProperty> getBestProperties() {
    return _publicProperties.where((property) => property.theBest).toList();
  }

  /// الحصول على العقارات الجاهزة
  List<FeaturedProperty> getReadyProperties() {
    return _publicProperties.where((property) => property.isReady).toList();
  }
}