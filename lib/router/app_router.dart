import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saba2v2/models/car_model.dart';
import 'package:saba2v2/providers/auth_provider.dart';
import 'package:saba2v2/screens/auth/login_screen.dart';
import 'package:saba2v2/screens/auth/register_user_screen.dart';
import 'package:saba2v2/screens/auth/register_provider_screen.dart';
import 'package:saba2v2/screens/business/CarsScreens/CarDetailsScreen.dart';
import 'package:saba2v2/screens/business/CarsScreens/CarRentalAnalysisScreen.dart';
import 'package:saba2v2/screens/business/CarsScreens/CarRentalDataEdit.dart';
import 'package:saba2v2/screens/business/CarsScreens/CarRentalEditDocuments.dart';
import 'package:saba2v2/screens/business/CarsScreens/CarRentalEditProfile.dart';
import 'package:saba2v2/screens/business/CarsScreens/CarRentalHomeScreen.dart';
import 'package:saba2v2/screens/business/CarsScreens/CarRentalSettingsProvider.dart';
import 'package:saba2v2/screens/business/CarsScreens/OrderDetails.dart';
import 'package:saba2v2/screens/business/CarsScreens/add_car_rent.dart';
import 'package:saba2v2/screens/business/CarsScreens/car_rental_data_edit.dart';
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
import 'package:saba2v2/screens/restaurant_orders_screen.dart';
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
import 'package:saba2v2/screens/chat_screen.dart';
import 'package:saba2v2/screens/conversations_list_screen.dart';

