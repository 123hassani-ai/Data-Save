-- ===================================================
-- Migration v5.1: ایجاد جدول forms
-- نسخه: 5.1.0  
-- تاریخ: 2025-09-01
-- توسط: DataSave Development Team
-- ===================================================

-- بررسی وجود جدول قبل از ایجاد
SELECT 'بررسی وجود جدول forms...' as status;

-- ایجاد جدول فرم‌ها
CREATE TABLE IF NOT EXISTS `forms` (
  `id` INT UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT 'شناسه یکتا فرم',
  `user_id` INT UNSIGNED NOT NULL COMMENT 'شناسه کاربر سازنده فرم',
  
  -- اطلاعات پایه فرم
  `persian_title` VARCHAR(255) NOT NULL COMMENT 'عنوان فارسی فرم',
  `english_title` VARCHAR(255) NULL COMMENT 'عنوان انگلیسی فرم (اختیاری)',
  `persian_description` TEXT NULL COMMENT 'توضیحات فارسی فرم',
  `english_description` TEXT NULL COMMENT 'توضیحات انگلیسی فرم',
  
  -- ساختار و پیکربندی فرم
  `form_schema` JSON NOT NULL COMMENT 'ساختار JSON فرم و فیلدهای آن',
  `form_config` JSON NULL COMMENT 'تنظیمات عمومی فرم (theme, validation, etc)',
  `form_settings` JSON NULL COMMENT 'تنظیمات نمایش فرم (RTL, colors, etc)',
  
  -- مدیریت وضعیت و نسخه
  `status` ENUM('active', 'draft', 'archived', 'published', 'paused') DEFAULT 'draft' COMMENT 'وضعیت فرم',
  `version` VARCHAR(10) DEFAULT '1.0' COMMENT 'نسخه فرم برای version control',
  `parent_form_id` INT UNSIGNED NULL COMMENT 'فرم والد (برای versioning)',
  
  -- آمار و متادیتا
  `total_responses` INT UNSIGNED DEFAULT 0 COMMENT 'تعداد کل پاسخ‌ها',
  `view_count` INT UNSIGNED DEFAULT 0 COMMENT 'تعداد نمایش فرم',
  `last_response_at` TIMESTAMP NULL COMMENT 'زمان آخرین پاسخ دریافتی',
  
  -- تنظیمات دسترسی
  `is_public` BOOLEAN DEFAULT FALSE COMMENT 'آیا فرم عمومی است؟',
  `requires_login` BOOLEAN DEFAULT FALSE COMMENT 'آیا نیاز به ورود دارد؟',
  `max_responses` INT UNSIGNED NULL COMMENT 'حداکثر تعداد پاسخ مجاز',
  `expires_at` TIMESTAMP NULL COMMENT 'زمان انقضای فرم',
  
  -- مدیریت حذف نرم
  `deleted_at` TIMESTAMP NULL COMMENT 'زمان حذف نرم',
  `deleted_by` INT UNSIGNED NULL COMMENT 'شناسه کاربر حذف کننده',
  
  -- مدیریت زمان
  `published_at` TIMESTAMP NULL COMMENT 'زمان انتشار فرم',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'زمان ایجاد',
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'زمان بروزرسانی',
  
  -- تعریف اندیکس‌ها برای عملکرد بهتر
  INDEX `idx_forms_user_id` (`user_id`),
  INDEX `idx_forms_status` (`status`),
  INDEX `idx_forms_created_at` (`created_at`),
  INDEX `idx_forms_published_at` (`published_at`),
  INDEX `idx_forms_is_public` (`is_public`),
  INDEX `idx_forms_expires_at` (`expires_at`),
  INDEX `idx_forms_soft_delete` (`deleted_at`),
  INDEX `idx_forms_user_status` (`user_id`, `status`),
  INDEX `idx_forms_public_status` (`is_public`, `status`),
  
  -- قیدهای خارجی
  FOREIGN KEY `fk_forms_user_id` (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  FOREIGN KEY `fk_forms_parent_form` (`parent_form_id`) REFERENCES `forms` (`id`) ON DELETE SET NULL,
  FOREIGN KEY `fk_forms_deleted_by` (`deleted_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  
  -- محدودیت‌های بررسی
  CONSTRAINT `chk_forms_persian_title` CHECK (CHAR_LENGTH(`persian_title`) >= 3),
  CONSTRAINT `chk_forms_version_format` CHECK (`version` REGEXP '^[0-9]+\.[0-9]+(\.[0-9]+)?$'),
  CONSTRAINT `chk_forms_max_responses` CHECK (`max_responses` IS NULL OR `max_responses` > 0),
  CONSTRAINT `chk_forms_total_responses` CHECK (`total_responses` >= 0)
  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci COMMENT='جدول فرم‌ها - Form Builder Core';

-- اطلاعات جدول ایجاد شده
SELECT 'جدول forms با موفقیت ایجاد شد!' as result;
SELECT CONCAT('تعداد فیلدها: ', COUNT(*)) as field_count 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'forms';

-- لاگ عملیات
INSERT INTO `system_logs` (`log_level`, `log_category`, `log_message`, `log_context`) VALUES
('INFO', 'MIGRATION', 'Migration v5.1: جدول forms ایجاد شد', JSON_OBJECT('table', 'forms', 'version', '5.1.0', 'date', NOW()));
