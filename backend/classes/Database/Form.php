<?php
/**
 * مدل فرم‌ها - Form Model
 * مدیریت فرم‌های Form Builder
 * 
 * @version 5.1.0
 * @author DataSave Development Team
 * @created 2025-09-01
 */

require_once __DIR__ . '/../../config/database.php';

class Form {
    private PDO $db;
    private Logger $logger;
    
    public function __construct() {
        $this->db = Database::getConnection();
        $this->logger = new Logger();
    }
    
    /**
     * ایجاد فرم جدید
     * @param array $formData اطلاعات فرم
     * @return array نتیجه عملیات
     */
    public function createForm(array $formData): array {
        try {
            // اعتبارسنجی داده‌های ورودی
            $validation = $this->validateFormData($formData);
            if (!$validation['valid']) {
                return [
                    'success' => false,
                    'message' => 'داده‌های ورودی نامعتبر',
                    'errors' => $validation['errors']
                ];
            }
            
            // بررسی وجود کاربر
            if (!$this->userExists($formData['user_id'])) {
                return [
                    'success' => false,
                    'message' => 'کاربر موردنظر یافت نشد'
                ];
            }
            
            $sql = "INSERT INTO forms (
                user_id, persian_title, english_title, persian_description, english_description,
                form_schema, form_config, form_settings, status, is_public, requires_login,
                max_responses, expires_at, version, parent_form_id
            ) VALUES (
                :user_id, :persian_title, :english_title, :persian_description, :english_description,
                :form_schema, :form_config, :form_settings, :status, :is_public, :requires_login,
                :max_responses, :expires_at, :version, :parent_form_id
            )";
            
            $stmt = $this->db->prepare($sql);
            $result = $stmt->execute([
                'user_id' => $formData['user_id'],
                'persian_title' => $formData['persian_title'],
                'english_title' => $formData['english_title'] ?? null,
                'persian_description' => $formData['persian_description'] ?? null,
                'english_description' => $formData['english_description'] ?? null,
                'form_schema' => json_encode($formData['form_schema'], JSON_UNESCAPED_UNICODE),
                'form_config' => isset($formData['form_config']) ? json_encode($formData['form_config'], JSON_UNESCAPED_UNICODE) : null,
                'form_settings' => isset($formData['form_settings']) ? json_encode($formData['form_settings'], JSON_UNESCAPED_UNICODE) : null,
                'status' => $formData['status'] ?? 'draft',
                'is_public' => $formData['is_public'] ?? false,
                'requires_login' => $formData['requires_login'] ?? false,
                'max_responses' => $formData['max_responses'] ?? null,
                'expires_at' => $formData['expires_at'] ?? null,
                'version' => $formData['version'] ?? '1.0',
                'parent_form_id' => $formData['parent_form_id'] ?? null
            ]);
            
            if ($result) {
                $formId = $this->db->lastInsertId();
                
                // لاگ عملیات
                $this->logger->info('FORM_BUILDER', 'فرم جدید ایجاد شد', [
                    'form_id' => $formId,
                    'user_id' => $formData['user_id'],
                    'title' => $formData['persian_title']
                ]);
                
                return [
                    'success' => true,
                    'message' => 'فرم با موفقیت ایجاد شد',
                    'form_id' => (int)$formId
                ];
            }
            
            return [
                'success' => false,
                'message' => 'خطا در ایجاد فرم'
            ];
            
        } catch (Exception $e) {
            $this->logger->error('FORM_BUILDER', 'خطا در ایجاد فرم', [
                'error' => $e->getMessage(),
                'user_id' => $formData['user_id'] ?? 'unknown'
            ]);
            
            return [
                'success' => false,
                'message' => 'خطای سیستم در ایجاد فرم'
            ];
        }
    }
    
    /**
     * دریافت اطلاعات فرم
     * @param int $formId شناسه فرم
     * @param bool $includeStats شامل آمار باشد؟
     * @return array|null اطلاعات فرم
     */
    public function getFormById(int $formId, bool $includeStats = false): ?array {
        try {
            $baseSql = "SELECT f.*, u.persian_name as creator_name, u.email as creator_email
                        FROM forms f 
                        JOIN users u ON f.user_id = u.id
                        WHERE f.id = :form_id AND f.deleted_at IS NULL";
            
            $stmt = $this->db->prepare($baseSql);
            $stmt->execute(['form_id' => $formId]);
            $form = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$form) {
                return null;
            }
            
            // تبدیل JSON fields
            if ($form['form_schema']) {
                $form['form_schema'] = json_decode($form['form_schema'], true);
            }
            if ($form['form_config']) {
                $form['form_config'] = json_decode($form['form_config'], true);
            }
            if ($form['form_settings']) {
                $form['form_settings'] = json_decode($form['form_settings'], true);
            }
            
            // تبدیل ID ها به عدد
            $form['id'] = (int)$form['id'];
            $form['user_id'] = (int)$form['user_id'];
            $form['total_responses'] = (int)$form['total_responses'];
            $form['view_count'] = (int)$form['view_count'];
            
            if ($includeStats) {
                $form['stats'] = $this->getFormStats($formId);
            }
            
            return $form;
            
        } catch (Exception $e) {
            $this->logger->error('FORM_BUILDER', 'خطا در دریافت فرم', [
                'error' => $e->getMessage(),
                'form_id' => $formId
            ]);
            return null;
        }
    }
    
    /**
     * بروزرسانی فرم
     * @param int $formId شناسه فرم
     * @param array $updateData داده‌های بروزرسانی
     * @param int $userId شناسه کاربر (برای بررسی مالکیت)
     * @return bool نتیجه عملیات
     */
    public function updateForm(int $formId, array $updateData, int $userId): bool {
        try {
            // بررسی مالکیت فرم
            if (!$this->checkFormOwnership($formId, $userId)) {
                return false;
            }
            
            $allowedFields = [
                'persian_title', 'english_title', 'persian_description', 'english_description',
                'form_schema', 'form_config', 'form_settings', 'status', 'is_public', 
                'requires_login', 'max_responses', 'expires_at'
            ];
            
            $updates = [];
            $params = ['form_id' => $formId];
            
            foreach ($updateData as $field => $value) {
                if (in_array($field, $allowedFields)) {
                    $updates[] = "$field = :$field";
                    
                    // JSON fields را رشته کنیم
                    if (in_array($field, ['form_schema', 'form_config', 'form_settings']) && is_array($value)) {
                        $params[$field] = json_encode($value, JSON_UNESCAPED_UNICODE);
                    } else {
                        $params[$field] = $value;
                    }
                }
            }
            
            if (empty($updates)) {
                return false;
            }
            
            $sql = "UPDATE forms SET " . implode(', ', $updates) . " WHERE id = :form_id AND deleted_at IS NULL";
            $stmt = $this->db->prepare($sql);
            $result = $stmt->execute($params);
            
            if ($result) {
                $this->logger->info('FORM_BUILDER', 'فرم بروزرسانی شد', [
                    'form_id' => $formId,
                    'user_id' => $userId,
                    'updated_fields' => array_keys($updateData)
                ]);
            }
            
            return $result;
            
        } catch (Exception $e) {
            $this->logger->error('FORM_BUILDER', 'خطا در بروزرسانی فرم', [
                'error' => $e->getMessage(),
                'form_id' => $formId,
                'user_id' => $userId
            ]);
            return false;
        }
    }
    
    /**
     * انتشار فرم
     * @param int $formId شناسه فرم
     * @param int $userId شناسه کاربر
     * @return bool نتیجه عملیات
     */
    public function publishForm(int $formId, int $userId): bool {
        try {
            // بررسی مالکیت
            if (!$this->checkFormOwnership($formId, $userId)) {
                return false;
            }
            
            $sql = "UPDATE forms 
                    SET status = 'published', published_at = NOW() 
                    WHERE id = :form_id AND deleted_at IS NULL";
            
            $stmt = $this->db->prepare($sql);
            $result = $stmt->execute(['form_id' => $formId]);
            
            if ($result) {
                $this->logger->info('FORM_BUILDER', 'فرم منتشر شد', [
                    'form_id' => $formId,
                    'user_id' => $userId
                ]);
            }
            
            return $result;
            
        } catch (Exception $e) {
            $this->logger->error('FORM_BUILDER', 'خطا در انتشار فرم', [
                'error' => $e->getMessage(),
                'form_id' => $formId,
                'user_id' => $userId
            ]);
            return false;
        }
    }
    
    /**
     * حذف نرم فرم
     * @param int $formId شناسه فرم
     * @param int $userId شناسه کاربر حذف کننده
     * @return bool نتیجه عملیات
     */
    public function softDeleteForm(int $formId, int $userId): bool {
        try {
            // بررسی مالکیت
            if (!$this->checkFormOwnership($formId, $userId)) {
                return false;
            }
            
            $sql = "UPDATE forms 
                    SET deleted_at = NOW(), deleted_by = :deleted_by, status = 'archived'
                    WHERE id = :form_id AND deleted_at IS NULL";
            
            $stmt = $this->db->prepare($sql);
            $result = $stmt->execute([
                'form_id' => $formId,
                'deleted_by' => $userId
            ]);
            
            if ($result) {
                $this->logger->warning('FORM_BUILDER', 'فرم حذف شد (نرم)', [
                    'form_id' => $formId,
                    'deleted_by' => $userId
                ]);
            }
            
            return $result;
            
        } catch (Exception $e) {
            $this->logger->error('FORM_BUILDER', 'خطا در حذف فرم', [
                'error' => $e->getMessage(),
                'form_id' => $formId,
                'user_id' => $userId
            ]);
            return false;
        }
    }
    
    /**
     * دریافت فرم‌های کاربر
     * @param int $userId شناسه کاربر
     * @param array $filters فیلترها
     * @param int $limit محدودیت تعداد
     * @param int $offset جهش
     * @return array لیست فرم‌ها
     */
    public function getUserForms(int $userId, array $filters = [], int $limit = 20, int $offset = 0): array {
        try {
            $conditions = ['user_id = :user_id', 'deleted_at IS NULL'];
            $params = ['user_id' => $userId];
            
            // اعمال فیلترها
            if (!empty($filters['status'])) {
                $conditions[] = 'status = :status';
                $params['status'] = $filters['status'];
            }
            
            if (!empty($filters['search'])) {
                $conditions[] = '(persian_title LIKE :search OR english_title LIKE :search)';
                $params['search'] = '%' . $filters['search'] . '%';
            }
            
            if (!empty($filters['is_public'])) {
                $conditions[] = 'is_public = :is_public';
                $params['is_public'] = $filters['is_public'];
            }
            
            $sql = "SELECT id, persian_title, english_title, status, is_public, 
                           total_responses, view_count, created_at, updated_at, published_at
                    FROM forms
                    WHERE " . implode(' AND ', $conditions) . "
                    ORDER BY created_at DESC
                    LIMIT :limit OFFSET :offset";
            
            $stmt = $this->db->prepare($sql);
            
            // bind parameters
            foreach ($params as $key => $value) {
                $stmt->bindValue(":$key", $value);
            }
            $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
            $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
            
            $stmt->execute();
            $forms = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            // تبدیل IDs به عدد
            foreach ($forms as &$form) {
                $form['id'] = (int)$form['id'];
                $form['total_responses'] = (int)$form['total_responses'];
                $form['view_count'] = (int)$form['view_count'];
                $form['is_public'] = (bool)$form['is_public'];
            }
            
            return $forms;
            
        } catch (Exception $e) {
            $this->logger->error('FORM_BUILDER', 'خطا در دریافت فرم‌های کاربر', [
                'error' => $e->getMessage(),
                'user_id' => $userId,
                'filters' => $filters
            ]);
            return [];
        }
    }
    
    /**
     * دریافت فرم‌های عمومی
     * @param array $filters فیلترها
     * @param int $limit محدودیت تعداد
     * @param int $offset جهش
     * @return array لیست فرم‌های عمومی
     */
    public function getPublicForms(array $filters = [], int $limit = 20, int $offset = 0): array {
        try {
            $conditions = [
                'is_public = 1', 
                'status = "published"', 
                'deleted_at IS NULL',
                '(expires_at IS NULL OR expires_at > NOW())'
            ];
            $params = [];
            
            if (!empty($filters['search'])) {
                $conditions[] = '(persian_title LIKE :search OR persian_description LIKE :search)';
                $params['search'] = '%' . $filters['search'] . '%';
            }
            
            $sql = "SELECT f.id, f.persian_title, f.english_title, f.persian_description,
                           f.total_responses, f.view_count, f.created_at, f.published_at,
                           u.persian_name as creator_name
                    FROM forms f
                    JOIN users u ON f.user_id = u.id
                    WHERE " . implode(' AND ', $conditions) . "
                    ORDER BY f.published_at DESC
                    LIMIT :limit OFFSET :offset";
            
            $stmt = $this->db->prepare($sql);
            
            foreach ($params as $key => $value) {
                $stmt->bindValue(":$key", $value);
            }
            $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
            $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
            
            $stmt->execute();
            $forms = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            foreach ($forms as &$form) {
                $form['id'] = (int)$form['id'];
                $form['total_responses'] = (int)$form['total_responses'];
                $form['view_count'] = (int)$form['view_count'];
            }
            
            return $forms;
            
        } catch (Exception $e) {
            $this->logger->error('FORM_BUILDER', 'خطا در دریافت فرم‌های عمومی', [
                'error' => $e->getMessage(),
                'filters' => $filters
            ]);
            return [];
        }
    }
    
    /**
     * افزایش شمارنده نمایش فرم
     * @param int $formId شناسه فرم
     * @return bool نتیجه عملیات
     */
    public function incrementViewCount(int $formId): bool {
        try {
            $sql = "UPDATE forms SET view_count = view_count + 1 WHERE id = :form_id";
            $stmt = $this->db->prepare($sql);
            return $stmt->execute(['form_id' => $formId]);
            
        } catch (Exception $e) {
            $this->logger->error('FORM_BUILDER', 'خطا در افزایش شمارنده نمایش', [
                'error' => $e->getMessage(),
                'form_id' => $formId
            ]);
            return false;
        }
    }
    
    // === متدهای کمکی خصوصی ===
    
    /**
     * اعتبارسنجی داده‌های فرم
     */
    private function validateFormData(array $data): array {
        $errors = [];
        
        if (empty($data['user_id'])) {
            $errors[] = 'شناسه کاربر الزامی است';
        }
        
        if (empty($data['persian_title'])) {
            $errors[] = 'عنوان فارسی فرم الزامی است';
        } elseif (strlen($data['persian_title']) < 3) {
            $errors[] = 'عنوان فرم باید حداقل 3 کاراکتر باشد';
        }
        
        if (empty($data['form_schema'])) {
            $errors[] = 'ساختار فرم الزامی است';
        } elseif (!is_array($data['form_schema'])) {
            $errors[] = 'ساختار فرم باید آرایه باشد';
        }
        
        if (isset($data['status']) && !in_array($data['status'], ['active', 'draft', 'archived', 'published', 'paused'])) {
            $errors[] = 'وضعیت فرم نامعتبر است';
        }
        
        return [
            'valid' => empty($errors),
            'errors' => $errors
        ];
    }
    
    /**
     * بررسی وجود کاربر
     */
    private function userExists(int $userId): bool {
        $sql = "SELECT id FROM users WHERE id = :user_id AND deleted_at IS NULL";
        $stmt = $this->db->prepare($sql);
        $stmt->execute(['user_id' => $userId]);
        return $stmt->fetch() !== false;
    }
    
    /**
     * بررسی مالکیت فرم
     */
    private function checkFormOwnership(int $formId, int $userId): bool {
        $sql = "SELECT user_id FROM forms WHERE id = :form_id AND deleted_at IS NULL";
        $stmt = $this->db->prepare($sql);
        $stmt->execute(['form_id' => $formId]);
        $form = $stmt->fetch();
        
        return $form && (int)$form['user_id'] === $userId;
    }
    
    /**
     * دریافت آمار فرم
     */
    private function getFormStats(int $formId): array {
        try {
            $sql = "SELECT 
                        COUNT(*) as total_responses,
                        COUNT(CASE WHEN status = 'submitted' THEN 1 END) as submitted_count,
                        COUNT(CASE WHEN status = 'reviewed' THEN 1 END) as reviewed_count,
                        AVG(quality_score) as avg_quality_score,
                        AVG(completion_time) as avg_completion_time
                    FROM form_responses 
                    WHERE form_id = :form_id AND deleted_at IS NULL";
            
            $stmt = $this->db->prepare($sql);
            $stmt->execute(['form_id' => $formId]);
            $stats = $stmt->fetch(PDO::FETCH_ASSOC);
            
            return [
                'total_responses' => (int)($stats['total_responses'] ?? 0),
                'submitted_count' => (int)($stats['submitted_count'] ?? 0),
                'reviewed_count' => (int)($stats['reviewed_count'] ?? 0),
                'avg_quality_score' => round((float)($stats['avg_quality_score'] ?? 0), 2),
                'avg_completion_time' => round((float)($stats['avg_completion_time'] ?? 0), 2)
            ];
            
        } catch (Exception $e) {
            return [];
        }
    }
}
