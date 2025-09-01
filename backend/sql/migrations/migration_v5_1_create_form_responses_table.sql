-- ===================================================
-- Migration v5.1: ایجاد جدول form_responses
-- نسخه: 5.1.0
-- تاریخ: 2025-09-01  
-- توسط: DataSave Development Team
-- ===================================================

-- بررسی وجود جدول قبل از ایجاد
SELECT 'بررسی وجود جدول form_responses...' as status;

-- ایجاد جدول پاسخ‌های فرم‌ها
CREATE TABLE IF NOT EXISTS `form_responses` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT 'شناسه یکتا پاسخ',
  `form_id` INT UNSIGNED NOT NULL COMMENT 'شناسه فرم مرتبط',
  `respondent_user_id` INT UNSIGNED NULL COMMENT 'شناسه کاربر پاسخ‌دهنده (اگر وارد شده)',
  
  -- داده‌های پاسخ
  `response_data` JSON NOT NULL COMMENT 'داده‌های پاسخ به صورت JSON',
  `response_hash` VARCHAR(64) NULL COMMENT 'هش داده‌ها برای تشخیص تکرار',
  `form_version` VARCHAR(10) NULL COMMENT 'نسخه فرم هنگام ثبت پاسخ',
  
  -- اطلاعات جلسه و کاربر
  `session_id` VARCHAR(128) NULL COMMENT 'شناسه جلسه پاسخ‌دهنده',
  `respondent_ip` VARCHAR(45) NOT NULL COMMENT 'آدرس IP پاسخ‌دهنده',
  `user_agent` TEXT NULL COMMENT 'اطلاعات مرورگر پاسخ‌دهنده',
  `device_info` JSON NULL COMMENT 'اطلاعات دستگاه (mobile, desktop, tablet)',
  
  -- اطلاعات زمانی و مکانی
  `started_at` TIMESTAMP NULL COMMENT 'زمان شروع پر کردن فرم',
  `submitted_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'زمان ثبت نهایی پاسخ',
  `completion_time` INT UNSIGNED NULL COMMENT 'زمان تکمیل به ثانیه',
  `timezone` VARCHAR(50) NULL COMMENT 'منطقه زمانی پاسخ‌دهنده',
  
  -- وضعیت و تأیید
  `status` ENUM('submitted', 'reviewed', 'approved', 'rejected', 'flagged') DEFAULT 'submitted' COMMENT 'وضعیت پاسخ',
  `is_verified` BOOLEAN DEFAULT FALSE COMMENT 'آیا پاسخ تأیید شده است؟',
  `reviewed_by` INT UNSIGNED NULL COMMENT 'شناسه کاربر بررسی کننده',
  `reviewed_at` TIMESTAMP NULL COMMENT 'زمان بررسی',
  `review_notes` TEXT NULL COMMENT 'یادداشت‌های بررسی',
  
  -- امتیازدهی و تحلیل
  `quality_score` DECIMAL(3,2) NULL COMMENT 'امتیاز کیفیت پاسخ (0-10)',
  `completeness_percent` DECIMAL(5,2) DEFAULT 100.00 COMMENT 'درصد تکمیل فرم',
  `flags` JSON NULL COMMENT 'پرچم‌های خاص (spam, duplicate, etc)',
  
  -- مدیریت حذف و آرشیو
  `archived_at` TIMESTAMP NULL COMMENT 'زمان آرشیو',
  `deleted_at` TIMESTAMP NULL COMMENT 'زمان حذف نرم',
  `deleted_by` INT UNSIGNED NULL COMMENT 'شناسه کاربر حذف کننده',
  
  -- مدیریت زمان
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'زمان ایجاد رکورد',
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'زمان بروزرسانی',
  
  -- تعریف اندیکس‌ها برای عملکرد بهتر
  INDEX `idx_responses_form_id` (`form_id`),
  INDEX `idx_responses_user_id` (`respondent_user_id`),
  INDEX `idx_responses_submitted_at` (`submitted_at`),
  INDEX `idx_responses_status` (`status`),
  INDEX `idx_responses_ip` (`respondent_ip`),
  INDEX `idx_responses_verified` (`is_verified`),
  INDEX `idx_responses_quality` (`quality_score`),
  INDEX `idx_responses_soft_delete` (`deleted_at`),
  INDEX `idx_responses_form_status` (`form_id`, `status`),
  INDEX `idx_responses_form_date` (`form_id`, `submitted_at`),
  INDEX `idx_responses_user_form` (`respondent_user_id`, `form_id`),
  INDEX `idx_responses_hash` (`response_hash`),
  
  -- قیدهای خارجی
  FOREIGN KEY `fk_responses_form_id` (`form_id`) REFERENCES `forms` (`id`) ON DELETE CASCADE,
  FOREIGN KEY `fk_responses_user_id` (`respondent_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  FOREIGN KEY `fk_responses_reviewed_by` (`reviewed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  FOREIGN KEY `fk_responses_deleted_by` (`deleted_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  
  -- محدودیت‌های بررسی
  CONSTRAINT `chk_responses_completion_time` CHECK (`completion_time` IS NULL OR `completion_time` > 0),
  CONSTRAINT `chk_responses_quality_score` CHECK (`quality_score` IS NULL OR (`quality_score` >= 0 AND `quality_score` <= 10)),
  CONSTRAINT `chk_responses_completeness` CHECK (`completeness_percent` >= 0 AND `completeness_percent` <= 100),
  CONSTRAINT `chk_responses_ip_format` CHECK (`respondent_ip` REGEXP '^([0-9]{1,3}\.){3}[0-9]{1,3}$|^([0-9a-fA-F]{0,4}:){1,7}[0-9a-fA-F]{0,4}$'),
  CONSTRAINT `chk_responses_hash_format` CHECK (`response_hash` IS NULL OR `response_hash` REGEXP '^[a-f0-9]{64}$')
  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci COMMENT='پاسخ‌های فرم‌ها - Form Responses Collection';

-- اطلاعات جدول ایجاد شده
SELECT 'جدول form_responses با موفقیت ایجاد شد!' as result;
SELECT CONCAT('تعداد فیلدها: ', COUNT(*)) as field_count 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'form_responses';

-- لاگ عملیات
INSERT INTO `system_logs` (`log_level`, `log_category`, `log_message`, `log_context`) VALUES
('INFO', 'MIGRATION', 'Migration v5.1: جدول form_responses ایجاد شد', JSON_OBJECT('table', 'form_responses', 'version', '5.1.0', 'date', NOW()));
