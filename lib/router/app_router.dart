import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saba2v2/models/car_model.dart';
import 'package:saba2v2/models/hotel_offer.dart';
import 'package:saba2v2/providers/auth_provider.dart';
import 'package:saba2v2/screens/auth/login_screen.dart';
import 'package:saba2v2/screens/auth/register_user_screen.dart';
import 'package:saba2v2/screens/auth/register_provider_screen.dart';
import 'package:saba2v2/screens/auth/otp_verification_screen.dart';
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
import 'package:saba2v2/screens/user/all_delivery_requests_screen.dart';
import 'package:saba2v2/screens/business/CarsScreens/delivery_registration_screen.dart';
import 'package:saba2v2/screens/business/cooking_registration_screen.dart';
import 'package:saba2v2/screens/business/RealStateScreens/realState.dart';
import 'package:saba2v2/screens/onboarding/onboarding_screen.dart';
import 'package:saba2v2/screens/business/RealStateScreens/AddNewStateScreen.dart';
import 'package:saba2v2/screens/business/RealStateScreens/RealStateHomeScreen.dart';
import 'package:saba2v2/screens/splash/splash_screen.dart';
import 'package:saba2v2/screens/auth/forgotPassword.dart';
import 'package:saba2v2/screens/user/SettingsUser.dart';
import 'package:saba2v2/screens/user/flight_search_screen.dart';
import 'package:saba2v2/screens/user/flight_results_screen.dart';
import 'package:saba2v2/screens/user/flight_details_screen.dart';
import 'package:saba2v2/screens/user/booking_screen.dart';
import 'package:saba2v2/screens/user/booking_confirmation_screen.dart';
import 'package:saba2v2/models/flight_offer.dart';
import 'package:saba2v2/screens/user/hotel_search_screen.dart';
import 'package:saba2v2/screens/user/hotel_results_screen.dart';
import 'package:saba2v2/screens/user/hotel_details_screen.dart';
import 'package:saba2v2/screens/user/hotel_booking_screen.dart';
import 'package:saba2v2/screens/user/restaurant-details.dart';
import 'package:saba2v2/screens/user/user_home_screen.dart';
import 'package:saba2v2/screens/user/user_restaurant_home.dart';
import 'package:saba2v2/screens/user/profile_screen.dart';
import 'package:saba2v2/screens/user/cart_screen.dart';
import 'package:saba2v2/screens/user/featured_properties_screen.dart';
import 'package:saba2v2/screens/user/featured_property_details_screen.dart';
import 'package:saba2v2/screens/user/search_screen.dart';
import 'package:saba2v2/screens/user/search_selection_screen.dart';
import 'package:saba2v2/screens/user/restaurant_search_screen.dart';
import 'package:saba2v2/screens/user/property_search_screen.dart';
import 'package:saba2v2/screens/business/CarsScreens/delivery_office_information.dart';
import 'package:saba2v2/screens/chat_screen.dart';
import 'package:saba2v2/screens/conversations_list_screen.dart';
import 'package:saba2v2/screens/user/all_properties_list_screen.dart';
import 'package:saba2v2/screens/user/security_permit_screen.dart';
import 'package:saba2v2/screens/user/filtered_restaurants_by_section_screen.dart';
import 'package:saba2v2/screens/user/car_service_selection_screen.dart';
import 'package:saba2v2/screens/user/delivery_request_screen.dart';
import 'package:saba2v2/screens/user/car_rental_request_screen.dart';
import 'package:saba2v2/screens/user/my_orders_screen.dart';
import 'package:saba2v2/screens/user/favorites_screen.dart';
import 'package:saba2v2/screens/driver/driver_requests_screen.dart';
import 'package:saba2v2/screens/driver/submit_offer_screen.dart';
import 'package:saba2v2/screens/driver/driver_home_screen.dart';
import 'package:saba2v2/screens/user/offers_screen.dart';
import 'package:saba2v2/models/offer_model.dart';
import 'package:saba2v2/models/delivery_request_model.dart';
// إضافة NavigationService لاستخدام navigatorKey الخاص به مع GoRouter
import 'package:saba2v2/screens/user/widgets/order_filter_widgets.dart';
import 'package:saba2v2/screens/pending_account_screen.dart';

