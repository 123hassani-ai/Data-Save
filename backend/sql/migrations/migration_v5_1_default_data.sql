-- ===================================================
-- Migration v5.1: داده‌های پیش‌فرض (Default Data)
-- نسخه: 5.1.0
-- تاریخ: 2025-09-01
-- توسط: DataSave Development Team
-- ===================================================

-- بررسی آمادگی جداول
SELECT 'بررسی آمادگی جداول برای درج داده‌های پیش‌فرض...' as status;

-- === ایجاد کاربر ادمین پیش‌فرض ===
INSERT IGNORE INTO `users` (
    `email`, `password_hash`, `persian_name`, `english_name`, 
    `role`, `status`, `email_verified_at`, `preferences`
) VALUES (
    'admin@datasave.ir', 
    '$2y$12$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', -- password: password
    'مدیر سیستم',
    'System Administrator',
    'admin',
    'active',
    NOW(),
    JSON_OBJECT(
        'language', 'fa',
        'theme', 'light',
        'timezone', 'Asia/Tehran',
        'notifications', JSON_OBJECT(
            'email', true,
            'browser', true,
            'form_responses', true
        )
    )
);

-- === ایجاد کاربر تست ===
INSERT IGNORE INTO `users` (
    `email`, `password_hash`, `persian_name`, `english_name`,
    `role`, `status`, `email_verified_at`, `preferences`
) VALUES (
    'test@datasave.ir',
    '$2y$12$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', -- password: password  
    'کاربر تست',
    'Test User',
    'user',
    'active',
    NOW(),
    JSON_OBJECT(
        'language', 'fa',
        'theme', 'light',
        'timezone', 'Asia/Tehran'
    )
);

-- === ایجاد ویجت‌های پایه فرم ===

-- ویجت متن ساده
INSERT IGNORE INTO `form_widgets` (
    `widget_type`, `widget_code`, `widget_category`,
    `persian_label`, `english_label`, 
    `persian_description`, `english_description`,
    `widget_config`, `validation_rules`, `default_props`,
    `icon_name`, `icon_color`, `display_order`, `is_active`
) VALUES
('text', 'text_input', 'basic',
 'ورودی متن', 'Text Input',
 'فیلد متنی برای ورود متن کوتاه', 'Text field for short text input',
 JSON_OBJECT(
     'maxLength', 255,
     'placeholder', 'متن خود را وارد کنید...',
     'multiline', false,
     'rtl', true
 ),
 JSON_OBJECT(
     'required', false,
     'minLength', 0,
     'maxLength', 255,
     'pattern', null
 ),
 JSON_OBJECT(
     'width', '100%',
     'height', 'auto',
     'margin', JSON_OBJECT('top', 8, 'bottom', 8)
 ),
 'text_fields', '#2196F3', 1, true),

-- ویجت متن چندخطی  
('textarea', 'textarea_input', 'basic',
 'متن چندخطی', 'Textarea',
 'فیلد متنی برای ورود متن طولانی', 'Text area for long text input',
 JSON_OBJECT(
     'maxLength', 1000,
     'placeholder', 'توضیحات خود را بنویسید...',
     'rows', 4,
     'rtl', true
 ),
 JSON_OBJECT(
     'required', false,
     'minLength', 0,
     'maxLength', 1000
 ),
 JSON_OBJECT(
     'width', '100%',
     'minHeight', '100px'
 ),
 'subject', '#4CAF50', 2, true),

-- ویجت ایمیل
('email', 'email_input', 'basic',
 'آدرس ایمیل', 'Email Address',
 'فیلد ورود آدرس ایمیل با اعتبارسنجی', 'Email input with validation',
 JSON_OBJECT(
     'placeholder', 'example@domain.com',
     'autocomplete', 'email',
     'rtl', false
 ),
 JSON_OBJECT(
     'required', false,
     'pattern', '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$'
 ),
 JSON_OBJECT(
     'width', '100%',
     'inputType', 'email'
 ),
 'email', '#FF9800', 3, true),

