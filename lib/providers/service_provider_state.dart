import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:saba2v2/models/service_request_model.dart';
import 'package:saba2v2/services/ar_rental_office_service.dart';

class ServiceProviderState extends ChangeNotifier {
  final CarRentalOfficeService _service;
  
  // --- [تم تعديل المتغيرات هنا] ---
  // الآن نخزن البيانات في ثلاث قوائم منفصلة
  List<ServiceRequest> _pendingRequests = [];
  List<ServiceRequest> _inProgressRequests = [];
  List<ServiceRequest> _completedRequests = [];
  
  bool _isLoading = false;
  String? _error;
  bool _disposed = false;
  
  Timer? _refreshTimer;

  ServiceProviderState({required CarRentalOfficeService service}) : _service = service;

  // --- [تم تعديل الـ Getters هنا] ---
  // الآن هذه الـ getters تقرأ مباشرة من القوائم المخزنة
  List<ServiceRequest> get pendingRequests => _pendingRequests;
  List<ServiceRequest> get inProgressRequests => _inProgressRequests;
  List<ServiceRequest> get completedRequests => _completedRequests;
  
  // Getter اختياري للحصول على كل الطلبات
  List<ServiceRequest> get allRequests => [..._pendingRequests, ..._inProgressRequests, ..._completedRequests];

  bool get isLoading => _isLoading;
  String? get error => _error;

