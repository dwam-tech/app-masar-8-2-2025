import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:saba2v2/providers/service_category_provider.dart';
import 'package:saba2v2/providers/restaurant_provider.dart';
import 'package:saba2v2/providers/real_estate_provider.dart';
import 'package:saba2v2/providers/auth_provider.dart';
import 'package:saba2v2/screens/user/user_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar', null);
  runApp(TestUserHomeApp());
}

class TestUserHomeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ServiceCategoryProvider()),
        ChangeNotifierProvider(create: (_) => RestaurantProvider()),
        ChangeNotifierProvider(create: (_) => RealEstateProvider()),
      ],
      child: MaterialApp(
        title: 'Test User Home',
        theme: ThemeData(
          fontFamily: 'Cairo',
          primarySwatch: Colors.orange,
        ),
        home: UserHomeScreen(),
      ),
    );
  }
}