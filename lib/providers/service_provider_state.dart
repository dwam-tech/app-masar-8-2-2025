import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:saba2v2/models/service_request_model.dart';
import 'package:saba2v2/services/ar_rental_office_service.dart';

class ServiceProviderState extends ChangeNotifier {
  final CarRentalOfficeService _service;
  
  List<ServiceRequest> _allRequests = [];
  bool _isLoading = false;
  String? _error;
  bool _disposed = false;
  
  // Auto-refresh system
  Timer? _refreshTimer;
  bool _isAutoRefreshEnabled = false;
  static const Duration _refreshInterval = Duration(seconds: 30);

  ServiceProviderState({required CarRentalOfficeService service}) : _service = service;

  // Getters
  List<ServiceRequest> get allRequests => _allRequests;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAutoRefreshEnabled => _isAutoRefreshEnabled;

  // Lists filtered by status
  List<ServiceRequest> get pendingRequests => 
      _allRequests.where((r) => r.status == 'approved').toList();
  
  List<ServiceRequest> get acceptedRequests => 
      _allRequests.where((r) => r.status == 'accepted').toList();
  
  List<ServiceRequest> get completedRequests => 
      _allRequests.where((r) => r.status == 'completed').toList();

  // Start auto-refresh
  void startAutoRefresh() {
    if (_disposed || _isAutoRefreshEnabled) return;
    
    _isAutoRefreshEnabled = true;
    debugPrint("ServiceProviderState: Auto-refresh started (every ${_refreshInterval.inSeconds}s)");
    
    _refreshTimer = Timer.periodic(_refreshInterval, (timer) {
      if (_disposed) {
        timer.cancel();
        return;
      }
      if (_isAutoRefreshEnabled) {
        debugPrint("ServiceProviderState: Auto-refreshing requests...");
        fetchAllRequests(silent: true);
      }
    });
    
    _safeNotifyListeners();
  }

  // Stop auto-refresh
  void stopAutoRefresh() {
    if (!_isAutoRefreshEnabled) return;
    
    _isAutoRefreshEnabled = false;
    _refreshTimer?.cancel();
    _refreshTimer = null;
    debugPrint("ServiceProviderState: Auto-refresh stopped");
    
    _safeNotifyListeners();
  }

  // Toggle auto-refresh
  void toggleAutoRefresh() {
    if (_disposed) return;
    if (_isAutoRefreshEnabled) {
      stopAutoRefresh();
    } else {
      startAutoRefresh();
    }
  }

  // Fetch all requests with a single API call
  Future<void> fetchAllRequests({bool silent = false}) async {
    if (_disposed) return;
    
    if (!silent) {
      _isLoading = true;
      _error = null;
      _safeNotifyListeners();
    }

    try {
      final newRequests = await _service.getAvailableRequests();
      
      if (_disposed) return;
      
      // Check for changes to detect updates
      final hasChanges = _hasRequestsChanged(_allRequests, newRequests);
      
      _allRequests = newRequests;
      
      if (hasChanges && silent) {
        debugPrint("ServiceProviderState: Requests updated! Found ${_allRequests.length} requests");
      } else if (!silent) {
        debugPrint("ServiceProviderState: Fetched ${_allRequests.length} requests");
      }
      
    } catch (e) {
      if (_disposed) return;
      
      if (!silent) {
        _error = e.toString();
      }
      debugPrint("ServiceProviderState Error: $e");
    } finally {
      if (_disposed) return;
      
      if (!silent) {
        _isLoading = false;
      }
      _safeNotifyListeners();
    }
  }

  // Check if requests have changed
  bool _hasRequestsChanged(List<ServiceRequest> oldRequests, List<ServiceRequest> newRequests) {
    if (oldRequests.length != newRequests.length) return true;
    
    for (int i = 0; i < oldRequests.length; i++) {
      if (oldRequests[i].id != newRequests[i].id || 
          oldRequests[i].status != newRequests[i].status ||
          oldRequests[i].createdAt != newRequests[i].createdAt) {
        return true;
      }
    }
    
    return false;
  }

  // Accept a request and refresh the list
  Future<bool> acceptRequest(int requestId) async {
    if (_disposed) return false;
    
    try {
      final success = await _service.acceptServiceRequest(requestId: requestId);
      if (success && !_disposed) {
        // Refresh the list to see the change
        await fetchAllRequests(silent: true);
        debugPrint("ServiceProviderState: Successfully accepted request $requestId");
      }
      return success;
    } catch (e) {
      if (_disposed) return false;
      
      _error = e.toString();
      debugPrint("ServiceProviderState Error (acceptRequest): $e");
      _safeNotifyListeners();
      return false;
    }
  }

  // Complete a request and refresh the list
  Future<bool> completeRequest(int requestId) async {
    if (_disposed) return false;
    
    try {
      final success = await _service.completeServiceRequest(requestId: requestId);
      if (success && !_disposed) {
        // Refresh the list to see the change
        await fetchAllRequests(silent: true);
        debugPrint("ServiceProviderState: Successfully completed request $requestId");
      }
      return success;
    } catch (e) {
      if (_disposed) return false;
      
      _error = e.toString();
      debugPrint("ServiceProviderState Error (completeRequest): $e");
      _safeNotifyListeners();
      return false;
    }
  }

  // Update availability
  Future<bool> updateAvailability({
    required int officeDetailId,
    bool? isAvailableForDelivery,
    bool? isAvailableForRent,
  }) async {
    if (_disposed) return false;
    
    try {
      final success = await _service.updateAvailability(
        officeDetailId: officeDetailId,
        isAvailableForDelivery: isAvailableForDelivery,
        isAvailableForRent: isAvailableForRent,
      );
      
      if (success) {
        debugPrint("ServiceProviderState: Successfully updated availability");
      }
      
      return success;
    } catch (e) {
      if (_disposed) return false;
      
      _error = e.toString();
      debugPrint("ServiceProviderState Error (updateAvailability): $e");
      _safeNotifyListeners();
      return false;
    }
  }

  // Safe notify listeners - only if not disposed
  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    if (_disposed) return;
    _error = null;
    _safeNotifyListeners();
  }

  // Update a specific request in the list
  void updateRequest(ServiceRequest updatedRequest) {
    if (_disposed) return;
    final index = _allRequests.indexWhere((request) => request.id == updatedRequest.id);
    if (index != -1) {
      _allRequests[index] = updatedRequest;
      _safeNotifyListeners();
    }
  }

  // Clean up resources
  @override
  void dispose() {
    _disposed = true;
    stopAutoRefresh();
    super.dispose();
  }
}