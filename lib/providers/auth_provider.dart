// مسار الملف: lib/providers/auth_provider.dart

import 'package:flutter/foundation.dart';
import 'package:saba2v2/services/auth_service.dart';

enum AuthStatus {
  uninitialized, // لم يتم التحقق بعد
  authenticated, // تم التحقق والمستخدم مسجل دخوله
  unauthenticated, // تم التحقق والمستخدم غير مسجل دخوله
}

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

   AuthStatus _authStatus = AuthStatus.uninitialized;


  bool _isLoggedIn = false;
  Map<String, dynamic>? _userData;
  String? _token;

  bool get isLoggedIn => _isLoggedIn;
  Map<String, dynamic>? get userData => _userData;
  String? get token => _token;
   AuthStatus get authStatus => _authStatus; // Getter للمتغير الجديد


  // تهيئة الحالة عند بدء التطبيق
  Future<void> initialize() async {
    await _loadUserSession();
  }

  // تحميل بيانات جلسة المستخدم من التخزين المحلي
 Future<void> _loadUserSession() async {
    _token = await _authService.getToken();
    _userData = await _authService.getUserData();

    if (_token != null) {
      _isLoggedIn = true;
      _authStatus = AuthStatus.authenticated;
    } else {
      _isLoggedIn = false;
      _authStatus = AuthStatus.unauthenticated;
    }
    // نقوم بإعلام المستمعين مرة واحدة في النهاية
    notifyListeners();
  }


  

  // تسجيل الدخول
 Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final result = await _authService.login(email: email, password: password);
    if (result['status'] == true) {
      await _loadUserSession(); // ستؤدي هذه الدالة إلى تحديث الحالة إلى authenticated
    }
    return result;
  }

