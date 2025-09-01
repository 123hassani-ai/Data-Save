-- =====================================================
-- اسکریپت SQL ایجاد دیتابیس و جداول DataSave
-- نسخه: 2.0 - Logger System + Database Connection
-- تاریخ ایجاد: September 2025
-- =====================================================

-- ایجاد دیتابیس اصلی با پشتیبانی کامل از زبان فارسی
CREATE DATABASE IF NOT EXISTS `datasave_db` 
DEFAULT CHARACTER SET utf8mb4 
COLLATE utf8mb4_persian_ci;

-- استفاده از دیتابیس ایجاد شده
USE `datasave_db`;

-- =====================================================
-- جدول تنظیمات سیستم (قابل توسعه و انعطاف‌پذیر)
-- =====================================================
CREATE TABLE IF NOT EXISTS `system_settings` (
  `id` INT PRIMARY KEY AUTO_INCREMENT COMMENT 'شناسه یکتا',
  `setting_key` VARCHAR(100) UNIQUE NOT NULL COMMENT 'کلید تنظیمات (یکتا)',
  `setting_value` TEXT COMMENT 'مقدار تنظیمات',
  `setting_type` ENUM('string','json','boolean','number','encrypted') DEFAULT 'string' COMMENT 'نوع داده',
  `description` VARCHAR(255) COMMENT 'توضیحات تنظیمات',
  `is_system` BOOLEAN DEFAULT FALSE COMMENT 'آیا تنظیمات سیستمی است؟',
  `is_readonly` BOOLEAN DEFAULT FALSE COMMENT 'آیا فقط خواندنی است؟',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'زمان ایجاد',
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'زمان آخرین بروزرسانی',
  
  -- ایندکس‌ها برای بهبود کارایی
  INDEX idx_setting_key (`setting_key`),
  INDEX idx_is_system (`is_system`),
  INDEX idx_setting_type (`setting_type`),
  INDEX idx_created_at (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci
COMMENT='جدول تنظیمات سیستم شامل تنظیمات OpenAI و سایر APIs';

-- =====================================================
-- جدول لاگ‌های سیستمی برای debugging و monitoring
-- =====================================================
CREATE TABLE IF NOT EXISTS `system_logs` (
  `log_id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'شناسه یکتا لاگ',
  `log_level` ENUM('DEBUG','INFO','WARNING','ERROR','CRITICAL') NOT NULL COMMENT 'سطح لاگ',
  `log_category` VARCHAR(50) NOT NULL COMMENT 'دسته‌بندی (DB, API, UI, System, etc.)',
  `log_message` TEXT NOT NULL COMMENT 'پیام اصلی لاگ',
  `log_context` JSON COMMENT 'اطلاعات تکمیلی و context به صورت JSON',
  `ip_address` VARCHAR(45) COMMENT 'آدرس IP کاربر (IPv4 یا IPv6)',
  `user_agent` TEXT COMMENT 'اطلاعات مرورگر کاربر',
  `session_id` VARCHAR(128) COMMENT 'شناسه جلسه کاربر',
  `user_id` INT COMMENT 'شناسه کاربر (در آینده)',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'زمان ثبت لاگ',
  
  -- ایندکس‌ها برای جستجو و فیلتر سریع
  INDEX idx_log_level (`log_level`),
  INDEX idx_log_category (`log_category`),
  INDEX idx_created_at (`created_at`),
  INDEX idx_log_level_category (`log_level`, `log_category`),
  INDEX idx_user_session (`user_id`, `session_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci
COMMENT='جدول لاگ‌های سیستمی برای debugging، monitoring و audit trail';

-- =====================================================
-- درج تنظیمات اولیه سیستم
-- =====================================================

-- پاک کردن داده‌های قبلی (در صورت وجود)
DELETE FROM `system_settings` WHERE `setting_key` IN (
  'openai_api_key', 'openai_model', 'openai_max_tokens', 'openai_temperature',
  'app_language', 'max_forms_per_user', 'enable_logging', 'system_version',
  'maintenance_mode', 'debug_mode'
);

-- تنظیمات OpenAI API
INSERT INTO `system_settings` (`setting_key`, `setting_value`, `setting_type`, `description`, `is_system`, `is_readonly`) VALUES
('openai_api_key', '', 'encrypted', 'کلید API سرویس OpenAI (رمزنگاری شده)', true, false),
('openai_model', 'gpt-4', 'string', 'مدل پیش‌فرض OpenAI برای درخواست‌ها', true, false),
('openai_max_tokens', '2048', 'number', 'حداکثر توکن برای پاسخ OpenAI', true, false),
('openai_temperature', '0.7', 'number', 'میزان خلاقیت AI (0.0 تا 1.0)', true, false),
('openai_timeout', '30', 'number', 'زمان انتظار برای درخواست OpenAI (ثانیه)', true, false);

-- تنظیمات عمومی سیستم
INSERT INTO `system_settings` (`setting_key`, `setting_value`, `setting_type`, `description`, `is_system`, `is_readonly`) VALUES
('app_language', 'fa', 'string', 'زبان پیش‌فرض برنامه (fa, en)', true, false),
('system_version', '2.0.0', 'string', 'نسخه فعلی سیستم', true, true),
('enable_logging', 'true', 'boolean', 'فعال‌سازی سیستم لاگ', true, false),
('debug_mode', 'true', 'boolean', 'حالت توسعه (debug) فعال باشد؟', true, false),
('maintenance_mode', 'false', 'boolean', 'حالت تعمیر و نگهداری', true, false);

-- تنظیمات کاربری و محدودیت‌ها
INSERT INTO `system_settings` (`setting_key`, `setting_value`, `setting_type`, `description`, `is_system`, `is_readonly`) VALUES
('max_forms_per_user', '50', 'number', 'حداکثر تعداد فرم برای هر کاربر', false, false),
('max_file_upload_size', '10485760', 'number', 'حداکثر اندازه فایل آپلود (بایت) - 10MB', false, false),
('session_timeout', '3600', 'number', 'زمان انقضای جلسه کاربری (ثانیه) - 1 ساعت', false, false);

-- تنظیمات نمایشی و UI
INSERT INTO `system_settings` (`setting_key`, `setting_value`, `setting_type`, `description`, `is_system`, `is_readonly`) VALUES
('default_theme', 'light', 'string', 'تم پیش‌فرض (light, dark)', false, false),
('items_per_page', '20', 'number', 'تعداد آیتم‌ها در هر صفحه', false, false),
('show_welcome_message', 'true', 'boolean', 'نمایش پیام خوش‌آمدگویی', false, false);

-- =====================================================
-- درج لاگ‌های اولیه سیستم
-- =====================================================
INSERT INTO `system_logs` (`log_level`, `log_category`, `log_message`, `log_context`, `created_at`) VALUES
('INFO', 'System', 'سیستم DataSave نصب شد', JSON_OBJECT('version', '2.0.0', 'install_type', 'fresh'), NOW()),
('INFO', 'Database', 'جداول پایه سیستم ایجاد شدند', JSON_OBJECT('tables', JSON_ARRAY('system_settings', 'system_logs')), NOW()),
('INFO', 'Settings', 'تنظیمات اولیه بارگذاری شد', JSON_OBJECT('settings_count', (SELECT COUNT(*) FROM system_settings)), NOW());

-- =====================================================
-- نمایش خلاصه نصب
-- =====================================================
SELECT 
  'نصب موفقیت‌آمیز بود! 🎉' as status,
  (SELECT COUNT(*) FROM system_settings) as total_settings,
  (SELECT COUNT(*) FROM system_settings WHERE is_system = true) as system_settings,
  (SELECT COUNT(*) FROM system_logs) as initial_logs,
  NOW() as installation_time;

-- نمایش تنظیمات OpenAI
SELECT 
  'تنظیمات OpenAI' as category,
  setting_key,
  CASE 
    WHEN setting_key = 'openai_api_key' THEN '***رمزنگاری شده***'
    ELSE setting_value 
  END as setting_value,
  description
FROM system_settings 
WHERE setting_key LIKE 'openai_%'
ORDER BY setting_key;

-- نمایش تنظیمات سیستم
SELECT 
  'تنظیمات سیستم' as category,
  setting_key,
  setting_value,
  setting_type,
  description
FROM system_settings 
WHERE is_system = true AND setting_key NOT LIKE 'openai_%'
ORDER BY setting_key;

COMMIT;

-- =====================================================
-- پیام پایان نصب
-- =====================================================
SELECT '✅ دیتابیس DataSave آماده است!' as message,
       'حالا می‌توانید Flutter را اجرا کنید' as next_step;
