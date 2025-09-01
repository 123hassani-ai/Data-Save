-- ایجاد دیتابیس
CREATE DATABASE IF NOT EXISTS `datasave_db` 
DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_persian_ci;

USE `datasave_db`;

-- جدول تنظیمات سیستم
CREATE TABLE IF NOT EXISTS `system_settings` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `setting_key` VARCHAR(100) UNIQUE NOT NULL COMMENT 'کلید تنظیمات',
  `setting_value` TEXT COMMENT 'مقدار تنظیمات',
  `setting_type` ENUM('string','json','boolean','number','encrypted') DEFAULT 'string',
  `description` VARCHAR(255) COMMENT 'توضیحات',
  `is_system` BOOLEAN DEFAULT FALSE COMMENT 'تنظیمات سیستمی',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  INDEX idx_setting_key (`setting_key`),
  INDEX idx_is_system (`is_system`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci;

-- جدول لاگ‌ها
CREATE TABLE IF NOT EXISTS `system_logs` (
  `log_id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `log_level` ENUM('DEBUG','INFO','WARNING','ERROR','CRITICAL') NOT NULL,
  `log_category` VARCHAR(50) NOT NULL,
  `log_message` TEXT NOT NULL,
  `log_context` JSON,
  `ip_address` VARCHAR(45),
  `user_agent` TEXT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  INDEX idx_log_level (`log_level`),
  INDEX idx_log_category (`log_category`),
  INDEX idx_created_at (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci;

-- درج تنظیمات پیش‌فرض
INSERT IGNORE INTO `system_settings` (`setting_key`, `setting_value`, `setting_type`, `description`, `is_system`) VALUES
('openai_api_key', '', 'encrypted', 'کلید API سرویس OpenAI', true),
('openai_model', 'gpt-4', 'string', 'مدل پیش‌فرض OpenAI', true),
('openai_max_tokens', '2048', 'number', 'حداکثر توکن پاسخ', true),
('app_language', 'fa', 'string', 'زبان پیش‌فرض', true),
('enable_logging', 'true', 'boolean', 'فعال‌سازی لاگ', true),
('max_log_entries', '1000', 'number', 'حداکثر تعداد لاگ', false),
('app_theme', 'light', 'string', 'تم پیش‌فرض اپلیکیشن', false),
('auto_save', 'true', 'boolean', 'ذخیره خودکار فرم‌ها', false),
('backup_enabled', 'false', 'boolean', 'پشتیبان‌گیری خودکار', false);
