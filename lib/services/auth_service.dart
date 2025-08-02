import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // إضافة مكتبة intl لتنسيق الوقت
import 'package:saba2v2/services/laravel_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// enum AuthStatus {
//   UNINITIALIZED,
//   AUTHENTICATED,
//   AUTHENTICATING,
//   UNAUTHENTICATED,
//   FAILED
// }


const String baseUrl = 'http://192.168.1.7:8000';

class AuthService {
final LaravelService _laravelService = LaravelService();

  // AuthStatus _status = AuthStatus.UNINITIALIZED;
  // bool _isLoading = false;
  // String? _errorMessage;
  // Map<String, dynamic>? _userData;

  // // ----------------- Getters (للوصول إلى الحالة من الواجهة) -----------------
  // AuthStatus get status => _status;
  // bool get isLoading => _isLoading;
  // String? get errorMessage => _errorMessage;
  // Map<String, dynamic>? get userData => _userData;

  // 
  


  

  Future<Map<String, dynamic>> registerNormalUser({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String governorate,
  }) async {
    try {
      final result = await _laravelService.registerNormalUser(
        name: name, email: email, password: password, phone: phone, governorate: governorate, userType: 'normal',
      );
      return {'status': result['status'], 'message': result['message'], 'user': result['user']};
    } catch (e) {
      return {'status': false, 'message': e.toString().replaceFirst('Exception: ', ''), 'user': null};
    }
  }

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
        username: username, email: email, password: password, phone: phone, city: city, address: address,
        vat: vat, officeLogoPath: officeLogoPath, ownerIdFrontPath: ownerIdFrontPath, ownerIdBackPath: ownerIdBackPath,
        officeImagePath: officeImagePath, commercialCardFrontPath: commercialCardFrontPath, commercialCardBackPath: commercialCardBackPath,
      );
      return {'status': result['status'], 'message': result['message'], 'user': result['user']};
    } catch (e) {
      return {'status': false, 'message': e.toString().replaceFirst('Exception: ', ''), 'user': null};
    }
  }

  Future<Map<String, dynamic>> registerIndividualAgent({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String governorate,
    required String profileImage,
    required String agentIdFrontImage,
    required String agentIdBackImage,
    String? taxCardFrontImage,
    String? taxCardBackImage,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'name': name, 'email': email, 'password': password, 'phone': phone, 'governorate': governorate,
        'user_type': 'real_estate_individual', 'is_approved': 0, 'agent_name': name,
        'profile_image': profileImage, 'agent_id_front_image': agentIdFrontImage, 'agent_id_back_image': agentIdBackImage,
        'tax_card_front_image': taxCardFrontImage, 'tax_card_back_image': taxCardBackImage,
      };
      body.removeWhere((key, value) => value == null);

      final response = await http.post(
        Uri.parse('$baseUrl/api/register'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'status': responseData['status'] ?? true, 'message': responseData['message'] ?? 'Registration successful', 'user_id': responseData['user_id'], 'user_type': responseData['user_type']};
      } else {
        debugPrint('API Validation Error (IndividualAgent): ${response.body}');
        throw Exception(responseData['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Error during individual agent registration: $e');
    }
  }

  Future<Map<String, dynamic>> registerDeliveryOffice({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String officeName,
    required String logoImageUrl,
    required String commercialFrontImageUrl,
    required String commercialBackImageUrl,
    required List<String> paymentMethods,
    required List<String> rentalTypes,
    required double costPerKm,
    required double driverCost,
    required String governorate,
    required int maxKmPerDay,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'name': fullName, 'governorate': governorate, 'email': email, 'password': password, 'phone': phone, 'user_type': "car_rental_office",
        'office_name': officeName, 'logo_image': logoImageUrl, 'commercial_register_front_image': commercialFrontImageUrl,
        'commercial_register_back_image': commercialBackImageUrl, 'payment_methods': paymentMethods, 'rental_options': rentalTypes,
        'cost_per_km': costPerKm, 'daily_driver_cost': driverCost, 'max_km_per_day': maxKmPerDay,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/register'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'status': responseData['status'] ?? true, 'message': responseData['message'] ?? 'Registration successful', 'user': responseData['user']};
      } else {
        debugPrint('API Validation Error (DeliveryOffice): ${response.body}');
        throw Exception(responseData['message'] ?? 'Registration failed');
      }
    } catch (e) {
      return {'status': false, 'message': e.toString().replaceFirst('Exception: ', '')};
    }
  }

  Future<Map<String, dynamic>> registerDeliveryPerson({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String governorate,
    required String profileImageUrl,
    required List<String> paymentMethods,
    required List<String> rentalTypes,
    required double costPerKm,
    required double driverCost,
    required int maxKmPerDay,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'name': fullName,
        'email': email,
        'password': password,
        'phone': phone,
        'governorate': governorate,
        'user_type': "driver",
        'profile_image': profileImageUrl,
        'payment_methods': paymentMethods,
        'rental_options': rentalTypes,
        'cost_per_km': costPerKm,
        'daily_driver_cost': driverCost,
        'max_km_per_day': maxKmPerDay,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/register'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return {'status': true, 'message': 'Registration successful', 'user': responseData['user']};
      } else {
        debugPrint('API Validation Error (DeliveryPerson): ${response.body}');
        final responseData = jsonDecode(response.body);
        throw Exception(responseData['message'] ?? 'Registration failed');
      }
    } catch (e) {
      debugPrint('A NETWORK or CONNECTION error occurred in registerDeliveryPerson: $e');
      return {'status': false, 'message': e.toString().replaceFirst('Exception: ', '')};
    }
  }

  Future<Map<String, dynamic>> registerRestaurant({
    required Map<String, dynamic> legalData,
    required Map<String, dynamic> accountInfo,
    required Map<String, dynamic> workHours,
  }) async {
    try {
      // إعادة تنسيق الفروع لتتطابق مع الهيكلية المطلوبة
      final List<Map<String, String>> formattedBranches = (accountInfo['branches'] as List<Map<String, String>>)
          .map((branch) => {
        'name': '${branch['governorate']} - ${branch['area']}',
        'address': branch['area']!,
      })
          .toList();

      // إعادة تنسيق ساعات العمل باستخدام DateFormat مع التحقق من نوع البيانات
      final List<Map<String, String>> formattedWorkingHours = (workHours['schedule'] as Map<String, dynamic>).entries.map((entry) {
        final day = entry.key;
        final schedule = entry.value as Map<String, dynamic>;
        final startTime = schedule['start'] is TimeOfDay
            ? schedule['start'] as TimeOfDay
            : TimeOfDay(hour: int.parse(schedule['start'].toString().split(':')[0]), minute: int.parse(schedule['start'].toString().split(':')[1].split(' ')[0]));
        final endTime = schedule['end'] is TimeOfDay
            ? schedule['end'] as TimeOfDay
            : TimeOfDay(hour: int.parse(schedule['end'].toString().split(':')[0]), minute: int.parse(schedule['end'].toString().split(':')[1].split(' ')[0]));

        return {
          'day': day,
          'from': DateFormat('HH:mm').format(DateTime(2023, 1, 1, startTime.hour, startTime.minute)),
          'to': DateFormat('HH:mm').format(DateTime(2023, 1, 1, endTime.hour, endTime.minute)),
        };
      }).toList();

      // دمج البيانات مع التأكد من تطابق أسماء الحقول
      final Map<String, dynamic> body = {
        'name': accountInfo['username'],
        'email': accountInfo['email'],
        'password': accountInfo['password'],
        'phone': accountInfo['phone'],
        'governorate': accountInfo['branches']?.isNotEmpty ?? false ? accountInfo['branches'][0]['governorate'] : null,
        'user_type': 'restaurant',
        'profile_image': legalData['profile_image'],
        'restaurant_name': accountInfo['restaurant_name'],
        'logo_image': accountInfo['restaurant_logo'],
        'owner_id_front_image': legalData['owner_id_front_image'],
        'owner_id_back_image': legalData['owner_id_back_image'],
        'license_front_image': legalData['license_front_image'],
        'license_back_image': legalData['license_back_image'],
        'commercial_register_front_image': legalData['commercial_register_front_image'],
        'commercial_register_back_image': legalData['commercial_register_back_image'],
        'vat_included': legalData['vat_included'],
        'vat_image_front': legalData['vat_image_front'],
        'vat_image_back': legalData['vat_image_back'],
        'cuisine_types': accountInfo['cuisine_types'],
        'branches': formattedBranches,
        'delivery_available': accountInfo['delivery_available'],
        'delivery_cost_per_km': accountInfo['delivery_cost_per_km'] != null ? double.parse(accountInfo['delivery_cost_per_km'].toString()) : null,
        'table_reservation_available': accountInfo['table_reservation_available'],
        'max_people_per_reservation': accountInfo['max_people_per_reservation'] != null ? int.parse(accountInfo['max_people_per_reservation'].toString()) : null,
        'reservation_notes': accountInfo['reservation_notes'],
        'deposit_required': accountInfo['deposit_required'],
        'deposit_amount': accountInfo['deposit_amount'] != null ? double.parse(accountInfo['deposit_amount'].toString()) : null,
        'working_hours': formattedWorkingHours,
      };

      // إزالة الحقول الفارغة (null)
      body.removeWhere((key, value) => value == null);

      debugPrint('Final Restaurant Registration Body: ${jsonEncode(body)}');

      final response = await http.post(
        Uri.parse('$baseUrl/api/register'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return {'status': true, 'message': responseData['message'] ?? 'Registration successful', 'user': responseData['user']};
      } else {
        debugPrint('API Validation Error (Restaurant): ${response.body}');
        final responseData = jsonDecode(response.body);
        throw Exception(responseData['message'] ?? 'Registration failed');
      }
    } catch (e) {
      debugPrint('A NETWORK or CONNECTION error occurred in registerRestaurant: $e');
      return {'status': false, 'message': e.toString().replaceFirst('Exception: ', '')};
    }
  }

//------------------- بدايه اخر كومنت------------------------------------------
//------------------------------------------------------------------------------
 /* Future<Map<String, dynamic>> login({
  required String email,
  required String password,
}) async {
  try {
    final Map<String, String> body = { 'email': email, 'password': password };

    final response = await http.post(
      Uri.parse('$baseUrl/api/login'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = jsonDecode(response.body);

      // ==========================================================
      // --- أضف جمل الطباعة هنا للتحقق ---
      debugPrint("AuthService LOGIN: Login successful. API Response received.");
      debugPrint("AuthService LOGIN: Full user data from API: ${jsonEncode(responseData['user'])}");
      // ==========================================================

      if (responseData['token'] != null && responseData['user'] != null) {
        await _saveToken(responseData['token']);
        await _saveUserData(responseData['user']); // هذه الدالة ستحاول حفظ real_estate_id
      }

      return {
        'status': responseData['status'] ?? true,
        'message': responseData['message'] ?? 'Login successful',
        'user': responseData['user'],
      };
    } else {
      debugPrint('AuthService LOGIN: API Login Error: ${response.body}');
      final responseData = jsonDecode(response.body);
      throw Exception(responseData['message'] ?? 'Login failed');
    }
  } catch (e) {
    debugPrint('AuthService LOGIN: A NETWORK or CONNECTION error occurred during login: $e');
    throw Exception('Error during login: $e');
  }
}

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();

    // 1. حفظ بيانات المستخدم الكاملة
    await prefs.setString('user_data', jsonEncode(userData));

    // 2. حفظ بيانات تأجير السيارات
    if (userData['car_rental']?['id'] != null) {
      final carRentalId = userData['car_rental']['id'];
      await prefs.setInt('car_rental_id', carRentalId);
      debugPrint("AuthService: Saved car_rental_id -> $carRentalId");
    }

    final officeDetail = userData['car_rental']?['office_detail'];
    if (officeDetail != null) {
      if (officeDetail['id'] != null) {
        await prefs.setInt('car_rental_office_detail_id', officeDetail['id']);
      }
      if (officeDetail['is_available_for_delivery'] != null) {
        await prefs.setBool('is_delivery_enabled', officeDetail['is_available_for_delivery'] == true || officeDetail['is_available_for_delivery'] == 1);
      }
      if (officeDetail['is_available_for_rent'] != null) {
        await prefs.setBool('is_rental_enabled', officeDetail['is_available_for_rent'] == true || officeDetail['is_available_for_rent'] == 1);
      }
    }

    // 3. حفظ بيانات العقارات
    if (userData['real_estate']?['id'] != null) {
      final realEstateId = userData['real_estate']['id'];
      await prefs.setInt('real_estate_id', realEstateId);
      debugPrint("AuthService: Saved real_estate_id -> $realEstateId");
    }
    
    // ==========================================================
    // --- 4. الإضافة الجديدة: حفظ بيانات المطاعم ---
    // ==========================================================
    if (userData['restaurant_detail']?['id'] != null) {
      final restaurantId = userData['restaurant_detail']['id'];
      // **نستخدم نفس المفتاح 'real_estate_id' لتسهيل الأمر على AuthProvider**
      await prefs.setInt('restaurantId', restaurantId); 
      debugPrint("AuthService SUCCESS: Saved restaurantId as 'restaurantId' -> $restaurantId");
    }
  }

  Future<int?> getRealEstateId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('real_estate_id');
  }

  Future<void> logout() async {
    try {
      await _laravelService.logout();
    } catch (e) {
      throw Exception('Error during logout: $e');
    }
  }
 
 
  Future<String?> getToken() async {
    return await _laravelService.getToken();
  }

  Future<Map<String, dynamic>?> getUserData() async {
    return await _laravelService.getUserData();
  }
*/
//--------------------نهايه اخر كومنت ----------------------------------
 //---------------------------------------------------------------------
 

 


 Future<Map<String, dynamic>> login({required String email, required String password}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        debugPrint("AuthService: Login successful. API Response received.");
        
        // **التصحيح الحاسم: قراءة التوكن والبيانات من المسار الصحيح**
        if (responseData['token'] != null && responseData['user'] != null) {
          await _saveSession(
            token: responseData['token'], // المسار الصحيح
            userData: responseData['user'],
          );
        }
        return {'status': true, 'message': 'Login successful', 'user': responseData['user']};
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to login');
      }
    } catch (e) {
      throw Exception('Network or server error during login: $e');
    }
  }

  /// دالة حفظ الجلسة (النسخة النهائية المصححة لتطابق الـ JSON)
  Future<void> _saveSession({required String token, required Map<String, dynamic> userData}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('user_data', jsonEncode(userData));
    
    await prefs.remove('entity_id'); // تصفير الـ ID القديم لضمان عدم التداخل
    
    // **التصحيح الحاسم: قراءة ID المطعم من المسار الصحيح**
    int? entityId;
    if (userData['restaurant_detail']?['id'] != null) {
      entityId = userData['restaurant_detail']['id'];
      debugPrint("AuthService SUCCESS: Found and saving restaurant ID: $entityId");
    } else if (userData['real_estate']?['id'] != null) {
      entityId = userData['real_estate']['id'];
      debugPrint("AuthService SUCCESS: Found and saving real estate ID: $entityId");
    }

    if (entityId != null) {
      // استخدام مفتاح موحد لحفظ ID المطعم أو العقار
      await prefs.setInt('entity_id', entityId);
    }
  }

  /// دالة تسجيل الخروج (النسخة النهائية الصحيحة)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user_data');
    await prefs.remove('entity_id');
    try {
      await _laravelService.logout();
    } catch (e) {
      debugPrint("Ignoring server logout error: $e");
    }
  }

  // --- دوال مساعدة (النسخة النهائية الصحيحة) ---
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('user_data');
    return data != null ? jsonDecode(data) : null;
  }

  Future<int?> getRealEstateId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('entity_id');
  }


  //--------------------------------------------

  Future<Map<String, dynamic>> fetchSettings() async {
    final url = Uri.parse('$baseUrl/api/settings'); // استخدام نفس الـ baseUrl
    
    try {
      final response = await http.get(
        url,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == true && data['settings'] != null) {
          // إذا نجح الطلب، قم بإرجاع خريطة الإعدادات
          return data['settings'] as Map<String, dynamic>;
        } else {
          // في حال كان الرد من السيرفر بصيغة غير متوقعة
          throw Exception('صيغة الرد من الـ API غير صحيحة.');
        }
      } else {
        // في حال فشل الطلب (مثل خطأ 404 أو 500)
        throw Exception('فشل تحميل الإعدادات. رمز الحالة: ${response.statusCode}');
      }
    } catch (e) {
      // للتعامل مع أخطاء الشبكة أو أخطاء أخرى
      debugPrint('حدث خطأ أثناء جلب الإعدادات: $e');
      throw Exception('لا يمكن الاتصال بالخادم. يرجى التحقق من اتصالك بالإنترنت.');
    }
  }

}