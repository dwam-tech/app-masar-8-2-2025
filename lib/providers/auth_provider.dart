import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:saba2v2/models/appointment_model.dart';
import 'package:saba2v2/models/property_model.dart';
import 'package:saba2v2/providers/conversation_provider.dart';
import 'package:saba2v2/services/auth_service.dart';
import 'package:saba2v2/services/image_upload_service.dart';
import 'package:saba2v2/services/property_service.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import '../config/constants.dart';
import '../main.dart' show registerDeviceToken, hookTokenRefresh, deleteDeviceToken;

/// enum لتمثيل حالة المصادقة بشكل واضح
enum AuthStatus {
  uninitialized,
  authenticated,
  unauthenticated,
}

/// Provider شامل لإدارة حالة المصادقة والعقارات في التطبيق
class AuthProvider with ChangeNotifier {
  bool _isFetchingAppointments = false;
  //============================================================================
  // 1. الخدمات والاعتماديات (Dependencies)
  //============================================================================
  final AuthService _authService = AuthService();
  final PropertyService _propertyService = PropertyService();
  final ImageUploadService _imageUploadService = ImageUploadService();

  //============================================================================
  // 2. متغيرات الحالة (State Variables)
  //============================================================================

  // -- حالة المصادقة --
  AuthStatus _authStatus = AuthStatus.uninitialized;
  Map<String, dynamic>? _userData;
  String? _token;
  int? _realEstateId; // **هذا هو المتغير الذي سيحمل ID المطعم أو العقار**

  // -- حالة العقارات --
  List<Property> _properties = [];
  bool _isLoading = false; // متغير تحميل واحد لكل العمليات الطويلة

  // -- حالة المواعيد --
  List<Appointment> _appointments = [];
  bool _isLoadingAppointments = false;
  String? _appointmentsError;
  
  // -- الريفريش اللحظي --
  Timer? _appointmentsRefreshTimer;
  static const Duration _refreshInterval = Duration(seconds: 10); // كل 10 ثواني

  //============================================================================
  // 3. الـ Getters (لقراءة الحالة من الواجهة)
  //============================================================================

  AuthStatus get authStatus => _authStatus;
  Map<String, dynamic>? get userData => _userData;
  bool get isLoggedIn => _authStatus == AuthStatus.authenticated;
  bool get isAuthenticated => _authStatus == AuthStatus.authenticated;
  String? get token => _token;
  List<Property> get properties => _properties;
  bool get isLoading => _isLoading;
  String? get userType => _userData?['user_type'];

  // Getter جديد ومهم للوصول إلى ID المطعم/العقار من أي شاشة
  int? get realEstateId => _realEstateId;

  //============================================================================
  // 4. دوال إدارة الحالة (Actions)
  //============================================================================

  /// يتم استدعاؤها عند بدء تشغيل التطبيق لتهيئة الحالة
  AuthProvider() {
    initialize();
  }

  Future<void> initialize() async {
    await _loadUserSession();
  }

  /// إعادة تحميل الجلسة يدوياً (للاستخدام في حالات الأخطاء)
  Future<void> reloadSession() async {
    debugPrint("=== Manual session reload requested ===");
    await _loadUserSession();
  }

  /// تحميل جلسة المستخدم من التخزين المحلي وجلب بياناته (النسخة النهائية المصححة)
  Future<void> _loadUserSession() async {
    debugPrint("=== AuthProvider _loadUserSession Start ===");
    
    _token = await _authService.getToken();
    _userData = await _authService.getUserData();

    debugPrint("Token loaded: ${_token != null ? 'Yes' : 'No'}");
    debugPrint("User data loaded: ${_userData != null ? 'Yes' : 'No'}");

    // ==========================================================
    // --- التصحيح الحاسم: استخدام الدالة المناسبة حسب نوع المستخدم ---
    // ==========================================================
    if (_userData != null) {
      final currentUserType = _userData!['user_type'] as String?;
      debugPrint("AuthProvider: Loading session for user type: $currentUserType");
      
      if (currentUserType == 'restaurant' || currentUserType == 'restaurant_owner') {
         _realEstateId = await _authService.getRestaurantId();
         debugPrint("AuthProvider: Loaded restaurant ID: $_realEstateId");
         
         // تشخيص إضافي للمطاعم
         if (_realEstateId == null) {
           debugPrint("WARNING: Restaurant ID is null for $currentUserType!");
           debugPrint("User data restaurant_detail: ${_userData!['restaurant_detail']}");
           
           // محاولة استخراج ID مباشرة من بيانات المستخدم
           if (_userData!['restaurant_detail']?['id'] != null) {
             final directId = _userData!['restaurant_detail']['id'];
             debugPrint("Found restaurant ID directly in user data: $directId");
             
             // حفظ ID مباشرة في SharedPreferences
             final prefs = await SharedPreferences.getInstance();
             await prefs.setInt('restaurant_id', directId);
             _realEstateId = directId;
             debugPrint("Saved and set restaurant ID: $_realEstateId");
           }
         }
      } else if (currentUserType == 'real_estate_office' || currentUserType == 'real_estate_individual') {
        _realEstateId = await _authService.getRealEstateId();
        debugPrint("AuthProvider: Loaded real estate ID: $_realEstateId");
      } else if (currentUserType == 'car_rental_owner') {
        _realEstateId = await _authService.getCarRentalId();
        debugPrint("AuthProvider: Loaded car rental ID: $_realEstateId");
      } else {
        _realEstateId = null;
        debugPrint("AuthProvider: User type '$currentUserType' does not have an entity ID");
      }
    }
    // ==========================================================

    if (_token != null && _userData != null) {
      _authStatus = AuthStatus.authenticated;
      // **رسالة التشخيص المحسنة**
      debugPrint(
          "AuthProvider: Session loaded successfully. User type: '$userType', Entity ID: $_realEstateId");

      // Note: FCM token refresh hook will be handled by the UI layer with proper context
      debugPrint("AuthProvider: FCM token refresh hook will be handled by UI layer");

      if (userType == 'real_estate_office' ||
          userType == 'real_estate_individual') {
        await fetchMyProperties();
        // بدء الريفريش اللحظي للمواعيد عند تسجيل الدخول
        startAppointmentsAutoRefresh();
      }
    } else {
      _authStatus = AuthStatus.unauthenticated;
      debugPrint("AuthProvider: Session not loaded - missing token or user data");
    }
    
    debugPrint("=== AuthProvider _loadUserSession End ===");
    notifyListeners();
  }

