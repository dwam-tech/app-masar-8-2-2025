import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'notification_service.dart';

/// خدمة معالجة الأخطاء والتحقق من صحة البيانات
class ErrorHandlingService {
  static final ErrorHandlingService _instance = ErrorHandlingService._internal();
  factory ErrorHandlingService() => _instance;
  ErrorHandlingService._internal();

  final NotificationService _notificationService = NotificationService();

  /// معالجة أخطاء الشبكة والAPI
  String handleApiError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return 'انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى.';
        case DioExceptionType.sendTimeout:
          return 'انتهت مهلة إرسال البيانات. يرجى المحاولة مرة أخرى.';
        case DioExceptionType.receiveTimeout:
          return 'انتهت مهلة استقبال البيانات. يرجى المحاولة مرة أخرى.';
        case DioExceptionType.badResponse:
          return _handleHttpError(error.response?.statusCode);
        case DioExceptionType.cancel:
          return 'تم إلغاء الطلب.';
        case DioExceptionType.connectionError:
          return 'خطأ في الاتصال. يرجى التحقق من اتصال الإنترنت.';
        case DioExceptionType.badCertificate:
          return 'خطأ في شهادة الأمان.';
        case DioExceptionType.unknown:
        default:
          return 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.';
      }
    }
    
    if (error is SocketException) {
      return 'لا يوجد اتصال بالإنترنت. يرجى التحقق من الاتصال.';
    }
    
    return 'حدث خطأ غير متوقع: ${error.toString()}';
  }

  /// معالجة أخطاء HTTP
  String _handleHttpError(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'طلب غير صحيح. يرجى التحقق من البيانات المدخلة.';
      case 401:
        return 'غير مخول. يرجى تسجيل الدخول مرة أخرى.';
      case 403:
        return 'ممنوع. ليس لديك صلاحية للوصول لهذا المورد.';
      case 404:
        return 'المورد المطلوب غير موجود.';
      case 408:
        return 'انتهت مهلة الطلب. يرجى المحاولة مرة أخرى.';
      case 422:
        return 'بيانات غير صحيحة. يرجى التحقق من المدخلات.';
      case 429:
        return 'تم تجاوز الحد المسموح من الطلبات. يرجى المحاولة لاحقاً.';
      case 500:
        return 'خطأ في الخادم. يرجى المحاولة لاحقاً.';
      case 502:
        return 'خطأ في البوابة. يرجى المحاولة لاحقاً.';
      case 503:
        return 'الخدمة غير متاحة حالياً. يرجى المحاولة لاحقاً.';
      case 504:
        return 'انتهت مهلة البوابة. يرجى المحاولة لاحقاً.';
      default:
        return 'خطأ في الخادم (${statusCode ?? 'غير معروف'}). يرجى المحاولة لاحقاً.';
    }
  }

  /// عرض رسالة خطأ للمستخدم
  void showError(BuildContext context, dynamic error, {bool showDialog = false}) {
    final errorMessage = handleApiError(error);
    
    if (showDialog) {
      NotificationService.showError(context, errorMessage);
    } else {
      NotificationService.showError(context, errorMessage);
    }
  }



  /// معالجة الأخطاء مع إعادة المحاولة
  Future<T?> executeWithRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 2),
    bool Function(dynamic error)? shouldRetry,
  }) async {
    int attempts = 0;
    
    while (attempts < maxRetries) {
      try {
        return await operation();
      } catch (error) {
        attempts++;
        
        // التحقق من إمكانية إعادة المحاولة
        if (shouldRetry != null && !shouldRetry(error)) {
          rethrow;
        }
        
        if (attempts >= maxRetries) {
          rethrow;
        }
        
        // انتظار قبل إعادة المحاولة
        await Future.delayed(delay * attempts);
      }
    }
    
    return null;
  }

  /// تسجيل الأخطاء (يمكن ربطها بخدمة تسجيل خارجية)
  void logError(dynamic error, StackTrace? stackTrace, {Map<String, dynamic>? context}) {
    debugPrint('=== خطأ في التطبيق ===');
    debugPrint('الخطأ: $error');
    if (stackTrace != null) {
      debugPrint('المسار: $stackTrace');
    }
    if (context != null) {
      debugPrint('السياق: $context');
    }
    debugPrint('========================');
    
    // يمكن إضافة خدمات تسجيل خارجية هنا مثل Firebase Crashlytics
  }

  /// الحصول على رسالة خطأ مبسطة
  String getErrorMessage(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return 'انتهت مهلة الاتصال';
        case DioExceptionType.sendTimeout:
          return 'انتهت مهلة الإرسال';
        case DioExceptionType.receiveTimeout:
          return 'انتهت مهلة الاستقبال';
        case DioExceptionType.badResponse:
          return 'خطأ في الاستجابة من الخادم';
        case DioExceptionType.cancel:
          return 'تم إلغاء الطلب';
        case DioExceptionType.connectionError:
          return 'خطأ في الاتصال';
        case DioExceptionType.unknown:
        default:
          return 'حدث خطأ غير متوقع';
      }
    }
    
    if (error is FormatException) {
      return 'خطأ في تنسيق البيانات';
    }
    
    return error.toString();
  }

  /// التحقق من حالة الاتصال بالإنترنت
  Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  /// معالجة أخطاء الصلاحيات
  String handlePermissionError(String permission) {
    switch (permission) {
      case 'location':
        return 'يحتاج التطبيق إلى إذن الموقع لتحديد موقعك الحالي.';
      case 'camera':
        return 'يحتاج التطبيق إلى إذن الكاميرا لالتقاط الصور.';
      case 'storage':
        return 'يحتاج التطبيق إلى إذن التخزين لحفظ الملفات.';
      case 'notification':
        return 'يحتاج التطبيق إلى إذن الإشعارات لإرسال التنبيهات.';
      default:
        return 'يحتاج التطبيق إلى إذن $permission للعمل بشكل صحيح.';
    }
  }
}