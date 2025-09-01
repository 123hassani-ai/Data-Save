# مرجع کامل جداول - Tables Reference

## 📊 Document Information
- **Created:** 2025-01-09
- **Last Updated:** 2025-09-01
- **Version:** 5.1.0
- **Maintainer:** DataSave Development Team
- **Related Files:** `/database_setup.sql`, `/backend/config/database.php`

## 🎯 Overview
مرجع کامل همه جداول دیتابیس DataSave به همراه جداول جدید Form Builder Engine مرحله 5.1

## 📋 Table of Contents
- [جداول اصلی سیستم](#جداول-اصلی-سیستم)
  - [system_settings](#جدول-system_settings)
  - [system_logs](#جدول-system_logs)
- [جداول Form Builder](#جداول-form-builder)
  - [users](#جدول-users)
  - [forms](#جدول-forms) 
  - [form_widgets](#جدول-form_widgets)
  - [form_responses](#جدول-form_responses)
- [Views و Triggers](#views-و-triggers)

## 📁 جداول اصلی سیستم - Core System Tables

### جدول system_settings

#### 📋 توضیحات کلی
**Purpose:** ذخیره تنظیمات سیستم شامل تنظیمات OpenAI، تنظیمات Form Builder، و پیکربندی‌های عمومی  
**Engine:** InnoDB  
**Charset:** utf8mb4_persian_ci  
**Current Records:** 17 تنظیم فعال (9 اصلی + 8 Form Builder)

#### 🏗️ ساختار جدول
| Column | Type | Key | Null | Default | Description |
|--------|------|-----|------|---------|-------------|
| `id` | INT | PK | NO | AUTO_INCREMENT | شناسه یکتا |
| `setting_key` | VARCHAR(100) | UNIQUE | NO | - | کلید تنظیمات (یکتا) |
| `setting_value` | TEXT | - | YES | NULL | مقدار تنظیمات |
| `setting_type` | ENUM | - | NO | 'string' | نوع داده (string, json, boolean, number, encrypted) |
| `description` | VARCHAR(255) | - | YES | NULL | توضیحات فارسی |
| `is_system` | BOOLEAN | - | NO | FALSE | آیا تنظیمات سیستمی است؟ |
| `is_readonly` | BOOLEAN | - | NO | FALSE | آیا فقط خواندنی است؟ |
| `created_at` | TIMESTAMP | - | NO | CURRENT_TIMESTAMP | زمان ایجاد |
| `updated_at` | TIMESTAMP | - | NO | ON UPDATE | زمان بروزرسانی |

#### 🔑 کلیدها و اندیکس‌ها
```sql
PRIMARY KEY (id)
UNIQUE KEY uk_setting_key (setting_key)
KEY idx_setting_key (setting_key)
KEY idx_is_system (is_system)  
KEY idx_setting_type (setting_type)
KEY idx_created_at (created_at)
```

#### 📊 داده‌های فعلی
| ID | Setting Key | Value | Type | Description | System |
|----|-------------|-------|------|-------------|---------|
| 1 | `openai_api_key` | `sk-proj-VCZeP...` | encrypted | کلید API سرویس OpenAI | ✅ |
| 2 | `openai_model` | `gpt-4` | string | مدل پیش‌فرض OpenAI | ✅ |
| 3 | `openai_max_tokens` | `2048` | number | حداکثر توکن برای پاسخ | ✅ |
| 4 | `openai_temperature` | `0.7` | number | میزان خلاقیت AI | ✅ |
| 5 | `app_language` | `fa` | string | زبان پیش‌فرض برنامه | ✅ |
| 6 | `enable_logging` | `true` | boolean | فعال‌سازی سیستم لاگ | ✅ |
| 7 | `max_log_entries` | `1000` | number | حداکثر تعداد لاگ | ❌ |
| 8 | `app_theme` | `light` | string | تم پیش‌فرض | ❌ |
| 9 | `auto_save` | `true` | boolean | ذخیره خودکار | ❌ |

#### 📝 نمونه SQL Queries
```sql
-- دریافت همه تنظیمات سیستمی
SELECT setting_key, setting_value, setting_type, description
FROM system_settings 
WHERE is_system = TRUE
ORDER BY setting_key;

-- بروزرسانی تنظیمات
UPDATE system_settings 
SET setting_value = ?, updated_at = NOW()
WHERE setting_key = ?;

-- دریافت تنظیمات OpenAI
SELECT setting_key, setting_value
FROM system_settings
WHERE setting_key LIKE 'openai_%';

-- حذف تنظیمات قدیمی
DELETE FROM system_settings 
WHERE is_readonly = FALSE 
  AND updated_at < DATE_SUB(NOW(), INTERVAL 1 YEAR);
```

#### 🔧 API Usage Examples
```php
<?php
// دریافت تمام تنظیمات
public function getAllSettings(): array {
    $sql = "SELECT * FROM system_settings ORDER BY setting_key";
    $stmt = $this->db->query($sql);
    return $stmt->fetchAll();
}

// بروزرسانی تنظیم خاص
public function updateSetting(string $key, $value): bool {
    $sql = "UPDATE system_settings SET setting_value = ?, updated_at = NOW() WHERE setting_key = ?";
    $stmt = $this->db->prepare($sql);
    return $stmt->execute([$value, $key]);
}
?>
```

### جدول system_logs

#### 📋 توضیحات کلی
**Purpose:** ثبت لاگ‌های سیستمی، خطاها، و audit trail برای debugging و monitoring  
**Engine:** InnoDB  
**Charset:** utf8mb4_persian_ci  
**Current Records:** 500+ لاگ فعال  
**Partitioning:** بر اساس سال (2024, 2025, ...)

#### 🏗️ ساختار جدول
| Column | Type | Key | Null | Default | Description |
|--------|------|-----|------|---------|-------------|
| `log_id` | BIGINT | PK | NO | AUTO_INCREMENT | شناسه یکتا لاگ |
| `log_level` | ENUM | - | NO | - | سطح لاگ (DEBUG, INFO, WARNING, ERROR, CRITICAL) |
| `log_category` | VARCHAR(50) | - | NO | - | دسته‌بندی (API, DB, UI, System) |
| `log_message` | TEXT | - | NO | - | پیام اصلی لاگ |
| `log_context` | JSON | - | YES | NULL | اطلاعات تکمیلی JSON |
| `ip_address` | VARCHAR(45) | - | YES | NULL | آدرس IP کاربر |
| `user_agent` | TEXT | - | YES | NULL | اطلاعات مرورگر |
| `session_id` | VARCHAR(128) | - | YES | NULL | شناسه جلسه |
| `user_id` | INT | - | YES | NULL | شناسه کاربر (آینده) |
| `created_at` | TIMESTAMP | - | NO | CURRENT_TIMESTAMP | زمان ثبت |

#### 🔑 کلیدها و اندیکس‌ها
```sql
PRIMARY KEY (log_id)
KEY idx_log_level (log_level)
KEY idx_log_category (log_category)
KEY idx_created_at (created_at)
KEY idx_level_category (log_level, log_category)
KEY idx_user_session (user_id, session_id)
```

#### 📊 آمار استفاده فعلی
```yaml
Log Levels Distribution:
  - DEBUG: 45% (توسعه)
  - INFO: 35% (عملیات معمول)
  - WARNING: 15% (هشدارها)
  - ERROR: 4% (خطاهای قابل تعمیر)
  - CRITICAL: 1% (خطاهای جدی)

Categories:
  - System: 30% (راه‌اندازی، shutdown)
  - API: 25% (درخواست‌های API)
  - Database: 20% (عملیات DB)
  - Frontend: 15% (UI events)
  - Backend: 10% (PHP operations)

Daily Growth: ~50 logs/day (development)
Retention Policy: 30 days (configurable)
```

#### 📝 نمونه SQL Queries
```sql
-- دریافت لاگ‌های اخیر
SELECT log_level, log_category, log_message, created_at
FROM system_logs 
ORDER BY created_at DESC 
LIMIT 50;

-- فیلتر بر اساس سطح خطا
SELECT log_category, COUNT(*) as error_count
FROM system_logs 
WHERE log_level IN ('ERROR', 'CRITICAL')
  AND created_at >= DATE_SUB(NOW(), INTERVAL 24 HOUR)
GROUP BY log_category
ORDER BY error_count DESC;

-- جستجو در محتوای لاگ‌ها
SELECT log_id, log_level, log_message, created_at
FROM system_logs 
WHERE log_message LIKE '%OpenAI%'
  OR JSON_EXTRACT(log_context, '$.api') = 'openai'
ORDER BY created_at DESC;

-- آمار روزانه لاگ‌ها
SELECT DATE(created_at) as log_date, 
       log_level,
       COUNT(*) as count
FROM system_logs
WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
GROUP BY DATE(created_at), log_level
ORDER BY log_date DESC, log_level;
```

#### 🔧 API Usage Examples
```php
<?php
// ثبت لاگ جدید
public function logMessage(string $level, string $category, string $message, ?array $context = null): bool {
    $sql = "INSERT INTO system_logs (log_level, log_category, log_message, log_context, ip_address, user_agent) 
            VALUES (?, ?, ?, ?, ?, ?)";
    
    $stmt = $this->db->prepare($sql);
    return $stmt->execute([
        $level,
        $category,
        $message,
        $context ? json_encode($context) : null,
        $_SERVER['REMOTE_ADDR'] ?? null,
        $_SERVER['HTTP_USER_AGENT'] ?? null
    ]);
}

// دریافت لاگ‌ها با فیلتر
public function getLogs(array $filters = [], int $limit = 50, int $offset = 0): array {
    $sql = "SELECT * FROM system_logs";
    $conditions = [];
    $params = [];
    
    if (!empty($filters['level'])) {
        $conditions[] = "log_level = ?";
        $params[] = $filters['level'];
    }
    
    if (!empty($conditions)) {
        $sql .= " WHERE " . implode(" AND ", $conditions);
    }
    
    $sql .= " ORDER BY created_at DESC LIMIT ? OFFSET ?";
    $params[] = $limit;
    $params[] = $offset;
    
    $stmt = $this->db->prepare($sql);
    $stmt->execute($params);
    return $stmt->fetchAll();
}
?>
```

---

## � جداول Form Builder - Form Builder Tables

### جدول users

#### 📋 توضیحات کلی
**Purpose:** مدیریت کاربران سیستم Form Builder با امکانات احراز هویت و نقش‌های مختلف  
**Engine:** InnoDB  
**Charset:** utf8mb4_persian_ci  
**Current Records:** 2 کاربر (admin + test user)

#### 🏗️ ساختار جدول
| Column | Type | Key | Null | Default | Description |
|--------|------|-----|------|---------|-------------|
| `id` | INT UNSIGNED | PK | NO | AUTO_INCREMENT | شناسه یکتا کاربر |
| `email` | VARCHAR(191) | UNIQUE | NO | - | ایمیل کاربر (یکتا) |
| `password_hash` | VARCHAR(255) | - | NO | - | رمز عبور هش شده با bcrypt |
| `persian_name` | VARCHAR(100) | - | NO | - | نام فارسی کاربر |
| `english_name` | VARCHAR(100) | - | YES | NULL | نام انگلیسی کاربر |
| `role` | ENUM | - | NO | 'user' | نقش کاربر (admin, user, moderator) |
| `status` | ENUM | - | NO | 'pending' | وضعیت کاربر (active, inactive, suspended, pending) |
| `phone` | VARCHAR(15) | - | YES | NULL | شماره تلفن |
| `preferences` | JSON | - | YES | NULL | تنظیمات شخصی کاربر |
| `deleted_at` | TIMESTAMP | - | YES | NULL | زمان حذف نرم |
| `created_at` | TIMESTAMP | - | NO | CURRENT_TIMESTAMP | زمان ایجاد |

### جدول forms

#### 📋 توضیحات کلی
**Purpose:** ذخیره فرم‌های ساخته شده توسط کاربران با ساختار JSON و تنظیمات کامل  
**Engine:** InnoDB  
**Charset:** utf8mb4_persian_ci  
**Current Records:** 1 فرم نمونه (تماس با ما)

#### 🏗️ ساختار جدول
| Column | Type | Key | Null | Default | Description |
|--------|------|-----|------|---------|-------------|
| `id` | INT UNSIGNED | PK | NO | AUTO_INCREMENT | شناسه یکتا فرم |
| `user_id` | INT UNSIGNED | FK | NO | - | شناسه کاربر سازنده فرم |
| `persian_title` | VARCHAR(255) | - | NO | - | عنوان فارسی فرم |
| `persian_description` | TEXT | - | YES | NULL | توضیحات فارسی فرم |
| `form_schema` | JSON | - | NO | - | ساختار JSON فرم و فیلدهای آن |
| `form_config` | JSON | - | YES | NULL | تنظیمات عمومی فرم |
| `status` | ENUM | - | NO | 'draft' | وضعیت فرم (active, draft, archived, published, paused) |
| `is_public` | BOOLEAN | - | NO | FALSE | آیا فرم عمومی است؟ |
| `total_responses` | INT UNSIGNED | - | NO | 0 | تعداد کل پاسخ‌ها |
| `created_at` | TIMESTAMP | - | NO | CURRENT_TIMESTAMP | زمان ایجاد |

### جدول form_widgets

#### 📋 توضیحات کلی
**Purpose:** کتابخانه ویجت‌های فرم ساز شامل ویجت‌های پایه و پیشرفته  
**Engine:** InnoDB  
**Charset:** utf8mb4_persian_ci  
**Current Records:** 10 ویجت پایه (text, select, radio, etc.)

#### 🏗️ ساختار جدول
| Column | Type | Key | Null | Default | Description |
|--------|------|-----|------|---------|-------------|
| `id` | INT UNSIGNED | PK | NO | AUTO_INCREMENT | شناسه یکتا ویجت |
| `widget_type` | VARCHAR(50) | - | NO | - | نوع ویجت (text, select, checkbox, etc) |
| `widget_code` | VARCHAR(100) | UNIQUE | NO | - | کد یکتا ویجت |
| `persian_label` | VARCHAR(255) | - | NO | - | برچسب فارسی ویجت |
| `widget_config` | JSON | - | NO | - | تنظیمات پیش‌فرض ویجت |
| `validation_rules` | JSON | - | YES | NULL | قوانین اعتبارسنجی |
| `icon_name` | VARCHAR(100) | - | YES | NULL | نام آیکون (Material Icons) |
| `usage_count` | INT UNSIGNED | - | NO | 0 | تعداد استفاده در فرم‌ها |
| `is_active` | BOOLEAN | - | NO | TRUE | آیا ویجت فعال است؟ |

### جدول form_responses

#### 📋 توضیحات کلی
**Purpose:** ذخیره پاسخ‌های دریافتی از فرم‌ها همراه با متادیتا و آمار  
**Engine:** InnoDB  
**Charset:** utf8mb4_persian_ci  
**Current Records:** 0 پاسخ (آماده دریافت)

#### 🏗️ ساختار جدول
| Column | Type | Key | Null | Default | Description |
|--------|------|-----|------|---------|-------------|
| `id` | BIGINT UNSIGNED | PK | NO | AUTO_INCREMENT | شناسه یکتا پاسخ |
| `form_id` | INT UNSIGNED | FK | NO | - | شناسه فرم مرتبط |
| `respondent_user_id` | INT UNSIGNED | FK | YES | NULL | شناسه کاربر پاسخ‌دهنده |
| `response_data` | JSON | - | NO | - | داده‌های پاسخ به صورت JSON |
| `respondent_ip` | VARCHAR(45) | - | NO | - | آدرس IP پاسخ‌دهنده |
| `submitted_at` | TIMESTAMP | - | NO | CURRENT_TIMESTAMP | زمان ثبت پاسخ |
| `status` | ENUM | - | NO | 'submitted' | وضعیت پاسخ (submitted, reviewed, approved, rejected) |
| `completion_time` | INT UNSIGNED | - | YES | NULL | زمان تکمیل به ثانیه |
| `quality_score` | DECIMAL(3,2) | - | YES | NULL | امتیاز کیفیت پاسخ |

---

## 🔄 Views و Triggers

### Views ایجاد شده
- **`v_user_forms_stats`** - آمار فرم‌های هر کاربر
- **`v_popular_widgets`** - ویجت‌های پرکاربرد  
- **`v_recent_responses`** - پاسخ‌های اخیر فرم‌ها

### Triggers فعال
- **`trg_response_insert_stats`** - بروزرسانی آمار فرم هنگام دریافت پاسخ
- **`trg_response_delete_stats`** - بروزرسانی آمار هنگام حذف پاسخ
- **`trg_form_create_widget_stats`** - ثبت لاگ ایجاد فرم جدید

---

## 🔮 جداول آینده - Future Tables

### جدول sessions (برنامه‌ریزی شده)

#### 📋 توضیحات کلی
**Purpose:** مدیریت جلسات کاربری و امنیت  
**Status:** فاز بعدی (5.2)  
**Engine:** InnoDB

#### 🏗️ ساختار پیشنهادی
```sql
CREATE TABLE `sessions` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `user_id` INT UNSIGNED NOT NULL,
  `token_hash` VARCHAR(255) NOT NULL,
  `ip_address` VARCHAR(45),
  `user_agent` TEXT,
  `expires_at` TIMESTAMP NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  UNIQUE KEY uk_token (token_hash),
  INDEX idx_user_expires (user_id, expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci;
```

## � خلاصه جداول - Tables Summary

### آمار کلی
| Table | Status | Records | Engine | Charset |
|-------|--------|---------|--------|---------|
| `system_settings` | ✅ Active | 9 | InnoDB | utf8mb4_persian_ci |
| `system_logs` | ✅ Active | 500+ | InnoDB | utf8mb4_persian_ci |
| `users` | ✅ Active | 2 | InnoDB | utf8mb4_persian_ci |
| `forms` | ✅ Active | 1 | InnoDB | utf8mb4_persian_ci |
| `form_widgets` | ✅ Active | 10 | InnoDB | utf8mb4_persian_ci |
| `form_responses` | ✅ Active | 0 | InnoDB | utf8mb4_persian_ci |
| `sessions` | 📅 Planned | 0 | InnoDB | utf8mb4_persian_ci |

### Views ایجاد شده
| View Name | Purpose | Base Tables |
|-----------|---------|-------------|
| `v_user_forms_stats` | آمار فرم‌های کاربر | users, forms |
| `v_popular_widgets` | ویجت‌های پرکاربرد | form_widgets |
| `v_recent_responses` | پاسخ‌های اخیر | form_responses, forms |

### Storage Requirements (واقعی)
```yaml
Current Database Size: ~2MB
Current Tables:
  - system_settings: ~2KB (9 records)
  - system_logs: ~100KB (500+ records)
  - users: ~1KB (2 records)  
  - forms: ~2KB (1 record)
  - form_widgets: ~5KB (10 records)
  - form_responses: ~0KB (0 records)
  - Views: ~1KB (3 views)

Growth Projections:
  - Next 6 months: ~50MB
  - Next 1 year: ~200MB
  - Next 3 years: ~2GB
```

## ⚠️ Important Notes

### نکات مهم
1. **Persian Support**: همه جداول با utf8mb4_persian_ci charset پیاده‌سازی شدند
2. **JSON Fields**: استفاده گسترده از JSON برای انعطاف‌پذیری داده‌ها
3. **Foreign Keys**: Cascade constraints برای حفظ یکپارچگی داده‌ها
4. **Indexing**: ایندکس‌های بهینه برای جستجوهای سریع
5. **Views & Triggers**: برای محاسبات خودکار آمارها

### وضعیت فعلی پایگاه داده
✅ **کامل شده:**
- 6 جدول اصلی ایجاد و آماده
- 3 View آماری فعال
- 3 Trigger برای بروزرسانی خودکار
- داده‌های تست اولیه بارگذاری شده

### محدودیت‌های فعلی
- سیستم backup خودکار نیاز به تنظیم
- Monitoring و alerting نصب نشده
- Replication برای high availability نیاز است
- Performance tuning در production مورد نیاز

### تست‌های انجام شده
✅ همه migrations با موفقیت اجرا شدند  
✅ Foreign keys بدون خطا ایجاد شدند  
✅ Views و Triggers فعال هستند  
✅ داده‌های نمونه successfully inserted  
✅ UTF8 Persian charset تایید شد

## 🔄 Related Documentation
- [Database Design](./database-design.md) - طراحی کلی دیتابیس
- [Relationships Diagram](./relationships-diagram.md) - نمودار روابط جداول  
- [Performance & Indexes](./indexes-performance.md) - بهینه‌سازی عملکرد
- [Migration Scripts](./migration-scripts.md) - اسکریپت‌های مهاجرت

---
*Last updated: 2025-01-09*  
*Document version: 2.1 (Phase 5.1 Database Evolution Completed)*  
*File: /docs/03-Database-Schema/tables-reference.md*  
*Maintainer: DataSave Development Team*