class AppRouter {
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/SplashScreen',
      refreshListenable: authProvider,
      redirect: (BuildContext context, GoRouterState state) {
        // تعطيل التوجيه بناءً على حالة المصادقة للسماح بالوصول لجميع الصفحات
        return null; // السماح بالوصول لجميع المسارات دون قيود
      },
      routes: [
        // الشاشات العامة
        GoRoute(
          path: '/SplashScreen',
          name: 'SplashScreen',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          name: 'onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        // شاشات المصادقة
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/forgotPassword',
          name: 'forgotPassword',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: '/register-user',
          name: 'registerUser',
          builder: (context, state) => const RegisterUserScreen(),
        ),
        GoRoute(
          path: '/register-provider',
          name: 'registerProvider',
          builder: (context, state) => const RegisterProviderScreen(),
        ),
        // شاشات التسجيل كمزود خدمة
        GoRoute(
          path: '/cooking-registration',
          name: 'cookingRegistration',
          builder: (context, state) => const CookingRegistrationScreen(),
        ),
        GoRoute(
          path: '/delivery-registration',
          name: 'deliveryRegistration',
          builder: (context, state) => const DeliveryRegistrationScreen(),
        ),
        // شاشات العقارات (Real Estate)
        GoRoute(
          path: '/subscription-registration',
          name: 'subscriptionRegistration',
          builder: (context, state) => const Realstate(),
        ),
        GoRoute(
          path: '/SubscriptionRegistrationOfficeScreen',
          name: 'SubscriptionRegistrationOfficeScreen',
          builder: (context, state) => const SubscriptionRegistrationOfficeScreen(),
        ),
        GoRoute(
          path: '/SubscriptionRegistrationSingleScreen',
          name: 'SubscriptionRegistrationSingleScreen',
          builder: (context, state) => const SubscriptionRegistrationSingleScreen(),
        ),
        GoRoute(
          path: '/AddNewStateScreen',
          name: 'AddNewStateScreen',
          builder: (context, state) => const AddNewStateScreen(),
        ),
        GoRoute(
          path: '/RealStateHomeScreen',
          name: 'RealStateHomeScreen',
          builder: (context, state) => const RealStateHomeScreen(),
        ),
        GoRoute(
          path: '/RealStateAnalysisScreen',
          name: 'RealStateAnalysisScreen',
          builder: (context, state) => const RealStateAnalysisScreen(),
        ),
        GoRoute(
          path: '/RealStateSettingsProvider',
          name: 'RealStateSettingsProvider',
          builder: (context, state) => const RealStateSettingsProvider(),
        ),
        GoRoute(
          path: '/RealStateEditProfile',
          name: 'RealStateEditProfile',
          builder: (context, state) => const RealStateEditProfile(),
        ),
        GoRoute(
          path: '/RealStateEditDocuments',
          name: 'RealStateEditDocuments',
          builder: (context, state) => const RealStateEditDocuments(),
        ),
        GoRoute(
          path: '/RealStateDataEdit',
          name: 'RealStateDataEdit',
          builder: (context, state) => const RealStateDataEdit(),
        ),
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
        // شاشات المطاعم (Restaurants)
        GoRoute(
          path: '/ResturantLawData',
          name: 'ResturantLawData',
          builder: (context, state) => const ResturantLawData(),
        ),
        GoRoute(
          path: '/ResturantInformation',
          name: 'ResturantInformation',
          builder: (context, state) => ResturantInformation(
            legalData: state.extra as RestaurantLegalData,
          ),
        ),
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
        GoRoute(
          path: '/restaurant-home',
          name: 'restaurantHome',
          builder: (context, state) => const ResturantHomeScreen(),
        ),
        GoRoute(
          path: '/restaurant-orders',
          name: 'restaurantOrders',
          builder: (context, state) => const RestaurantOrdersScreen(),
        ),
        GoRoute(
          path: '/Menu',
          name: 'Menu',
          builder: (context, state) => const RestaurantMenuScreen(),
        ),
        GoRoute(
          path: '/RestaurantAnalysisScreen',
          name: 'RestaurantAnalysisScreen',
          builder: (context, state) => const RestaurantAnalysisScreen(),
        ),
        GoRoute(
          path: '/SettingsProvider',
          name: 'SettingsProvider',
          builder: (context, state) => const SettingsProvider(),
        ),
        GoRoute(
          path: '/RestaurantEditProfile',
          name: 'RestaurantEditProfile',
          builder: (context, state) => const RestaurantEditProfile(),
        ),
        GoRoute(
          path: '/Resteditdocuments',
          name: 'Resteditdocuments',
          builder: (context, state) => const Resteditdocuments(),
        ),
        GoRoute(
          path: '/ResDataEdit',
          name: 'ResDataEdit',
          builder: (context, state) => const ResDataEdit(),
        ),
        GoRoute(
          path: '/ResTimeWorkEdit',
          name: 'ResTimeWorkEdit',
          builder: (context, state) => const ResTimeWorkEdit(),
        ),
        // شاشات التوصيل (Delivery)
        GoRoute(
          path: '/delivery-office-information',
          name: 'deliveryOfficeInformation',
          builder: (context, state) => const DeliveryOfficeInformation(),
        ),
        GoRoute(
          path: '/delivery-homescreen',
          name: 'deliveryHomescreen',
          builder: (context, state) => const CarRentalHomeScreen(),
        ),
        GoRoute(
          path: '/DeliveryPersonInformationScreen',
          name: 'DeliveryPersonInformationScreen',
          builder: (context, state) => const DeliveryPersonInformationScreen(),
        ),
        GoRoute(
          path: '/OrderDetails',
          name: 'OrderDetails',
          builder: (context, state) => const OrderDetails(),
        ),
        GoRoute(
          path: '/CarRentalAnalysisScreen',
          name: 'CarRentalAnalysisScreen',
          builder: (context, state) => const CarRentalAnalysisScreen(),
        ),
        GoRoute(
          path: '/CarRentalSettingsProvider',
          name: 'CarRentalSettingsProvider',
          builder: (context, state) => const CarRentalSettingsProvider(),
        ),
        GoRoute(
          path: '/CarRentalEditProfile',
          name: 'CarRentalEditProfile',
          builder: (context, state) => const CarRentalEditProfile(),
        ),
        GoRoute(
          path: '/CarRentalEditDocuments',
          name: 'CarRentalEditDocuments',
          builder: (context, state) => const CarRentalEditDocuments(),
        ),
        GoRoute(
          path: '/CarRentalDataEdit',
          name: 'CarRentalDataEdit',
          builder: (context, state) => const CarRentalDataEdit(),
        ),
        GoRoute(
          path: '/AddCarRental',
          name: 'AddCarRental',
          builder: (context, state) => const AddCarRental(),
        ),
        GoRoute(
          path: '/car-details',
          name: 'CarDetailsScreen',
          builder: (context, state) {
            final car = state.extra as Car;
            return CarDetailsScreen(car: car);
          },
        ),
        GoRoute(
          path: '/CarDataEdit',
          name: 'CarDataEdit',
          builder: (context, state) {
            final car = state.extra as Car;
            return CarDataEdit(car: car);
          },
        ),
        // شاشات المستخدمين
        GoRoute(
          path: '/UserHomeScreen',
          name: 'UserHomeScreen',
          builder: (context, state) => const UserHomeScreen(),
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/SettingsUser',
          name: 'SettingsUser',
          builder: (context, state) => const SettingsUser(),
        ),
        // شاشات إضافية
        GoRoute(
          path: '/conversations',
          name: 'conversations',
          builder: (context, state) => const ConversationsListScreen(),
        ),
        GoRoute(
          path: '/chat',
          name: 'chat',
          builder: (context, state) => const ChatScreen(),
        ),
        GoRoute(
          path: '/NotificationsScreen',
          name: 'NotificationsScreen',
          builder: (context, state) => const NotificationsScreen(),
        ),
        GoRoute(
          path: '/AccountReviewing',
          name: 'AccountReviewing',
          builder: (context, state) => const AccountReviewing(),
        ),
        GoRoute(
          path: '/ChangeProfilePass',
          name: 'ChangeProfilePass',
          builder: (context, state) => const ChangeProfilePass(),
        ),
        GoRoute(
          path: '/ForgotProfilePassword',
          name: 'ForgotProfilePassword',
          builder: (context, state) => const ForgotProfilePassword(),
        ),
        GoRoute(
          path: '/ResetProfilePassword',
          name: 'ResetProfilePassword',
          builder: (context, state) => const ResetProfilePassword(),
        ),
        GoRoute(
          path: '/AboutApp',
          name: 'AboutApp',
          builder: (context, state) => const AboutApp(),
        ),
        GoRoute(
          path: '/FAQScreen',
          name: 'FAQScreen',
          builder: (context, state) => const FAQScreen(),
        ),
        GoRoute(
          path: '/TermsScreen',
          name: 'TermsScreen',
          builder: (context, state) => const TermsScreen(),
        ),
        GoRoute(
          path: '/ContactUsScreen',
          name: 'ContactUsScreen',
          builder: (context, state) => const ContactUsScreen(),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Text('خطأ: ${state.error}'),
        ),
      ),
    );
  }
}