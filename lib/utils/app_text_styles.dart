import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // العناوين الرئيسية
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );
  
  static const TextStyle heading3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );
  
  static const TextStyle heading4 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );
  
  static const TextStyle heading5 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );
  
  static const TextStyle heading6 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );
  
  // النصوص العادية
  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  
  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.4,
  );
  
  static const TextStyle body3 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );
  
  // النصوص الثانوية
  static const TextStyle subtitle1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
  );
  
  static const TextStyle subtitle2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
  );
  
  // النصوص الصغيرة
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
    height: 1.3,
  );
  
  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textLight,
    height: 1.6,
    letterSpacing: 1.5,
  );
  
  // أنماط الأزرار
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  
  static const TextStyle buttonSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  
  // أنماط خاصة بالمحادثات
  static const TextStyle chatMessage = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
  
  static const TextStyle chatTime = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.3,
  );
  
  static const TextStyle chatSenderName = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );
  
  // أنماط التنبيهات
  static const TextStyle errorText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.errorColor,
    height: 1.4,
  );
  
  static const TextStyle successText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.successColor,
    height: 1.4,
  );
  
  static const TextStyle warningText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.warningColor,
    height: 1.4,
  );
  
  // أنماط الروابط
  static const TextStyle link = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryColor,
    decoration: TextDecoration.underline,
    height: 1.4,
  );
}