## 🚀 پرامپت مرحله اول: ایجاد پروژه Flutter

```markdown
# 🎯 ماموریت: ایجاد پروژه DataSave - مرحله اول

## هدف
ایجاد پروژه Flutter Web جدید با نام DataSave در مسیر فعلی و راه‌اندازی ساختار استاندارد Clean Architecture

## Context فنی
- مسیر پروژه: `/Applications/XAMPP/xamppfiles/htdocs/datasave`
- پلتفرم: Flutter Web (PWA Support)
- زبان: Dart
- معماری: Clean Architecture
- پشتیبانی: Persian RTL + Material Design 3

## اقدامات مورد نیاز

### 1️⃣ ایجاد پروژه Flutter
```bash
cd /Applications/XAMPP/xamppfiles/htdocs/datasave
flutter create --platforms web --project-name datasave --org ir.datasave .
```

### 2️⃣ پیکربندی pubspec.yaml
```yaml
name: datasave
description: پلتفرم هوشمند فرم‌ساز
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: ">=3.16.0"

dependencies:
  flutter:
    sdk: flutter
  
  # UI & Localization
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0
  google_fonts: ^6.1.0
  
  # State Management
  provider: ^6.1.1
  
  # HTTP & API
  http: ^1.1.2
  dio: ^5.4.0
  
  # Database
  mysql1: ^0.20.0
  
  # Utils
  uuid: ^4.2.1
  shared_preferences: ^2.2.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1

flutter:
  uses-material-design: true
  generate: true
```

### 3️⃣ ایجاد ساختار Clean Architecture
```
lib/
├── core/
│   ├── config/
│   │   └── app_config.dart
│   ├── constants/
│   │   └── app_constants.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── utils/
│       └── validators.dart
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── presentation/
│   ├── pages/
│   │   └── home/
│   │       └── home_page.dart
│   ├── widgets/
│   │   └── shared/
│   └── routes/
│       └── app_routes.dart
└── main.dart
```

### 4️⃣ محتوای main.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'presentation/pages/home/home_page.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const DataSaveApp());
}

class DataSaveApp extends StatelessWidget {
  const DataSaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DataSave - فرم‌ساز هوشمند',
      debugShowCheckedModeBanner: false,
      
      // Persian Localization
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('fa', 'IR')],
      
      // Theme
      theme: AppTheme.lightTheme,
      
      // Home
      home: const HomePage(),
    );
  }
}
```

## Validation Rules
- بررسی ایجاد موفق پروژه با `flutter doctor`
- تست اجرا با `flutter run -d chrome`
- بررسی RTL support
- تایید Material Design 3

## اقدامات پس از تکمیل
1. اجرای `flutter pub get`
2. تست اولیه با `flutter run -d chrome`
3. گزارش وضعیت اجرا
4. Screenshot صفحه اولیه

## گزارش مورد انتظار
- وضعیت ایجاد پروژه
- پیام‌های مهم Console
- Screenshot از صفحه اولیه
- مشکلات احتمالی
```

---

