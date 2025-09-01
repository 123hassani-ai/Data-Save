## 🚀 پرامپت مرحله دوم: Logger System + Database Connection

```markdown
# 🎯 ماموریت: راه‌اندازی Logger System و Database Connection - مرحله دوم

## هدف
پیاده‌سازی سیستم لاگینگ حرفه‌ای + اتصال به MySQL + ایجاد جدول تنظیمات برای OpenAI API

## Context فنی
- مسیر پروژه: `/Applications/XAMPP/xamppfiles/htdocs/datasave`
- دیتابیس: MySQL (پورت 3307) - XAMPP
- رمز عبور root: `Mojtab@123`
- معماری: Clean Architecture
- هدف: تست اتصال دیتابیس + مدیریت تنظیمات AI

## اقدامات مورد نیاز

### 1️⃣ بروزرسانی pubspec.yaml
```yaml
dependencies:
  # موارد فعلی بمانند + اضافه کردن:
  
  # Database & Logging
  mysql1: ^0.20.0
  logging: ^1.2.0
  path: ^1.9.0
  
  # JSON & Crypto برای تنظیمات
  crypto: ^3.0.3
  convert: ^3.1.1
```

### 2️⃣ ایجاد دیتابیس و جدول تنظیمات

**اسکریپت SQL:**
```sql
-- ایجاد دیتابیس
CREATE DATABASE IF NOT EXISTS `datasave_db` 
DEFAULT CHARACTER SET utf8mb4 
COLLATE utf8mb4_persian_ci;

USE `datasave_db`;

