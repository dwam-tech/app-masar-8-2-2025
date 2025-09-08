// مسار الملف: services/ar_rental_office_service.dart

import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/service_request_model.dart'; // تأكد من أن هذا المسار صحيح
import '../config/constants.dart';

class CarRentalOfficeService {
  final String _apiBaseUrl = AppConstants.apiBaseUrl;
  final String token;

  CarRentalOfficeService({required this.token});
  
  //==============================================================
  // --- دالة جديدة لتحديث بيانات المكتب ---
  //==============================================================
  Future<Map<String, dynamic>> updateOfficeDetails({
    required int officeDetailId,
    required Map<String, dynamic> data,
  }) async {
    final url = Uri.parse('$_apiBaseUrl/car-rental-office-detail/$officeDetailId');
    
    try {
      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        debugPrint("Office details updated successfully: ${response.body}");
        return {
          'status': true,
          'message': 'تم تحديث البيانات بنجاح',
          'data': responseData,
        };
      } else {
        debugPrint("Failed to update office details: ${response.body}");
        throw Exception(responseData['message'] ?? 'فشل تحديث البيانات');
      }
    } catch (e) {
      debugPrint("Error in updateOfficeDetails: $e");
      throw Exception('حدث خطأ في الشبكة.');
    }
  }

  //==============================================================
  // دوال جلب البيانات (GET)
  //==============================================================

  /// 1. جلب الطلبات قيد الانتظار
  Future<List<ServiceRequest>> getPendingRequests() async {
    final url = Uri.parse('$_apiBaseUrl/provider/service-requests'); 
    return _getRequests(url);
  }

  /// 2. جلب الطلبات قيد التنفيذ
  Future<List<ServiceRequest>> getInProgressRequests() async {
    final url = Uri.parse('$_apiBaseUrl/provider/service-requests/accept'); 
    return _getRequests(url);
  }

  /// 3. جلب الطلبات المنتهية
  Future<List<ServiceRequest>> getCompletedRequests() async {
    final url = Uri.parse('$_apiBaseUrl/provider/service-requests/complete');
    return _getRequests(url);
  }

  /// دالة مساعدة عامة لجلب قوائم الطلبات بمرونة
  Future<List<ServiceRequest>> _getRequests(Uri url) async {
    try {
      final response = await http.get(url, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });
      
      debugPrint("Fetching from URL: $url");
      debugPrint("Response Status: ${response.statusCode}");
      // debugPrint("Response Body: ${response.body}"); // يمكنك إلغاء التعليق لرؤية الرد

      if (response.statusCode == 200) {
        final decodedBody = jsonDecode(response.body);
        
        List<dynamic> requestsList;
        if (decodedBody is List) {
          requestsList = decodedBody;
        } else if (decodedBody is Map<String, dynamic> && decodedBody.containsKey('requests')) {
          requestsList = decodedBody['requests'];
        } else {
          return [];
        }
        
        return requestsList.map((json) => ServiceRequest.fromJson(json)).toList();
      } else {
        throw Exception('فشل جلب الطلبات من ($url) - خطأ ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Error in _getRequests ($url): $e");
      throw Exception('حدث خطأ في الشبكة أو في تنسيق البيانات.');
    }
  }

  //==============================================================
  // دوال الإجراءات (POST)
  //==============================================================

  /// 4. قبول طلب خدمة
  Future<Map<String, dynamic>> acceptServiceRequest({required int requestId}) async {
    final url = Uri.parse('$_apiBaseUrl/provider/service-requests/$requestId/accept');
    return _postAction(url, successMessage: 'تم قبول الطلب بنجاح');
  }
  
  /// 5. إنهاء طلب خدمة
  Future<Map<String, dynamic>> completeServiceRequest({required int requestId}) async {
    final url = Uri.parse('$_apiBaseUrl/provider/service-requests/$requestId/complete');
    return _postAction(url, successMessage: 'تم إنهاء الطلب بنجاح');
  }

  /// دالة مساعدة عامة لإجراءات POST
  Future<Map<String, dynamic>> _postAction(Uri url, {required String successMessage}) async {
    try {
      final response = await http.post(url, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'status': true, 'message': responseData['message'] ?? successMessage};
      } else {
        throw Exception(responseData['message'] ?? 'فشل تنفيذ الإجراء');
      }
    } catch (e) {
      debugPrint("Error in _postAction ($url): $e");
      throw Exception('حدث خطأ في الشبكة: $e');
    }
  }

  //==============================================================
  // دالة تحديث التوفر
  //==============================================================
  Future<bool> updateAvailability({
    required int officeDetailId,
    bool? isAvailableForDelivery,
    bool? isAvailableForRent,
  }) async {
    final availabilityUrl = Uri.parse('$_apiBaseUrl/car-rental-office-detail/$officeDetailId/availability');
    final body = {
      if (isAvailableForDelivery != null) "is_available_for_delivery": isAvailableForDelivery,
      if (isAvailableForRent != null) "is_available_for_rent": isAvailableForRent,
    };

    try {
        final response = await http.patch(
        availabilityUrl,
        headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
            "Content-Type": "application/json"
        },
        body: jsonEncode(body),
        );

        if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            return data['status'] == true;
        } else {
            throw Exception("Failed to update availability: ${response.body}");
        }
    } catch (e) {
      debugPrint('Error updating availability: $e');
      throw Exception('Failed to update availability due to a network error.');
    }
  }

