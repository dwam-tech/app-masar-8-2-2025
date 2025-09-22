import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:saba2v2/models/delivery_request_model.dart';
import 'package:saba2v2/services/driver_service.dart';

class DriverState extends ChangeNotifier {
  final DriverService service;
  
  // قوائم الطلبات
  List<DeliveryRequestModel> _allRequests = [];
  List<DeliveryRequestModel> _availableRequests = [];
  List<DeliveryRequestModel> _myOffers = [];
  List<DeliveryRequestModel> _completedRequests = [];
  
  // حالات التحميل والأخطاء
  bool _isLoading = false;
  String? _error;
  
  // Timer للتحديث التلقائي
  Timer? _refreshTimer;
  
  // حالة السائق
  bool _isAvailable = false;
  
  DriverState({required this.service});
  
  // Getters
  List<DeliveryRequestModel> get allRequests => _allRequests;
  List<DeliveryRequestModel> get availableRequests => _availableRequests;
  List<DeliveryRequestModel> get myOffers => _myOffers;
  List<DeliveryRequestModel> get completedRequests => _completedRequests;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAvailable => _isAvailable;
  
  /// جلب جميع الطلبات
  Future<void> fetchAllRequests() async {
    try {
      _setLoading(true);
      _clearError();
      
      // جلب الطلبات بشكل متوازي
      final results = await Future.wait([
        service.fetchAvailableRequests(),
        service.fetchMyOffers(),
        service.fetchCompletedRequests(),
      ]);
      
      _availableRequests = results[0];
      _myOffers = results[1];
      _completedRequests = results[2];
      
      // دمج جميع الطلبات
      _allRequests = [
        ..._availableRequests,
        ..._myOffers,
        ..._completedRequests,
      ];
      
      notifyListeners();
    } catch (e) {
      _setError('خطأ في جلب الطلبات: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// جلب الطلبات المتاحة فقط
  Future<void> fetchAvailableRequests() async {
    try {
      _setLoading(true);
      _clearError();
      
      _availableRequests = await service.fetchAvailableRequests();
      _updateAllRequests();
      
      notifyListeners();
    } catch (e) {
      _setError('خطأ في جلب الطلبات المتاحة: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// جلب عروضي المقدمة
  Future<void> fetchMyOffers() async {
    try {
      _setLoading(true);
      _clearError();
      
      _myOffers = await service.fetchMyOffers();
      _updateAllRequests();
      
      notifyListeners();
    } catch (e) {
      _setError('خطأ في جلب عروضي: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// جلب الطلبات المنتهية
  Future<void> fetchCompletedRequests() async {
    try {
      _setLoading(true);
      _clearError();
      
      _completedRequests = await service.fetchCompletedRequests();
      _updateAllRequests();
      
      notifyListeners();
    } catch (e) {
      _setError('خطأ في جلب الطلبات المنتهية: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// تقديم عرض على طلب
  Future<bool> submitOffer({
    required int requestId,
    required double offeredPrice,
    String? notes,
  }) async {
    try {
      _clearError();
      
      final success = await service.submitOffer(
        requestId: requestId,
        offeredPrice: offeredPrice,
        notes: notes,
      );
      
      if (success) {
        // تحديث القوائم بعد تقديم العرض
        await fetchAllRequests();
      }
      
      return success;
    } catch (e) {
      _setError('خطأ في تقديم العرض: $e');
      return false;
    }
  }
  
  /// تحديث حالة توفر السائق
  Future<bool> updateAvailability(bool isAvailable) async {
    try {
      _clearError();
      
      final success = await service.updateAvailability(isAvailable: isAvailable);
      
      if (success) {
        _isAvailable = isAvailable;
        notifyListeners();
        
        // إذا أصبح السائق متاحاً، قم بجلب الطلبات المتاحة
        if (isAvailable) {
          await fetchAvailableRequests();
        }
      }
      
      return success;
    } catch (e) {
      _setError('خطأ في تحديث حالة التوفر: $e');
      return false;
    }
  }
  
  /// البحث في الطلبات
  List<DeliveryRequestModel> searchRequests(String query) {
    if (query.isEmpty) return _allRequests;
    
    final lowerQuery = query.toLowerCase();
    return _allRequests.where((request) {
      return (request.fromLocation?.toLowerCase().contains(lowerQuery) ?? false) ||
             (request.toLocation?.toLowerCase().contains(lowerQuery) ?? false) ||
             request.id.toString().contains(query);
    }).toList();
  }
  
  /// تصفية الطلبات حسب المحافظة
  List<DeliveryRequestModel> filterByGovernorate(String governorate) {
    // Since governorate is not available in the model, return all requests
    return _allRequests;
  }
  
  /// تصفية الطلبات حسب نطاق السعر
  List<DeliveryRequestModel> filterByPriceRange(double minPrice, double maxPrice) {
    return _allRequests.where((request) {
      final price = request.requestedPrice;
      return price != null && price >= minPrice && price <= maxPrice;
    }).toList();
  }
  
  /// ترتيب الطلبات حسب التاريخ
  List<DeliveryRequestModel> sortByDate({bool ascending = false}) {
    final sorted = List<DeliveryRequestModel>.from(_allRequests);
    sorted.sort((a, b) {
      final comparison = a.createdAt.compareTo(b.createdAt);
      return ascending ? comparison : -comparison;
    });
    return sorted;
  }
  
  /// ترتيب الطلبات حسب السعر
  List<DeliveryRequestModel> sortByPrice({bool ascending = true}) {
    final sorted = List<DeliveryRequestModel>.from(_allRequests);
    sorted.sort((a, b) {
      final priceA = a.requestedPrice ?? 0;
      final priceB = b.requestedPrice ?? 0;
      final comparison = priceA.compareTo(priceB);
      return ascending ? comparison : -comparison;
    });
    return sorted;
  }
  
  /// ترتيب الطلبات حسب المسافة
  List<DeliveryRequestModel> sortByDistance({bool ascending = true}) {
    final sorted = List<DeliveryRequestModel>.from(_allRequests);
    // Since estimatedDistance is not available, sort by ID instead
    sorted.sort((a, b) {
      final comparison = a.id.compareTo(b.id);
      return ascending ? comparison : -comparison;
    });
    return sorted;
  }
  
  /// بدء التحديث التلقائي
  void startAutoRefresh({Duration interval = const Duration(minutes: 2)}) {
    stopAutoRefresh(); // إيقاف أي timer موجود
    
    _refreshTimer = Timer.periodic(interval, (timer) {
      if (!_isLoading) {
        fetchAllRequests();
      }
    });
  }
  
  /// إيقاف التحديث التلقائي
  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }
  
  /// تحديث قائمة جميع الطلبات
  void _updateAllRequests() {
    _allRequests = [
      ..._availableRequests,
      ..._myOffers,
      ..._completedRequests,
    ];
  }
  
  /// تعيين حالة التحميل
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) _clearError();
    notifyListeners();
  }
  
  /// تعيين رسالة خطأ
  void _setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }
  
  /// مسح رسالة الخطأ
  void _clearError() {
    _error = null;
  }
  
  /// إعادة تعيين جميع البيانات
  void reset() {
    _allRequests.clear();
    _availableRequests.clear();
    _myOffers.clear();
    _completedRequests.clear();
    _isLoading = false;
    _error = null;
    _isAvailable = false;
    stopAutoRefresh();
    notifyListeners();
  }
  
  /// الحصول على إحصائيات سريعة
  Map<String, int> getQuickStats() {
    return {
      'total': _allRequests.length,
      'available': _availableRequests.length,
      'myOffers': _myOffers.length,
      'completed': _completedRequests.length,
    };
  }
  
  /// التحقق من وجود طلبات جديدة
  bool hasNewRequests(List<DeliveryRequestModel> previousRequests) {
    if (previousRequests.isEmpty && _availableRequests.isNotEmpty) {
      return true;
    }
    
    final previousIds = previousRequests.map((r) => r.id).toSet();
    final currentIds = _availableRequests.map((r) => r.id).toSet();
    
    return !currentIds.difference(previousIds).isEmpty;
  }
  
  @override
  void dispose() {
    stopAutoRefresh();
    super.dispose();
  }
}