# مرجع کامل جداول - Tables Reference

## 📊 Document Information
- **Created:** 2025-01-09
- **Last Updated:** 2025-01-09
- **Version:** 1.0
- **Maintainer:** DataSave Development Team
- **Related Files:** `/database_setup.sql`, `/backend/config/database.php`

## 🎯 Overview
مرجع کامل همه جداول دیتابیس DataSave با جزئیات کامل ساختار، داده‌های نمونه، و الگوهای استفاده.

## 📋 Table of Contents
- [جداول فعلی](#جداول-فعلی)
  - [system_settings](#جدول-system_settings)
  - [system_logs](#جدول-system_logs)
- [جداول آینده](#جداول-آینده)
  - [users](#جدول-users)
  - [forms](#جدول-forms)
  - [widgets](#جدول-widgets)
  - [form_responses](#جدول-form_responses)

## 📁 جداول فعلی - Current Tables

### جدول system_settings

#### 📋 توضیحات کلی
**Purpose:** ذخیره تنظیمات سیستم شامل تنظیمات OpenAI، تنظیمات برنامه، و پیکربندی‌های عمومی  
**Engine:** InnoDB  
**Charset:** utf8mb4_persian_ci  
**Current Records:** 9 تنظیم فعال

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

## 🔮 جداول آینده - Future Tables

### جدول users

#### 📋 توضیحات کلی
**Purpose:** مدیریت کاربران، احراز هویت، و نقش‌ها  
**Status:** برنامه‌ریزی شده برای فاز 5  
**Engine:** InnoDB  
**Charset:** utf8mb4_persian_ci

#### 🏗️ ساختار پیشنهادی
```sql
CREATE TABLE `users` (
  `user_id` INT PRIMARY KEY AUTO_INCREMENT,
  `username` VARCHAR(50) UNIQUE NOT NULL COMMENT 'نام کاربری یکتا',
  `email` VARCHAR(255) UNIQUE NOT NULL COMMENT 'ایمیل یکتا', 
  `password_hash` VARCHAR(255) NOT NULL COMMENT 'رمز عبور هش شده',
  `first_name` VARCHAR(100) COMMENT 'نام',
  `last_name` VARCHAR(100) COMMENT 'نام خانوادگی',
  `phone` VARCHAR(20) COMMENT 'شماره تلفن',
  `avatar_url` VARCHAR(500) COMMENT 'آدرس تصویر پروفایل',
  `language` CHAR(2) DEFAULT 'fa' COMMENT 'زبان ترجیحی',
  `timezone` VARCHAR(50) DEFAULT 'Asia/Tehran' COMMENT 'منطقه زمانی',
  `role` ENUM('admin','manager','user','guest') DEFAULT 'user' COMMENT 'نقش کاربر',
  `plan` ENUM('free','basic','premium','enterprise') DEFAULT 'free' COMMENT 'پلن اشتراک',
  `email_verified` BOOLEAN DEFAULT FALSE COMMENT 'ایمیل تایید شده؟',
  `is_active` BOOLEAN DEFAULT TRUE COMMENT 'کاربر فعال؟',
  `last_login` TIMESTAMP NULL COMMENT 'آخرین ورود',
  `login_count` INT DEFAULT 0 COMMENT 'تعداد ورود',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  INDEX idx_email (`email`),
  INDEX idx_username (`username`),
  INDEX idx_role (`role`),
  INDEX idx_active (`is_active`),
  INDEX idx_plan (`plan`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci;
```

#### 👤 نقش‌های کاربری
| Role | Permissions | Description |
|------|------------|-------------|
| `admin` | Full access | دسترسی کامل به سیستم |
| `manager` | Manage users & forms | مدیریت کاربران و فرم‌ها |
| `user` | Create forms | ایجاد و مدیریت فرم‌های شخصی |
| `guest` | View only | فقط مشاهده فرم‌های عمومی |

### جدول forms

#### 📋 توضیحات کلی
**Purpose:** ذخیره فرم‌های ایجاد شده توسط کاربران  
**Status:** فاز 3 (در حال توسعه)  
**Engine:** InnoDB  
**Relations:** belongs to User, has many Responses

#### 🏗️ ساختار پیشنهادی
```sql
CREATE TABLE `forms` (
  `form_id` INT PRIMARY KEY AUTO_INCREMENT,
  `form_uuid` CHAR(36) UNIQUE NOT NULL DEFAULT (UUID()) COMMENT 'شناسه عمومی فرم',
  `user_id` INT NOT NULL COMMENT 'شناسه سازنده فرم',
  `form_title` VARCHAR(255) NOT NULL COMMENT 'عنوان فرم',
  `form_description` TEXT COMMENT 'توضیحات فرم',
  `form_structure` JSON NOT NULL COMMENT 'ساختار کامل فرم (fields, validation, etc)',
  `form_settings` JSON COMMENT 'تنظیمات فرم (theme, notifications, etc)',
  `ai_prompt` TEXT COMMENT 'پرامپت اولیه AI که فرم از آن ساخته شد',
  `form_status` ENUM('draft','published','paused','archived') DEFAULT 'draft',
  `form_version` INT DEFAULT 1 COMMENT 'نسخه فرم (برای version control)',
  `view_count` INT DEFAULT 0 COMMENT 'تعداد بازدید',
  `submission_count` INT DEFAULT 0 COMMENT 'تعداد پاسخ',
  `completion_rate` DECIMAL(5,2) DEFAULT 0.00 COMMENT 'درصد تکمیل فرم',
  `is_public` BOOLEAN DEFAULT FALSE COMMENT 'فرم عمومی؟',
  `password_protected` BOOLEAN DEFAULT FALSE COMMENT 'محافظت با رمز؟',
  `password_hash` VARCHAR(255) COMMENT 'رمز فرم (در صورت محافظت)',
  `max_submissions` INT COMMENT 'حداکثر تعداد پاسخ',
  `expires_at` TIMESTAMP NULL COMMENT 'تاریخ انقضا',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
  INDEX idx_user_id (`user_id`),
  INDEX idx_form_status (`form_status`),
  INDEX idx_is_public (`is_public`),
  INDEX idx_created_at (`created_at`),
  FULLTEXT KEY ft_title_desc (`form_title`, `form_description`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci;
```

#### 📊 Form Structure JSON Schema
```json
{
  "form_structure": {
    "fields": [
      {
        "id": "field_1",
        "type": "text_input",
        "label": "نام و نام خانوادگی",
        "required": true,
        "validation": {
          "min_length": 2,
          "max_length": 100,
          "pattern": "persian_name"
        },
        "properties": {
          "placeholder": "نام خود را وارد کنید",
          "help_text": "نام کامل به فارسی"
        }
      }
    ],
    "layout": {
      "theme": "modern",
      "direction": "rtl", 
      "columns": 1
    },
    "logic": {
      "conditional_fields": [],
      "calculations": []
    }
  }
}
```

### جدول widgets

#### 📋 توضیحات کلی
**Purpose:** کتابخانه ویجت‌های قابل استفاده در فرم‌ساز  
**Status:** فاز 3 (در حال توسعه)  
**Engine:** InnoDB

#### 🏗️ ساختار پیشنهادی
```sql
CREATE TABLE `widgets` (
  `widget_id` INT PRIMARY KEY AUTO_INCREMENT,
  `widget_type` VARCHAR(50) NOT NULL COMMENT 'نوع ویجت (text_input, date_picker, etc)',
  `widget_name_fa` VARCHAR(100) NOT NULL COMMENT 'نام فارسی ویجت',
  `widget_name_en` VARCHAR(100) NOT NULL COMMENT 'نام انگلیسی ویجت',
  `widget_icon` VARCHAR(50) COMMENT 'نام آیکون Material',
  `widget_category` VARCHAR(50) COMMENT 'دسته‌بندی (input, selection, display, etc)',
  `default_properties` JSON COMMENT 'ویژگی‌های پیش‌فرض',
  `validation_schema` JSON COMMENT 'قوانین اعتبارسنجی ممکن',
  `render_template` TEXT COMMENT 'الگوی رندر کردن',
  `help_text` TEXT COMMENT 'راهنمای استفاده',
  `is_active` BOOLEAN DEFAULT TRUE COMMENT 'ویجت فعال؟',
  `is_premium` BOOLEAN DEFAULT FALSE COMMENT 'ویجت پریمیوم؟',
  `sort_order` INT DEFAULT 0 COMMENT 'ترتیب نمایش',
  `version` VARCHAR(20) DEFAULT '1.0' COMMENT 'نسخه ویجت',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  UNIQUE KEY uk_widget_type (`widget_type`),
  INDEX idx_category (`widget_category`),
  INDEX idx_active (`is_active`),
  INDEX idx_premium (`is_premium`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci;
```

#### 🧩 انواع ویجت‌های برنامه‌ریزی شده
| Widget Type | Persian Name | Category | Premium |
|-------------|--------------|----------|---------|
| `text_input` | ورودی متن | input | ❌ |
| `textarea` | متن چندخطی | input | ❌ |
| `number_input` | ورودی عدد | input | ❌ |
| `email_input` | ایمیل | input | ❌ |
| `phone_input` | شماره تلفن | input | ❌ |
| `date_picker` | انتخاب تاریخ | input | ❌ |
| `time_picker` | انتخاب زمان | input | ❌ |
| `dropdown` | لیست کشویی | selection | ❌ |
| `radio_group` | گروه رادیویی | selection | ❌ |
| `checkbox_group` | گروه چک‌باکس | selection | ❌ |
| `file_upload` | آپلود فایل | input | ✅ |
| `signature_pad` | امضا دیجیتال | input | ✅ |
| `rating` | امتیازدهی | selection | ✅ |
| `location_picker` | انتخاب موقعیت | input | ✅ |

### جدول form_responses

#### 📋 توضیحات کلی
**Purpose:** ذخیره پاسخ‌های ارسال شده به فرم‌ها  
**Status:** فاز 4 (برنامه‌ریزی شده)  
**Engine:** InnoDB  
**Partitioning:** ماهانه بر اساس تاریخ

#### 🏗️ ساختار پیشنهادی
```sql
CREATE TABLE `form_responses` (
  `response_id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `form_id` INT NOT NULL COMMENT 'شناسه فرم',
  `response_uuid` CHAR(36) UNIQUE NOT NULL DEFAULT (UUID()) COMMENT 'شناسه عمومی پاسخ',
  `respondent_ip` VARCHAR(45) COMMENT 'IP پاسخ‌دهنده',
  `respondent_agent` TEXT COMMENT 'User Agent',
  `response_data` JSON NOT NULL COMMENT 'داده‌های پاسخ کامل',
  `submission_time` DECIMAL(8,3) COMMENT 'زمان تکمیل فرم (ثانیه)',
  `is_complete` BOOLEAN DEFAULT TRUE COMMENT 'پاسخ کامل؟',
  `validation_errors` JSON COMMENT 'خطاهای اعتبارسنجی',
  `score` INT COMMENT 'امتیاز (برای quiz/assessment)',
  `status` ENUM('submitted','reviewed','approved','rejected') DEFAULT 'submitted',
  `reviewed_by` INT COMMENT 'بررسی شده توسط',
  `reviewed_at` TIMESTAMP NULL COMMENT 'زمان بررسی',
  `notes` TEXT COMMENT 'یادداشت‌های بررسی',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (form_id) REFERENCES forms(form_id) ON DELETE CASCADE,
  FOREIGN KEY (reviewed_by) REFERENCES users(user_id) ON DELETE SET NULL,
  INDEX idx_form_id (`form_id`),
  INDEX idx_status (`status`),
  INDEX idx_created_at (`created_at`),
  INDEX idx_is_complete (`is_complete`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci
PARTITION BY RANGE (TO_DAYS(created_at)) (
    PARTITION p202501 VALUES LESS THAN (TO_DAYS('2025-02-01')),
    PARTITION p202502 VALUES LESS THAN (TO_DAYS('2025-03-01')),
    PARTITION p202503 VALUES LESS THAN (TO_DAYS('2025-04-01')),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);
```

#### 📊 Response Data JSON Schema
```json
{
  "response_data": {
    "field_1": {
      "value": "مجتبی حسنی",
      "type": "text_input",
      "validation_passed": true
    },
    "field_2": {
      "value": "majid@example.com", 
      "type": "email_input",
      "validation_passed": true
    },
    "metadata": {
      "start_time": "2025-01-09T10:00:00Z",
      "end_time": "2025-01-09T10:05:30Z",
      "page_views": 1,
      "form_version": 1
    }
  }
}
```

## 📊 خلاصه جداول - Tables Summary

### آمار کلی
| Table | Status | Records | Size | Partitioned |
|-------|--------|---------|------|-------------|
| `system_settings` | ✅ Active | 9 | ~2KB | ❌ |
| `system_logs` | ✅ Active | 500+ | ~100KB | ✅ |
| `users` | 📅 Planned | 0 | - | ❌ |
| `forms` | 🔄 In Progress | 0 | - | ❌ |
| `widgets` | 🔄 In Progress | 0 | - | ❌ |
| `form_responses` | 📅 Future | 0 | - | ✅ |

### Storage Requirements (تخمینی)
```yaml
Current Database Size: ~500KB
Projected 1 Year:
  - users: ~1MB (1000 users)
  - forms: ~10MB (5000 forms)  
  - form_responses: ~100MB (50000 responses)
  - system_logs: ~50MB (partitioned)
  - Total: ~160MB

Projected 3 Years:
  - users: ~5MB (10000 users)
  - forms: ~100MB (50000 forms)
  - form_responses: ~1GB (500000 responses)
  - system_logs: ~200MB (partitioned)
  - Total: ~1.3GB
```

## ⚠️ Important Notes

### نکات مهم
1. **Persian Support**: همه جداول با utf8mb4_persian_ci
2. **JSON Fields**: برای ساختارهای پیچیده و قابل توسعه
3. **Partitioning**: جداول حجیم بر اساس زمان
4. **Foreign Keys**: CASCADE برای data integrity
5. **Indexing**: بر اساس الگوهای query شایع

### محدودیت‌های فعلی
- جداول کاربری هنوز پیاده‌سازی نشده
- سیستم backup خودکار ندارد
- replication تنظیم نشده
- monitoring tools نصب نیست

## 🔄 Related Documentation
- [Database Design](./database-design.md)
- [Relationships Diagram](./relationships-diagram.md)
- [Performance & Indexes](./indexes-performance.md)
- [Migration Scripts](./migration-scripts.md)

---
*Last updated: 2025-01-09*  
*File: /docs/03-Database-Schema/tables-reference.md*
