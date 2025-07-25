// مسار الملف: lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart'; // <<<--- الخطوة 1: تم إضافة هذا السطر
import 'package:saba2v2/router/app_router.dart';
import 'package:saba2v2/providers/service_category_provider.dart';
import 'package:saba2v2/providers/restaurant_provider.dart';
import 'package:saba2v2/providers/real_estate_provider.dart';
import 'package:saba2v2/providers/auth_provider.dart';

void main() async {
  // التأكد من تهيئة Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();

  // <<<--- الخطوة 2: تم إضافة هذا السطر لتهيئة بيانات اللغة العربية ---
  await initializeDateFormatting('ar', null);

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