-- ===================================================
-- Migration v5.1: ایجاد اندیکس‌ها و روابط کامل
-- نسخه: 5.1.0
-- تاریخ: 2025-09-01
-- توسط: DataSave Development Team  
-- ===================================================

-- بررسی وجود جداول مورد نیاز
SELECT 'بررسی وجود جداول مورد نیاز...' as status;

-- === اندیکس‌های کامپوزیت برای کوئری‌های پیچیده ===
-- (در صورت وجود، نادیده گرفته می‌شود)

-- اندیکس‌های ترکیبی برای جدول forms  
CREATE INDEX IF NOT EXISTS `idx_forms_user_status_published` ON `forms` (`user_id`, `status`, `published_at`);
CREATE INDEX IF NOT EXISTS `idx_forms_public_expires` ON `forms` (`is_public`, `expires_at`);
CREATE INDEX IF NOT EXISTS `idx_forms_status_responses` ON `forms` (`status`, `total_responses`);
CREATE INDEX IF NOT EXISTS `idx_forms_user_created` ON `forms` (`user_id`, `created_at`);

-- اندیکس‌های ترکیبی برای جدول form_widgets
CREATE INDEX IF NOT EXISTS `idx_widgets_active_category_order` ON `form_widgets` (`is_active`, `widget_category`, `display_order`);
CREATE INDEX IF NOT EXISTS `idx_widgets_type_active_usage` ON `form_widgets` (`widget_type`, `is_active`, `usage_count`);
CREATE INDEX IF NOT EXISTS `idx_widgets_pro_active` ON `form_widgets` (`is_pro`, `is_active`);

-- اندیکس‌های ترکیبی برای جدول form_responses
CREATE INDEX IF NOT EXISTS `idx_responses_form_submitted_status` ON `form_responses` (`form_id`, `submitted_at`, `status`);
CREATE INDEX IF NOT EXISTS `idx_responses_user_submitted` ON `form_responses` (`respondent_user_id`, `submitted_at`);
CREATE INDEX IF NOT EXISTS `idx_responses_ip_submitted` ON `form_responses` (`respondent_ip`, `submitted_at`);
CREATE INDEX IF NOT EXISTS `idx_responses_verified_quality` ON `form_responses` (`is_verified`, `quality_score`);
CREATE INDEX IF NOT EXISTS `idx_responses_status_reviewed` ON `form_responses` (`status`, `reviewed_at`);

-- === تریگرهای خودکار برای آمار ===

-- تریگر بروزرسانی آمار فرم هنگام ایجاد پاسخ جدید
DROP TRIGGER IF EXISTS `trg_response_insert_stats`;
DELIMITER $$
CREATE TRIGGER `trg_response_insert_stats` 
AFTER INSERT ON `form_responses`
FOR EACH ROW
BEGIN
    -- بروزرسانی تعداد پاسخ‌ها در جدول forms
    UPDATE `forms` 
    SET `total_responses` = `total_responses` + 1,
        `last_response_at` = NEW.`submitted_at`
    WHERE `id` = NEW.`form_id`;
    
    -- ثبت لاگ
    INSERT INTO `system_logs` (`log_level`, `log_category`, `log_message`, `log_context`)
    VALUES ('DEBUG', 'FORM_BUILDER', 'پاسخ جدید برای فرم ثبت شد', 
            JSON_OBJECT('form_id', NEW.`form_id`, 'response_id', NEW.`id`));
END$$
DELIMITER ;

-- تریگر بروزرسانی آمار فرم هنگام حذف پاسخ
DROP TRIGGER IF EXISTS `trg_response_delete_stats`;
DELIMITER $$
CREATE TRIGGER `trg_response_delete_stats`
AFTER UPDATE ON `form_responses`
FOR EACH ROW
BEGIN
    -- اگر پاسخ حذف شود (soft delete)
    IF NEW.`deleted_at` IS NOT NULL AND OLD.`deleted_at` IS NULL THEN
        UPDATE `forms` 
        SET `total_responses` = GREATEST(`total_responses` - 1, 0)
        WHERE `id` = NEW.`form_id`;
        
        INSERT INTO `system_logs` (`log_level`, `log_category`, `log_message`, `log_context`)
        VALUES ('DEBUG', 'FORM_BUILDER', 'پاسخ فرم حذف شد', 
                JSON_OBJECT('form_id', NEW.`form_id`, 'response_id', NEW.`id`));
    END IF;
END$$
DELIMITER ;

