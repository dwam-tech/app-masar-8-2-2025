import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saba2v2/providers/auth_provider.dart';
import 'package:saba2v2/screens/auth/login_screen.dart';
import 'package:saba2v2/screens/auth/register_user_screen.dart';
import 'package:saba2v2/screens/auth/register_provider_screen.dart';
import 'package:saba2v2/screens/business/CarsScreens/CarRentalAnalysisScreen.dart';
import 'package:saba2v2/screens/business/CarsScreens/CarRentalDataEdit.dart';
import 'package:saba2v2/screens/business/CarsScreens/CarRentalEditDocuments.dart';
import 'package:saba2v2/screens/business/CarsScreens/CarRentalEditProfile.dart';
import 'package:saba2v2/screens/business/CarsScreens/CarRentalHomeScreen.dart';
import 'package:saba2v2/screens/business/CarsScreens/CarRentalSettingsProvider.dart';
import 'package:saba2v2/screens/business/CarsScreens/OrderDetails.dart';
import 'package:saba2v2/screens/business/CarsScreens/delivery_person_inforamtion.dart';
import 'package:saba2v2/screens/business/CarsScreens/driver_car_info.dart';
import 'package:saba2v2/screens/business/Public/ChangeProfilePass.dart';
import 'package:saba2v2/screens/business/Public/ContactUsScreen.dart';
import 'package:saba2v2/screens/business/Public/FAQScreen.dart';
import 'package:saba2v2/screens/business/Public/ForgotProfilePassword.dart';
import 'package:saba2v2/screens/business/Public/ResetProfilePassword.dart';
import 'package:saba2v2/screens/business/Public/Settings_Provider.dart';
import 'package:saba2v2/screens/business/Public/TermsScreen.dart';
import 'package:saba2v2/screens/business/Public/about-app.dart';
import 'package:saba2v2/screens/business/RealStateScreens/AccountReviewing.dart';
import 'package:saba2v2/screens/business/Public/Notifcations.dart';
import 'package:saba2v2/screens/business/RealStateScreens/RealStateAnalysisScreen.dart';
import 'package:saba2v2/screens/business/RealStateScreens/RealStateDataEdit.dart';
import 'package:saba2v2/screens/business/RealStateScreens/RealStateEditDocuments.dart';
import 'package:saba2v2/screens/business/RealStateScreens/RealStateEditProfile.dart';
import 'package:saba2v2/screens/business/RealStateScreens/RealStateSettingsProvider.dart';
import 'package:saba2v2/screens/business/RealStateScreens/property_details_screen.dart';
import 'package:saba2v2/screens/business/ResturantScreens/Analysis.dart';
import 'package:saba2v2/screens/business/ResturantScreens/Menu.dart';
import 'package:saba2v2/screens/business/ResturantScreens/ResDataEdit.dart';
import 'package:saba2v2/screens/business/ResturantScreens/ResTimeWorkEdit.dart';
import 'package:saba2v2/screens/business/ResturantScreens/RestEditDocuments.dart';
import 'package:saba2v2/screens/business/ResturantScreens/ResturantEditProfile.dart';
import 'package:saba2v2/screens/business/ResturantScreens/ResturantHomeScreen.dart';
import 'package:saba2v2/screens/business/ResturantScreens/ResturantInformation.dart';
import 'package:saba2v2/screens/business/ResturantScreens/ResturantLawData.dart';
import 'package:saba2v2/screens/business/ResturantScreens/ResturantWorkeTime.dart';
import 'package:saba2v2/screens/business/RealStateScreens/SubscriptionRegistrationOfficeScreen.dart';
import 'package:saba2v2/screens/business/RealStateScreens/SubscriptionRegistrationSingleScreen.dart';
import 'package:saba2v2/screens/business/CarsScreens/delivery_registration_screen.dart';
import 'package:saba2v2/screens/business/cooking_registration_screen.dart';
import 'package:saba2v2/screens/business/RealStateScreens/realState.dart';
import 'package:saba2v2/screens/onboarding/onboarding_screen.dart';
import 'package:saba2v2/screens/business/RealStateScreens/AddNewStateScreen.dart';
import 'package:saba2v2/screens/business/RealStateScreens/RealStateHomeScreen.dart';
import 'package:saba2v2/screens/splash/splash_screen.dart';
import 'package:saba2v2/screens/auth/forgotPassword.dart';
import 'package:saba2v2/screens/user/SettingsUser.dart';
import 'package:saba2v2/screens/user/restaurant-details.dart';
import 'package:saba2v2/screens/user/user_home_screen.dart';
import 'package:saba2v2/screens/user/profile_screen.dart';
import 'package:saba2v2/screens/business/CarsScreens/delivery_office_information.dart';

