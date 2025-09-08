// مسار الملف: lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

// مزوّداتك كما هي
import 'package:saba2v2/providers/menu_management_provider.dart';
import 'package:saba2v2/providers/order_provider.dart';
import 'package:saba2v2/providers/restaurant_order_provider.dart';
import 'package:saba2v2/router/app_router.dart';
import 'package:saba2v2/providers/service_category_provider.dart';
import 'package:saba2v2/providers/restaurant_provider.dart';
import 'package:saba2v2/providers/real_estate_provider.dart';
import 'package:saba2v2/providers/auth_provider.dart';
import 'package:saba2v2/providers/conversation_provider.dart';
import 'package:saba2v2/providers/conversations_provider.dart';
import 'package:saba2v2/providers/restaurant_profile_provider.dart';
import 'package:saba2v2/providers/cart_provider.dart';
import 'package:saba2v2/providers/featured_properties_provider.dart';
import 'package:saba2v2/providers/public_properties_provider.dart';
import 'package:saba2v2/providers/banner_provider.dart';
import 'package:saba2v2/providers/flight_search_provider.dart';
import 'package:saba2v2/providers/hotel_search_provider.dart';
import 'package:saba2v2/providers/notification_provider.dart';
import 'package:go_router/go_router.dart';

// إضافة NavigationService للوصول إلى السياق خارجツツツ
import 'package:saba2v2/screens/user/widgets/order_filter_widgets.dart';

// === BEGIN: FCM Setup ===
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// FCM: إشعارات محلية لعرض التنبيه في الـ Foreground
final FlutterLocalNotificationsPlugin _flnp = FlutterLocalNotificationsPlugin();

// FCM: هاندلر رسائل الخلفية (يجب أن يكون top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // FCM: Background message received
  print('[FCM] onBackgroundMessage: ${message.messageId} | ${message.data}');
}

// FCM: إعداد Local Notifications وإنشاء قناة الإشعارات
Future<void> _setupLocalNotifications() async {
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidInit);
  await _flnp.initialize(initSettings);

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'default', // FCM: مهم - يطابق meta-data والسيرفر
    'General',
    description: 'General notifications',
    importance: Importance.high,
  );

  await _flnp
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

// === FCM Token Registration Functions ===
// FCM: تسجيل Device Token مع الباك-إند
Future<void> registerDeviceToken(String bearerToken) async {
  final token = await FirebaseMessaging.instance.getToken();
  print('[FCM] Current token: $token');
  if (token == null) return;

  final res = await http.post(
    Uri.parse('https://msar.app/api/device-tokens'),
    headers: {
      'Authorization': 'Bearer $bearerToken',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({'token': token, 'platform': 'android'}),
  );
  print('[FCM] Register token response: ${res.statusCode} - ${res.body}');
}

// FCM: ربط تجديد Token مع الباك-إند
void hookTokenRefresh(String bearerToken) {
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    print('[FCM] onTokenRefresh: $newToken');
    final res = await http.post(
      Uri.parse('https://msar.app/api/device-tokens'),
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'token': newToken, 'platform': 'android'}),
    );
    print('[FCM] Refresh register response: ${res.statusCode} - ${res.body}');
  });
}

