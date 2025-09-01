# ساختار فایل‌های پروژه - Project Structure

## 📊 Document Information
- **Created:** 2025-01-09
- **Last Updated:** 2025-01-09
- **Version:** 1.0
- **Maintainer:** DataSave Development Team
- **Related Files:** Root directory structure, `/lib/`, `/backend/`

## 🎯 Overview
این سند ساختار کامل فایل‌ها و دایرکتوری‌های پروژه DataSave را به تفصیل شرح می‌دهد. این ساختار بر اساس اصول Clean Architecture و بهترین practices در توسعه Flutter و PHP طراحی شده است.

## 📂 Root Directory Structure

```
datasave/
├── 📁 backend/                     # Backend PHP application
├── 📁 build/                       # Flutter build artifacts
├── 📁 docs/                        # Project documentation
├── 📁 lib/                         # Flutter source code
├── 📁 test/                        # Test files
├── 📁 web/                         # Web-specific assets
├── 📄 analysis_options.yaml        # Dart analysis rules
├── 📄 api-openai.txt              # OpenAI API documentation
├── 📄 database_setup.sql          # Database initialization script
├── 📄 datasave.iml               # IntelliJ IDEA module file
├── 📄 pubspec.lock               # Flutter dependencies lock
├── 📄 pubspec.yaml               # Flutter project configuration
└── 📄 README.md                  # Project README
```

## 🎨 Frontend Structure (Flutter)

### 📁 lib/ Directory
```
lib/
├── 📄 main.dart                    # Entry point اپلیکیشن
├── 📁 core/                        # Core functionality
│   ├── 📁 config/                  # Configuration management
│   │   ├── 📄 app_config.dart      # تنظیمات اصلی اپلیکیشن
│   │   └── 📄 database_config.dart # تنظیمات پایگاه داده
│   ├── 📁 constants/               # Constants and enums
│   │   └── 📄 app_constants.dart   # ثابت‌های اپلیکیشن
│   ├── 📁 database/               # Database utilities
│   │   └── 📄 database_service.dart # سرویس پایگاه داده
│   ├── 📁 logger/                 # Logging system
│   │   └── 📄 logger_service.dart  # سرویس لاگینگ
│   ├── 📁 models/                 # Data models
│   │   └── 📄 chat_message.dart    # مدل پیام چت
│   ├── 📁 services/               # External services
│   │   ├── 📄 api_service.dart     # سرویس API
│   │   └── 📄 openai_service.dart  # سرویس OpenAI
│   ├── 📁 theme/                  # UI theming
│   │   └── 📄 app_theme.dart       # تم اپلیکیشن
│   └── 📁 utils/                  # Utility functions
├── 📁 presentation/               # UI Layer
│   ├── 📁 controllers/            # State management
│   ├── 📁 pages/                  # Screen pages
│   ├── 📁 routes/                 # Navigation routing
│   └── 📁 widgets/                # Reusable widgets
└── 📁 widgets/                    # Additional widgets
    └── 📄 font_test_widget.dart   # ویجت تست فونت
```

### 🎨 Core Layer Details

#### 📁 core/config/
```dart
// app_config.dart - تنظیمات اصلی اپلیکیشن
class AppConfig {
  static const String appName = 'DataSave';
  static const String version = '1.0.0';
  static const String apiBaseUrl = 'http://localhost/datasave-api';
  static const Duration apiTimeout = Duration(seconds: 30);
  static const String defaultLanguage = 'fa';
  static const bool enableDebugMode = true;
  
  // Persian specific configurations
  static const String persianFontFamily = 'Vazirmatn';
  static const TextDirection defaultTextDirection = TextDirection.rtl;
  static const Locale defaultLocale = Locale('fa', 'IR');
}
```

#### 📁 core/constants/
```dart
// app_constants.dart - ثابت‌های اپلیکیشن
class AppConstants {
  // API Endpoints
  static const String settingsEndpoint = '/api/settings';
  static const String logsEndpoint = '/api/logs';
  static const String systemEndpoint = '/api/system';
  
  // Database Tables
  static const String systemSettingsTable = 'system_settings';
  static const String systemLogsTable = 'system_logs';
  
  // Persian Numbers
  static const Map<String, String> persianNumbers = {
    '0': '۰', '1': '۱', '2': '۲', '3': '۳', '4': '۴',
    '5': '۵', '6': '۶', '7': '۷', '8': '۸', '9': '۹',
  };
  
  // Default Settings
  static const Map<String, dynamic> defaultSettings = {
    'openai_model': 'gpt-4',
    'openai_max_tokens': 2048,
    'app_language': 'fa',
    'enable_logging': true,
    'max_log_entries': 1000,
    'app_theme': 'light',
    'auto_save': true,
    'backup_enabled': false,
  };
}
```

