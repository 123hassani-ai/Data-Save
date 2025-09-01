# پیاده‌سازی Persian RTL - Persian RTL Implementation

## 📊 Document Information
- **Created:** 2025-09-01
- **Last Updated:** 2025-09-01
- **Version:** 1.0
- **Maintainer:** DataSave Frontend Team
- **Related Files:** `/lib/core/localization`, `/web/vazirmatn.css`

## 🎯 Overview
این مستند نحوه پیاده‌سازی پشتیبانی کامل از زبان فارسی و قالب راست به چپ (RTL) در اپلیکیشن Flutter پروژه DataSave را شرح می‌دهد، شامل تنظیمات لوکال، فونت‌ها، ترجمه‌ها، و راهکارهای رفع مشکلات رایج RTL.

## 📋 Table of Contents
- [پیکربندی RTL](#پیکربندی-rtl)
- [فونت‌های فارسی](#فونت‌های-فارسی)
- [ترجمه و چندزبانگی](#ترجمه-و-چندزبانگی)
- [مدیریت متن RTL](#مدیریت-متن-rtl)
- [چالش‌های RTL و راه‌حل‌ها](#چالش‌های-rtl-و-راه‌حل‌ها)
- [تست RTL](#تست-rtl)
- [بهترین شیوه‌ها](#بهترین-شیوه‌ها)

## 🔄 پیکربندی RTL

### تنظیمات اصلی MaterialApp
```dart
// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:datasave/core/localization/app_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DataSave',
      debugShowCheckedModeBanner: false,
      
      // تنظیمات لوکال برای فارسی
      locale: const Locale('fa', 'IR'),
      
      // پشتیبانی از لوکال‌های موجود
      supportedLocales: const [
        Locale('fa', 'IR'), // فارسی (ایران)
        Locale('en', 'US'), // انگلیسی (امریکا)
      ],
      
      // تنظیمات لوکالیزیشن
      localizationsDelegates: const [
        // دلیگیت اختصاصی اپلیکیشن
        AppLocalizations.delegate,
        
        // دلیگیت‌های ماتریال و کوپرتینو
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      // تعیین راست به چپ بودن با توجه به لوکال
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode &&
              supportedLocale.countryCode == locale?.countryCode) {
            return supportedLocale;
          }
        }
        // اگر لوکال مورد نظر پشتیبانی نشود، به لوکال اول (فارسی) برمی‌گردیم
        return supportedLocales.first;
      },
      
      // تم اپلیکیشن با تنظیمات راست به چپ
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Vazirmatn', // فونت پیش‌فرض فارسی
        textTheme: const TextTheme(
          // تنظیمات سبک متنی برای فارسی
          titleLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          titleMedium: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
          bodyLarge: TextStyle(fontSize: 16),
          bodyMedium: TextStyle(fontSize: 14),
        ),
      ),
      
      home: const HomePage(),
    );
  }
}
```

### کلاس AppLocalizations
```dart
// lib/core/localization/app_localizations.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  
  AppLocalizations(this.locale);
  
  // Helper method to keep the code in the widgets concise
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }
  
  // Static member to have a simple access to the delegate from the MaterialApp
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
  
  Map<String, String> _localizedStrings = {};
  
  Future<bool> load() async {
    // Load the language JSON file from the "lang" folder
    String jsonString = await rootBundle.loadString('assets/lang/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    
    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });
    
    return true;
  }
  
  // This method will be called from every widget which needs a localized text
  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }
  
  // تابع کمکی برای استفاده سریع‌تر از ترجمه
  String get(String key) => translate(key);
  
  // اطلاعات در مورد جهت متن
  bool get isRtl => locale.languageCode == 'fa' || locale.languageCode == 'ar';
  
  // دریافت جهت متن براساس لوکال
  TextDirection get textDirection => isRtl ? TextDirection.rtl : TextDirection.ltr;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  
  @override
  bool isSupported(Locale locale) {
    // Include all of your supported language codes here
    return ['fa', 'en'].contains(locale.languageCode);
  }
  
  @override
  Future<AppLocalizations> load(Locale locale) async {
    // AppLocalizations class is where the JSON loading actually runs
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }
  
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
```

### نمونه فایل ترجمه فارسی
```json
// assets/lang/fa.json

{
  "app_name": "دیتاسیو",
  "home_title": "صفحه اصلی",
  "settings": "تنظیمات",
  "forms": "فرم‌ها",
  "create_form": "ایجاد فرم جدید",
  "edit_form": "ویرایش فرم",
  "delete_form": "حذف فرم",
  "form_name": "نام فرم",
  "form_description": "توضیحات فرم",
  "save": "ذخیره",
  "cancel": "انصراف",
  "confirm": "تایید",
  "login": "ورود",
  "logout": "خروج",
  "username": "نام کاربری",
  "password": "رمز عبور",
  "email": "ایمیل",
  "phone": "تلفن",
  "profile": "پروفایل",
  "dashboard": "داشبورد",
  "analytics": "آنالیز",
  "reports": "گزارش‌ها",
  "language": "زبان",
  "theme": "تم",
  "dark_mode": "حالت تاریک",
  "light_mode": "حالت روشن",
  "notifications": "اعلان‌ها",
  "error_occurred": "خطایی رخ داده است",
  "try_again": "تلاش مجدد",
  "no_data": "اطلاعاتی موجود نیست",
  "loading": "در حال بارگذاری..."
}
```

## 🔤 فونت‌های فارسی

### تنظیمات فونت وزیرمتن
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
```

### تنظیمات CSS برای فونت در وب
```css
/* web/vazirmatn.css */

/* واردکردن فونت وزیرمتن */
@font-face {
  font-family: 'Vazirmatn';
  src: url('fonts/Vazirmatn-Regular.woff2') format('woff2');
  font-weight: 400;
  font-style: normal;
}

@font-face {
  font-family: 'Vazirmatn';
  src: url('fonts/Vazirmatn-Bold.woff2') format('woff2');
  font-weight: 700;
  font-style: normal;
}

/* سایر وزن‌های فونت */

/* تنظیمات پایه RTL */
body {
  font-family: 'Vazirmatn', sans-serif;
  direction: rtl;
  text-align: right;
}

/* تنظیمات RTL برای المان‌های خاص */
.rtl-specific {
  direction: rtl;
  text-align: right;
}

.ltr-specific {
  direction: ltr;
  text-align: left;
}

/* تنظیمات برای اعداد */
.persian-digits {
  font-feature-settings: "ss01";
}

.english-digits {
  font-feature-settings: "ss02";
}
```

### کلاس کمکی RTL برای استایل‌ها
```dart
// lib/core/utils/rtl_helper.dart

import 'package:flutter/material.dart';
import 'package:datasave/core/localization/app_localizations.dart';

class RtlHelper {
  // محاسبه پدینگ با توجه به RTL
  static EdgeInsetsGeometry getPadding({
    required BuildContext context,
    double start = 0,
    double end = 0,
    double top = 0,
    double bottom = 0,
  }) {
    final isRtl = AppLocalizations.of(context).isRtl;
    
    return EdgeInsetsDirectional.fromSTEB(
      start,
      top,
      end,
      bottom,
    );
  }
  
  // محاسبه مارجین با توجه به RTL
  static EdgeInsetsGeometry getMargin({
    required BuildContext context,
    double start = 0,
    double end = 0,
    double top = 0,
    double bottom = 0,
  }) {
    return EdgeInsetsDirectional.fromSTEB(
      start,
      top,
      end,
      bottom,
    );
  }
  
  // مقدار افست برای انیمیشن‌ها
  static double getOffsetX(BuildContext context, double value) {
    final isRtl = AppLocalizations.of(context).isRtl;
    return isRtl ? -value : value;
  }
  
  // تبدیل اعداد انگلیسی به فارسی
  static String toPersianDigits(String text) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    
    for (int i = 0; i < english.length; i++) {
      text = text.replaceAll(english[i], persian[i]);
    }
    
    return text;
  }
  
  // تبدیل اعداد فارسی به انگلیسی
  static String toEnglishDigits(String text) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    
    for (int i = 0; i < persian.length; i++) {
      text = text.replaceAll(persian[i], english[i]);
    }
    
    return text;
  }
  
  // فرمت‌کردن اعداد با جداکننده سه‌رقمی
  static String formatNumber(int number, {bool usePersianDigits = true}) {
    final formatter = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String formatted = number.toString().replaceAllMapped(
      formatter, (Match m) => '${m[1]},');
    
    return usePersianDigits ? toPersianDigits(formatted) : formatted;
  }
}
```

## 🌐 ترجمه و چندزبانگی

### مدیریت زبان‌ها
```dart
// lib/core/providers/language_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  Locale _locale = const Locale('fa', 'IR');
  
  Locale get locale => _locale;
  
  // لیست زبان‌های پشتیبانی شده
  final List<Locale> supportedLocales = const [
    Locale('fa', 'IR'), // فارسی
    Locale('en', 'US'), // انگلیسی
  ];
  
  // نام زبان‌ها برای نمایش
  Map<String, String> languageNames = {
    'fa': 'فارسی',
    'en': 'English',
  };
  
  // دریافت نام زبان فعلی
  String get currentLanguageName => languageNames[_locale.languageCode] ?? 'فارسی';
  
  // بررسی RTL بودن
  bool get isRtl => _locale.languageCode == 'fa' || _locale.languageCode == 'ar';
  
  LanguageProvider() {
    _loadSavedLanguage();
  }
  
  // تغییر زبان
  void changeLanguage(Locale newLocale) async {
    if (supportedLocales.contains(newLocale)) {
      _locale = newLocale;
      
      // ذخیره زبان انتخاب شده
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('language_code', newLocale.languageCode);
      await prefs.setString('country_code', newLocale.countryCode ?? '');
      
      notifyListeners();
    }
  }
  
  // بارگذاری زبان ذخیره‌شده
  Future<void> _loadSavedLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('language_code');
    String? countryCode = prefs.getString('country_code');
    
    if (languageCode != null) {
      _locale = Locale(languageCode, countryCode);
      notifyListeners();
    }
  }
}
```

### نمونه کد استفاده از ترجمه‌ها
```dart
// نمونه استفاده از ترجمه‌ها در ویجت‌ها

// روش 1: استفاده از AppLocalizations.of(context)
Text(AppLocalizations.of(context).translate('home_title')),

// روش 2: استفاده از تابع کمکی get
Text(AppLocalizations.of(context).get('settings')),

// روش 3: ایجاد اکستنشن کمکی
extension TranslateX on BuildContext {
  String tr(String key) => AppLocalizations.of(this).translate(key);
}

// استفاده از اکستنشن
Text(context.tr('save')),

// جهت متن با توجه به RTL
Directionality(
  textDirection: AppLocalizations.of(context).textDirection,
  child: TextField(
    textAlign: AppLocalizations.of(context).isRtl ? TextAlign.right : TextAlign.left,
    decoration: InputDecoration(
      hintText: AppLocalizations.of(context).translate('search'),
      hintTextDirection: AppLocalizations.of(context).textDirection,
    ),
  ),
),
```

## 📝 مدیریت متن RTL

### ویجت هوشمند RTL Text
```dart
// lib/core/widgets/rtl_text.dart

import 'package:flutter/material.dart';
import 'package:datasave/core/localization/app_localizations.dart';

class RtlText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;
  final bool convertNumbers;
  
  const RtlText(
    this.text, {
    Key? key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.convertNumbers = true,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final isRtl = AppLocalizations.of(context).isRtl;
    
    // تبدیل اعداد به فارسی در صورت نیاز
    String displayText = text;
    if (convertNumbers && isRtl) {
      displayText = RtlHelper.toPersianDigits(text);
    }
    
    return Text(
      displayText,
      style: style,
      textAlign: textAlign ?? (isRtl ? TextAlign.right : TextAlign.left),
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
    );
  }
}
```

### ویجت RTL TextField
```dart
// lib/core/widgets/rtl_text_field.dart

import 'package:flutter/material.dart';
import 'package:datasave/core/localization/app_localizations.dart';
import 'package:datasave/core/utils/rtl_helper.dart';

class RtlTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final InputDecoration? decoration;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final bool convertNumbers;
  final int? maxLines;
  final int? minLines;
  
  const RtlTextField({
    Key? key,
    this.controller,
    this.labelText,
    this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.decoration,
    this.onChanged,
    this.validator,
    this.convertNumbers = true,
    this.maxLines = 1,
    this.minLines,
  }) : super(key: key);
  
  @override
  State<RtlTextField> createState() => _RtlTextFieldState();
}

class _RtlTextFieldState extends State<RtlTextField> {
  late TextEditingController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }
  
  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final isRtl = AppLocalizations.of(context).isRtl;
    
    return TextFormField(
      controller: _controller,
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText,
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      textAlign: isRtl ? TextAlign.right : TextAlign.left,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      onChanged: (value) {
        // تبدیل اعداد از فارسی به انگلیسی برای ذخیره‌سازی
        if (widget.convertNumbers && isRtl && widget.keyboardType == TextInputType.number) {
          final englishDigits = RtlHelper.toEnglishDigits(value);
          if (englishDigits != value) {
            _controller.value = TextEditingValue(
              text: englishDigits,
              selection: TextSelection.collapsed(offset: englishDigits.length),
            );
            value = englishDigits;
          }
        }
        
        if (widget.onChanged != null) {
          widget.onChanged!(value);
        }
      },
      validator: widget.validator,
      decoration: widget.decoration ??
          InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            alignLabelWithHint: true,
            hintTextDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            contentPadding: RtlHelper.getPadding(
              context: context,
              start: 16,
              end: 16,
              top: 12,
              bottom: 12,
            ),
          ),
    );
  }
}
```

## 🧩 چالش‌های RTL و راه‌حل‌ها

### چالش‌های رایج RTL
```yaml
RTL Challenges:
  1. آیکون‌ها و فلش‌ها:
     - چالش: آیکون‌ها و فلش‌ها در RTL باید معکوس شوند
     - راه‌حل: استفاده از Directionality و TextDirection.rtl

  2. ترتیب عناصر:
     - چالش: ترتیب عناصر در RTL باید از راست به چپ باشد
     - راه‌حل: استفاده از Row و MainAxisAlignment.end

  3. انیمیشن‌ها:
     - چالش: انیمیشن‌ها باید با RTL هماهنگ باشند
     - راه‌حل: معکوس‌کردن مقادیر انیمیشن براساس RTL

  4. اعداد:
     - چالش: نمایش اعداد فارسی یا انگلیسی
     - راه‌حل: تبدیل اعداد با کلاس کمکی RtlHelper

  5. اسکرول‌ها و Swipe:
     - چالش: جهت اسکرول و swipe باید مناسب RTL باشد
     - راه‌حل: استفاده از ScrollDirection و معکوس‌کردن منطق swipe
