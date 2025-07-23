import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Base URL for the Laravel API
const String baseUrl = 'http://192.168.1.7:8000'; // Replace with your actual API base URL

class LaravelService {
  // Register a normal user
  Future<Map<String, dynamic>> registerNormalUser({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String governorate,
    required String userType,
  }) async {
    try {
      final Map<String, String> body = {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'governorate': governorate,
        'user_type': userType,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['user'] != null && responseData['user']['token'] != null) {
          await _saveToken(responseData['user']['token']);
        }
        return {
          'status': responseData['status'] ?? true,
          'message': responseData['message'] ?? 'Registration successful',
          'user': responseData['user'],
        };
      } else {
        throw Exception(responseData['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Error during registration: $e');
    }
  }

  // Register a real estate office
  Future<Map<String, dynamic>> registerRealstateOffice({
    required String username,
    required String email,
    required String password,
    required String phone,
    required String city,
    required String address,
    required bool vat,
    required String officeLogoPath,
    required String ownerIdFrontPath,
    required String ownerIdBackPath,
    required String officeImagePath,
    required String commercialCardFrontPath,
    required String commercialCardBackPath,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'name': username,
        'email': email,
        'password': password,
        'phone': phone,
        'governorate': city,
        'user_type': 'real_estate_office',
        'office_name': username,
        'office_address': address,
        'office_phone': phone,
        'logo_image': officeLogoPath,
        'owner_id_front_image': ownerIdFrontPath,
        'owner_id_back_image': ownerIdBackPath,
        'office_image': officeImagePath,
        'commercial_register_front_image': commercialCardFrontPath,
        'commercial_register_back_image': commercialCardBackPath,
        'tax_enabled': vat,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['user'] != null && responseData['user']['token'] != null) {
          await _saveToken(responseData['user']['token']);
        }
        return {
          'status': responseData['status'] ?? true,
          'message': responseData['message'] ?? 'Registration successful',
          'user': responseData['user'],
        };
      } else {
        throw Exception(responseData['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Error during registration: $e');
    }
  }

  // Login user
  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final Map<String, String> body = {
        'identifier': identifier,
        'password': password,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseData['user'] != null && responseData['user']['token'] != null) {
          await _saveToken(responseData['user']['token']);
        }
        return {
          'status': responseData['status'] ?? true,
          'message': responseData['message'] ?? 'Login successful',
          'user': responseData['user'],
        };
      } else {
        throw Exception(responseData['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Error during login: $e');
    }
  }

  // Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        await prefs.remove('token'); // Remove token on successful logout
        await prefs.remove('user_data'); // Optional: Remove user data
      } else {
        throw Exception('Logout failed');
      }
    } catch (e) {
      throw Exception('Error during logout: $e');
    }
  }

  // Save token to SharedPreferences
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // Get token from SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Get user data from SharedPreferences
  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');
    return userDataString != null ? jsonDecode(userDataString) : null;
  }

  // Save user data to SharedPreferences (call this after login/register if needed)
  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(userData));
  }
}