class AppRouter {
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/SplashScreen',
      refreshListenable: authProvider,
      // ربط navigatorKey لضمان إمكانية الوصول إلى BuildContext عبر NavigationService
      navigatorKey: NavigationService.navigatorKey,
      redirect: (BuildContext context, GoRouterState state) {
        // التحقق من نوع المستخدم وتوجيهه للصفحة المناسبة
        if (authProvider.isAuthenticated) {
          final userType = authProvider.userType;
          
          // التحقق من حالة الموافقة على الحساب أولاً
          if (!authProvider.isApproved && state.uri.toString() != '/pending-account') {
            return '/pending-account';
          }
          
          // توجيه السائقين للصفحة المخصصة لهم
          if (userType == 'delivery_person' || userType == 'driver') {
            if (state.uri.toString() == '/SplashScreen' || state.uri.toString() == '/login') {
              return '/driver-home';
            }
          }
          // توجيه مالكي السيارات لصفحة التأجير
          else if (userType == 'car_rental_owner') {
            if (state.uri.toString() == '/SplashScreen' || state.uri.toString() == '/login') {
              return '/delivery-homescreen';
            }
          }
          // توجيه المستخدمين العاديين للصفحة الرئيسية
          else if (userType == 'user') {
            if (state.uri.toString() == '/SplashScreen' || state.uri.toString() == '/login') {
              return '/UserHomeScreen';
            }
          }
        }
        return null; // السماح بالوصول لجميع المسارات الأخرى
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
        GoRoute(
          path: '/otp-verification',
          name: 'otpVerification',
          builder: (context, state) {
            final extra = state.extra;
            String email = '';
            String? purpose;
            String? userName;
            if (extra is Map) {
              if (extra['email'] is String) email = extra['email'];
              if (extra['purpose'] is String) purpose = extra['purpose'];
              if (extra['userName'] is String) userName = extra['userName'];
            } else if (extra is String) {
              email = extra;
            }
            return OtpVerificationScreen(
              email: email,
              userName: userName,
              purpose: purpose ?? 'email_verification',
            );
          },
        ),
        // صفحة الحساب قيد المراجعة
        GoRoute(
          path: '/pending-account',
          name: 'pendingAccount',
          builder: (context, state) => const PendingAccountScreen(),
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
            return FeaturedPropertyDetailsScreen(propertyId: id);
          },
        ),
        // شاشات المطاعم (Restaurants)
        GoRoute(
          path: '/restaurants/menu-section/:section',
          name: 'filteredRestaurantsBySection',
          builder: (context, state) {
            final section = state.pathParameters['section'] ?? '';
            return FilteredRestaurantsBySectionScreen(section: section);
          },
        ),
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
          path: '/restaurant-details/:id',
          name: 'restaurantDetails',
          builder: (context, state) {
            final restaurantId = state.pathParameters['id']!;
            return RestaurantDetailsScreen(restaurantId: restaurantId);
          },
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
          path: '/user-restaurants',
          name: 'userRestaurants',
          builder: (context, state) => const UserRestaurantHome(),
        ),
        GoRoute(
          path: '/all-delivery-requests',
          name: 'allDeliveryRequests',
          builder: (context, state) => const AllDeliveryRequestsScreen(),
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
        GoRoute(
          path: '/cart',
          name: 'cart',
          builder: (context, state) => const CartScreen(),
        ),
        GoRoute(
          path: '/my-orders',
          name: 'myOrders',
          builder: (context, state) => const MyOrdersScreen(),
        ),
        GoRoute(
          path: '/favorites',
          name: 'favorites',
          builder: (context, state) => const FavoritesScreen(),
        ),
        GoRoute(
          path: '/featured-properties',
          name: 'featuredProperties',
          builder: (context, state) => const FeaturedPropertiesScreen(),
        ),
        GoRoute(
          path: '/search',
          name: 'search',
          builder: (context, state) => SearchScreen(),
        ),
        GoRoute(
          path: '/search-selection',
          name: 'searchSelection',
          builder: (context, state) => const SearchSelectionScreen(),
        ),
        GoRoute(
          path: '/restaurant-search',
          name: 'restaurantSearch',
          builder: (context, state) => const RestaurantSearchScreen(),
        ),
        GoRoute(
          path: '/property-search',
          name: 'propertySearch',
          builder: (context, state) => const PropertySearchScreen(),
        ),
        GoRoute(
          path: '/all-properties',
          name: 'allProperties',
          builder: (context, state) => const AllPropertiesListScreen(),
        ),
        GoRoute(
          path: '/security-permit',
          name: 'securityPermit',
          builder: (context, state) => const SecurityPermitScreen(),
        ),
        GoRoute(
          path: '/car-service-selection',
          name: 'carServiceSelection',
          builder: (context, state) => const CarServiceSelectionScreen(),
        ),
        GoRoute(
          path: '/delivery-request',
          name: 'deliveryRequest',
          builder: (context, state) => const DeliveryRequestScreen(),
        ),
        GoRoute(
          path: '/offers/:requestId',
          name: 'offers',
          builder: (context, state) {
            final requestId = state.pathParameters['requestId']!;
            final extra = state.extra as Map<String, dynamic>? ?? {};
            return OffersScreen(
              deliveryRequestId: int.parse(requestId),
              fromLocation: extra['fromLocation'] ?? '',
              toLocation: extra['toLocation'] ?? '',
              requestedPrice: extra['requestedPrice'] ?? 0.0,
              estimatedDurationMinutes: extra['estimatedDurationMinutes'] ?? 0,
            );
          },
        ),
        // شاشات السائق
        GoRoute(
          path: '/driver-home',
          name: 'driverHome',
          builder: (context, state) => const DriverHomeScreen(),
        ),
        GoRoute(
          path: '/driver-requests',
          name: 'driverRequests',
          builder: (context, state) => const DriverRequestsScreen(),
        ),
        GoRoute(
          path: '/submit-offer/:requestId',
          name: 'submitOffer',
          builder: (context, state) {
            final requestId = state.pathParameters['requestId']!;
            final deliveryRequest = state.extra as DeliveryRequestModel;
            return SubmitOfferScreen(
              deliveryRequest: deliveryRequest,
            );
          },
        ),
        GoRoute(
          path: '/car-rental',
          name: 'carRental',
          builder: (context, state) => const CarRentalRequestScreen(),
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
          builder: (context, state) {
            final extra = state.extra;
            String email = '';
            if (extra is Map && extra['email'] is String) {
              email = extra['email'];
            } else if (extra is String) {
              email = extra;
            }
            return ResetProfilePassword(email: email);
          },
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
        GoRoute(
          path: '/flight-search',
          name: 'flightSearch',
          builder: (context, state) => FlightSearchScreen(),
        ),
        GoRoute(
          path: '/flight-results',
          name: 'flightResults',
          builder: (context, state) => FlightResultsScreen(),
        ),
        GoRoute(
          path: '/flight-details',
          name: 'flightDetails',
          builder: (context, state) {
            final offer = state.extra as FlightOffer;
            return FlightDetailsScreen(offer: offer);
          },
        ),
        GoRoute(
          path: '/booking',
          name: 'booking',
          builder: (context, state) {
            final offer = state.extra as FlightOffer;
            return BookingScreen(offer: offer);
          },
        ),
        GoRoute(
          path: '/booking-confirmation',
          name: 'bookingConfirmation',
          builder: (context, state) {
            final bookingData = state.extra as Map<String, dynamic>;
            return BookingConfirmationScreen(bookingData: bookingData);
          },
        ),
        GoRoute(
          path: '/hotel-search',
          name: 'hotelSearch',
          builder: (context, state) => HotelSearchScreen(),
        ),
        GoRoute(
          path: '/hotel-results',
          name: 'hotelResults',
          builder: (context, state) => HotelResultsScreen(),
        ),
        GoRoute(
          path: '/hotel-details',
          name: 'hotelDetails',
          builder: (context, state) {
            final hotel = state.extra as HotelOffer;
            return HotelDetailsScreen(hotel: hotel);
          },
        ),
        GoRoute(
          path: '/hotel-booking',
          name: 'hotelBooking',
          builder: (context, state) {
            final hotel = state.extra as HotelOffer;
            return HotelBookingScreen(hotel: hotel);
          },
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