  //-----------------------------------------------------
  // دوال خاصة بالمصادقة والعقارات
  //-----------------------------------------------------

  Future<Map<String, dynamic>> login(
      {required String email, required String password, BuildContext? context}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _authService.login(email: email, password: password);
      
      // التحقق من نجاح تسجيل الدخول قبل المتابعة
      if (result['status'] == true) {
        // **التعديل الحاسم: استدعاء _loadUserSession سيقوم بتحديث كل شيء، بما في ذلك _realEstateId**
        await _loadUserSession();
        
        // Note: FCM token registration will be handled by the UI layer with proper context
        if (isLoggedIn && _token != null) {
          print('[AUTH] FCM token registration will be handled by UI layer after login');
        }
        
        // بدء الريفريش اللحظي للمواعيد بعد تسجيل الدخول الناجح
        if (isLoggedIn && (userType == 'real_estate_office' || userType == 'real_estate_individual')) {
          startAppointmentsAutoRefresh();
        }
      }
      
      return result;
    } catch (e) {
      debugPrint('AuthProvider Login Error: $e');
      await logout();
      
      // معالجة أنواع مختلفة من الأخطاء
      String errorMessage;
      if (e.toString().contains('SocketException') || e.toString().contains('NetworkException')) {
        errorMessage = 'تعذر الاتصال بالخادم. يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى';
      } else if (e.toString().contains('FormatException')) {
        errorMessage = 'خطأ في تنسيق البيانات المستلمة من الخادم';
      } else {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      }
      
      return {'status': false, 'message': errorMessage};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout([ConversationProvider? conversationProvider]) async {
    // إيقاف الريفريش اللحظي قبل تسجيل الخروج
    stopAppointmentsAutoRefresh();
    
    // تصفير بيانات المحادثات إذا تم تمرير المزود
    conversationProvider?.clearData();
    
    // FCM: حذف Device Token من الباك-إند قبل تسجيل الخروج
    if (_token != null) {
      try {
        await deleteDeviceToken(_token!);
        print('[FCM] Device token deleted successfully on logout');
      } catch (e) {
        print('[FCM] Error deleting device token on logout: $e');
      }
    }
    
    await _authService.logout();
    _authStatus = AuthStatus.unauthenticated;
    _userData = null;
    _token = null;
    _realEstateId = null; // **تصفير الـ ID عند الخروج**
    _properties.clear();
    _appointments.clear(); // تصفير المواعيد عند الخروج
    notifyListeners();
  }

  /// تسجيل الدخول عبر Google (للمستخدمين العاديين فقط)
  Future<Map<String, dynamic>> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // إعداد Google Sign In
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );
      
