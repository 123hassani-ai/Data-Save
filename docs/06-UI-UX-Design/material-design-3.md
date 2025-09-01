# Material Design 3 - طراحی متریال

## 📊 Document Information
- **Created:** 2025-09-01
- **Last Updated:** 2025-09-01
- **Version:** 1.0
- **Maintainer:** DataSave Design Team
- **Related Files:** `/lib/core/theme/material_theme.dart`, `/lib/core/widgets/material3_components/`

## 🎯 Overview
این مستند پیاده‌سازی Material Design 3 (Material You) در پروژه DataSave را شرح می‌دهد. شامل سیستم طراحی جدید گوگل، کامپوننت‌های Material 3، سیستم رنگ‌بندی پویا، و نحوه بهره‌گیری از ویژگی‌های جدید این استاندارد در Flutter است.

## 📋 Table of Contents
- [مبانی Material Design 3](#مبانی-material-design-3)
- [سیستم رنگ‌بندی پویا](#سیستم-رنگ‌بندی-پویا)
- [کامپوننت‌های Material 3](#کامپوننت‌های-material-3)
- [تایپوگرافی و فونت‌ها](#تایپوگرافی-و-فونت‌ها)
- [انیمیشن‌ها و حرکت‌ها](#انیمیشن‌ها-و-حرکت‌ها)
- [شخصی‌سازی](#شخصی‌سازی)
- [نمونه‌های کاربردی](#نمونه‌های-کاربردی)

## 🎨 مبانی Material Design 3

### تفاوت‌های Material 3 با Material 2
```yaml
Material 3 vs Material 2:
  Color System:
    - رنگ‌بندی پویا براساس wallpaper کاربر
    - پالت رنگ گسترده‌تر و منطقی‌تر
    - توانایی تطبیق با تم سیستم
    
  Typography:
    - سیستم تایپوگرافی جدید با نام‌گذاری شفاف‌تر
    - فونت‌های بهینه‌شده برای خوانایی
    
  Components:
    - شکل‌های گردتر و نرم‌تر
    - سایه‌های کمتر و استفاده بیشتر از رنگ‌ها
    - تاکید بیشتر بر محتوا
    
  Motion:
    - انیمیشن‌های نرم‌تر و طبیعی‌تر
    - انتقال‌های هوشمند
    
  Accessibility:
    - بهبود کنتراست و خوانایی
    - پشتیبانی بهتر از ابزارهای کمکی
```

### اصول طراحی Material 3
```yaml
Design Principles:
  1. Expressive:
     - شخصی‌سازی بیشتر
     - انعکاس شخصیت کاربر
     
  2. Adaptive:
     - تطبیق با محیط و دستگاه
     - واکنش‌گرا و منعطف
     
  3. Cohesive:
     - سازگاری در تمام پلتفرم‌ها
     - تجربه یکسان و پیوسته
```

## 🌈 سیستم رنگ‌بندی پویا

### پیاده‌سازی Dynamic Color
```dart
// lib/core/theme/dynamic_color.dart

import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:datasave/core/theme/colors.dart';

class DynamicColorTheme {
  // بازگرداندن ColorScheme با پشتیبانی از Dynamic Color
  static Future<ColorScheme> getLightColorScheme() async {
    try {
      // دریافت رنگ‌های پویا از سیستم (Android 12+)
      final corePalette = await DynamicColorPlugin.getCorePalette();
      
      if (corePalette != null) {
        // ایجاد ColorScheme از رنگ‌های پویا
        return ColorScheme.fromSeed(
          seedColor: Color(corePalette.primary.get(40)),
          brightness: Brightness.light,
        );
      }
    } catch (e) {
      // در صورت عدم پشتیبانی یا خطا، از رنگ‌های پیش‌فرض استفاده شود
      debugPrint('Dynamic Color not supported: $e');
    }
    
    // ColorScheme پیش‌فرض
    return ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    );
  }
  
  static Future<ColorScheme> getDarkColorScheme() async {
    try {
      final corePalette = await DynamicColorPlugin.getCorePalette();
      
      if (corePalette != null) {
        return ColorScheme.fromSeed(
          seedColor: Color(corePalette.primary.get(80)),
          brightness: Brightness.dark,
        );
      }
    } catch (e) {
      debugPrint('Dynamic Color not supported: $e');
    }
    
    return ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    );
  }
  
  // بررسی پشتیبانی از Dynamic Color
  static Future<bool> isDynamicColorSupported() async {
    try {
      final corePalette = await DynamicColorPlugin.getCorePalette();
      return corePalette != null;
    } catch (e) {
      return false;
    }
  }
  
  // ایجاد تم کامل با Dynamic Color
  static Future<ThemeData> createLightTheme() async {
    final colorScheme = await getLightColorScheme();
    return _buildTheme(colorScheme);
  }
  
  static Future<ThemeData> createDarkTheme() async {
    final colorScheme = await getDarkColorScheme();
    return _buildTheme(colorScheme);
  }
  
  // ساخت ThemeData با ColorScheme
  static ThemeData _buildTheme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      
      // Material 3 AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: colorScheme.surfaceTint,
        elevation: 0,
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
      ),
      
      // Material 3 Card
      cardTheme: CardTheme(
        color: colorScheme.surfaceVariant,
        surfaceTintColor: colorScheme.surfaceTint,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // Material 3 FilledButton
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      // فونت Vazirmatn
      fontFamily: 'Vazirmatn',
      
      // سیستم تایپوگرافی Material 3
      textTheme: _buildMaterial3TextTheme(colorScheme),
    );
  }
  
  // ساخت TextTheme مطابق Material 3
  static TextTheme _buildMaterial3TextTheme(ColorScheme colorScheme) {
    return TextTheme(
      // Display styles
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        color: colorScheme.onSurface,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: colorScheme.onSurface,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: colorScheme.onSurface,
      ),
      
      // Headline styles
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: colorScheme.onSurface,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: colorScheme.onSurface,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: colorScheme.onSurface,
      ),
      
      // Title styles
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: colorScheme.onSurface,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        color: colorScheme.onSurface,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: colorScheme.onSurface,
      ),
      
      // Body styles
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: colorScheme.onSurface,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: colorScheme.onSurface,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: colorScheme.onSurface,
      ),
    );
  }
}
```

## 🧩 کامپوننت‌های Material 3

### نمونه کارت Material 3
```dart
// lib/core/widgets/material3_card.dart

import 'package:flutter/material.dart';

enum CardType {
  elevated,
  filled,
  outlined,
}

class Material3Card extends StatelessWidget {
  final Widget child;
  final CardType type;
  final VoidCallback? onTap;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final double? elevation;
  final Color? backgroundColor;
  
  const Material3Card({
    Key? key,
    required this.child,
    this.type = CardType.elevated,
    this.onTap,
    this.margin,
    this.padding,
    this.elevation,
    this.backgroundColor,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // تنظیمات مخصوص هر نوع کارت
    Color? cardColor;
    double cardElevation;
    BorderSide? borderSide;
    
    switch (type) {
      case CardType.elevated:
        cardColor = backgroundColor ?? colorScheme.surface;
        cardElevation = elevation ?? 1;
        borderSide = null;
        break;
      case CardType.filled:
        cardColor = backgroundColor ?? colorScheme.surfaceVariant;
        cardElevation = 0;
        borderSide = null;
        break;
      case CardType.outlined:
        cardColor = backgroundColor ?? colorScheme.surface;
        cardElevation = 0;
        borderSide = BorderSide(color: colorScheme.outline);
        break;
    }
    
    return Card(
      margin: margin,
      elevation: cardElevation,
      surfaceTintColor: colorScheme.surfaceTint,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: borderSide ?? BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: padding ?? EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}
```

### دکمه‌های Material 3
```dart
// lib/core/widgets/material3_buttons.dart

import 'package:flutter/material.dart';

// FilledButton
class PrimaryFilledButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  
  const PrimaryFilledButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18),
                  SizedBox(width: 8),
                ],
                Text(text),
              ],
            ),
    );
  }
}

// FilledTonalButton
class SecondaryFilledButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  
  const SecondaryFilledButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18),
            SizedBox(width: 8),
          ],
          Text(text),
        ],
      ),
    );
  }
}
```

## 📱 نمونه‌های کاربردی

### صفحه نمایش کامپوننت‌های Material 3
```dart
// lib/presentation/screens/design_system/material3_showcase.dart

import 'package:flutter/material.dart';
import 'package:datasave/core/widgets/material3_card.dart';
import 'package:datasave/core/widgets/material3_buttons.dart';

class Material3ShowcaseScreen extends StatefulWidget {
  const Material3ShowcaseScreen({Key? key}) : super(key: key);
  
  @override
  State<Material3ShowcaseScreen> createState() => _Material3ShowcaseScreenState();
}

class _Material3ShowcaseScreenState extends State<Material3ShowcaseScreen> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Material 3 Components'),
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildSection(
            title: 'کارت‌ها',
            children: [
              Row(
                children: [
                  Expanded(
                    child: Material3Card(
                      type: CardType.elevated,
                      child: Column(
                        children: [
                          Icon(Icons.cloud, size: 48, color: colorScheme.primary),
                          SizedBox(height: 8),
                          Text('Elevated Card', style: Theme.of(context).textTheme.titleMedium),
                          Text('کارت با سایه', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Material3Card(
                      type: CardType.filled,
                      child: Column(
                        children: [
                          Icon(Icons.color_lens, size: 48, color: colorScheme.primary),
                          SizedBox(height: 8),
                          Text('Filled Card', style: Theme.of(context).textTheme.titleMedium),
                          Text('کارت پر شده', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          _buildSection(
            title: 'دکمه‌ها',
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PrimaryFilledButton(
                    text: 'Filled Button',
                    icon: Icons.check,
                    onPressed: () => _showSnackbar('Filled Button pressed'),
                  ),
                  SizedBox(height: 12),
                  SecondaryFilledButton(
                    text: 'Tonal Button',
                    icon: Icons.palette,
                    onPressed: () => _showSnackbar('Tonal Button pressed'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSnackbar('FAB pressed'),
        icon: Icon(Icons.add),
        label: Text('ایجاد'),
      ),
    );
  }
  
  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        ...children,
        SizedBox(height: 24),
      ],
    );
  }
  
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
```

## 🏆 بهترین شیوه‌ها

### اصول Material Design 3
```yaml
Material Design 3 Best Practices:
  1. استفاده از Material 3 Components:
     - به‌روزرسانی به جدیدترین نسخه Flutter
     - فعال‌سازی useMaterial3: true
     - استفاده از کامپوننت‌های جدید
     
  2. Dynamic Color:
     - پشتیبانی از رنگ‌بندی پویا در اندروید ۱۲+
     - تعریف fallback برای دستگاه‌های قدیمی‌تر
     
  3. Color Scheme:
     - استفاده از ColorScheme.fromSeed
     - حفظ سازگاری با تم‌های روشن و تاریک
     
  4. Typography:
     - استفاده از سیستم تایپوگرافی Material 3
     - تنظیم فونت‌های مناسب برای زبان فارسی
```

### نکات پیاده‌سازی
```yaml
Implementation Tips:
  1. مهاجرت تدریجی:
     - به‌روزرسانی کامپوننت‌ها به تدریج
     - تست در دستگاه‌های مختلف
     
  2. سازگاری:
     - حفظ پشتیبانی از نسخه‌های قدیمی اندروید
     - تست در iOS و وب
     
  3. شخصی‌سازی:
     - ایجاد ThemeExtension برای تنظیمات سفارشی
     - حفظ سازگاری با برند
```

## 🔄 Related Documentation
- [Color Scheme](color-scheme.md)
- [Typography and Fonts](typography-fonts.md)
- [UI Components Library](ui-components-library.md)
- [Design System](design-system.md)

---
*Last updated: 2025-09-01*  
*File: docs/06-UI-UX-Design/material-design-3.md*