// lib/services/car_rental_office_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/service_request_model.dart';

class CarRentalOfficeService {
  final String _apiBaseUrl = "http://192.168.1.7:8000/api/provider/service-requests";
  final String token;

  CarRentalOfficeService({required this.token});

  /// Fetches ALL available service requests for the logged-in provider.
  /// The backend automatically filters by provider type (office/driver).
  Future<List<ServiceRequest>> getAvailableRequests() async {
    final url = Uri.parse(_apiBaseUrl); 
    try {
      final response = await http.get(url, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final decodedBody = jsonDecode(response.body);
        
        if (decodedBody['status'] == true && decodedBody['requests'] != null) {
          final List<dynamic> requestsList = decodedBody['requests'];
          return requestsList.map((json) => ServiceRequest.fromJson(json)).toList();
        } else {
          // Handle cases where 'status' is false or 'requests' key is missing
          return [];
        }
      } else {
        // Handle HTTP errors like 401, 500 etc.
        debugPrint("API Error (getAvailableRequests): Status ${response.statusCode}, Body: ${response.body}");
        throw Exception('Failed to fetch requests.');
      }
    } catch (e) {
      debugPrint("Exception in getAvailableRequests: $e");
      rethrow; // Rethrow to be handled by the provider
    }
  }

  // Action methods (accept, complete) can remain the same.
  Future<void> acceptServiceRequest({required int requestId}) async {
    // ... POST action logic
  }

  Future<void> completeServiceRequest({required int requestId}) async {
    // ... POST action logic
  }
}