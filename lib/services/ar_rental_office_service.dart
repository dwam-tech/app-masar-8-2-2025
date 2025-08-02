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
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true && data['requests'] != null) {
          return (data['requests'] as List)
              .map((json) => ServiceRequest.fromJson(json))
              .toList();
        }
        return [];
      } else {
        throw Exception('Failed to load requests: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching requests: $e');
      throw Exception('Network error: $e');
    }
  }

  /// Accepts a service request
  Future<bool> acceptServiceRequest({required int requestId}) async {
    final url = Uri.parse('http://192.168.1.7:8000/api/provider/service-requests/accept');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'request_id': requestId}),
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) print('Error accepting request: $e');
      return false;
    }
  }

  /// Completes a service request
  Future<bool> completeServiceRequest({required int requestId}) async {
    final url = Uri.parse('http://192.168.1.7:8000/api/provider/service-requests/complete');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'request_id': requestId}),
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) print('Error completing request: $e');
      return false;
    }
  }

  /// Updates availability for delivery and rental services
  Future<bool> updateAvailability({
    required int officeDetailId,
    bool? isAvailableForDelivery,
    bool? isAvailableForRent,
  }) async {
    final availabilityUrl = Uri.parse('http://192.168.1.7:8000/api/car-rental-office-detail/$officeDetailId/availability');

    final body = {
      if (isAvailableForDelivery != null) "is_available_for_delivery": isAvailableForDelivery,
      if (isAvailableForRent != null) "is_available_for_rent": isAvailableForRent,
    };

    try {
      final response = await http.patch(
        availabilityUrl,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "application/json"
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['status'] == true;
      } else {
        throw Exception("Failed to update availability: ${response.body}");
      }
    } catch (e) {
      if (kDebugMode) print('Error updating availability: $e');
      return false;
    }
  }
}