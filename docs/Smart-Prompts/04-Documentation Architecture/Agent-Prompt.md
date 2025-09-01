# 📚 DataSave Professional Documentation System - پرامپت مستندسازی

## 🎯 Mission Overview
Create comprehensive, professional documentation for the DataSave project by analyzing all source files and generating structured documentation that will serve as the foundation for future development phases.

## 📋 Current Project Status
**Project:** DataSave - AI-Powered Form Builder Platform  
**Phase:** 3 Complete (Dashboard UI + Settings + Logging Interface)  
**Current Status:** Full-stack integration complete with Persian RTL support
**Next Phase:** Form Builder Core Engine Development
**Documentation Status:** Comprehensive documentation system established

### ✅ Completed Features
- **Flutter Frontend:** Complete UI with Material Design 3
- **PHP Backend:** RESTful API with MySQL integration
- **Database Schema:** system_settings and system_logs tables
- **OpenAI Integration:** GPT-4 API integration for AI features
- **Persian RTL:** Full Persian language support with Vazirmatn font
- **Logging System:** Multi-level logging with database persistence
- **Settings Management:** Complete configuration system
- **Theme System:** Material Design 3 with Persian typography

### 🔧 Technical Stack Status
- **Frontend:** Flutter 3.x with Provider state management
- **Backend:** PHP 8.x with PDO and MySQL
- **Database:** MySQL 8.0 (XAMPP on port 3307)
- **API Integration:** OpenAI GPT-4, RESTful APIs
- **UI Framework:** Material Design 3 with Persian RTL
- **Architecture:** Clean Architecture principles implemented  

## 🏗️ Documentation Architecture

Create a structured documentation system in the `/docs` directory with the following hierarchy:

```
docs/
├── 00-Project-Overview/
│   ├── project-vision.md                    # هدف کلی و چشم‌انداز پروژه
│   ├── technical-requirements.md            # نیازمندی‌های فنی
│   └── development-roadmap.md               # نقشه راه توسعه
│
├── 01-Architecture/
│   ├── system-architecture.md               # معماری کلی سیستم
│   ├── clean-architecture-implementation.md # پیاده‌سازی Clean Architecture
│   ├── project-structure.md                # ساختار فایل‌های پروژه
│   └── design-patterns.md                  # الگوهای طراحی استفاده شده
│
├── 02-Backend-APIs/
│   ├── php-backend-overview.md             # مرور کلی Backend PHP
│   ├── api-endpoints-reference.md          # مرجع کامل API endpoints
│   ├── database-integration.md             # نحوه ارتباط با دیتابیس
│   ├── error-handling.md                   # مدیریت خطا در Backend
│   └── security-implementation.md          # پیاده‌سازی امنیت
│
├── 03-Database-Schema/
│   ├── database-design.md                  # طراحی کلی دیتابیس
│   ├── tables-reference.md                 # مرجع کامل جداول
│   ├── relationships-diagram.md            # روابط بین جداول
│   ├── indexes-performance.md              # اندیس‌ها و بهینه‌سازی
│   └── migration-scripts.md               # اسکریپت‌های migration
│
├── 04-Flutter-Frontend/
│   ├── flutter-architecture.md             # معماری Flutter
│   ├── state-management.md                 # مدیریت وضعیت با Provider
│   ├── ui-components-library.md            # کتابخانه کامپوننت‌های UI
│   ├── routing-navigation.md               # مسیریابی و navigation
│   ├── responsive-design.md                # طراحی Responsive
│   └── persian-rtl-implementation.md       # پیاده‌سازی Persian RTL
│
├── 05-Services-Integration/
│   ├── openai-integration.md               # ادغام OpenAI API
│   ├── api-service-layer.md               # لایه سرویس API
│   ├── logging-system.md                  # سیستم لاگینگ 
│   ├── configuration-management.md        # مدیریت تنظیمات
│   └── external-services.md               # سرویس‌های خارجی
│
├── 06-UI-UX-Design/
│   ├── design-system.md                   # سیستم طراحی
│   ├── material-design-3.md               # Material Design 3 Implementation
│   ├── typography-fonts.md                # تایپوگرافی و فونت‌ها
│   ├── color-scheme.md                    # رنگ‌بندی و Theme
│   ├── component-specifications.md        # مشخصات کامپوننت‌ها
│   └── user-interface-guidelines.md       # راهنمای رابط کاربری
│
├── 07-Development-Workflow/
│   ├── development-environment.md         # محیط توسعه
│   ├── build-deployment.md               # Build و Deployment
│   ├── testing-strategy.md               # استراتژی تست
│   ├── version-control.md                # کنترل نسخه Git
│   └── code-standards.md                 # استانداردهای کدنویسی
│
└── 99-Quick-Reference/
    ├── api-quick-reference.md             # مرجع سریع API
    ├── database-quick-reference.md        # مرجع سریع Database
    ├── flutter-quick-reference.md         # مرجع سریع Flutter
    └── troubleshooting-guide.md           # راهنمای عیب‌یابی
```

