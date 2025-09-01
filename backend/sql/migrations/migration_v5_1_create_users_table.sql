-- ===================================================
-- Migration v5.1: ایجاد جدول users
-- نسخه: 5.1.0
-- تاریخ: 2025-09-01
-- توسط: DataSave Development Team
-- ===================================================

-- بررسی وجود جدول قبل از ایجاد
SELECT 'بررسی وجود جدول users...' as status;

-- ایجاد جدول کاربران سیستم
CREATE TABLE IF NOT EXISTS `users` (
  `id` INT UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT 'شناسه یکتا کاربر',
  `email` VARCHAR(191) UNIQUE NOT NULL COMMENT 'ایمیل کاربر (یکتا)',
  `password_hash` VARCHAR(255) NOT NULL COMMENT 'رمز عبور هش شده با bcrypt',
  `persian_name` VARCHAR(100) NOT NULL COMMENT 'نام فارسی کاربر',
  `english_name` VARCHAR(100) NULL COMMENT 'نام انگلیسی کاربر (اختیاری)',
  
  `role` ENUM('admin', 'user', 'moderator') DEFAULT 'user' COMMENT 'نقش کاربر در سیستم',
  `status` ENUM('active', 'inactive', 'suspended', 'pending') DEFAULT 'pending' COMMENT 'وضعیت کاربر',
  
  -- اطلاعات تکمیلی
  `phone` VARCHAR(15) NULL COMMENT 'شماره تلفن',
  `avatar_url` VARCHAR(255) NULL COMMENT 'آدرس تصویر پروفایل',
  `preferences` JSON NULL COMMENT 'تنظیمات شخصی کاربر',
  
  -- مدیریت حذف نرم
  `deleted_at` TIMESTAMP NULL COMMENT 'زمان حذف نرم (soft delete)',
  `deleted_by` INT UNSIGNED NULL COMMENT 'شناسه کاربر حذف کننده',
  
  -- مدیریت زمان
  `email_verified_at` TIMESTAMP NULL COMMENT 'زمان تأیید ایمیل',
  `last_login_at` TIMESTAMP NULL COMMENT 'آخرین ورود',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'زمان ایجاد',
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'زمان بروزرسانی',
  
  -- تعریف اندیکس‌ها برای عملکرد بهتر
  INDEX `idx_users_email` (`email`),
  INDEX `idx_users_status` (`status`),
  INDEX `idx_users_role` (`role`),
  INDEX `idx_users_created_at` (`created_at`),
  INDEX `idx_users_last_login` (`last_login_at`),
  INDEX `idx_users_soft_delete` (`deleted_at`),
  INDEX `idx_users_status_role` (`status`, `role`),
  
  -- قید خارجی برای حذف کننده
  FOREIGN KEY `fk_users_deleted_by` (`deleted_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  
  -- محدودیت‌های بررسی
  CONSTRAINT `chk_users_email_format` CHECK (`email` REGEXP '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$'),
  CONSTRAINT `chk_users_persian_name` CHECK (CHAR_LENGTH(`persian_name`) >= 2),
  CONSTRAINT `chk_users_phone` CHECK (`phone` IS NULL OR `phone` REGEXP '^[0-9+()-\s]+$')
  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci COMMENT='جدول کاربران سیستم - Form Builder Users';

-- اطلاعات جدول ایجاد شده
SELECT 'جدول users با موفقیت ایجاد شد!' as result;
SELECT CONCAT('تعداد فیلدها: ', COUNT(*)) as field_count 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'users';

-- لاگ عملیات
INSERT INTO `system_logs` (`log_level`, `log_category`, `log_message`, `log_context`) VALUES
('INFO', 'MIGRATION', 'Migration v5.1: جدول users ایجاد شد', JSON_OBJECT('table', 'users', 'version', '5.1.0', 'date', NOW()));
