import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';
import 'package:saba2v2/services/restaurant_service.dart';
import 'package:saba2v2/data/restaurant_categories_map.dart';

class RestaurantProvider with ChangeNotifier {
  final RestaurantService _restaurantService = RestaurantService();

  // البانرز
  List<Map<String, dynamic>> _banners = [];
  bool _bannersLoading = false;
  String? _bannersError;

  // فئات المطاعم
  List<Map<String, dynamic>> _categories = [];
  bool _categoriesLoading = false;
  String? _categoriesError;

  // المطاعم
  List<Map<String, dynamic>> _restaurants = [];
  bool _restaurantsLoading = false;
  String? _restaurantsError;

  // أفضل المطاعم
  List<Map<String, dynamic>> _bestRestaurants = [];
  bool _bestRestaurantsLoading = false;
  String? _bestRestaurantsError;
  Map<String, dynamic>? _bestRestaurantsPagination;

  // جميع المطاعم
  List<Map<String, dynamic>> _allRestaurants = [];
  bool _allRestaurantsLoading = false;
  String? _allRestaurantsError;
  Map<String, dynamic>? _allRestaurantsPagination;

  // Getters للبانرز
  List<Map<String, dynamic>> get banners => _banners;
  bool get bannersLoading => _bannersLoading;
  String? get bannersError => _bannersError;

  // Getters للفئات
  List<Map<String, dynamic>> get categories => _categories;
  bool get categoriesLoading => _categoriesLoading;
  String? get categoriesError => _categoriesError;

  // Getters للمطاعم
  List<Map<String, dynamic>> get restaurants => _restaurants;
  bool get restaurantsLoading => _restaurantsLoading;
  String? get restaurantsError => _restaurantsError;

  // Getters لأفضل المطاعم
  List<Map<String, dynamic>> get bestRestaurants => _bestRestaurants;
  bool get bestRestaurantsLoading => _bestRestaurantsLoading;
  String? get bestRestaurantsError => _bestRestaurantsError;
  Map<String, dynamic>? get bestRestaurantsPagination => _bestRestaurantsPagination;

  // Getters لجميع المطاعم
  List<Map<String, dynamic>> get allRestaurants => _allRestaurants;
  bool get allRestaurantsLoading => _allRestaurantsLoading;
  String? get allRestaurantsError => _allRestaurantsError;
  Map<String, dynamic>? get allRestaurantsPagination => _allRestaurantsPagination;

  // جلب البانرز من API
  Future<void> fetchBanners() async {
    _bannersLoading = true;
    _bannersError = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${Constants.baseUrl}/api/restaurant-banners'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<String> bannerUrls = List<String>.from(data['ResturantBanners'] ?? []);
        
        _banners = bannerUrls.asMap().entries.map((entry) {
          int index = entry.key;
          String imageUrl = entry.value;
          
          // إضافة base URL إذا كان المسار نسبي
          String fullImageUrl = imageUrl.startsWith('http') 
              ? imageUrl 
              : '${Constants.baseUrl}/$imageUrl';
          
          return {
            'id': (index + 1).toString(),
            'imageUrl': fullImageUrl,
            'title': 'عرض خاص ${index + 1}',
            'link': '/restaurant-offers',
          };
        }).toList();
      } else {
        throw Exception('فشل في جلب البانرات: ${response.statusCode}');
      }
      