```

### راه‌حل‌های کاربردی RTL
```dart
// نمونه Row با پشتیبانی RTL
Row(
  mainAxisAlignment: AppLocalizations.of(context).isRtl
    ? MainAxisAlignment.end
    : MainAxisAlignment.start,
  children: [
    Icon(Icons.star),
    SizedBox(width: 8),
    RtlText('امتیاز: 4.5'),
  ],
)

// نمونه ویجت با آیکون مناسب RTL
IconButton(
  icon: Icon(
    AppLocalizations.of(context).isRtl
      ? Icons.arrow_back
      : Icons.arrow_forward
  ),
  onPressed: () => Navigator.pop(context),
)

// نمونه Drawer با RTL
Scaffold(
  drawerEdgeDragWidth: 100,
  endDrawerEnableOpenDragGesture: true,
  drawer: AppLocalizations.of(context).isRtl ? null : AppDrawer(),
  endDrawer: AppLocalizations.of(context).isRtl ? AppDrawer() : null,
  body: ...
)

// نمونه استفاده از EdgeInsetsDirectional
Padding(
  padding: EdgeInsetsDirectional.only(
    start: 16.0, // به جای left
    end: 16.0,   // به جای right
    top: 8.0,
    bottom: 8.0,
  ),
  child: ...
)
```

### میدلور RTL برای روت‌ها
```dart
// lib/core/navigation/rtl_route.dart

