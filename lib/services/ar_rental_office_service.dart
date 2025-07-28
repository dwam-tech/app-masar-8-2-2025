import 'dart:convert';
import 'package:http/http.dart' as http;

class CarRentalOfficeService {
  final String _baseUrl = "http://192.168.1.7:8000";
  final String token;

  CarRentalOfficeService({required this.token});

  Future<bool> updateAvailability({
    required int officeDetailId,
    bool? isAvailableForDelivery,
    bool? isAvailableForRent,
  }) async {
    final url = Uri.parse('$_baseUrl/api/car-rental-office-detail/$officeDetailId/availability');

    final body = {
      if (isAvailableForDelivery != null) "is_available_for_delivery": isAvailableForDelivery,
      if (isAvailableForRent != null) "is_available_for_rent": isAvailableForRent,
    };

    final response = await http.patch(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "Content-Type": "application/json"
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['status'] == true;
    } else {
      throw Exception("Failed to update availability: ${response.body}");
    }
  }
}
