-- =====================================================
-- اسکریپت کامل دیتابیس DataSave - تمام جداول مورد نیاز
-- نسخه: 5.2 - Form Builder Complete
-- تاریخ: September 2025
-- =====================================================

USE `datasave_db`;

-- =====================================================
-- جدول کاربران - Users Table
-- =====================================================
CREATE TABLE IF NOT EXISTS `users` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `username` VARCHAR(50) UNIQUE NOT NULL,
  `email` VARCHAR(100) UNIQUE NOT NULL,
  `password_hash` VARCHAR(255),
  `first_name` VARCHAR(50),
  `last_name` VARCHAR(50),
  `role` ENUM('admin','user','guest') DEFAULT 'user',
  `status` ENUM('active','inactive','pending','deleted') DEFAULT 'pending',
  `email_verified_at` TIMESTAMP NULL,
  `last_login_at` TIMESTAMP NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` TIMESTAMP NULL,
  
  INDEX idx_username (`username`),
  INDEX idx_email (`email`),
  INDEX idx_status (`status`),
  INDEX idx_created_at (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci
COMMENT='جدول کاربران سیستم';

-- =====================================================
-- جدول فرم‌ها - Forms Table
-- =====================================================
CREATE TABLE IF NOT EXISTS `forms` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `persian_title` VARCHAR(255) NOT NULL,
  `english_title` VARCHAR(255),
  `persian_description` TEXT,
  `english_description` TEXT,
  `form_schema` JSON NOT NULL COMMENT 'ساختار کامل فرم به صورت JSON',
  `form_config` JSON COMMENT 'تنظیمات ظاهری و رفتاری فرم',
  `form_settings` JSON COMMENT 'تنظیمات عمومی فرم',
  `status` ENUM('draft','published','archived','deleted') DEFAULT 'draft',
  `is_public` BOOLEAN DEFAULT FALSE,
  `requires_login` BOOLEAN DEFAULT FALSE,
  `max_responses` INT DEFAULT NULL,
  `response_count` INT DEFAULT 0,
  `expires_at` TIMESTAMP NULL,
  `published_at` TIMESTAMP NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` TIMESTAMP NULL,
  
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  INDEX idx_user_id (`user_id`),
  INDEX idx_status (`status`),
  INDEX idx_is_public (`is_public`),
  INDEX idx_created_at (`created_at`),
  INDEX idx_published_at (`published_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci
COMMENT='جدول فرم‌های ایجاد شده توسط کاربران';

-- =====================================================
-- جدول کتابخانه ویجت‌ها - Widget Library
-- =====================================================
CREATE TABLE IF NOT EXISTS `form_widgets` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `widget_type` VARCHAR(50) NOT NULL,
  `persian_label` VARCHAR(100) NOT NULL,
  `english_label` VARCHAR(100),
  `persian_description` TEXT,
  `english_description` TEXT,
  `icon_name` VARCHAR(50),
  `widget_category` VARCHAR(50) DEFAULT 'basic',
  `widget_config` JSON COMMENT 'تنظیمات پیش‌فرض ویجت',
  `validation_rules` JSON COMMENT 'قوانین اعتبارسنجی پیش‌فرض',
  `is_active` BOOLEAN DEFAULT TRUE,
  `is_premium` BOOLEAN DEFAULT FALSE,
  `display_order` INT DEFAULT 0,
  `usage_count` INT DEFAULT 0,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  INDEX idx_widget_type (`widget_type`),
  INDEX idx_widget_category (`widget_category`),
  INDEX idx_is_active (`is_active`),
  INDEX idx_display_order (`display_order`),
  INDEX idx_usage_count (`usage_count`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci
COMMENT='کتابخانه ویجت‌های قابل استفاده در فرم‌ساز';

-- =====================================================
-- جدول پاسخ‌های فرم - Form Responses
-- =====================================================
CREATE TABLE IF NOT EXISTS `form_responses` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `form_id` INT NOT NULL,
  `user_id` INT NULL COMMENT 'NULL برای پاسخ‌های مهمان',
  `response_data` JSON NOT NULL COMMENT 'داده‌های پاسخ به صورت JSON',
  `ip_address` VARCHAR(45),
  `user_agent` TEXT,
  `started_at` TIMESTAMP NULL,
  `submitted_at` TIMESTAMP NULL,
  `is_complete` BOOLEAN DEFAULT FALSE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (`form_id`) REFERENCES `forms`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  INDEX idx_form_id (`form_id`),
  INDEX idx_user_id (`user_id`),
  INDEX idx_is_complete (`is_complete`),
  INDEX idx_submitted_at (`submitted_at`),
  INDEX idx_created_at (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci
COMMENT='پاسخ‌های ارسال شده توسط کاربران برای فرم‌ها';

-- =====================================================
-- جدول نشست‌های کاربران - User Sessions
-- =====================================================
CREATE TABLE IF NOT EXISTS `user_sessions` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `session_token` VARCHAR(255) UNIQUE NOT NULL,
  `ip_address` VARCHAR(45),
  `user_agent` TEXT,
  `expires_at` TIMESTAMP NOT NULL,
  `last_activity` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  INDEX idx_user_id (`user_id`),
  INDEX idx_session_token (`session_token`),
  INDEX idx_expires_at (`expires_at`),
  INDEX idx_last_activity (`last_activity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci
COMMENT='نشست‌های فعال کاربران';

-- =====================================================
-- درج ویجت‌های پیش‌فرض - Default Widgets
-- =====================================================
INSERT IGNORE INTO `form_widgets` (`widget_type`, `persian_label`, `english_label`, `persian_description`, `english_description`, `icon_name`, `widget_category`, `widget_config`, `validation_rules`, `display_order`) VALUES

-- ویجت‌های پایه - Basic Widgets
('text', 'کادر متن', 'Text Input', 'فیلد ورودی متن تک خطی', 'Single line text input field', 'text_fields', 'basic', 
 JSON_OBJECT('placeholder', 'متن خود را وارد کنید', 'max_length', 255), 
 JSON_OBJECT('required', false, 'min_length', 0, 'max_length', 255), 1),

('textarea', 'متن چندخطی', 'Textarea', 'فیلد ورودی متن چند خطی', 'Multi-line text input field', 'notes', 'basic',
 JSON_OBJECT('placeholder', 'متن چندخطی خود را وارد کنید', 'rows', 4, 'max_length', 1000),
 JSON_OBJECT('required', false, 'min_length', 0, 'max_length', 1000), 2),

('number', 'ورودی عددی', 'Number Input', 'فیلد ورودی اعداد', 'Numeric input field', 'numbers', 'basic',
 JSON_OBJECT('placeholder', 'عدد را وارد کنید', 'min', 0, 'max', 999999),
 JSON_OBJECT('required', false, 'type', 'number'), 3),

('email', 'ایمیل', 'Email Input', 'فیلد ورودی آدرس ایمیل', 'Email address input field', 'alternate_email', 'basic',
 JSON_OBJECT('placeholder', 'name@example.com'),
 JSON_OBJECT('required', false, 'type', 'email'), 4),

-- ویجت‌های انتخابی - Selection Widgets
('select', 'لیست کشویی', 'Select Dropdown', 'لیست کشویی برای انتخاب گزینه', 'Dropdown selection list', 'arrow_drop_down', 'selection',
 JSON_OBJECT('options', JSON_ARRAY(JSON_OBJECT('value', 'option1', 'label', 'گزینه ۱'), JSON_OBJECT('value', 'option2', 'label', 'گزینه ۲')), 'multiple', false),
 JSON_OBJECT('required', false), 5),

('radio', 'دکمه رادیویی', 'Radio Buttons', 'گروه دکمه‌های رادیویی', 'Radio button group', 'radio_button_checked', 'selection',
 JSON_OBJECT('options', JSON_ARRAY(JSON_OBJECT('value', 'yes', 'label', 'بله'), JSON_OBJECT('value', 'no', 'label', 'خیر'))),
 JSON_OBJECT('required', false), 6),

('checkbox', 'چک‌باکس', 'Checkboxes', 'گروه چک‌باکس‌ها', 'Checkbox group', 'check_box', 'selection',
 JSON_OBJECT('options', JSON_ARRAY(JSON_OBJECT('value', 'option1', 'label', 'گزینه ۱'), JSON_OBJECT('value', 'option2', 'label', 'گزینه ۲')), 'multiple', true),
 JSON_OBJECT('required', false), 7),

-- ویجت‌های تاریخ و زمان - Date/Time Widgets
('date', 'انتخاب تاریخ', 'Date Picker', 'فیلد انتخاب تاریخ', 'Date selection field', 'calendar_today', 'datetime',
 JSON_OBJECT('format', 'yyyy/mm/dd', 'calendar_type', 'persian'),
 JSON_OBJECT('required', false, 'type', 'date'), 8),

('time', 'انتخاب زمان', 'Time Picker', 'فیلد انتخاب زمان', 'Time selection field', 'access_time', 'datetime',
 JSON_OBJECT('format', '24', 'step', 1),
 JSON_OBJECT('required', false, 'type', 'time'), 9),

-- ویجت‌های پیشرفته - Advanced Widgets
('file', 'آپلود فایل', 'File Upload', 'بارگذاری فایل', 'File upload field', 'cloud_upload', 'advanced',
 JSON_OBJECT('accept', '.pdf,.doc,.docx,.jpg,.png', 'max_size', 5242880, 'multiple', false),
 JSON_OBJECT('required', false, 'file_types', JSON_ARRAY('pdf', 'doc', 'docx', 'jpg', 'png')), 10);

-- =====================================================
-- درج کاربر پیش‌فرض - Default User
-- =====================================================
INSERT IGNORE INTO `users` (`username`, `email`, `first_name`, `last_name`, `role`, `status`, `email_verified_at`) VALUES
('admin', 'admin@datasave.ir', 'مدیر', 'سیستم', 'admin', 'active', NOW());

-- =====================================================
-- نمایش خلاصه نصب
-- =====================================================
SELECT 
  '✅ تمام جداول ایجاد شد!' as message,
  (SELECT COUNT(*) FROM form_widgets) as total_widgets,
  (SELECT COUNT(*) FROM users) as total_users;