-- جدول تنظیمات سیستم (قابل توسعه)
CREATE TABLE `system_settings` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `setting_key` VARCHAR(100) UNIQUE NOT NULL COMMENT 'کلید تنظیمات',
  `setting_value` TEXT COMMENT 'مقدار تنظیمات',
  `setting_type` ENUM('string','json','boolean','number','encrypted') DEFAULT 'string',
  `description` VARCHAR(255) COMMENT 'توضیحات تنظیمات',
  `is_system` BOOLEAN DEFAULT FALSE COMMENT 'تنظیمات سیستمی؟',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  INDEX idx_setting_key (`setting_key`),
  INDEX idx_is_system (`is_system`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci
COMMENT='تنظیمات سیستم و API های خارجی';

-- درج تنظیمات اولیه
INSERT INTO `system_settings` (`setting_key`, `setting_value`, `setting_type`, `description`, `is_system`) VALUES
('openai_api_key', '', 'encrypted', 'کلید API سرویس OpenAI', true),
('openai_model', 'gpt-4', 'string', 'مدل پیش‌فرض OpenAI', true),
('openai_max_tokens', '2048', 'number', 'حداکثر توکن برای پاسخ', true),
('openai_temperature', '0.7', 'number', 'میزان خلاقیت AI (0-1)', true),
('app_language', 'fa', 'string', 'زبان پیش‌فرض برنامه', true),
('max_forms_per_user', '50', 'number', 'حداکثر فرم برای هر کاربر', false),
('enable_logging', 'true', 'boolean', 'فعال‌سازی سیستم لاگ', true);

-- جدول لاگ‌ها
CREATE TABLE `system_logs` (
  `log_id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `log_level` ENUM('DEBUG','INFO','WARNING','ERROR','CRITICAL') NOT NULL,
  `log_category` VARCHAR(50) NOT NULL COMMENT 'دسته‌بندی (DB, API, UI, System)',
  `log_message` TEXT NOT NULL COMMENT 'پیام لاگ',
  `log_context` JSON COMMENT 'اطلاعات تکمیلی JSON',
  `ip_address` VARCHAR(45) COMMENT 'آدرس IP کاربر',
  `user_agent` TEXT COMMENT 'مرورگر کاربر',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  INDEX idx_log_level (`log_level`),
  INDEX idx_log_category (`log_category`),
  INDEX idx_created_at (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci
COMMENT='لاگ‌های سیستمی برای debugging و monitoring';
```

### 3️⃣ ایجاد فایل‌های Core

**lib/core/config/database_config.dart:**
```dart
/// پیکربندی اتصال به پایگاه داده MySQL
class DatabaseConfig {
  static const String host = 'localhost';
  static const int port = 3307;
  static const String database = 'datasave_db';
  static const String username = 'root';
  static const String password = 'Mojtab@123';
  static const String charset = 'utf8mb4';
  
  /// تنظیمات Connection Pool
  static const int maxConnections = 5;
  static const Duration connectionTimeout = Duration(seconds: 30);
}
```

**lib/core/database/database_service.dart:**
```dart
import 'package:mysql1/mysql1.dart';
import '../config/database_config.dart';
import '../logger/logger_service.dart';

/// سرویس اتصال و مدیریت پایگاه داده
class DatabaseService {
  static DatabaseService? _instance;
  MySqlConnection? _connection;
  
  DatabaseService._();
  
  static DatabaseService get instance => _instance ??= DatabaseService._();
  
  /// برقراری اتصال به دیتابیس
  Future<MySqlConnection> getConnection() async {
    // پیاده‌سازی Connection Pool و Error Handling
  }
  
  /// تست اتصال
  Future<bool> testConnection() async {
    // تست اتصال و گزارش نتیجه
  }
  
  /// اجرای Query با لاگینگ
  Future<Results> query(String sql, [List<Object?>? values]) async {
    // اجرای Query + لاگ کامل
  }
}
```

**lib/core/logger/logger_service.dart:**
```dart
import 'dart:convert';
import 'package:logging/logging.dart';

/// سیستم لاگینگ چندسطحه با ذخیره در دیتابیس
class LoggerService {
  static final Logger _logger = Logger('DataSave');
  static bool _initialized = false;
  
  /// راه‌اندازی Logger
  static void initialize() {
    if (_initialized) return;
    
    // تنظیمات Logger
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen(_handleLogRecord);
    
    _initialized = true;
    info('Logger System', 'سیستم لاگینگ راه‌اندازی شد');
  }
  
  /// لاگ سطح INFO
  static void info(String category, String message, [Map<String, dynamic>? context]) {
    // پیاده‌سازی با ذخیره در دیتابیس
  }
  
  /// لاگ سطح ERROR
  static void error(String category, String message, [dynamic error, StackTrace? stackTrace]) {
    // پیاده‌سازی خطاها
  }
  
  /// لاگ سطح WARNING
  static void warning(String category, String message, [Map<String, dynamic>? context]) {
    // پیاده‌سازی هشدارها
  }
  
  /// لاگ سطح DEBUG (فقط در حالت توسعه)
  static void debug(String category, String message, [Map<String, dynamic>? context]) {
    // پیاده‌سازی دیباگ
  }
}
```

**lib/core/services/settings_service.dart:**
```dart
/// سرویس مدیریت تنظیمات سیستم و OpenAI
class SettingsService {
  static SettingsService? _instance;
  
  SettingsService._();
  static SettingsService get instance => _instance ??= SettingsService._();
  
  /// دریافت تنظیمات OpenAI
  Future<Map<String, String>> getOpenAISettings() async {
    // خواندن تنظیمات API از دیتابیس
    // رمزگشایی کلید API
  }
  
  /// بروزرسانی تنظیمات
  Future<bool> updateSetting(String key, String value) async {
    // بروزرسانی در دیتابیس + لاگ
  }
  
  /// تست اتصال OpenAI
  Future<bool> testOpenAIConnection() async {
    // تست کردن API Key
  }
}
```

### 4️⃣ بروزرسانی main.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../02-/core/logger/logger_service.dart';
import '../02-/core/database/database_service.dart';
import '../02-/presentation/pages/home/home_page.dart';
import '../02-/core/theme/app_theme.dart';

void main() async {
  // اطمینان از راه‌اندازی Flutter
  WidgetsFlutterBinding.ensureInitialized();
  
  // راه‌اندازی Logger
  LoggerService.initialize();
  LoggerService.info('System', 'شروع راه‌اندازی DataSave...');
  
  // تست اتصال دیتابیس
  try {
    final dbService = DatabaseService.instance;
    final isConnected = await dbService.testConnection();
    
    if (isConnected) {
      LoggerService.info('Database', 'اتصال دیتابیس برقرار شد');
    } else {
      LoggerService.error('Database', 'خطا در اتصال دیتابیس');
    }
  } catch (e) {
    LoggerService.error('Database', 'خطای critical در دیتابیس', e);
  }
  
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

### 5️⃣ صفحه تست سیستم - lib/presentation/pages/home/home_page.dart

```dart
/// صفحه اصلی با تست‌های سیستم
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _databaseConnected = false;
  String _connectionStatus = 'در حال بررسی...';
  List<Map<String, dynamic>> _systemSettings = [];

  @override
  void initState() {
    super.initState();
    _testSystemComponents();
  }

  /// تست اجزای سیستم
  Future<void> _testSystemComponents() async {
    // تست دیتابیس
    // بارگذاری تنظیمات
    // نمایش نتایج در UI
  }

  /// تست لاگینگ
  void _testLogging() {
    LoggerService.info('UI', 'تست لاگ INFO از رابط کاربری');
    LoggerService.warning('UI', 'تست لاگ WARNING');
    LoggerService.error('UI', 'تست لاگ ERROR برای آزمایش');
    LoggerService.debug('UI', 'تست لاگ DEBUG');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('لاگ‌های تست ایجاد شدند')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DataSave - فرم‌ساز هوشمند'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // کارت وضعیت دیتابیس
            // کارت تنظیمات سیستم
            // دکمه‌های تست
            // نمایش لاگ‌های اخیر
          ],
        ),
      ),
    );
  }
}
```

## Validation Rules
- بررسی اتصال موفق به MySQL (پورت 3307)
- تست ایجاد و خواندن جدول system_settings
- تست ثبت لاگ در جدول system_logs
- بررسی عملکرد Logger در Console و Database
- تست رمزنگاری/رمزگشایی برای API Keys

## اقدامات پس از تکمیل
1. اجرای `flutter pub get`
2. اجرای اسکریپت SQL در phpMyAdmin
3. تست اجرا با `flutter run -d chrome`
4. بررسی لاگ‌ها در جدول system_logs
5. Screenshot صفحه تست سیستم

## گزارش مورد انتظار
- وضعیت اتصال دیتابیس (موفق/ناموفق)
- تعداد لاگ‌های ثبت شده در دیتابیس
- Screenshot رابط کاربری با نتایج تست
- لیست تنظیمات بارگذاری شده از جدول
- مشکلات احتمالی و راه‌حل‌ها

## نکات مهم
- رمز عبور دیتابیس: `Mojtab@123`
- پورت MySQL: `3307` (نه 3306)
- Character Set: `utf8mb4_persian_ci`
- تمام لاگ‌ها هم در Console و هم در Database ثبت شوند
- API Key های حساس باید رمزنگاری شوند
```

---


**تأکیدات کلیدی:**
✅ **بدون Authentication** - فقط Logger + Database  
✅ **پورت 3307** و رمز `Mojtab@123`  
✅ **جدول تنظیمات قابل توسعه** برای OpenAI  
✅ **تست کامل سیستم** در صفحه اصلی  

آماده دریافت گزارش نتیجه هستم! 🚀