import 'package:saba2v2/services/laravel_service.dart'; // Replace with your actual path

class AuthService {
  final LaravelService _laravelService = LaravelService();

  // Register a normal user
  Future<Map<String, dynamic>> registerNormalUser({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String governorate,
  }) async {
    try {
      final result = await _laravelService.registerNormalUser(
        name: name,
        email: email,
        password: password,
        phone: phone,
        governorate: governorate,
        userType: 'normal',
      );
      return {
        'status': result['status'],
        'message': result['message'],
        'user': result['user'],
      };
    } catch (e) {
      return {
        'status': false,
        'message': e.toString().replaceFirst('Exception: ', ''),
        'user': null,
      };
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
      final result = await _laravelService.registerRealstateOffice(
        username: username,
        email: email,
        password: password,
        phone: phone,
        city: city,
        address: address,
        vat: vat,
        officeLogoPath: officeLogoPath,
        ownerIdFrontPath: ownerIdFrontPath,
        ownerIdBackPath: ownerIdBackPath,
        officeImagePath: officeImagePath,
        commercialCardFrontPath: commercialCardFrontPath,
        commercialCardBackPath: commercialCardBackPath,
      );
      return {
        'status': result['status'],
        'message': result['message'],
        'user': result['user'],
      };
    } catch (e) {
      return {
        'status': false,
        'message': e.toString().replaceFirst('Exception: ', ''),
        'user': null,
      };
    }
  }

  // Login user
  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final result = await _laravelService.login(
        identifier: identifier,
        password: password,
      );
      return {
        'status': result['status'],
        'message': result['message'],
        'user': result['user'],
      };
    } catch (e) {
      return {
        'status': false,
        'message': e.toString().replaceFirst('Exception: ', ''),
        'user': null,
      };
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      await _laravelService.logout();
    } catch (e) {
      throw Exception('Error during logout: $e');
    }
  }

  // Get token from SharedPreferences
  Future<String?> getToken() async {
    return await _laravelService.getToken();
  }

  // Get user data from SharedPreferences
  Future<Map<String, dynamic>?> getUserData() async {
    return await _laravelService.getUserData();
  }
}