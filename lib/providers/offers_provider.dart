import 'package:flutter/material.dart';
import '../models/delivery_request_model.dart';
import '../models/offer_model.dart';
import '../services/offers_service.dart';
import '../services/realtime_service.dart';
import '../services/error_handling_service.dart';
import '../services/validation_service.dart';
import 'dart:async';

class OffersProvider with ChangeNotifier {
  final OffersService _offersService = OffersService();
  final RealtimeService _realtimeService = RealtimeService();
  final ErrorHandlingService _errorHandler = ErrorHandlingService();
  
  // State variables
  DeliveryRequestModel? _deliveryRequest;
  List<OfferModel> _offers = [];
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _error;
  String? _lastMessage;
  Timer? _autoRefreshTimer;
  
  // Real-time subscriptions
  StreamSubscription<OfferModel>? _newOfferSubscription;
  StreamSubscription<DeliveryRequestModel>? _requestUpdateSubscription;
  StreamSubscription<int>? _offerRemovedSubscription;
  
  // Getters
  DeliveryRequestModel? get deliveryRequest => _deliveryRequest;
  List<OfferModel> get offers => _offers;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get error => _error;
  String? get errorMessage => _error;
  String? get lastMessage => _lastMessage;
  bool get hasData => _deliveryRequest != null;
  bool get hasOffers => _offers.isNotEmpty;
  bool get isRequestAccepted => _deliveryRequest?.status == 'accepted_waiting_driver' || 
                                _deliveryRequest?.status == 'in_progress' ||
                                _deliveryRequest?.status == 'delivered';
  
  // Load delivery request and offers
  Future<void> loadDeliveryRequestWithOffers(String requestId) async {
    return loadDeliveryRequestAndOffers(requestId);
  }

  Future<void> loadDeliveryRequestAndOffers(String requestId) async {
    _setLoading(true);
    _clearError();
    
    try {
      // التحقق من الاتصال بالإنترنت
      final hasConnection = await _errorHandler.hasInternetConnection();
      if (!hasConnection) {
        throw Exception('لا يوجد اتصال بالإنترنت');
      }
      
      // تنفيذ العملية مع إعادة المحاولة
      final result = await _errorHandler.executeWithRetry<Map<String, dynamic>>(
        () => _offersService.getDeliveryRequestWithOffers(requestId),
        maxRetries: 3,
        shouldRetry: (error) => error is! FormatException,
      );
      
      if (result != null && result['status'] == true) {
        final data = result['data'];
        if (data != null) {
          _deliveryRequest = data['delivery_request'];
          _offers = List<OfferModel>.from(
            (data['offers'] ?? []).map((offer) => OfferModel.fromJson(offer))
          );
          
          // إذا لم تكن هناك عروض، لا نعتبر هذا خطأ
          // بل نعرض الرسالة التوضيحية من الخادم
          if (_offers.isEmpty && result['message'] != null) {
            // نحفظ الرسالة التوضيحية بدلاً من رسالة خطأ
            _lastMessage = result['message'];
          }
          
          _startAutoRefresh(requestId);
          _startRealtimeMonitoring(requestId);
        } else {
          _setError('لا توجد بيانات متاحة للطلب');
        }
      } else {
        _setError(result?['message'] ?? 'حدث خطأ في تحميل البيانات');
      }
    } catch (e) {
      _setError(_errorHandler.handleApiError(e));
      _errorHandler.logError(e, StackTrace.current);
    } finally {
      _setLoading(false);
    }
  }
  
  // Refresh offers
  Future<void> refreshOffers(String requestId) async {
    return refreshData(requestId);
  }

  // Refresh data
  Future<void> refreshData(String requestId) async {
    if (_isRefreshing) return;
    
    _setRefreshing(true);
    _clearError();
    
    try {
      final result = await _offersService.refreshDeliveryRequestStatus(requestId);
      
      if (result['success']) {
        _deliveryRequest = result['deliveryRequest'];
        _offers = result['offers'] ?? [];
        
        // تحديث lastMessage من الخادم
        if (result['message'] != null) {
          _lastMessage = result['message'];
        }
      } else {
        _setError(result['message'] ?? 'حدث خطأ في تحديث البيانات');
        _lastMessage = result['message'];
      }
    } catch (e) {
      _setError('حدث خطأ في الاتصال بالخادم');
    } finally {
      _setRefreshing(false);
    }
  }
  