// تسجيل مستخدم عادي
 
 
 
 
  Future<Map<String, dynamic>> registerNormalUser({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String governorate,
  }) async {
    try {
      final result = await _authService.registerNormalUser(
        name: name,
        email: email,
        password: password,
        phone: phone,
        governorate: governorate,
      );
      if (result['status'] == true) {
        await _loadUserSession();
      }
      return result;
    } catch (e) {
      return {
        'status': false,
        'message': 'خطأ أثناء التسجيل: $e',
        'user': null
      };
    }
  }

  // تسجيل حساب مكتب عقارات
  // Future<Map<String, dynamic>> registerRealstateOffice({
  //   required String username,
  //   required String email,
  //   required String password,
  //   required String phone,
  //   required String city,
  //   required String address,
  //   required bool vat,
  //   required String officeLogoPath,
  //   required String ownerIdFrontPath,
  //   required String ownerIdBackPath,
  //   required String officeImagePath,
  //   required String commercialCardFrontPath,
  //   required String commercialCardBackPath,
  // }) async {
  //   try {
  //     final result = await _authService.registerRealstateOffice(
  //       username: username, email: email, password: password, phone: phone, city: city, address: address,
  //       vat: vat, officeLogoPath: officeLogoPath, ownerIdFrontPath: ownerIdFrontPath,
  //       ownerIdBackPath: ownerIdBackPath, officeImagePath: officeImagePath,
  //       commercialCardFrontPath: commercialCardFrontPath, commercialCardBackPath: commercialCardBackPath,
  //     );
  //     if (result['status'] == true) {
  //       await _loadUserSession();
  //     }
  //     return result;
  //   } catch (e) {
  //     return {'status': false, 'message': 'خطأ أثناء التسجيل: $e', 'user': null};
  //   }
  // }

  // // تسجيل وسيط عقاري فردي
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
      final result = await _authService.registerIndividualAgent(
        name: name,
        email: email,
        password: password,
        phone: phone,
        governorate: governorate,
        profileImage: profileImage,
        agentIdFrontImage: agentIdFrontImage,
        agentIdBackImage: agentIdBackImage,
        taxCardFrontImage: taxCardFrontImage,
        taxCardBackImage: taxCardBackImage,
      );
      return result;
    } catch (e) {
      return {'status': false, 'message': 'خطأ أثناء التسجيل: $e'};
    }
  }

  // تسجيل مكتب توصيل
  // إنشاء حساب مكتب عقار كامل بالخطوات المتتالية

  // --- هذه هي النسخة النهائية والمعدلة ---
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
      final result = await _authService.registerRealstateOffice(
        username: username,
        email: email,
        password: password,
        phone: phone,
        city: city,
        address: address,
        vat: vat,
        // تم تصحيح تمرير المتغيرات. الآن يتم تمريرها كما هي بدون .toString()
        officeLogoPath: officeLogoPath,
        ownerIdFrontPath: ownerIdFrontPath,
        ownerIdBackPath: ownerIdBackPath,
        officeImagePath: officeImagePath,
        commercialCardFrontPath: commercialCardFrontPath,
        commercialCardBackPath: commercialCardBackPath,
      );

      if (result['status'] == true) {
        // تم تصحيح success إلى status
        await _loadUserSession();
      }

      return result;
    } catch (e) {
      return {
        'status': false,
        'message': 'خطأ أثناء التسجيل: $e',
        'user': null
      };
    }
  }

  Future<Map<String, dynamic>> registerDeliveryOffice({
    required String fullName,
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
    required int maxKmPerDay,
  }) async {
    // ببساطة، يقوم بتمرير الطلب إلى الخدمة (الشيف)
    final result = await _authService.registerDeliveryOffice(
      fullName: fullName,
      email: email,
      governorate: governorate,
      password: password,
      phone: phone,
      officeName: officeName,
      logoImageUrl: logoImageUrl,
      commercialFrontImageUrl: commercialFrontImageUrl,
      commercialBackImageUrl: commercialBackImageUrl,
      paymentMethods: paymentMethods,
      rentalTypes: rentalTypes,
      costPerKm: costPerKm,
      driverCost: driverCost,
      maxKmPerDay: maxKmPerDay,
    );
    return result;
  }

  Future<Map<String, dynamic>> registerDeliveryPerson({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String governorate,
    required  String profileImageUrl,
    required List<String> paymentMethods,
    required List<String> rentalTypes,
    required double costPerKm,
    required double driverCost,
    required int maxKmPerDay,
  }) async {
    try {
      final result = await _authService.registerDeliveryPerson(
        fullName: fullName,
        email: email,
        password: password,
        phone: phone,
        governorate: governorate,
        profileImageUrl: profileImageUrl,
        paymentMethods: paymentMethods ,
        rentalTypes: rentalTypes,
        costPerKm: costPerKm,
        driverCost: driverCost,
        maxKmPerDay: maxKmPerDay,
      );
      return result;
    } catch (e) {
      return {'status': false, 'message': 'خطأ أثناء التسجيل: $e'};
    }
  }

Future<Map<String, dynamic>> registerRestaurant({
    required Map<String, dynamic> legalData,
    required Map<String, dynamic> accountInfo,
    required Map<String, dynamic> workHours,
  }) async {
    try {
      final result = await _authService.registerRestaurant(
        
        legalData: legalData,
        accountInfo: accountInfo,
        workHours: workHours,
      );
      return result;
    } catch (e) {
      return {'status': false, 'message': 'خطأ أثناء التسجيل: $e'};
    }
  }



// تسجيل الخروج
 
 
  Future<void> logout() async {
  try {
    // استدعاء الخدمة لمسح التوكن من السيرفر (خطوة اختيارية ولكنها جيدة)
    await _authService.logout(); 
  } catch (e) {
    // حتى لو فشل الطلب للسيرفر، يجب أن نكمل تسجيل الخروج محليًا
    debugPrint("Failed to logout from server, logging out locally. Error: $e");
  } finally {
    // --- هذا هو الجزء الأهم ---
    // 1. مسح كل بيانات المستخدم من حالة التطبيق
    _isLoggedIn = false;
    _userData = null;
    _token = null;
    _authStatus = AuthStatus.unauthenticated; // تحديث الحالة الجديدة

    // 2. إخبار الواجهة وكل المستمعين بهذا التغيير
    // بدون هذا السطر، لن يحدث أي شيء في الواجهة
    notifyListeners(); // <<<<<--- هذا هو السطر السحري
  }
}
}
