# مرجع سریع Database - Database Quick Reference

## 📊 Document Information
- **Created:** 2025-09-01
- **Last Updated:** 2025-09-01
- **Version:** 1.0
- **Maintainer:** DataSave Development Team
- **Related Files:** `/database_setup.sql`, `/backend/config/database.php`

## 🎯 Overview
مرجع سریع و جامع برای همه اجزای دیتابیس DataSave شامل جداول، queries مفید، stored procedures، و دستورات مدیریت دیتابیس.

## 📋 Table of Contents
- [Tables Overview](#tables-overview)
- [Common Queries](#common-queries)
- [User Management](#user-management)
- [Form Management](#form-management)
- [System Operations](#system-operations)
- [Maintenance Commands](#maintenance-commands)
- [Performance Queries](#performance-queries)
- [Backup & Restore](#backup--restore)

## 📊 Tables Overview

### Core Tables
| Table Name | Purpose | Key Fields | Relationships |
|------------|---------|------------|---------------|
| `users` | مدیریت کاربران | `id`, `email`, `username`, `role` | → `forms`, `form_responses` |
| `forms` | فرم‌های ایجاد شده | `id`, `title`, `user_id`, `config` | ← `users`, → `form_fields` |
| `form_fields` | فیلدهای فرم | `id`, `form_id`, `type`, `config` | ← `forms`, → `field_options` |
| `form_responses` | پاسخ‌های فرم | `id`, `form_id`, `user_id`, `data` | ← `forms`, `users` |
| `field_options` | گزینه‌های فیلد | `id`, `field_id`, `value`, `label` | ← `form_fields` |
| `user_sessions` | نشست‌های کاربر | `id`, `user_id`, `token`, `expires_at` | ← `users` |

### System Tables
| Table Name | Purpose | Key Fields | Description |
|------------|---------|------------|-------------|
| `system_settings` | تنظیمات سیستم | `key`, `value`, `type` | تنظیمات عمومی |
| `activity_logs` | لاگ فعالیت‌ها | `id`, `user_id`, `action`, `timestamp` | رصد فعالیت‌ها |
| `api_keys` | کلیدهای API | `id`, `user_id`, `key_hash`, `permissions` | مدیریت API |
| `file_uploads` | فایل‌های آپلود | `id`, `user_id`, `path`, `size` | مدیریت فایل |

## 🔍 Common Queries

### User Queries
```sql
-- کاربر فعال بر اساس ایمیل
SELECT * FROM users 
WHERE email = 'user@example.com' 
  AND status = 'active' 
  AND deleted_at IS NULL;

-- کاربران اخیر (7 روز گذشته)
SELECT u.*, 
       COUNT(f.id) as forms_count,
       MAX(u.last_login_at) as last_login
FROM users u
LEFT JOIN forms f ON u.id = f.user_id
WHERE u.created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
GROUP BY u.id
ORDER BY u.created_at DESC;

-- کاربران با بیشترین فعالیت
SELECT u.id, u.username, u.email,
       COUNT(DISTINCT f.id) as forms_created,
       COUNT(DISTINCT fr.id) as responses_submitted,
       COUNT(DISTINCT al.id) as total_activities
FROM users u
LEFT JOIN forms f ON u.id = f.user_id
LEFT JOIN form_responses fr ON u.id = fr.user_id
LEFT JOIN activity_logs al ON u.id = al.user_id
WHERE u.deleted_at IS NULL
GROUP BY u.id
HAVING forms_created > 0 OR responses_submitted > 0
ORDER BY total_activities DESC
LIMIT 10;

-- آمار کاربران بر اساس نقش
SELECT role, 
       COUNT(*) as total_users,
       COUNT(CASE WHEN status = 'active' THEN 1 END) as active_users,
       COUNT(CASE WHEN last_login_at >= DATE_SUB(NOW(), INTERVAL 30 DAY) THEN 1 END) as recent_logins
FROM users 
WHERE deleted_at IS NULL
GROUP BY role;
```

### Form Queries
```sql
-- فرم‌های فعال با تعداد پاسخ
SELECT f.id, f.title, f.description,
       u.username as creator,
       COUNT(fr.id) as response_count,
       f.created_at,
       f.updated_at
FROM forms f
LEFT JOIN users u ON f.user_id = u.id
LEFT JOIN form_responses fr ON f.id = fr.form_id
WHERE f.status = 'active' 
  AND f.deleted_at IS NULL
GROUP BY f.id
ORDER BY response_count DESC;

-- جزئیات کامل یک فرم
SELECT f.*,
       u.username as creator_name,
       u.email as creator_email,
       (SELECT COUNT(*) FROM form_fields ff WHERE ff.form_id = f.id) as fields_count,
       (SELECT COUNT(*) FROM form_responses fr WHERE fr.form_id = f.id) as responses_count
FROM forms f
LEFT JOIN users u ON f.user_id = u.id
WHERE f.id = ? AND f.deleted_at IS NULL;

-- فیلدهای یک فرم با گزینه‌ها
SELECT ff.id as field_id, ff.type, ff.label, ff.required, ff.config,
       JSON_ARRAYAGG(
           JSON_OBJECT(
               'id', fo.id,
               'value', fo.value,
               'label', fo.label,
               'order_num', fo.order_num
           )
       ) as options
FROM form_fields ff
LEFT JOIN field_options fo ON ff.id = fo.field_id
WHERE ff.form_id = ? 
  AND ff.deleted_at IS NULL
GROUP BY ff.id
ORDER BY ff.order_num;

-- فرم‌های پرپاسخ (آخر 30 روز)
SELECT f.id, f.title,
       COUNT(fr.id) as recent_responses,
       AVG(TIMESTAMPDIFF(MINUTE, fr.started_at, fr.submitted_at)) as avg_completion_time
FROM forms f
LEFT JOIN form_responses fr ON f.id = fr.form_id 
    AND fr.submitted_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
WHERE f.deleted_at IS NULL
GROUP BY f.id
HAVING recent_responses > 0
ORDER BY recent_responses DESC
LIMIT 20;
```

### Response Analysis Queries
```sql
-- آمار پاسخ‌ها بر اساس تاریخ
SELECT DATE(submitted_at) as submission_date,
       COUNT(*) as response_count,
       COUNT(DISTINCT form_id) as unique_forms,
       COUNT(DISTINCT user_id) as unique_users
FROM form_responses
WHERE submitted_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
  AND deleted_at IS NULL
GROUP BY DATE(submitted_at)
ORDER BY submission_date DESC;

-- پاسخ‌های ناتمام
SELECT fr.id, f.title, u.username,
       fr.started_at,
       TIMESTAMPDIFF(HOUR, fr.started_at, NOW()) as hours_since_start
FROM form_responses fr
JOIN forms f ON fr.form_id = f.id
LEFT JOIN users u ON fr.user_id = u.id
WHERE fr.submitted_at IS NULL 
  AND fr.started_at >= DATE_SUB(NOW(), INTERVAL 24 HOUR)
ORDER BY fr.started_at DESC;

-- تحلیل زمان تکمیل فرم‌ها
SELECT f.id, f.title,
       COUNT(fr.id) as completed_responses,
       AVG(TIMESTAMPDIFF(MINUTE, fr.started_at, fr.submitted_at)) as avg_minutes,
       MIN(TIMESTAMPDIFF(MINUTE, fr.started_at, fr.submitted_at)) as min_minutes,
       MAX(TIMESTAMPDIFF(MINUTE, fr.started_at, fr.submitted_at)) as max_minutes
FROM forms f
JOIN form_responses fr ON f.id = fr.form_id
WHERE fr.submitted_at IS NOT NULL
  AND fr.started_at IS NOT NULL
GROUP BY f.id
HAVING completed_responses >= 5
ORDER BY avg_minutes DESC;
```

## 👥 User Management

### User CRUD Operations
```sql
-- ایجاد کاربر جدید
INSERT INTO users (username, email, password_hash, role, status, created_at)
VALUES (?, ?, ?, 'user', 'pending', NOW());

-- فعال‌سازی کاربر
UPDATE users 
SET status = 'active', 
    email_verified_at = NOW(), 
    updated_at = NOW()
WHERE id = ? AND status = 'pending';

-- تغییر رمز عبور
UPDATE users 
SET password_hash = ?, 
    password_changed_at = NOW(),
    updated_at = NOW()
WHERE id = ?;

-- غیرفعال کردن کاربر
UPDATE users 
SET status = 'inactive',
    updated_at = NOW()
WHERE id = ?;

-- حذف نرم کاربر
UPDATE users 
SET deleted_at = NOW(),
    status = 'deleted'
WHERE id = ?;

-- بازگردانی کاربر حذف شده
UPDATE users 
SET deleted_at = NULL,
    status = 'active',
    updated_at = NOW()
WHERE id = ? AND deleted_at IS NOT NULL;
```

### Session Management
```sql
-- ایجاد نشست جدید
INSERT INTO user_sessions (user_id, token_hash, ip_address, user_agent, expires_at, created_at)
VALUES (?, ?, ?, ?, DATE_ADD(NOW(), INTERVAL 24 HOUR), NOW());

-- تمدید نشست
UPDATE user_sessions 
SET expires_at = DATE_ADD(NOW(), INTERVAL 24 HOUR),
    last_activity = NOW()
WHERE token_hash = ? AND expires_at > NOW();

-- حذف نشست منقضی
DELETE FROM user_sessions 
WHERE expires_at < NOW();

-- حذف همه نشست‌های کاربر
DELETE FROM user_sessions 
WHERE user_id = ?;

-- نشست‌های فعال کاربر
SELECT id, ip_address, user_agent, created_at, last_activity, expires_at
FROM user_sessions 
WHERE user_id = ? AND expires_at > NOW()
ORDER BY last_activity DESC;
```

## 📝 Form Management

### Form Operations
```sql
-- ایجاد فرم جدید
INSERT INTO forms (user_id, title, description, config, status, created_at)
VALUES (?, ?, ?, ?, 'draft', NOW());

-- کپی فرم
INSERT INTO forms (user_id, title, description, config, status, created_at)
SELECT user_id, CONCAT(title, ' - کپی'), description, config, 'draft', NOW()
FROM forms WHERE id = ?;

-- انتشار فرم
UPDATE forms 
SET status = 'published',
    published_at = NOW(),
    updated_at = NOW()
WHERE id = ? AND user_id = ?;

-- آرشیو فرم
UPDATE forms 
SET status = 'archived',
    archived_at = NOW(),
    updated_at = NOW()
WHERE id = ? AND user_id = ?;

-- آمار فرم
SELECT 
    (SELECT COUNT(*) FROM form_responses WHERE form_id = ?) as total_responses,
    (SELECT COUNT(*) FROM form_responses WHERE form_id = ? AND submitted_at IS NOT NULL) as completed_responses,
    (SELECT COUNT(*) FROM form_responses WHERE form_id = ? AND submitted_at IS NULL) as incomplete_responses,
    (SELECT AVG(TIMESTAMPDIFF(MINUTE, started_at, submitted_at)) FROM form_responses WHERE form_id = ? AND submitted_at IS NOT NULL) as avg_completion_time;
```

### Field Management
```sql
-- اضافه کردن فیلد به فرم
INSERT INTO form_fields (form_id, type, label, required, config, order_num, created_at)
VALUES (?, ?, ?, ?, ?, 
    (SELECT COALESCE(MAX(order_num), 0) + 1 FROM form_fields WHERE form_id = ?), 
    NOW());

-- تغییر ترتیب فیلدها
UPDATE form_fields 
SET order_num = CASE 
    WHEN id = ? THEN ?
    WHEN id = ? THEN ?
    ELSE order_num 
END,
updated_at = NOW()
WHERE form_id = ?;

-- حذف فیلد
UPDATE form_fields 
SET deleted_at = NOW()
WHERE id = ? AND form_id IN (SELECT id FROM forms WHERE user_id = ?);

-- گزینه‌های فیلد select/radio/checkbox
INSERT INTO field_options (field_id, value, label, order_num)
VALUES (?, ?, ?, ?);
```

## ⚙️ System Operations

### Settings Management
```sql
-- دریافت تنظیمات سیستم
SELECT * FROM system_settings 
WHERE key IN ('app_name', 'maintenance_mode', 'max_file_size', 'allowed_file_types');

-- بروزرسانی تنظیمات
INSERT INTO system_settings (key, value, type, updated_at)
VALUES (?, ?, ?, NOW())
ON DUPLICATE KEY UPDATE 
    value = VALUES(value),
    updated_at = NOW();

-- فعال/غیرفعال کردن حالت تعمیرات
UPDATE system_settings 
SET value = ?, updated_at = NOW()
WHERE key = 'maintenance_mode';
```

### Activity Logging
```sql
-- ثبت فعالیت
INSERT INTO activity_logs (user_id, action, resource_type, resource_id, ip_address, user_agent, created_at)
VALUES (?, ?, ?, ?, ?, ?, NOW());

-- لاگ‌های اخیر کاربر
SELECT al.*, u.username
FROM activity_logs al
LEFT JOIN users u ON al.user_id = u.id
WHERE al.user_id = ?
ORDER BY al.created_at DESC
LIMIT 50;

-- لاگ‌های مشکوک
SELECT al.*, u.username
FROM activity_logs al
LEFT JOIN users u ON al.user_id = u.id
WHERE al.action IN ('failed_login', 'suspicious_activity', 'security_violation')
  AND al.created_at >= DATE_SUB(NOW(), INTERVAL 24 HOUR)
ORDER BY al.created_at DESC;

-- پاکسازی لاگ‌های قدیمی
DELETE FROM activity_logs 
WHERE created_at < DATE_SUB(NOW(), INTERVAL 6 MONTH);
```

## 🔧 Maintenance Commands

### Database Cleanup
```sql
-- پاکسازی نشست‌های منقضی
DELETE FROM user_sessions 
WHERE expires_at < DATE_SUB(NOW(), INTERVAL 7 DAY);

-- پاکسازی پاسخ‌های ناتمام قدیمی (بیش از 7 روز)
DELETE FROM form_responses 
WHERE submitted_at IS NULL 
  AND created_at < DATE_SUB(NOW(), INTERVAL 7 DAY);

-- پاکسازی فایل‌های یتیم
DELETE FROM file_uploads 
WHERE id NOT IN (
    SELECT DISTINCT JSON_UNQUOTE(JSON_EXTRACT(data, '$.file_id'))
    FROM form_responses 
    WHERE JSON_EXTRACT(data, '$.file_id') IS NOT NULL
);

-- بهینه‌سازی جداول
OPTIMIZE TABLE users, forms, form_fields, form_responses, activity_logs;

-- بازسازی ایندکس‌ها
ANALYZE TABLE users, forms, form_fields, form_responses;
```

### Index Management
```sql
-- بررسی ایندکس‌های موجود
SHOW INDEX FROM users;
SHOW INDEX FROM forms;
SHOW INDEX FROM form_responses;

-- ایجاد ایندکس‌های مفید
CREATE INDEX idx_users_email_status ON users(email, status);
CREATE INDEX idx_forms_user_status ON forms(user_id, status);
CREATE INDEX idx_responses_form_submitted ON form_responses(form_id, submitted_at);
CREATE INDEX idx_activity_user_created ON activity_logs(user_id, created_at);
CREATE INDEX idx_sessions_token_expires ON user_sessions(token_hash, expires_at);

-- حذف ایندکس غیرضروری
DROP INDEX idx_old_index ON table_name;
```

## 📈 Performance Queries

### Query Performance Analysis
```sql
-- کوئری‌های کند
SELECT query_time, lock_time, rows_examined, rows_sent, sql_text
FROM mysql.slow_log
WHERE start_time >= DATE_SUB(NOW(), INTERVAL 1 HOUR)
ORDER BY query_time DESC;

-- آمار جداول
SELECT 
    table_name,
    table_rows,
    data_length,
    index_length,
    (data_length + index_length) as total_size
FROM information_schema.tables 
WHERE table_schema = 'datasave'
ORDER BY total_size DESC;

-- آمار ایندکس‌ها
SELECT 
    table_name,
    index_name,
    cardinality,
    index_type
FROM information_schema.statistics 
WHERE table_schema = 'datasave'
ORDER BY table_name, cardinality DESC;
```

### System Status
```sql
-- وضعیت connection ها
SHOW STATUS LIKE 'Connections';
SHOW STATUS LIKE 'Threads_connected';
SHOW STATUS LIKE 'Threads_running';

-- آمار کوئری
SHOW STATUS LIKE 'Questions';
SHOW STATUS LIKE 'Queries';
SHOW STATUS LIKE 'Slow_queries';

-- وضعیت buffer pool
SHOW STATUS LIKE 'Innodb_buffer_pool%';

-- Process list
SHOW PROCESSLIST;
```

## 💾 Backup & Restore

### Backup Commands
```bash
# پشتیبان کامل
mysqldump -u username -p --single-transaction --routines --triggers datasave > backup_$(date +%Y%m%d_%H%M%S).sql

# پشتیبان جداول خاص
mysqldump -u username -p datasave users forms form_fields form_responses > backup_core_tables.sql

# پشتیبان ساختار فقط
mysqldump -u username -p --no-data datasave > schema_only.sql

# پشتیبان با compression
mysqldump -u username -p --single-transaction datasave | gzip > backup.sql.gz
```

### Restore Commands
```bash
# بازگردانی کامل
mysql -u username -p datasave < backup_file.sql

# بازگردانی از فایل فشرده
gunzip < backup.sql.gz | mysql -u username -p datasave

# بازگردانی جدول خاص
mysql -u username -p datasave -e "DROP TABLE IF EXISTS users;"
mysqldump -u username -p source_db users | mysql -u username -p target_db
```

### Automated Backup Script
```bash
#!/bin/bash
# Daily backup script

DB_NAME="datasave"
DB_USER="username"
DB_PASS="password"
BACKUP_DIR="/path/to/backups"
DATE=$(date +%Y%m%d_%H%M%S)

# Create backup
mysqldump -u $DB_USER -p$DB_PASS --single-transaction $DB_NAME > $BACKUP_DIR/backup_$DATE.sql

# Compress backup
gzip $BACKUP_DIR/backup_$DATE.sql

# Delete old backups (keep last 30 days)
find $BACKUP_DIR -name "backup_*.sql.gz" -mtime +30 -delete

# Log completion
echo "$(date): Backup completed - backup_$DATE.sql.gz" >> $BACKUP_DIR/backup.log
```

## 🛡️ Security Queries

### Security Monitoring
```sql
-- تشخیص ورودی‌های مشکوک
SELECT ip_address, COUNT(*) as failed_attempts,
       MIN(created_at) as first_attempt,
       MAX(created_at) as last_attempt
FROM activity_logs
WHERE action = 'failed_login'
  AND created_at >= DATE_SUB(NOW(), INTERVAL 1 HOUR)
GROUP BY ip_address
HAVING failed_attempts >= 5
ORDER BY failed_attempts DESC;

-- کاربران با فعالیت غیرعادی
SELECT u.id, u.username, u.email,
       COUNT(DISTINCT al.ip_address) as unique_ips,
       COUNT(al.id) as total_activities
FROM users u
JOIN activity_logs al ON u.id = al.user_id
WHERE al.created_at >= DATE_SUB(NOW(), INTERVAL 24 HOUR)
GROUP BY u.id
HAVING unique_ips > 10 OR total_activities > 1000
ORDER BY total_activities DESC;

-- نشست‌های فعال مشکوک
SELECT us.*, u.username, u.email,
       COUNT(al.id) as activities_count
FROM user_sessions us
JOIN users u ON us.user_id = u.id
LEFT JOIN activity_logs al ON us.user_id = al.user_id 
    AND al.created_at >= us.created_at
WHERE us.expires_at > NOW()
GROUP BY us.id
HAVING activities_count = 0 OR activities_count > 500
ORDER BY us.created_at DESC;
```

## 🔄 Related Documentation
- [Database Design](../03-Database-Schema/database-design.md)
- [Tables Reference](../03-Database-Schema/tables-reference.md)
- [API Endpoints Reference](../02-Backend-APIs/api-endpoints-reference.md)
- [Performance Optimization](../03-Database-Schema/indexes-performance.md)

---
*Last updated: 2025-09-01*  
*File: docs/99-Quick-Reference/database-quick-reference.md*