## 📝 Documentation Standards & Guidelines

### 🏷️ File Naming Convention
- All files in **kebab-case** with `.md` extension
- Persian titles in file headers
- English technical terms where appropriate
- Consistent numbering system for organization

### 📋 Document Structure Template
```markdown
# [Document Title in Persian] - [English Subtitle]

## 📊 Document Information
- **Created:** [Date]
- **Last Updated:** [Date]
- **Version:** [x.x]
- **Maintainer:** DataSave Development Team
- **Related Files:** [List of related source files]

## 🎯 Overview
[Brief description in Persian]

## 📋 Table of Contents
- [Auto-generated TOC]

## 🔧 Technical Details
[Detailed technical information with code examples]

## 📱 Usage Examples
[Practical examples with code snippets]

## ⚠️ Important Notes
[Critical information, warnings, dependencies]

## 🔄 Related Documentation
[Links to related documentation files]

## 📚 References
[External references, APIs, libraries]

---
*Last updated: [Auto-update timestamp]*
*File: [File path]*
```

## 🎯 Specific Documentation Requirements

### 1️⃣ Project Overview Section
**File: `docs/00-Project-Overview/project-vision.md`**
```markdown
Required Content:
- DataSave mission and vision
- Target audience and use cases
- Key features and capabilities
- Technology stack overview
- Success metrics and KPIs
- Future expansion plans
```

### 2️⃣ Database Schema Documentation
**File: `docs/03-Database-Schema/tables-reference.md`**
```markdown
For each table, document:
- Table name and purpose
- All columns with data types
- Primary keys and foreign keys
- Indexes and constraints
- Example data
- Related tables and relationships
- Usage patterns and queries

Current tables to document:
✅ system_settings (9 records complete)
✅ system_logs (500+ active records)

Example format:
## Table: system_settings
**Purpose:** Store application configuration and API settings including OpenAI integration
**Engine:** InnoDB
**Charset:** utf8mb4_persian_ci

| Column | Type | Key | Null | Default | Description |
|--------|------|-----|------|---------|-------------|
| id | INT | PK | NO | AI | شناسه یکتا |
| setting_key | VARCHAR(100) | UNI | NO | - | کلید تنظیمات |
| setting_value | TEXT | - | YES | NULL | مقدار تنظیمات |
| setting_type | ENUM | - | NO | 'string' | نوع داده |
| description | VARCHAR(255) | - | YES | NULL | توضیحات |
| is_system | BOOLEAN | - | NO | FALSE | تنظیمات سیستمی؟ |
| is_readonly | BOOLEAN | - | NO | FALSE | فقط خواندنی؟ |
| created_at | TIMESTAMP | - | NO | CURRENT_TIMESTAMP | زمان ایجاد |
| updated_at | TIMESTAMP | - | NO | ON UPDATE | زمان بروزرسانی |

**Current Settings (9 records):**
- openai_api_key (encrypted) - کلید API سرویس OpenAI
- openai_model (gpt-4) - مدل پیش‌فرض OpenAI  
- openai_max_tokens (2048) - حداکثر توکن پاسخ
- app_language (fa) - زبان پیش‌فرض برنامه
- enable_logging (true) - فعال‌سازی سیستم لاگ
- max_log_entries (1000) - حداکثر تعداد لاگ
- app_theme (light) - تم پیش‌فرض اپلیکیشن
- auto_save (true) - ذخیره خودکار فرم‌ها
- backup_enabled (false) - پشتیبان‌گیری خودکار

**API Usage Example:**
```php
// Get all settings
$settings = $db->query("SELECT * FROM system_settings ORDER BY setting_key");

