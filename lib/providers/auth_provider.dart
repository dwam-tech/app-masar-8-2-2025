import 'package:flutter/foundation.dart';
import 'package:saba2v2/services/auth_service.dart'; // Replace with your actual path

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoggedIn = false;
  Map<String, dynamic>? _userData;
  String? _token;

  bool get isLoggedIn => _isLoggedIn;
  Map<String, dynamic>? get userData => _userData;
  String? get token => _token;

  // تهيئة الحالة عند بدء التطبيق
  Future<void> initialize() async {
    await _loadUserSession();
  }

  // تحميل بيانات جلسة المستخدم من التخزين المحلي
  Future<void> _loadUserSession() async {
    _token = await _authService.getToken();
    _userData = await _authService.getUserData();
    _isLoggedIn = _token != null;
    notifyListeners();
  }

  // تسجيل الدخول
  Future<Map<String, dynamic>> login(String identifier, String password) async {
    final result = await _authService.login(identifier: identifier, password: password);

    if (result['status']) {
      await _loadUserSession();
    }

    return result;
  }

  // تسجيل مستخدم عادي
  Future<Map<String, dynamic>> registerNormalUser({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String governorate,
  }) async {
    try {
      final result = await _authService.registerNormalUser(
        name: name,
        email: email,
        password: password,
        phone: phone,
        governorate: governorate,
      );

      if (result['status']) {
        await _loadUserSession(); // تحديث حالة الجلسة بعد التسجيل الناجح
      }

      return result;
    } catch (e) {
      return {
        'status': false,
        'message': 'خطأ أثناء التسجيل: $e',
        'user': null,
      };
    }
  }

  // تسجيل حساب مكتب عقارات

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
      final result = await _authService.registerRealstateOffice(
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

      if (result['status']) {
        await _loadUserSession();
      }

      return result;
    } catch (e) {
      return {
        'status': false,
        'message': 'خطأ أثناء التسجيل: $e',
        'user': null,
      };
    }
  }
  // تسجيل الخروج
  Future<void> logout() async {
    try {
      await _authService.logout();
      _isLoggedIn = false;
      _userData = null;
      _token = null;
      notifyListeners();
    } catch (e) {
      throw Exception('خطأ أثناء تسجيل الخروج: $e');
    }
  }
}