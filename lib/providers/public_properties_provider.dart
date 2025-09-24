// lib/providers/public_properties_provider.dart

import 'package:flutter/material.dart';
import '../models/featured_property.dart';
import '../services/public_properties_service.dart';
import '../services/property_search_service.dart';

class PublicPropertiesProvider with ChangeNotifier {
  List<FeaturedProperty> _publicProperties = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMoreData = true;

  // Search-related properties
  List<FeaturedProperty> _searchResults = [];
  bool _isSearching = false;
  String? _searchError;
  Map<String, dynamic> _searchPagination = {};

  List<FeaturedProperty> get publicProperties => _publicProperties;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMoreData => _hasMoreData;

  List<FeaturedProperty> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  String? get searchError => _searchError;
  Map<String, dynamic> get searchPagination => _searchPagination;
  int get currentPage => _currentPage;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// جلب العقارات العامة
  Future<void> fetchPublicProperties({bool loadMore = false}) async {
    if (_isLoading) return;

    if (!loadMore) {
      _currentPage = 1;
      _hasMoreData = true;
      _publicProperties.clear();
    }

    if (!_hasMoreData) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final properties = await PropertySearchService.getPublicProperties(
        page: _currentPage,
        perPage: 15,
      );

      if (properties.isNotEmpty) {
        if (loadMore) {
          _publicProperties.addAll(properties);
        } else {
          _publicProperties = properties;
        }
        _currentPage++;
      } else {
        _hasMoreData = false;
      }
    } catch (e) {
      _error = 'حدث خطأ أثناء جلب العقارات: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// البحث في العقارات
  Future<void> searchProperties({
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
    bool loadMore = false,
  }) async {
    if (_isSearching && !loadMore) return;

    if (!loadMore) {
      _searchResults.clear();
      _searchPagination = {};
    }

    _isSearching = true;
    _searchError = null;
    notifyListeners();

    try {
      final result = await PropertySearchService.searchProperties(
        search: search,
        type: type,
        governorate: governorate,
        city: city,
        minPrice: minPrice,
        maxPrice: maxPrice,
        bedrooms: bedrooms,
        bathrooms: bathrooms,
        minArea: minArea,
        maxArea: maxArea,
        paymentMethod: paymentMethod,
        view: view,
        isReady: isReady,
        theBest: theBest,
        sortBy: sortBy,
        sortOrder: sortOrder,
        page: page,
      );

      if (result['success'] == true) {
        final List<FeaturedProperty> properties = result['data'];
        
        if (loadMore) {
          _searchResults.addAll(properties);
        } else {
          _searchResults = properties;
        }
        
        _searchPagination = result['pagination'];
      } else {
        _searchError = 'فشل في البحث عن العقارات';
      }
    } catch (e) {
      _searchError = 'حدث خطأ أثناء البحث: $e';
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  /// إعادة تحميل العقارات العامة
  Future<void> refreshPublicProperties() async {
    _currentPage = 1;
    _hasMoreData = true;
    _publicProperties.clear();
    await fetchPublicProperties();
  }

  /// مسح نتائج البحث
  void clearSearchResults() {
    _searchResults.clear();
    _searchError = null;
    _searchPagination = {};
    notifyListeners();
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