// FCM: حذف Device Token من الباك-إند
Future<void> deleteDeviceToken(String bearerToken, {String? token}) async {
  final res = await http.delete(
    Uri.parse('https://msar.app/api/device-tokens'),
    headers: {
      'Authorization': 'Bearer $bearerToken',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
    body: token != null ? jsonEncode({'token': token}) : null,
  );
  print('[FCM] Delete token response: ${res.statusCode} - ${res.body}');
}
// === END: FCM Setup ===

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar', null);

  // مهيئ الاعتماد كما هو
  final authProvider = AuthProvider();
  await authProvider.initialize();

  // FCM: تهيئة Firebase
  await Firebase.initializeApp();
  
  // FCM: تسجيل هاندلر الخلفية قبل runApp
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // FCM: تهيئة Local Notifications وإعداد Listeners
  await _setupLocalNotifications();
  
  // FCM: طلب صلاحيات الإشعار
  final settings = await FirebaseMessaging.instance.requestPermission();
  print('[FCM] Permission status: ${settings.authorizationStatus}');
  
  // FCM: الحصول على Device Token
  final token = await FirebaseMessaging.instance.getToken();
  print('[FCM] Current token: $token');
  
  // FCM: استقبال إشعار والتطبيق مفتوح (Foreground)
  FirebaseMessaging.onMessage.listen((RemoteMessage m) async {
    print('[FCM] onMessage: ${m.messageId} | ${m.notification?.title}');

    // قمع الإشعار فقط إذا كان المستخدم فعليًا على شاشة المحادثة
    bool suppress = false;
    final ctx = NavigationService.navigatorKey.currentContext;
    if (ctx != null) {
      bool inChatRoute = false;
      bool inChatProvider = false;
      try {
        final location = GoRouterState.of(ctx).uri.path;
        inChatRoute = location.startsWith('/chat');
        print('[FCM] Current route: $location | inChatRoute=$inChatRoute');
      } catch (_) {}
      try {
        final convProv = Provider.of<ConversationProvider>(ctx, listen: false);
        inChatProvider = convProv.isInChatScreen;
        if (inChatProvider) {
          // تحديث سريع للمحادثة دون انتظار
          // ignore: unawaited_futures
          convProv.refreshConversation();
        }
      } catch (_) {}
      suppress = inChatRoute || inChatProvider;
    }

    if (suppress) {
      print('[FCM] Suppressed foreground notification (user in chat screen)');
      return;
    }

    final n = m.notification;
    final title = n?.title ?? (m.data['title'] as String?) ?? 'إشعار جديد';
    final body = n?.body ?? (m.data['body'] as String?) ?? 'لديك إشعار جديد';
    await _flnp.show(
      m.hashCode,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'default', 'General',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: m.data['link'],
    );
  });

  // FCM: عند فتح التطبيق بالضغط على الإشعار
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('[FCM] onMessageOpenedApp: data=${message.data}');
    // TODO: توجيه المستخدم بناءً على message.data
  });

  // باقي تهيئة الـ Providers و runApp كما هي بالضبط
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => ServiceCategoryProvider()),
        ChangeNotifierProvider(create: (_) => RestaurantProvider()),
        ChangeNotifierProvider(create: (_) => RealEstateProvider()),
        ChangeNotifierProvider(create: (ctx) => MenuManagementProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => RestaurantOrderProvider()),
        ChangeNotifierProvider(create: (_) => ConversationProvider()),
        ChangeNotifierProvider(create: (_) => ConversationsProvider()),
        ChangeNotifierProvider(create: (_) => RestaurantProfileProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FeaturedPropertiesProvider()),
        ChangeNotifierProvider(create: (_) => PublicPropertiesProvider()),
        ChangeNotifierProvider(create: (_) => BannerProvider()),
        ChangeNotifierProvider(create: (_) => FlightSearchProvider()),
        ChangeNotifierProvider(create: (_) => HotelSearchProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp.router(
        title: 'تطبيق مسار',
        theme: ThemeData(
          primarySwatch: Colors.orange,
          fontFamily: 'Cairo',
          scaffoldBackgroundColor: Colors.white,
          textTheme: const TextTheme(
            displayLarge: TextStyle(fontFamily: 'Cairo'),
            displayMedium: TextStyle(fontFamily: 'Cairo'),
            displaySmall: TextStyle(fontFamily: 'Cairo'),
            headlineLarge: TextStyle(fontFamily: 'Cairo'),
            headlineMedium: TextStyle(fontFamily: 'Cairo'),
            headlineSmall: TextStyle(fontFamily: 'Cairo'),
            titleLarge: TextStyle(fontFamily: 'Cairo'),
            titleMedium: TextStyle(fontFamily: 'Cairo'),
            titleSmall: TextStyle(fontFamily: 'Cairo'),
            bodyLarge: TextStyle(fontFamily: 'Cairo'),
            bodyMedium: TextStyle(fontFamily: 'Cairo'),
            bodySmall: TextStyle(fontFamily: 'Cairo'),
            labelLarge: TextStyle(fontFamily: 'Cairo'),
            labelMedium: TextStyle(fontFamily: 'Cairo'),
            labelSmall: TextStyle(fontFamily: 'Cairo'),
          ),
        ),
        routerConfig: AppRouter.createRouter(authProvider),
        debugShowCheckedModeBanner: false,
        locale: const Locale('ar', 'EG'),
        // navigatorKey تمت إزالته هنا لأن MaterialApp.router في هذه النسخة لا يدعم هذا الوسيط
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: child!,
          );
        },
      ),
    ),
  );
}