// Update OpenAI settings
$stmt = $db->prepare("UPDATE system_settings SET setting_value = ? WHERE setting_key = 'openai_model'");
$stmt->execute(['gpt-4']);
```
```

### 3️⃣ API Endpoints Documentation  
**File: `docs/02-Backend-APIs/api-endpoints-reference.md`**
```markdown
For each endpoint, document:

## GET /api/settings/get.php
**Purpose:** دریافت تمام تنظیمات سیستم شامل تنظیمات OpenAI
**Method:** GET
**Authentication:** None (local development)
**Parameters:** None

**Response Format:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "setting_key": "openai_api_key",
      "setting_value": "sk-proj-...",
      "setting_type": "encrypted",
      "description": "کلید API سرویس OpenAI",
      "is_system": true
    },
    {
      "id": 2,
      "setting_key": "openai_model", 
      "setting_value": "gpt-4",
      "setting_type": "string",
      "description": "مدل پیش‌فرض OpenAI",
      "is_system": true
    }
  ],
  "count": 9
}
```

**Error Handling:**
- Database connection errors (500)
- JSON parsing errors (500)
- Empty result scenarios (200 with empty array)

**Usage Example:**
```dart
final settings = await ApiService.getSettings();
if (settings != null && settings['success'] == true) {
  final settingsList = settings['data'] as List;
  // Process settings
}
```

**Related Files:**
- `backend/api/settings/get.php`
- `lib/core/services/api_service.dart`
- `lib/presentation/controllers/settings_controller.dart`

## POST /api/settings/update.php
**Purpose:** بروزرسانی تنظیمات سیستم
**Method:** POST
**Content-Type:** application/json

**Request Body:**
```json
{
  "setting_key": "openai_model",
  "setting_value": "gpt-4-turbo"
}
```

**Response Format:**
```json
{
  "success": true,
  "message": "تنظیمات با موفقیت بروزرسانی شد"
}
```

## GET /api/logs/list.php
**Purpose:** دریافت لیست لاگ‌های سیستم با فیلتر و صفحه‌بندی
**Method:** GET
**Parameters:** 
- level (optional): فیلتر سطح لاگ
- limit (optional): تعداد رکورد (پیش‌فرض: 50)
- offset (optional): جایگاه شروع

**Response Format:**
```json
{
  "success": true,
  "data": [
    {
      "log_id": 1,
      "log_level": "INFO",
      "log_category": "API",
      "log_message": "درخواست دریافت تنظیمات",
      "created_at": "2025-09-01 10:30:00"
    }
  ],
  "total": 523,
  "count": 50
}
```

## POST /api/logs/create.php
**Purpose:** ثبت لاگ جدید در سیستم
**Method:** POST
**Content-Type:** application/json

**Request Body:**
```json
{
  "log_level": "INFO",
  "log_category": "Frontend",
  "log_message": "کاربر وارد صفحه تنظیمات شد",
  "log_context": {"page": "settings", "user_action": "navigate"}
}
```

## GET /api/system/status.php
**Purpose:** بررسی وضعیت کلی سیستم و سرویس‌ها
**Method:** GET