  // Accept offer
  Future<bool> acceptOffer(String requestId, String offerId) async {
    _setLoading(true);
    _clearError();
    
    try {
      // التحقق من صحة معرف العرض
      if (offerId.isEmpty) {
        throw ArgumentError('معرف العرض غير صحيح');
      }
      
      // التحقق من وجود العرض
      final offerExists = _offers.any((offer) => offer.id == offerId);
      if (!offerExists) {
        throw Exception('العرض غير موجود');
      }
      
      // تنفيذ العملية مع إعادة المحاولة
      final result = await _errorHandler.executeWithRetry<Map<String, dynamic>>(
        () => _offersService.acceptOffer(requestId, offerId),
        maxRetries: 2,
        shouldRetry: (error) => !error.toString().contains('401'),
      );
      
      if (result != null && result['success']) {
        // Update local state
        _deliveryRequest = result['deliveryRequest'];
        _offers.clear(); // Clear offers as request is now accepted
        _stopAutoRefresh(); // Stop auto refresh as request is accepted
        return true;
      } else {
        _setError(result?['message'] ?? 'حدث خطأ في قبول العرض');
        return false;
      }
    } catch (e) {
      _setError(_errorHandler.handleApiError(e));
      _errorHandler.logError(e, StackTrace.current);
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Cancel delivery request
  Future<bool> cancelDeliveryRequest(String requestId, String reason) async {
    _setLoading(true);
    _clearError();
    
    try {
      // التحقق من حالة الطلب
      if (_deliveryRequest?.status == 'cancelled') {
        _setError('الطلب ملغى مسبقاً');
        return false;
      }
      
      if (_deliveryRequest?.status == 'completed') {
        _setError('لا يمكن إلغاء طلب مكتمل');
        return false;
      }
      
      // تنفيذ العملية مع إعادة المحاولة
      final result = await _errorHandler.executeWithRetry<Map<String, dynamic>>(
        () => _offersService.cancelDeliveryRequest(requestId, reason),
        maxRetries: 2,
        shouldRetry: (error) => !error.toString().contains('404'),
      );
      
      if (result != null && result['success']) {
        // Update local state
        _deliveryRequest = result['deliveryRequest'];
        _offers.clear(); // Clear offers as request is cancelled
        _stopAutoRefresh(); // Stop auto refresh as request is cancelled
        return true;
      } else {
        _setError(result?['message'] ?? 'حدث خطأ في إلغاء الطلب');
        return false;
      }
    } catch (e) {
      _setError(_errorHandler.handleApiError(e));
      _errorHandler.logError(e, StackTrace.current);
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Start auto refresh timer
  void _startAutoRefresh(String requestId) {
    _stopAutoRefresh(); // Stop any existing timer
    
    if (!isRequestAccepted) {
      _autoRefreshTimer = Timer.periodic(
        const Duration(seconds: 30), // Reduced frequency due to real-time updates
        (timer) async {
          if (!isRequestAccepted) {
            await refreshData(requestId);
          } else {
            _stopAutoRefresh();
          }
        },
      );
    }
  }
  
  // Start real-time monitoring
  void _startRealtimeMonitoring(String requestId) {
    _stopRealtimeMonitoring(); // Stop any existing monitoring
    
    if (!isRequestAccepted) {
      _realtimeService.startMonitoring(requestId);
      
      // Listen to new offers
      _newOfferSubscription = _realtimeService.listenToNewOffers((offer) {
        addOffer(offer);
      });
      
      // Listen to request updates
      _requestUpdateSubscription = _realtimeService.listenToRequestUpdates((request) {
        updateDeliveryRequestStatus(request);
      });
      
      // Listen to offer removals
      _offerRemovedSubscription = _realtimeService.listenToOfferRemovals((offerId) {
        removeOffer(offerId);
      });
    }
  }
  
  // Stop auto refresh timer
  void _stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
  }
  
  // Stop real-time monitoring
  void _stopRealtimeMonitoring() {
    _realtimeService.stopMonitoring();
    _newOfferSubscription?.cancel();
    _requestUpdateSubscription?.cancel();
    _offerRemovedSubscription?.cancel();
    _newOfferSubscription = null;
    _requestUpdateSubscription = null;
    _offerRemovedSubscription = null;
  }
  
  // Add new offer (for real-time updates)
  void addOffer(OfferModel offer) {
    if (!_offers.any((o) => o.id == offer.id)) {
      _offers.add(offer);
      _offers.sort((a, b) => a.offeredPrice.compareTo(b.offeredPrice));
      notifyListeners();
    }
  }
  
  // Remove offer
  void removeOffer(int offerId) {
    _offers.removeWhere((offer) => offer.id == offerId);
    notifyListeners();
  }
  
  // Update offer
  void updateOffer(OfferModel updatedOffer) {
    final index = _offers.indexWhere((offer) => offer.id == updatedOffer.id);
    if (index != -1) {
      _offers[index] = updatedOffer;
      notifyListeners();
    }
  }
  
  // Update delivery request status
  void updateDeliveryRequestStatus(DeliveryRequestModel updatedRequest) {
    _deliveryRequest = updatedRequest;
    
    // If request is accepted, clear offers and stop monitoring
    if (isRequestAccepted) {
      _offers.clear();
      _stopAutoRefresh();
      _stopRealtimeMonitoring();
    }
    
    notifyListeners();
  }
  
  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setRefreshing(bool refreshing) {
    _isRefreshing = refreshing;
    notifyListeners();
  }
  
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
    _lastMessage = null;
  }
  
  // Clear all data
  void clearData() {
    _deliveryRequest = null;
    _offers.clear();
    _isLoading = false;
    _isRefreshing = false;
    _error = null;
    _lastMessage = null;
    _stopAutoRefresh();
    _stopRealtimeMonitoring();
    notifyListeners();
  }
  
  // Get offers count
  int get offersCount => _offers.length;
  
  // Get lowest offer price
  double? get lowestOfferPrice {
    if (_offers.isEmpty) return null;
    return _offers.map((offer) => offer.offeredPrice).reduce((a, b) => a < b ? a : b);
  }
  
  // Get highest offer price
  double? get highestOfferPrice {
    if (_offers.isEmpty) return null;
    return _offers.map((offer) => offer.offeredPrice).reduce((a, b) => a > b ? a : b);
  }
  
  // Get average offer price
  double? get averageOfferPrice {
    if (_offers.isEmpty) return null;
    final total = _offers.fold<double>(0, (sum, offer) => sum + offer.offeredPrice);
    return total / _offers.length;
  }
  
  // Filter offers by price range
  List<OfferModel> getOffersByPriceRange(double minPrice, double maxPrice) {
    return _offers.where((offer) => 
      offer.offeredPrice >= minPrice && offer.offeredPrice <= maxPrice
    ).toList();
  }
  
  // Sort offers by price (ascending)
  void sortOffersByPriceAsc() {
    _offers.sort((a, b) => a.offeredPrice.compareTo(b.offeredPrice));
    notifyListeners();
  }
  
  // Sort offers by price (descending)
  void sortOffersByPriceDesc() {
    _offers.sort((a, b) => b.offeredPrice.compareTo(a.offeredPrice));
    notifyListeners();
  }
  
  // Sort offers by rating (descending)
  void sortOffersByRating() {
    _offers.sort((a, b) => (b.driverRating ?? 0).compareTo(a.driverRating ?? 0));
    notifyListeners();
  }
  
  @override
  void dispose() {
    _stopAutoRefresh();
    _stopRealtimeMonitoring();
    super.dispose();
  }
}