-- تریگر بروزرسانی آمار استفاده ویجت‌ها (نسخه ساده)
DROP TRIGGER IF EXISTS `trg_form_create_widget_stats`;
DELIMITER $$  
CREATE TRIGGER `trg_form_create_widget_stats`
AFTER INSERT ON `forms`
FOR EACH ROW
BEGIN
    -- ثبت لاگ ایجاد فرم جدید
    INSERT INTO `system_logs` (`log_level`, `log_category`, `log_message`, `log_context`)
    VALUES ('INFO', 'FORM_BUILDER', 'فرم جدید ایجاد شد', 
            JSON_OBJECT('form_id', NEW.`id`, 'user_id', NEW.`user_id`, 'title', NEW.`persian_title`));
END$$
DELIMITER ;

-- === ایجاد Views برای دسترسی آسان ===

-- View برای آمار فرم‌های کاربران
CREATE OR REPLACE VIEW `v_user_forms_stats` AS
SELECT 
    u.`id` as user_id,
    u.`persian_name`,
    u.`email`,
    COUNT(f.`id`) as total_forms,
    COUNT(CASE WHEN f.`status` = 'published' THEN 1 END) as published_forms,
    COUNT(CASE WHEN f.`status` = 'draft' THEN 1 END) as draft_forms,
    COALESCE(SUM(f.`total_responses`), 0) as total_responses,
    MAX(f.`created_at`) as last_form_created
FROM `users` u
LEFT JOIN `forms` f ON u.`id` = f.`user_id` AND f.`deleted_at` IS NULL
WHERE u.`deleted_at` IS NULL
GROUP BY u.`id`, u.`persian_name`, u.`email`;

-- View برای آمار ویجت‌های محبوب
CREATE OR REPLACE VIEW `v_popular_widgets` AS
SELECT 
    fw.`id`,
    fw.`widget_type`,
    fw.`persian_label`,
    fw.`widget_category`,
    fw.`usage_count`,
    fw.`last_used_at`,
    ROUND(fw.`usage_count` * 100.0 / NULLIF((SELECT SUM(`usage_count`) FROM `form_widgets`), 0), 2) as usage_percentage
FROM `form_widgets` fw
WHERE fw.`is_active` = TRUE
ORDER BY fw.`usage_count` DESC;

-- View برای آمار پاسخ‌های اخیر
CREATE OR REPLACE VIEW `v_recent_responses` AS
SELECT 
    fr.`id`,
    f.`persian_title` as form_title,
    u.`persian_name` as form_creator,
    fr.`submitted_at`,
    fr.`status`,
    fr.`respondent_ip`,
    fr.`completion_time`,
    fr.`quality_score`
FROM `form_responses` fr
JOIN `forms` f ON fr.`form_id` = f.`id`
JOIN `users` u ON f.`user_id` = u.`id`
WHERE fr.`deleted_at` IS NULL
  AND fr.`submitted_at` >= DATE_SUB(NOW(), INTERVAL 30 DAY)
ORDER BY fr.`submitted_at` DESC;

-- === بروزرسانی تنظیمات سیستم ===

-- اضافه کردن تنظیمات جدید برای Form Builder
INSERT INTO `system_settings` (`setting_key`, `setting_value`, `setting_type`, `description`, `is_system`) VALUES
('form_builder_enabled', 'true', 'boolean', 'فعال‌سازی سیستم فرم ساز', true),
('max_forms_per_user', '10', 'number', 'حداکثر تعداد فرم برای هر کاربر', true),
('max_responses_per_form', '1000', 'number', 'حداکثر پاسخ برای هر فرم', true),
('default_form_template', '{}', 'json', 'قالب پیش‌فرض فرم‌ها', false),
('widget_library_version', '1.0', 'string', 'نسخه کتابخانه ویجت‌ها', true),
('response_retention_days', '365', 'number', 'مدت نگهداری پاسخ‌ها (روز)', false),
('enable_form_analytics', 'true', 'boolean', 'فعال‌سازی آنالیتیکس فرم', false),
('require_user_verification', 'false', 'boolean', 'الزام تأیید کاربران جدید', false)
ON DUPLICATE KEY UPDATE `updated_at` = NOW();

-- === اطلاعات تکمیل ===
SELECT 'اندیکس‌ها، تریگرها و Views با موفقیت ایجاد شدند!' as result;

-- شمارش کل اندیکس‌ها
SELECT 
    TABLE_NAME,
    COUNT(*) as index_count
FROM INFORMATION_SCHEMA.STATISTICS 
WHERE TABLE_SCHEMA = DATABASE() 
  AND TABLE_NAME IN ('users', 'forms', 'form_widgets', 'form_responses')
GROUP BY TABLE_NAME;

-- لاگ عملیات
INSERT INTO `system_logs` (`log_level`, `log_category`, `log_message`, `log_context`) VALUES
('INFO', 'MIGRATION', 'Migration v5.1: اندیکس‌ها و روابط ایجاد شد', JSON_OBJECT('version', '5.1.0', 'date', NOW()));
