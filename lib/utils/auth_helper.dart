import 'package:shared_preferences/shared_preferences.dart';

class AuthHelper {
  static const String _tokenKey = 'token';
  static const String _userDataKey = 'user_data';

  /// الحصول على التوكن من SharedPreferences
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      return null;
    }
  }

  /// حفظ التوكن في SharedPreferences
  static Future<bool> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_tokenKey, token);
    } catch (e) {
      return false;
    }
  }

  /// حذف التوكن من SharedPreferences
  static Future<bool> removeToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_tokenKey);
    } catch (e) {
      return false;
    }
  }

  /// التحقق من وجود التوكن
  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// حفظ بيانات المستخدم
  static Future<bool> saveUserData(String userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_userDataKey, userData);
    } catch (e) {
      return false;
    }
  }

  /// الحصول على بيانات المستخدم
  static Future<String?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userDataKey);
    } catch (e) {
      return null;
    }
  }

  /// حذف بيانات المستخدم
  static Future<bool> removeUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_userDataKey);
    } catch (e) {
      return false;
    }
  }

  /// تسجيل الخروج (حذف جميع البيانات)
  static Future<bool> logout() async {
    try {
      final tokenRemoved = await removeToken();
      final userDataRemoved = await removeUserData();
      return tokenRemoved && userDataRemoved;
    } catch (e) {
      return false;
    }
  }
}