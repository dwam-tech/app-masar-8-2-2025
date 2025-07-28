// lib/services/car_api_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/car_model.dart';

class CarApiService {
  final String _baseUrl = "http://192.168.1.7:8000";
  final String _token;

  CarApiService({required String token}) : _token = token;

  /// ترفع ملف صورة إلى السيرفر وتعيد رابط الصورة كنص.
  Future<String> uploadImage(File imageFile) async {
    try {
      if (_token.isEmpty) {
        throw Exception('User is not authenticated. Token is missing.');
      }

      final uri = Uri.parse('$_baseUrl/api/upload');
      var request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $_token';
      request.headers['Accept'] = 'application/json';
      request.files.add(await http.MultipartFile.fromPath('files[]', imageFile.path));

      var streamedResponse = await request.send().timeout(const Duration(seconds: 45));
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200 && response.statusCode != 201) {
        debugPrint('Image Upload Error Body: ${response.body}');
        throw Exception('فشل رفع الصورة. رمز الحالة: ${response.statusCode}');
      }

      var jsonResponse = jsonDecode(response.body);

      if (jsonResponse['status'] == true) {
        if (jsonResponse['files'] != null && jsonResponse['files'] is List && jsonResponse['files'].isNotEmpty) {
          return jsonResponse['files'][0] as String;
        } else {
          throw Exception('الرد من السيرفر لا يحتوي على قائمة الملفات المطلوبة.');
        }
      } else {
        throw Exception('السيرفر أعاد حالة فشل: ${jsonResponse['message'] ?? 'خطأ غير معروف'}');
      }

    } on SocketException {
      throw Exception('خطأ في الشبكة: يرجى التحقق من اتصالك بالإنترنت.');
    } on Exception catch (e) {
      debugPrint('An exception occurred in CarApiService.uploadImage: $e');
      rethrow;
    }
  }

  /// تضيف سيارة جديدة إلى السيرفر.
  Future<void> addCar(Map<String, dynamic> carData) async {
    final url = Uri.parse('$_baseUrl/api/cars');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $_token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode(carData),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('فشل إضافة السيارة: ${response.body}');
    }
  }

  // --- *** الدالة الجديدة *** ---
  /// تحدث بيانات سيارة موجودة على السيرفر.
  Future<Car> updateCar(int carId, Map<String, dynamic> carData) async {
    final url = Uri.parse('$_baseUrl/api/cars/$carId');

    // لغايات التصحيح والمتابعة
    debugPrint('Updating car with ID: $carId');
    debugPrint('Update Data: ${json.encode(carData)}');

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $_token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode(carData),
    );

    debugPrint('Update Car - Status Code: ${response.statusCode}');
    debugPrint('Update Car - Response Body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> responseData = json.decode(response.body);

        // قد يقوم السيرفر بإرجاع البيانات داخل مفتاح 'data' أو 'car'
        final carJson = responseData.containsKey('data')
            ? responseData['data']
            : responseData.containsKey('car')
            ? responseData['car']
            : responseData;

        if (carJson is Map<String, dynamic>) {
          return Car.fromJson(carJson);
        } else {
          throw Exception("الصيغة غير صحيحة لبيانات السيارة في الرد.");
        }
      } catch (e) {
        debugPrint("Error parsing updateCar response: $e");
        throw Exception("خطأ في تحليل بيانات السيارة المحدثة من السيرفر.");
      }
    } else {
      String errorMessage = 'فشل تحديث بيانات السيارة. رمز الحالة: ${response.statusCode}';
      if (response.body.isNotEmpty) {
        try {
          errorMessage += ' - ${json.decode(response.body)['message']}';
        } catch (_) {}
      }
      throw Exception(errorMessage);
    }
  }


  /// تجلب قائمة السيارات الخاصة بمكتب تأجير معين.
  Future<List<Car>> fetchMyCars(int carRentalId) async {
    final url = Uri.parse('$_baseUrl/api/car-rentals/$carRentalId/cars');

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $_token',
      'Accept': 'application/json',
    });

    if (response.statusCode == 200) {
      try {
        if (response.body.isEmpty) {
          throw Exception('الرد من السيرفر فارغ.');
        }
        final Map<String, dynamic> responseData = json.decode(response.body);

        final carListKey = responseData.containsKey('cars')
            ? 'cars'
            : responseData.containsKey('data')
            ? 'data'
            : null;

        if (carListKey != null && responseData[carListKey] is List) {
          final List<dynamic> carsList = responseData[carListKey];
          return carsList.map((jsonData) => Car.fromJson(jsonData)).toList();
        } else {
          throw Exception("الرد من السيرفر لا يحتوي على قائمة 'cars' أو 'data'.");
        }
      } catch (e) {
        debugPrint("Error parsing fetchMyCars response: $e");
        throw Exception("خطأ في تحليل البيانات القادمة من السيرفر.");
      }
    } else {
      String errorMessage = 'فشل جلب قائمة السيارات. رمز الحالة: ${response.statusCode}';
      if (response.body.isNotEmpty) {
        try {
          errorMessage += ' - ${json.decode(response.body)['message']}';
        } catch (_) {}
      }
      throw Exception(errorMessage);
    }
  }

  /// تحذف سيارة معينة من السيرفر.
  Future<bool> deleteCar(int carId) async {
    final url = Uri.parse('$_baseUrl/api/cars/$carId');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $_token',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['status'] == true;
    } else {
      String errorMessage = 'فشل حذف السيارة. رمز الحالة: ${response.statusCode}';
      if (response.body.isNotEmpty) {
        try {
          errorMessage += ' - ${json.decode(response.body)['message']}';
        } catch (_) {}
      }
      throw Exception(errorMessage);
    }
  }
}