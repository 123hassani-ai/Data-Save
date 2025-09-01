# 📚 DataSave Professional Documentation System - پرامپت مستندسازی

## 🎯 Mission Overview
Create comprehensive, professional documentation for the DataSave project by analyzing all source files and generating structured documentation that will serve as the foundation for future development phases.

## 📋 Current Project Status
**Project:** DataSave - AI-Powered Form Builder Platform  
**Phase:** 3 Complete (Dashboard UI + Settings + Logging Interface)  
**Next Phase:** Form Builder Core Engine  
**Documentation Status:** Needs comprehensive professional documentation  

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
✅ system_settings (9 records)
✅ system_logs (active logging)

Example format:
## Table: system_settings
**Purpose:** Store application configuration and API settings
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
| created_at | TIMESTAMP | - | NO | CURRENT_TIMESTAMP | زمان ایجاد |
| updated_at | TIMESTAMP | - | NO | ON UPDATE | زمان بروزرسانی |

**Current Settings:**
- openai_api_key (encrypted)
- openai_model (gpt-4)
- openai_max_tokens (2048)
- app_language (fa)
- enable_logging (true)
- max_log_entries (1000)
- app_theme (light)
- auto_save (true)
- backup_enabled (false)
```

### 3️⃣ API Endpoints Documentation  
**File: `docs/02-Backend-APIs/api-endpoints-reference.md`**
```markdown
For each endpoint, document:

## GET /api/settings/get.php
**Purpose:** دریافت تمام تنظیمات سیستم
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
      "setting_value": "***مخفی***",
      "setting_type": "encrypted",
      "description": "کلید API سرویس OpenAI",
      "is_system": true
    }
  ],
  "count": 9
}
```

**Error Handling:**
- Database connection errors
- JSON parsing errors
- Missing data scenarios

**Usage Example:**
```dart
final settings = await ApiService.getSettings();
if (settings != null) {
  // Process settings
}
```

**Related Files:**
- `backend/api/settings/get.php`
- `lib/core/services/api_service.dart`
```

### 4️⃣ Flutter Architecture Documentation
**File: `docs/04-Flutter-Frontend/flutter-architecture.md`**
```markdown
Required Content:
- Clean Architecture implementation
- Folder structure explanation
- Dependency injection pattern
- State management with Provider
- Navigation system
- Error handling strategy
- Performance optimization techniques

File Structure Documentation:
```
lib/
├── core/                    # Core functionality
│   ├── config/             # Configuration management
│   ├── constants/          # App constants
│   ├── logger/            # Logging system
│   ├── services/          # API and external services
│   └── theme/             # UI theme and styling
├── data/                  # Data layer (future)
├── domain/                # Business logic layer (future)  
├── presentation/          # UI layer
│   ├── pages/            # Screen pages
│   ├── widgets/          # Reusable widgets
│   └── routes/           # Navigation routing
└── main.dart             # App entry point
```

### 5️⃣ UI Component Library Documentation
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
1. Database Schema (Critical for development)
2. API Reference (Essential for integration)  
3. Flutter Architecture (Core for UI development)
4. UI Components (Important for consistency)
5. Development Workflow (Necessary for team work)

**Maintenance Integration:** Every future prompt will include documentation update requirements to ensure documentation stays current with codebase changes.

---

**Ready to generate professional documentation system for DataSave! 📚✨**