      // تسجيل الدخول عبر Google
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        // المستخدم ألغى عملية تسجيل الدخول
        return {'status': false, 'message': 'تم إلغاء عملية تسجيل الدخول'};
      }
      
      // الحصول على معلومات المصادقة
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // إرسال البيانات إلى الباك إند
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/api/auth/google/mobile'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'google_id': googleUser.id,
          'email': googleUser.email,
          'name': googleUser.displayName ?? '',
          'avatar': googleUser.photoUrl ?? '',
          'access_token': googleAuth.accessToken,
        }),
      );
      
      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200 && responseData['status'] == true) {
        // حفظ بيانات المستخدم والتوكن
        await _authService.saveUserDataWithToken(
          token: responseData['token'],
          userData: responseData['user'],
        );
        
        // إعادة تحميل الجلسة
        await _loadUserSession();
        
        // تسجيل FCM token إذا كان المستخدم مسجل دخول
        if (isLoggedIn && _token != null) {
          print('[AUTH] FCM token registration will be handled by UI layer after Google login');
        }
        
        return {
          'status': true,
          'message': responseData['message'] ?? 'تم تسجيل الدخول بنجاح',
          'user': responseData['user']
        };
      } else {
        return {
          'status': false,
          'message': responseData['message'] ?? 'فشل في تسجيل الدخول عبر Google'
        };
      }
    } catch (e) {
      debugPrint('Google Sign In Error: $e');
      
      String errorMessage;
      if (e.toString().contains('SocketException') || e.toString().contains('NetworkException')) {
        errorMessage = 'تعذر الاتصال بالخادم. يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى';
      } else if (e.toString().contains('sign_in_canceled')) {
        errorMessage = 'تم إلغاء عملية تسجيل الدخول';
      } else if (e.toString().contains('network_error')) {
        errorMessage = 'خطأ في الشبكة. يرجى المحاولة مرة أخرى';
      } else {
        errorMessage = 'حدث خطأ أثناء تسجيل الدخول عبر Google';
      }
      
      return {'status': false, 'message': errorMessage};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyProperties() async {
    if (!isLoggedIn) {
      debugPrint("AuthProvider FETCH: User is not logged in. Aborting fetch.");
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final fetchedProperties = await _propertyService.getMyProperties();
      _properties = fetchedProperties;
      debugPrint("AuthProvider FETCH: Successfully loaded ${_properties.length} properties");
    } catch (error) {
      debugPrint("AuthProvider FETCH: An error occurred while fetching properties: $error");
      _properties = [];
      
      // يمكن إضافة معالجة أخطاء أكثر تفصيلاً هنا إذا لزم الأمر
      // مثل التحقق من نوع الخطأ وإظهار رسائل مناسبة للمستخدم
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addProperty({
    required String address,
    required String type,
    required int price,
    required String description,
    required File imageFile,
    required int bedrooms,
    required int bathrooms,
    required String view,
    required String paymentMethod,
    required String area,
    required bool isReady,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final String imageUrl = await _imageUploadService.uploadImage(imageFile);
      final newProperty = await _propertyService.addProperty(
        address: address,
        type: type,
        price: price,
        description: description,
        imageUrl: imageUrl,
        bedrooms: bedrooms,
        bathrooms: bathrooms,
        view: view,
        paymentMethod: paymentMethod,
        area: area,
        isReady: isReady,
      );
      _properties.insert(0, newProperty);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      debugPrint("AuthProvider: Error during add property process: $error");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProperty({
    required Property updatedProperty,
    File? newImageFile,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      var propertyDataToSend = updatedProperty.toJson();

      if (newImageFile != null) {
        final newImageUrl = await _imageUploadService.uploadImage(newImageFile);
        propertyDataToSend['image_url'] = newImageUrl;
      }
      final savedProperty = await _propertyService.updateProperty(
          updatedProperty.id, propertyDataToSend);
      final index = _properties.indexWhere((p) => p.id == savedProperty.id);
      if (index != -1) {
        _properties[index] = savedProperty;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      debugPrint("AuthProvider: Error updating property: $error");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProperty(int propertyId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _propertyService.deleteProperty(propertyId);
      _properties.removeWhere((p) => p.id == propertyId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      debugPrint("AuthProvider: Error deleting property: $error");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  //-----------------------------------------------------
  // دوال التسجيل الكاملة (تبقى كما هي)
  //-----------------------------------------------------
  Future<Map<String, dynamic>> registerNormalUser(
      {required String name,
      required String email,
      required String password,
      required String phone,
      required String governorate}) async {
    final result = await _authService.registerNormalUser(
        name: name,
        email: email,
        password: password,
        phone: phone,
        governorate: governorate);
    // تم إزالة _loadUserSession لتوجيه المستخدم إلى صفحة تسجيل الدخول
    return result;
  }

  /// التحقق من رمز OTP للبريد الإلكتروني
  Future<Map<String, dynamic>> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    print('DEBUG AuthProvider: verifyEmailOtp called');
    print('DEBUG AuthProvider: Email: "$email"');
    print('DEBUG AuthProvider: OTP: "$otp"');
    
    try {
      final result = await _authService.verifyEmailOtp(
        email: email,
        otp: otp,
      );
      print('DEBUG AuthProvider: verifyEmailOtp result: $result');
      return result;
    } catch (e) {
      print('DEBUG AuthProvider: verifyEmailOtp Exception: $e');
      debugPrint('AuthProvider verifyEmailOtp Error: $e');
      return {
        'status': false,
        'message': 'حدث خطأ أثناء التحقق من الرمز',
      };
    }
  }

  /// إعادة إرسال رمز OTP للبريد الإلكتروني
  Future<Map<String, dynamic>> resendEmailOtp({
    required String email,
  }) async {
    print('DEBUG AuthProvider: resendEmailOtp called');
    print('DEBUG AuthProvider: Email: "$email"');
    
    try {
      final result = await _authService.resendEmailOtp(email: email);
      print('DEBUG AuthProvider: resendEmailOtp result: $result');
      return result;
    } catch (e) {
      print('DEBUG AuthProvider: resendEmailOtp Exception: $e');
      debugPrint('AuthProvider resendEmailOtp Error: $e');
      return {
        'status': false,
        'message': 'حدث خطأ أثناء إعادة إرسال الرمز',
      };
    }
  }

  Future<Map<String, dynamic>> sendPasswordResetOtp({
    required String email,
  }) async {
    print('DEBUG AuthProvider: sendPasswordResetOtp called');
    print('DEBUG AuthProvider: Email: "$email"');
    try {
      final result = await _authService.sendPasswordResetOtp(email: email);
      print('DEBUG AuthProvider: sendPasswordResetOtp result: $result');
      return result;
    } catch (e) {
      print('DEBUG AuthProvider: sendPasswordResetOtp Exception: $e');
      debugPrint('AuthProvider sendPasswordResetOtp Error: $e');
      return {
        'status': false,
        'message': 'حدث خطأ أثناء إرسال رمز إعادة التعيين',
      };
    }
  }

  Future<Map<String, dynamic>> resetPasswordWithOtp({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    print('DEBUG AuthProvider: resetPasswordWithOtp called');
    print('DEBUG AuthProvider: Email: "$email"');
    print('DEBUG AuthProvider: OTP: "$otp"');
    try {
      final result = await _authService.resetPasswordWithOtp(
        email: email,
        otp: otp,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      print('DEBUG AuthProvider: resetPasswordWithOtp result: $result');
      return result;
    } catch (e) {
      print('DEBUG AuthProvider: resetPasswordWithOtp Exception: $e');
      debugPrint('AuthProvider resetPasswordWithOtp Error: $e');
      return {
        'status': false,
        'message': 'حدث خطأ أثناء إعادة تعيين كلمة المرور',
      };
    }
  }

  /// تغيير كلمة المرور للمستخدم المسجل
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    print('DEBUG AuthProvider: changePassword called');
    try {
      final result = await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );
      print('DEBUG AuthProvider: changePassword result: $result');
      
      // إذا تم تغيير كلمة المرور بنجاح، قم بتسجيل خروج المستخدم
      if (result['status'] == true) {
        await logout();
      }
      
      return result;
    } catch (e) {
      print('DEBUG AuthProvider: changePassword Exception: $e');
      debugPrint('AuthProvider changePassword Error: $e');
      return {
        'status': false,
        'message': 'حدث خطأ أثناء تغيير كلمة المرور',
      };
    }
  }

  Future<Map<String, dynamic>> registerRealstateOffice(
      {required String username,
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
      required String commercialCardBackPath}) async {
    final result = await _authService.registerRealstateOffice(
        username: username,
        email: email,
        password: password,
        phone: phone,
        city: city,
        address: address,
        vat: vat,
        officeLogoPath: officeLogoPath,
        ownerIdFrontPath: ownerIdFrontPath,
        ownerIdBackPath: ownerIdBackPath,
        officeImagePath: officeImagePath,
        commercialCardFrontPath: commercialCardFrontPath,
        commercialCardBackPath: commercialCardBackPath);
    // تم إزالة _loadUserSession لتوجيه المستخدم إلى صفحة تسجيل الدخول
    return result;
  }

  Future<Map<String, dynamic>> registerIndividualAgent(
      {required String name,
      required String email,
      required String password,
      required String phone,
      required String governorate,
      required String profileImage,
      required String agentIdFrontImage,
      required String agentIdBackImage,
      String? taxCardFrontImage,
      String? taxCardBackImage}) async {
    return await _authService.registerIndividualAgent(
        name: name,
        email: email,
        password: password,
        phone: phone,
        governorate: governorate,
        profileImage: profileImage,
        agentIdFrontImage: agentIdFrontImage,
        agentIdBackImage: agentIdBackImage,
        taxCardFrontImage: taxCardFrontImage,
        taxCardBackImage: taxCardBackImage);
  }

  Future<Map<String, dynamic>> registerDeliveryOffice(
      {required String fullName,
      required String email,
      required String password,
      required String phone,
      required String officeName,
      required String governorate,
      required String logoImageUrl,
      required String commercialFrontImageUrl,
      required String commercialBackImageUrl,
      required List<String> paymentMethods,
      required List<String> rentalTypes,
      required double costPerKm,
      required double driverCost,
      required int maxKmPerDay}) async {
    return await _authService.registerDeliveryOffice(
        fullName: fullName,
        email: email,
        password: password,
        phone: phone,
        officeName: officeName,
        governorate: governorate,
        logoImageUrl: logoImageUrl,
        commercialFrontImageUrl: commercialFrontImageUrl,
        commercialBackImageUrl: commercialBackImageUrl,
        paymentMethods: paymentMethods,
        rentalTypes: rentalTypes,
        costPerKm: costPerKm,
        driverCost: driverCost,
        maxKmPerDay: maxKmPerDay);
  }

  Future<Map<String, dynamic>> registerDeliveryPerson(
      {required String fullName,
      required String email,
      required String password,
      required String phone,
      required String governorate,
      required String profileImageUrl,
      required List<String> paymentMethods,
      required List<String> rentalTypes,
      required double costPerKm,
      required double driverCost,
      required int maxKmPerDay}) async {
    return await _authService.registerDeliveryPerson(
        fullName: fullName,
        email: email,
        password: password,
        phone: phone,
        governorate: governorate,
        profileImageUrl: profileImageUrl,
        paymentMethods: paymentMethods,
        rentalTypes: rentalTypes,
        costPerKm: costPerKm,
        driverCost: driverCost,
        maxKmPerDay: maxKmPerDay);
  }

  Future<Map<String, dynamic>> registerRestaurant(
      {required Map<String, dynamic> legalData,
      required Map<String, dynamic> accountInfo,
      required Map<String, dynamic> workHours}) async {
    return await _authService.registerRestaurant(
        legalData: legalData, accountInfo: accountInfo, workHours: workHours);
  }

  // --- دوال المواعيد (تبقى كما هي) ---
  List<Appointment> get appointments => _appointments;
  bool get isLoadingAppointments => _isLoadingAppointments;
  String? get appointmentsError => _appointmentsError;

  Future<void> fetchAppointments() async {
    if (_isFetchingAppointments) return;
    _isFetchingAppointments = true;
    _isLoadingAppointments = true;
    _appointmentsError = null;
    notifyListeners();
    try {
      // استخدام endpoint موجود مؤقتاً حتى يتم إضافة الـ route الجديد
      final url = Uri.parse('${AppConstants.apiBaseUrl}/appointments');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token'
        },
      );
      debugPrint('Silent Appointments Response Body: ${response.body}');
      debugPrint('Appointments Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final decodedData = json.decode(utf8.decode(response.bodyBytes));
        
        // التحقق من وجود البيانات قبل المعالجة
        if (decodedData != null && decodedData is Map<String, dynamic>) {
          final appointmentsResponse = AppointmentsResponse.fromJson(decodedData);
          
          // فلترة المواعيد لإظهار مواعيد مقدم الخدمة الحالي فقط
          if (_userData != null && _userData!['id'] != null) {
            final currentUserId = _userData!['id'];
            _appointments = appointmentsResponse.appointments
                .where((appointment) => appointment.provider?.id == currentUserId)
                .toList();
          } else {
            _appointments = appointmentsResponse.appointments;
          }
          
          // ترتيب المواعيد من الأجدد للأقدم
          // الترتيب حسب تاريخ الإنشاء (الأحدث أولاً)
          _appointments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          debugPrint("تم جلب وترتيب المواعيد: ${_appointments.length} موعد، من الأجدد للأقدم");
        } else {
          _appointmentsError = 'Invalid response format from server';
          _appointments = [];
        }
      } else {
        _appointmentsError =
            'Failed to load appointments. Status code: ${response.statusCode}';
        debugPrint("Failed to fetch appointments. Status: ${response.statusCode}, Body: ${response.body}");
        _appointments = [];
      }
    } catch (error) {
      _appointmentsError = 'An error occurred: ${error.toString()}';
      debugPrint("Error fetching appointments: $error");
      _appointments = [];
    } finally {
      _isFetchingAppointments = false;
      _isLoadingAppointments = false;
      notifyListeners();
    }
  }

  /// بدء الريفريش اللحظي للمواعيد
  void startAppointmentsAutoRefresh() {
    // إلغاء أي timer موجود مسبقاً
    _appointmentsRefreshTimer?.cancel();
    
    // بدء timer جديد
    _appointmentsRefreshTimer = Timer.periodic(_refreshInterval, (timer) {
      // التحقق من أن المستخدم ما زال مسجل دخول
      if (isLoggedIn) {
        // جلب المواعيد بصمت (بدون إظهار loading indicator)
        _fetchAppointmentsSilently();
      } else {
        // إيقاف التايمر إذا لم يعد المستخدم مسجل دخول
        stopAppointmentsAutoRefresh();
      }
    });
  }

  /// إيقاف الريفريش اللحظي للمواعيد
  void stopAppointmentsAutoRefresh() {
    _appointmentsRefreshTimer?.cancel();
    _appointmentsRefreshTimer = null;
  }

  /// إجبار الريفريش الفوري للمواعيد
  Future<void> forceRefreshAppointments() async {
    await _fetchAppointmentsSilently();
  }

  /// جلب المواعيد بصمت (بدون تغيير حالة التحميل)
  Future<void> _fetchAppointmentsSilently() async {
    if (_isFetchingAppointments) return;
    _isFetchingAppointments = true;
    try {
      final url = Uri.parse('${AppConstants.apiBaseUrl}/appointments');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token'
        },
      );
      
      if (response.statusCode == 200) {
        final decodedData = json.decode(utf8.decode(response.bodyBytes));
        
        if (decodedData != null && decodedData is Map<String, dynamic>) {
          final appointmentsResponse = AppointmentsResponse.fromJson(decodedData);
          
          List<Appointment> newAppointments;
          if (_userData != null && _userData!['id'] != null) {
            final currentUserId = _userData!['id'];
            newAppointments = appointmentsResponse.appointments
                .where((appointment) => appointment.provider?.id == currentUserId)
                .toList();
          } else {
            newAppointments = appointmentsResponse.appointments;
          }
          
          // الترتيب حسب تاريخ الإنشاء (الأحدث أولاً)
          newAppointments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          
          // التحقق من وجود تغييرات قبل التحديث
          if (_hasAppointmentsChanged(newAppointments)) {
            _appointments = newAppointments;
            _appointmentsError = null;
            // إشعار المستمعين بالتحديث
            notifyListeners();
            debugPrint("تم تحديث المواعيد: ${_appointments.length} موعد، مرتبة من الأجدد للأقدم");
          }
        }
      }
    } catch (error) {
      // في حالة الريفريش الصامت، لا نعرض الأخطاء للمستخدم
      debugPrint("Silent refresh error: $error");
    } finally {
      _isFetchingAppointments = false;
    }
  }

  /// التحقق من وجود تغييرات في المواعيد
  bool _hasAppointmentsChanged(List<Appointment> newAppointments) {
    if (_appointments.length != newAppointments.length) {
      return true;
    }
    
    // إنشاء خريطة للمواعيد الحالية للمقارنة السريعة
    final currentAppointmentsMap = <int, Appointment>{};
    for (final appointment in _appointments) {
      currentAppointmentsMap[appointment.id] = appointment;
    }
    
    // التحقق من وجود مواعيد جديدة أو تغييرات في الحالة
    for (final newAppointment in newAppointments) {
      final currentAppointment = currentAppointmentsMap[newAppointment.id];
      if (currentAppointment == null || 
          currentAppointment.status != newAppointment.status ||
          currentAppointment.appointmentDatetime != newAppointment.appointmentDatetime) {
        return true;
      }
    }
    
    return false;
  }

  Future<bool> approveAppointment({required int appointmentId}) async {
    final url = Uri.parse(
        '${AppConstants.apiBaseUrl}/appointments/$appointmentId/status');
    try {
      final body = json.encode({
        "status": "provider_approved",
        "provider_approved": true,
        "notes": "تم تحديد الموعد من قبل المكتب"
      });
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token'
        },
        body: body,
      );
      
      if (response.statusCode == 200) {
        // تحديث حالة الموعد في القائمة المحلية بدلاً من حذفه
        final appointmentIndex = _appointments.indexWhere((appointment) => appointment.id == appointmentId);
        if (appointmentIndex != -1) {
          // إنشاء موعد جديد بحالة محدثة
          final originalAppointment = _appointments[appointmentIndex];
          final updatedAppointment = Appointment(
            id: originalAppointment.id,
            appointmentDatetime: originalAppointment.appointmentDatetime,
            note: originalAppointment.note,
            adminNote: "تم تحديد الموعد من قبل المكتب",
            status: "provider_approved",
            property: originalAppointment.property,
            customer: originalAppointment.customer,
            provider: originalAppointment.provider,
            createdAt: originalAppointment.createdAt, // تمرير القيمة الموجودة
          );
          
          // استبدال الموعد القديم بالموعد المحدث
          _appointments[appointmentIndex] = updatedAppointment;
        }
        notifyListeners();
        return true;
      } else {
        // طباعة رسالة الخطأ للتشخيص
        debugPrint("Failed to approve appointment. Status: ${response.statusCode}, Body: ${response.body}");
        return false;
      }
    } catch (error) {
      debugPrint("Error approving appointment: $error");
      return false;
    }
  }

  //============================================================================
  // 5. تنظيف الموارد (Cleanup)
  //============================================================================
  
  @override
  void dispose() {
    _appointmentsRefreshTimer?.cancel();
    super.dispose();
  }

  /// دالة تحديث محافظة المستخدم
  Future<bool> updateCity(String newCity) async {
    try {
      final success = await _authService.updateCity(newCity);
      if (success) {
        // تحديث البيانات المحلية في Provider
        if (_userData != null) {
          _userData!['governorate'] = newCity;
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('خطأ في AuthProvider.updateCity: $e');
      return false;
    }
  }

  /// دالة للحصول على محافظة المستخدم الحالية
  String? get userCity {
    return _userData?['governorate'];
  }
}










// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:saba2v2/models/appointment_model.dart';
// import 'package:saba2v2/models/property_model.dart';
// import 'package:saba2v2/services/auth_service.dart';
// import 'package:saba2v2/services/image_upload_service.dart';
// import 'package:saba2v2/services/property_service.dart';
// import 'package:http/http.dart' as http;


// /// enum لتمثيل حالة المصادقة بشكل واضح
// enum AuthStatus {
//   uninitialized,
//   authenticated,
//   unauthenticated,
// }

// /// Provider شامل لإدارة حالة المصادقة والعقارات في التطبيق
// class AuthProvider with ChangeNotifier {
//   //============================================================================
//   // 1. الخدمات والاعتماديات (Dependencies)
//   //============================================================================
//   final AuthService _authService = AuthService();
//   final PropertyService _propertyService = PropertyService();
//   final ImageUploadService _imageUploadService = ImageUploadService();
//   int? _realEstateId;
//   List<Appointment> _appointments = [];
//   bool _isLoadingAppointments = false;
//   String? _appointmentsError;


//   // أضف Getter جديد
//   int? get realEstateId => _realEstateId;

//   //============================================================================
//   // 2. متغيرات الحالة (State Variables)
//   //============================================================================

//   // -- حالة المصادقة --
//   AuthStatus _authStatus = AuthStatus.uninitialized;
//   Map<String, dynamic>? _userData;
//   String? _token;

//   // -- حالة العقارات --
//   List<Property> _properties = [];
//   bool _isLoading = false; // متغير تحميل واحد لكل العمليات الطويلة

//   //============================================================================
//   // 3. الـ Getters (لقراءة الحالة من الواجهة)
//   //============================================================================

//   AuthStatus get authStatus => _authStatus;
//   Map<String, dynamic>? get userData => _userData;
//   bool get isLoggedIn => _authStatus == AuthStatus.authenticated;
//   String? get token => _token;
//   List<Property> get properties => _properties;
//   bool get isLoading => _isLoading;

//   // Getter لنوع المستخدم لتسهيل الوصول إليه من أي مكان
//   String? get userType => _userData?['user_type'];

//   //============================================================================
//   // 4. دوال إدارة الحالة (Actions)
//   //============================================================================

//   /// يتم استدعاؤها عند بدء تشغيل التطبيق لتهيئة الحالة
//   Future<void> initialize() async {
//     await _loadUserSession();
//   }

//   /// إعادة تحميل الجلسة يدوياً (للاستخدام في حالات الأخطاء)
//   Future<void> reloadSession() async {
//     debugPrint("=== Manual session reload requested ===");
//     await _loadUserSession();
//   }

//   /// تحميل جلسة المستخدم من التخزين المحلي وجلب بياناته (النسخة النهائية المصححة)
//   Future<void> _loadUserSession() async {
//     _token = await _authService.getToken();
//     _userData = await _authService.getUserData();

//     if (_token != null && _userData != null) {
//       _authStatus = AuthStatus.authenticated;
//       debugPrint(
//           "AuthProvider SESSION: Session loaded. User type is: '$userType'.");

//       // التحقق من نوع المستخدم قبل جلب العقارات
//       if (userType == 'real_estate_office' ||
//           userType == 'real_estate_individual') {
//         debugPrint(
//             "AuthProvider SESSION: User is Real Estate. Fetching properties...");
//         await fetchMyProperties();
//       } else {
//         debugPrint(
//             "AuthProvider SESSION: User is not a real estate type. Skipping property fetch.");
//       }
//     } else {
//       _authStatus = AuthStatus.unauthenticated;
//     }
//     notifyListeners();
//   }
//   //-----------------------------------------------------
//   // دوال خاصة بالمصادقة والعقارات
//   //-----------------------------------------------------

//   //  Future<void> _initializeUser() async {
//   //   final token = await _authService.getToken();
//   //   if (token != null) {
//   //     final userDataMap = await _authService.getUserData();
//   //     if (userDataMap != null) {
//   //       _user = User.fromJson(userDataMap);
//   //       // **الخطوة الأهم: تحميل الـ ID عند بدء التشغيل**
//   //       _realEstateId = await _authService.getRealEstateId();
//   //       debugPrint("AuthProvider (init): Loaded realEstateId -> $_realEstateId");
//   //       notifyListeners();
//   //     }
//   //   }
//   // }

//   // Future<Map<String, dynamic>> login({
//   //   required String email,
//   //   required String password,
//   // }) async {
//   //   _isLoading = true;
//   //   notifyListeners();

//   //   try {
//   //     final result = await _authService.login(email: email, password: password);

//   //     if (result['status'] == true && result['user'] != null) {
//   //       debugPrint("AuthProvider LOGIN: Login API call successful.");

//   //       // قراءة البيانات المحفوظة حديثًا بواسطة الخدمة
//   //       await _loadUserSession(); // هذه الدالة أصبحت ذكية وستقوم باللازم

//   //       return result;
//   //     } else {
//   //       // في حالة فشل تسجيل الدخول من الـ API
//   //       _authStatus = AuthStatus.unauthenticated;
//   //       return result;
//   //     }
//   //   } catch (e) {
//   //     debugPrint("AuthProvider LOGIN: An error occurred: $e");
//   //     _authStatus = AuthStatus.unauthenticated;
//   //     return {'status': false, 'message': 'حدث خطأ غير متوقع: $e'};
//   //   } finally {
//   //     _isLoading = false;
//   //     notifyListeners();
//   //   }
//   // }

// Future<Map<String, dynamic>> login({required String email, required String password}) async {
//     _isLoading = true;
//     notifyListeners();
//     try {
//       final result = await _authService.login(email: email, password: password);
//       await _loadUserSession(); // تحديث حالة الـ Provider بعد نجاح تسجيل الدخول
//       return result;
//     } catch (e) {
//       await logout();
//       return {'status': false, 'message': e.toString()};
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }


//   Future<void> logout() async {
//     try {
//       await _authService.logout();
//     } catch (e) {
//       debugPrint("Failed to logout from server: $e");
//     } finally {
//       _authStatus = AuthStatus.unauthenticated;
//       _userData = null;
//       _token = null;
//       _properties.clear(); // مسح قائمة العقارات عند الخروج
//       notifyListeners();
//     }
//   }

//   /// جلب عقارات المستخدم الحالي من الـ API
//   // في ملف: lib/providers/auth_provider.dart

//   Future<void> fetchMyProperties() async {
//     if (!isLoggedIn) {
//       debugPrint("AuthProvider FETCH: User is not logged in. Aborting fetch.");
//       return;
//     }

//     debugPrint("AuthProvider FETCH: Starting to fetch properties...");
//     _isLoading = true;
//     notifyListeners(); // <-- إعلام الواجهة ببدء التحميل

//     try {
//       // استدعاء الخدمة لجلب البيانات
//       final fetchedProperties = await _propertyService.getMyProperties();

//       // تحديث قائمة العقارات في الـ Provider
//       _properties = fetchedProperties;

//       // ==========================================================
//       // --- طباعة تشخيصية للتحقق من البيانات المستلمة ---
//       debugPrint(
//           "AuthProvider FETCH: Successfully fetched ${_properties.length} properties.");
//       if (_properties.isNotEmpty) {
//         debugPrint(
//             "AuthProvider FETCH: First property address: ${_properties.first.address}");
//       }
//       // ==========================================================
//     } catch (error) {
//       debugPrint(
//           "AuthProvider FETCH: An error occurred while fetching properties.");
//       debugPrint("Error details: $error");
//       // في حالة الخطأ، تأكد من إفراغ القائمة
//       _properties = [];
//     }

//     // إيقاف التحميل وإعلام الواجهة بالتغيير النهائي
//     _isLoading = false;
//     debugPrint("AuthProvider FETCH: Fetch finished. Notifying listeners.");
//     notifyListeners(); // <-- التأكد من إعلام الواجهة بالبيانات الجديدة أو القائمة الفارغة
//   }

//   /// إضافة عقار جديد (رفع الصورة ثم إضافة البيانات)
//   Future<bool> addProperty({
//     required String address,
//     required String type,
//     required int price,
//     required String description,
//     required File imageFile,
//     required int bedrooms,
//     required int bathrooms,
//     required String view,
//     required String paymentMethod,
//     required String area,
//     required bool isReady,
//   }) async {
//     _isLoading = true;
//     notifyListeners();
//     try {
//       final String imageUrl = await _imageUploadService.uploadImage(imageFile);
//       final newProperty = await _propertyService.addProperty(
//         address: address,
//         type: type,
//         price: price,
//         description: description,
//         imageUrl: imageUrl,
//         bedrooms: bedrooms,
//         bathrooms: bathrooms,
//         view: view,
//         paymentMethod: paymentMethod,
//         area: area,
//         isReady: isReady,
//       );
//       _properties.insert(0, newProperty);
//       _isLoading = false;
//       notifyListeners();
//       return true;
//     } catch (error) {
//       debugPrint("AuthProvider: Error during add property process: $error");
//       _isLoading = false;
//       notifyListeners();
//       return false;
//     }
//   }

//   /// تحديث بيانات عقار
//   // في ملف: lib/providers/auth_provider.dart

// // استبدل هذه الدالة بالكامل
//   Future<bool> updateProperty({
//     required Property updatedProperty, // <-- الاسم الصحيح هو updatedProperty
//     File? newImageFile,
//   }) async {
//     _isLoading = true;
//     notifyListeners();

//     try {
//       var propertyDataToSend = updatedProperty.toJson();

//       if (newImageFile != null) {
//         debugPrint("AuthProvider: Uploading new image for update...");
//         final newImageUrl = await _imageUploadService.uploadImage(newImageFile);
//         propertyDataToSend['image_url'] = newImageUrl;
//       }

//       final savedProperty = await _propertyService.updateProperty(
//           updatedProperty.id, // <-- تمرير الـ ID
//           propertyDataToSend // <-- تمرير الـ Map
//           );

//       final index = _properties.indexWhere((p) => p.id == savedProperty.id);
//       if (index != -1) {
//         _properties[index] = savedProperty;
//       }

//       _isLoading = false;
//       notifyListeners();
//       return true;
//     } catch (error) {
//       debugPrint("AuthProvider: Error updating property: $error");
//       _isLoading = false;
//       notifyListeners();
//       return false;
//     }
//   }

//   Future<bool> deleteProperty(int propertyId) async {
//     _isLoading = true;
//     notifyListeners();

//     try {
//       await _propertyService.deleteProperty(propertyId);

//       // احذف العقار من القائمة المحلية
//       _properties.removeWhere((p) => p.id == propertyId);

//       _isLoading = false;
//       notifyListeners();
//       return true;
//     } catch (error) {
//       debugPrint("AuthProvider: Error deleting property: $error");
//       _isLoading = false;
//       notifyListeners();
//       return false;
//     }
//   }
//   //-----------------------------------------------------
//   // دوال التسجيل الكاملة
//   //-----------------------------------------------------

//   Future<Map<String, dynamic>> registerNormalUser(
//       {required String name,
//       required String email,
//       required String password,
//       required String phone,
//       required String governorate}) async {
//     final result = await _authService.registerNormalUser(
//         name: name,
//         email: email,
//         password: password,
//         phone: phone,
//         governorate: governorate);
//     if (result['status'] == true) await _loadUserSession();
//     return result;
//   }

//   Future<Map<String, dynamic>> registerRealstateOffice(
//       {required String username,
//       required String email,
//       required String password,
//       required String phone,
//       required String city,
//       required String address,
//       required bool vat,
//       required String officeLogoPath,
//       required String ownerIdFrontPath,
//       required String ownerIdBackPath,
//       required String officeImagePath,
//       required String commercialCardFrontPath,
//       required String commercialCardBackPath}) async {
//     final result = await _authService.registerRealstateOffice(
//         username: username,
//         email: email,
//         password: password,
//         phone: phone,
//         city: city,
//         address: address,
//         vat: vat,
//         officeLogoPath: officeLogoPath,
//         ownerIdFrontPath: ownerIdFrontPath,
//         ownerIdBackPath: ownerIdBackPath,
//         officeImagePath: officeImagePath,
//         commercialCardFrontPath: commercialCardFrontPath,
//         commercialCardBackPath: commercialCardBackPath);
//     if (result['status'] == true) await _loadUserSession();
//     return result;
//   }

//   Future<Map<String, dynamic>> registerIndividualAgent(
//       {required String name,
//       required String email,
//       required String password,
//       required String phone,
//       required String governorate,
//       required String profileImage,
//       required String agentIdFrontImage,
//       required String agentIdBackImage,
//       String? taxCardFrontImage,
//       String? taxCardBackImage}) async {
//     return await _authService.registerIndividualAgent(
//         name: name,
//         email: email,
//         password: password,
//         phone: phone,
//         governorate: governorate,
//         profileImage: profileImage,
//         agentIdFrontImage: agentIdFrontImage,
//         agentIdBackImage: agentIdBackImage,
//         taxCardFrontImage: taxCardFrontImage,
//         taxCardBackImage: taxCardBackImage);
//   }

//   Future<Map<String, dynamic>> registerDeliveryOffice(
//       {required String fullName,
//       required String email,
//       required String password,
//       required String phone,
//       required String officeName,
//       required String governorate,
//       required String logoImageUrl,
//       required String commercialFrontImageUrl,
//       required String commercialBackImageUrl,
//       required List<String> paymentMethods,
//       required List<String> rentalTypes,
//       required double costPerKm,
//       required double driverCost,
//       required int maxKmPerDay}) async {
//     return await _authService.registerDeliveryOffice(
//         fullName: fullName,
//         email: email,
//         password: password,
//         phone: phone,
//         officeName: officeName,
//         governorate: governorate,
//         logoImageUrl: logoImageUrl,
//         commercialFrontImageUrl: commercialFrontImageUrl,
//         commercialBackImageUrl: commercialBackImageUrl,
//         paymentMethods: paymentMethods,
//         rentalTypes: rentalTypes,
//         costPerKm: costPerKm,
//         driverCost: driverCost,
//         maxKmPerDay: maxKmPerDay);
//   }

//   Future<Map<String, dynamic>> registerDeliveryPerson(
//       {required String fullName,
//       required String email,
//       required String password,
//       required String phone,
//       required String governorate,
//       required String profileImageUrl,
//       required List<String> paymentMethods,
//       required List<String> rentalTypes,
//       required double costPerKm,
//       required double driverCost,
//       required int maxKmPerDay}) async {
//     return await _authService.registerDeliveryPerson(
//         fullName: fullName,
//         email: email,
//         password: password,
//         phone: phone,
//         governorate: governorate,
//         profileImageUrl: profileImageUrl,
//         paymentMethods: paymentMethods,
//         rentalTypes: rentalTypes,
//         costPerKm: costPerKm,
//         driverCost: driverCost,
//         maxKmPerDay: maxKmPerDay);
//   }

//   Future<Map<String, dynamic>> registerRestaurant(
//       {required Map<String, dynamic> legalData,
//       required Map<String, dynamic> accountInfo,
//       required Map<String, dynamic> workHours}) async {
//     return await _authService.registerRestaurant(
//         legalData: legalData, accountInfo: accountInfo, workHours: workHours);
//   }





//   List<Appointment> get appointments => _appointments;
//   bool get isLoadingAppointments => _isLoadingAppointments;
//   String? get appointmentsError => _appointmentsError;

//   // --- أضف هذه الدالة الجديدة لجلب المواعيد ---
//   Future<void> fetchAppointments() async {
//     // افترض أن التوكن مخزن في متغير اسمه _token
//     // final token = _token; 
//     // if (token == null) {
//     //   _appointmentsError = "User not authenticated.";
//     //   notifyListeners();
//     //   return;
//     // }
    
//     // للـtesting, يمكن استخدام توكن وهمي مؤقتاً
//    // const String dummyToken = _token; // <-- ضع التوكن الحقيقي هنا

//     _isLoadingAppointments = true;
//     _appointmentsError = null;
//     notifyListeners();

//     try {
//       // استبدل 'YOUR_BASE_URL' بعنوان الـ URL الأساسي لديك
//       final url = Uri.parse('http://192.168.1.7:8000/api/appointments');
      
//       final response = await http.get(
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//           'Authorization': 'Bearer $_token', // <-- استخدام التوكن
//         },
//       );

//       if (response.statusCode == 200) {
//         final decodedData = json.decode(utf8.decode(response.bodyBytes));
//         final appointmentsResponse = AppointmentsResponse.fromJson(decodedData);
//         _appointments = appointmentsResponse.appointments;
//       } else {
//         // Handle server errors
//         _appointmentsError = 'Failed to load appointments. Status code: ${response.statusCode}';
//       }
//     } catch (error) {
//       // Handle connection errors
//       _appointmentsError = 'An error occurred: ${error.toString()}';
//       if (kDebugMode) {
//         print(_appointmentsError);
//       }
//     } finally {
//       _isLoadingAppointments = false;
//       notifyListeners();
//     }
//   }


//   // ... (داخل كلاس AuthProvider)

// // --- أضف هذه الدالة الجديدة ---
// Future<bool> approveAppointment({required int appointmentId}) async {
//   // افترض أن التوكن مخزن في متغير اسمه _token
//   // final token = _token;
//   // if (token == null) return false;

//   // للـtesting, يمكن استخدام توكن وهمي مؤقتاً
//   const String dummyToken = "YOUR_AUTH_TOKEN_HERE"; // <-- ضع التوكن الحقيقي هنا

//   final url = Uri.parse('http://192.168.1.7:8000/api/appointments/$appointmentId/status');

//   try {
//     // تجهيز البيانات التي سيتم إرسالها (Body)
//     final body = json.encode({
//       "status": "provider_approved",
//       // "provider_approved": true, // هذا الحقل قد لا يكون ضروريا إذا كان الخادم يكتفي بالـ status
//       "notes": "تم تأكيد الموعد من قبل المكتب العقاري." // يمكنك استخدام ملاحظة ثابتة أو جعلها متغيرة
//     });

//     final response = await http.put(
//       url,
//       headers: {
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//         'Authorization': 'Bearer $_token',
//       },
//       body: body,
//     );

//     // إذا نجح الطلب (عادة 200 OK for PUT update)
//     if (response.statusCode == 200) {
//       // إزالة الموعد المقبول من القائمة المحلية
//       _appointments.removeWhere((appointment) => appointment.id == appointmentId);
//       // إعلام الواجهة بوجود تغيير لتحديث نفسها
//       notifyListeners();
//       return true; // إرجاع true للدلالة على النجاح
//     } else {
//       // في حالة وجود خطأ من الخادم
//       if (kDebugMode) {
//         print('Failed to approve appointment. Status: ${response.statusCode}, Body: ${response.body}');
//       }
//       return false;
//     }
//   } catch (error) {
//     // في حالة وجود خطأ في الاتصال
//     if (kDebugMode) {
//       print('Error approving appointment: ${error.toString()}');
//     }
//     return false;
//   }
// }
// }
