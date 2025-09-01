-- ===================================================
-- Master Migration Script v5.1
-- اجرای کامل تمام migrations مرحله 5.1
-- نسخه: 5.1.0
-- تاریخ: 2025-09-01
-- ===================================================

-- ثبت شروع عملیات migration
INSERT INTO `system_logs` (`log_level`, `log_category`, `log_message`, `log_context`) VALUES
('INFO', 'MIGRATION', 'شروع اجرای Master Migration v5.1', 
 JSON_OBJECT('version', '5.1.0', 'start_time', NOW()));

-- === مرحله 1: ایجاد جدول Users ===
SELECT '🚀 شروع ایجاد جدول Users...' as step_1;
SOURCE migration_v5_1_create_users_table.sql;

-- === مرحله 2: ایجاد جدول Forms ===  
SELECT '🚀 شروع ایجاد جدول Forms...' as step_2;
SOURCE migration_v5_1_create_forms_table.sql;

-- === مرحله 3: ایجاد جدول Form Widgets ===
SELECT '🚀 شروع ایجاد جدول Form Widgets...' as step_3;
SOURCE migration_v5_1_create_form_widgets_table.sql;

-- === مرحله 4: ایجاد جدول Form Responses ===
SELECT '🚀 شروع ایجاد جدول Form Responses...' as step_4;
SOURCE migration_v5_1_create_form_responses_table.sql;

-- === مرحله 5: ایجاد Indexes و Relations ===
SELECT '🚀 شروع ایجاد Indexes و Relations...' as step_5;
SOURCE migration_v5_1_indexes_and_relations.sql;

-- === مرحله 6: درج داده‌های پیش‌فرض ===
SELECT '🚀 شروع درج داده‌های پیش‌فرض...' as step_6;
SOURCE migration_v5_1_default_data.sql;

-- === بررسی نهایی و گزارش ===
SELECT '✅ بررسی نهایی Database Schema...' as final_check;

-- بررسی وجود تمام جداول
SELECT 
    'جدول' as type,
    TABLE_NAME as name,
    TABLE_ROWS as rows_count,
    CASE 
        WHEN TABLE_NAME = 'users' THEN '👤 کاربران سیستم'
        WHEN TABLE_NAME = 'forms' THEN '📝 فرم‌های ساخته شده'  
        WHEN TABLE_NAME = 'form_widgets' THEN '🧩 کتابخانه ویجت‌ها'
        WHEN TABLE_NAME = 'form_responses' THEN '💬 پاسخ‌های دریافتی'
        WHEN TABLE_NAME = 'system_settings' THEN '⚙️ تنظیمات سیستم (موجود)'
        WHEN TABLE_NAME = 'system_logs' THEN '📊 لاگ‌های سیستم (موجود)'
    END as description,
    '✅' as status
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = DATABASE() 
  AND TABLE_NAME IN ('users', 'forms', 'form_widgets', 'form_responses', 'system_settings', 'system_logs')
ORDER BY 
    CASE TABLE_NAME 
        WHEN 'system_settings' THEN 1
        WHEN 'system_logs' THEN 2  
        WHEN 'users' THEN 3
        WHEN 'forms' THEN 4
        WHEN 'form_widgets' THEN 5
        WHEN 'form_responses' THEN 6
    END;

-- بررسی Views ایجاد شده
SELECT 
    'ویو' as type,
    TABLE_NAME as name, 
    '-' as rows_count,
    CASE 
        WHEN TABLE_NAME = 'v_user_forms_stats' THEN '📊 آمار فرم‌های کاربران'
        WHEN TABLE_NAME = 'v_popular_widgets' THEN '🔥 ویجت‌های محبوب'
        WHEN TABLE_NAME = 'v_recent_responses' THEN '📝 پاسخ‌های اخیر'
    END as description,
    '✅' as status
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME LIKE 'v_%'
ORDER BY TABLE_NAME;

-- بررسی تنظیمات Form Builder
SELECT 
    'تنظیمات' as type,
    setting_key as name,
    setting_value as rows_count,
    description,
    CASE WHEN is_system = 1 THEN '🔐 سیستمی' ELSE '👤 کاربری' END as status
FROM system_settings 
WHERE setting_key LIKE '%form%' OR setting_key LIKE '%widget%' OR setting_key LIKE '%response%'
ORDER BY is_system DESC, setting_key;

-- آمار کلی Migration
SELECT 
    (SELECT COUNT(*) FROM users) as total_users,
    (SELECT COUNT(*) FROM forms) as total_forms,  
    (SELECT COUNT(*) FROM form_widgets) as total_widgets,
    (SELECT COUNT(*) FROM form_responses) as total_responses,
    (SELECT COUNT(*) FROM system_settings WHERE setting_key LIKE '%form%') as form_settings;

-- ثبت تکمیل موفق Migration
INSERT INTO `system_logs` (`log_level`, `log_category`, `log_message`, `log_context`) VALUES
('INFO', 'MIGRATION', 'Master Migration v5.1 با موفقیت تکمیل شد', 
 JSON_OBJECT('version', '5.1.0', 'completion_time', NOW(), 'status', 'SUCCESS'));

SELECT '🎉 Migration v5.1 با موفقیت تکمیل شد!' as final_result;
SELECT 'DataSave به Form Builder Core Engine تبدیل شد 🚀' as celebration;

-- نمایش دستورات مفید بعدی
SELECT '
📋 دستورات مفید برای مرحله بعد:

-- تست کاربر ادمین:
SELECT * FROM users WHERE role = "admin";

-- بررسی فرم نمونه:  
SELECT * FROM forms WHERE status = "published";

-- مشاهده ویجت‌های موجود:
SELECT widget_type, persian_label FROM form_widgets WHERE is_active = 1;

-- آمار کلی:
SELECT * FROM v_user_forms_stats;

-- تست API Connection:
-- php -f backend/api/test/connection.php

🎯 آماده برای مرحله 5.2: Form Builder UI Engine
' as next_steps;
