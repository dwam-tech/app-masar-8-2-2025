import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';

class SecurityPermitService {
  static Future<Map<String, dynamic>> submitPermit(Map<String, dynamic> data) async {
    final uri = Uri.parse('${AppConstants.apiBaseUrl}/security-permits');
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.userTokenKey);

    if (token == null) {
      throw Exception('User is not authenticated.');
    }

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(data),
    );

    final responseData = json.decode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return responseData;
    } else {
      // رمي خطأ يحتوي على رسالة الخادم
      throw Exception(responseData['message'] ?? 'Failed to submit security permit.');
    }
  }
}