#### 📁 core/services/
```dart
// api_service.dart - سرویس ارتباط با API
class ApiService {
  final String baseUrl;
  final Duration timeout;
  final http.Client _client;
  final Logger _logger;
  
  ApiService({
    required this.baseUrl,
    this.timeout = const Duration(seconds: 30),
    http.Client? client,
    Logger? logger,
  }) : _client = client ?? http.Client(),
       _logger = logger ?? Logger();
  
  // GET request with Persian support
  Future<ApiResponse<T>> get<T>(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      _logger.info('API GET: $uri');
      
      final response = await _client
        .get(
          uri,
          headers: _getHeaders(),
        )
        .timeout(timeout);
      
      return _handleResponse<T>(response);
    } catch (e) {
      _logger.error('API GET Error: $e');
      return ApiResponse.error('خطا در ارتباط با سرور: $e');
    }
  }
  
  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
      'Accept-Charset': 'utf-8',
    };
  }
}
```

### 🎨 Presentation Layer Details

#### 📁 presentation/pages/
```
pages/
├── 📄 dashboard_page.dart          # صفحه اصلی داشبورد
├── 📄 settings_page.dart           # صفحه تنظیمات سیستم
└── 📄 logs_page.dart               # صفحه مشاهده لاگ‌ها
```

#### 📁 presentation/widgets/shared/
```
shared/
├── 📄 stat_card.dart               # کارت نمایش آمار
├── 📄 settings_card.dart           # کارت تنظیمات گروهی
├── 📄 log_stat_card.dart           # کارت آمار لاگ‌ها
└── 📄 action_button.dart           # دکمه عملیات
```

#### Widget Structure Example
```dart
// stat_card.dart - کارت نمایش آمار
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;
  
  const StatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topRight, // RTL gradient
              end: Alignment.bottomLeft,
              colors: [
                effectiveColor.withOpacity(0.1),
                effectiveColor.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    icon,
                    color: effectiveColor,
                    size: 32,
                  ),
                  Text(
                    PersianNumberFormatter.format(value),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: effectiveColor,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Vazirmatn',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Vazirmatn',
                ),
                textAlign: TextAlign.right, // RTL alignment
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## 🔧 Backend Structure (PHP)

### 📁 backend/ Directory
```
backend/
├── 📄 index.php                    # Main entry point
├── 📁 api/                         # REST API endpoints
│   ├── 📁 logs/                    # Logging endpoints
│   │   ├── 📄 clear.php            # پاک کردن لاگ‌ها
│   │   ├── 📄 create.php           # ایجاد لاگ جدید
│   │   ├── 📄 list.php             # لیست لاگ‌ها
│   │   └── 📄 stats.php            # آمار لاگ‌ها
│   ├── 📁 settings/                # Settings management
│   │   ├── 📄 get.php              # دریافت تنظیمات
│   │   ├── 📄 test.php             # تست تنظیمات
│   │   └── 📄 update.php           # بروزرسانی تنظیمات
│   └── 📁 system/                  # System information
│       ├── 📄 info.php             # اطلاعات سیستم
│       └── 📄 status.php           # وضعیت سیستم
├── 📁 classes/                     # PHP Classes
│   ├── 📄 ApiResponse.php          # کلاس پاسخ استاندارد
│   └── 📄 Logger.php               # کلاس لاگینگ
├── 📁 config/                      # Configuration files
│   ├── 📄 cors.php                 # تنظیمات CORS
│   └── 📄 database.php             # تنظیمات پایگاه داده
└── 📁 sql/                         # SQL scripts
    └── 📄 create_tables.sql        # اسکریپت ایجاد جداول
```

### 🔧 API Structure Details

#### 📁 api/settings/
```php
<?php
// get.php - دریافت تمام تنظیمات
require_once '../../config/cors.php';
require_once '../../config/database.php';
require_once '../../classes/ApiResponse.php';