Future<Map<String, dynamic>> updateUserProfile({
    required int userId,
    required Map<String, dynamic> data,
  }) async {
    final url = Uri.parse('$_apiBaseUrl/users/$userId');
    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        debugPrint("User profile updated successfully: ${response.body}");
        return {'status': true, 'message': 'تم تحديث البيانات بنجاح', 'user': responseData['user']};
      } else {
        debugPrint("Failed to update user profile: ${response.body}");
        throw Exception(responseData['message'] ?? responseData['error'] ?? 'فشل تحديث البيانات');
      }
    } catch (e) {
      debugPrint("Error in updateUserProfile: $e");
      throw Exception('حدث خطأ في الشبكة.');
    }
  }

 Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

 Future<Map<String, dynamic>> fetchCurrentUser() async {
    final token = await getToken();
    if (token == null) {
      throw Exception("لا يمكن جلب البيانات: المستخدم غير مسجل.");
    }

    final url = Uri.parse('${AppConstants.apiBaseUrl}/user');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // الـ API قد يرجع البيانات مباشرة أو داخل مفتاح 'user'
        if (responseData is Map<String, dynamic> && responseData.containsKey('user')) {
            return responseData['user'];
        }
        return responseData; // إرجاع الرد مباشرة
      } else {
        throw Exception(responseData['message'] ?? 'فشل جلب بيانات المستخدم.');
      }
    } catch (e) {
      debugPrint("Error in fetchCurrentUser: $e");
      throw Exception("حدث خطأ في الشبكة أثناء جلب بيانات المستخدم.");
    }
  }

}





// // مسار الملف: services/ar_rental_office_service.dart

// import 'dart:convert';

// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
// import '../models/service_request_model.dart'; // تأكد من أن هذا المسار صحيح

// class CarRentalOfficeService {
//   final String _apiBaseUrl = "http://192.168.1.7:8000/api/provider/service-requests";
//   final String token;

//   CarRentalOfficeService({required this.token});

//   //==============================================================
//   // دوال جلب البيانات (GET)
//   //==============================================================

//   /// 1. جلب الطلبات قيد الانتظار
//   Future<List<ServiceRequest>> getPendingRequests() async {
//     final url = Uri.parse(_apiBaseUrl); 
//     return _getRequests(url);
//   }

//   /// 2. جلب الطلبات قيد التنفيذ
//   Future<List<ServiceRequest>> getInProgressRequests() async {
//     final url = Uri.parse('$_apiBaseUrl/accept'); 
//     return _getRequests(url);
//   }

//   /// 3. جلب الطلبات المنتهية
//   Future<List<ServiceRequest>> getCompletedRequests() async {
//     final url = Uri.parse('$_apiBaseUrl/complete');
//     return _getRequests(url);
//   }

//   /// --- [هذه هي الدالة المعدلة التي تتعامل مع كل الحالات] ---
//   /// دالة مساعدة عامة لجلب قوائم الطلبات بمرونة
//   Future<List<ServiceRequest>> _getRequests(Uri url) async {
//     try {
//       final response = await http.get(url, headers: {
//         'Accept': 'application/json',
//         'Authorization': 'Bearer $token',
//       });
      
