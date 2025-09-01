-- ===================================================
-- Migration v5.1: ایجاد جدول form_widgets  
-- نسخه: 5.1.0
-- تاریخ: 2025-09-01
-- توسط: DataSave Development Team
-- ===================================================

-- بررسی وجود جدول قبل از ایجاد
SELECT 'بررسی وجود جدول form_widgets...' as status;

-- ایجاد جدول کتابخانه ویجت‌ها
CREATE TABLE IF NOT EXISTS `form_widgets` (
  `id` INT UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT 'شناسه یکتا ویجت',
  
  -- نوع و شناسه ویجت
  `widget_type` VARCHAR(50) NOT NULL COMMENT 'نوع ویجت (text, select, checkbox, radio, etc)',
  `widget_code` VARCHAR(100) UNIQUE NOT NULL COMMENT 'کد یکتا ویجت برای استفاده در API',
  `widget_category` VARCHAR(50) DEFAULT 'basic' COMMENT 'دسته‌بندی ویجت (basic, advanced, custom)',
  
  -- برچسب‌ها و توضیحات
  `persian_label` VARCHAR(255) NOT NULL COMMENT 'برچسب فارسی ویجت',
  `english_label` VARCHAR(255) NULL COMMENT 'برچسب انگلیسی ویجت',
  `persian_description` TEXT NULL COMMENT 'توضیحات فارسی ویجت',
  `english_description` TEXT NULL COMMENT 'توضیحات انگلیسی ویجت',
  
  -- پیکربندی و تنظیمات
  `widget_config` JSON NOT NULL COMMENT 'تنظیمات پیش‌فرض ویجت',
  `validation_rules` JSON NULL COMMENT 'قوانین اعتبارسنجی ویجت',
  `default_props` JSON NULL COMMENT 'خصوصیات پیش‌فرض ویجت',
  
  -- ظاهر و نمایش
  `icon_name` VARCHAR(100) NULL COMMENT 'نام آیکون ویجت (Material Icons)',
  `icon_color` VARCHAR(7) DEFAULT '#2196F3' COMMENT 'رنگ آیکون (hex)',
  `preview_image` VARCHAR(255) NULL COMMENT 'تصویر پیش‌نمایش ویجت',
  
  -- اولویت و چینش
  `display_order` INT UNSIGNED DEFAULT 999 COMMENT 'ترتیب نمایش در لیست',
  `is_pro` BOOLEAN DEFAULT FALSE COMMENT 'آیا ویجت پرمیوم است؟',
  `is_active` BOOLEAN DEFAULT TRUE COMMENT 'آیا ویجت فعال است؟',
  `min_version` VARCHAR(10) DEFAULT '1.0' COMMENT 'حداقل نسخه سیستم مورد نیاز',
  
  -- آمار استفاده
  `usage_count` INT UNSIGNED DEFAULT 0 COMMENT 'تعداد استفاده در فرم‌ها',
  `last_used_at` TIMESTAMP NULL COMMENT 'آخرین زمان استفاده',
  
  -- مدیریت زمان
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'زمان ایجاد',
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'زمان بروزرسانی',
  
  -- تعریف اندیکس‌ها برای عملکرد بهتر
  INDEX `idx_widgets_type` (`widget_type`),
  INDEX `idx_widgets_category` (`widget_category`),
  INDEX `idx_widgets_active` (`is_active`),
  INDEX `idx_widgets_pro` (`is_pro`),
  INDEX `idx_widgets_order` (`display_order`),
  INDEX `idx_widgets_usage` (`usage_count`),
  INDEX `idx_widgets_type_active` (`widget_type`, `is_active`),
  INDEX `idx_widgets_category_order` (`widget_category`, `display_order`),
  
  -- محدودیت‌های بررسی  
  CONSTRAINT `chk_widgets_type_valid` CHECK (`widget_type` IN (
    'text', 'textarea', 'email', 'password', 'number', 'tel', 'url',
    'select', 'multiselect', 'radio', 'checkbox', 'toggle',
    'date', 'datetime', 'time', 'range', 'color',
    'file', 'image', 'signature', 'rating', 'matrix'
  )),
  CONSTRAINT `chk_widgets_persian_label` CHECK (CHAR_LENGTH(`persian_label`) >= 2),
  CONSTRAINT `chk_widgets_code_format` CHECK (`widget_code` REGEXP '^[a-z][a-z0-9_]*$'),
  CONSTRAINT `chk_widgets_icon_color` CHECK (`icon_color` REGEXP '^#[0-9A-Fa-f]{6}$'),
  CONSTRAINT `chk_widgets_version_format` CHECK (`min_version` REGEXP '^[0-9]+\.[0-9]+(\.[0-9]+)?$')
  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci COMMENT='کتابخانه ویجت‌های فرم ساز';

-- اطلاعات جدول ایجاد شده
SELECT 'جدول form_widgets با موفقیت ایجاد شد!' as result;
SELECT CONCAT('تعداد فیلدها: ', COUNT(*)) as field_count 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'form_widgets';

-- لاگ عملیات
INSERT INTO `system_logs` (`log_level`, `log_category`, `log_message`, `log_context`) VALUES
('INFO', 'MIGRATION', 'Migration v5.1: جدول form_widgets ایجاد شد', JSON_OBJECT('table', 'form_widgets', 'version', '5.1.0', 'date', NOW()));
