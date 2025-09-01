
## 🏗️ معماری پیشنهادی

```
Flutter Web ↔️ PHP Backend API ↔️ MySQL (XAMPP)
```

**مزایا:**
✅ استفاده کامل از XAMPP موجود  
✅ PHP سریع و مناسب برای API  
✅ MySQL بدون محدودیت  
✅ آماده‌سازی برای Production  

---

## 🚀 پرامپت مرحله دوم: PHP Backend + Flutter Frontend

```markdown
# 🎯 ماموریت: راه‌اندازی PHP Backend API + Flutter Frontend - مرحله دوم

## هدف
ایجاد Backend API با PHP + اتصال Flutter Web + سیستم Logger کامل + مدیریت تنظیمات

## Context فنی
- **Backend:** PHP 8+ (XAMPP)
- **Database:** MySQL پورت 3307 - رمز: `Mojtab@123`
- **Frontend:** Flutter Web
- **API:** RESTful با JSON Response
- **مسیر Backend:** `/Applications/XAMPP/xamppfiles/htdocs/datasave/backend/`

## اقدامات مورد نیاز

### 1️⃣ ساختار Backend PHP

**ایجاد ساختار فایل‌ها:**
```
backend/
├── config/
│   ├── database.php          # تنظیمات دیتابیس
│   └── cors.php             # تنظیمات CORS
├── api/
│   ├── settings/
│   │   ├── get.php          # دریافت تنظیمات
│   │   ├── update.php       # بروزرسانی تنظیمات
│   │   └── test.php         # تست اتصال
│   ├── logs/
│   │   ├── create.php       # ایجاد لاگ
│   │   ├── list.php         # لیست لاگ‌ها
│   │   └── clear.php        # پاکسازی لاگ‌ها
│   └── system/
│       ├── status.php       # وضعیت سیستم
│       └── info.php         # اطلاعات سرور
├── classes/
│   ├── Database.php         # کلاس دیتابیس
│   ├── Logger.php           # کلاس لاگینگ
│   └── ApiResponse.php      # فرمت پاسخ API
├── sql/
│   └── create_tables.sql    # اسکریپت ایجاد جداول
└── index.php               # صفحه اصلی API
```

### 2️⃣ فایل‌های Backend PHP

**backend/config/database.php:**
```php
<?php
/**
 * تنظیمات اتصال به پایگاه داده MySQL
 */
class DatabaseConfig {
    public const HOST = 'localhost';
    public const PORT = 3307;
    public const DATABASE = 'datasave_db';
    public const USERNAME = 'root';
    public const PASSWORD = 'Mojtab@123';
    public const CHARSET = 'utf8mb4';
    
    public static function getConnectionString(): string {
        return sprintf(
            "mysql:host=%s;port=%d;dbname=%s;charset=%s",
            self::HOST,
            self::PORT,
            self::DATABASE,
            self::CHARSET
        );
    }
}

/**
 * کلاس مدیریت دیتابیس
 */
class Database {
    private static ?PDO $connection = null;
    
    public static function getConnection(): PDO {
        if (self::$connection === null) {
            try {
                self::$connection = new PDO(
                    DatabaseConfig::getConnectionString(),
                    DatabaseConfig::USERNAME,
                    DatabaseConfig::PASSWORD,
                    [
                        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                        PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8mb4 COLLATE utf8mb4_persian_ci"
                    ]
                );
            } catch (PDOException $e) {
                throw new Exception("خطا در اتصال دیتابیس: " . $e->getMessage());
            }
        }
        
        return self::$connection;
    }
    
    public static function testConnection(): array {
        try {
            $pdo = self::getConnection();
            $stmt = $pdo->query("SELECT 1 as test, NOW() as server_time");
            $result = $stmt->fetch();
            
            return [
                'success' => true,
                'message' => 'اتصال دیتابیس برقرار است',
                'server_time' => $result['server_time'],
                'charset' => 'utf8mb4_persian_ci'
            ];
        } catch (Exception $e) {
            return [
                'success' => false,
                'message' => 'خطا در اتصال: ' . $e->getMessage()
            ];
        }
    }
}
?>
```

**backend/config/cors.php:**
```php
<?php
/**
 * تنظیمات CORS برای Flutter Web
 */
header('Access-Control-Allow-Origin: http://localhost:3000');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
header('Access-Control-Allow-Credentials: true');
header('Content-Type: application/json; charset=utf-8');

// پاسخ به درخواست‌های OPTIONS (Preflight)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}
?>
```

**backend/classes/ApiResponse.php:**
```php
<?php
/**
 * کلاس استاندارد پاسخ‌های API
 */
