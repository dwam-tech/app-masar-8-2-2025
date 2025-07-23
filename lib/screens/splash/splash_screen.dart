import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      context.go('/onboarding');
    });
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