-- ویجت شماره
('number', 'number_input', 'basic',
 'ورودی عدد', 'Number Input',
 'فیلد ورود اعداد', 'Number input field',
 JSON_OBJECT(
     'placeholder', '123',
     'min', null,
     'max', null,
     'step', 1
 ),
 JSON_OBJECT(
     'required', false,
     'min', null,
     'max', null
 ),
 JSON_OBJECT(
     'width', '100%',
     'inputType', 'number'
 ),
 'plus_one', '#9C27B0', 4, true),

-- ویجت انتخابی (Select)
('select', 'select_input', 'basic',
 'فهرست انتخابی', 'Select Dropdown',
 'فهرست کشویی برای انتخاب گزینه', 'Dropdown list for option selection',
 JSON_OBJECT(
     'placeholder', 'گزینه خود را انتخاب کنید',
     'multiple', false,
     'searchable', true,
     'options', JSON_ARRAY(
         JSON_OBJECT('value', 'option1', 'label', 'گزینه اول'),
         JSON_OBJECT('value', 'option2', 'label', 'گزینه دوم')
     )
 ),
 JSON_OBJECT(
     'required', false,
     'minSelections', null,
     'maxSelections', null
 ),
 JSON_OBJECT(
     'width', '100%'
 ),
 'arrow_drop_down', '#607D8B', 5, true),

-- ویجت رادیو باتن
('radio', 'radio_input', 'basic',
 'انتخاب رادیویی', 'Radio Buttons',
 'گروهی از دکمه‌های رادیویی', 'Group of radio buttons',
 JSON_OBJECT(
     'layout', 'vertical',
     'options', JSON_ARRAY(
         JSON_OBJECT('value', 'yes', 'label', 'بله'),
         JSON_OBJECT('value', 'no', 'label', 'خیر')
     )
 ),
 JSON_OBJECT(
     'required', false
 ),
 JSON_OBJECT(
     'width', '100%'
 ),
 'radio_button_checked', '#F44336', 6, true),

-- ویجت چک باکس  
('checkbox', 'checkbox_input', 'basic',
 'کادر انتخاب', 'Checkboxes',
 'گروهی از کادرهای انتخاب', 'Group of checkboxes',
 JSON_OBJECT(
     'layout', 'vertical',
     'options', JSON_ARRAY(
         JSON_OBJECT('value', 'opt1', 'label', 'گزینه اول'),
         JSON_OBJECT('value', 'opt2', 'label', 'گزینه دوم')
     )
 ),
 JSON_OBJECT(
     'required', false,
     'minSelections', 0,
     'maxSelections', null
 ),
 JSON_OBJECT(
     'width', '100%'
 ),
 'check_box', '#4CAF50', 7, true),

-- ویجت تاریخ
('date', 'date_input', 'advanced',
 'انتخاب تاریخ', 'Date Picker',
 'انتخابگر تاریخ شمسی و میلادی', 'Persian and Gregorian date picker',
 JSON_OBJECT(
     'calendar', 'persian',
     'format', 'YYYY/MM/DD',
     'placeholder', '1403/06/11',
     'minDate', null,
     'maxDate', null
 ),
 JSON_OBJECT(
     'required', false
 ),
 JSON_OBJECT(
     'width', '100%'
 ),
 'date_range', '#00BCD4', 8, true),

-- ویجت فایل
('file', 'file_input', 'advanced',
 'بارگذاری فایل', 'File Upload',
 'بارگذاری فایل‌های مختلف', 'Upload various file types',
 JSON_OBJECT(
     'maxSize', '10MB',
     'allowedTypes', JSON_ARRAY('image/*', '.pdf', '.doc', '.docx'),
     'multiple', false,
     'placeholder', 'فایل خود را انتخاب کنید'
 ),
 JSON_OBJECT(
     'required', false,
     'maxFiles', 1
 ),
 JSON_OBJECT(
     'width', '100%'
 ),
 'cloud_upload', '#795548', 9, true),