try {
    // اتصال به پایگاه داده با پشتیبانی UTF-8
    $pdo = new PDO(
        "mysql:host=$host;port=$port;dbname=$dbname;charset=utf8mb4",
        $username,
        $password,
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8mb4"
        ]
    );
    
    // دریافت تمام تنظیمات فعال
    $stmt = $pdo->prepare("
        SELECT setting_key, setting_value, description 
        FROM system_settings 
        WHERE is_active = 1 
        ORDER BY setting_key ASC
    ");
    
    $stmt->execute();
    $settings = $stmt->fetchAll();
    
    // مخفی کردن کلیدهای حساس
    foreach ($settings as &$setting) {
        if (str_contains($setting['setting_key'], 'api_key')) {
            $setting['setting_value'] = '***مخفی***';
        }
    }
    
    $response = new ApiResponse(
        success: true,
        message: 'تنظیمات با موفقیت دریافت شد',
        data: $settings
    );
    
    echo $response->toJson();
    
} catch (PDOException $e) {
    $response = new ApiResponse(
        success: false,
        message: 'خطا در دریافت تنظیمات: ' . $e->getMessage(),
        errors: [$e->getMessage()]
    );
    
    echo $response->toJson();
} catch (Exception $e) {
    $response = new ApiResponse(
        success: false,
        message: 'خطای غیرمنتظره: ' . $e->getMessage(),
        errors: [$e->getMessage()]
    );
    
    echo $response->toJson();
}
?>
```

#### 📁 classes/
```php
<?php
// ApiResponse.php - کلاس پاسخ استاندارد API
class ApiResponse {
    private bool $success;
    private string $message;
    private mixed $data;
    private array $errors;
    private string $timestamp;
    
    public function __construct(
        bool $success = true,
        string $message = '',
        mixed $data = null,
        array $errors = []
    ) {
        $this->success = $success;
        $this->message = $message;
        $this->data = $data;
        $this->errors = $errors;
        $this->timestamp = date('Y-m-d H:i:s');
    }
    
    public function toJson(): string {
        return json_encode([
            'success' => $this->success,
            'message' => $this->message,
            'data' => $this->data,
            'errors' => $this->errors,
            'timestamp' => $this->timestamp
        ], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
    }
    
    public function isSuccess(): bool {
        return $this->success;
    }
    
    public function getData(): mixed {
        return $this->data;
    }
}
?>
```

## 📊 Database Structure

### 📁 SQL Scripts
```sql
-- create_tables.sql - ایجاد جداول اصلی
CREATE DATABASE IF NOT EXISTS datasave 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE datasave;

-- جدول تنظیمات سیستم
CREATE TABLE IF NOT EXISTS system_settings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    setting_key VARCHAR(100) NOT NULL UNIQUE,
    setting_value TEXT NOT NULL,
    description VARCHAR(255) DEFAULT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_setting_key (setting_key),
    INDEX idx_active (is_active),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB 
  CHARACTER SET utf8mb4 
  COLLATE utf8mb4_unicode_ci 
  COMMENT='تنظیمات سیستم و پیکربندی';

-- جدول لاگ‌های سیستم  
CREATE TABLE IF NOT EXISTS system_logs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    log_level ENUM('debug', 'info', 'warning', 'error', 'critical') DEFAULT 'info',
    message TEXT NOT NULL,
    context JSON DEFAULT NULL,
    user_id INT DEFAULT NULL,
    ip_address VARCHAR(45) DEFAULT NULL,
    user_agent TEXT DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_log_level (log_level),
    INDEX idx_created_at (created_at),
    INDEX idx_user_id (user_id),
    INDEX idx_compound (log_level, created_at)
) ENGINE=InnoDB 
  CHARACTER SET utf8mb4 
  COLLATE utf8mb4_unicode_ci 
  COMMENT='لاگ‌های سیستم و فعالیت کاربران';
```

## 📚 Documentation Structure

### 📁 docs/ Directory
```
docs/
├── 📄 README.md                    # مستندات اصلی
├── 📄 datasave_professional_doc.md # مستندات حرفه‌ای
├── 📁 00-Project-Overview/         # نمای کلی پروژه
├── 📁 01-Architecture/             # معماری سیستم
├── 📁 02-Backend-APIs/             # مستندات Backend
├── 📁 03-Database-Schema/          # طراحی پایگاه داده
├── 📁 04-Flutter-Frontend/         # مستندات Frontend
├── 📁 05-Services-Integration/     # یکپارچه‌سازی سرویس‌ها
├── 📁 06-UI-UX-Design/             # طراحی رابط کاربری
├── 📁 07-Development-Workflow/     # گردش کار توسعه
├── 📁 99-Quick-Reference/          # راهنمای سریع
└── 📁 Smart-Prompts/              # پرامپت‌های هوشمند
    ├── 📁 01-Starter-Create Flutter Project/
    ├── 📁 02-Logger System - Database Connection/
    ├── 📁 03-Dashboard UI-Settings Management-Logging Interface/
    └── 📁 04-Documentation Architecture/
