import 'package:flutter/material.dart';

class HotelTheme {
  // الألوان الأساسية للتطبيق
  static const Color primaryOrange = Color(0xFFFC8700);
  static const Color lightOrange = Color(0xFFFFF3E6);
  static const Color darkOrange = Color(0xFFE67600);
  static const Color accentOrange = Color(0xFFFF9500);
  
  // الألوان المساعدة
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);
  
  // الظلال
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      spreadRadius: 0,
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      spreadRadius: 0,
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
  
  // أنماط النصوص
  static const TextStyle headingLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    height: 1.2,
  );
  
  static const TextStyle headingMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.3,
  );
  
  static const TextStyle headingSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.3,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: textPrimary,
    height: 1.4,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textPrimary,
    height: 1.4,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.4,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.3,
  );
  
  // أنماط الأزرار
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryOrange,
    foregroundColor: Colors.white,
    elevation: 2,
    shadowColor: primaryOrange.withOpacity(0.3),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  );
  
  static ButtonStyle secondaryButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: primaryOrange,
    side: const BorderSide(color: primaryOrange, width: 1.5),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  );
  
  // أنماط الحاويات
  static BoxDecoration cardDecoration = BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(16),
    boxShadow: cardShadow,
  );
  
  static BoxDecoration elevatedCardDecoration = BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(20),
    boxShadow: elevatedShadow,
  );
  
  static BoxDecoration inputBoxDecoration = BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: borderColor, width: 1),
  );
  
  static BoxDecoration focusedInputDecoration = BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: primaryOrange, width: 2),
  );

  // أنماط حقول الإدخال
  static InputDecoration inputDecoration = InputDecoration(
    filled: true,
    fillColor: cardColor,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: borderColor, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: borderColor, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: primaryOrange, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );
  
  // أنماط التقييم
  static Widget buildRatingStars(double rating, {double size = 16}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return Icon(Icons.star, color: warningColor, size: size);
        } else if (index < rating) {
          return Icon(Icons.star_half, color: warningColor, size: size);
        } else {
          return Icon(Icons.star_border, color: Colors.grey[300], size: size);
        }
      }),
    );
  }
  
  // أنماط الشارات
  static Widget buildBadge(String text, {Color? color, Color? textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color ?? lightOrange,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: bodySmall.copyWith(
          color: textColor ?? primaryOrange,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
  
  // أنماط الأيقونات
  static Widget buildIconWithBackground(IconData icon, {Color? backgroundColor, Color? iconColor}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor ?? lightOrange,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: iconColor ?? primaryOrange,
        size: 20,
      ),
    );
  }
  
  // أنماط التدرج
  static LinearGradient primaryGradient = const LinearGradient(
    colors: [primaryOrange, accentOrange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient lightGradient = LinearGradient(
    colors: [lightOrange, lightOrange.withOpacity(0.5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}