-- ویجت امتیازدهی
('rating', 'rating_input', 'advanced',
 'امتیازدهی', 'Rating',
 'سیستم امتیازدهی با ستاره', 'Star rating system',
 JSON_OBJECT(
     'maxRating', 5,
     'allowHalf', true,
     'showLabels', true,
     'labels', JSON_ARRAY('ضعیف', 'متوسط', 'خوب', 'عالی', 'فوق‌العاده')
 ),
 JSON_OBJECT(
     'required', false,
     'minRating', 0,
     'maxRating', 5
 ),
 JSON_OBJECT(
     'width', '100%'
 ),
 'star_rate', '#FFC107', 10, true);

-- === ایجاد فرم نمونه ===

-- دریافت ID کاربر ادمین
SET @admin_id = (SELECT `id` FROM `users` WHERE `email` = 'admin@datasave.ir' LIMIT 1);

-- ایجاد فرم نمونه
INSERT IGNORE INTO `forms` (
    `user_id`, `persian_title`, `english_title`,
    `persian_description`, `english_description`,
    `form_schema`, `form_config`, `form_settings`,
    `status`, `is_public`, `published_at`
) VALUES (
    @admin_id,
    'فرم نمونه تماس با ما',
    'Sample Contact Form',
    'این یک فرم نمونه برای دریافت پیام‌های کاربران است',
    'This is a sample form for collecting user messages',
    JSON_OBJECT(
        'version', '1.0',
        'widgets', JSON_ARRAY(
            JSON_OBJECT(
                'id', 'name_field',
                'type', 'text',
                'label', 'نام و نام خانوادگی',
                'placeholder', 'نام خود را وارد کنید',
                'required', true,
                'order', 1
            ),
            JSON_OBJECT(
                'id', 'email_field', 
                'type', 'email',
                'label', 'آدرس ایمیل',
                'placeholder', 'email@example.com',
                'required', true,
                'order', 2
            ),
            JSON_OBJECT(
                'id', 'subject_field',
                'type', 'select',
                'label', 'موضوع',
                'options', JSON_ARRAY(
                    JSON_OBJECT('value', 'support', 'label', 'پشتیبانی'),
                    JSON_OBJECT('value', 'sales', 'label', 'فروش'),
                    JSON_OBJECT('value', 'other', 'label', 'سایر')
                ),
                'required', true,
                'order', 3
            ),
            JSON_OBJECT(
                'id', 'message_field',
                'type', 'textarea', 
                'label', 'پیام شما',
                'placeholder', 'پیام خود را بنویسید...',
                'required', true,
                'order', 4
            )
        )
    ),
    JSON_OBJECT(
        'theme', 'default',
        'rtl', true,
        'showProgress', true,
        'allowDraft', false
    ),
    JSON_OBJECT(
        'primaryColor', '#2196F3',
        'backgroundColor', '#ffffff',
        'textColor', '#333333',
        'direction', 'rtl'
    ),
    'published',
    true,
    NOW()
);

-- === آمار نهایی ===
SELECT 'داده‌های پیش‌فرض با موفقیت درج شدند!' as result;

-- شمارش رکوردهای درج شده
SELECT 
    (SELECT COUNT(*) FROM `users`) as total_users,
    (SELECT COUNT(*) FROM `form_widgets`) as total_widgets,
    (SELECT COUNT(*) FROM `forms`) as total_forms;

-- لاگ عملیات
INSERT INTO `system_logs` (`log_level`, `log_category`, `log_message`, `log_context`) VALUES
('INFO', 'MIGRATION', 'Migration v5.1: داده‌های پیش‌فرض درج شد', 
 JSON_OBJECT('users', 2, 'widgets', 10, 'forms', 1, 'version', '5.1.0', 'date', NOW()));
