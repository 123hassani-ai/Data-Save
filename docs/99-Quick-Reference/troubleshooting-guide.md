# راهنمای عیب‌یابی - Troubleshooting Guide

## 📊 Document Information
- **Created:** 2025-09-01
- **Last Updated:** 2025-09-01
- **Version:** 1.0
- **Maintainer:** DataSave Development Team
- **Related Files:** `logs/`, `backend/api/logs/`

## 🎯 Overview
راهنمای جامع عیب‌یابی مشکلات رایج در DataSave شامل مشکلات Backend، Frontend، Database، و API integration با راه‌حل‌های قدم به قدم.

## 📋 Table of Contents
- [مشکلات رایج Backend](#مشکلات-رایج-backend)
- [مشکلات Flutter Frontend](#مشکلات-flutter-frontend)
- [مشکلات Database](#مشکلات-database)
- [مشکلات API Integration](#مشکلات-api-integration)
- [مشکلات Persian RTL](#مشکلات-persian-rtl)
- [مشکلات Performance](#مشکلات-performance)
- [ابزارهای Debug](#ابزارهای-debug)
- [لاگ‌های سیستم](#لاگهای-سیستم)

## 🔧 مشکلات رایج Backend - Common Backend Issues

### 1. خطای اتصال به دیتابیس
**علائم:**
```
PDOException: SQLSTATE[HY000] [2002] Connection refused
```

**علت‌های احتمالی:**
- XAMPP خاموش است
- MySQL service اجرا نمی‌شود  
- تنظیمات دیتابیس اشتباه است
- Port مسدود است

**راه‌حل:**
```bash
# بررسی وضعیت XAMPP
sudo /Applications/XAMPP/xamppfiles/xampp status

# راه‌اندازی XAMPP
sudo /Applications/XAMPP/xamppfiles/xampp start

# بررسی Port MySQL (باید 3307 باشد)
netstat -an | grep 3307

# بررسی تنظیمات در database.php
cat backend/config/database.php
```

**پیکربندی صحیح دیتابیس:**
```php
// backend/config/database.php
private static $host = 'localhost';
private static $port = '3307';  // نه 3306
private static $database = 'datasave';
private static $username = 'root';
private static $password = 'Mojtab@123';  // طبق .github/instructions/roles.instructions.md
```

### 2. خطای CORS
**علائم:**
```
Access to XMLHttpRequest blocked by CORS policy
```

**راه‌حل:**
```php
// backend/config/cors.php - بررسی کنید موجود باشد
header("Access-Control-Allow-Origin: http://localhost:8085");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}
```

### 3. خطای مجوز فایل
**علائم:**
```
Warning: file_get_contents(): failed to open stream: Permission denied
```

**راه‌حل:**
```bash
# تنظیم مجوزها
chmod -R 755 /Applications/XAMPP/xamppfiles/htdocs/datasave
chmod -R 777 backend/api/logs/

# بررسی ownership
ls -la backend/api/logs/
```

### 4. خطای JSON parsing
**علائم:**
```
Syntax error in JSON at position X
```

**راه‌حل:**
```php
// بررسی JSON قبل از decode
$input = file_get_contents('php://input');
if (!json_decode($input)) {
    ApiResponse::clientError('فرمت JSON نامعتبر است');
    exit;
}

// استفاده از validation
if (!$this->validateJsonInput($input)) {
    ApiResponse::clientError('داده‌های ورودی نامعتبر');
    exit;
}
```

---

## 📱 مشکلات Flutter Frontend - Flutter Frontend Issues

### 1. خطای Hot Reload
**علائم:**
```
Hot reload was rejected
```

**راه‌حل:**
```bash
# Restart Flutter app
flutter run

# Clear cache
flutter clean
flutter pub get

# Reset Flutter SDK
flutter doctor
flutter upgrade
```

### 2. خطای Package Dependencies
**علائم:**
```
Because datasave depends on package_name ^1.0.0 which doesn't match any versions
```

**راه‌حل:**
```bash
# Update dependencies
flutter pub upgrade

# Clear pub cache
flutter pub cache clean

# Fix version conflicts in pubspec.yaml
dependencies:
  package_name: ^1.0.0  # استفاده از version range مناسب
```

### 3. خطای Build
**علائم:**
```
FAILURE: Build failed with an exception
```

**راه‌حل:**
```bash
# Clean build
flutter clean
flutter pub get

# Check Flutter doctor
flutter doctor -v

# Rebuild
flutter build web
```

### 4. خطای State Management
**علائم:**
```
setState() called after dispose()
```

**راه‌حل:**
```dart
// Check if widget is still mounted
if (mounted) {
  setState(() {
    // Update state
  });
}

// Proper disposal in dispose method
@override
void dispose() {
  _controller.dispose();
  super.dispose();
}
```

---

## 🗄️ مشکلات Database - Database Issues

### 1. خطای Character Set
**علائم:**
```
Persian text displays as ????
```

**راه‌حل:**
```sql
-- بررسی charset دیتابیس
SHOW VARIABLES LIKE 'character_set%';

-- تنظیم charset صحیح
ALTER DATABASE datasave CHARACTER SET utf8mb4 COLLATE utf8mb4_persian_ci;

-- برای جداول موجود
ALTER TABLE system_settings CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_persian_ci;
ALTER TABLE system_logs CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_persian_ci;
```

### 2. خطای Foreign Key
**علائم:**
```
Cannot add foreign key constraint
```

**راه‌حل:**
```sql
-- بررسی FOREIGN_KEY_CHECKS
SET FOREIGN_KEY_CHECKS = 0;

-- اجرای migration
-- INSERT/UPDATE operations

SET FOREIGN_KEY_CHECKS = 1;

-- بررسی consistency داده‌ها
SELECT * FROM information_schema.KEY_COLUMN_USAGE 
WHERE REFERENCED_TABLE_SCHEMA = 'datasave';
```

### 3. مشکل Backup/Restore
**علائم:**
```
Access denied for user 'root'@'localhost'
```

**راه‌حل:**
```bash
# Backup با credentials صحیح
mysqldump -h localhost -P 3307 -u root -pMojtab@123 datasave > backup.sql

# Restore
mysql -h localhost -P 3307 -u root -pMojtab@123 datasave < backup.sql

# بررسی اتصال
mysql -h localhost -P 3307 -u root -pMojtab@123 -e "SHOW DATABASES;"
```

---

## 🔗 مشکلات API Integration - API Integration Issues

### 1. خطای Network Timeout
**علائم:**
```
SocketException: Connection timed out
```

**راه‌حل:**
```dart
// افزایش timeout در Dio
final dio = Dio(BaseOptions(
  connectTimeout: Duration(seconds: 30),
  receiveTimeout: Duration(seconds: 30),
  sendTimeout: Duration(seconds: 30),
));

// Retry mechanism
Future<T?> retryRequest<T>(Future<T> Function() request) async {
  for (int i = 0; i < 3; i++) {
    try {
      return await request();
    } catch (e) {
      if (i == 2) rethrow;
      await Future.delayed(Duration(seconds: pow(2, i).toInt()));
    }
  }
  return null;
}
```

### 2. خطای API Response Format
**علائم:**
```
type 'String' is not a subtype of type 'Map<String, dynamic>'
```

**راه‌حل:**
```dart
// Validation قبل از استفاده
Future<List<Map<String, dynamic>>?> getSettings() async {
  try {
    final response = await _dio.get('/api/settings/get.php');
    
    // بررسی response format
    if (response.data is! Map<String, dynamic>) {
      throw FormatException('Invalid response format');
    }
    
    final data = response.data as Map<String, dynamic>;
    
    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'API Error');
    }
    
    // بررسی data field
    if (data['data'] is! List) {
      throw FormatException('Data field is not a list');
    }
    
    return List<Map<String, dynamic>>.from(data['data']);
    
  } catch (e) {
    LoggerService.error('API', 'خطا در دریافت تنظیمات', e);
    return null;
  }
}
```

### 3. خطای OpenAI API
**علائم:**
```
OpenAI API Error 401: Invalid API key
```

**راه‌حل:**
```dart
// بررسی API key
final apiKey = await SecureStorage.getApiKey();
if (apiKey == null || apiKey.isEmpty) {
  throw Exception('OpenAI API Key تنظیم نشده است');
}

// بررسی format API key
if (!apiKey.startsWith('sk-')) {
  throw Exception('فرمت OpenAI API Key نامعتبر است');
}

// Test connection
final testResponse = await OpenAIService.testConnection();
if (!testResponse) {
  throw Exception('اتصال به OpenAI برقرار نشد');
}
```

---

## 🌐 مشکلات Persian RTL - Persian RTL Issues

### 1. مشکل Text Direction
**علائم:**
- متن فارسی چپ‌چین نمایش داده می‌شود
- آیکون‌ها در جای اشتباه قرار دارند

**راه‌حل:**
```dart
// استفاده از Directionality
Directionality(
  textDirection: TextDirection.rtl,
  child: YourWidget(),
)

// یا در سطح MaterialApp
MaterialApp(
  locale: Locale('fa', 'IR'),
  supportedLocales: [
    Locale('fa', 'IR'),
    Locale('en', 'US'),
  ],
  localizationsDelegates: [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
)
```

### 2. مشکل Persian Numbers
**علائم:**
- اعداد انگلیسی نمایش داده می‌شوند

**راه‌حل:**
```dart
// Utility for Persian numbers
String toPersianNumbers(String input) {
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
  
  String result = input;
  for (int i = 0; i < english.length; i++) {
    result = result.replaceAll(english[i], persian[i]);
  }
  return result;
}

// استفاده در Widget
Text(toPersianNumbers('123')), // نمایش: ۱۲۳
```

### 3. مشکل Font Rendering
**علائم:**
- فونت فارسی به درستی نمایش داده نمی‌شود

**راه‌حل:**
```yaml
# pubspec.yaml
flutter:
  fonts:
    - family: Vazirmatn
      fonts:
        - asset: assets/fonts/Vazirmatn-Regular.ttf
        - asset: assets/fonts/Vazirmatn-Bold.ttf
          weight: 700
```

```dart
// در Theme
ThemeData(
  fontFamily: 'Vazirmatn',
  textTheme: TextTheme(
    bodyLarge: TextStyle(
      fontFamily: 'Vazirmatn',
      fontSize: 16,
    ),
  ),
)
```

---

## ⚡ مشکلات Performance - Performance Issues

### 1. Slow API Response
**علائم:**
- API ها بیش از 2 ثانیه طول می‌کشند

**راه‌حل:**
```php
// بررسی slow queries
SET long_query_time = 1;
SET global slow_query_log = 'ON';

// اضافه کردن indexes
ALTER TABLE system_settings ADD INDEX idx_setting_key (setting_key);
ALTER TABLE system_logs ADD INDEX idx_created_at (created_at);
ALTER TABLE system_logs ADD INDEX idx_level (level);

// بهینه‌سازی queries
// به جای SELECT *
SELECT setting_key, setting_value, setting_type FROM system_settings;
```

### 2. Flutter App Laggy
**علائم:**
- UI lag و jank دارد

**راه‌حل:**
```dart
// استفاده از const constructors
const StatCard(
  title: 'تنظیمات',
  value: '9',
  icon: Icons.settings,
)

// Lazy loading برای lists
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListTile(/* ... */);
  },
)

// Image caching
CachedNetworkImage(
  imageUrl: imageUrl,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
```

### 3. Memory Leaks
**علائم:**
- App crash با OutOfMemory

**راه‌حل:**
```dart
// Proper disposal
@override
void dispose() {
  _controller.dispose();
  _subscription?.cancel();
  super.dispose();
}

// StreamBuilder proper usage
StreamBuilder<List<LogEntry>>(
  stream: logsStream,
  builder: (context, snapshot) {
    // Handle stream data
  },
)
```

---

## 🛠️ ابزارهای Debug - Debug Tools

### 1. Flutter Inspector
```bash
# اجرای Flutter با debug mode
flutter run --debug

# باز کردن DevTools
flutter pub global activate devtools
flutter pub global run devtools

# در browser: http://127.0.0.1:9100
```

### 2. Network Debugging
```dart
// اضافه کردن LogInterceptor به Dio
dio.interceptors.add(LogInterceptor(
  requestBody: true,
  responseBody: true,
  requestHeader: true,
  responseHeader: true,
  error: true,
  logPrint: (object) => debugPrint(object.toString()),
));
```

### 3. Database Debugging
```sql
-- فعال کردن MySQL logging
SET GLOBAL general_log = 'ON';
SET GLOBAL log_output = 'file';
SET GLOBAL general_log_file = '/tmp/mysql.log';

-- مشاهده queries
SHOW PROCESSLIST;

-- تحلیل performance
EXPLAIN SELECT * FROM system_settings WHERE setting_key = 'openai_api_key';
```

---

## 📊 لاگ‌های سیستم - System Logs

### 1. Flutter Logs
```dart
// Console logs
print('Debug message');
debugPrint('Debug message with timestamp');

// Using Logger service
LoggerService.info('Category', 'پیام اطلاعاتی');
LoggerService.warning('Category', 'پیام هشدار');
LoggerService.error('Category', 'پیام خطا', error);
```

### 2. PHP Backend Logs
```php
// PHP error logs
error_log("Debug message: " . print_r($data, true));

// Custom logging
$logger = new Logger();
$logger->info('API', 'درخواست دریافت تنظیمات');
$logger->error('Database', 'خطا در اتصال', $exception);
```

### 3. System Log Analysis
```bash
# مشاهده PHP error logs
tail -f /Applications/XAMPP/xamppfiles/logs/php_error_log

# MySQL error logs  
tail -f /Applications/XAMPP/xamppfiles/var/mysql/mysql_error.log

# Apache access logs
tail -f /Applications/XAMPP/xamppfiles/logs/access_log
```

---

## 🚨 Emergency Procedures

### 1. Database Recovery
```bash
# Backup فوری
mysqldump -h localhost -P 3307 -u root -pMojtab@123 datasave > emergency_backup_$(date +%Y%m%d_%H%M%S).sql

# Restore از backup
mysql -h localhost -P 3307 -u root -pMojtab@123 datasave < backup_file.sql

# بررسی data integrity
mysql -h localhost -P 3307 -u root -pMojtab@123 -e "
USE datasave;
SELECT COUNT(*) FROM system_settings;
SELECT COUNT(*) FROM system_logs;
"
```

### 2. Service Restart
```bash
# کامل restart XAMPP
sudo /Applications/XAMPP/xamppfiles/xampp stop
sudo /Applications/XAMPP/xamppfiles/xampp start

# فقط MySQL restart
sudo /Applications/XAMPP/xamppfiles/xampp stopmysql
sudo /Applications/XAMPP/xamppfiles/xampp startmysql
```

### 3. Clean Installation
```bash
# Flutter clean build
flutter clean
flutter pub get
flutter pub upgrade
flutter build web

# Clear all caches
flutter pub cache clean
rm -rf .dart_tool/
rm -rf build/
```

---

## 📞 Getting Help

### 1. Log Collection
قبل از درخواست کمک، این اطلاعات را جمع‌آوری کنید:

```bash
# System info
flutter doctor -v > system_info.txt
php -v >> system_info.txt
mysql --version >> system_info.txt

# Error logs
tail -100 /Applications/XAMPP/xamppfiles/logs/php_error_log > error_logs.txt

# App logs (از داخل Flutter app)
# Export logs از صفحه Logs
```

### 2. Issue Reporting Template
```markdown
**مشکل:** [توضیح مختصر مشکل]

**قدم‌های تکرار:**
1. 
2. 
3. 

**نتیجه مورد انتظار:**
[چه چیزی انتظار داشتید اتفاق بیفتد]

**نتیجه واقعی:**  
[چه چیزی واقعاً اتفاق افتاد]

**محیط:**
- OS: macOS [version]
- Flutter: [version]
- PHP: [version] 
- MySQL: [version]

**لاگ‌های خطا:**
```
[paste error logs here]
```

**تصاویر/GIFs:**
[در صورت امکان]
```

---

## ⚠️ Important Notes

### Prevention Tips
- همیشه قبل از تغییرات مهم backup بگیرید
- تست کامل قبل از production deployment  
- Monitor کردن منظم performance metrics
- بروزرسانی منظم dependencies
- Documentation مداوم مشکلات و راه‌حل‌ها

### When to Seek Help
- مشکلات security-related
- Data loss یا corruption
- Performance degradation شدید
- مشکلات production environment
- خطاهای غیرمنتظره و تکراری

---

## 🔄 Related Documentation
- [Development Environment](../07-Development-Workflow/development-environment.md)
- [Logging System](../05-Services-Integration/logging-system.md)
- [Database Design](../03-Database-Schema/database-design.md)
- [API Endpoints Reference](../02-Backend-APIs/api-endpoints-reference.md)

## 📚 References
- [Flutter Debugging Guide](https://docs.flutter.dev/testing/debugging)
- [PHP Error Handling](https://www.php.net/manual/en/book.errorfunc.php)
- [MySQL Troubleshooting](https://dev.mysql.com/doc/refman/8.0/en/problems.html)
- [XAMPP Documentation](https://www.apachefriends.org/docs/)

---
*Last updated: 2025-09-01*  
*File: docs/99-Quick-Reference/troubleshooting-guide.md*