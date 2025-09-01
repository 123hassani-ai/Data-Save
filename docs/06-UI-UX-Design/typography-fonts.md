# تایپوگرافی و فونت‌ها - Typography & Fonts

## 📊 Document Information
- **Created:** 2025-09-01
- **Last Updated:** 2025-09-01
- **Version:** 1.0
- **Maintainer:** DataSave Design Team
- **Related Files:** `/web/vazirmatn.css`, `/lib/core/theme/typography.dart`, `/assets/fonts/`

## 🎯 Overview
این مستند سیستم تایپوگرافی و فونت‌های مورد استفاده در پروژه DataSave را شرح می‌دهد. شامل پیاده‌سازی فونت‌های فارسی، سیستم تایپوگرافی Material 3، و بهترین شیوه‌ها برای خوانایی متن‌های دوزبانه (فارسی-انگلیسی) است.

## 📋 Table of Contents
- [سیستم فونت](#سیستم-فونت)
- [فونت Vazirmatn](#فونت-vazirmatn)
- [سیستم تایپوگرافی](#سیستم-تایپوگرافی)
- [پیاده‌سازی Flutter](#پیاده‌سازی-flutter)
- [استایل‌های متنی](#استایل‌های-متنی)
- [خوانایی و دسترسی‌پذیری](#خوانایی-و-دسترسی‌پذیری)
- [نمونه‌های کاربردی](#نمونه‌های-کاربردی)

## 🔤 سیستم فونت

### فونت‌های اصلی پروژه
```yaml
Primary Fonts:
  Persian/Farsi:
    - Font Family: Vazirmatn
    - Designer: صابر راستی کردستانی
    - License: SIL Open Font License
    - Weights: 100-900 (9 weights)
    - Format: Variable Font (TTF)
    
  English/Latin:
    - Font Family: Vazirmatn (Latin subset)
    - Backup: Roboto, San Francisco Pro
    - System Fallback: system-ui, -apple-system
    
  Monospace:
    - Font Family: JetBrains Mono
    - Usage: کد، اعداد، داده‌های خام
    - Weights: 400, 500, 700
```

### هرم فونت‌ها
```dart
// lib/core/theme/font_hierarchy.dart

class AppFonts {
  // فونت اصلی
  static const String primary = 'Vazirmatn';
  
  // فونت monospace
  static const String monospace = 'JetBrainsMono';
  
  // فولبک فونت‌ها
  static const List<String> fallbackFonts = [
    'Vazirmatn',
    'Tahoma',
    'Arial',
    'sans-serif',
  ];
  
  // وزن‌های فونت Vazirmatn
  static const FontWeight thin = FontWeight.w100;
  static const FontWeight extraLight = FontWeight.w200;
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
  static const FontWeight black = FontWeight.w900;
  
  // سایزهای فونت
  static const double sizeCaption = 10;
  static const double sizeOverline = 10;
  static const double sizeBody2 = 12;
  static const double sizeBody1 = 14;
  static const double sizeSubtitle2 = 14;
  static const double sizeButton = 14;
  static const double sizeSubtitle1 = 16;
  static const double sizeHeadline6 = 18;
  static const double sizeHeadline5 = 20;
  static const double sizeHeadline4 = 24;
  static const double sizeHeadline3 = 32;
  static const double sizeHeadline2 = 45;
  static const double sizeHeadline1 = 57;
}
```

## 🎨 فونت Vazirmatn

### ویژگی‌های Vazirmatn
```yaml
Vazirmatn Features:
  Language Support:
    - فارسی کامل
    - عربی
    - اردو
    - کردی
    - انگلیسی (Latin)
    
  Typography Features:
    - OpenType Features support
    - Contextual Alternates
    - Stylistic Sets
    - Kerning optimization
    - Right-to-left (RTL) support
    
  Technical Specs:
    - Variable Font Technology
    - WOFF2 format for web
    - TTF format for mobile
    - Complete Persian Unicode coverage
    
  Design Characteristics:
    - سادگی و خوانایی بالا
    - مناسب برای متن‌های طولانی
    - سازگاری با صفحات نمایش مختلف
    - بهینه‌سازی برای رابط‌های کاربری
```

### نصب و پیکربندی Vazirmatn
```yaml
# pubspec.yaml

flutter:
  fonts:
    - family: Vazirmatn
      fonts:
        - asset: assets/fonts/Vazirmatn-Thin.ttf
          weight: 100
        - asset: assets/fonts/Vazirmatn-ExtraLight.ttf
          weight: 200
        - asset: assets/fonts/Vazirmatn-Light.ttf
          weight: 300
        - asset: assets/fonts/Vazirmatn-Regular.ttf
          weight: 400
        - asset: assets/fonts/Vazirmatn-Medium.ttf
          weight: 500
        - asset: assets/fonts/Vazirmatn-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Vazirmatn-Bold.ttf
          weight: 700
        - asset: assets/fonts/Vazirmatn-ExtraBold.ttf
          weight: 800
        - asset: assets/fonts/Vazirmatn-Black.ttf
          weight: 900
    
    - family: JetBrainsMono
      fonts:
        - asset: assets/fonts/JetBrainsMono-Regular.ttf
          weight: 400
        - asset: assets/fonts/JetBrainsMono-Medium.ttf
          weight: 500
        - asset: assets/fonts/JetBrainsMono-Bold.ttf
          weight: 700
```

### تنظیمات وب
```css
/* web/vazirmatn.css */

@font-face {
  font-family: 'Vazirmatn';
  font-style: normal;
  font-weight: 100 900;
  font-display: swap;
  src: url('/assets/fonts/Vazirmatn-Variable.woff2') format('woff2');
}

/* بهینه‌سازی برای فونت‌های RTL */
.rtl-text {
  font-family: 'Vazirmatn', 'Tahoma', Arial, sans-serif;
  direction: rtl;
  text-align: right;
  font-feature-settings: "kern" 1, "liga" 1;
}

/* بهینه‌سازی برای فونت‌های LTR */
.ltr-text {
  font-family: 'Vazirmatn', 'Roboto', Arial, sans-serif;
  direction: ltr;
  text-align: left;
}

/* فونت monospace */
.monospace-text {
  font-family: 'JetBrains Mono', 'Courier New', monospace;
  font-feature-settings: "liga" 1, "calt" 1;
}

/* بهینه‌سازی رندرینگ */
.optimized-text {
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-rendering: optimizeLegibility;
  font-kerning: auto;
  font-variant-ligatures: common-ligatures;
}
```

## 📝 سیستم تایپوگرافی

### سیستم Material 3
```dart
// lib/core/theme/typography.dart

import 'package:flutter/material.dart';
import 'package:datasave/core/theme/font_hierarchy.dart';

class AppTypography {
  // TextTheme کامل براساس Material 3
  static TextTheme get material3TextTheme {
    return TextTheme(
      // Display styles - برای عناوین بزرگ
      displayLarge: TextStyle(
        fontFamily: AppFonts.primary,
        fontSize: 57,
        fontWeight: AppFonts.regular,
        letterSpacing: -0.25,
        height: 1.12,
      ),
      displayMedium: TextStyle(
        fontFamily: AppFonts.primary,
        fontSize: 45,
        fontWeight: AppFonts.regular,
        letterSpacing: 0,
        height: 1.16,
      ),
      displaySmall: TextStyle(
        fontFamily: AppFonts.primary,
        fontSize: 36,
        fontWeight: AppFonts.regular,
        letterSpacing: 0,
        height: 1.22,
      ),

      // Headline styles - برای عناوین
      headlineLarge: TextStyle(
        fontFamily: AppFonts.primary,
        fontSize: 32,
        fontWeight: AppFonts.regular,
        letterSpacing: 0,
        height: 1.25,
      ),
      headlineMedium: TextStyle(
        fontFamily: AppFonts.primary,
        fontSize: 28,
        fontWeight: AppFonts.regular,
        letterSpacing: 0,
        height: 1.29,
      ),
      headlineSmall: TextStyle(
        fontFamily: AppFonts.primary,
        fontSize: 24,
        fontWeight: AppFonts.regular,
        letterSpacing: 0,
        height: 1.33,
      ),

      // Title styles - برای عناوین متوسط
      titleLarge: TextStyle(
        fontFamily: AppFonts.primary,
        fontSize: 22,
        fontWeight: AppFonts.medium,
        letterSpacing: 0,
        height: 1.27,
      ),
      titleMedium: TextStyle(
        fontFamily: AppFonts.primary,
        fontSize: 16,
        fontWeight: AppFonts.medium,
        letterSpacing: 0.15,
        height: 1.50,
      ),
      titleSmall: TextStyle(
        fontFamily: AppFonts.primary,
        fontSize: 14,
        fontWeight: AppFonts.medium,
        letterSpacing: 0.1,
        height: 1.43,
      ),

      // Body styles - برای متن اصلی
      bodyLarge: TextStyle(
        fontFamily: AppFonts.primary,
        fontSize: 16,
        fontWeight: AppFonts.regular,
        letterSpacing: 0.5,
        height: 1.50,
      ),
      bodyMedium: TextStyle(
        fontFamily: AppFonts.primary,
        fontSize: 14,
        fontWeight: AppFonts.regular,
        letterSpacing: 0.25,
        height: 1.43,
      ),
      bodySmall: TextStyle(
        fontFamily: AppFonts.primary,
        fontSize: 12,
        fontWeight: AppFonts.regular,
        letterSpacing: 0.4,
        height: 1.33,
      ),

      // Label styles - برای برچسب‌ها و دکمه‌ها
      labelLarge: TextStyle(
        fontFamily: AppFonts.primary,
        fontSize: 14,
        fontWeight: AppFonts.medium,
        letterSpacing: 0.1,
        height: 1.43,
      ),
      labelMedium: TextStyle(
        fontFamily: AppFonts.primary,
        fontSize: 12,
        fontWeight: AppFonts.medium,
        letterSpacing: 0.5,
        height: 1.33,
      ),
      labelSmall: TextStyle(
        fontFamily: AppFonts.primary,
        fontSize: 11,
        fontWeight: AppFonts.medium,
        letterSpacing: 0.5,
        height: 1.45,
      ),
    );
  }

  // استایل‌های سفارشی
  static TextStyle get h1 => material3TextTheme.displayLarge!;
  static TextStyle get h2 => material3TextTheme.displayMedium!;
  static TextStyle get h3 => material3TextTheme.displaySmall!;
  static TextStyle get h4 => material3TextTheme.headlineLarge!;
  static TextStyle get h5 => material3TextTheme.headlineMedium!;
  static TextStyle get h6 => material3TextTheme.headlineSmall!;
  
  static TextStyle get subtitle1 => material3TextTheme.titleLarge!;
  static TextStyle get subtitle2 => material3TextTheme.titleMedium!;
  
  static TextStyle get body1 => material3TextTheme.bodyLarge!;
  static TextStyle get body2 => material3TextTheme.bodyMedium!;
  
  static TextStyle get caption => material3TextTheme.bodySmall!;
  static TextStyle get overline => material3TextTheme.labelSmall!;
  
  static TextStyle get button => material3TextTheme.labelLarge!;

  // استایل‌های مخصوص فارسی
  static TextStyle get persianTitle => TextStyle(
    fontFamily: AppFonts.primary,
    fontSize: 20,
    fontWeight: AppFonts.semiBold,
    letterSpacing: 0,
    height: 1.6,
  );
  
  static TextStyle get persianBody => TextStyle(
    fontFamily: AppFonts.primary,
    fontSize: 14,
    fontWeight: AppFonts.regular,
    letterSpacing: 0,
    height: 1.8,
  );
  
  static TextStyle get persianCaption => TextStyle(
    fontFamily: AppFonts.primary,
    fontSize: 12,
    fontWeight: AppFonts.regular,
    letterSpacing: 0,
    height: 1.5,
  );
  
  // فونت monospace
  static TextStyle get code => TextStyle(
    fontFamily: AppFonts.monospace,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.4,
  );
  
  static TextStyle get numbers => TextStyle(
    fontFamily: AppFonts.monospace,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.2,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}
```

### استایل‌های حالت‌محور
```dart
// lib/core/theme/text_styles.dart

import 'package:flutter/material.dart';
import 'package:datasave/core/theme/typography.dart';

class AppTextStyles {
  // متدهای کمکی برای تغییر رنگ
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }
  
  // متدهای کمکی برای تغییر وزن
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }
  
  // متدهای کمکی برای تغییر اندازه
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }
  
  // استایل‌های حالتی
  static class StateStyles {
    // استایل‌های وضعیت
    static TextStyle get success => AppTypography.body1.copyWith(
      color: Colors.green.shade700,
      fontWeight: AppFonts.medium,
    );
    
    static TextStyle get error => AppTypography.body1.copyWith(
      color: Colors.red.shade700,
      fontWeight: AppFonts.medium,
    );
    
    static TextStyle get warning => AppTypography.body1.copyWith(
      color: Colors.orange.shade700,
      fontWeight: AppFonts.medium,
    );
    
    static TextStyle get info => AppTypography.body1.copyWith(
      color: Colors.blue.shade700,
      fontWeight: AppFonts.medium,
    );
    
    // استایل‌های تعاملی
    static TextStyle get link => AppTypography.body1.copyWith(
      color: Colors.blue.shade600,
      decoration: TextDecoration.underline,
      fontWeight: AppFonts.medium,
    );
    
    static TextStyle get linkHover => AppTypography.body1.copyWith(
      color: Colors.blue.shade800,
      decoration: TextDecoration.underline,
      fontWeight: AppFonts.semiBold,
    );
    
    // استایل‌های غیرفعال
    static TextStyle get disabled => AppTypography.body1.copyWith(
      color: Colors.grey.shade500,
    );
    
    static TextStyle get muted => AppTypography.body2.copyWith(
      color: Colors.grey.shade600,
    );
  }
  
  // استایل‌های مخصوص کامپوننت
  static class ComponentStyles {
    // استایل‌های AppBar
    static TextStyle get appBarTitle => AppTypography.titleLarge.copyWith(
      fontWeight: AppFonts.semiBold,
    );
    
    // استایل‌های Card
    static TextStyle get cardTitle => AppTypography.titleMedium.copyWith(
      fontWeight: AppFonts.semiBold,
    );
    
    static TextStyle get cardSubtitle => AppTypography.bodyMedium.copyWith(
      color: Colors.grey.shade600,
    );
    
    // استایل‌های Button
    static TextStyle get buttonText => AppTypography.button.copyWith(
      fontWeight: AppFonts.semiBold,
    );
    
    // استایل‌های TextField
    static TextStyle get inputText => AppTypography.bodyLarge;
    
    static TextStyle get inputLabel => AppTypography.bodyMedium.copyWith(
      color: Colors.grey.shade700,
    );
    
    static TextStyle get inputHint => AppTypography.bodyMedium.copyWith(
      color: Colors.grey.shade500,
    );
    
    static TextStyle get inputError => AppTypography.bodySmall.copyWith(
      color: Colors.red.shade700,
    );
    
    // استایل‌های SnackBar
    static TextStyle get snackBarContent => AppTypography.bodyMedium.copyWith(
      color: Colors.white,
      fontWeight: AppFonts.medium,
    );
  }
  
  // استایل‌های تخصصی
  static class SpecialStyles {
    // استایل اعداد فارسی
    static TextStyle get persianNumbers => AppTypography.numbers.copyWith(
      fontFamily: AppFonts.primary,
    );
    
    // استایل تاریخ و ساعت
    static TextStyle get dateTime => AppTypography.bodyMedium.copyWith(
      fontFamily: AppFonts.monospace,
      fontWeight: AppFonts.medium,
    );
    
    // استایل کد و متغیرها
    static TextStyle get codeInline => AppTypography.bodyMedium.copyWith(
      fontFamily: AppFonts.monospace,
      backgroundColor: Colors.grey.shade100,
      color: Colors.purple.shade800,
    );
    
    // استایل نقل‌قول
    static TextStyle get quote => AppTypography.bodyLarge.copyWith(
      fontStyle: FontStyle.italic,
      color: Colors.grey.shade700,
      height: 1.6,
    );
    
    // استایل تأکیدی
    static TextStyle get emphasis => AppTypography.bodyMedium.copyWith(
      fontWeight: AppFonts.bold,
      color: Colors.black87,
    );
  }
}
```

## 🎨 پیاده‌سازی Flutter

### کنترل‌کننده تم متن
```dart
// lib/core/theme/text_theme_controller.dart

import 'package:flutter/material.dart';
import 'package:datasave/core/theme/typography.dart';

class TextThemeController {
  // ایجاد TextTheme براساس ColorScheme
  static TextTheme createTextTheme(ColorScheme colorScheme) {
    return AppTypography.material3TextTheme.apply(
      displayColor: colorScheme.onSurface,
      bodyColor: colorScheme.onSurface,
      decorationColor: colorScheme.primary,
    );
  }
  
  // سفارشی‌سازی TextTheme برای تم تاریک
  static TextTheme createDarkTextTheme(ColorScheme colorScheme) {
    return AppTypography.material3TextTheme.apply(
      displayColor: colorScheme.onSurface,
      bodyColor: colorScheme.onSurface,
      decorationColor: colorScheme.primary,
    ).copyWith(
      // تنظیمات خاص تم تاریک
      bodyLarge: AppTypography.body1.copyWith(
        color: colorScheme.onSurface,
        height: 1.6, // ارتفاع خط بیشتر برای خوانایی بهتر در تم تاریک
      ),
      bodyMedium: AppTypography.body2.copyWith(
        color: colorScheme.onSurface.withOpacity(0.8),
        height: 1.5,
      ),
    );
  }
  
  // اعمال font scaling
  static TextTheme scaleTextTheme(TextTheme textTheme, double scaleFactor) {
    return textTheme.copyWith(
      displayLarge: textTheme.displayLarge?.copyWith(
        fontSize: (textTheme.displayLarge?.fontSize ?? 57) * scaleFactor,
      ),
      displayMedium: textTheme.displayMedium?.copyWith(
        fontSize: (textTheme.displayMedium?.fontSize ?? 45) * scaleFactor,
      ),
      displaySmall: textTheme.displaySmall?.copyWith(
        fontSize: (textTheme.displaySmall?.fontSize ?? 36) * scaleFactor,
      ),
      headlineLarge: textTheme.headlineLarge?.copyWith(
        fontSize: (textTheme.headlineLarge?.fontSize ?? 32) * scaleFactor,
      ),
      headlineMedium: textTheme.headlineMedium?.copyWith(
        fontSize: (textTheme.headlineMedium?.fontSize ?? 28) * scaleFactor,
      ),
      headlineSmall: textTheme.headlineSmall?.copyWith(
        fontSize: (textTheme.headlineSmall?.fontSize ?? 24) * scaleFactor,
      ),
      titleLarge: textTheme.titleLarge?.copyWith(
        fontSize: (textTheme.titleLarge?.fontSize ?? 22) * scaleFactor,
      ),
      titleMedium: textTheme.titleMedium?.copyWith(
        fontSize: (textTheme.titleMedium?.fontSize ?? 16) * scaleFactor,
      ),
      titleSmall: textTheme.titleSmall?.copyWith(
        fontSize: (textTheme.titleSmall?.fontSize ?? 14) * scaleFactor,
      ),
      bodyLarge: textTheme.bodyLarge?.copyWith(
        fontSize: (textTheme.bodyLarge?.fontSize ?? 16) * scaleFactor,
      ),
      bodyMedium: textTheme.bodyMedium?.copyWith(
        fontSize: (textTheme.bodyMedium?.fontSize ?? 14) * scaleFactor,
      ),
      bodySmall: textTheme.bodySmall?.copyWith(
        fontSize: (textTheme.bodySmall?.fontSize ?? 12) * scaleFactor,
      ),
      labelLarge: textTheme.labelLarge?.copyWith(
        fontSize: (textTheme.labelLarge?.fontSize ?? 14) * scaleFactor,
      ),
      labelMedium: textTheme.labelMedium?.copyWith(
        fontSize: (textTheme.labelMedium?.fontSize ?? 12) * scaleFactor,
      ),
      labelSmall: textTheme.labelSmall?.copyWith(
        fontSize: (textTheme.labelSmall?.fontSize ?? 11) * scaleFactor,
      ),
    );
  }
}
```

### ویجت تنظیم فونت
```dart
// lib/core/widgets/text_scale_widget.dart

import 'package:flutter/material.dart';
import 'package:datasave/core/theme/text_theme_controller.dart';

class TextScaleWidget extends StatefulWidget {
  final Widget child;
  final double? initialScale;
  
  const TextScaleWidget({
    Key? key,
    required this.child,
    this.initialScale = 1.0,
  }) : super(key: key);
  
  @override
  State<TextScaleWidget> createState() => _TextScaleWidgetState();
}

class _TextScaleWidgetState extends State<TextScaleWidget> {
  late double _textScaleFactor;
  
  @override
  void initState() {
    super.initState();
    _textScaleFactor = widget.initialScale ?? 1.0;
  }
  
  void updateTextScale(double scale) {
    setState(() {
      _textScaleFactor = scale.clamp(0.8, 2.0); // محدود کردن مقدار
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final originalTheme = Theme.of(context);
        final scaledTextTheme = TextThemeController.scaleTextTheme(
          originalTheme.textTheme,
          _textScaleFactor,
        );
        
        return Theme(
          data: originalTheme.copyWith(textTheme: scaledTextTheme),
          child: widget.child,
        );
      },
    );
  }
}

// استفاده از TextScaleWidget
class TextScaleSettings extends StatefulWidget {
  @override
  _TextScaleSettingsState createState() => _TextScaleSettingsState();
}

class _TextScaleSettingsState extends State<TextScaleSettings> {
  double _currentScale = 1.0;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'اندازه فونت',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Slider(
          value: _currentScale,
          min: 0.8,
          max: 2.0,
          divisions: 12,
          label: '${(_currentScale * 100).round()}%',
          onChanged: (value) {
            setState(() => _currentScale = value);
          },
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextScaleWidget(
            initialScale: _currentScale,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'نمونه متن فارسی',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: 8),
                Text(
                  'این نمونه‌ای از متن فارسی است که برای بررسی اندازه فونت استفاده می‌شود. با تغییر مقدار slider می‌توانید اندازه فونت را تنظیم کنید.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
```

## 👁️ خوانایی و دسترسی‌پذیری

### اصول خوانایی
```yaml
Readability Principles:
  Font Size:
    - حداقل اندازه: 14px برای متن اصلی
    - اندازه بهینه: 16px برای خوانایی مطلوب
    - حداکثر اندازه: 57px برای عناوین اصلی
    
  Line Height:
    - متن فارسی: 1.6-1.8
    - متن انگلیسی: 1.4-1.6
    - عناوین: 1.2-1.4
    
  Letter Spacing:
    - عناوین: -0.25px to 0.5px
    - متن اصلی: 0px to 0.5px
    - برچسب‌ها: 0.1px to 0.5px
    
  Color Contrast:
    - حداقل کنتراست: 4.5:1
    - کنتراست بهینه: 7:1
    - متن کوچک: حداقل 3:1
    
  Responsive Design:
    - اندازه فونت منطبق با اندازه صفحه
    - حفظ نسبت‌ها در دستگاه‌های مختلف
    - قابلیت تغییر اندازه توسط کاربر
```

### پیاده‌سازی دسترسی‌پذیری
```dart
// lib/core/accessibility/text_accessibility.dart

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

class AccessibleText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final String? semanticLabel;
  final bool isHeading;
  final bool isLiveRegion;
  final TextAlign? textAlign;
  
  const AccessibleText(
    this.text, {
    Key? key,
    this.style,
    this.semanticLabel,
    this.isHeading = false,
    this.isLiveRegion = false,
    this.textAlign,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? text,
      header: isHeading,
      liveRegion: isLiveRegion,
      child: Text(
        text,
        style: _getAccessibleStyle(context),
        textAlign: textAlign,
      ),
    );
  }
  
  TextStyle _getAccessibleStyle(BuildContext context) {
    final originalStyle = style ?? Theme.of(context).textTheme.bodyMedium!;
    
    // بررسی تنظیمات دسترسی‌پذیری سیستم
    final mediaQuery = MediaQuery.of(context);
    final textScaler = mediaQuery.textScaler;
    
    // اعمال تنظیمات دسترسی‌پذیری
    return originalStyle.copyWith(
      fontSize: originalStyle.fontSize! * textScaler.scale(1.0),
      // اطمینان از حداقل اندازه فونت
      fontSize: originalStyle.fontSize! < 14 ? 14 : originalStyle.fontSize,
      // افزایش ارتفاع خط برای خوانایی بهتر
      height: (originalStyle.height ?? 1.4) * 1.1,
    );
  }
}

// بررسی کنتراست رنگ
class ColorContrastChecker {
  // محاسبه نسبت کنتراست
  static double calculateContrast(Color foreground, Color background) {
    final foregroundLuminance = _calculateLuminance(foreground);
    final backgroundLuminance = _calculateLuminance(background);
    
    final lighter = math.max(foregroundLuminance, backgroundLuminance);
    final darker = math.min(foregroundLuminance, backgroundLuminance);
    
    return (lighter + 0.05) / (darker + 0.05);
  }
  
  // بررسی مطابقت با استانداردهای WCAG
  static bool meetsWCAGAA(Color foreground, Color background) {
    return calculateContrast(foreground, background) >= 4.5;
  }
  
  static bool meetsWCAGAAA(Color foreground, Color background) {
    return calculateContrast(foreground, background) >= 7.0;
  }
  
  // محاسبه luminance
  static double _calculateLuminance(Color color) {
    final r = _linearizeColorComponent(color.red / 255.0);
    final g = _linearizeColorComponent(color.green / 255.0);
    final b = _linearizeColorComponent(color.blue / 255.0);
    
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }
  
  static double _linearizeColorComponent(double component) {
    if (component <= 0.03928) {
      return component / 12.92;
    } else {
      return math.pow((component + 0.055) / 1.055, 2.4).toDouble();
    }
  }
}
```

## 📱 نمونه‌های کاربردی

### صفحه نمایش تایپوگرافی
```dart
// lib/presentation/screens/design_system/typography_showcase.dart

import 'package:flutter/material.dart';
import 'package:datasave/core/theme/typography.dart';
import 'package:datasave/core/theme/text_styles.dart';
import 'package:datasave/core/accessibility/text_accessibility.dart';

class TypographyShowcaseScreen extends StatelessWidget {
  const TypographyShowcaseScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تایپوگرافی و فونت‌ها'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildSection('عناوین اصلی', [
            _TextExample('Display Large', AppTypography.material3TextTheme.displayLarge!),
            _TextExample('Display Medium', AppTypography.material3TextTheme.displayMedium!),
            _TextExample('Display Small', AppTypography.material3TextTheme.displaySmall!),
          ]),
          
          _buildSection('عناوین', [
            _TextExample('Headline Large', AppTypography.material3TextTheme.headlineLarge!),
            _TextExample('Headline Medium', AppTypography.material3TextTheme.headlineMedium!),
            _TextExample('Headline Small', AppTypography.material3TextTheme.headlineSmall!),
          ]),
          
          _buildSection('عناوین فرعی', [
            _TextExample('Title Large', AppTypography.material3TextTheme.titleLarge!),
            _TextExample('Title Medium', AppTypography.material3TextTheme.titleMedium!),
            _TextExample('Title Small', AppTypography.material3TextTheme.titleSmall!),
          ]),
          
          _buildSection('متن اصلی', [
            _TextExample('Body Large - متن اصلی بزرگ برای خوانایی بهتر', AppTypography.material3TextTheme.bodyLarge!),
            _TextExample('Body Medium - متن معمولی برای محتوای اصلی', AppTypography.material3TextTheme.bodyMedium!),
            _TextExample('Body Small - متن کوچک برای توضیحات', AppTypography.material3TextTheme.bodySmall!),
          ]),
          
          _buildSection('برچسب‌ها', [
            _TextExample('Label Large', AppTypography.material3TextTheme.labelLarge!),
            _TextExample('Label Medium', AppTypography.material3TextTheme.labelMedium!),
            _TextExample('Label Small', AppTypography.material3TextTheme.labelSmall!),
          ]),
          
          _buildSection('فونت‌های مخصوص', [
            _TextExample('Persian Title - عنوان فارسی', AppTypography.persianTitle),
            _TextExample('Persian Body - متن فارسی', AppTypography.persianBody),
            _TextExample('Code - const example = "Hello World";', AppTypography.code),
            _TextExample('Numbers - ۱۲۳۴۵۶۷۸۹۰', AppTypography.numbers),
          ]),
          
          _buildSection('استایل‌های وضعیت', [
            _TextExample('Success - عملیات موفق', AppTextStyles.StateStyles.success),
            _TextExample('Error - خطا در عملیات', AppTextStyles.StateStyles.error),
            _TextExample('Warning - هشدار', AppTextStyles.StateStyles.warning),
            _TextExample('Info - اطلاعات', AppTextStyles.StateStyles.info),
            _TextExample('Link - لینک قابل کلیک', AppTextStyles.StateStyles.link),
          ]),
          
          _buildSection('دسترسی‌پذیری', [
            AccessibleText(
              'این متن دارای قابلیت دسترسی‌پذیری است',
              semanticLabel: 'نمونه متن قابل دسترس',
              isHeading: false,
            ),
            SizedBox(height: 12),
            AccessibleText(
              'عنوان با دسترسی‌پذیری',
              style: Theme.of(context).textTheme.headlineSmall,
              semanticLabel: 'این عنوان با دسترسی‌پذیری است',
              isHeading: true,
            ),
          ]),
        ],
      ),
    );
  }
  
  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Text(
            title,
            style: AppTextStyles.ComponentStyles.cardTitle,
          ),
        ),
        ...children,
        Divider(height: 32),
      ],
    );
  }
}

class _TextExample extends StatelessWidget {
  final String text;
  final TextStyle style;
  
  const _TextExample(this.text, this.style);
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text, style: style),
          SizedBox(height: 4),
          Text(
            'Size: ${style.fontSize?.toStringAsFixed(0)}px, Weight: ${style.fontWeight?.toString().split('.').last}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
              fontFamily: 'monospace',
            ),
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }
}
```

## 🔄 Related Documentation
- [Material Design 3](material-design-3.md)
- [Persian RTL Implementation](../04-Flutter-Frontend/persian-rtl-implementation.md)
- [Color Scheme](color-scheme.md)
- [UI Components Library](ui-components-library.md)

---
*Last updated: 2025-09-01*  
*File: docs/06-UI-UX-Design/typography-fonts.md*