import 'package:flutter/material.dart';
import 'package:datasave/core/localization/app_localizations.dart';

class RtlPageRoute<T> extends MaterialPageRoute<T> {
  final BuildContext context;
  
  RtlPageRoute({
    required this.context,
    required WidgetBuilder builder,
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) : super(
    builder: builder,
    settings: settings,
    maintainState: maintainState,
    fullscreenDialog: fullscreenDialog,
  );
  
  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final isRtl = AppLocalizations.of(this.context).isRtl;
    
    // For RTL: slide from right to left (reversed)
    if (isRtl) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      );
    }
    
    // For LTR: normal slide from left to right
    return super.buildTransitions(context, animation, secondaryAnimation, child);
  }
}

// استفاده:
Navigator.push(
  context,
  RtlPageRoute(
    context: context,
    builder: (context) => ProfileScreen(),
  ),
);
```

## 🧪 تست RTL

### راهنمای تست RTL
```yaml
RTL Testing Guidelines:
  1. تست در هر دو حالت RTL و LTR:
     - تست با زبان فارسی (RTL)
     - تست با زبان انگلیسی (LTR)
     
  2. موارد مهم تست:
     - چینش عناصر و ترتیب آنها
     - فرم‌ها و فیلدهای ورودی
     - انیمیشن‌ها و ترنزیشن‌ها
     - اسکرول‌ها و جست‌ها
     - نمایش اعداد و تاریخ‌ها
     
  3. تست روی دستگاه‌های مختلف:
     - تلفن همراه
     - تبلت
     - وب
     
  4. تست با اندازه‌های مختلف فونت:
     - اندازه کوچک
     - اندازه متوسط
     - اندازه بزرگ (برای افراد کم‌بینا)
