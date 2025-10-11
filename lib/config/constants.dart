class AppConstants {
  static const String baseUrl = 'https://msar.app'; // الرابط الموحد المعتمد
  static const String apiBaseUrl = '$baseUrl/api';         // رابط ה-API الأساسي

  // تم توحيد المفتاح ليعتمد على ما هو موجود في Service رفع الصور
  static const String userTokenKey = 'token'; 
}

/// قيم ثابتة خاصة بالعقارات
class RealEstateConstants {
  /// أنواع العقارات المقبولة من الـ Backend
  static const List<String> propertyTypes = [
    'apartment',
    'villa',
    'townhouse',
    'office',
    'shop',
  ];

  /// أنواع الملكية المقبولة
  static const List<String> ownershipTypes = [
    'freehold',
    'leasehold',
    'usufruct',
  ];
}