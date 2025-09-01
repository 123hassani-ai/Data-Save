# مشخصات کامپوننت‌ها - Component Specifications

## 📊 Document Information
- **Created:** 2025-09-01
- **Last Updated:** 2025-09-01
- **Version:** 1.0
- **Maintainer:** DataSave Development Team
- **Related Files:** `/lib/presentation/widgets/`, `/lib/widgets/`

## 🎯 Overview
مستندات کامل کامپوننت‌های UI در DataSave شامل مشخصات فنی، نحوه استفاده، و نمونه کدها با پشتیبانی کامل RTL و Persian.

## 📋 Table of Contents
- [کامپوننت‌های مشترک](#کامپوننتهای-مشترک)
  - [StatCard](#statcard-widget)
  - [CustomAppBar](#customappbar-widget)
  - [PersianTextField](#persiantextfield-widget)
- [کامپوننت‌های صفحه‌ای](#کامپوننتهای-صفحهای)
  - [DashboardPage](#dashboardpage-widget)
  - [SettingsPage](#settingspage-widget)
  - [LogsPage](#logspage-widget)
- [استانداردهای طراحی](#استانداردهای-طراحی)
- [راهنمای RTL](#راهنمای-rtl)

## 🔧 کامپوننت‌های مشترک - Shared Components

### StatCard Widget

#### 📋 توضیحات کلی
**File:** `lib/presentation/widgets/shared/stat_card.dart`
**Purpose:** نمایش آمار در قالب کارت زیبا با آیکون و رنگ‌بندی
**Usage:** داشبورد، صفحات آماری، نمایش اطلاعات خلاصه

#### 🏗️ Properties
```dart
class StatCard extends StatelessWidget {
  final String title;           // عنوان کارت (اجباری)
  final String value;           // مقدار عددی یا متنی (اجباری)  
  final IconData icon;          // آیکون نمایشی (اجباری)
  final Color? color;           // رنگ کارت (اختیاری - پیش‌فرض: primary)
  final VoidCallback? onTap;    // عملیات کلیک (اختیاری)
}
```

#### 📱 Design Specifications
```yaml
Dimensions:
  Height: 120px
  Width: Flexible (به عرض والد وابسته)
  Padding: 16px all sides
  Border Radius: 12px
  
Styling:
  Elevation: 2px shadow
  Gradient Background: color with 0.1 to 0.05 opacity
  Icon Size: 32px
  Title Font: subtitle2 (14sp)
  Value Font: headlineSmall (24sp, Bold)

Colors:
  Default: Theme.primary
  Success: Colors.green
  Warning: Colors.orange
  Error: Colors.red
  Info: Colors.blue
```

#### 💻 Usage Examples
```dart
// کارت آمار اطلاعات
StatCard(
  title: 'اطلاعات',
  value: '107',
  icon: Icons.info,
  color: Colors.green,
  onTap: () => Navigator.pushNamed(context, '/logs'),
)

// کارت آمار تنظیمات
StatCard(
  title: 'تنظیمات',
  value: '9',
  icon: Icons.settings,
  color: Colors.blue,
  onTap: () => Navigator.pushNamed(context, '/settings'),
)

// کارت بدون کلیک
StatCard(
  title: 'کاربران',
  value: '0',
  icon: Icons.person,
)
```

#### 🎨 Visual States
```dart
// حالت عادی
StatCard(...) // با gradient background

// حالت hover (web/desktop)
InkWell effect with ripple animation

// حالت disable  
color: Colors.grey
onTap: null
```

---

### CustomAppBar Widget

#### 📋 توضیحات کلی
**File:** `lib/presentation/widgets/shared/custom_app_bar.dart`
**Purpose:** AppBar سفارشی با پشتیبانی RTL و عناصر فارسی
**Usage:** تمام صفحات اصلی برنامه

#### 🏗️ Properties
```dart
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;                    // عنوان صفحه
  final List<Widget>? actions;           // دکمه‌های اکشن
  final bool showBackButton;             // نمایش دکمه برگشت
  final VoidCallback? onBackPressed;     // عملیات برگشت سفارشی
}
```

#### 📱 Design Specifications
```yaml
Dimensions:
  Height: 56px (standard AppBar)
  Title Padding: 16px horizontal
  
Styling:
  Background: Theme.colorScheme.surface
  Foreground: Theme.colorScheme.onSurface
  Elevation: 1px
  Title Typography: headlineSmall Persian
  
RTL Support:
  Text Direction: RTL
  Back Button: Right side (RTL)
  Actions: Left side (RTL)
```

#### 💻 Usage Examples
```dart
// AppBar ساده
CustomAppBar(
  title: 'داشبورد',
)

// AppBar با دکمه‌های اکشن
CustomAppBar(
  title: 'تنظیمات',
  actions: [
    IconButton(
      icon: Icon(Icons.save),
      onPressed: () => _saveSettings(),
    ),
  ],
)

// AppBar با دکمه برگشت سفارشی
CustomAppBar(
  title: 'جزئیات',
  showBackButton: true,
  onBackPressed: () => _handleCustomBack(),
)
```

---

### PersianTextField Widget

#### 📋 توضیحات کلی
**File:** `lib/presentation/widgets/shared/persian_text_field.dart`
**Purpose:** فیلد ورودی متن با پشتیبانی کامل Persian RTL
**Usage:** فرم‌ها، صفحات ورودی، تنظیمات

#### 🏗️ Properties
```dart
class PersianTextField extends StatelessWidget {
  final String label;                    // برچسب فیلد
  final String? hint;                    // متن راهنما
  final TextEditingController? controller; // کنترلر متن
  final TextInputType keyboardType;      // نوع کیبورد
  final bool obscureText;                // مخفی کردن متن (رمز عبور)
  final String? Function(String?)? validator; // اعتبارسنجی
  final void Function(String)? onChanged;     // تغییر متن
  final bool enabled;                    // فعال/غیرفعال
  final int? maxLines;                   // حداکثر خط
  final IconData? prefixIcon;            // آیکون قبل از متن
  final Widget? suffixIcon;              // ویجت بعد از متن
}
```

#### 📱 Design Specifications
```yaml
Dimensions:
  Height: 56px (single line) | auto (multi line)
  Border Radius: 8px
  Padding: 16px horizontal, 12px vertical
  
Styling:
  Border: 1px solid divider color
  Focus Border: 2px solid primary color
  Background: Theme.inputDecorationTheme
  Text Direction: RTL
  Font: Vazirmatn Persian
  
States:
  Normal: border with divider color
  Focus: border with primary color + elevation
  Error: border with error color + error message
  Disabled: grey background + disabled colors
```

#### 💻 Usage Examples
```dart
// فیلد متن ساده
PersianTextField(
  label: 'نام کاربری',
  hint: 'نام کاربری خود را وارد کنید',
  controller: usernameController,
)

// فیلد رمز عبور
PersianTextField(
  label: 'رمز عبور',
  obscureText: true,
  prefixIcon: Icons.lock,
  validator: (value) {
    if (value?.isEmpty == true) {
      return 'رمز عبور اجباری است';
    }
    return null;
  },
)

// فیلد چند خطه
PersianTextField(
  label: 'توضیحات',
  maxLines: 3,
  keyboardType: TextInputType.multiline,
)

// فیلد عددی
PersianTextField(
  label: 'تعداد',
  keyboardType: TextInputType.number,
  prefixIcon: Icons.numbers,
)
```

---

## 📱 کامپوننت‌های صفحه‌ای - Page Components

### DashboardPage Widget

#### 📋 توضیحات کلی
**File:** `lib/presentation/pages/dashboard_page.dart`
**Purpose:** صفحه اصلی داشبورد با نمایش آمار و دسترسی سریع
**Layout:** Grid layout با StatCard ها

#### 🏗️ Structure
```dart
class DashboardPage extends StatefulWidget {
  // State management
  // Statistics loading
  // Navigation handling
}
```

#### 📱 Layout Specifications
```yaml
Layout:
  Type: GridView
  Cross Axis Count: 2 (mobile) | 4 (tablet) | 6 (desktop)
  Spacing: 16px
  Aspect Ratio: 1.0
  
Content:
  - System Status Card
  - Settings Count Card  
  - Logs Count Card
  - Forms Count Card (future)
  - Users Count Card (future)
  - Storage Used Card (future)

Navigation:
  Each card navigates to related page
  Bottom Navigation Bar
  FloatingActionButton for quick actions
```

---

### SettingsPage Widget

#### 📋 توضیحات کلی
**File:** `lib/presentation/pages/settings_page.dart`
**Purpose:** صفحه تنظیمات سیستم با دسته‌بندی
**Features:** OpenAI settings، App settings، System settings

#### 🏗️ Structure
```yaml
Sections:
  - OpenAI Configuration
    - API Key (encrypted input)
    - Model Selection (dropdown)
    - Max Tokens (numeric input)
    - Temperature (slider)
    
  - App Configuration  
    - Language (dropdown)
    - Theme (radio buttons)
    - Auto Save (switch)
    
  - System Configuration
    - Enable Logging (switch)
    - Max Log Entries (numeric)
    - Backup Settings (switch)
```

---

### LogsPage Widget  

#### 📋 توضیحات کلی
**File:** `lib/presentation/pages/logs_page.dart`
**Purpose:** صفحه نمایش و مدیریت لاگ‌های سیستم
**Features:** Real-time logs، filtering، export

#### 🏗️ Structure
```yaml
Components:
  - Search/Filter Bar
  - Log Level Filter (Info, Warning, Error)
  - Date Range Filter  
  - Refresh Button
  - Clear Logs Button
  - Export Logs Button
  
Log Item Layout:
  - Timestamp (Persian)
  - Level Badge (colored)
  - Category 
  - Message (RTL)
  - Details (expandable)
```

---

## 🎨 استانداردهای طراحی - Design Standards

### Color System
```dart
// Primary Colors
Primary: Color(0xFF1976D2)      // آبی اصلی
Secondary: Color(0xFF388E3C)    // سبز تکمیلی
Error: Color(0xFFD32F2F)        // قرمز خطا
Warning: Color(0xFFF57C00)      // نارنجی هشدار
Success: Color(0xFF388E3C)      // سبز موفقیت

// Surface Colors  
Surface: Color(0xFFFAFAFA)      // سفید کرم
Background: Color(0xFFFFFFFF)   // سفید خالص
Card: Color(0xFFFFFFFF)         // سفید کارت
```

### Typography Scale
```dart
// Vazirmatn Persian Font
headlineLarge: 32sp, Bold       // عناوین اصلی
headlineMedium: 28sp, Bold      // عناوین فرعی
headlineSmall: 24sp, Bold       // عناوین کارت
titleLarge: 20sp, Medium        // عناوین بخش
titleMedium: 16sp, Medium       // عناوین آیتم
bodyLarge: 16sp, Regular        // متن اصلی
bodyMedium: 14sp, Regular       // متن توضیحات
labelLarge: 14sp, Medium        // برچسب دکمه
labelMedium: 12sp, Medium       // برچسب کوچک
```

### Spacing System
```dart
// Material Design Spacing
xs: 4px      // فاصله خیلی کوچک
sm: 8px      // فاصله کوچک  
md: 16px     // فاصله متوسط (پیش‌فرض)
lg: 24px     // فاصله بزرگ
xl: 32px     // فاصله خیلی بزرگ
xxl: 48px    // فاصله عظیم
```

---

## 🌐 راهنمای RTL - RTL Guidelines

### Text Direction
```dart
// تمام متون باید RTL باشند
Directionality(
  textDirection: TextDirection.rtl,
  child: Widget(),
)

// یا استفاده از locale
MaterialApp(
  locale: Locale('fa', 'IR'),
  supportedLocales: [Locale('fa', 'IR')],
)
```

### Layout Considerations
```yaml
Row/Column: 
  MainAxis: Right to Left in RTL
  CrossAxis: Unchanged
  
Padding/Margin:
  start/end instead of left/right
  EdgeInsetsDirectional.only(start: 16)
  
Icons:
  directional icons flip automatically
  use Icons.arrow_forward (auto-flips to right in RTL)
  
Navigation:
  back button appears on right
  drawer opens from right
  tabs progress right to left
```

### Persian Number Formatting
```dart
// Persian/Farsi Numbers
String toPersianNumbers(String input) {
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
  
  for (int i = 0; i < english.length; i++) {
    input = input.replaceAll(english[i], persian[i]);
  }
  return input;
}
```

---

## ⚠️ Important Notes

### Performance Guidelines
- Use `const` constructors wherever possible
- Implement `StatelessWidget` when state is not needed
- Use `ListView.builder` for long lists
- Cache network images
- Minimize widget rebuilds

### Accessibility
- Provide semantic labels for screen readers
- Ensure sufficient color contrast
- Support keyboard navigation
- Add tooltips for icons
- Use descriptive button text

### Testing Requirements
- Unit tests for business logic
- Widget tests for UI components  
- Integration tests for user flows
- Golden tests for visual regression
- Accessibility tests

---

## 🔄 Related Documentation
- [Flutter Architecture](../04-Flutter-Frontend/flutter-architecture.md)
- [Persian RTL Implementation](../04-Flutter-Frontend/persian-rtl-implementation.md)
- [Material Design 3](material-design-3.md)
- [Design System](design-system.md)
- [UI Components Library](ui-components-library.md)

## 📚 References
- [Flutter Widget Catalog](https://flutter.dev/docs/development/ui/widgets)
- [Material Design 3](https://m3.material.io/)
- [Persian Typography Guide](https://github.com/rastikerdar/vazirmatn)
- [RTL Layout Guidelines](https://material.io/design/usability/bidirectionality.html)

---
*Last updated: 2025-09-01*  
*File: docs/06-UI-UX-Design/component-specifications.md*