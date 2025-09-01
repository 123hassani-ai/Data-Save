-- ===================================================
-- Rollback v5.1: برگشت کامل تغییرات Database Evolution
-- نسخه: 5.1.0
-- تاریخ: 2025-09-01  
-- توسط: DataSave Development Team
-- ===================================================

-- ⚠️ اخطار: این اسکریپت تمام تغییرات مرحله 5.1 را برگردانده و داده‌ها را حذف می‌کند
-- لطفاً قبل از اجرا از دیتابیس backup تهیه کنید

-- ثبت شروع عملیات rollback
INSERT INTO `system_logs` (`log_level`, `log_category`, `log_message`, `log_context`) VALUES
('WARNING', 'MIGRATION', 'شروع عملیات Rollback v5.1', 
 JSON_OBJECT('action', 'rollback_start', 'version', '5.1.0', 'timestamp', NOW()));

-- === مرحله 1: حذف Views ===
SELECT 'حذف Views ایجاد شده...' as step_1;

DROP VIEW IF EXISTS `v_recent_responses`;
DROP VIEW IF EXISTS `v_popular_widgets`;  
DROP VIEW IF EXISTS `v_user_forms_stats`;

-- === مرحله 2: حذف Triggers ===
SELECT 'حذف Triggers ایجاد شده...' as step_2;

DROP TRIGGER IF EXISTS `trg_form_create_widget_stats`;
DROP TRIGGER IF EXISTS `trg_response_delete_stats`;
DROP TRIGGER IF EXISTS `trg_response_insert_stats`;

-- === مرحله 3: حذف تنظیمات Form Builder ===
SELECT 'حذف تنظیمات Form Builder...' as step_3;

DELETE FROM `system_settings` WHERE `setting_key` IN (
    'form_builder_enabled',
    'max_forms_per_user', 
    'max_responses_per_form',
    'default_form_template',
    'widget_library_version',
    'response_retention_days',
    'enable_form_analytics',
    'require_user_verification'
);

-- === مرحله 4: حذف جداول به ترتیب وابستگی ===
SELECT 'حذف جداول ایجاد شده...' as step_4;

-- ابتدا Foreign Key constraints را غیرفعال می‌کنیم
SET FOREIGN_KEY_CHECKS = 0;

-- حذف جدول form_responses (بیشترین وابستگی)
DROP TABLE IF EXISTS `form_responses`;
SELECT 'جدول form_responses حذف شد' as status;

-- حذف جدول forms  
DROP TABLE IF EXISTS `forms`;
SELECT 'جدول forms حذف شد' as status;

-- حذف جدول form_widgets
DROP TABLE IF EXISTS `form_widgets`;
SELECT 'جدول form_widgets حذف شد' as status;

-- حذف جدول users
DROP TABLE IF EXISTS `users`;  
SELECT 'جدول users حذف شد' as status;

-- بازگردانی Foreign Key constraints
SET FOREIGN_KEY_CHECKS = 1;

-- === مرحله 5: پاکسازی لاگ‌های مربوط به Form Builder ===
SELECT 'پاکسازی لاگ‌های مربوطه...' as step_5;

DELETE FROM `system_logs` 
WHERE `log_category` IN ('FORM_BUILDER', 'USER_MANAGEMENT')
   OR `log_message` LIKE '%Migration v5.1%'
   OR `log_message` LIKE '%form%'
   OR `log_message` LIKE '%widget%'
   OR `log_message` LIKE '%user%';

-- === مرحله 6: بررسی نهایی ===
SELECT 'بررسی نهایی وضعیت دیتابیس...' as step_6;

-- بررسی عدم وجود جداول حذف شده
SELECT 
    CASE 
        WHEN COUNT(*) = 0 THEN 'تمام جداول v5.1 با موفقیت حذف شدند'
        ELSE CONCAT('تعداد ', COUNT(*), ' جدول هنوز باقی مانده')
    END as table_cleanup_status
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = DATABASE() 
  AND TABLE_NAME IN ('users', 'forms', 'form_widgets', 'form_responses');

-- بررسی عدم وجود Views
SELECT 
    CASE 
        WHEN COUNT(*) = 0 THEN 'تمام Views v5.1 با موفقیت حذف شدند'
        ELSE CONCAT('تعداد ', COUNT(*), ' View هنوز باقی مانده')  
    END as view_cleanup_status
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME LIKE 'v_%';

-- بررسی عدم وجود Triggers  
SELECT
    CASE
        WHEN COUNT(*) = 0 THEN 'تمام Triggers v5.1 با موفقیت حذف شدند'
        ELSE CONCAT('تعداد ', COUNT(*), ' Trigger هنوز باقی مانده')
    END as trigger_cleanup_status
FROM INFORMATION_SCHEMA.TRIGGERS
WHERE TRIGGER_SCHEMA = DATABASE()
  AND TRIGGER_NAME LIKE 'trg_%';

-- === مرحله 7: بررسی سلامت جداول اصلی ===
SELECT 'بررسی سلامت جداول اصلی...' as step_7;

-- بررسی وجود و سلامت جداول اصلی
SELECT 
    TABLE_NAME,
    TABLE_ROWS,
    CASE 
        WHEN TABLE_NAME = 'system_settings' THEN 'جدول تنظیمات سیستم سالم است'
        WHEN TABLE_NAME = 'system_logs' THEN 'جدول لاگ‌ها سالم است'
        ELSE 'جدول شناخته نشده'
    END as status
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = DATABASE() 
  AND TABLE_NAME IN ('system_settings', 'system_logs');

-- تست عملکرد جداول اصلی
SELECT COUNT(*) as system_settings_count FROM `system_settings`;
SELECT COUNT(*) as system_logs_count FROM `system_logs`;

-- === تکمیل عملیات Rollback ===
INSERT INTO `system_logs` (`log_level`, `log_category`, `log_message`, `log_context`) VALUES
('INFO', 'MIGRATION', 'عملیات Rollback v5.1 با موفقیت تکمیل شد', 
 JSON_OBJECT('action', 'rollback_complete', 'version', '5.1.0', 'timestamp', NOW()));

SELECT '🎯 عملیات Rollback با موفقیت تکمیل شد!' as final_result;
SELECT 'دیتابیس به وضعیت قبل از مرحله 5.1 بازگردانده شد' as confirmation;

-- === راهنمای بازیابی (در صورت نیاز) ===
SELECT '
📋 راهنمای بازیابی در صورت نیاز:

1. بازگردانی از Backup:
   mysql -u root -p datasave < backup_before_v5.1.sql

2. اجرای مجدد Migration v5.1:
   SOURCE migration_v5_1_create_users_table.sql;
   SOURCE migration_v5_1_create_forms_table.sql;
   SOURCE migration_v5_1_create_form_widgets_table.sql;
   SOURCE migration_v5_1_create_form_responses_table.sql;
   SOURCE migration_v5_1_indexes_and_relations.sql;
   SOURCE migration_v5_1_default_data.sql;

3. بررسی نهایی:
   SELECT COUNT(*) FROM users;
   SELECT COUNT(*) FROM forms;
   SELECT COUNT(*) FROM form_widgets;

⚠️ توجه: همیشه قبل از Rollback از دیتابیس Backup تهیه کنید
' as recovery_guide;