```

## 🧪 Testing Structure

### 📁 test/ Directory
```
test/
├── 📄 widget_test.dart             # تست‌های widget
├── 📁 unit/                        # Unit tests
│   ├── 📁 core/                    # تست core functionality
│   │   ├── 📁 services/            # تست سرویس‌ها
│   │   └── 📁 models/              # تست models
│   └── 📁 presentation/            # تست presentation layer
│       ├── 📁 controllers/         # تست controllers
│       └── 📁 widgets/             # تست widgets
├── 📁 integration/                 # Integration tests
│   ├── 📄 app_test.dart            # تست کل اپلیکیشن
│   └── 📄 api_integration_test.dart # تست API integration
└── 📁 fixtures/                    # Test data
    ├── 📄 settings_data.json       # نمونه داده تنظیمات
    └── 📄 logs_data.json           # نمونه داده لاگ‌ها
```

### Test File Example
```dart
// test/unit/core/services/api_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:datasave/core/services/api_service.dart';

void main() {
  group('ApiService Tests', () {
    late ApiService apiService;
    late MockHttpClient mockHttpClient;
    
    setUp(() {
      mockHttpClient = MockHttpClient();
      apiService = ApiService(
        baseUrl: 'http://test.local',
        client: mockHttpClient,
      );
    });
    
    test('should handle Persian content correctly in GET request', () async {
      // تست محتوای فارسی در درخواست GET
      final persianResponse = {
        'success': true,
        'message': 'درخواست با موفقیت انجام شد',
        'data': [
          {
            'setting_key': 'app_language',
            'setting_value': 'fa',
            'description': 'زبان اپلیکیشن'
          }
        ]
      };
      
      when(mockHttpClient.get(any))
        .thenAnswer((_) async => MockHttpResponse(
          200, 
          json.encode(persianResponse)
        ));
      
      final result = await apiService.get('/api/settings/get.php');
      
      expect(result.success, true);
      expect(result.data, isA<List>());
      expect(result.message, contains('موفقیت'));
    });
  });
}
```

## 🌐 Web Assets Structure

### 📁 web/ Directory
```
web/
├── 📄 favicon.png                  # آیکون سایت
├── 📄 index.html                   # صفحه HTML اصلی
├── 📄 manifest.json               # PWA manifest
├── 📄 vazirmatn.css               # فونت فارسی Vazirmatn
├── 📁 fonts/                       # فونت‌های محلی
│   ├── 📄 Vazirmatn-Bold.ttf      # فونت Bold
│   ├── 📄 Vazirmatn-Light.ttf     # فونت Light
│   └── 📄 Vazirmatn-Regular.ttf   # فونت Regular
└── 📁 icons/                       # آیکون‌های PWA
    ├── 📄 Icon-192.png             # آیکون 192×192
    ├── 📄 Icon-512.png             # آیکون 512×512
    ├── 📄 Icon-maskable-192.png    # آیکون Maskable 192×192
    └── 📄 Icon-maskable-512.png    # آیکون Maskable 512×512
```

### Web Configuration
```html
<!-- index.html - صفحه HTML اصلی -->
<!DOCTYPE html>
<html lang="fa" dir="rtl">
<head>
  <base href="$FLUTTER_BASE_HREF">
  <meta charset="UTF-8">
  <meta content="IE=Edge" http-equiv="X-UA-Compatible">
  <meta name="description" content="DataSave - پلتفرم هوشمند طراحی فرم">
  <meta name="apple-mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-status-bar-style" content="black">
  <meta name="apple-mobile-web-app-title" content="DataSave">
  <link rel="apple-touch-icon" href="icons/Icon-192.png">
  <link rel="icon" type="image/png" href="favicon.png"/>
  <title>DataSave - ایجاد فرم هوشمند</title>
  <link rel="manifest" href="manifest.json">
  
  <!-- Preload Persian fonts -->
  <link rel="preload" href="fonts/Vazirmatn-Regular.ttf" as="font" type="font/ttf" crossorigin>
  <link rel="preload" href="fonts/Vazirmatn-Bold.ttf" as="font" type="font/ttf" crossorigin>
  <link rel="stylesheet" href="vazirmatn.css">
  
  <style>
    body {
      font-family: 'Vazirmatn', sans-serif;
      direction: rtl;
      text-align: right;
    }
  </style>
</head>
<body>
  <div id="loading">
    <div class="loading-text">در حال بارگذاری...</div>
  </div>
  <script src="main.dart.js" type="application/javascript"></script>