**Response Format:**
```json
{
  "success": true,
  "data": {
    "database": {
      "status": "connected",
      "version": "MySQL 8.0",
      "charset": "utf8mb4_persian_ci"
    },
    "api": {
      "status": "operational",
      "endpoints": 8,
      "version": "1.0.0"
    },
    "openai": {
      "status": "configured",
      "model": "gpt-4",
      "test_connection": true
    }
  },
  "timestamp": "2025-09-01T10:30:00Z"
}
```
```

### 4️⃣ Flutter Architecture Documentation
**File: `docs/04-Flutter-Frontend/flutter-architecture.md`**
```markdown
Required Content:
- Clean Architecture implementation with Provider pattern
- Complete folder structure explanation
- Dependency injection and service location
- State management with Provider and ChangeNotifier
- Navigation system with named routes
- Error handling strategy and user feedback
- Performance optimization techniques
- Persian RTL implementation details

File Structure Documentation:
```
lib/
├── core/                          # Core functionality
│   ├── config/                    # Configuration management
│   │   ├── app_config.dart        # App configuration
│   │   └── database_config.dart   # API endpoints config
│   ├── constants/                 # App constants
│   │   └── app_constants.dart     # Global constants
│   ├── logger/                    # Logging system
│   │   └── logger_service.dart    # Multi-level logging
│   ├── models/                    # Data models
│   │   └── chat_message.dart      # Chat message model
│   ├── services/                  # API and external services
│   │   ├── api_service.dart       # Backend API client
│   │   └── openai_service.dart    # OpenAI GPT-4 integration
│   ├── theme/                     # UI theme and styling
│   │   ├── app_theme.dart         # Material Design 3 theme
│   │   └── persian_fonts.dart     # Vazirmatn font definitions
│   └── utils/                     # Utility functions
├── presentation/                  # UI layer (Clean Architecture)
│   ├── controllers/               # State management controllers
│   │   ├── settings_controller.dart  # Settings state
│   │   └── logs_controller.dart      # Logs state
│   ├── pages/                     # Screen pages
│   │   ├── home/                  # Dashboard page
│   │   ├── settings/              # Settings management
│   │   └── logs/                  # Logs viewer
│   ├── routes/                    # Navigation routing
│   │   └── app_routes.dart        # Named routes
│   └── widgets/                   # Reusable widgets
│       ├── shared/                # Common widgets
│       └── chat/                  # Chat-specific widgets
├── widgets/                       # Additional custom widgets
│   └── font_test_widget.dart      # Persian font test widget
└── main.dart                      # App entry point with providers
```

### Provider State Management Implementation:
```dart
// Main app with providers setup
class DataSaveApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsController()),
        ChangeNotifierProvider(create: (_) => LogsController()),
      ],
      child: MaterialApp(
        title: 'DataSave - فرم‌ساز هوشمند',
        theme: AppTheme.lightTheme,
        locale: const Locale('fa', 'IR'),
        home: HomePage(),
      ),
    );
  }
}

// Controller pattern example
class SettingsController with ChangeNotifier {
  String _openaiApiKey = '';
  bool _isLoading = false;
  String? _error;
  
  // Getters
  String get openaiApiKey => _openaiApiKey;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Business methods
  Future<void> loadSettings() async {
    _setLoading(true);
    try {
      final settings = await ApiService.getSettings();
      _updateSettingsFromApi(settings);
      _error = null;
    } catch (e) {
      _error = 'خطا در بارگذاری تنظیمات: ${e.toString()}';
      LoggerService.error('SettingsController', _error!);
    } finally {
      _setLoading(false);
    }
  }
}
```

### Persian RTL Implementation:
```dart
// Theme with Persian font and RTL support
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Vazirmatn',
      textTheme: _persianTextTheme(),
      appBarTheme: AppBarTheme(
        titleTextStyle: PersianFonts.pageTitle,
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: PersianFonts.normal,
      ),
    );
  }
}

// Persian text themes
class PersianFonts {
  static const String fontFamily = 'Vazirmatn';
  
  static const TextStyle pageTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle normal = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );
}
```
```
**File: `docs/06-UI-UX-Design/component-specifications.md`**
```markdown
Document all custom components:

## StatCard Widget
**File:** `lib/presentation/widgets/shared/stat_card.dart`
**Purpose:** Display statistical information with icon and color coding