      _bannersLoading = false;
      notifyListeners();
    } catch (e) {
      _bannersError = e.toString();
      _bannersLoading = false;
      notifyListeners();
      
      // في حالة الخطأ، استخدام بيانات افتراضية
      _banners = [
        {
          'id': '1',
          'imageUrl': 'assets/images/banner_food.jpg',
          'title': 'عروض المطاعم',
          'link': '/restaurant-offers',
        },
      ];
    }
  }

  // جلب فئات المطاعم من API
  Future<void> fetchCategories() async {
    _categoriesLoading = true;
    _categoriesError = null;
    notifyListeners();

    try {
      // TODO: استبدال بـ API call حقيقي
      await Future.delayed(const Duration(seconds: 1)); // محاكاة API call
      
      _categories = [
        {
          'id': '1',
          'title': 'مشويات',
          'imageUrl': 'assets/images/grilled.png',
          'route': '/restaurants/grilled',
        },
        {
          'id': '2',
          'title': 'سيفود',
          'imageUrl': 'assets/images/seafood.png',
          'route': '/restaurants/seafood',
        },
        {
          'id': '3',
          'title': 'دجاج مقلي',
          'imageUrl': 'assets/images/fried_chicken.png',
          'route': '/restaurants/chicken',
        },
        {
          'id': '4',
          'title': 'حلويات',
          'imageUrl': 'assets/images/desserts.png',
          'route': '/restaurants/desserts',
        },
        {
          'id': '5',
          'title': 'بيتزا',
          'imageUrl': 'assets/images/pizza_category.png',
          'route': '/restaurants/pizza',
        },
        {
          'id': '6',
          'title': 'ايس كريم',
          'imageUrl': 'assets/images/ice_cream.png',
          'route': '/restaurants/ice-cream',
        },
      ];
      
      _categoriesLoading = false;
      notifyListeners();
    } catch (e) {
      _categoriesError = e.toString();
      _categoriesLoading = false;
      notifyListeners();
    }
  }

  // جلب المطاعم من API
  Future<void> fetchRestaurants({String? city, String? category}) async {
    _restaurantsLoading = true;
    _restaurantsError = null;
    notifyListeners();

    try {
      // TODO: استبدال بـ API call حقيقي
      await Future.delayed(const Duration(seconds: 1)); // محاكاة API call
      
      _restaurants = [
        {
          'id': '1',
          'name': 'مطعم الأصالة',
          'category': 'مشويات',
          'imageUrl': 'assets/images/restaurant.png',
          'rating': 4.5,
          'location': 'القاهرة',
          'deliveryTime': '30-45 دقيقة',
          'deliveryFee': 15.0,
          'minOrder': 50.0,
          'isOpen': true,
        },
        {
          'id': '2',
          'name': 'مطعم البحر الأحمر',
          'category': 'سيفود',
          'imageUrl': 'assets/images/seafood.png',
          'rating': 4.6,
          'location': 'الإسكندرية',
          'deliveryTime': '35-50 دقيقة',
          'deliveryFee': 18.0,
          'minOrder': 70.0,
          'isOpen': true,
        },
        {
          'id': '3',
          'name': 'كنتاكي',
          'category': 'دجاج مقلي',
          'imageUrl': 'assets/images/fried_chicken.png',
          'rating': 4.0,
          'location': 'الجيزة',
          'deliveryTime': '20-30 دقيقة',
          'deliveryFee': 12.0,
          'minOrder': 35.0,
          'isOpen': true,
        },
        {
          'id': '4',
          'name': 'حلواني الشام',
          'category': 'حلويات',
          'imageUrl': 'assets/images/desserts.png',
          'rating': 4.7,
          'location': 'القاهرة',
          'deliveryTime': '40-50 دقيقة',
          'deliveryFee': 20.0,
          'minOrder': 60.0,
          'isOpen': true,
        },
        {
          'id': '5',
          'name': 'بيتزا هت',
          'category': 'بيتزا',
          'imageUrl': 'assets/images/pizza.jpg',
          'rating': 4.2,
          'location': 'الجيزة',
          'deliveryTime': '25-35 دقيقة',
          'deliveryFee': 10.0,
          'minOrder': 40.0,
          'isOpen': true,
        },
        {
          'id': '6',
          'name': 'باسكن روبنز',
          'category': 'ايس كريم',
          'imageUrl': 'assets/images/ice_cream.png',
          'rating': 4.4,
          'location': 'القاهرة',
          'deliveryTime': '15-25 دقيقة',
          'deliveryFee': 8.0,
          'minOrder': 25.0,
          'isOpen': true,
        },
      ];
      
      // تطبيق الفلاتر إذا كانت موجودة
      if (city != null) {
        _restaurants = _restaurants.where((r) => r['location'] == city).toList();
      }
      if (category != null) {
        _restaurants = _restaurants.where((r) => r['category'] == category).toList();
      }
      
      _restaurantsLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('RestaurantProvider fetchRestaurants Error: $e');
      
      // معالجة أنواع مختلفة من الأخطاء
      if (e.toString().contains('SocketException') || e.toString().contains('NetworkException')) {
        _restaurantsError = 'تعذر الاتصال بالخادم. يرجى التحقق من اتصال الإنترنت';
      } else if (e.toString().contains('TimeoutException')) {
        _restaurantsError = 'انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى';
      } else if (e.toString().contains('FormatException')) {
        _restaurantsError = 'خطأ في تنسيق البيانات المستلمة';
      } else {
        _restaurantsError = 'حدث خطأ أثناء جلب المطاعم: ${e.toString()}';
      }
      
      _restaurantsLoading = false;
      notifyListeners();
    }
  }

  // البحث في المطاعم
  Future<void> searchRestaurants(String query) async {
    _restaurantsLoading = true;
    _restaurantsError = null;
    notifyListeners();

    try {
      // TODO: استبدال بـ API call حقيقي للبحث
      await Future.delayed(const Duration(milliseconds: 500));
      
      // محاكاة البحث في البيانات المحلية
      await fetchRestaurants(); // جلب جميع المطاعم أولاً
      
      if (query.isNotEmpty) {
        _restaurants = _restaurants.where((restaurant) {
          final name = restaurant['name'].toString().toLowerCase();
          final category = restaurant['category'].toString().toLowerCase();
          final searchQuery = query.toLowerCase();
          
          return name.contains(searchQuery) || category.contains(searchQuery);
        }).toList();
      }
      
      _restaurantsLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('RestaurantProvider searchRestaurants Error: $e');
      
      // معالجة أنواع مختلفة من الأخطاء
      if (e.toString().contains('SocketException') || e.toString().contains('NetworkException')) {
        _restaurantsError = 'تعذر الاتصال بالخادم أثناء البحث. يرجى التحقق من اتصال الإنترنت';
      } else if (e.toString().contains('TimeoutException')) {
        _restaurantsError = 'انتهت مهلة البحث. يرجى المحاولة مرة أخرى';
      } else {
        _restaurantsError = 'حدث خطأ أثناء البحث: ${e.toString()}';
      }
      
      _restaurantsLoading = false;
      notifyListeners();
    }
  }

  // الحصول على مطعم بالـ ID
  Map<String, dynamic>? getRestaurantById(String id) {
    try {
      return _restaurants.firstWhere((restaurant) => restaurant['id'] == id);
    } catch (e) {
      return null;
    }
  }

  // تحديث حالة المطعم (مفتوح/مغلق)
  void updateRestaurantStatus(String id, bool isOpen) {
    final index = _restaurants.indexWhere((r) => r['id'] == id);
    if (index != -1) {
      _restaurants[index]['isOpen'] = isOpen;
      notifyListeners();
    }
  }

  // جلب أفضل المطاعم من API
  Future<void> fetchBestRestaurants({bool loadMore = false}) async {
    print('🚀 [RestaurantProvider] fetchBestRestaurants called - loadMore: $loadMore');
    
    if (loadMore && _bestRestaurantsLoading) {
      print('⏸️ [RestaurantProvider] Already loading, skipping...');
      return;
    }
    
    if (!loadMore) {
      print('🔄 [RestaurantProvider] Starting fresh load...');
      _bestRestaurantsLoading = true;
      _bestRestaurantsError = null;
      _bestRestaurants.clear();
    }
    notifyListeners();

    try {
      final currentPage = loadMore 
          ? (_bestRestaurantsPagination?['meta']?['current_page'] ?? 0) + 1 
          : 1;
      
      print('📄 [RestaurantProvider] Loading page: $currentPage');
      
      final response = await _restaurantService.getBestRestaurants(page: currentPage);
      
      print('✅ [RestaurantProvider] Service response received');
      print('📊 [RestaurantProvider] Response keys: ${response.keys.toList()}');
      
      final List<Map<String, dynamic>> newRestaurants = 
          List<Map<String, dynamic>>.from(response['data'] ?? []);
      
      print('🍽️ [RestaurantProvider] Parsed ${newRestaurants.length} restaurants');
      
      if (loadMore) {
        _bestRestaurants.addAll(newRestaurants);
        print('➕ [RestaurantProvider] Added to existing list. Total: ${_bestRestaurants.length}');
      } else {
        _bestRestaurants = newRestaurants;
        print('🔄 [RestaurantProvider] Replaced list. Total: ${_bestRestaurants.length}');
      }
      
      _bestRestaurantsPagination = {
        'links': response['links'],
        'meta': response['meta'],
      };
      
      print('📊 [RestaurantProvider] Pagination info: ${_bestRestaurantsPagination?['meta']}');
      
      _bestRestaurantsLoading = false;
      print('✅ [RestaurantProvider] Loading completed successfully');
      notifyListeners();
    } catch (e) {
      print('💥 [RestaurantProvider] Error occurred: $e');
      _bestRestaurantsError = e.toString();
      _bestRestaurantsLoading = false;
      notifyListeners();
    }
  }

  // تحقق من إمكانية تحميل المزيد من أفضل المطاعم
  bool get canLoadMoreBestRestaurants {
    final meta = _bestRestaurantsPagination?['meta'];
    if (meta == null) return false;
    return meta['current_page'] < meta['last_page'];
  }

  // جلب جميع المطاعم من API
  Future<void> fetchAllRestaurants({bool loadMore = false}) async {
    print('🚀 [RestaurantProvider] fetchAllRestaurants called - loadMore: $loadMore');
    
    if (loadMore && _allRestaurantsLoading) {
      print('⏸️ [RestaurantProvider] Already loading, skipping...');
      return;
    }
    
    if (!loadMore) {
      print('🔄 [RestaurantProvider] Starting fresh load...');
      _allRestaurantsLoading = true;
      _allRestaurantsError = null;
      _allRestaurants.clear();
    }
    notifyListeners();

    try {
      final currentPage = loadMore 
          ? (_allRestaurantsPagination?['meta']?['current_page'] ?? 0) + 1 
          : 1;
      
      print('📄 [RestaurantProvider] Loading page: $currentPage');
      
      final response = await _restaurantService.getAllRestaurants(page: currentPage);
      
      print('✅ [RestaurantProvider] Service response received');
      print('📊 [RestaurantProvider] Response keys: ${response.keys.toList()}');
      
      final List<Map<String, dynamic>> newRestaurants = 
          List<Map<String, dynamic>>.from(response['data'] ?? []);
      
      print('🍽️ [RestaurantProvider] Parsed ${newRestaurants.length} restaurants');
      
      if (loadMore) {
        _allRestaurants.addAll(newRestaurants);
        print('➕ [RestaurantProvider] Added to existing list. Total: ${_allRestaurants.length}');
      } else {
        _allRestaurants = newRestaurants;
        print('🔄 [RestaurantProvider] Replaced list. Total: ${_allRestaurants.length}');
      }
      
      _allRestaurantsPagination = {
        'links': response['links'],
        'meta': response['meta'],
      };
      
      print('📊 [RestaurantProvider] Pagination info: ${_allRestaurantsPagination?['meta']}');
      
      _allRestaurantsLoading = false;
      print('✅ [RestaurantProvider] Loading completed successfully');
      notifyListeners();
    } catch (e) {
      print('💥 [RestaurantProvider] Error occurred: $e');
      _allRestaurantsError = e.toString();
      _allRestaurantsLoading = false;
      notifyListeners();
    }
  }

  // تحقق من إمكانية تحميل المزيد من جميع المطاعم
  bool get canLoadMoreAllRestaurants {
    final meta = _allRestaurantsPagination?['meta'];
    if (meta == null) return false;
    return meta['current_page'] < meta['last_page'];
  }

  // إعادة تعيين البيانات
  void reset() {
    _banners.clear();
    _categories.clear();
    _restaurants.clear();
    _bestRestaurants.clear();
    _allRestaurants.clear();
    _bannersLoading = false;
    _categoriesLoading = false;
    _restaurantsLoading = false;
    _bestRestaurantsLoading = false;
    _allRestaurantsLoading = false;
    _bannersError = null;
    _categoriesError = null;
    _restaurantsError = null;
    _bestRestaurantsError = null;
    _allRestaurantsError = null;
    _bestRestaurantsPagination = null;
    _allRestaurantsPagination = null;
    notifyListeners();
  }

  // ===== Menu Section Filtering State & Methods =====
  List<String> _menuSections = [];
  List<String> get menuSections => _menuSections;
  bool _menuSectionsLoading = false;
  bool get menuSectionsLoading => _menuSectionsLoading;
  String? _selectedMenuSection;
  String? get selectedMenuSection => _selectedMenuSection;

  List<Map<String, dynamic>> _filteredRestaurants = [];
  List<Map<String, dynamic>> get filteredRestaurants => _filteredRestaurants;
  bool _filteredRestaurantsLoading = false;
  bool get filteredRestaurantsLoading => _filteredRestaurantsLoading;
  String? _filteredRestaurantsError;
  String? get filteredRestaurantsError => _filteredRestaurantsError;

  Future<void> fetchMenuSections() async {
    _menuSectionsLoading = true;
    notifyListeners();
    try {
      _menuSections = await _restaurantService.getAllMenuSections();
      _menuSectionsLoading = false;
      notifyListeners();
    } catch (e) {
      _menuSectionsLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRestaurantsByMenuSection(String section) async {
    _filteredRestaurantsLoading = true;
    _filteredRestaurantsError = null;
    _selectedMenuSection = section;
    notifyListeners();
    try {
      final response = await _restaurantService.getRestaurantsByMenuSection(section);
      final List<dynamic> data = response['data'] ?? [];
      _filteredRestaurants = data.cast<Map<String, dynamic>>();
      _filteredRestaurantsLoading = false;
      notifyListeners();
    } catch (e) {
      _filteredRestaurantsLoading = false;
      _filteredRestaurantsError = e.toString();
      notifyListeners();
    }
  }

  void clearMenuSectionFilter() {
    _selectedMenuSection = null;
    _filteredRestaurants = [];
    notifyListeners();
  }
}