</body>
</html>
```

## ⚙️ Configuration Files

### 📄 pubspec.yaml
```yaml
name: datasave
description: پلتفرم هوشمند طراحی فرم با قابلیت‌های AI
version: 1.0.0+1

environment:
  sdk: '>=3.2.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  provider: ^6.1.1
  
  # HTTP Client
  http: ^1.1.2
  
  # Persian Tools
  persian_tools: ^1.0.0
  shamsi_date: ^3.1.0
  
  # UI Components
  cupertino_icons: ^1.0.6
  
  # Logging
  logger: ^2.0.2+1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  mockito: ^5.4.4
  build_runner: ^2.4.7

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/icons/
  
  fonts:
    - family: Vazirmatn
      fonts:
        - asset: web/fonts/Vazirmatn-Regular.ttf
          weight: 400
        - asset: web/fonts/Vazirmatn-Bold.ttf
          weight: 700
        - asset: web/fonts/Vazirmatn-Light.ttf
          weight: 300
```

### 📄 analysis_options.yaml
```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "build/**"
  
  language:
    strict-casts: true
    strict-raw-types: true

linter:
  rules:
    # Persian-specific rules
    prefer_const_constructors: true
    prefer_const_literals_to_create_immutables: true
    use_key_in_widget_constructors: true
    
    # Performance rules
    avoid_function_literals_in_foreach_calls: true
    avoid_redundant_argument_values: true
    
    # Style rules
    always_declare_return_types: true
    prefer_single_quotes: true
    require_trailing_commas: true
```

## 🔍 File Naming Conventions

### Dart Files
```yaml
Files: snake_case.dart
Classes: PascalCase
Variables: camelCase
Constants: SCREAMING_SNAKE_CASE
Private: _leadingUnderscore

Examples:
  - dashboard_page.dart (file)
  - DashboardPage (class)  
  - settingsController (variable)
  - API_BASE_URL (constant)
  - _privateMethod (private)
```

### PHP Files
```yaml
Files: snake_case.php
Classes: PascalCase
Methods: camelCase
Constants: SCREAMING_SNAKE_CASE

Examples:
  - settings_api.php (file)
  - ApiResponse (class)
  - getUserSettings (method)
  - DATABASE_HOST (constant)
```

### Database Naming
```yaml
Tables: snake_case
Columns: snake_case
Indexes: idx_column_name
Constraints: fk_table_column

Examples:
  - system_settings (table)
  - setting_key (column)
  - idx_setting_key (index)
  - fk_logs_user_id (foreign key)
```

## 📋 Directory Purpose Summary

| Directory | Purpose | Language | Notes |
|-----------|---------|----------|-------|
| `/lib/core/` | Core functionality | Dart | Framework-independent |
| `/lib/presentation/` | UI layer | Dart | Flutter-specific |
| `/backend/api/` | REST endpoints | PHP | API implementations |
| `/backend/classes/` | PHP utilities | PHP | Reusable classes |
| `/docs/` | Documentation | Markdown | Persian + English |
| `/test/` | Test files | Dart | Unit & integration |
| `/web/` | Web assets | HTML/CSS | PWA support |

## ⚠️ Important Notes

### Structure Benefits
1. **Clear Separation**: هر بخش مسئولیت مشخص دارد
2. **Persian-First**: پشتیبانی کامل از فارسی در همه لایه‌ها
3. **Maintainable**: ساختار قابل نگهداری و توسعه
4. **Testable**: تمام اجزا قابل تست هستند
5. **Scalable**: قابل گسترش برای ویژگی‌های آینده

### Best Practices Followed
- Clean Architecture principles
- SOLID design principles
- Persian content handling
- RTL layout support
- Performance optimization
- Security considerations

### Future Structure Enhancements
- **Feature Modules**: تقسیم‌بندی بر اساس feature
- **Domain Layer**: اضافه کردن domain entities
- **Repository Pattern**: پیاده‌سازی کامل repository
- **Middleware**: اضافه کردن middleware برای API
- **Cache Layer**: پیاده‌سازی caching strategy

## 🔄 Related Documentation
- [Clean Architecture Implementation](./clean-architecture-implementation.md)
- [System Architecture](./system-architecture.md)
- [Design Patterns](./design-patterns.md)
- [Flutter Architecture](../04-Flutter-Frontend/flutter-architecture.md)

---
*این مستندات بخشی از مجموعه مستندات فنی پروژه DataSave است*  
*Last updated: 2025-01-09*  
*File: /docs/01-Architecture/project-structure.md*