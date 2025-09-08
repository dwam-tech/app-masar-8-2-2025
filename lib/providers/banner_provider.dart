import 'package:flutter/foundation.dart';
import '../services/settings_service.dart';

class BannerProvider with ChangeNotifier {
  final SettingsService _settingsService = SettingsService();
  
  List<String> _banners = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<String> get banners => _banners;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// جلب البانرات من API
  Future<void> fetchBanners() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final banners = await _settingsService.getUserHomeBanners();
      _banners = banners;
      _error = null;
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error in BannerProvider: $e');
      }
      // في حالة الخطأ، استخدم البانرات الافتراضية
      _banners = [
        'http://dwam-tech.com/wp-content/uploads/2025/07/Untitled-design.png',
        'http://dwam-tech.com/wp-content/uploads/2025/07/Untitled-design.png',
        'http://dwam-tech.com/wp-content/uploads/2025/07/Untitled-design.png',
      ];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// إعادة تحميل البانرات
  Future<void> refreshBanners() async {
    await fetchBanners();
  }

  /// تنظيف البيانات
  void clearBanners() {
    _banners = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}