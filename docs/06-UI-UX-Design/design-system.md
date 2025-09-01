# سیستم طراحی - Design System

## 📊 Document Information
- **Created:** 2025-01-09
- **Last Updated:** 2025-01-09
- **Version:** 1.0
- **Maintainer:** DataSave Development Team
- **Related Files:** `/lib/core/theme/`, `/web/vazirmatn.css`

## 🎯 Overview
مستندات کامل سیستم طراحی DataSave بر اساس Material Design 3 با تمرکز بر Persian RTL و فرهنگ ایرانی.

## 📋 Table of Contents
- [فلسفه طراحی](#فلسفه-طراحی)
- [رنگ‌ها و پالت](#رنگها-و-پالت)
- [تایپوگرافی و فونت‌ها](#تایپوگرافی-و-فونتها)
- [فضای خالی و اندازه‌گیری](#فضای-خالی-و-اندازهگیری)
- [آیکون‌ها و تصاویر](#آیکونها-و-تصاویر)
- [اجزای رابط کاربری](#اجزای-رابط-کاربری)

## 🎨 فلسفه طراحی - Design Philosophy

### Material Design 3 Persian Adaptation
```yaml
Design Principles:
  - Persian-First Design: طراحی اولیه برای فارسی
  - Material You Integration: رنگ‌های dynamic و personal
  - Cultural Sensitivity: انطباق با فرهنگ ایرانی
  - Accessibility First: دسترسی برای همه کاربران
  - Performance Optimized: بهینه‌سازی عملکرد

Visual Language:
  - Clean and Modern: تمیز و مدرن
  - Purposeful Simplicity: سادگی هدفمند  
  - Consistent Patterns: الگوهای منسجم
  - Contextual Depth: عمق متناسب با محتوا
  - Expressive Typography: تایپوگرافی بیانگر
```

### Cultural Design Considerations
```yaml
Persian UI Patterns:
  - Right-to-Left Layout: چیدمان راست به چپ
  - Persian Number System: اعداد فارسی (۰-۹)
  - Cultural Color Preferences: رنگ‌های مناسب فرهنگ
  - Local Icon Adaptations: آیکون‌های بومی
  - Persian Date System: تقویم شمسی

Accessibility Features:
  - High Contrast Options: تباین بالا
  - Large Text Support: پشتیبانی متن بزرگ
  - Screen Reader Friendly: سازگار با صفحه‌خوان
  - Keyboard Navigation: ناوبری با کیبورد
  - Color Blind Support: پشتیبانی رنگ‌کوری
```

## 🎭 رنگ‌ها و پالت - Colors & Palette

### Primary Color Palette
```dart
// Primary Colors - رنگ‌های اصلی
static const Color primaryColor = Color(0xFF2196F3);      // آبی اصلی
static const Color primaryVariant = Color(0xFF1976D2);    // آبی تیره
static const Color primaryLight = Color(0xFFBBDEFB);      // آبی روشن

// Secondary Colors - رنگ‌های ثانویه  
static const Color secondaryColor = Color(0xFF03DAC6);    // فیروزه‌ای
static const Color secondaryVariant = Color(0xFF00BFA5); // فیروزه‌ای تیره
static const Color secondaryLight = Color(0xFFB2DFDB);   // فیروزه‌ای روشن
```

### Semantic Colors
```dart
// Status Colors - رنگ‌های وضعیت
static const Color successColor = Color(0xFF4CAF50);      // سبز موفقیت
static const Color warningColor = Color(0xFFFF9800);      // نارنجی هشدار
static const Color errorColor = Color(0xFFB00020);        // قرمز خطا
static const Color infoColor = Color(0xFF2196F3);         // آبی اطلاعات

// Text Colors - رنگ‌های متن
static const Color textPrimary = Color(0xFF212121);       // متن اصلی
static const Color textSecondary = Color(0xFF757575);     // متن ثانویه
static const Color textDisabled = Color(0xFFBDBDBD);      // متن غیرفعال
static const Color textHint = Color(0xFF9E9E9E);          // متن راهنما
```

### Background Colors
```dart
// Surface Colors - رنگ‌های سطح
static const Color backgroundColor = Color(0xFFF5F5F5);   // پس‌زمینه اصلی
static const Color surfaceColor = Color(0xFFFFFFFF);      // سطح کارت‌ها
static const Color surfaceVariant = Color(0xFFFAFAFA);    // تنوع سطح
static const Color outline = Color(0xFFE0E0E0);           // خط‌های حاشیه

// Persian Cultural Colors - رنگ‌های فرهنگی ایرانی
static const Color persianBlue = Color(0xFF1976D2);       // آبی ایرانی
static const Color persianGreen = Color(0xFF388E3C);      // سبز ایرانی  
static const Color persianRed = Color(0xFFD32F2F);        // قرمز ایرانی
```

### Color Usage Guidelines
```yaml
Primary Color Usage:
  - App Bar و Navigation
  - دکمه‌های اصلی (Primary Buttons)
  - لینک‌ها و عناصر قابل کلیک
  - Progress indicators
  - Selected states

Secondary Color Usage:
  - دکمه‌های ثانویه (Secondary Buttons)
  - Floating Action Buttons
  - Toggle switches
  - اکسنت‌های UI
  - Highlighting elements

Status Colors Usage:
  - Success: تایید، تکمیل، موفقیت
  - Warning: هشدار، توجه، احتیاط
  - Error: خطا، ناموفق، مشکل
  - Info: اطلاعات، راهنما، توضیح
```

### Dark Mode Palette
```dart
// Dark Theme Colors - رنگ‌های تم تیره
static const Color darkPrimary = Color(0xFF90CAF9);
static const Color darkSecondary = Color(0xFF80CBC4);
static const Color darkBackground = Color(0xFF121212);
static const Color darkSurface = Color(0xFF1E1E1E);
static const Color darkTextPrimary = Color(0xFFFFFFFF);
static const Color darkTextSecondary = Color(0xFFB3B3B3);
```

## 📝 تایپوگرافی و فونت‌ها - Typography & Fonts

### Persian Font System
```yaml
Primary Font: Vazirmatn
  - Designer: صابر راستی‌کردار
  - Type: Sans-serif
  - Weights: Light (300), Regular (400), Medium (500), Bold (700)
  - Language: فارسی، عربی، اردو، کردی
  - Features: Contextual alternates, Persian digits

Fallback Fonts:
  - Noto Sans Arabic
  - Noto Sans  
  - Tahoma
  - Arial

Font Loading:
  - Local files: /web/fonts/
  - CSS preload: vazirmatn.css
  - WOFF2 format: بهینه‌سازی حجم
```

### Typography Scale
```dart
// Display Styles - استایل‌های نمایشی
displayLarge:   57sp / 64sp line height / Light (300)
displayMedium:  45sp / 52sp line height / Regular (400)
displaySmall:   36sp / 44sp line height / Regular (400)

// Headline Styles - استایل‌های سرتیتر
headlineLarge:  32sp / 40sp line height / Regular (400)
headlineMedium: 28sp / 36sp line height / Regular (400)
headlineSmall:  24sp / 32sp line height / Regular (400)

// Title Styles - استایل‌های عنوان
titleLarge:     22sp / 28sp line height / Medium (500)
titleMedium:    16sp / 24sp line height / Medium (500)
titleSmall:     14sp / 20sp line height / Medium (500)

// Body Styles - استایل‌های متن
bodyLarge:      16sp / 24sp line height / Regular (400)
bodyMedium:     14sp / 20sp line height / Regular (400)
bodySmall:      12sp / 16sp line height / Regular (400)

// Label Styles - استایل‌های برچسب
labelLarge:     14sp / 20sp line height / Medium (500)
labelMedium:    12sp / 16sp line height / Medium (500)
labelSmall:     11sp / 16sp line height / Medium (500)
```

### Persian Typography Rules
```yaml
Text Direction: RTL (راست به چپ)
Line Height: 1.4x - 1.6x برای خوانایی بهتر
Letter Spacing: حداقل برای حفظ اتصال حروف
Word Spacing: استاندارد Unicode
Number System: ۰۱۲۳۴۵۶۷۸۹ (Persian digits)
Date Format: ۱۴۰۳/۱۰/۱۹ (Solar Hijri)

Persian Punctuation:
  - Comma: ، (Persian comma)
  - Question: ؟ (Arabic question mark)  
  - Semicolon: ؛ (Arabic semicolon)
  - Percent: ٪ (Arabic percent)
```

### Font Implementation
```dart
// Persian Font Class
class PersianFonts {
  static const String fontFamily = 'Vazirmatn';
  
  static const List<String> fontFamilyFallback = [
    'Vazirmatn',
    'Noto Sans Arabic',
    'Noto Sans',
    'Tahoma',
    'Arial',
  ];

  // Page Title
  static const TextStyle pageTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.33,
  );

  // Card Title  
  static const TextStyle cardTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 1.28,
  );

  // Body Text
  static const TextStyle bodyText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );

  // Button Text
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  // Caption
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );
}
```

### Persian Number System
```dart
class PersianNumbers {
  static const Map<String, String> englishToPersian = {
    '0': '۰', '1': '۱', '2': '۲', '3': '۳', '4': '۴',
    '5': '۵', '6': '۶', '7': '۷', '8': '۸', '9': '۹',
  };

  static String toPersian(String input) {
    String result = input;
    englishToPersian.forEach((en, fa) {
      result = result.replaceAll(en, fa);
    });
    return result;
  }

  static String formatNumber(int number) {
    final formatter = NumberFormat('#,###', 'fa');
    return toPersian(formatter.format(number));
  }
}
```

## 📏 فضای خالی و اندازه‌گیری - Spacing & Sizing

### Spacing System (8dp Grid)
```yaml
Base Unit: 8dp

Spacing Scale:
  xs: 4dp    (0.5 × base)
  sm: 8dp    (1 × base)  
  md: 16dp   (2 × base)
  lg: 24dp   (3 × base)
  xl: 32dp   (4 × base)
  2xl: 40dp  (5 × base)
  3xl: 48dp  (6 × base)

Semantic Spacing:
  Component Padding: 16dp
  Card Margin: 16dp
  Button Padding: 24dp horizontal, 12dp vertical
  List Item Height: 56dp
  App Bar Height: 56dp
  Bottom Nav Height: 80dp
```

### Layout Grid
```yaml
Mobile Layout:
  - Margins: 16dp
  - Gutters: 16dp  
  - Columns: 4
  - Max Width: 100%

Tablet Layout:
  - Margins: 24dp
  - Gutters: 24dp
  - Columns: 8
  - Max Width: 100%

Desktop Layout:
  - Margins: 32dp
  - Gutters: 32dp
  - Columns: 12
  - Max Width: 1200dp
```

### Component Sizing
```dart
// Button Sizes
class ButtonSizes {
  static const double small = 32;     // کوچک
  static const double medium = 40;    // متوسط  
  static const double large = 48;     // بزرگ
}

// Icon Sizes  
class IconSizes {
  static const double small = 16;     // آیکون کوچک
  static const double medium = 24;    // آیکون متوسط
  static const double large = 32;     // آیکون بزرگ
  static const double xlarge = 48;    // آیکون خیلی بزرگ
}

// Card Sizes
class CardSizes {
  static const double borderRadius = 12;  // انحنای گوشه
  static const double elevation = 2;      // سایه
  static const double padding = 16;       // فاصله داخلی
}
```

## 🖼️ آیکون‌ها و تصاویر - Icons & Images

### Icon System
```yaml
Icon Family: Material Design Icons
Style: Outlined (پیش‌فرض), Filled, Round, Sharp
Format: Vector (SVG), Icon Font
Sizes: 16dp, 24dp, 32dp, 48dp
Colors: تطبیق با theme colors

Persian Icon Adaptations:
  - Navigation icons: جهت RTL
  - Arrow directions: معکوس برای فارسی
  - Text alignment icons: راست‌چین پیش‌فرض
  - Calendar icons: تقویم شمسی
```

### Icon Usage Guidelines
```dart
// Icon Usage Examples
class AppIcons {
  // Navigation
  static const IconData menu = Icons.menu;
  static const IconData back = Icons.arrow_back;
  static const IconData forward = Icons.arrow_forward;
  
  // Actions
  static const IconData add = Icons.add;
  static const IconData edit = Icons.edit;
  static const IconData delete = Icons.delete;
  static const IconData save = Icons.save;
  
  // Status
  static const IconData success = Icons.check_circle;
  static const IconData warning = Icons.warning;
  static const IconData error = Icons.error;
  static const IconData info = Icons.info;
  
  // Persian Specific
  static const IconData persianCalendar = Icons.calendar_today;
  static const IconData persianKeyboard = Icons.keyboard;
}
```

### Image Guidelines
```yaml
Image Formats:
  - PNG: UI elements, icons
  - SVG: Vector graphics, logos
  - WebP: Photos, complex images
  - AVIF: Next-gen format (fallback)

Responsive Images:
  - 1x: Base resolution
  - 2x: High DPI (Retina)
  - 3x: Ultra high DPI

Loading Strategy:
  - Progressive loading
  - Placeholder images
  - Lazy loading
  - Error fallbacks

Persian Image Considerations:
  - RTL layouts in images
  - Persian text in graphics
  - Cultural appropriateness
  - Local context relevance
```

## 🎯 اجزای رابط کاربری - UI Components

### Button Styles
```dart
// Primary Button
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    textStyle: PersianFonts.button,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    elevation: 2,
  ),
  child: Text('ارسال'),
)

// Secondary Button
OutlinedButton(
  style: OutlinedButton.styleFrom(
    foregroundColor: AppColors.primaryColor,
    side: BorderSide(color: AppColors.primaryColor),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    textStyle: PersianFonts.button,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  child: Text('انصراف'),
)

// Text Button
TextButton(
  style: TextButton.styleFrom(
    foregroundColor: AppColors.primaryColor,
    textStyle: PersianFonts.button,
  ),
  child: Text('بیشتر'),
)
```

### Card Styles
```dart
// Standard Card
Card(
  elevation: 2,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('عنوان کارت', style: PersianFonts.cardTitle),
        const SizedBox(height: 8),
        Text('محتوای کارت', style: PersianFonts.bodyText),
      ],
    ),
  ),
)

// Statistics Card
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12),
    gradient: LinearGradient(
      colors: [
        AppColors.primaryColor.withOpacity(0.1),
        AppColors.primaryColor.withOpacity(0.05),
      ],
    ),
  ),
  child: Column(
    children: [
      Icon(Icons.analytics, color: AppColors.primaryColor),
      Text('۱,۲۳۴', style: PersianFonts.headlineMedium),
      Text('کل کاربران', style: PersianFonts.caption),
    ],
  ),
)
```

### Form Elements
```dart
// Persian TextField
TextField(
  textDirection: TextDirection.rtl,
  style: PersianFonts.bodyText,
  decoration: InputDecoration(
    labelText: 'نام کاربری',
    hintText: 'نام خود را وارد کنید',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    filled: true,
    fillColor: Colors.grey.shade50,
  ),
)

// Persian Dropdown
DropdownButtonFormField<String>(
  decoration: InputDecoration(
    labelText: 'انتخاب کنید',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  items: [
    DropdownMenuItem(value: '1', child: Text('گزینه یک')),
    DropdownMenuItem(value: '2', child: Text('گزینه دو')),
  ],
  onChanged: (value) {},
)

// Persian Checkbox
CheckboxListTile(
  title: Text('موافقت با قوانین', style: PersianFonts.bodyText),
  value: true,
  onChanged: (value) {},
  controlAffinity: ListTileControlAffinity.leading,
)
```

### Navigation Elements
```dart
// Persian AppBar
AppBar(
  title: Text('فرم‌ساز هوشمند', style: PersianFonts.pageTitle),
  centerTitle: true,
  backgroundColor: AppColors.primaryColor,
  foregroundColor: Colors.white,
  elevation: 0,
)

// Bottom Navigation
BottomNavigationBar(
  type: BottomNavigationBarType.fixed,
  selectedLabelStyle: PersianFonts.caption,
  unselectedLabelStyle: PersianFonts.caption,
  items: [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'خانه',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.settings),
      label: 'تنظیمات',
    ),
  ],
)

// Navigation Drawer
Drawer(
  child: ListView(
    children: [
      DrawerHeader(
        decoration: BoxDecoration(color: AppColors.primaryColor),
        child: Text('DataSave', style: PersianFonts.headlineMedium.copyWith(color: Colors.white)),
      ),
      ListTile(
        leading: Icon(Icons.dashboard),
        title: Text('داشبورد', style: PersianFonts.bodyText),
        onTap: () {},
      ),
    ],
  ),
)
```

## 📱 Responsive Design

### Breakpoints
```yaml
Mobile: 0dp - 599dp
  - Single column layout
  - Full width components
  - Touch-friendly targets (48dp)
  - Persian mobile patterns

Tablet: 600dp - 1199dp
  - Two column layout
  - Side navigation
  - Larger touch targets
  - Extended Persian text lines

Desktop: 1200dp+
  - Multi-column layout
  - Mouse interaction
  - Compact components
  - Full Persian typography
```

### Layout Adaptation
```dart
class ResponsiveLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          // Mobile Layout
          return MobileLayout();
        } else if (constraints.maxWidth < 1200) {
          // Tablet Layout  
          return TabletLayout();
        } else {
          // Desktop Layout
          return DesktopLayout();
        }
      },
    );
  }
}
```

## 🎨 Theme Implementation

### Theme Configuration
```dart
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryColor,
        brightness: Brightness.light,
      ),
      
      fontFamily: PersianFonts.fontFamily,
      textTheme: _buildTextTheme(),
      
      appBarTheme: _buildAppBarTheme(),
      cardTheme: _buildCardTheme(),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      outlinedButtonTheme: _buildOutlinedButtonTheme(),
      textButtonTheme: _buildTextButtonTheme(),
      inputDecorationTheme: _buildInputDecorationTheme(),
    );
  }

  static TextTheme _buildTextTheme() {
    return TextTheme(
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
    );
  }
}
```

## 🌙 Dark Mode Support

### Dark Theme Colors
```dart
static ThemeData get darkTheme {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryColor,
      brightness: Brightness.dark,
    ),
    fontFamily: PersianFonts.fontFamily,
    // ... other theme configurations
  );
}
```

### Dynamic Theme Switching
```dart
class ThemeController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  
  ThemeMode get themeMode => _themeMode;
  
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
  
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light 
      ? ThemeMode.dark 
      : ThemeMode.light;
    notifyListeners();
  }
}
```

## ♿ Accessibility Design

### Accessibility Guidelines
```yaml
Color Contrast:
  - Normal Text: 4.5:1 minimum
  - Large Text: 3:1 minimum  
  - UI Components: 3:1 minimum

Touch Targets:
  - Minimum Size: 48dp × 48dp
  - Spacing: 8dp between targets
  - Persian Gestures: RTL swipe directions

Text Accessibility:
  - Scalable fonts: 12sp - 30sp
  - Persian text scaling
  - High contrast text colors
  - Readable line heights

Screen Reader:
  - Semantic labels in Persian
  - Proper heading structure
  - Focus management
  - RTL navigation support
```

### Accessible Components
```dart
Semantics(
  label: 'دکمه ارسال فرم',
  hint: 'برای ارسال فرم ضربه بزنید',
  child: ElevatedButton(
    onPressed: () {},
    child: Text('ارسال'),
  ),
)
```

## ⚠️ Important Notes

### Design Best Practices
1. **Persian-First**: همه طراحی‌ها اول برای فارسی
2. **Cultural Sensitivity**: رعایت فرهنگ ایرانی
3. **Accessibility**: دسترسی برای همه کاربران
4. **Performance**: بهینه‌سازی عملکرد
5. **Consistency**: انسجام در تمام صفحات

### Common Mistakes
- استفاده از LTR layouts برای متن فارسی
- نادیده گرفتن اعداد فارسی
- رنگ‌های نامناسب فرهنگ ایرانی
- آیکون‌های غیرمناسب RTL
- فونت‌های غیربهینه فارسی

### Future Enhancements
- پشتیبانی کامل تم تیره
- انیمیشن‌های پیشرفته
- micro-interactions
- موشن دیزاین
- پیشنهادات هوشمند رنگ

## 🔄 Related Documentation
- [Material Design 3 Implementation](./material-design-3.md)
- [Persian RTL Guide](./persian-rtl-guide.md)
- [UI Components Library](../04-Flutter-Frontend/ui-components-library.md)
- [Accessibility Guidelines](./accessibility-guidelines.md)

---
*Last updated: 2025-01-09*  
*File: /docs/06-UI-UX-Design/design-system.md*
