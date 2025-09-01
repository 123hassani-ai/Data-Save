import 'package:flutter/material.dart';

/// کلاس مدیریت فونت‌های فارسی - Persian font management class
class PersianFonts {
  /// خانواده فونت اصلی - Main font family
  static const String fontFamily = 'Vazirmatn';
  
  /// لیست فونت‌های fallback - Fallback fonts list
  static const List<String> fontFamilyFallback = [
    'Vazirmatn',
    'Noto Sans Arabic', 
    'Noto Sans',
    'Tahoma',
    'Arial',
  ];
  
  /// استایل‌های متنی فارسی - Persian text styles
  
  // سرتیترهای بزرگ - Large headings
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 45,
    fontWeight: FontWeight.w400,
  );
  
  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w400,
  );
  
  // سرتیتر‌ها - Headlines
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 32,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 28,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );
  
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 24,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );
  
  // تیترها - Titles
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w500,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
  );
  
  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );
  
  // متن‌های بدنه - Body texts
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
  );
  
  // لیبل‌ها - Labels
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );
  
  // استایل‌های خاص فارسی - Special Persian styles
  
  /// متن عادی فارسی - Normal Persian text
  static TextStyle normal = _withFallback(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );
  
  /// متن ضخیم فارسی - Bold Persian text
  static TextStyle bold = _withFallback(
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );
  
  /// متن نازک فارسی - Light Persian text
  static TextStyle light = _withFallback(
    fontSize: 14,
    fontWeight: FontWeight.w300,
  );
  
  /// کپشن فارسی - Persian caption
  static TextStyle caption = _withFallback(
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );
  
  /// متن دکمه فارسی - Persian button text
  static TextStyle button = _withFallback(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.25,
  );
  
  /// عنوان صفحه - Page title
  static TextStyle pageTitle = _withFallback(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );
  
  /// عنوان کارت - Card title
  static TextStyle cardTitle = _withFallback(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
  
  /// زیرنویس کارت - Card subtitle
  static TextStyle cardSubtitle = _withFallback(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );
  
  /// متن آمار - Statistics text
  static TextStyle statisticsTitle = _withFallback(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );
  
  static TextStyle statisticsValue = _withFallback(
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );
  
  /// متن کوچک - Small text
  static TextStyle small = _withFallback(
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );
  
  /// تب فعال - Active tab
  static TextStyle tabActive = _withFallback(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );
  
  /// تب غیرفعال - Inactive tab
  static TextStyle tabInactive = _withFallback(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );
  
  /// عنوان AppBar - AppBar title
  static TextStyle appBarTitle = _withFallback(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );
  
  // توابع کمکی - Helper functions
  
  /// تولید استایل متن با رنگ مشخص - Generate text style with specific color
  static TextStyle withColor(TextStyle baseStyle, Color color) {
    return baseStyle.copyWith(color: color);
  }
  
  /// تولید استایل متن با سایز مشخص - Generate text style with specific size
  static TextStyle withSize(TextStyle baseStyle, double size) {
    return baseStyle.copyWith(fontSize: size);
  }
  
  /// تولید استایل متن با وزن مشخص - Generate text style with specific weight
  static TextStyle withWeight(TextStyle baseStyle, FontWeight weight) {
    return baseStyle.copyWith(fontWeight: weight);
  }
  
  /// تولید TextStyle با فونت‌های fallback - Generate TextStyle with fallback fonts
  static TextStyle _withFallback({
    required double fontSize,
    required FontWeight fontWeight,
    double? letterSpacing,
    double? height,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
      color: color,
    );
  }
}

/// Extension برای استفاده آسان از فونت‌های فارسی
extension PersianTextStyleExtension on TextStyle {
  /// تبدیل به فونت فارسی - Convert to Persian font
  TextStyle get persian {
    return copyWith(fontFamily: PersianFonts.fontFamily);
  }
  
  /// اعمال فونت فارسی با سایز مشخص
  TextStyle persianWithSize(double size) {
    return copyWith(
      fontFamily: PersianFonts.fontFamily,
      fontSize: size,
    );
  }
  
  /// اعمال فونت فارسی با وزن مشخص
  TextStyle persianWithWeight(FontWeight weight) {
    return copyWith(
      fontFamily: PersianFonts.fontFamily,
      fontWeight: weight,
    );
  }
}