class ApiResponse {
    public static function success($data = null, string $message = 'موفق'): void {
        http_response_code(200);
        echo json_encode([
            'success' => true,
            'message' => $message,
            'data' => $data,
            'timestamp' => date('Y-m-d H:i:s')
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }
    
    public static function error(string $message, int $code = 400, $details = null): void {
        http_response_code($code);
        echo json_encode([
            'success' => false,
            'message' => $message,
            'details' => $details,
            'timestamp' => date('Y-m-d H:i:s')
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }
    
    public static function notFound(string $message = 'یافت نشد'): void {
        self::error($message, 404);
    }
    
    public static function serverError(string $message = 'خطای سرور'): void {
        self::error($message, 500);
    }
}
?>
```

**backend/classes/Logger.php:**
```php
<?php
/**
 * سیستم لاگینگ PHP
 */
class Logger {
    private PDO $db;
    
    public function __construct() {
        $this->db = Database::getConnection();
    }
    
    public function log(string $level, string $category, string $message, ?array $context = null): bool {
        try {
            $sql = "INSERT INTO system_logs (log_level, log_category, log_message, log_context, ip_address, user_agent) 
                    VALUES (:level, :category, :message, :context, :ip, :user_agent)";
            
            $stmt = $this->db->prepare($sql);
            return $stmt->execute([
                'level' => strtoupper($level),
                'category' => $category,
                'message' => $message,
                'context' => $context ? json_encode($context, JSON_UNESCAPED_UNICODE) : null,
                'ip' => $_SERVER['REMOTE_ADDR'] ?? 'Unknown',
                'user_agent' => $_SERVER['HTTP_USER_AGENT'] ?? 'Unknown'
            ]);
        } catch (Exception $e) {
            error_log("Logger Error: " . $e->getMessage());
            return false;
        }
    }
    
    public function info(string $category, string $message, ?array $context = null): bool {
        return $this->log('INFO', $category, $message, $context);
    }
    
    public function error(string $category, string $message, ?array $context = null): bool {
        return $this->log('ERROR', $category, $message, $context);
    }
    
    public function warning(string $category, string $message, ?array $context = null): bool {
        return $this->log('WARNING', $category, $message, $context);
    }
    
    public function getRecentLogs(int $limit = 20): array {
        try {
            $sql = "SELECT * FROM system_logs ORDER BY created_at DESC LIMIT :limit";
            $stmt = $this->db->prepare($sql);
            $stmt->bindValue('limit', $limit, PDO::PARAM_INT);
            $stmt->execute();
            
            return $stmt->fetchAll();
        } catch (Exception $e) {
            error_log("Get Logs Error: " . $e->getMessage());
            return [];
        }
    }
}
?>
```

**backend/api/settings/get.php:**
```php
<?php
require_once '../../config/cors.php';
require_once '../../config/database.php';
require_once '../../classes/ApiResponse.php';
require_once '../../classes/Logger.php';

try {
    $logger = new Logger();
    $logger->info('API', 'درخواست دریافت تنظیمات');
    
    $db = Database::getConnection();
    $sql = "SELECT * FROM system_settings ORDER BY setting_key";
    $stmt = $db->query($sql);
    $settings = $stmt->fetchAll();
    
    // رمزگشایی فیلدهای encrypted (در صورت نیاز)
    foreach ($settings as &$setting) {
        if ($setting['setting_type'] === 'encrypted' && !empty($setting['setting_value'])) {
            $setting['setting_value'] = '***مخفی***'; // عدم نمایش مقادیر حساس
        }
    }
    
    ApiResponse::success($settings, 'تنظیمات با موفقیت بارگذاری شد');
    
} catch (Exception $e) {
    $logger->error('API', 'خطا در دریافت تنظیمات: ' . $e->getMessage());
    ApiResponse::serverError('خطا در دریافت تنظیمات');
}
?>
```

**backend/api/logs/create.php:**
```php
<?php
require_once '../../config/cors.php';
require_once '../../config/database.php';
require_once '../../classes/ApiResponse.php';
require_once '../../classes/Logger.php';

try {
    // دریافت داده‌های JSON
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!$input || !isset($input['level']) || !isset($input['category']) || !isset($input['message'])) {
        ApiResponse::error('داده‌های ناقص ارسال شده', 400);
    }
    
    $logger = new Logger();
    $result = $logger->log(
        $input['level'],
        $input['category'],
        $input['message'],
        $input['context'] ?? null
    );
    
    if ($result) {
        ApiResponse::success(null, 'لاگ با موفقیت ثبت شد');
    } else {
        ApiResponse::error('خطا در ثبت لاگ');
    }
    
} catch (Exception $e) {
    ApiResponse::serverError('خطای سرور در ثبت لاگ');
}
?>
```

### 3️⃣ اسکریپت SQL

**backend/sql/create_tables.sql:**
```sql
-- ایجاد دیتابیس
CREATE DATABASE IF NOT EXISTS `datasave_db` 
DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_persian_ci;

USE `datasave_db`;

-- جدول تنظیمات سیستم
CREATE TABLE IF NOT EXISTS `system_settings` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `setting_key` VARCHAR(100) UNIQUE NOT NULL COMMENT 'کلید تنظیمات',
  `setting_value` TEXT COMMENT 'مقدار تنظیمات',
  `setting_type` ENUM('string','json','boolean','number','encrypted') DEFAULT 'string',
  `description` VARCHAR(255) COMMENT 'توضیحات',
  `is_system` BOOLEAN DEFAULT FALSE COMMENT 'تنظیمات سیستمی',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  INDEX idx_setting_key (`setting_key`),
  INDEX idx_is_system (`is_system`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci;

-- جدول لاگ‌ها
CREATE TABLE IF NOT EXISTS `system_logs` (
  `log_id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `log_level` ENUM('DEBUG','INFO','WARNING','ERROR','CRITICAL') NOT NULL,
  `log_category` VARCHAR(50) NOT NULL,
  `log_message` TEXT NOT NULL,
  `log_context` JSON,
  `ip_address` VARCHAR(45),
  `user_agent` TEXT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  INDEX idx_log_level (`log_level`),
  INDEX idx_log_category (`log_category`),
  INDEX idx_created_at (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci;

-- درج تنظیمات پیش‌فرض
INSERT IGNORE INTO `system_settings` (`setting_key`, `setting_value`, `setting_type`, `description`, `is_system`) VALUES
('openai_api_key', '', 'encrypted', 'کلید API سرویس OpenAI', true),
('openai_model', 'gpt-4', 'string', 'مدل پیش‌فرض OpenAI', true),
('openai_max_tokens', '2048', 'number', 'حداکثر توکن پاسخ', true),
('app_language', 'fa', 'string', 'زبان پیش‌فرض', true),
('enable_logging', 'true', 'boolean', 'فعال‌سازی لاگ', true),
('max_log_entries', '1000', 'number', 'حداکثر تعداد لاگ', false);
```

### 4️⃣ بروزرسانی Flutter Frontend

**pubspec.yaml (حذف mysql1):**
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # بدون تغییر موارد قبلی + اضافه:
  http: ^1.1.2
  dio: ^5.4.0
  
  # حذف شود:
  # mysql1: ^0.20.0  ❌
```

**lib/core/services/api_service.dart:**
```dart
/// سرویس ارتباط با Backend API
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://localhost/datasave/backend/api';
  
  /// دریافت تنظیمات از سرور
  static Future<List<Map<String, dynamic>>> getSettings() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/settings/get.php'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success']) {
          return List<Map<String, dynamic>>.from(jsonResponse['data']);
        }
      }
      throw Exception('خطا در دریافت تنظیمات');
    } catch (e) {
      throw Exception('خطا در ارتباط با سرور: $e');
    }
  }
  
  /// ارسال لاگ به سرور
  static Future<bool> sendLog(String level, String category, String message, [Map<String, dynamic>? context]) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/logs/create.php'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: json.encode({
          'level': level,
          'category': category,
          'message': message,
          'context': context,
        }),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('خطا در ارسال لاگ: $e');
      return false;
    }
  }
  
  /// تست اتصال سرور
  static Future<Map<String, dynamic>> testConnection() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/system/status.php'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'message': 'سرور در دسترس نیست'};
    } catch (e) {
      return {'success': false, 'message': 'خطا در اتصال: $e'};
    }
  }
}
```

**lib/core/logger/logger_service.dart (بروزرسانی):**
```dart
/// Logger با ارسال به Backend
import '../services/api_service.dart';

