import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:saba2v2/router/app_router.dart';
import 'package:saba2v2/providers/service_category_provider.dart';
import 'package:saba2v2/providers/restaurant_provider.dart';
import 'package:saba2v2/providers/real_estate_provider.dart';
import 'package:saba2v2/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة مدير الحالة
  final authProvider = AuthProvider();
  await authProvider.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => ServiceCategoryProvider()),
        ChangeNotifierProvider(create: (_) => RestaurantProvider()),
        ChangeNotifierProvider(create: (_) => RealEstateProvider()),
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
        // هنا الإضافة لمنع تكبير/تصغير الخط من السيستم
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