```

### تست خودکار RTL
```dart
// test/rtl_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:datasave/core/localization/app_localizations.dart';
import 'package:datasave/core/widgets/rtl_text.dart';
import 'package:datasave/core/utils/rtl_helper.dart';

void main() {
  testWidgets('RtlText should respect RTL direction', (WidgetTester tester) async {
    // تست RtlText در حالت RTL
    await tester.pumpWidget(
      MaterialApp(
        locale: Locale('fa', 'IR'),
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('fa', 'IR'),
          Locale('en', 'US'),
        ],
        home: Scaffold(
          body: Center(
            child: RtlText('این یک متن تست است'),
          ),
        ),
      ),
    );
    
    // انتظار داریم متن راست به چپ باشد
    final text = tester.widget<RtlText>(find.byType(RtlText));
    expect(text.textAlign, TextAlign.right);
    
    // تست تبدیل اعداد
    await tester.pumpWidget(
      MaterialApp(
        locale: Locale('fa', 'IR'),
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('fa', 'IR'),
          Locale('en', 'US'),
        ],
        home: Scaffold(
          body: Center(
            child: RtlText('123'),
          ),
        ),
      ),
    );
    
    // انتظار داریم اعداد تبدیل شده باشند
    final textWidget = tester.widget<Text>(find.byType(Text));
    expect(textWidget.data, '۱۲۳');
  });
  
  test('RtlHelper should convert numbers correctly', () {
    // تست تبدیل اعداد انگلیسی به فارسی
    expect(RtlHelper.toPersianDigits('123'), '۱۲۳');
    
    // تست تبدیل اعداد فارسی به انگلیسی
    expect(RtlHelper.toEnglishDigits('۱۲۳'), '123');
    
    // تست فرمت‌کردن اعداد
    expect(RtlHelper.formatNumber(1000000, usePersianDigits: false), '1,000,000');
    expect(RtlHelper.formatNumber(1000000), '۱,۰۰۰,۰۰۰');
  });
}
```

## 🏆 بهترین شیوه‌ها

### بهترین شیوه‌های RTL
```yaml
RTL Best Practices:
  1. همیشه از EdgeInsetsDirectional به جای EdgeInsets استفاده کنید:
     - EdgeInsetsDirectional.only(start: 16, end: 16)
     - به جای EdgeInsets.only(left: 16, right: 16)
     
  2. از start و end به جای left و right استفاده کنید:
     - BorderDirectional
     - AlignmentDirectional
     - TextAlignmentDirectional
     
  3. از Directionality برای تغییر جهت بلوک‌های خاص استفاده کنید:
     - زمانی که محتوا با جهت کلی اپلیکیشن متفاوت است
     
  4. برای چینش عناصر به ترتیب، از Row و MainAxisAlignment استفاده کنید:
     - سیستم اتوماتیک ترتیب را براساس RTL تنظیم می‌کند
     
  5. از TextDirection.rtl و TextDirection.ltr استفاده کنید:
     - به جای استفاده از مقادیر ثابت
     
  6. اعداد و ارقام را به درستی مدیریت کنید:
     - تبدیل نمایشی اعداد به فارسی
     - ذخیره اعداد به انگلیسی
     
  7. آیکون‌ها و تصاویر را هوشمندانه معکوس کنید:
     - فقط آیکون‌هایی که به جهت مربوط هستند معکوس شوند
