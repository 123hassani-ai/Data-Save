# طرح رنگ‌بندی - Color Scheme

## 📊 Document Information
- **Created:** 2025-09-01
- **Last Updated:** 2025-09-01
- **Version:** 1.0
- **Maintainer:** DataSave Design Team
- **Related Files:** `/lib/core/theme/colors.dart`, `/web/css/theme.css`

## 🎯 Overview
این مستند طرح رنگ‌بندی رسمی پروژه DataSave را شرح می‌دهد، شامل پالت رنگ اصلی، رنگ‌های معنایی، سیستم رنگ‌بندی Material 3، و نحوه پیاده‌سازی تم روشن و تاریک. این مستند راهنمای جامعی برای استفاده صحیح از رنگ‌ها در سراسر برنامه است.

## 📋 Table of Contents
- [پالت رنگ اصلی](#پالت-رنگ-اصلی)
- [سیستم رنگ‌بندی Material 3](#سیستم-رنگ‌بندی-material-3)
- [رنگ‌های معنایی](#رنگ‌های-معنایی)
- [تم روشن و تاریک](#تم-روشن-و-تاریک)
- [کنتراست و دسترسی‌پذیری](#کنتراست-و-دسترسی‌پذیری)
- [نمونه‌های کاربردی](#نمونه‌های-کاربردی)
- [بهترین شیوه‌ها](#بهترین-شیوه‌ها)

## 🎨 پالت رنگ اصلی

### رنگ‌های برند
```yaml
Primary Colors:
  primary-main: "#1976D2"      # آبی اصلی
  primary-light: "#42A5F5"     # آبی روشن
  primary-dark: "#0D47A1"      # آبی تیره
  primary-contrast: "#FFFFFF"  # متن روی آبی
  
  secondary-main: "#009688"    # سبز آبی
  secondary-light: "#4DB6AC"   # سبز آبی روشن
  secondary-dark: "#00796B"    # سبز آبی تیره
  secondary-contrast: "#FFFFFF"  # متن روی سبز آبی
  
  tertiary-main: "#FF9800"     # نارنجی
  tertiary-light: "#FFB74D"    # نارنجی روشن
  tertiary-dark: "#F57C00"     # نارنجی تیره
  tertiary-contrast: "#000000"  # متن روی نارنجی
```

### پالت رنگ گسترده
```yaml
Extended Palette:
  neutral-50: "#FAFAFA"
  neutral-100: "#F5F5F5"
  neutral-200: "#EEEEEE"
  neutral-300: "#E0E0E0"
  neutral-400: "#BDBDBD"
  neutral-500: "#9E9E9E"
  neutral-600: "#757575"
  neutral-700: "#616161"
  neutral-800: "#424242"
  neutral-900: "#212121"
  
  blue-50: "#E3F2FD"
  blue-100: "#BBDEFB"
  blue-200: "#90CAF9"
  blue-300: "#64B5F6"
  blue-400: "#42A5F5"
  blue-500: "#2196F3"
  blue-600: "#1E88E5"
  blue-700: "#1976D2"
  blue-800: "#1565C0"
  blue-900: "#0D47A1"
  
  teal-50: "#E0F2F1"
  teal-100: "#B2DFDB"
  teal-200: "#80CBC4"
  teal-300: "#4DB6AC"
  teal-400: "#26A69A"
  teal-500: "#009688"
  teal-600: "#00897B"
  teal-700: "#00796B"
  teal-800: "#00695C"
  teal-900: "#004D40"
  
  orange-50: "#FFF3E0"
  orange-100: "#FFE0B2"
  orange-200: "#FFCC80"
  orange-300: "#FFB74D"
  orange-400: "#FFA726"
  orange-500: "#FF9800"
  orange-600: "#FB8C00"
  orange-700: "#F57C00"
  orange-800: "#EF6C00"
  orange-900: "#E65100"
```

### نمودار پالت رنگ
```
┌─────────────────────────────────────────────────────┐
│ پالت رنگ DataSave                                   │
├──────────────┬──────────────┬──────────────┬────────┤
│   رنگ اصلی   │   آبی        │ #1976D2      │ ████   │
├──────────────┼──────────────┼──────────────┼────────┤
│  رنگ ثانویه  │   سبز آبی    │ #009688      │ ████   │
├──────────────┼──────────────┼──────────────┼────────┤
│  رنگ مکمل    │   نارنجی     │ #FF9800      │ ████   │
├──────────────┼──────────────┼──────────────┼────────┤
│  رنگ خنثی    │   خاکستری    │ #9E9E9E      │ ████   │
└──────────────┴──────────────┴──────────────┴────────┘
```

## 🧩 سیستم رنگ‌بندی Material 3

### پیاده‌سازی Material 3 در Flutter
```dart
// lib/core/theme/colors.dart

import 'package:flutter/material.dart';

class AppColors {
  // رنگ‌های اصلی
  static const MaterialColor primarySwatch = MaterialColor(
    0xFF1976D2,
    <int, Color>{
      50: Color(0xFFE3F2FD),
      100: Color(0xFFBBDEFB),
      200: Color(0xFF90CAF9),
      300: Color(0xFF64B5F6),
      400: Color(0xFF42A5F5),
      500: Color(0xFF2196F3),
      600: Color(0xFF1E88E5),
      700: Color(0xFF1976D2),
      800: Color(0xFF1565C0),
      900: Color(0xFF0D47A1),
    },
  );
  
  // رنگ‌های پایه
  static const Color primary = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF42A5F5);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color primaryContainer = Color(0xFFD0E4FF);
  static const Color onPrimaryContainer = Color(0xFF001D36);
  
  static const Color secondary = Color(0xFF009688);
  static const Color secondaryLight = Color(0xFF4DB6AC);
  static const Color secondaryDark = Color(0xFF00796B);
  static const Color secondaryContainer = Color(0xFFC4F9F2);
  static const Color onSecondaryContainer = Color(0xFF002923);
  
  static const Color tertiary = Color(0xFFFF9800);
  static const Color tertiaryLight = Color(0xFFFFB74D);
  static const Color tertiaryDark = Color(0xFFF57C00);
  static const Color tertiaryContainer = Color(0xFFFFE0B2);
  static const Color onTertiaryContainer = Color(0xFF401800);
  
  // رنگ‌های خنثی
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF5F5F5);
  static const Color error = Color(0xFFB00020);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onTertiary = Color(0xFF000000);
  static const Color onSurface = Color(0xFF000000);
  static const Color onBackground = Color(0xFF000000);
  static const Color onError = Color(0xFFFFFFFF);
  
  // رنگ‌های تم تاریک
  static const Color primaryDarkMode = Color(0xFF90CAF9);
  static const Color primaryDarkModeContainer = Color(0xFF004A83);
  static const Color onPrimaryDarkModeContainer = Color(0xFFD0E4FF);
  
  static const Color surfaceDarkMode = Color(0xFF121212);
  static const Color backgroundDarkMode = Color(0xFF1E1E1E);
  static const Color onSurfaceDarkMode = Color(0xFFFFFFFF);
  static const Color onBackgroundDarkMode = Color(0xFFE0E0E0);
  
  // رنگ‌های معنایی
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);
  static const Color hint = Color(0xFF9E9E9E);
  
  // متدها برای محاسبه سایه‌های رنگ
  static Color darken(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    
    return hslDark.toColor();
  }
  
  static Color lighten(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    
    return hslLight.toColor();
  }
}
```

### پیکربندی ColorScheme در Material 3
```dart
// lib/core/theme/theme_data.dart

import 'package:flutter/material.dart';
import 'package:datasave/core/theme/colors.dart';

class AppTheme {
  // تم روشن
  static ThemeData lightTheme() {
    final ColorScheme colorScheme = ColorScheme(
      primary: AppColors.primary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      tertiary: AppColors.tertiary,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: AppColors.onTertiaryContainer,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      background: AppColors.background,
      onBackground: AppColors.onBackground,
      error: AppColors.error,
      onError: AppColors.onError,
      brightness: Brightness.light,
      onPrimary: AppColors.onPrimary,
      onSecondary: AppColors.onSecondary,
      onTertiary: AppColors.onTertiary,
    );
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      primarySwatch: AppColors.primarySwatch,
      scaffoldBackgroundColor: colorScheme.background,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: colorScheme.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: colorScheme.onPrimary,
          backgroundColor: colorScheme.primary,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 4,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withOpacity(0.6),
      ),
      textTheme: _buildTextTheme(),
      fontFamily: 'Vazirmatn',
    );
  }
  
  // تم تاریک
  static ThemeData darkTheme() {
    final ColorScheme colorScheme = ColorScheme(
      primary: AppColors.primaryDarkMode,
      primaryContainer: AppColors.primaryDarkModeContainer,
      onPrimaryContainer: AppColors.onPrimaryDarkModeContainer,
      secondary: AppColors.secondaryLight,
      secondaryContainer: AppColors.secondaryDark,
      onSecondaryContainer: Color(0xFFC4F9F2),
      tertiary: AppColors.tertiaryLight,
      tertiaryContainer: AppColors.tertiaryDark,
      onTertiaryContainer: Color(0xFFFFE0B2),
      surface: AppColors.surfaceDarkMode,
      onSurface: AppColors.onSurfaceDarkMode,
      background: AppColors.backgroundDarkMode,
      onBackground: AppColors.onBackgroundDarkMode,
      error: Color(0xFFCF6679),
      onError: Color(0xFF000000),
      brightness: Brightness.dark,
      onPrimary: Color(0xFF000000),
      onSecondary: Color(0xFF000000),
      onTertiary: Color(0xFF000000),
    );
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.background,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: Color(0xFF2C2C2C),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Color(0xFF000000),
          backgroundColor: colorScheme.primary,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF2C2C2C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: Color(0xFF000000),
        elevation: 4,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withOpacity(0.6),
      ),
      textTheme: _buildTextTheme(isDark: true),
      fontFamily: 'Vazirmatn',
    );
  }
  
  // ساخت TextTheme
  static TextTheme _buildTextTheme({bool isDark = false}) {
    final Color textColor = isDark ? Colors.white : Colors.black;
    
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: textColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: textColor,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: textColor,
      ),
    );
  }
}
```

## 🚦 رنگ‌های معنایی

### رنگ‌های وضعیت
```yaml
Semantic Colors:
  # رنگ‌های وضعیت
  success: "#4CAF50"       # موفقیت
  success-light: "#A5D6A7" # موفقیت روشن
  success-dark: "#2E7D32"  # موفقیت تیره
  
  warning: "#FFC107"       # هشدار
  warning-light: "#FFE082" # هشدار روشن
  warning-dark: "#FFA000"  # هشدار تیره
  
  error: "#B00020"         # خطا
  error-light: "#EF9A9A"   # خطا روشن
  error-dark: "#C62828"    # خطا تیره
  
  info: "#2196F3"          # اطلاعات
  info-light: "#90CAF9"    # اطلاعات روشن
  info-dark: "#1565C0"     # اطلاعات تیره
  
  # رنگ‌های متن
  text-primary: "#212121"  # متن اصلی
  text-secondary: "#757575" # متن ثانویه
  text-disabled: "#9E9E9E" # متن غیرفعال
  text-hint: "#9E9E9E"     # متن راهنما
  
  # رنگ‌های پس‌زمینه
  background-default: "#F5F5F5" # پس‌زمینه اصلی
  background-paper: "#FFFFFF"   # پس‌زمینه کاغذی
  background-disabled: "#E0E0E0" # پس‌زمینه غیرفعال
  
  # رنگ‌های مرز
  border-default: "#E0E0E0" # مرز اصلی
  border-focus: "#1976D2"   # مرز فوکوس
  border-error: "#B00020"   # مرز خطا
```

### استفاده از رنگ‌های معنایی
```dart
// lib/core/widgets/status_badge.dart

import 'package:flutter/material.dart';
import 'package:datasave/core/theme/colors.dart';

enum StatusType {
  success,
  warning,
  error,
  info,
  neutral
}

class StatusBadge extends StatelessWidget {
  final StatusType type;
  final String text;
  final bool outlined;
  
  const StatusBadge({
    Key? key,
    required this.type,
    required this.text,
    this.outlined = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : _getColor(),
        border: outlined ? Border.all(color: _getColor()) : null,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: outlined ? _getColor() : _getTextColor(),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
  
  Color _getColor() {
    switch (type) {
      case StatusType.success:
        return AppColors.success;
      case StatusType.warning:
        return AppColors.warning;
      case StatusType.error:
        return AppColors.error;
      case StatusType.info:
        return AppColors.info;
      case StatusType.neutral:
        return AppColors.hint;
    }
  }
  
  Color _getTextColor() {
    switch (type) {
      case StatusType.success:
        return Colors.white;
      case StatusType.warning:
        return Colors.black87;
      case StatusType.error:
        return Colors.white;
      case StatusType.info:
        return Colors.white;
      case StatusType.neutral:
        return Colors.white;
    }
  }
}
```

## 🌓 تم روشن و تاریک

### مدیریت تم
```dart
// lib/core/providers/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:datasave/core/theme/theme_data.dart';

class ThemeProvider with ChangeNotifier {
  // کلید ذخیره تم در SharedPreferences
  static const String themePreferenceKey = 'theme_mode';
  
  // حالت فعلی تم
  ThemeMode _themeMode = ThemeMode.light;
  
  // دریافت حالت فعلی تم
  ThemeMode get themeMode => _themeMode;
  
  // دریافت تم فعلی
  ThemeData getTheme(BuildContext context) {
    if (_themeMode == ThemeMode.dark) {
      return AppTheme.darkTheme();
    } else if (_themeMode == ThemeMode.light) {
      return AppTheme.lightTheme();
    } else {
      // بررسی تم سیستم
      final brightness = MediaQuery.of(context).platformBrightness;
      return brightness == Brightness.dark
          ? AppTheme.darkTheme()
          : AppTheme.lightTheme();
    }
  }
  
  // سازنده
  ThemeProvider() {
    _loadThemePreference();
  }
  
  // تغییر تم
  void setThemeMode(ThemeMode themeMode) async {
    _themeMode = themeMode;
    notifyListeners();
    
    // ذخیره تنظیمات
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(themePreferenceKey, _themeModeToString(themeMode));
  }
  
  // بارگذاری تنظیمات ذخیره شده
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(themePreferenceKey);
    
    if (savedTheme != null) {
      _themeMode = _stringToThemeMode(savedTheme);
      notifyListeners();
    }
  }
  
  // تبدیل ThemeMode به رشته
  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
  
  // تبدیل رشته به ThemeMode
  ThemeMode _stringToThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }
  
  // بررسی تاریک بودن تم
  bool isDarkMode(BuildContext context) {
    if (_themeMode == ThemeMode.system) {
      return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }
  
  // تغییر حالت تم بین روشن و تاریک
  void toggleTheme() {
    final newMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    setThemeMode(newMode);
  }
}
```

### استفاده از تم در برنامه
```dart
// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:datasave/core/providers/theme_provider.dart';
import 'package:datasave/routes.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      title: 'DataSave',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: themeProvider.getTheme(context),
      darkTheme: AppTheme.darkTheme(),
      initialRoute: Routes.splash,
      routes: Routes.getRoutes(),
      onGenerateRoute: Routes.onGenerateRoute,
    );
  }
}
```

### ویجت تغییر تم
```dart
// lib/presentation/widgets/theme_switcher.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:datasave/core/providers/theme_provider.dart';

class ThemeSwitcher extends StatelessWidget {
  const ThemeSwitcher({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode(context);
    
    return ListTile(
      title: Text('حالت تاریک'),
      subtitle: Text(isDarkMode ? 'فعال' : 'غیرفعال'),
      leading: Icon(
        isDarkMode ? Icons.dark_mode : Icons.light_mode,
        color: isDarkMode ? Colors.amber : Colors.blue,
      ),
      trailing: Switch(
        value: isDarkMode,
        onChanged: (value) {
          themeProvider.setThemeMode(
            value ? ThemeMode.dark : ThemeMode.light
          );
        },
        activeColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
```

## 🔍 کنتراست و دسترسی‌پذیری

### بررسی کنتراست رنگ‌ها
```dart
// lib/core/utils/color_utils.dart

import 'dart:math';
import 'package:flutter/material.dart';

class ColorUtils {
  // محاسبه نسبت کنتراست بین دو رنگ
  // براساس استاندارد WCAG 2.0
  static double contrastRatio(Color color1, Color color2) {
    final l1 = _luminance(color1);
    final l2 = _luminance(color2);
    
    // محاسبه نسبت کنتراست (روشن‌تر / تاریک‌تر)
    return (max(l1, l2) + 0.05) / (min(l1, l2) + 0.05);
  }
  
  // محاسبه درخشندگی نسبی رنگ
  static double _luminance(Color color) {
    // استخراج مقادیر RGB بین 0 تا 1
    final r = color.red / 255;
    final g = color.green / 255;
    final b = color.blue / 255;
    
    // تبدیل غیرخطی sRGB به درخشندگی
    final rLum = r <= 0.03928 ? r / 12.92 : pow((r + 0.055) / 1.055, 2.4);
    final gLum = g <= 0.03928 ? g / 12.92 : pow((g + 0.055) / 1.055, 2.4);
    final bLum = b <= 0.03928 ? b / 12.92 : pow((b + 0.055) / 1.055, 2.4);
    
    // محاسبه درخشندگی نسبی براساس فرمول WCAG
    return 0.2126 * (rLum as double) + 0.7152 * (gLum as double) + 0.0722 * (bLum as double);
  }
  
  // بررسی مناسب بودن رنگ متن روی پس‌زمینه
  static bool isAccessible(Color background, Color text, {bool isLargeText = false}) {
    final ratio = contrastRatio(background, text);
    
    // بررسی استاندارد WCAG 2.0 AA
    // حداقل 4.5:1 برای متن معمولی و 3:1 برای متن بزرگ
    return isLargeText ? ratio >= 3.0 : ratio >= 4.5;
  }
  
  // تولید رنگ متن مناسب (سیاه یا سفید) براساس رنگ پس‌زمینه
  static Color contrastingTextColor(Color backgroundColor) {
    return _luminance(backgroundColor) > 0.5 ? Colors.black : Colors.white;
  }
  
  // تیره‌تر کردن رنگ
  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    
    return hslDark.toColor();
  }
  
  // روشن‌تر کردن رنگ
  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    
    return hslLight.toColor();
  }
}
```

### ویجت متن با کنتراست بالا
```dart
// lib/core/widgets/high_contrast_text.dart

import 'package:flutter/material.dart';
import 'package:datasave/core/utils/color_utils.dart';

class HighContrastText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color? backgroundColor;
  final bool enforceDarkText;
  final bool isLargeText;
  
  const HighContrastText(
    this.text, {
    Key? key,
    this.style,
    this.backgroundColor,
    this.enforceDarkText = false,
    this.isLargeText = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Theme.of(context).colorScheme.background;
    
    // تعیین رنگ متن با کنتراست مناسب
    Color textColor;
    
    if (enforceDarkText) {
      // اگر نیاز به متن تیره باشد
      textColor = Colors.black;
      
      // بررسی کنتراست
      if (!ColorUtils.isAccessible(bgColor, textColor, isLargeText: isLargeText)) {
        // روشن‌تر کردن پس‌زمینه تا کنتراست کافی ایجاد شود
        return Container(
          color: ColorUtils.lighten(bgColor, 0.3),
          child: Text(
            text,
            style: style?.copyWith(color: textColor) ?? 
                   TextStyle(color: textColor),
          ),
        );
      }
    } else {
      // انتخاب خودکار رنگ متن مناسب
      textColor = ColorUtils.contrastingTextColor(bgColor);
    }
    
    return Text(
      text,
      style: style?.copyWith(color: textColor) ?? 
             TextStyle(color: textColor),
    );
  }
}
```

## 🎭 نمونه‌های کاربردی

### نمونه دکمه‌های رنگی
```dart
// lib/presentation/widgets/colored_buttons.dart

import 'package:flutter/material.dart';
import 'package:datasave/core/theme/colors.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final IconData? icon;
  
  const PrimaryButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        minimumSize: Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: isLoading
          ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: AppColors.onPrimary,
                strokeWidth: 2,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon),
                  SizedBox(width: 8),
                ],
                Text(text),
              ],
            ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  
  const SecondaryButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.icon,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.secondary,
        side: BorderSide(color: AppColors.secondary),
        minimumSize: Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon),
            SizedBox(width: 8),
          ],
          Text(text),
        ],
      ),
    );
  }
}

class TertiaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  
  const TertiaryButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.icon,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.tertiary,
        minimumSize: Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon),
            SizedBox(width: 8),
          ],
          Text(text),
        ],
      ),
    );
  }
}

class StatusButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final StatusType type;
  
  const StatusButton({
    Key? key,
    required this.text,
    required this.onPressed,
    required this.type,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    Color buttonColor;
    Color textColor = Colors.white;
    
    switch (type) {
      case StatusType.success:
        buttonColor = AppColors.success;
        break;
      case StatusType.warning:
        buttonColor = AppColors.warning;
        textColor = Colors.black87;
        break;
      case StatusType.error:
        buttonColor = AppColors.error;
        break;
      case StatusType.info:
        buttonColor = AppColors.info;
        break;
      case StatusType.neutral:
        buttonColor = AppColors.hint;
        break;
    }
    
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: textColor,
        minimumSize: Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(text),
    );
  }
}
```

### صفحه پالت رنگ
```dart
// lib/presentation/screens/design_system/color_palette_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:datasave/core/theme/colors.dart';
import 'package:datasave/core/utils/color_utils.dart';

class ColorPaletteScreen extends StatelessWidget {
  const ColorPaletteScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('پالت رنگ'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildCategoryTitle(context, 'رنگ‌های اصلی'),
          _buildColorGrid([
            ColorItem('primary', AppColors.primary),
            ColorItem('primaryLight', AppColors.primaryLight),
            ColorItem('primaryDark', AppColors.primaryDark),
            ColorItem('primaryContainer', AppColors.primaryContainer),
            ColorItem('onPrimaryContainer', AppColors.onPrimaryContainer),
          ]),
          
          _buildCategoryTitle(context, 'رنگ‌های ثانویه'),
          _buildColorGrid([
            ColorItem('secondary', AppColors.secondary),
            ColorItem('secondaryLight', AppColors.secondaryLight),
            ColorItem('secondaryDark', AppColors.secondaryDark),
            ColorItem('secondaryContainer', AppColors.secondaryContainer),
            ColorItem('onSecondaryContainer', AppColors.onSecondaryContainer),
          ]),
          
          _buildCategoryTitle(context, 'رنگ‌های مکمل'),
          _buildColorGrid([
            ColorItem('tertiary', AppColors.tertiary),
            ColorItem('tertiaryLight', AppColors.tertiaryLight),
            ColorItem('tertiaryDark', AppColors.tertiaryDark),
            ColorItem('tertiaryContainer', AppColors.tertiaryContainer),
            ColorItem('onTertiaryContainer', AppColors.onTertiaryContainer),
          ]),
          
          _buildCategoryTitle(context, 'رنگ‌های معنایی'),
          _buildColorGrid([
            ColorItem('success', AppColors.success),
            ColorItem('warning', AppColors.warning),
            ColorItem('error', AppColors.error),
            ColorItem('info', AppColors.info),
            ColorItem('hint', AppColors.hint),
          ]),
          
          _buildCategoryTitle(context, 'رنگ‌های خنثی'),
          _buildColorGrid([
            ColorItem('surface', AppColors.surface),
            ColorItem('background', AppColors.background),
            ColorItem('onSurface', AppColors.onSurface),
            ColorItem('onBackground', AppColors.onBackground),
          ]),
        ],
      ),
    );
  }
  
  Widget _buildCategoryTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
  
  Widget _buildColorGrid(List<ColorItem> colors) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: colors.length,
      itemBuilder: (context, index) {
        return _buildColorCard(context, colors[index]);
      },
    );
  }
  
  Widget _buildColorCard(BuildContext context, ColorItem colorItem) {
    final textColor = ColorUtils.contrastingTextColor(colorItem.color);
    
    return GestureDetector(
      onTap: () {
        _copyColorToClipboard(context, colorItem);
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: colorItem.color,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Center(
                  child: Text(
                    colorItem.name,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    colorItem.color.toString(),
                    style: TextStyle(fontSize: 12),
                  ),
                  Text(
                    '#${_colorToHex(colorItem.color)}',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _copyColorToClipboard(BuildContext context, ColorItem colorItem) {
    final hexColor = '#${_colorToHex(colorItem.color)}';
    Clipboard.setData(ClipboardData(text: hexColor));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('کد رنگ $hexColor کپی شد'),
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  String _colorToHex(Color color) {
    return color.value.toRadixString(16).padLeft(8, '0').substring(2);
  }
}

class ColorItem {
  final String name;
  final Color color;
  
  ColorItem(this.name, this.color);
}
```

## 🏆 بهترین شیوه‌ها

### اصول استفاده از رنگ
```yaml
Color Usage Principles:
  1. سازگاری:
     - استفاده از رنگ‌های یکسان برای عملکردهای مشابه
     - پیروی از پالت رنگ تعریف شده
     
  2. معنادار بودن:
     - استفاده از رنگ‌های معنایی برای انتقال وضعیت
     - حفظ ثبات در استفاده از رنگ‌های معنایی
     
  3. دسترسی‌پذیری:
     - حفظ کنتراست مناسب بین متن و پس‌زمینه
     - عدم اتکا فقط به رنگ برای انتقال اطلاعات
     
  4. سلسله مراتب:
     - استفاده از رنگ برای نشان دادن اهمیت
     - برجسته‌سازی عناصر مهم با رنگ‌های اصلی
     
  5. مقیاس‌پذیری:
     - استفاده از سیستم‌های رنگی مقیاس‌پذیر
     - امکان تغییر رنگ‌ها با حفظ هارمونی
```

### ساختار مستندات رنگ
```yaml
Color Documentation Structure:
  1. نام‌گذاری روشن:
     - استفاده از نام‌های توصیفی برای رنگ‌ها
     - ترکیب نام معنایی و عملکردی
     
  2. سلسله مراتب رنگ:
     - تعریف رنگ‌های پایه
     - تعریف رنگ‌های مشتق شده
     - تعریف رنگ‌های معنایی
     
  3. فرمت‌های رنگی:
     - ارائه رنگ‌ها در فرمت‌های مختلف (HEX, RGB, HSL)
     - توضیح کاربرد هر رنگ
     
  4. راهنمای کاربرد:
     - مثال‌های استفاده از هر رنگ
     - مثال‌های ترکیبی رنگ‌ها
     
  5. به‌روزرسانی:
     - نگهداری مستندات به‌روز
     - ثبت تغییرات در نسخه‌های مختلف
```

### استفاده از رنگ‌ها در کدنویسی
```yaml
Coding with Colors:
  1. متغیرهای رنگی:
     - تعریف رنگ‌ها به صورت ثابت (static const)
     - استفاده از کلاس AppColors
     
  2. دسترسی به رنگ‌ها:
     - استفاده از Theme.of(context).colorScheme
     - استفاده مستقیم از AppColors در موارد خاص
     
  3. رنگ‌های متغیر:
     - محاسبه رنگ‌ها در زمان اجرا در صورت نیاز
     - استفاده از توابع کمکی برای تغییر رنگ
     
  4. مدیریت تم:
     - پشتیبانی از تم روشن و تاریک
     - استفاده از ColorScheme برای مدیریت رنگ‌ها
     
  5. آزمایش:
     - تست رنگ‌ها در حالت‌های مختلف
     - بررسی کنتراست و دسترسی‌پذیری
```

## 🔄 Related Documentation
- [Typography and Fonts](typography-fonts.md)
- [Design System](design-system.md)
- [Material Design 3](material-design-3.md)
- [UI Components Library](ui-components-library.md)

---
*Last updated: 2025-09-01*  
*File: docs/06-UI-UX-Design/color-scheme.md*