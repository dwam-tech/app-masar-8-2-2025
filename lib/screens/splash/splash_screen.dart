import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:saba2v2/providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // انتظار 3 ثوانٍ لعرض شاشة البداية
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;
    
    // التحقق من حالة المصادقة
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.isLoggedIn && authProvider.userData != null) {
      // إذا كان المستخدم مسجل دخول، توجيهه إلى الصفحة المناسبة حسب نوع المستخدم
      final userType = authProvider.userType;
      
      switch (userType) {
        case 'normal':
          context.go('/UserHomeScreen');
          break;
        case 'real_estate_office':
        case 'real_estate_individual':
          context.go('/RealStateHomeScreen');
          break;
        case 'restaurant':
          context.go('/restaurant-home');
          break;
        case 'car_rental_office':
        case 'driver':
          context.go('/delivery-homescreen');
          break;
        default:
          // في حالة نوع مستخدم غير معروف، توجيه إلى onboarding
          context.go('/onboarding');
      }
    } else {
      // إذا لم يكن مسجل دخول، توجيه إلى onboarding
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Directionality(
      textDirection: TextDirection.rtl, // تفعيل اتجاه النص العربي
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 48 : 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center, // مهم جداً عشان النص يبقى مظبوط
              children: [
                Image.asset(
                  'assets/images/Logo.png',
                  width: isTablet ? size.width * 0.28 : size.width * 0.5,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: isTablet ? 36 : 24),
                Text(
                  'اهلاً ومرحباً بك في تطبيق مسار',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isTablet ? 34 : 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: isTablet ? 32 : 20),
                SizedBox(
                  width: isTablet ? 56 : 36,
                  height: isTablet ? 56 : 36,
                  child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                    strokeWidth: 4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
