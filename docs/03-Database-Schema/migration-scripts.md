# اسکریپت‌های Migration - Database Migration Scripts

## 📊 Document Information
- **Created:** 2025-09-01
- **Last Updated:** 2025-09-01
- **Version:** 1.0
- **Maintainer:** DataSave Development Team
- **Related Files:** `/database_setup.sql`, `/backend/sql/create_tables.sql`

## 🎯 Overview
مجموعه کامل اسکریپت‌های migration برای DataSave شامل ایجاد جداول، بروزرسانی schema، و مدیریت نسخه‌های دیتابیس با پشتیبانی کامل از زبان فارسی.

## 📋 Table of Contents
- [استراتژی Migration](#استراتژی-migration)
- [Schema Versioning](#schema-versioning)
- [Migration Scripts فعلی](#migration-scripts-فعلی)
- [Future Migrations](#future-migrations)
- [Rollback Scripts](#rollback-scripts)
- [Migration Tools](#migration-tools)
- [Best Practices](#best-practices)

## 📈 استراتژی Migration - Migration Strategy

### Migration Philosophy
```yaml
Migration Approach:
  - Forward-only migrations (no rollbacks to older versions)
  - Incremental schema changes
  - Data preservation priority
  - Persian text compatibility
  - Zero-downtime deployments (where possible)

Naming Convention:
  - Format: YYYY_MM_DD_HHMMSS_descriptive_name.sql
  - Example: 2025_09_01_100000_create_system_settings_table.sql
  - Persian descriptions in comments

Version Control:
  - Git-tracked migration files
  - Sequential execution order
  - Migration status tracking
  - Automated deployment integration
```

### Database Version Tracking
```sql
-- جدول tracking وضعیت migrations
CREATE TABLE schema_migrations (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    version VARCHAR(50) NOT NULL UNIQUE,
    migration_name VARCHAR(255) NOT NULL,
    executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    execution_time_ms INT,
    checksum VARCHAR(64),
    success BOOLEAN DEFAULT TRUE,
    error_message TEXT,
    executed_by VARCHAR(100),
    
    KEY idx_version (version),
    KEY idx_executed_at (executed_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci 
COMMENT='ردیابی وضعیت اجرای migration scripts';

-- ثبت migration اولیه
INSERT INTO schema_migrations (version, migration_name, executed_by) VALUES
('2025_01_09_100000', 'Initial database setup', 'system');
```

## 📜 Migration Scripts فعلی - Current Migration Scripts

### 1️⃣ Initial Database Setup (v2025.01.09.100000)
```sql
-- File: database_setup.sql
-- Purpose: راه‌اندازی اولیه دیتابیس DataSave
-- Status: ✅ Executed
-- Date: 2025-01-09

-- تنظیم charset و collation برای Persian
SET NAMES utf8mb4 COLLATE utf8mb4_persian_ci;
SET character_set_client = utf8mb4;
SET character_set_connection = utf8mb4;
SET character_set_results = utf8mb4;
SET collation_connection = utf8mb4_persian_ci;

-- ایجاد دیتابیس در صورت عدم وجود
CREATE DATABASE IF NOT EXISTS datasave 
CHARACTER SET utf8mb4 COLLATE utf8mb4_persian_ci
COMMENT 'دیتابیس اصلی پروژه DataSave - فرم ساز هوشمند';

USE datasave;

-- جدول تنظیمات سیستم
CREATE TABLE system_settings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    setting_key VARCHAR(100) NOT NULL UNIQUE COMMENT 'کلید یکتا تنظیم',
    setting_value TEXT COMMENT 'مقدار تنظیم',
    setting_type ENUM('string', 'json', 'boolean', 'number', 'encrypted') DEFAULT 'string' COMMENT 'نوع داده',
    description VARCHAR(255) COMMENT 'توضیحات فارسی',
    is_system BOOLEAN DEFAULT FALSE COMMENT 'آیا تنظیم سیستمی است؟',
    is_readonly BOOLEAN DEFAULT FALSE COMMENT 'آیا فقط خواندنی است؟',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    KEY idx_setting_key (setting_key),
    KEY idx_setting_type (setting_type),
    KEY idx_is_system (is_system),
    KEY idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci
COMMENT='جدول تنظیمات سیستم شامل API keys و تنظیمات عمومی';

-- جدول لاگ‌های سیستم  
CREATE TABLE system_logs (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    log_level ENUM('DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL') NOT NULL COMMENT 'سطح لاگ',
    log_category VARCHAR(50) NOT NULL COMMENT 'دسته‌بندی (API, DB, UI, System)',
    log_message TEXT NOT NULL COMMENT 'پیام اصلی لاگ',
    log_context JSON COMMENT 'اطلاعات تکمیلی JSON',
    ip_address VARCHAR(45) COMMENT 'آدرس IP کاربر',
    user_agent TEXT COMMENT 'اطلاعات مرورگر',
    session_id VARCHAR(128) COMMENT 'شناسه جلسه',
    user_id INT COMMENT 'شناسه کاربر (آینده)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    KEY idx_log_level (log_level),
    KEY idx_log_category (log_category),
    KEY idx_created_at (created_at),
    KEY idx_level_category (log_level, log_category),
    KEY idx_user_session (user_id, session_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci
COMMENT='جدول لاگ‌های سیستمی و audit trail'
PARTITION BY RANGE (YEAR(created_at)) (
    PARTITION p2024 VALUES LESS THAN (2025),
    PARTITION p2025 VALUES LESS THAN (2026),
    PARTITION p2026 VALUES LESS THAN (2027),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- درج تنظیمات اولیه
INSERT INTO system_settings (setting_key, setting_value, setting_type, description, is_system, is_readonly) VALUES
('openai_api_key', 'sk-proj-VCZeP...', 'encrypted', 'کلید API سرویس OpenAI', TRUE, TRUE),
('openai_model', 'gpt-4', 'string', 'مدل پیش‌فرض OpenAI', TRUE, FALSE),
('openai_max_tokens', '2048', 'number', 'حداکثر توکن برای پاسخ', TRUE, FALSE),
('openai_temperature', '0.7', 'number', 'میزان خلاقیت AI (0-1)', TRUE, FALSE),
('app_language', 'fa', 'string', 'زبان پیش‌فرض برنامه', FALSE, FALSE),
('enable_logging', 'true', 'boolean', 'فعال‌سازی سیستم لاگ', FALSE, FALSE),
('max_log_entries', '1000', 'number', 'حداکثر تعداد لاگ محلی', FALSE, FALSE),
('app_theme', 'light', 'string', 'تم پیش‌فرض اپلیکیشن', FALSE, FALSE),
('auto_save', 'true', 'boolean', 'ذخیره خودکار فرم‌ها', FALSE, FALSE);

-- لاگ اولیه
INSERT INTO system_logs (log_level, log_category, log_message, log_context) VALUES
('INFO', 'System', 'دیتابیس DataSave با موفقیت راه‌اندازی شد', 
 JSON_OBJECT('version', '1.0.0', 'tables_created', 2, 'charset', 'utf8mb4_persian_ci'));

-- ثبت migration در جدول tracking
INSERT INTO schema_migrations (version, migration_name, executed_by) VALUES
('2025_01_09_100000', 'Initial DataSave database setup', 'system');
```

### 2️⃣ System Performance Indexes (v2025.09.01.101500)
```sql
-- File: 2025_09_01_101500_add_performance_indexes.sql
-- Purpose: بهینه‌سازی عملکرد کوئری‌ها
-- Status: 🚧 Pending
-- Dependencies: Initial setup

USE datasave;

-- اضافه کردن اندیکس‌های بهینه‌سازی
ALTER TABLE system_settings 
ADD KEY idx_key_type (setting_key, setting_type),
ADD KEY idx_system_readonly (is_system, is_readonly),
ADD KEY idx_updated_at (updated_at);

-- بهینه‌سازی جدول لاگ‌ها
ALTER TABLE system_logs 
ADD KEY idx_level_time (log_level, created_at),
ADD KEY idx_category_time (log_category, created_at),
ADD KEY idx_message_fulltext (log_message(100)),
ADD KEY idx_session_time (session_id, created_at);

-- اضافه کردن fulltext search برای لاگ‌ها
ALTER TABLE system_logs 
ADD FULLTEXT KEY ft_log_message (log_message);

-- ثبت migration
INSERT INTO schema_migrations (version, migration_name, executed_by, execution_time_ms) 
VALUES ('2025_09_01_101500', 'Add performance indexes', 'admin', 250);

-- لاگ عملیات
INSERT INTO system_logs (log_level, log_category, log_message, log_context) VALUES
('INFO', 'Database', 'اندیکس‌های بهینه‌سازی اضافه شدند', 
 JSON_OBJECT('migration', '2025_09_01_101500', 'indexes_added', 8));
```

## 🚀 Future Migrations - آینده

### 3️⃣ User Management Tables (v2025.10.01.100000)
```sql
-- File: 2025_10_01_100000_create_user_tables.sql
-- Purpose: ایجاد جداول مدیریت کاربران
-- Status: 📋 Planned

USE datasave;

-- جدول کاربران
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100),
    phone_number VARCHAR(20),
    user_role ENUM('admin', 'user', 'guest') DEFAULT 'user',
    is_active BOOLEAN DEFAULT TRUE,
    email_verified BOOLEAN DEFAULT FALSE,
    phone_verified BOOLEAN DEFAULT FALSE,
    last_login TIMESTAMP NULL,
    login_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    KEY idx_username (username),
    KEY idx_email (email),
    KEY idx_role_active (user_role, is_active),
    KEY idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci
COMMENT='جدول اصلی کاربران سیستم';

-- جدول sessions کاربران
CREATE TABLE user_sessions (
    session_id VARCHAR(128) PRIMARY KEY,
    user_id INT NOT NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    expires_at TIMESTAMP,
    
    KEY idx_user_id (user_id),
    KEY idx_active_expires (is_active, expires_at),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci
COMMENT='جدول sessions فعال کاربران';

-- بروزرسانی جدول لاگ‌ها برای ربط با کاربران
ALTER TABLE system_logs 
ADD CONSTRAINT fk_logs_user 
FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL;
```

### 4️⃣ Forms and Widgets Tables (v2025.11.01.100000)
```sql
-- File: 2025_11_01_100000_create_forms_tables.sql
-- Purpose: ایجاد جداول اصلی فرم‌ها و widgets
-- Status: 📋 Planned

USE datasave;

-- جدول فرم‌ها
CREATE TABLE forms (
    form_id INT AUTO_INCREMENT PRIMARY KEY,
    form_name VARCHAR(200) NOT NULL,
    form_title VARCHAR(255) NOT NULL,
    form_description TEXT,
    form_structure JSON NOT NULL COMMENT 'ساختار کامل فرم در JSON',
    form_settings JSON COMMENT 'تنظیمات فرم (validation, styling, etc)',
    created_by INT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    is_public BOOLEAN DEFAULT FALSE,
    view_count INT DEFAULT 0,
    response_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    KEY idx_name (form_name),
    KEY idx_created_by (created_by),
    KEY idx_active_public (is_active, is_public),
    KEY idx_created_at (created_at),
    FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci
COMMENT='جدول اصلی فرم‌های ایجاد شده';

-- جدول widgets مجاز
CREATE TABLE form_widgets (
    widget_id INT AUTO_INCREMENT PRIMARY KEY,
    widget_type VARCHAR(50) NOT NULL,
    widget_name VARCHAR(100) NOT NULL,
    widget_config JSON COMMENT 'پیکربندی پیش‌فرض widget',
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    KEY idx_type_active (widget_type, is_active),
    KEY idx_sort_order (sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci
COMMENT='جدول widgets قابل استفاده در فرم‌ها';

-- جدول پاسخ‌های فرم‌ها
CREATE TABLE form_responses (
    response_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    form_id INT NOT NULL,
    response_data JSON NOT NULL COMMENT 'داده‌های پاسخ کاربر',
    respondent_ip VARCHAR(45),
    respondent_user_agent TEXT,
    submitted_by INT COMMENT 'کاربر ثبت‌کننده (اگر لاگین باشد)',
    submission_time DECIMAL(5,2) COMMENT 'زمان تکمیل فرم (ثانیه)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    KEY idx_form_id (form_id),
    KEY idx_submitted_by (submitted_by),
    KEY idx_created_at (created_at),
    FOREIGN KEY (form_id) REFERENCES forms(form_id) ON DELETE CASCADE,
    FOREIGN KEY (submitted_by) REFERENCES users(user_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci
COMMENT='جدول پاسخ‌های ارسال شده کاربران'
PARTITION BY RANGE (YEAR(created_at)) (
    PARTITION p2025 VALUES LESS THAN (2026),
    PARTITION p2026 VALUES LESS THAN (2027),
    PARTITION p2027 VALUES LESS THAN (2028),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- درج widgets پیش‌فرض
INSERT INTO form_widgets (widget_type, widget_name, widget_config, sort_order) VALUES
('text_input', 'ورودی متن', JSON_OBJECT('placeholder', 'متن خود را وارد کنید', 'maxlength', 255), 1),
('textarea', 'متن چندخطی', JSON_OBJECT('placeholder', 'توضیحات خود را بنویسید', 'rows', 4), 2),
('select', 'لیست انتخاب', JSON_OBJECT('options', JSON_ARRAY('گزینه 1', 'گزینه 2')), 3),
('radio', 'انتخاب تکی', JSON_OBJECT('options', JSON_ARRAY('بله', 'خیر')), 4),
('checkbox', 'چک‌باکس چندگانه', JSON_OBJECT('options', JSON_ARRAY('گزینه 1', 'گزینه 2')), 5),
('number', 'ورودی عدد', JSON_OBJECT('min', 0, 'max', 1000), 6),
('email', 'ایمیل', JSON_OBJECT('placeholder', 'example@domain.com'), 7),
('phone', 'شماره تلفن', JSON_OBJECT('placeholder', '09123456789'), 8),
('date', 'تاریخ', JSON_OBJECT('format', 'persian'), 9),
('rating', 'امتیازدهی', JSON_OBJECT('max_stars', 5), 10);
```

## 🔄 Rollback Scripts

### Rollback Strategy
```sql
-- File: rollback_template.sql
-- Purpose: الگوی کلی برای rollback scripts
-- Usage: در صورت نیاز به بازگشت تغییرات

-- 1. بررسی وضعیت فعلی
SELECT version, migration_name, executed_at 
FROM schema_migrations 
WHERE version = '[TARGET_VERSION]';

-- 2. پشتیبان‌گیری از داده‌های مهم
CREATE TABLE backup_[TABLE_NAME]_[DATE] AS 
SELECT * FROM [TABLE_NAME] 
WHERE [CONDITIONS];

-- 3. حذف تغییرات
DROP INDEX IF EXISTS [INDEX_NAME] ON [TABLE_NAME];
ALTER TABLE [TABLE_NAME] DROP COLUMN IF EXISTS [COLUMN_NAME];
DROP TABLE IF EXISTS [TABLE_NAME];

-- 4. ثبت rollback در migrations
INSERT INTO schema_migrations (version, migration_name, executed_by) 
VALUES ('[ROLLBACK_VERSION]', 'Rollback: [DESCRIPTION]', '[ADMIN_NAME]');

-- 5. لاگ عملیات rollback
INSERT INTO system_logs (log_level, log_category, log_message, log_context) VALUES
('WARNING', 'Database', 'Rollback executed for migration [VERSION]', 
 JSON_OBJECT('rollback_version', '[ROLLBACK_VERSION]', 'reason', '[REASON]'));
```

## 🛠️ Migration Tools

### PHP Migration Runner
```php
<?php
// backend/tools/migration_runner.php
class MigrationRunner {
    private $pdo;
    private $migrationsPath;
    
    public function __construct() {
        $this->pdo = DatabaseConfig::getInstance()->getPDO();
        $this->migrationsPath = __DIR__ . '/../sql/migrations/';
    }
    
    public function runPendingMigrations(): array {
        $executed = $this->getExecutedMigrations();
        $available = $this->getAvailableMigrations();
        $pending = array_diff($available, $executed);
        
        $results = [];
        foreach ($pending as $migration) {
            $results[] = $this->executeMigration($migration);
        }
        
        return $results;
    }
    
    private function executeMigration(string $migrationFile): array {
        $startTime = microtime(true);
        
        try {
            $this->pdo->beginTransaction();
            
            $sql = file_get_contents($this->migrationsPath . $migrationFile);
            $this->pdo->exec($sql);
            
            $executionTime = (microtime(true) - $startTime) * 1000;
            
            // ثبت در جدول migrations
            $version = $this->extractVersionFromFilename($migrationFile);
            $stmt = $this->pdo->prepare(
                "INSERT INTO schema_migrations (version, migration_name, execution_time_ms, executed_by) 
                 VALUES (?, ?, ?, ?)"
            );
            $stmt->execute([$version, $migrationFile, $executionTime, 'migration_runner']);
            
            $this->pdo->commit();
            
            return [
                'migration' => $migrationFile,
                'status' => 'success',
                'execution_time_ms' => $executionTime
            ];
            
        } catch (Exception $e) {
            $this->pdo->rollback();
            
            // ثبت خطا در migrations table
            $stmt = $this->pdo->prepare(
                "INSERT INTO schema_migrations (version, migration_name, success, error_message, executed_by) 
                 VALUES (?, ?, FALSE, ?, ?)"
            );
            $stmt->execute([$version, $migrationFile, $e->getMessage(), 'migration_runner']);
            
            return [
                'migration' => $migrationFile,
                'status' => 'error',
                'error' => $e->getMessage()
            ];
        }
    }
}
?>
```

### Flutter Migration Status Check
```dart
// lib/core/database/migration_status.dart
class MigrationStatus {
  static Future<Map<String, dynamic>> checkMigrationStatus() async {
    try {
      final response = await ApiService.checkMigrationStatus();
      
      if (response != null && response['success'] == true) {
        return {
          'status': 'current',
          'latest_version': response['latest_version'],
          'pending_count': response['pending_count'],
          'last_migration': response['last_migration'],
        };
      }
      
      return {'status': 'unknown'};
      
    } catch (e) {
      LoggerService.error('MigrationStatus', 'Failed to check migration status: $e');
      return {'status': 'error', 'error': e.toString()};
    }
  }
  
  static Future<bool> requiresMigration() async {
    final status = await checkMigrationStatus();
    return status['pending_count'] != null && status['pending_count'] > 0;
  }
}
```

## ✅ Best Practices

### Migration Guidelines
```yaml
Before Writing Migration:
  - ✅ Plan schema changes carefully
  - ✅ Consider data migration implications
  - ✅ Test on development database first
  - ✅ Include Persian text compatibility
  - ✅ Add proper indexes for performance

During Migration:
  - ✅ Use transactions for atomic changes
  - ✅ Include execution time tracking
  - ✅ Log all major operations
  - ✅ Handle errors gracefully
  - ✅ Validate data integrity after changes

After Migration:
  - ✅ Verify all functions work correctly
  - ✅ Check application compatibility
  - ✅ Monitor performance impacts
  - ✅ Update documentation
  - ✅ Inform development team

File Organization:
  - ✅ Sequential numbering system
  - ✅ Descriptive filenames
  - ✅ Separate rollback scripts
  - ✅ Version control all scripts
  - ✅ Environment-specific configs
```

### Performance Considerations
- Migration execution during low-traffic periods
- Chunked data migrations for large datasets
- Index creation with ALGORITHM=INPLACE when possible
- Monitor resource usage during migration
- Have rollback plan ready

## ⚠️ Important Notes

### Persian Text Compatibility
- همه migrations باید charset=utf8mb4 را حفظ کنند
- Persian collation در تمام text columns
- Persian text validation در business logic

### Production Safety
- هرگز migrations را مستقیماً در production اجرا نکنید
- همیشه از backup قبل از migration بگیرید
- Migration testing در staging environment

### Data Migration
- برای تغییرات ساختاری، ابتدا داده‌ها را migrate کنید
- Validate data integrity بعد از هر تغییر
- Keep historical data when possible

## 🔄 Related Documentation
- [Database Design](database-design.md)
- [Tables Reference](tables-reference.md)
- [PHP Backend Overview](../02-Backend-APIs/php-backend-overview.md)
- [Development Workflow](../07-Development-Workflow/development-environment.md)

## 📚 References
- [MySQL Migration Best Practices](https://dev.mysql.com/doc/refman/8.0/en/alter-table.html)
- [Database Versioning Strategies](https://flywaydb.org/documentation/)
- [PHP PDO Transaction Handling](https://www.php.net/manual/en/pdo.transactions.php)

---
*Last updated: 2025-09-01*
*File: docs/03-Database-Schema/migration-scripts.md*