// مسار الملف: lib/router/app_router.dart
// هذا الملف يحتوي على إعدادات التوجيه باستخدام go_router لإدارة الشاشات

class AppRouter {
  // إنشاء وإعداد GoRouter مع توفير AuthProvider للتحكم في حالة المصادقة
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      // تحديد المسار الأولي عند بدء التطبيق
      initialLocation: '/SplashScreen',
      
      // الاستماع لتغييرات حالة المصادقة من AuthProvider
      refreshListenable: authProvider,

      // منطق إعادة التوجيه بناءً على حالة المصادقة
      redirect: (BuildContext context, GoRouterState state) {
        final authStatus = authProvider.authStatus;
        final currentLocation = state.uri.toString();

        // التحقق إذا كان التطبيق في حالة التهيئة
        if (authStatus == AuthStatus.uninitialized ) {
          return '/SplashScreen';
        }

        // إذا لم يكن المستخدم مسجل دخوله
        if (authStatus == AuthStatus.unauthenticated) {
          
          
          
          // السماح بالوصول إلى شاشات المصادقة والتسجيل
          if (currentLocation == '/login' ||
              currentLocation == '/register-user' ||
              currentLocation == '/register-provider' ||
              currentLocation == '/forgotPassword' ||
              currentLocation.startsWith('/subscription') ||
              currentLocation.startsWith('/delivery') ||
              currentLocation.startsWith('/cooking-registration')) {
            return null; // عدم إعادة التوجيه
          }
          // إعادة التوجيه إلى شاشة تسجيل الدخول
          return '/login';
        }

        // إذا كان المستخدم مسجل دخوله
        if (authStatus == AuthStatus.authenticated) {
          // إعادة التوجيه إلى الشاشة الرئيسية بناءً على نوع المستخدم
          if (currentLocation == '/SplashScreen' || currentLocation == '/login') {
            final userType = authProvider.userData?['user_type'];
            switch (userType) {
              case 'normal':
                return '/UserHomeScreen';
              case 'real_estate_office':
              case 'real_estate_individual':
                return '/RealStateHomeScreen';
              case 'restaurant':
                return '/restaurant-home';
              case 'car_rental_office':
              case 'driver':
                return '/delivery-homescreen';
              default:
                return '/UserHomeScreen'; // الافتراضي للمستخدم العادي
            }
          }
        }
        
        // السماح بالاستمرار إلى المسار المطلوب إذا لم ينطبق أي شرط
        return null;
      },

