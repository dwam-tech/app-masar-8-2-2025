// Map لأقسام المطاعم مع الصور والعناوين والمسارات
class RestaurantCategoriesMap {
  static const Map<String, Map<String, String>> categories = {
    'grilled': {
      'title': 'مشويات',
      'image': 'assets/images/grilled.png',
      'route': '/restaurants/category/grilled',
    },
    'seafood': {
      'title': 'سيفود',
      'image': 'assets/images/seafood.png',
      'route': '/restaurants/category/seafood',
    },
    'fried_chicken': {
      'title': 'دجاج مقلي',
      'image': 'assets/images/fried_chicken.png',
      'route': '/restaurants/category/fried_chicken',
    },
    'desserts': {
      'title': 'حلويات',
      'image': 'assets/images/desserts.png',
      'route': '/restaurants/category/desserts',
    },
    'pizza': {
      'title': 'بيتزا',
      'image': 'assets/images/pizza_category.png',
      'route': '/restaurants/category/pizza',
    },
    'ice_cream': {
      'title': 'ايس كريم',
      'image': 'assets/images/ice_cream.png',
      'route': '/restaurants/category/ice_cream',
    },
  };

  // دالة للحصول على بيانات القسم بالـ ID
  static Map<String, String>? getCategoryById(String categoryId) {
    return categories[categoryId];
  }

  // دالة للحصول على جميع الأقسام
  static Map<String, Map<String, String>> getAllCategories() {
    return categories;
  }

  // دالة للحصول على عنوان القسم
  static String getCategoryTitle(String categoryId) {
    return categories[categoryId]?['title'] ?? 'غير محدد';
  }

  // دالة للحصول على صورة القسم
  static String getCategoryImage(String categoryId) {
    return categories[categoryId]?['image'] ?? 'assets/images/categories/default.png';
  }

  // دالة للحصول على مسار القسم
  static String getCategoryRoute(String categoryId) {
    return categories[categoryId]?['route'] ?? '/restaurants';
  }
}