```

### لیست راه‌حل‌های RTL برای موارد خاص
```yaml
RTL Solutions for Specific Cases:
  1. PageView و TabBar:
     - استفاده از controller با initialPage مناسب
     - در RTL، initialPage را معکوس کنید
     
  2. Drawer و BottomSheet:
     - استفاده از drawer و endDrawer به صورت شرطی
     
  3. Slider و اجزای تعاملی:
     - استفاده از Directionality
     - معکوس‌کردن min و max در RTL در صورت نیاز
     
  4. Chart و نمودار:
     - تنظیم جهت محورها براساس RTL
     - استفاده از labelDirection مناسب
     
  5. تاریخ و زمان:
     - استفاده از کتابخانه‌های سازگار با تاریخ شمسی
     - تبدیل مناسب فرمت‌های تاریخ
     
  6. کیبورد و ورودی:
     - تنظیم TextInputType و TextDirection
     - مدیریت textAlign براساس RTL
```

## 🔄 Related Documentation
- [UI Components Library](../06-UI-UX-Design/ui-components-library.md)
- [Responsive Design](responsive-design.md)
- [Typography and Fonts](../06-UI-UX-Design/typography-fonts.md)
- [Material Design 3](../06-UI-UX-Design/material-design-3.md)

---
*Last updated: 2025-09-01*  
*File: docs/04-Flutter-Frontend/persian-rtl-implementation.md*