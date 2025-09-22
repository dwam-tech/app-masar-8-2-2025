import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/offer_model.dart';
import '../models/delivery_request_model.dart';
import 'offers_service.dart';

class RealtimeService {
  static final RealtimeService _instance = RealtimeService._internal();
  factory RealtimeService() => _instance;
  RealtimeService._internal();
  
  Timer? _pollingTimer;
  final OffersService _offersService = OffersService();
  
  // Stream controllers for real-time updates
  final StreamController<OfferModel> _newOfferController = StreamController<OfferModel>.broadcast();
  final StreamController<DeliveryRequestModel> _requestUpdateController = StreamController<DeliveryRequestModel>.broadcast();
  final StreamController<int> _offerRemovedController = StreamController<int>.broadcast();
  
  // Streams
  Stream<OfferModel> get newOfferStream => _newOfferController.stream;
  Stream<DeliveryRequestModel> get requestUpdateStream => _requestUpdateController.stream;
  Stream<int> get offerRemovedStream => _offerRemovedController.stream;
  
  // Current state tracking
  String? _currentRequestId;
  List<int> _knownOfferIds = [];
  String? _lastRequestStatus;
  
  // Start real-time monitoring for a delivery request
  void startMonitoring(String requestId) {
    if (_currentRequestId == requestId && _pollingTimer?.isActive == true) {
      return; // Already monitoring this request
    }
    
    stopMonitoring(); // Stop any existing monitoring
    
    _currentRequestId = requestId;
    _knownOfferIds.clear();
    _lastRequestStatus = null;
    
    // Start polling every 10 seconds
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 10),
      (timer) => _pollForUpdates(requestId),
    );
    
    // Initial poll
    _pollForUpdates(requestId);
    
    if (kDebugMode) {
      print('RealtimeService: Started monitoring request $requestId');
    }
  }
  
  // Stop real-time monitoring
  void stopMonitoring() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _currentRequestId = null;
    _knownOfferIds.clear();
    _lastRequestStatus = null;
    
    if (kDebugMode) {
      print('RealtimeService: Stopped monitoring');
    }
  }
  
  // Poll for updates
  Future<void> _pollForUpdates(String requestId) async {
    try {
      final result = await _offersService.getDeliveryRequestWithOffers(requestId);
      
      if (result['success']) {
        final deliveryRequest = result['deliveryRequest'] as DeliveryRequestModel?;
        final offers = result['offers'] as List<OfferModel>? ?? [];
        
        if (deliveryRequest != null) {
          // Check for request status changes
          if (_lastRequestStatus != deliveryRequest.status) {
            _lastRequestStatus = deliveryRequest.status;
            _requestUpdateController.add(deliveryRequest);
            
            // Stop monitoring if request is no longer pending offers
            if (deliveryRequest.status != 'pending_offers') {
              stopMonitoring();
              return;
            }
          }
          
          // Check for new offers
          final currentOfferIds = offers.map((offer) => offer.id).toList();
          
          // Find new offers
          for (final offer in offers) {
            if (!_knownOfferIds.contains(offer.id)) {
              _newOfferController.add(offer);
              if (kDebugMode) {
                print('RealtimeService: New offer detected: ${offer.id}');
              }
            }
          }
          
          // Find removed offers
          for (final knownId in _knownOfferIds) {
            if (!currentOfferIds.contains(knownId)) {
              _offerRemovedController.add(knownId);
              if (kDebugMode) {
                print('RealtimeService: Offer removed: $knownId');
              }
            }
          }
          
          // Update known offer IDs
          _knownOfferIds = currentOfferIds;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('RealtimeService: Error polling for updates: $e');
      }
    }
  }
  
  // Manually trigger an update check
  Future<void> checkForUpdates() async {
    if (_currentRequestId != null) {
      await _pollForUpdates(_currentRequestId!);
    }
  }
  
  // Get current monitoring status
  bool get isMonitoring => _pollingTimer?.isActive == true;
  String? get currentRequestId => _currentRequestId;
  
  // Simulate real-time offer (for testing)
  void simulateNewOffer(OfferModel offer) {
    if (kDebugMode) {
      _newOfferController.add(offer);
      print('RealtimeService: Simulated new offer: ${offer.id}');
    }
  }
  
  // Simulate request update (for testing)
  void simulateRequestUpdate(DeliveryRequestModel request) {
    if (kDebugMode) {
      _requestUpdateController.add(request);
      print('RealtimeService: Simulated request update: ${request.status}');
    }
  }
  
  // Dispose resources
  void dispose() {
    stopMonitoring();
    _newOfferController.close();
    _requestUpdateController.close();
    _offerRemovedController.close();
  }
}

// Extension for easier integration with providers
extension RealtimeServiceExtension on RealtimeService {
  // Start monitoring with automatic cleanup
  StreamSubscription<OfferModel> listenToNewOffers(
    void Function(OfferModel offer) onNewOffer,
  ) {
    return newOfferStream.listen(onNewOffer);
  }
  
  StreamSubscription<DeliveryRequestModel> listenToRequestUpdates(
    void Function(DeliveryRequestModel request) onRequestUpdate,
  ) {
    return requestUpdateStream.listen(onRequestUpdate);
  }
  
  StreamSubscription<int> listenToOfferRemovals(
    void Function(int offerId) onOfferRemoved,
  ) {
    return offerRemovedStream.listen(onOfferRemoved);
  }
}