//       debugPrint("Fetching from URL: $url");
//       debugPrint("Response Status: ${response.statusCode}");
//       debugPrint("Response Body: ${response.body}");

//       if (response.statusCode == 200) {
//         final decodedBody = jsonDecode(response.body);
        
//         // --- المنطق الذكي للتعامل مع التنسيقات المختلفة ---
//         List<dynamic> requestsList;

//         if (decodedBody is List) {
//           // الحالة 1: الرد هو قائمة مباشرة [ ... ]
//           debugPrint("Parsing response as a direct LIST.");
//           requestsList = decodedBody;
//         } else if (decodedBody is Map<String, dynamic> && decodedBody.containsKey('requests')) {
//           // الحالة 2: الرد هو كائن يحتوي على مفتاح 'requests'
//           debugPrint("Parsing response from 'requests' key in a MAP.");
//           requestsList = decodedBody['requests'];
//         } else {
//           // إذا كان التنسيق غير معروف (مثل رد ناجح ولكن بدون بيانات)
//           debugPrint("Response format is not a list or a map with 'requests' key. Returning empty list.");
//           return [];
//         }
        
//         return requestsList.map((json) => ServiceRequest.fromJson(json)).toList();

//       } else {
//         throw Exception('فشل جلب الطلبات من ($url) - خطأ ${response.statusCode}');
//       }
//     } catch (e) {
//       debugPrint("Error in _getRequests ($url): $e");
//       throw Exception('حدث خطأ في الشبكة أو في تنسيق البيانات.');
//     }
//   }

//   //==============================================================
//   // دوال الإجراءات (POST) - لا تغيير فيها
//   //==============================================================

//   /// 4. قبول طلب خدمة
//   Future<Map<String, dynamic>> acceptServiceRequest({required int requestId}) async {
//     final url = Uri.parse('$_apiBaseUrl/$requestId/accept');
//     return _postAction(url, successMessage: 'تم قبول الطلب بنجاح');
//   }
  
//   /// 5. إنهاء طلب خدمة
//   Future<Map<String, dynamic>> completeServiceRequest({required int requestId}) async {
//     final url = Uri.parse('$_apiBaseUrl/$requestId/complete');
//     return _postAction(url, successMessage: 'تم إنهاء الطلب بنجاح');
//   }

//   /// دالة مساعدة عامة لإجراءات POST
//   Future<Map<String, dynamic>> _postAction(Uri url, {required String successMessage}) async {
//     try {
//       final response = await http.post(url, headers: {
//         'Accept': 'application/json',
//         'Authorization': 'Bearer $token',
//       });

//       final responseData = jsonDecode(response.body);
//       if (response.statusCode == 200) {
//         return {'status': true, 'message': responseData['message'] ?? successMessage};
//       } else {
//         throw Exception(responseData['message'] ?? 'فشل تنفيذ الإجراء');
//       }
//     } catch (e) {
//       debugPrint("Error in _postAction ($url): $e");
//       throw Exception('حدث خطأ في الشبكة: $e');
//     }
//   }

//   //==============================================================
//   // دالة تحديث التوفر - لا تغيير فيها
//   //==============================================================
//   Future<bool> updateAvailability({
//     required int officeDetailId,
//     bool? isAvailableForDelivery,
//     bool? isAvailableForRent,
//   }) async {
//     final availabilityUrl = Uri.parse('http://192.168.1.7:8000/api/car-rental-office-detail/$officeDetailId/availability');

//     final body = {
//       if (isAvailableForDelivery != null) "is_available_for_delivery": isAvailableForDelivery,
//       if (isAvailableForRent != null) "is_available_for_rent": isAvailableForRent,
//     };

//     try {
//         final response = await http.patch(
//         availabilityUrl,
//         headers: {
//             "Authorization": "Bearer $token",
//             "Accept": "application/json",
//             "Content-Type": "application/json"
//         },
//         body: jsonEncode(body),
//         );

//         if (response.statusCode == 200) {
//             final data = jsonDecode(response.body);
//             return data['status'] == true;
//         } else {
//             throw Exception("Failed to update availability: ${response.body}");
//         }
//     } catch (e) {
//       debugPrint('Error updating availability: $e');
//       throw Exception('Failed to update availability due to a network error.');
//     }
//   }
// }