      // قائمة المسارات المتاحة في التطبيق
      routes: [
        // **********************************************************************
        // *                          الشاشات العامة                            *
        // **********************************************************************
        // شاشة البداية (Splash Screen)
        GoRoute(
          path: '/SplashScreen',
          name: 'SplashScreen',
          builder: (context, state) => const SplashScreen(),
        ),
        // شاشة التعريف بالتطبيق (Onboarding)
        GoRoute(
          path: '/onboarding',
          name: 'onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),

        // **********************************************************************
        // *                         شاشات المصادقة                            *
        // **********************************************************************
        // شاشة تسجيل الدخول
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        // شاشة نسيان كلمة المرور
        GoRoute(
          path: '/forgotPassword',
          name: 'forgotPassword',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        // شاشة تسجيل مستخدم جديد
        GoRoute(
          path: '/register-user',
          name: 'registerUser',
          builder: (context, state) => const RegisterUserScreen(),
        ),
        // شاشة تسجيل مزود خدمة
        GoRoute(
          path: '/register-provider',
          name: 'registerProvider',
          builder: (context, state) => const RegisterProviderScreen(),
        ),

        // **********************************************************************
        // *                     شاشات التسجيل كمزود خدمة                      *
        // **********************************************************************
        // شاشة تسجيل خدمات الطهي
        GoRoute(
          path: '/cooking-registration',
          name: 'cookingRegistration',
          builder: (context, state) => const CookingRegistrationScreen(),
        ),
        // شاشة تسجيل خدمات التوصيل
        GoRoute(
          path: '/delivery-registration',
          name: 'deliveryRegistration',
          builder: (context, state) => const DeliveryRegistrationScreen(),
        ),

        // **********************************************************************
        // *                     شاشات العقارات (Real Estate)                   *
        // **********************************************************************
        // شاشة تسجيل الاشتراك في العقارات
        GoRoute(
          path: '/subscription-registration',
          name: 'subscriptionRegistration',
          builder: (context, state) => const Realstate(),
        ),
        // شاشة تسجيل مكتب عقاري
        GoRoute(
          path: '/SubscriptionRegistrationOfficeScreen',
          name: 'SubscriptionRegistrationOfficeScreen',
          builder: (context, state) => const SubscriptionRegistrationOfficeScreen(),
        ),
        // شاشة تسجيل فرد عقاري
        GoRoute(
          path: '/SubscriptionRegistrationSingleScreen',
          name: 'SubscriptionRegistrationSingleScreen',
          builder: (context, state) => const SubscriptionRegistrationSingleScreen(),
        ),
        // شاشة إضافة عقار جديد
        GoRoute(
          path: '/AddNewStateScreen',
          name: 'AddNewStateScreen',
          builder: (context, state) => const AddNewStateScreen(),
        ),
        // الشاشة الرئيسية للعقارات
        GoRoute(
          path: '/RealStateHomeScreen',
          name: 'RealStateHomeScreen',
          builder: (context, state) => const RealStateHomeScreen(),
        ),
        // شاشة تحليلات العقارات
        GoRoute(
          path: '/RealStateAnalysisScreen',
          name: 'RealStateAnalysisScreen',
          builder: (context, state) => const RealStateAnalysisScreen(),
        ),
        // شاشة إعدادات مزود العقارات
        GoRoute(
          path: '/RealStateSettingsProvider',
          name: 'RealStateSettingsProvider',
          builder: (context, state) => const RealStateSettingsProvider(),
        ),
        // شاشة تعديل ملف العقارات
        GoRoute(
          path: '/RealStateEditProfile',
          name: 'RealStateEditProfile',
          builder: (context, state) => const RealStateEditProfile(),
        ),
        // شاشة تعديل وثائق العقارات
        GoRoute(
          path: '/RealStateEditDocuments',
          name: 'RealStateEditDocuments',
          builder: (context, state) => const RealStateEditDocuments(),
        ),
        // شاشة تعديل بيانات العقارات
        GoRoute(
          path: '/RealStateDataEdit',
          name: 'RealStateDataEdit',
          builder: (context, state) => const RealStateDataEdit(),
        ),
        // شاشة تفاصيل العقار
        GoRoute(
          path: '/propertyDetails/:id',
          name: 'propertyDetails',
          builder: (context, state) {
            final id = state.pathParameters['id'];
            if (id == null) {
              return const Scaffold(
                body: Center(child: Text('خطأ: معرف العقار غير موجود')),
              );
            }
            return PropertyDetailsScreen(propertyId: id);
          },
        ),

        // **********************************************************************
        // *                     شاشات المطاعم (Restaurants)                    *
        // **********************************************************************
        // شاشة بيانات قانونية للمطعم
        GoRoute(
          path: '/ResturantLawData',
          name: 'ResturantLawData',
          builder: (context, state) => const ResturantLawData(),
        ),
        // شاشة معلومات المطعم
        GoRoute(
          path: '/ResturantInformation',
          name: 'ResturantInformation',
          builder: (context, state) => ResturantInformation(
            legalData: state.extra as RestaurantLegalData,
          ),
        ),
        // شاشة أوقات عمل المطعم
        GoRoute(
          path: '/ResturantWorkTime',
          name: 'ResturantWorkTime',
          builder: (context, state) {
            final data = state.extra as Map<String, dynamic>;
            return ResturantWorkTime(
              legalData: data['legal_data'] as RestaurantLegalData,
              accountInfo: data['account_info'] as RestaurantAccountInfo,
            );
          },
        ),
        // الشاشة الرئيسية للمطعم
        GoRoute(
          path: '/restaurant-home',
          name: 'restaurantHome',
          builder: (context, state) => const ResturantHomeScreen(),
        ),
        // شاشة قائمة الطعام
        GoRoute(
          path: '/Menu',
          name: 'Menu',
          builder: (context, state) => const RestaurantMenuScreen(),
        ),
        // شاشة تحليلات المطعم
        GoRoute(
          path: '/RestaurantAnalysisScreen',
          name: 'RestaurantAnalysisScreen',
          builder: (context, state) => const RestaurantAnalysisScreen(),
        ),
        // شاشة إعدادات مزود المطعم
        GoRoute(
          path: '/SettingsProvider',
          name: 'SettingsProvider',
          builder: (context, state) => const SettingsProvider(),
        ),
        // شاشة تعديل ملف المطعم
        GoRoute(
          path: '/RestaurantEditProfile',
          name: 'RestaurantEditProfile',
          builder: (context, state) => const RestaurantEditProfile(),
        ),
        // شاشة تعديل وثائق المطعم
        GoRoute(
          path: '/Resteditdocuments',
          name: 'Resteditdocuments',
          builder: (context, state) => const Resteditdocuments(),
        ),
        // شاشة تعديل بيانات المطعم
        GoRoute(
          path: '/ResDataEdit',
          name: 'ResDataEdit',
          builder: (context, state) => const ResDataEdit(),
        ),
        // شاشة تعديل أوقات عمل المطعم
        GoRoute(
          path: '/ResTimeWorkEdit',
          name: 'ResTimeWorkEdit',
          builder: (context, state) => const ResTimeWorkEdit(),
        ),

        // **********************************************************************
        // *                     شاشات التوصيل (Delivery)                       *
        // **********************************************************************
        // شاشة معلومات مكتب التوصيل
        GoRoute(
          path: '/delivery-office-information',
          name: 'deliveryOfficeInformation',
          builder: (context, state) => const DeliveryOfficeInformation(),
        ),
        // الشاشة الرئيسية للتوصيل
        GoRoute(
          path: '/delivery-homescreen',
          name: 'deliveryHomescreen',
          builder: (context, state) => const CarRentalHomeScreen(),
        ),
        // شاشة معلومات شخص التوصيل
        GoRoute(
          path: '/DeliveryPersonInformationScreen',
          name: 'DeliveryPersonInformationScreen',
          builder: (context, state) => const DeliveryPersonInformationScreen(),
        ),
        // شاشة معلومات سيارة السائق
        // GoRoute(
        //   path: '/DriverCarInfo',
        //   name: 'DriverCarInfo',
        //   builder: (BuildContext context, GoRouterState state) {
        //     final personData = state.extra as Map<String, dynamic>;
        //     return DriverCarInfo(personData: personData);
        //   },
        // ),
        // شاشة تفاصيل الطلب
        GoRoute(
          path: '/OrderDetails',
          name: 'OrderDetails',
          builder: (context, state) => const OrderDetails(),
        ),
        // شاشة تحليلات التوصيل
        GoRoute(
          path: '/CarRentalAnalysisScreen',
          name: 'CarRentalAnalysisScreen',
          builder: (context, state) => const CarRentalAnalysisScreen(),
        ),
        // شاشة إعدادات مزود التوصيل
        GoRoute(
          path: '/CarRentalSettingsProvider',
          name: 'CarRentalSettingsProvider',
          builder: (context, state) => const CarRentalSettingsProvider(),
        ),
        // شاشة تعديل ملف التوصيل
        GoRoute(
          path: '/CarRentalEditProfile',
          name: 'CarRentalEditProfile',
          builder: (context, state) => const CarRentalEditProfile(),
        ),
        // شاشة تعديل وثائق التوصيل
        GoRoute(
          path: '/CarRentalEditDocuments',
          name: 'CarRentalEditDocuments',
          builder: (context, state) => const CarRentalEditDocuments(),
        ),
        // شاشة تعديل بيانات التوصيل
        GoRoute(
          path: '/CarRentalDataEdit',
          name: 'CarRentalDataEdit',
          builder: (context, state) => const CarRentalDataEdit(),
        ),

        // **********************************************************************
        // *                        شاشات المستخدمين                           *
        // **********************************************************************
        // الشاشة الرئيسية للمستخدم
        GoRoute(
          path: '/UserHomeScreen',
          name: 'UserHomeScreen',
          builder: (context, state) => const UserHomeScreen(),
        ),
        // شاشة الملف الشخصي
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        // شاشة إعدادات المستخدم
        GoRoute(
          path: '/SettingsUser',
          name: 'SettingsUser',
          builder: (context, state) => const SettingsUser(),
        ),
        // شاشة تفاصيل المطعم
        GoRoute(
          path: '/restaurant-details/:id',
          name: 'restaurantDetails',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return RestaurantDetailsScreen(restaurantId: id);
          },
        ),

        // **********************************************************************
        // *                        شاشات إضافية                                *
        // **********************************************************************
        // شاشة الإشعارات
        GoRoute(
          path: '/NotificationsScreen',
          name: 'NotificationsScreen',
          builder: (context, state) => const NotificationsScreen(),
        ),
        // شاشة مراجعة الحساب
        GoRoute(
          path: '/AccountReviewing',
          name: 'AccountReviewing',
          builder: (context, state) => const AccountReviewing(),
        ),
        // شاشة تغيير كلمة المرور
        GoRoute(
          path: '/ChangeProfilePass',
          name: 'ChangeProfilePass',
          builder: (context, state) => const ChangeProfilePass(),
        ),
        // شاشة نسيان كلمة المرور (إعدادات)
        GoRoute(
          path: '/ForgotProfilePassword',
          name: 'ForgotProfilePassword',
          builder: (context, state) => const ForgotProfilePassword(),
        ),
        // شاشة إعادة تعيين كلمة المرور
        GoRoute(
          path: '/ResetProfilePassword',
          name: 'ResetProfilePassword',
          builder: (context, state) => const ResetProfilePassword(),
        ),
        // شاشة حول التطبيق
        GoRoute(
          path: '/AboutApp',
          name: 'AboutApp',
          builder: (context, state) => const AboutApp(),
        ),
        // شاشة الأسئلة الشائعة
        GoRoute(
          path: '/FAQScreen',
          name: 'FAQScreen',
          builder: (context, state) => const FAQScreen(),
        ),
        // شاشة الشروط والأحكام
        GoRoute(
          path: '/TermsScreen',
          name: 'TermsScreen',
          builder: (context, state) => const TermsScreen(),
        ),
        // شاشة التواصل معنا
        GoRoute(
          path: '/ContactUsScreen',
          name: 'ContactUsScreen',
          builder: (context, state) => const ContactUsScreen(),
        ),
      ],

      // معالجة الأخطاء عند فشل التوجيه
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Text('خطأ: ${state.error}'),
        ),
      ),
    );
  }
}