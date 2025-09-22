import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/offer_model.dart';
import '../models/delivery_request_model.dart';
import '../utils/constants.dart';
import '../utils/auth_helper.dart';
import 'laravel_service.dart';

class OffersService {
  static const String baseUrl = Constants.baseUrl;

  /// جلب تفاصيل طلب التوصيل مع العروض المرسلة
  Future<Map<String, dynamic>> getDeliveryRequestWithOffers(String requestId) async {
    try {
      final token = await AuthHelper.getToken();
      if (token == null) {
        throw Exception('لم يتم العثور على رمز المصادقة');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/delivery/requests/$requestId/with-offers'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'status': true,
          'data': {
            'delivery_request': DeliveryRequestModel.fromJson(data['data']['delivery_request']),
            'offers': (data['data']['offers'] as List)
                .map((offer) => OfferModel.fromJson(offer))
                .toList(),
          },
          'message': data['message'] ?? 'تم جلب البيانات بنجاح',
        };
      } else if (response.statusCode == 401) {
        throw Exception('انتهت صلاحية جلسة المستخدم، يرجى تسجيل الدخول مرة أخرى');
      } else if (response.statusCode == 403) {
        throw Exception('ليس لديك صلاحية للوصول إلى هذا الطلب');
      } else if (response.statusCode == 404) {
        return {
          'status': false,
          'message': 'لم يتم العثور على الطلب المحدد. قد يكون الطلب قد تم حذفه أو انتهت صلاحيته.',
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'status': false,
          'message': errorData['message'] ?? 'حدث خطأ في الخادم',
        };
      }
    } catch (e) {
      if (e.toString().contains('SocketException') || e.toString().contains('TimeoutException')) {
        return {
          'status': false,
          'message': 'تحقق من اتصالك بالإنترنت وحاول مرة أخرى',
        };
      }
      return {
        'status': false,
        'message': 'حدث خطأ أثناء جلب البيانات: ${e.toString()}',
      };
    }
  }

  /// قبول عرض معين
  Future<Map<String, dynamic>> acceptOffer(String requestId, String offerId) async {
    try {
      final token = await AuthHelper.getToken();
      if (token == null) {
        throw Exception('لم يتم العثور على رمز المصادقة');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/delivery/requests/$requestId/offers/$offerId/accept'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'تم قبول العرض بنجاح',
          'data': data['data'],
        };
      } else if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'بيانات غير صحيحة');
      } else if (response.statusCode == 401) {
        throw Exception('انتهت صلاحية جلسة المستخدم، يرجى تسجيل الدخول مرة أخرى');
      } else if (response.statusCode == 403) {
        throw Exception('ليس لديك صلاحية لقبول هذا العرض');
      } else if (response.statusCode == 404) {
        throw Exception('لم يتم العثور على العرض المحدد');
      } else if (response.statusCode == 422) {
        final errorData = json.decode(response.body);
        String errorMessage = 'خطأ في البيانات المرسلة';
        if (errorData['errors'] != null) {
          final errors = errorData['errors'] as Map<String, dynamic>;
          errorMessage = errors.values.first[0] ?? errorMessage;
        }
        throw Exception(errorMessage);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'حدث خطأ أثناء قبول العرض');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') || e.toString().contains('TimeoutException')) {
        throw Exception('تحقق من اتصالك بالإنترنت وحاول مرة أخرى');
      }
      rethrow;
    }
  }

  /// تحديث حالة طلب التوصيل
  Future<Map<String, dynamic>> refreshDeliveryRequestStatus(String requestId) async {
    try {
      final token = await AuthHelper.getToken();
      if (token == null) {
        throw Exception('لم يتم العثور على رمز المصادقة');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/delivery/requests/$requestId/offers'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == true) {
          final requestData = data['data']['delivery_request'];
          final offersData = data['data']['offers'] ?? [];
          final lastMessage = data['lastMessage'];
          
          return {
            'success': true,
            'deliveryRequest': DeliveryRequestModel.fromJson(requestData),
            'offers': offersData.map<OfferModel>((offer) => OfferModel.fromJson(offer)).toList(),
            'message': lastMessage ?? data['message'] ?? 'تم تحديث البيانات بنجاح',
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'حدث خطأ في جلب البيانات',
          };
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'حدث خطأ أثناء تحديث حالة الطلب');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') || e.toString().contains('TimeoutException')) {
        throw Exception('تحقق من اتصالك بالإنترنت وحاول مرة أخرى');
      }
      rethrow;
    }
  }

  /// إلغاء طلب التوصيل
  Future<Map<String, dynamic>> cancelDeliveryRequest(String requestId, String reason) async {
    try {
      final token = await AuthHelper.getToken();
      if (token == null) {
        throw Exception('لم يتم العثور على رمز المصادقة');
      }

      final response = await http.patch(
        Uri.parse('$baseUrl/delivery/requests/$requestId/cancel'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'reason': reason,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'تم إلغاء الطلب بنجاح',
          'data': data['data'],
        };
      } else if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'بيانات غير صحيحة');
      } else if (response.statusCode == 401) {
        throw Exception('انتهت صلاحية جلسة المستخدم، يرجى تسجيل الدخول مرة أخرى');
      } else if (response.statusCode == 403) {
        throw Exception('ليس لديك صلاحية لإلغاء هذا الطلب');
      } else if (response.statusCode == 404) {
        throw Exception('لم يتم العثور على الطلب المحدد');
      } else if (response.statusCode == 422) {
        final errorData = json.decode(response.body);
        String errorMessage = 'خطأ في البيانات المرسلة';
        if (errorData['errors'] != null) {
          final errors = errorData['errors'] as Map<String, dynamic>;
          errorMessage = errors.values.first[0] ?? errorMessage;
        }
        throw Exception(errorMessage);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'حدث خطأ أثناء إلغاء الطلب');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') || e.toString().contains('TimeoutException')) {
        throw Exception('تحقق من اتصالك بالإنترنت وحاول مرة أخرى');
      }
      rethrow;
    }
  }
}