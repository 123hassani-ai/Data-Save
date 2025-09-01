<?php
/**
 * مدل ویجت‌های فرم - FormWidget Model
 * مدیریت کتابخانه ویجت‌های Form Builder
 * 
 * @version 5.1.0
 * @author DataSave Development Team
 * @created 2025-09-01
 */

require_once __DIR__ . '/../../config/database.php';

class FormWidget {
    private PDO $db;
    private Logger $logger;
    
    public function __construct() {
        $this->db = Database::getConnection();
        $this->logger = new Logger();
    }
    
    /**
     * ایجاد ویجت جدید
     * @param array $widgetData اطلاعات ویجت
     * @return array نتیجه عملیات
     */
    public function createWidget(array $widgetData): array {
        try {
            // اعتبارسنجی داده‌های ورودی
            $validation = $this->validateWidgetData($widgetData);
            if (!$validation['valid']) {
                return [
                    'success' => false,
                    'message' => 'داده‌های ورودی نامعتبر',
                    'errors' => $validation['errors']
                ];
            }
            
            // بررسی تکرار کد ویجت
            if ($this->widgetCodeExists($widgetData['widget_code'])) {
                return [
                    'success' => false,
                    'message' => 'این کد ویجت قبلاً استفاده شده است'
                ];
            }
            
            $sql = "INSERT INTO form_widgets (
                widget_type, widget_code, widget_category, persian_label, english_label,
                persian_description, english_description, widget_config, validation_rules,
                default_props, icon_name, icon_color, display_order, is_pro, is_active, min_version
            ) VALUES (
                :widget_type, :widget_code, :widget_category, :persian_label, :english_label,
                :persian_description, :english_description, :widget_config, :validation_rules,
                :default_props, :icon_name, :icon_color, :display_order, :is_pro, :is_active, :min_version
            )";
            
            $stmt = $this->db->prepare($sql);
            $result = $stmt->execute([
                'widget_type' => $widgetData['widget_type'],
                'widget_code' => $widgetData['widget_code'],
                'widget_category' => $widgetData['widget_category'] ?? 'basic',
                'persian_label' => $widgetData['persian_label'],
                'english_label' => $widgetData['english_label'] ?? null,
                'persian_description' => $widgetData['persian_description'] ?? null,
                'english_description' => $widgetData['english_description'] ?? null,
                'widget_config' => json_encode($widgetData['widget_config'], JSON_UNESCAPED_UNICODE),
                'validation_rules' => isset($widgetData['validation_rules']) ? json_encode($widgetData['validation_rules'], JSON_UNESCAPED_UNICODE) : null,
                'default_props' => isset($widgetData['default_props']) ? json_encode($widgetData['default_props'], JSON_UNESCAPED_UNICODE) : null,
                'icon_name' => $widgetData['icon_name'] ?? null,
                'icon_color' => $widgetData['icon_color'] ?? '#2196F3',
                'display_order' => $widgetData['display_order'] ?? 999,
                'is_pro' => $widgetData['is_pro'] ?? false,
                'is_active' => $widgetData['is_active'] ?? true,
                'min_version' => $widgetData['min_version'] ?? '1.0'
            ]);
            
            if ($result) {
                $widgetId = $this->db->lastInsertId();
                
                // لاگ عملیات
                $this->logger->info('FORM_BUILDER', 'ویجت جدید ایجاد شد', [
                    'widget_id' => $widgetId,
                    'widget_type' => $widgetData['widget_type'],
                    'widget_code' => $widgetData['widget_code']
                ]);
                
                return [
                    'success' => true,
                    'message' => 'ویجت با موفقیت ایجاد شد',
                    'widget_id' => (int)$widgetId
                ];
            }
            
            return [
                'success' => false,
                'message' => 'خطا در ایجاد ویجت'
            ];
            
        } catch (Exception $e) {
            $this->logger->error('FORM_BUILDER', 'خطا در ایجاد ویجت', [
                'error' => $e->getMessage(),
                'widget_type' => $widgetData['widget_type'] ?? 'unknown'
            ]);
            
            return [
                'success' => false,
                'message' => 'خطای سیستم در ایجاد ویجت'
            ];
        }
    }
    
    /**
     * دریافت اطلاعات ویجت
     * @param int $widgetId شناسه ویجت
     * @return array|null اطلاعات ویجت
     */
    public function getWidgetById(int $widgetId): ?array {
        try {
            $sql = "SELECT * FROM form_widgets WHERE id = :widget_id";
            $stmt = $this->db->prepare($sql);
            $stmt->execute(['widget_id' => $widgetId]);
            $widget = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$widget) {
                return null;
            }
            
            // تبدیل JSON fields
            if ($widget['widget_config']) {
                $widget['widget_config'] = json_decode($widget['widget_config'], true);
            }
            if ($widget['validation_rules']) {
                $widget['validation_rules'] = json_decode($widget['validation_rules'], true);
            }
            if ($widget['default_props']) {
                $widget['default_props'] = json_decode($widget['default_props'], true);
            }
            
            // تبدیل ID و اعداد
            $widget['id'] = (int)$widget['id'];
            $widget['display_order'] = (int)$widget['display_order'];
            $widget['usage_count'] = (int)$widget['usage_count'];
            $widget['is_pro'] = (bool)$widget['is_pro'];
            $widget['is_active'] = (bool)$widget['is_active'];
            
            return $widget;
            
        } catch (Exception $e) {
            $this->logger->error('FORM_BUILDER', 'خطا در دریافت ویجت', [
                'error' => $e->getMessage(),
                'widget_id' => $widgetId
            ]);
            return null;
        }
    }
    
    /**
     * دریافت ویجت با کد
     * @param string $widgetCode کد ویجت
     * @return array|null اطلاعات ویجت
     */
    public function getWidgetByCode(string $widgetCode): ?array {
        try {
            $sql = "SELECT * FROM form_widgets WHERE widget_code = :widget_code AND is_active = 1";
            $stmt = $this->db->prepare($sql);
            $stmt->execute(['widget_code' => $widgetCode]);
            $widget = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$widget) {
                return null;
            }
            
            // تبدیل JSON fields مشابه متد قبل
            if ($widget['widget_config']) {
                $widget['widget_config'] = json_decode($widget['widget_config'], true);
            }
            if ($widget['validation_rules']) {
                $widget['validation_rules'] = json_decode($widget['validation_rules'], true);
            }
            if ($widget['default_props']) {
                $widget['default_props'] = json_decode($widget['default_props'], true);
            }
            
            $widget['id'] = (int)$widget['id'];
            $widget['display_order'] = (int)$widget['display_order'];
            $widget['usage_count'] = (int)$widget['usage_count'];
            $widget['is_pro'] = (bool)$widget['is_pro'];
            $widget['is_active'] = (bool)$widget['is_active'];
            
            return $widget;
            
        } catch (Exception $e) {
            $this->logger->error('FORM_BUILDER', 'خطا در دریافت ویجت با کد', [
                'error' => $e->getMessage(),
                'widget_code' => $widgetCode
            ]);
            return null;
        }
    }
    
    /**
     * دریافت کتابخانه ویجت‌ها
     * @param array $filters فیلترها
     * @param bool $activeOnly فقط فعال‌ها
     * @return array لیست ویجت‌ها
     */
    public function getWidgetLibrary(array $filters = [], bool $activeOnly = true): array {
        try {
            $conditions = [];
            $params = [];
            
            if ($activeOnly) {
                $conditions[] = 'is_active = 1';
            }
            
            // فیلتر بر اساس نوع
            if (!empty($filters['widget_type'])) {
                $conditions[] = 'widget_type = :widget_type';
                $params['widget_type'] = $filters['widget_type'];
            }
            
            // فیلتر بر اساس دسته‌بندی
            if (!empty($filters['category'])) {
                $conditions[] = 'widget_category = :category';
                $params['category'] = $filters['category'];
            }
            
            // فیلتر ویجت‌های پرمیوم
            if (isset($filters['is_pro'])) {
                $conditions[] = 'is_pro = :is_pro';
                $params['is_pro'] = $filters['is_pro'];
            }
            
            // جستجو در برچسب‌ها
            if (!empty($filters['search'])) {
                $conditions[] = '(persian_label LIKE :search OR english_label LIKE :search OR persian_description LIKE :search)';
                $params['search'] = '%' . $filters['search'] . '%';
            }
            
            $whereClause = empty($conditions) ? '' : 'WHERE ' . implode(' AND ', $conditions);
            
            $sql = "SELECT id, widget_type, widget_code, widget_category, persian_label, 
                           english_label, persian_description, widget_config, validation_rules,
                           default_props, icon_name, icon_color, display_order, is_pro, usage_count
                    FROM form_widgets 
                    $whereClause
                    ORDER BY widget_category, display_order, persian_label";
            
            $stmt = $this->db->prepare($sql);
            $stmt->execute($params);
            $widgets = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            // تبدیل JSON fields برای همه ویجت‌ها
            foreach ($widgets as &$widget) {
                if ($widget['widget_config']) {
                    $widget['widget_config'] = json_decode($widget['widget_config'], true);
                }
                if ($widget['validation_rules']) {
                    $widget['validation_rules'] = json_decode($widget['validation_rules'], true);
                }
                if ($widget['default_props']) {
                    $widget['default_props'] = json_decode($widget['default_props'], true);
                }
                
                $widget['id'] = (int)$widget['id'];
                $widget['display_order'] = (int)$widget['display_order'];
                $widget['usage_count'] = (int)$widget['usage_count'];
                $widget['is_pro'] = (bool)$widget['is_pro'];
            }
            
            return $widgets;
            
        } catch (Exception $e) {
            $this->logger->error('FORM_BUILDER', 'خطا در دریافت کتابخانه ویجت‌ها', [
                'error' => $e->getMessage(),
                'filters' => $filters
            ]);
            return [];
        }
    }
    
    /**
     * دریافت ویجت‌های دسته‌بندی شده
     * @param bool $activeOnly فقط فعال‌ها
     * @return array ویجت‌های گروه‌بندی شده
     */
    public function getWidgetsByCategory(bool $activeOnly = true): array {
        try {
            $widgets = $this->getWidgetLibrary([], $activeOnly);
            $categories = [];
            
            foreach ($widgets as $widget) {
                $category = $widget['widget_category'];
                if (!isset($categories[$category])) {
                    $categories[$category] = [
                        'category_name' => $this->getCategoryName($category),
                        'widgets' => []
                    ];
                }
                $categories[$category]['widgets'][] = $widget;
            }
            
            return $categories;
            
        } catch (Exception $e) {
            $this->logger->error('FORM_BUILDER', 'خطا در گروه‌بندی ویجت‌ها', [
                'error' => $e->getMessage()
            ]);
            return [];
        }
    }
    
    /**
     * بروزرسانی آمار استفاده ویجت
     * @param string $widgetType نوع ویجت
     * @return bool نتیجه عملیات
     */
    public function incrementUsage(string $widgetType): bool {
        try {
            $sql = "UPDATE form_widgets 
                    SET usage_count = usage_count + 1, last_used_at = NOW() 
                    WHERE widget_type = :widget_type AND is_active = 1";
            
            $stmt = $this->db->prepare($sql);
            $result = $stmt->execute(['widget_type' => $widgetType]);
            
            if ($result) {
                $this->logger->info('FORM_BUILDER', 'آمار استفاده ویجت بروزرسانی شد', [
                    'widget_type' => $widgetType
                ]);
            }
            
            return $result;
            
        } catch (Exception $e) {
            $this->logger->error('FORM_BUILDER', 'خطا در بروزرسانی آمار ویجت', [
                'error' => $e->getMessage(),
                'widget_type' => $widgetType
            ]);
            return false;
        }
    }
    
    /**
     * بروزرسانی ویجت
     * @param int $widgetId شناسه ویجت
     * @param array $updateData داده‌های بروزرسانی
     * @return bool نتیجه عملیات
     */
    public function updateWidget(int $widgetId, array $updateData): bool {
        try {
            $allowedFields = [
                'widget_category', 'persian_label', 'english_label', 'persian_description', 
                'english_description', 'widget_config', 'validation_rules', 'default_props',
                'icon_name', 'icon_color', 'display_order', 'is_pro', 'is_active', 'min_version'
            ];
            
            $updates = [];
            $params = ['widget_id' => $widgetId];
            
            foreach ($updateData as $field => $value) {
                if (in_array($field, $allowedFields)) {
                    $updates[] = "$field = :$field";
                    
                    // JSON fields را رشته کنیم
                    if (in_array($field, ['widget_config', 'validation_rules', 'default_props']) && is_array($value)) {
                        $params[$field] = json_encode($value, JSON_UNESCAPED_UNICODE);
                    } else {
                        $params[$field] = $value;
                    }
                }
            }
            
            if (empty($updates)) {
                return false;
            }
            
            $sql = "UPDATE form_widgets SET " . implode(', ', $updates) . " WHERE id = :widget_id";
            $stmt = $this->db->prepare($sql);
            $result = $stmt->execute($params);
            
            if ($result) {
                $this->logger->info('FORM_BUILDER', 'ویجت بروزرسانی شد', [
                    'widget_id' => $widgetId,
                    'updated_fields' => array_keys($updateData)
                ]);
            }
            
            return $result;
            
        } catch (Exception $e) {
            $this->logger->error('FORM_BUILDER', 'خطا در بروزرسانی ویجت', [
                'error' => $e->getMessage(),
                'widget_id' => $widgetId
            ]);
            return false;
        }
    }
    
    /**
     * دریافت ویجت‌های محبوب
     * @param int $limit تعداد ویجت
     * @return array لیست ویجت‌های محبوب
     */
    public function getPopularWidgets(int $limit = 10): array {
        try {
            $sql = "SELECT id, widget_type, widget_code, persian_label, icon_name, 
                           icon_color, usage_count, last_used_at
                    FROM form_widgets 
                    WHERE is_active = 1 AND usage_count > 0
                    ORDER BY usage_count DESC, last_used_at DESC
                    LIMIT :limit";
            
            $stmt = $this->db->prepare($sql);
            $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
            $stmt->execute();
            $widgets = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            foreach ($widgets as &$widget) {
                $widget['id'] = (int)$widget['id'];
                $widget['usage_count'] = (int)$widget['usage_count'];
            }
            
            return $widgets;
            
        } catch (Exception $e) {
            $this->logger->error('FORM_BUILDER', 'خطا در دریافت ویجت‌های محبوب', [
                'error' => $e->getMessage()
            ]);
            return [];
        }
    }
    
    // === متدهای کمکی خصوصی ===
    
    /**
     * اعتبارسنجی داده‌های ویجت
     */
    private function validateWidgetData(array $data): array {
        $errors = [];
        
        // نوع ویجت اجباری
        if (empty($data['widget_type'])) {
            $errors[] = 'نوع ویجت الزامی است';
        } elseif (!$this->isValidWidgetType($data['widget_type'])) {
            $errors[] = 'نوع ویجت نامعتبر است';
        }
        
        // کد ویجت اجباری
        if (empty($data['widget_code'])) {
            $errors[] = 'کد ویجت الزامی است';
        } elseif (!preg_match('/^[a-z][a-z0-9_]*$/', $data['widget_code'])) {
            $errors[] = 'فرمت کد ویجت نامعتبر است (فقط حروف کوچک، اعداد و _)';
        }
        
        // برچسب فارسی اجباری
        if (empty($data['persian_label'])) {
            $errors[] = 'برچسب فارسی الزامی است';
        } elseif (strlen($data['persian_label']) < 2) {
            $errors[] = 'برچسب فارسی باید حداقل 2 کاراکتر باشد';
        }
        
        // تنظیمات ویجت اجباری
        if (empty($data['widget_config'])) {
            $errors[] = 'تنظیمات ویجت الزامی است';
        } elseif (!is_array($data['widget_config'])) {
            $errors[] = 'تنظیمات ویجت باید آرایه باشد';
        }
        
        // رنگ آیکون
        if (isset($data['icon_color']) && !preg_match('/^#[0-9A-Fa-f]{6}$/', $data['icon_color'])) {
            $errors[] = 'رنگ آیکون باید در فرمت hex معتبر باشد';
        }
        
        return [
            'valid' => empty($errors),
            'errors' => $errors
        ];
    }
    
    /**
     * بررسی معتبر بودن نوع ویجت
     */
    private function isValidWidgetType(string $type): bool {
        $validTypes = [
            'text', 'textarea', 'email', 'password', 'number', 'tel', 'url',
            'select', 'multiselect', 'radio', 'checkbox', 'toggle',
            'date', 'datetime', 'time', 'range', 'color',
            'file', 'image', 'signature', 'rating', 'matrix'
        ];
        return in_array($type, $validTypes);
    }
    
    /**
     * بررسی وجود کد ویجت
     */
    private function widgetCodeExists(string $code): bool {
        $sql = "SELECT id FROM form_widgets WHERE widget_code = :widget_code";
        $stmt = $this->db->prepare($sql);
        $stmt->execute(['widget_code' => $code]);
        return $stmt->fetch() !== false;
    }
    
    /**
     * دریافت نام دسته‌بندی
     */
    private function getCategoryName(string $category): string {
        $categoryNames = [
            'basic' => 'ویجت‌های پایه',
            'advanced' => 'ویجت‌های پیشرفته',
            'custom' => 'ویجت‌های سفارشی',
            'input' => 'فیلدهای ورودی',
            'selection' => 'فیلدهای انتخابی',
            'media' => 'رسانه و فایل',
            'layout' => 'چیدمان و ساختار'
        ];
        
        return $categoryNames[$category] ?? $category;
    }
}