class LoggerService {
  static void info(String category, String message, [Map<String, dynamic>? context]) {
    print('INFO: [$category] $message');
    ApiService.sendLog('INFO', category, message, context);
  }
  
  static void error(String category, String message, [dynamic error]) {
    print('ERROR: [$category] $message');
    final context = error != null ? {'error': error.toString()} : null;
    ApiService.sendLog('ERROR', category, message, context);
  }
  
  static void warning(String category, String message, [Map<String, dynamic>? context]) {
    print('WARNING: [$category] $message');
    ApiService.sendLog('WARNING', category, message, context);
  }
  
  // سایر متدها...
}
```

## Validation Rules
- بررسی اجرای موفق اسکریپت SQL در phpMyAdmin
- تست API endpoints با Postman/Browser
- تست اتصال Flutter به PHP Backend
- بررسی ثبت لاگ‌ها در دیتابیس MySQL
- تایید فرمت JSON صحیح پاسخ‌ها

## اقدامات پس از تکمیل
1. ایجاد ساختار Backend در مسیر XAMPP
2. اجرای اسکریپت SQL در phpMyAdmin
3. تست API ها از مرورگر
4. بروزرسانی Flutter و تست اتصال
5. Screenshot نتایج تست

## گزارش مورد انتظار
- URL های API و وضعیت عملکرد
- تعداد تنظیمات بارگذاری شده از دیتابیس
- تعداد لاگ‌های ثبت شده در MySQL
- Screenshot رابط Flutter با داده‌های Backend
- نتایج تست Performance API
```

---

**🎯 این راه‌حل کامل:**
✅ **PHP Backend** با XAMPP  
✅ **MySQL** بدون محدودیت  
✅ **RESTful API** استاندارد  
✅ **Flutter Web** متصل به Backend  
✅ **Logger System** دوطرفه  

آماده اجراست! 🚀