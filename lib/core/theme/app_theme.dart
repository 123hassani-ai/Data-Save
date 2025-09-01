import 'package:flutter/material.dart';
import 'persian_fonts.dart';

class AppTheme {
  // رنگ‌های اصلی برنامه
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFB00020);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);

  // تعریف فونت فارسی Vazirmatn
  static const String fontFamily = 'Vazirmatn';

  // تم روشن برنامه
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      
      // فونت فارسی Vazirmatn برای کل برنامه
      fontFamily: fontFamily,
      
      // تعریف تایپوگرافی فارسی
      textTheme: TextTheme(
        displayLarge: PersianFonts.displayLarge,
        displayMedium: PersianFonts.displayMedium,
        displaySmall: PersianFonts.displaySmall,
        headlineLarge: PersianFonts.headlineLarge,
        headlineMedium: PersianFonts.headlineMedium,
        headlineSmall: PersianFonts.headlineSmall,
        titleLarge: PersianFonts.titleLarge,
        titleMedium: PersianFonts.titleMedium,
        titleSmall: PersianFonts.titleSmall,
        bodyLarge: PersianFonts.bodyLarge,
        bodyMedium: PersianFonts.bodyMedium,
        bodySmall: PersianFonts.bodySmall,
        labelLarge: PersianFonts.labelLarge,
        labelMedium: PersianFonts.labelMedium,
        labelSmall: PersianFonts.labelSmall,
      ),
      
      // تنظیمات AppBar با فونت فارسی
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: PersianFonts.pageTitle.copyWith(
          color: Colors.white,
        ),
      ),
      
      // تنظیمات Card ها
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // تنظیمات دکمه‌ها با فونت فارسی
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: PersianFonts.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // تنظیمات TextButton با فونت فارسی
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: PersianFonts.button,
        ),
      ),

      // تنظیمات OutlinedButton با فونت فارسی
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          textStyle: PersianFonts.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      // تنظیمات فیلدهای ورودی با فونت فارسی
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        labelStyle: PersianFonts.normal,
        hintStyle: PersianFonts.normal.copyWith(color: Colors.grey[600]),
        helperStyle: PersianFonts.caption,
        errorStyle: PersianFonts.caption.copyWith(color: errorColor),
      ),

      // تنظیمات SnackBar با فونت فارسی
      snackBarTheme: SnackBarThemeData(
        contentTextStyle: PersianFonts.normal.copyWith(color: Colors.white),
      ),

      // تنظیمات Dialog با فونت فارسی
      dialogTheme: DialogThemeData(
        titleTextStyle: PersianFonts.pageTitle,
        contentTextStyle: PersianFonts.bodyMedium,
      ),

      // تنظیمات Tooltip با فونت فارسی
      tooltipTheme: TooltipThemeData(
        textStyle: PersianFonts.caption.copyWith(color: Colors.white),
      ),

      // تنظیمات ListTile با فونت فارسی
      listTileTheme: ListTileThemeData(
        titleTextStyle: PersianFonts.cardTitle,
        subtitleTextStyle: PersianFonts.cardSubtitle,
      ),

      // تنظیمات Tab ها با فونت فارسی
      tabBarTheme: TabBarThemeData(
        labelStyle: PersianFonts.tabActive,
        unselectedLabelStyle: PersianFonts.tabInactive,
      ),

      // تنظیمات BottomNavigationBar با فونت فارسی
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedLabelStyle: PersianFonts.caption,
        unselectedLabelStyle: PersianFonts.caption.copyWith(color: Colors.grey),
      ),

      // تنظیمات Chip ها با فونت فارسی
      chipTheme: ChipThemeData(
        labelStyle: PersianFonts.small,
        backgroundColor: Colors.grey[100],
        selectedColor: primaryColor.withOpacity(0.2),
      ),

      // تنظیمات DataTable با فونت فارسی
      dataTableTheme: DataTableThemeData(
        headingTextStyle: PersianFonts.cardTitle,
        dataTextStyle: PersianFonts.normal,
      ),
    );
  }
}