**Properties:**
- title: String (required)
- value: String (required) 
- icon: IconData (required)
- color: Color (optional)
- onTap: VoidCallback (optional)

**Usage:**
```dart
StatCard(
  title: 'اطلاعات',
  value: '107',
  icon: Icons.info,
  color: Colors.green,
  onTap: () => navigateToLogs(),
)
```

**Design Specifications:**
- Height: 120px
- Border radius: 16px
- Elevation: 2
- Persian RTL support
- Material Design 3 colors
```

## 🔄 Documentation Maintenance Strategy

### Auto-Update Requirements
Every prompt should include a documentation update section:

```markdown
## 📚 Documentation Update Requirements

After implementing changes, update the following documentation files:

### Modified Files Documentation
- List all modified source files
- Update related documentation sections
- Add new API endpoints to reference
- Update database schema if changed
- Modify UI component specifications
- Update quick reference guides

### Version Control
- Increment document version numbers
- Update "Last Modified" timestamps
- Add change log entries
- Cross-reference related documents

### Validation
- Ensure all code examples work
- Verify all links are functional
- Check documentation completeness
- Validate technical accuracy
```

## 🎯 Implementation Instructions

### Phase 1: Foundation Documentation (Immediate)
1. **Analyze all existing source files** in the DataSave project
2. **Extract key information** about architecture, APIs, database schema
3. **Create the documentation structure** as outlined above
4. **Generate initial content** for critical files:
   - Project overview
   - Database schema reference
   - API endpoints reference
   - Flutter architecture overview

### Phase 2: Detailed Documentation (Ongoing)
1. **Complete component documentation** for all UI widgets
2. **Document business logic** and data flow
3. **Create troubleshooting guides** based on common issues
4. **Add performance optimization** documentation

### Phase 3: Maintenance Integration (Permanent)
1. **Integrate documentation updates** into all future prompts
2. **Establish review process** for documentation accuracy
3. **Create automated validation** for documentation completeness
4. **Maintain version synchronization** between code and docs

## ✅ Success Criteria

### Documentation Quality Standards
- [ ] **Completeness:** All major components documented
- [ ] **Accuracy:** Technical information verified and current
- [ ] **Clarity:** Clear explanations with practical examples
- [ ] **Consistency:** Uniform structure and formatting
- [ ] **Maintainability:** Easy to update and extend
- [ ] **Accessibility:** Easy navigation and search
- [ ] **Bilingual Support:** Persian primary, English technical terms

### Usage Validation
- [ ] **Developer Onboarding:** New developer can understand system in 30 minutes
- [ ] **Troubleshooting:** Common issues can be resolved using documentation
- [ ] **Feature Development:** New features can be implemented using architectural guidelines
- [ ] **API Integration:** External developers can integrate using API documentation
- [ ] **Database Management:** Database operations are clearly documented

## 🚀 Immediate Action Items

1. **Create documentation folder structure** in `/docs`
2. **Analyze current codebase** to extract documentation content
3. **Generate foundation documentation files** with current system state
4. **Establish documentation update workflow** for future development
5. **Create quick reference guides** for immediate developer needs

---

## 🎊 Documentation Generation Strategy

**Approach:** Comprehensive analysis of all source files followed by structured documentation generation with real-world examples and current system state.

**Priority Order:**
1. Database Schema (Critical for development) ✅
2. API Reference (Essential for integration) ✅
3. Flutter Architecture (Core for UI development) ✅
4. UI Components (Important for consistency) ✅
5. Development Workflow (Necessary for team work) ✅

**Latest Updates (2025-09-01):**
1. Completed comprehensive logging system documentation
2. Enhanced configuration management documentation
3. Updated external services integration documentation
4. Added Persian text handling throughout documentation
5. Added detailed code examples in multiple languages

**Maintenance Integration:** Every future prompt will include documentation update requirements to ensure documentation stays current with codebase changes.

---

**Ready to generate professional documentation system for DataSave! 📚✨**