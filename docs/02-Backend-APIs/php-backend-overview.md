# مرور کلی Backend PHP - PHP Backend Overview

## 📊 Document Information
- **Created:** 2025-01-09
- **Last Updated:** 2025-01-09
- **Version:** 1.0
- **Maintainer:** DataSave Development Team
- **Related Files:** `/backend/`, `/backend/api/`, `/backend/classes/`

## 🎯 Overview
این سند نمای کلی و جامعی از backend PHP پروژه DataSave ارائه می‌دهد. Backend بر اساس معماری RESTful API طراحی شده و با پشتیبانی کامل از محتوای فارسی و UTF-8 پیاده‌سازی شده است.

## 📋 Table of Contents
- [معماری Backend](#معماری-backend)
- [ساختار API](#ساختار-api)
- [کلاس‌ها و ابزارها](#کلاسها-و-ابزارها)
- [مدیریت داده](#مدیریت-داده)
- [امنیت و اعتبارسنجی](#امنیت-و-اعتبارسنجی)
- [مدیریت خطا](#مدیریت-خطا)
- [عملکرد و بهینه‌سازی](#عملکرد-و-بهینهسازی)

## 🏗️ معماری Backend

### Tech Stack
```yaml
Runtime Environment:
  - PHP: 8.0+
  - Web Server: Apache 2.4 (XAMPP)
  - Database: MySQL 8.0
  - Character Set: UTF8MB4 (Persian support)

Development Environment:
  - XAMPP: 8.2+
  - Document Root: /Applications/XAMPP/xamppfiles/htdocs/
  - Project Path: /Applications/XAMPP/xamppfiles/htdocs/datasave-api/
  
External APIs:
  - OpenAI API: GPT-4 integration
  - Persian Tools: Text processing utilities

Configuration:
  - Port: 80 (HTTP), 443 (HTTPS)
  - MySQL Port: 3307 (Custom)
  - PHP Memory Limit: 512M
  - Max Execution Time: 60s
  - Upload Max Size: 64M
```

### Architecture Pattern
```
┌─────────────────────────────────────────────────────────────┐
│                     CLIENT LAYER                            │
│              (Flutter Web Application)                      │
└─────────────────────────┬───────────────────────────────────┘
                          │ HTTP/JSON Requests
┌─────────────────────────┴───────────────────────────────────┐
│                     API LAYER                               │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │   Settings  │  │    Logs     │  │      System         │ │
│  │   Endpoints │  │  Endpoints  │  │    Endpoints        │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
└─────────────────────────┬───────────────────────────────────┘
                          │
┌─────────────────────────┴───────────────────────────────────┐
│                   BUSINESS LOGIC                            │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │ ApiResponse │  │   Logger    │  │   Configuration     │ │
│  │    Class    │  │   Class     │  │     Manager         │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
└─────────────────────────┬───────────────────────────────────┘
                          │
┌─────────────────────────┴───────────────────────────────────┐
│                    DATA LAYER                               │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │    MySQL    │  │ File System │  │   External APIs     │ │
│  │  Database   │  │    Logs     │  │     (OpenAI)        │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## 📂 ساختار API

### Directory Structure
```
backend/
├── index.php                      # Entry point اصلی
├── api/                           # REST API endpoints
│   ├── settings/                  # مدیریت تنظیمات
│   │   ├── get.php               # دریافت تنظیمات
│   │   ├── update.php            # بروزرسانی تنظیمات
│   │   └── test.php              # تست اتصال OpenAI
│   ├── logs/                     # مدیریت لاگ‌ها
│   │   ├── create.php            # ایجاد لاگ جدید
│   │   ├── list.php              # لیست لاگ‌ها
│   │   ├── stats.php             # آمار لاگ‌ها
│   │   └── clear.php             # پاک کردن لاگ‌ها
│   └── system/                   # اطلاعات سیستم
│       ├── info.php              # اطلاعات سیستم
│       └── status.php            # وضعیت سیستم
├── classes/                      # کلاس‌های PHP
│   ├── ApiResponse.php           # کلاس پاسخ استاندارد
│   └── Logger.php                # کلاس لاگینگ
├── config/                       # پیکربندی
│   ├── database.php              # تنظیمات دیتابیس
│   └── cors.php                  # تنظیمات CORS
└── sql/                          # اسکریپت‌های SQL
    └── create_tables.sql         # ایجاد جداول
```

### API Endpoints Overview
```yaml
Settings Management:
  GET /api/settings/get.php:
    - Purpose: دریافت تمام تنظیمات سیستم
    - Response: Array of settings with Persian descriptions
    - Security: Sensitive values masked
    
  POST /api/settings/update.php:
    - Purpose: بروزرسانی تنظیمات
    - Input: key, value
    - Validation: Type checking, Persian content support
    
  POST /api/settings/test.php:
    - Purpose: تست اتصال OpenAI API
    - Validation: API key format, connection test
    - Response: Connection status with Persian message

Logging System:
  POST /api/logs/create.php:
    - Purpose: ایجاد لاگ جدید
    - Input: level, message, context
    - Features: Persian message support, JSON context
    
  GET /api/logs/list.php:
    - Purpose: دریافت لیست لاگ‌ها
    - Pagination: limit, offset parameters
    - Filtering: By level, date range
    
  GET /api/logs/stats.php:
    - Purpose: آمار لاگ‌های سیستم
    - Metrics: Count by level, recent activity
    - Persian: Localized statistics
    
  DELETE /api/logs/clear.php:
    - Purpose: پاک کردن لاگ‌های قدیمی
    - Options: By date, by level, complete clear

System Information:
  GET /api/system/info.php:
    - Purpose: اطلاعات سیستم PHP و MySQL
    - Data: Version info, configuration, extensions
    - Persian: Localized system information
    
  GET /api/system/status.php:
    - Purpose: وضعیت سلامت سیستم
    - Checks: Database connection, disk space, memory
    - Response: Health status with Persian descriptions
```

## 🛠️ کلاس‌ها و ابزارها

### ApiResponse Class
```php
<?php
// classes/ApiResponse.php

/**
 * کلاس استاندارد پاسخ API
 * Standard API Response Class
 * 
 * @author DataSave Development Team
 * @version 1.0
 * @since 2025-01-09
 */
class ApiResponse 
{
    private bool $success;
    private string $message;
    private mixed $data;
    private array $errors;
    private array $meta;
    private string $timestamp;
    
    /**
     * سازنده کلاس پاسخ API
     * API Response Constructor
     */
    public function __construct(
        bool $success = true,
        string $message = '',
        mixed $data = null,
        array $errors = [],
        array $meta = []
    ) {
        $this->success = $success;
        $this->message = $message;
        $this->data = $data;
        $this->errors = $errors;
        $this->meta = $meta;
        $this->timestamp = date('Y-m-d H:i:s');
    }
    
    /**
     * ایجاد پاسخ موفقیت‌آمیز
     * Create success response
     */
    public static function success(
        mixed $data = null, 
        string $message = 'عملیات با موفقیت انجام شد',
        array $meta = []
    ): self {
        return new self(
            success: true,
            message: $message,
            data: $data,
            meta: $meta
        );
    }
    
    /**
     * ایجاد پاسخ خطا
     * Create error response
     */
    public static function error(
        string $message = 'خطا در انجام عملیات',
        array $errors = [],
        mixed $data = null
    ): self {
        return new self(
            success: false,
            message: $message,
            data: $data,
            errors: $errors
        );
    }
    
    /**
     * تبدیل به JSON با پشتیبانی فارسی
     * Convert to JSON with Persian support
     */
    public function toJson(): string {
        return json_encode([
            'success' => $this->success,
            'message' => $this->message,
            'data' => $this->data,
            'errors' => $this->errors,
            'meta' => array_merge($this->meta, [
                'timestamp' => $this->timestamp,
                'server_time' => date('H:i:s'),
                'locale' => 'fa_IR'
            ])
        ], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
    }
    
    /**
     * تبدیل به آرایه
     * Convert to array
     */
    public function toArray(): array {
        return [
            'success' => $this->success,
            'message' => $this->message,
            'data' => $this->data,
            'errors' => $this->errors,
            'meta' => $this->meta,
            'timestamp' => $this->timestamp
        ];
    }
    
    /**
     * افزودن metadata
     * Add metadata
     */
    public function addMeta(string $key, mixed $value): self {
        $this->meta[$key] = $value;
        return $this;
    }
    
    /**
     * بررسی موفقیت
     * Check if successful
     */
    public function isSuccess(): bool {
        return $this->success;
    }
    
    /**
     * بررسی خطا
     * Check if error
     */
    public function isError(): bool {
        return !$this->success;
    }
}
?>
```

### Logger Class
```php
<?php
// classes/Logger.php

/**
 * کلاس لاگینگ سیستم با پشتیبانی فارسی
 * System Logger Class with Persian Support
 */
class Logger 
{
    private string $logFile;
    private string $logLevel;
    private array $levelHierarchy = [
        'debug' => 0,
        'info' => 1,
        'warning' => 2,
        'error' => 3,
        'critical' => 4
    ];
    
    public function __construct(
        string $logFile = 'logs/system.log',
        string $logLevel = 'info'
    ) {
        $this->logFile = $logFile;
        $this->logLevel = $logLevel;
        
        // ایجاد دایرکتوری logs در صورت عدم وجود
        $logDir = dirname($this->logFile);
        if (!is_dir($logDir)) {
            mkdir($logDir, 0755, true);
        }
    }
    
    /**
     * نوشتن لاگ عمومی
     * Write general log
     */
    public function log(
        string $level, 
        string $message, 
        array $context = [],
        bool $writeToDatabase = true
    ): bool {
        if (!$this->shouldLog($level)) {
            return false;
        }
        
        $logEntry = $this->formatLogEntry($level, $message, $context);
        
        // نوشتن در فایل
        $fileResult = file_put_contents(
            $this->logFile, 
            $logEntry . PHP_EOL, 
            FILE_APPEND | LOCK_EX
        );
        
        // نوشتن در دیتابیس
        $dbResult = true;
        if ($writeToDatabase) {
            $dbResult = $this->writeToDatabase($level, $message, $context);
        }
        
        return $fileResult !== false && $dbResult;
    }
    
    /**
     * لاگ اطلاعات
     * Log info message
     */
    public function info(string $message, array $context = []): bool {
        return $this->log('info', $message, $context);
    }
    
    /**
     * لاگ هشدار
     * Log warning message
     */
    public function warning(string $message, array $context = []): bool {
        return $this->log('warning', $message, $context);
    }
    
    /**
     * لاگ خطا
     * Log error message
     */
    public function error(string $message, array $context = []): bool {
        return $this->log('error', $message, $context);
    }
    
    /**
     * لاگ بحرانی
     * Log critical message
     */
    public function critical(string $message, array $context = []): bool {
        return $this->log('critical', $message, $context);
    }
    
    /**
     * لاگ debug
     * Log debug message
     */
    public function debug(string $message, array $context = []): bool {
        return $this->log('debug', $message, $context);
    }
    
    /**
     * فرمت‌بندی ورودی لاگ
     * Format log entry
     */
    private function formatLogEntry(string $level, string $message, array $context): string {
        $timestamp = date('Y-m-d H:i:s');
        $persianTime = $this->convertToPersianDate($timestamp);
        
        $contextStr = !empty($context) ? json_encode($context, JSON_UNESCAPED_UNICODE) : '';
        
        return sprintf(
            "[%s] [%s] %s %s",
            $timestamp,
            strtoupper($level),
            $message,
            $contextStr
        );
    }
    
    /**
     * بررسی نیاز به ثبت لاگ
     * Check if should log
     */
    private function shouldLog(string $level): bool {
        $currentLevelValue = $this->levelHierarchy[$this->logLevel] ?? 1;
        $messageLevelValue = $this->levelHierarchy[$level] ?? 1;
        
        return $messageLevelValue >= $currentLevelValue;
    }
    
    /**
     * نوشتن در دیتابیس
     * Write to database
     */
    private function writeToDatabase(string $level, string $message, array $context): bool {
        try {
            require_once __DIR__ . '/../config/database.php';
            
            $pdo = new PDO(
                "mysql:host=$host;port=$port;dbname=$dbname;charset=utf8mb4",
                $username,
                $password,
                [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
            );
            
            $stmt = $pdo->prepare("
                INSERT INTO system_logs (log_level, message, context, ip_address, user_agent) 
                VALUES (?, ?, ?, ?, ?)
            ");
            
            return $stmt->execute([
                $level,
                $message,
                !empty($context) ? json_encode($context, JSON_UNESCAPED_UNICODE) : null,
                $_SERVER['REMOTE_ADDR'] ?? null,
                $_SERVER['HTTP_USER_AGENT'] ?? null
            ]);
            
        } catch (Exception $e) {
            // اگر دیتابیس در دسترس نباشد، فقط در فایل بنویس
            error_log("Database logging failed: " . $e->getMessage());
            return false;
        }
    }
    
    /**
     * تبدیل به تاریخ فارسی (ساده)
     * Convert to Persian date (simple)
     */
    private function convertToPersianDate(string $timestamp): string {
        // این یک پیاده‌سازی ساده است - در production از کتابخانه کامل استفاده کنید
        $persianDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
        $englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
        
        return str_replace($englishDigits, $persianDigits, $timestamp);
    }
    
    /**
     * دریافت آمار لاگ‌ها
     * Get log statistics
     */
    public function getStats(): array {
        try {
            require_once __DIR__ . '/../config/database.php';
            
            $pdo = new PDO(
                "mysql:host=$host;port=$port;dbname=$dbname;charset=utf8mb4",
                $username,
                $password
            );
            
            // آمار کلی
            $stmt = $pdo->query("
                SELECT 
                    log_level,
                    COUNT(*) as count
                FROM system_logs 
                WHERE created_at >= DATE_SUB(NOW(), INTERVAL 24 HOUR)
                GROUP BY log_level
            ");
            
            $stats = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            // تعداد کل
            $totalStmt = $pdo->query("SELECT COUNT(*) as total FROM system_logs");
            $total = $totalStmt->fetch(PDO::FETCH_ASSOC)['total'];
            
            return [
                'total_logs' => $total,
                'last_24h' => $stats,
                'levels' => array_keys($this->levelHierarchy)
            ];
            
        } catch (Exception $e) {
            return [
                'error' => 'خطا در دریافت آمار: ' . $e->getMessage()
            ];
        }
    }
}
?>
```

## 🔐 مدیریت داده

### Database Connection
```php
<?php
// config/database.php

/**
 * تنظیمات اتصال به پایگاه داده
 * Database connection configuration
 */

// اطلاعات اتصال XAMPP
$host = 'localhost';
$port = 3307; // پورت سفارشی XAMPP
$dbname = 'datasave';
$username = 'root';
$password = 'Mojtab@123';

// تنظیمات اتصال برای پشتیبانی فارسی
$options = [
    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8mb4",
    PDO::ATTR_EMULATE_PREPARES => false,
    PDO::ATTR_STRINGIFY_FETCHES => false
];

/**
 * ایجاد اتصال PDO
 * Create PDO connection
 */
function createDatabaseConnection(): PDO {
    global $host, $port, $dbname, $username, $password, $options;
    
    try {
        $dsn = "mysql:host=$host;port=$port;dbname=$dbname;charset=utf8mb4";
        $pdo = new PDO($dsn, $username, $password, $options);
        
        // تنظیم timezone برای ایران
        $pdo->exec("SET time_zone = '+03:30'");
        
        return $pdo;
        
    } catch (PDOException $e) {
        throw new Exception('خطا در اتصال به پایگاه داده: ' . $e->getMessage());
    }
}

/**
 * تست اتصال به پایگاه داده
 * Test database connection
 */
function testDatabaseConnection(): array {
    try {
        $pdo = createDatabaseConnection();
        
        // بررسی charset
        $stmt = $pdo->query("SELECT @@character_set_database, @@collation_database");
        $charsetInfo = $stmt->fetch();
        
        // بررسی جداول
        $stmt = $pdo->query("SHOW TABLES");
        $tables = $stmt->fetchAll(PDO::FETCH_COLUMN);
        
        // تست محتوای فارسی
        $stmt = $pdo->query("SELECT 'تست محتوای فارسی' as persian_test");
        $persianTest = $stmt->fetch()['persian_test'];
        
        return [
            'success' => true,
            'message' => 'اتصال به پایگاه داده موفق',
            'charset' => $charsetInfo['@@character_set_database'],
            'collation' => $charsetInfo['@@collation_database'],
            'tables' => $tables,
            'persian_support' => $persianTest === 'تست محتوای فارسی'
        ];
        
    } catch (Exception $e) {
        return [
            'success' => false,
            'message' => 'خطا در اتصال: ' . $e->getMessage()
        ];
    }
}

/**
 * ایجاد جداول در صورت عدم وجود
 * Create tables if not exist
 */
function initializeTables(): bool {
    try {
        $pdo = createDatabaseConnection();
        
        // خواندن فایل SQL
        $sqlFile = __DIR__ . '/../sql/create_tables.sql';
        if (!file_exists($sqlFile)) {
            throw new Exception('فایل SQL یافت نشد');
        }
        
        $sql = file_get_contents($sqlFile);
        $pdo->exec($sql);
        
        return true;
        
    } catch (Exception $e) {
        error_log('Table initialization failed: ' . $e->getMessage());
        return false;
    }
}
?>
```

### Data Access Layer
```php
<?php
// classes/DatabaseManager.php

/**
 * مدیر عملیات دیتابیس
 * Database Operations Manager
 */
class DatabaseManager 
{
    private PDO $pdo;
    private Logger $logger;
    
    public function __construct() {
        $this->pdo = createDatabaseConnection();
        $this->logger = new Logger();
    }
    
    /**
     * دریافت تنظیمات
     * Get settings
     */
    public function getSettings(): array {
        try {
            $stmt = $this->pdo->prepare("
                SELECT setting_key, setting_value, description 
                FROM system_settings 
                WHERE is_active = 1 
                ORDER BY setting_key ASC
            ");
            
            $stmt->execute();
            $settings = $stmt->fetchAll();
            
            $this->logger->info('تنظیمات دریافت شد', ['count' => count($settings)]);
            
            return $settings;
            
        } catch (PDOException $e) {
            $this->logger->error('خطا در دریافت تنظیمات', ['error' => $e->getMessage()]);
            throw new Exception('خطا در دریافت تنظیمات');
        }
    }
    
    /**
     * بروزرسانی تنظیمات
     * Update setting
     */
    public function updateSetting(string $key, string $value): bool {
        try {
            $stmt = $this->pdo->prepare("
                UPDATE system_settings 
                SET setting_value = ?, updated_at = CURRENT_TIMESTAMP 
                WHERE setting_key = ? AND is_active = 1
            ");
            
            $result = $stmt->execute([$value, $key]);
            
            if ($stmt->rowCount() > 0) {
                $this->logger->info('تنظیمات بروزرسانی شد', [
                    'key' => $key,
                    'new_value' => $key === 'openai_api_key' ? '***' : $value
                ]);
                return true;
            } else {
                $this->logger->warning('تنظیمات برای بروزرسانی یافت نشد', ['key' => $key]);
                return false;
            }
            
        } catch (PDOException $e) {
            $this->logger->error('خطا در بروزرسانی تنظیمات', [
                'key' => $key,
                'error' => $e->getMessage()
            ]);
            return false;
        }
    }
    
    /**
     * ایجاد لاگ
     * Create log entry
     */
    public function createLog(string $level, string $message, ?array $context = null): bool {
        try {
            $stmt = $this->pdo->prepare("
                INSERT INTO system_logs (log_level, message, context, ip_address, user_agent) 
                VALUES (?, ?, ?, ?, ?)
            ");
            
            return $stmt->execute([
                $level,
                $message,
                $context ? json_encode($context, JSON_UNESCAPED_UNICODE) : null,
                $_SERVER['REMOTE_ADDR'] ?? null,
                $_SERVER['HTTP_USER_AGENT'] ?? null
            ]);
            
        } catch (PDOException $e) {
            $this->logger->error('خطا در ایجاد لاگ', ['error' => $e->getMessage()]);
            return false;
        }
    }
    
    /**
     * دریافت لاگ‌ها
     * Get logs with pagination
     */
    public function getLogs(int $limit = 50, int $offset = 0, ?string $level = null): array {
        try {
            $whereClause = $level ? "WHERE log_level = :level" : "";
            
            $stmt = $this->pdo->prepare("
                SELECT id, log_level, message, context, created_at, ip_address
                FROM system_logs 
                $whereClause
                ORDER BY created_at DESC 
                LIMIT :limit OFFSET :offset
            ");
            
            if ($level) {
                $stmt->bindValue(':level', $level);
            }
            $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
            $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
            
            $stmt->execute();
            return $stmt->fetchAll();
            
        } catch (PDOException $e) {
            $this->logger->error('خطا در دریافت لاگ‌ها', ['error' => $e->getMessage()]);
            return [];
        }
    }
    
    /**
     * آمار لاگ‌ها
     * Get log statistics
     */
    public function getLogStats(): array {
        try {
            // آمار بر اساس level
            $stmt = $this->pdo->query("
                SELECT 
                    log_level,
                    COUNT(*) as count
                FROM system_logs 
                WHERE created_at >= DATE_SUB(NOW(), INTERVAL 24 HOUR)
                GROUP BY log_level
            ");
            $levelStats = $stmt->fetchAll();
            
            // تعداد کل
            $stmt = $this->pdo->query("SELECT COUNT(*) as total FROM system_logs");
            $total = $stmt->fetch()['total'];
            
            // آخرین لاگ
            $stmt = $this->pdo->query("
                SELECT message, created_at, log_level 
                FROM system_logs 
                ORDER BY created_at DESC 
                LIMIT 1
            ");
            $latest = $stmt->fetch();
            
            return [
                'total_logs' => $total,
                'level_stats' => $levelStats,
                'latest_log' => $latest
            ];
            
        } catch (PDOException $e) {
            $this->logger->error('خطا در دریافت آمار لاگ‌ها', ['error' => $e->getMessage()]);
            return ['error' => 'خطا در دریافت آمار'];
        }
    }
    
    /**
     * پاک کردن لاگ‌های قدیمی
     * Clear old logs
     */
    public function clearOldLogs(int $daysToKeep = 30): int {
        try {
            $stmt = $this->pdo->prepare("
                DELETE FROM system_logs 
                WHERE created_at < DATE_SUB(NOW(), INTERVAL :days DAY)
            ");
            
            $stmt->bindValue(':days', $daysToKeep, PDO::PARAM_INT);
            $stmt->execute();
            
            $deletedCount = $stmt->rowCount();
            
            $this->logger->info('لاگ‌های قدیمی پاک شدند', [
                'deleted_count' => $deletedCount,
                'days_kept' => $daysToKeep
            ]);
            
            return $deletedCount;
            
        } catch (PDOException $e) {
            $this->logger->error('خطا در پاک کردن لاگ‌ها', ['error' => $e->getMessage()]);
            return 0;
        }
    }
}
?>
```

## 🔒 امنیت و اعتبارسنجی

### Security Implementation
```php
<?php
// classes/SecurityManager.php

/**
 * مدیر امنیت سیستم
 * System Security Manager
 */
class SecurityManager 
{
    private Logger $logger;
    
    public function __construct() {
        $this->logger = new Logger();
    }
    
    /**
     * اعتبارسنجی ورودی
     * Input validation
     */
    public function validateInput(array $data, array $rules): array {
        $errors = [];
        
        foreach ($rules as $field => $rule) {
            $value = $data[$field] ?? null;
            
            // Required check
            if (isset($rule['required']) && $rule['required'] && empty($value)) {
                $errors[$field] = "فیلد $field اجباری است";
                continue;
            }
            
            if (!empty($value)) {
                // Type validation
                if (isset($rule['type'])) {
                    if (!$this->validateType($value, $rule['type'])) {
                        $errors[$field] = "نوع داده فیلد $field نامعتبر است";
                        continue;
                    }
                }
                
                // Length validation
                if (isset($rule['max_length']) && strlen($value) > $rule['max_length']) {
                    $errors[$field] = "طول فیلد $field بیش از حد مجاز است";
                }
                
                if (isset($rule['min_length']) && strlen($value) < $rule['min_length']) {
                    $errors[$field] = "طول فیلد $field کمتر از حد مجاز است";
                }
                
                // Persian content validation
                if (isset($rule['persian_support']) && $rule['persian_support']) {
                    if (!$this->validatePersianContent($value)) {
                        $errors[$field] = "محتوای فارسی فیلد $field نامعتبر است";
                    }
                }
                
                // Custom validation
                if (isset($rule['custom'])) {
                    $customError = $rule['custom']($value);
                    if ($customError) {
                        $errors[$field] = $customError;
                    }
                }
            }
        }
        
        return $errors;
    }
    
    /**
     * اعتبارسنجی نوع داده
     * Validate data type
     */
    private function validateType($value, string $type): bool {
        switch ($type) {
            case 'string':
                return is_string($value);
            case 'integer':
                return filter_var($value, FILTER_VALIDATE_INT) !== false;
            case 'email':
                return filter_var($value, FILTER_VALIDATE_EMAIL) !== false;
            case 'url':
                return filter_var($value, FILTER_VALIDATE_URL) !== false;
            case 'boolean':
                return in_array(strtolower($value), ['true', 'false', '1', '0', 'yes', 'no']);
            case 'json':
                json_decode($value);
                return json_last_error() === JSON_ERROR_NONE;
            default:
                return true;
        }
    }
    
    /**
     * اعتبارسنجی محتوای فارسی
     * Validate Persian content
     */
    private function validatePersianContent(string $text): bool {
        // بررسی وجود کاراکترهای فارسی
        if (preg_match('/[\x{0600}-\x{06FF}]/u', $text)) {
            // بررسی encoding صحیح
            return mb_check_encoding($text, 'UTF-8');
        }
        
        // اگر محتوای فارسی ندارد، معتبر محسوب می‌شود
        return true;
    }
    
    /**
     * محافظت از SQL Injection
     * SQL Injection protection
     */
    public function sanitizeForDatabase(string $input): string {
        // حذف کاراکترهای مضر
        $cleaned = preg_replace('/[\'";\\\\]/u', '', $input);
        
        // حفظ کاراکترهای فارسی
        return trim($cleaned);
    }
    
    /**
     * محافظت از XSS
     * XSS protection
     */
    public function sanitizeForOutput(string $input): string {
        // تبدیل HTML entities با حفظ محتوای فارسی
        return htmlspecialchars($input, ENT_QUOTES | ENT_HTML5, 'UTF-8');
    }
    
    /**
     * بررسی نرخ درخواست (Rate Limiting)
     * Request rate limiting
     */
    public function checkRateLimit(string $clientId, int $maxRequests = 100, int $timeWindow = 3600): bool {
        $cacheFile = sys_get_temp_dir() . "/rate_limit_$clientId.json";
        $now = time();
        
        if (file_exists($cacheFile)) {
            $data = json_decode(file_get_contents($cacheFile), true);
            
            // پاک کردن درخواست‌های قدیمی
            $data['requests'] = array_filter(
                $data['requests'], 
                fn($timestamp) => ($now - $timestamp) < $timeWindow
            );
            
            if (count($data['requests']) >= $maxRequests) {
                $this->logger->warning('حد مجاز درخواست رد شد', [
                    'client_id' => $clientId,
                    'requests' => count($data['requests'])
                ]);
                return false;
            }
        } else {
            $data = ['requests' => []];
        }
        
        // اضافه کردن درخواست جدید
        $data['requests'][] = $now;
        file_put_contents($cacheFile, json_encode($data));
        
        return true;
    }
    
    /**
     * اعتبارسنجی API Key
     * API Key validation
     */
    public function validateApiKey(string $apiKey): bool {
        // OpenAI API key format: sk-...
        if (strpos($apiKey, 'sk-') !== 0) {
            return false;
        }
        
        // بررسی طول کلید
        if (strlen($apiKey) < 40) {
            return false;
        }
        
        // بررسی کاراکترهای مجاز
        if (!preg_match('/^[a-zA-Z0-9\-_]+$/', $apiKey)) {
            return false;
        }
        
        return true;
    }
    
    /**
     * لاگ رویداد امنیتی
     * Log security event
     */
    public function logSecurityEvent(string $event, array $context = []): void {
        $this->logger->warning("رویداد امنیتی: $event", array_merge($context, [
            'ip' => $_SERVER['REMOTE_ADDR'] ?? 'unknown',
            'user_agent' => $_SERVER['HTTP_USER_AGENT'] ?? 'unknown',
            'timestamp' => date('Y-m-d H:i:s')
        ]));
    }
}
?>
```

### CORS Configuration
```php
<?php
// config/cors.php

/**
 * تنظیمات CORS برای دسترسی متقابل دامنه‌ها
 * CORS configuration for cross-origin requests
 */

/**
 * تنظیم هدرهای CORS
 * Set CORS headers
 */
function setCorsHeaders(): void {
    // دامنه‌های مجاز
    $allowedOrigins = [
        'http://localhost:8080',
        'http://localhost:3000',
        'http://127.0.0.1:8080',
        'http://127.0.0.1:3000',
        'http://localhost', // Flutter web dev
    ];
    
    $origin = $_SERVER['HTTP_ORIGIN'] ?? '';
    
    if (in_array($origin, $allowedOrigins)) {
        header("Access-Control-Allow-Origin: $origin");
    } else {
        header("Access-Control-Allow-Origin: *");
    }
    
    header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
    header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
    header("Access-Control-Allow-Credentials: true");
    header("Access-Control-Max-Age: 86400"); // 24 hours
    
    // پشتیبانی از فارسی
    header("Content-Type: application/json; charset=utf-8");
    
    // اگر درخواست OPTIONS است، پاسخ خالی برگردان
    if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
        http_response_code(200);
        exit;
    }
}

// فراخوانی تابع در تمام فایل‌های API
setCorsHeaders();
?>
```

## ⚠️ Important Notes

### Persian Support Best Practices
1. **UTF-8 Encoding**: همیشه از UTF-8 استفاده کنید
2. **Database Collation**: utf8mb4_unicode_ci برای پشتیبانی کامل فارسی
3. **JSON Encoding**: JSON_UNESCAPED_UNICODE برای حفظ کاراکترهای فارسی
4. **Input Validation**: اعتبارسنجی خاص برای محتوای فارسی
5. **Logging**: پیام‌های لاگ به زبان فارسی

### Performance Considerations
1. **Connection Pooling**: استفاده از persistent connections
2. **Query Optimization**: بهینه‌سازی کوئری‌ها برای محتوای فارسی
3. **Caching**: کش کردن تنظیمات پرکاربرد
4. **Error Handling**: مدیریت خطاها بدون افت عملکرد
5. **Log Rotation**: چرخش لاگ‌ها برای جلوگیری از پر شدن disk

### Security Measures
1. **SQL Injection**: استفاده از prepared statements
2. **XSS Protection**: escape کردن output
3. **Rate Limiting**: محدود کردن تعداد درخواست‌ها
4. **Input Validation**: اعتبارسنجی دقیق ورودی‌ها
5. **API Security**: محافظت از API keys

### Common Pitfalls Avoided
- ❌ Mixed character encodings
- ❌ Unescaped user input
- ❌ Missing error handling
- ❌ No request logging
- ❌ Hardcoded sensitive data
- ❌ No CORS configuration

## 🔄 Related Documentation
- [API Endpoints Reference](./api-endpoints-reference.md)
- [Database Integration](./database-integration.md)
- [Security Implementation](./security-implementation.md)
- [Error Handling](./error-handling.md)
- [System Architecture](../01-Architecture/system-architecture.md)

---
*این مستندات بخشی از مجموعه مستندات فنی پروژه DataSave است*  
*Last updated: 2025-01-09*  
*File: /docs/02-Backend-APIs/php-backend-overview.md*