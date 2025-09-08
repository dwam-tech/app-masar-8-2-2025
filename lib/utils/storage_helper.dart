import 'package:shared_preferences/shared_preferences.dart';

class StorageHelper {
  static const String _tokenKey = 'user_token';
  static const String _userIdKey = 'user_id';
  static const String _userDataKey = 'user_data';

  // حفظ التوكن
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // جلب التوكن
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // حفظ معرف المستخدم
  static Future<void> saveCurrentUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, userId);
  }

  // جلب معرف المستخدم
  static Future<int?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  // حفظ بيانات المستخدم
  static Future<void> saveUserData(String userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, userData);
  }

  // جلب بيانات المستخدم
  static Future<String?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userDataKey);
  }

  // مسح جميع البيانات
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // مسح التوكن فقط
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // التحقق من وجود التوكن
  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // التحقق من تسجيل الدخول
  static Future<bool> isLoggedIn() async {
    return await hasToken();
  }
}