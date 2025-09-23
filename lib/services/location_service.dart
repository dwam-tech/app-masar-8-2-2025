import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

class LocationService {
  static const String _googleApiKey = 'AIzaSyBqBMvoAdJKoG_rPBhO8Da75gtw0Gc13Vc';
  
  /// التحقق من صلاحيات الموقع وتفعيل خدمة الموقع
  static Future<bool> checkLocationPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    // التحقق من تفعيل خدمة الموقع
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// الحصول على الموقع الحالي
  static Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await checkLocationPermissions();
      if (!hasPermission) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      print('خطأ في الحصول على الموقع: $e');
      return null;
    }
  }

  /// تحويل الإحداثيات إلى عنوان ومحافظة
  static Future<Map<String, String?>> getAddressFromCoordinates(
    double latitude, 
    double longitude
  ) async {
    try {
      // استخدام مكتبة geocoding أولاً
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude, 
        longitude
      );
      
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        String? governorate = place.administrativeArea ?? place.subAdministrativeArea;
        
        // تحسين تحديد المحافظة للمدن المصرية
        governorate = _normalizeGovernorate(governorate);
        
        return {
          'governorate': governorate,
          'city': place.locality ?? place.subLocality,
          'current_address': _formatAddress(place),
        };
      }
      
      // إذا فشلت مكتبة geocoding، استخدم Google Geocoding API
      return await _getAddressFromGoogleAPI(latitude, longitude);
    } catch (e) {
      print('خطأ في تحويل الإحداثيات: $e');
      // إذا فشل كل شيء، استخدم Google API كبديل
      return await _getAddressFromGoogleAPI(latitude, longitude);
    }
  }

  /// تطبيع أسماء المحافظات المصرية
  static String? _normalizeGovernorate(String? governorate) {
    if (governorate == null) return null;
    
    final Map<String, String> governorateMap = {
      'Ismailia Governorate': 'الإسماعيلية',
      'Ismailia': 'الإسماعيلية',
      'Cairo Governorate': 'القاهرة',
      'Cairo': 'القاهرة',
      'Giza Governorate': 'الجيزة',
      'Giza': 'الجيزة',
      'Alexandria Governorate': 'الإسكندرية',
      'Alexandria': 'الإسكندرية',
      'Qalyubia Governorate': 'القليوبية',
      'Qalyubia': 'القليوبية',
      'Port Said Governorate': 'بورسعيد',
      'Port Said': 'بورسعيد',
      'Suez Governorate': 'السويس',
      'Suez': 'السويس',
      'Dakahlia Governorate': 'الدقهلية',
      'Dakahlia': 'الدقهلية',
      'Sharqia Governorate': 'الشرقية',
      'Sharqia': 'الشرقية',
      'Gharbia Governorate': 'الغربية',
      'Gharbia': 'الغربية',
      'Monufia Governorate': 'المنوفية',
      'Monufia': 'المنوفية',
      'Beheira Governorate': 'البحيرة',
      'Beheira': 'البحيرة',
      'Kafr el-Sheikh Governorate': 'كفر الشيخ',
      'Kafr el-Sheikh': 'كفر الشيخ',
      'Damietta Governorate': 'دمياط',
      'Damietta': 'دمياط',
      'North Sinai Governorate': 'شمال سيناء',
      'North Sinai': 'شمال سيناء',
      'South Sinai Governorate': 'جنوب سيناء',
      'South Sinai': 'جنوب سيناء',
      'Red Sea Governorate': 'البحر الأحمر',
      'Red Sea': 'البحر الأحمر',
      'Matrouh Governorate': 'مطروح',
      'Matrouh': 'مطروح',
      'Fayoum Governorate': 'الفيوم',
      'Fayoum': 'الفيوم',
      'Beni Suef Governorate': 'بني سويف',
      'Beni Suef': 'بني سويف',
      'Minya Governorate': 'المنيا',
      'Minya': 'المنيا',
      'Asyut Governorate': 'أسيوط',
      'Asyut': 'أسيوط',
      'Sohag Governorate': 'سوهاج',
      'Sohag': 'سوهاج',
      'Qena Governorate': 'قنا',
      'Qena': 'قنا',
      'Luxor Governorate': 'الأقصر',
      'Luxor': 'الأقصر',
      'Aswan Governorate': 'أسوان',
      'Aswan': 'أسوان',
      'New Valley Governorate': 'الوادي الجديد',
      'New Valley': 'الوادي الجديد',
    };
    
    return governorateMap[governorate] ?? governorate;
  }

  /// تنسيق العنوان من Placemark
  static String _formatAddress(Placemark place) {
    List<String> addressParts = [];
    
    if (place.street != null && place.street!.isNotEmpty) {
      addressParts.add(place.street!);
    }
    if (place.locality != null && place.locality!.isNotEmpty) {
      addressParts.add(place.locality!);
    }
    if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
      addressParts.add(place.administrativeArea!);
    }
    if (place.country != null && place.country!.isNotEmpty) {
      addressParts.add(place.country!);
    }
    
    return addressParts.join(', ');
  }

  /// استخدام Google Geocoding API كبديل
  static Future<Map<String, String?>> _getAddressFromGoogleAPI(
    double latitude, 
    double longitude
  ) async {
    try {
      final String url = 'https://maps.googleapis.com/maps/api/geocode/json'
          '?latlng=$latitude,$longitude'
          '&language=ar'
          '&key=$_googleApiKey';

      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final result = data['results'][0];
          final components = result['address_components'] as List;
          
          String? governorate;
          String? city;
          
          // البحث عن المحافظة والمدينة في مكونات العنوان
          for (var component in components) {
            final types = component['types'] as List;
            
            if (types.contains('administrative_area_level_1')) {
              governorate = component['long_name'];
            } else if (types.contains('locality') || types.contains('administrative_area_level_2')) {
              city = component['long_name'];
            }
          }
          
          // تحسين تحديد المحافظة للمدن المصرية
          governorate = _normalizeGovernorate(governorate);
          
          return {
            'governorate': governorate,
            'city': city,
            'current_address': result['formatted_address'],
          };
        }
      }
      
      return {
        'governorate': null,
        'city': null,
        'current_address': 'الموقع: $latitude, $longitude',
      };
    } catch (e) {
      print('خطأ في Google Geocoding API: $e');
      return {
        'governorate': null,
        'city': null,
        'current_address': 'الموقع: $latitude, $longitude',
      };
    }
  }

  /// الحصول على الموقع الحالي مع تفاصيل العنوان
  static Future<Map<String, dynamic>?> getCurrentLocationWithAddress() async {
    try {
      final position = await getCurrentLocation();
      if (position == null) {
        return null;
      }

      final addressInfo = await getAddressFromCoordinates(
        position.latitude, 
        position.longitude
      );

      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'governorate': addressInfo['governorate'],
        'city': addressInfo['city'],
        'current_address': addressInfo['current_address'],
        'accuracy': position.accuracy,
        'timestamp': position.timestamp,
      };
    } catch (e) {
      print('خطأ في الحصول على الموقع مع العنوان: $e');
      return null;
    }
  }

  /// حساب المسافة بين نقطتين بالكيلومتر
  static double calculateDistance(
    double lat1, double lon1, 
    double lat2, double lon2
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }
}