  @override
  void dispose() {
    _disposed = true;
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  /// --- [تم تعديل هذه الدالة بالكامل] ---
  /// تجلب كل أنواع الطلبات وتخزنها في القوائم المخصصة لها
  Future<void> fetchAllRequests({bool silent = false}) async {
    if (_disposed) return;
    
    if (!silent) {
      _isLoading = true;
      _error = null;
      _safeNotifyListeners();
    }

    try {
      final results = await Future.wait([
        _service.getPendingRequests(),
        _service.getInProgressRequests(),
        _service.getCompletedRequests(),
      ]);
      
      if (_disposed) return;
      
      _pendingRequests = results[0];
      _inProgressRequests = results[1];
      _completedRequests = results[2];
      
      if (!silent) {
        debugPrint("ServiceProviderState: Fetched all lists. Pending: ${_pendingRequests.length}, In Progress: ${_inProgressRequests.length}, Completed: ${_completedRequests.length}");
      }
      
    } catch (e) {
      if (_disposed) return;
      
      if (!silent) {
        _error = e.toString();
      }
      debugPrint("ServiceProviderState Error in fetchAllRequests: $e");
    } finally {
      if (_disposed) return;
      
      if (!silent) {
        _isLoading = false;
      }
      _safeNotifyListeners();
    }
  }

  // دالة قبول الطلب (لا تحتاج تعديل)
  Future<bool> acceptRequest(int requestId) async {
    if (_disposed) return false;
    
    try {
      final result = await _service.acceptServiceRequest(requestId: requestId);
      if (result['status'] == true && !_disposed) {
        // إعادة تحميل كل شيء لضمان انتقال الطلب بين القوائم
        await fetchAllRequests(silent: true);
        return true;
      } else {
        throw Exception(result['message'] ?? 'فشل قبول الطلب من الخادم.');
      }
    } catch (e) {
      if (_disposed) return false;
      _error = e.toString();
      _safeNotifyListeners();
      return false;
    }
  }

  // دالة إنهاء الطلب (لا تحتاج تعديل)
  Future<bool> completeRequest(int requestId) async {
    if (_disposed) return false;
    
    try {
      final result = await _service.completeServiceRequest(requestId: requestId);
      if (result['status'] == true && !_disposed) {
        // إعادة تحميل كل شيء لضمان انتقال الطلب بين القوائم
        await fetchAllRequests(silent: true);
        return true;
      } else {
        throw Exception(result['message'] ?? 'فشل إنهاء الطلب من الخادم.');
      }
    } catch (e) {
      if (_disposed) return false;
      _error = e.toString();
      _safeNotifyListeners();
      return false;
    }
  }
  
  // التحديث التلقائي (لا تحتاج تعديل)
  void startAutoRefresh() {
    const refreshInterval = Duration(seconds: 30);
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(refreshInterval, (timer) {
      if (!_disposed) {
        debugPrint("ServiceProviderState: Auto-refreshing requests...");
        fetchAllRequests(silent: true);
      } else {
        timer.cancel();
      }
    });
  }
}






// import 'dart:async';
// import 'package:flutter/foundation.dart';
// import 'package:saba2v2/models/service_request_model.dart';
// import 'package:saba2v2/services/ar_rental_office_service.dart';

// class ServiceProviderState extends ChangeNotifier {
//   final CarRentalOfficeService _service;
  
//   List<ServiceRequest> _allRequests = [];
  
//   bool _isLoading = false;
//   String? _error;
//   bool _disposed = false;
  
//   // Auto-refresh system
//   Timer? _refreshTimer;
//   bool _isAutoRefreshEnabled = false;
//   static const Duration _refreshInterval = Duration(seconds: 30);

//   ServiceProviderState({required CarRentalOfficeService service}) : _service = service;

//   // Getters
//   List<ServiceRequest> get allRequests => _allRequests;
//   bool get isLoading => _isLoading;
//   String? get error => _error;
//   bool get isAutoRefreshEnabled => _isAutoRefreshEnabled;

//   // Lists filtered by status
//   List<ServiceRequest> get pendingRequests => 
//       _allRequests.where((r) => r.status == 'approved').toList();
  
//   List<ServiceRequest> get acceptedRequests => 
//       _allRequests.where((r) => r.status == 'accepted').toList();
  
//   List<ServiceRequest> get completedRequests => 
//       _allRequests.where((r) => r.status == 'completed').toList();

//   // Start auto-refresh
//   void startAutoRefresh() {
//     if (_disposed || _isAutoRefreshEnabled) return;
    
//     _isAutoRefreshEnabled = true;
//     debugPrint("ServiceProviderState: Auto-refresh started (every ${_refreshInterval.inSeconds}s)");
    
//     _refreshTimer = Timer.periodic(_refreshInterval, (timer) {
//       if (_disposed) {
//         timer.cancel();
//         return;
//       }
//       if (_isAutoRefreshEnabled) {
//         debugPrint("ServiceProviderState: Auto-refreshing requests...");
//         fetchAllRequests(silent: true);
//       }
//     });
    
//     _safeNotifyListeners();
//   }

//   // Stop auto-refresh
//   void stopAutoRefresh() {
//     if (!_isAutoRefreshEnabled) return;
    
//     _isAutoRefreshEnabled = false;
//     _refreshTimer?.cancel();
//     _refreshTimer = null;
//     debugPrint("ServiceProviderState: Auto-refresh stopped");
    
//     _safeNotifyListeners();
//   }

//   // Toggle auto-refresh
//   void toggleAutoRefresh() {
//     if (_disposed) return;
//     if (_isAutoRefreshEnabled) {
//       stopAutoRefresh();
//     } else {
//       startAutoRefresh();
//     }
//   }

//   // Fetch all requests with a single API call
//    /// --- [هذه هي النسخة المصححة للدالة] ---
//   Future<void> fetchAllRequests({bool silent = false}) async {
//     if (_disposed) return;
    
//     if (!silent) {
//       _isLoading = true;
//       _error = null;
//       _safeNotifyListeners();
//     }

//     try {
//       // 1. استدعاء كل دوال الجلب الجديدة بالتوازي باستخدام Future.wait
//       final List<List<ServiceRequest>> results = await Future.wait([
//         _service.getPendingRequests(),
//         _service.getInProgressRequests(),
//         _service.getCompletedRequests(),
//       ]);
      
//       if (_disposed) return;
      
//       // 2. دمج نتائج الثلاث قوائم في قائمة واحدة شاملة
//       final List<ServiceRequest> newRequests = [
//         ...results[0], // الطلبات قيد الانتظار
//         ...results[1], // الطلبات قيد التنفيذ
//         ...results[2], // الطلبات المنتهية
//       ];

//       // 3. بقية الكود يعمل كما هو مع القائمة الجديدة
//       final hasChanges = _hasRequestsChanged(_allRequests, newRequests);
      
//       _allRequests = newRequests;
      
//       if (hasChanges && silent) {
//         debugPrint("ServiceProviderState: Requests updated! Found ${_allRequests.length} requests");
//       } else if (!silent) {
//         debugPrint("ServiceProviderState: Fetched ${_allRequests.length} requests");
//       }
      
//     } catch (e) {
//       if (_disposed) return;
      
//       if (!silent) {
//         _error = e.toString();
//       }
//       debugPrint("ServiceProviderState Error in fetchAllRequests: $e");
//     } finally {
//       if (_disposed) return;
      
//       if (!silent) {
//         _isLoading = false;
//       }
//       _safeNotifyListeners();
//     }
//   }

//   // تأكدي من أن هذه الدالة موجودة وتعمل بشكل صحيح
//   bool _hasRequestsChanged(List<ServiceRequest> oldList, List<ServiceRequest> newList) {
//     if (oldList.length != newList.length) return true;
//     // يمكنك إضافة منطق مقارنة أكثر تعقيدًا هنا إذا أردتِ
//     return false;
//   }// Check if requests have changed
//   // bool _hasRequestsChanged(List<ServiceRequest> oldRequests, List<ServiceRequest> newRequests) {
//   //   if (oldRequests.length != newRequests.length) return true;
    
//   //   for (int i = 0; i < oldRequests.length; i++) {
//   //     if (oldRequests[i].id != newRequests[i].id || 
//   //         oldRequests[i].status != newRequests[i].status ||
//   //         oldRequests[i].createdAt != newRequests[i].createdAt) {
//   //       return true;
//   //     }
//   //   }
    
//   //   return false;
//   // }

//   // Accept a request and refresh the list
//    /// --- [هذه هي النسخة المصححة للدالة] ---
//   Future<bool> acceptRequest(int requestId) async {
//     if (_disposed) return false;

//     // يمكنك إضافة متغير تحميل هنا إذا أردتِ
//     // _isLoading = true;
//     // _safeNotifyListeners();

//     try {
//       // 1. استدعاء الخدمة، الآن `result` هو Map
//       final result = await _service.acceptServiceRequest(requestId: requestId);

//       // 2. التحقق من مفتاح 'status' داخل الـ Map
//       if (result['status'] == true && !_disposed) {
//         // إذا نجح الطلب، قم بتحديث القوائم
//         await fetchAllRequests(silent: true);
//         debugPrint("ServiceProviderState: Successfully accepted request $requestId. Message: ${result['message']}");
        
//         // إيقاف التحميل وإرجاع true للنجاح
//         // _isLoading = false;
//         // _safeNotifyListeners();
//         return true;
//       } else {
//         // إذا كان status هو false أو غير موجود
//         throw Exception(result['message'] ?? 'فشل قبول الطلب من الخادم.');
//       }

//     } catch (e) {
//       if (_disposed) return false;
      
//       _error = e.toString();
//       debugPrint("ServiceProviderState Error (acceptRequest): $_error");
//       // _isLoading = false;
//       _safeNotifyListeners();
//       return false; // إرجاع false للفشل
//     }
//   }// Complete a request and refresh the list
//     /// --- [هذه هي النسخة المصححة للدالة] ---
//   Future<bool> completeRequest(int requestId) async {
//     if (_disposed) return false;

//     try {
//       // 1. استدعاء الخدمة، الآن `result` هو Map
//       final result = await _service.completeServiceRequest(requestId: requestId);

//       // 2. التحقق من مفتاح 'status' داخل الـ Map
//       if (result['status'] == true && !_disposed) {
//         // إذا نجح الطلب، قم بتحديث القوائم
//         await fetchAllRequests(silent: true);
//         debugPrint("ServiceProviderState: Successfully completed request $requestId. Message: ${result['message']}");
        
//         // إرجاع true للنجاح
//         return true;
//       } else {
//         // إذا كان status هو false أو غير موجود
//         throw Exception(result['message'] ?? 'فشل إنهاء الطلب من الخادم.');
//       }

//     } catch (e) {
//       if (_disposed) return false;
      
//       _error = e.toString();
//       debugPrint("ServiceProviderState Error (completeRequest): $_error");
//       _safeNotifyListeners();
//       return false; // إرجاع false للفشل
//     }
//   }// Update availability
//   Future<bool> updateAvailability({
//     required int officeDetailId,
//     bool? isAvailableForDelivery,
//     bool? isAvailableForRent,
//   }) async {
//     if (_disposed) return false;
    
//     try {
//       final success = await _service.updateAvailability(
//         officeDetailId: officeDetailId,
//         isAvailableForDelivery: isAvailableForDelivery,
//         isAvailableForRent: isAvailableForRent,
//       );
      
//       if (success) {
//         debugPrint("ServiceProviderState: Successfully updated availability");
//       }
      
//       return success;
//     } catch (e) {
//       if (_disposed) return false;
      
//       _error = e.toString();
//       debugPrint("ServiceProviderState Error (updateAvailability): $e");
//       _safeNotifyListeners();
//       return false;
//     }
//   }

//   // Safe notify listeners - only if not disposed
//   void _safeNotifyListeners() {
//     if (!_disposed) {
//       notifyListeners();
//     }
//   }

//   // Clear error
//   void clearError() {
//     if (_disposed) return;
//     _error = null;
//     _safeNotifyListeners();
//   }

//   // Update a specific request in the list
//   void updateRequest(ServiceRequest updatedRequest) {
//     if (_disposed) return;
//     final index = _allRequests.indexWhere((request) => request.id == updatedRequest.id);
//     if (index != -1) {
//       _allRequests[index] = updatedRequest;
//       _safeNotifyListeners();
//     }
//   }

//   // Clean up resources
//   @override
//   void dispose() {
//     _disposed = true;
//     stopAutoRefresh();
//     super.dispose();
//   }
// }