<?php
/**
 * مدل کاربران سیستم - User Model
 * مدیریت کاربران Form Builder
 * 
 * @version 5.1.0
 * @author DataSave Development Team
 * @created 2025-09-01
 */

require_once __DIR__ . '/../../config/database.php';

class User {
    private PDO $db;
    private Logger $logger;
    
    public function __construct() {
        $this->db = Database::getConnection();
        $this->logger = new Logger();
    }
    
    /**
     * ایجاد کاربر جدید
     * @param array $userData اطلاعات کاربر
     * @return array نتیجه عملیات
     */
    public function createUser(array $userData): array {
        try {
            // اعتبارسنجی داده‌های ورودی
            $validation = $this->validateUserData($userData);
            if (!$validation['valid']) {
                return [
                    'success' => false,
                    'message' => 'داده‌های ورودی نامعتبر',
                    'errors' => $validation['errors']
                ];
            }
            
            // بررسی تکرار ایمیل
            if ($this->emailExists($userData['email'])) {
                return [
                    'success' => false,
                    'message' => 'این آدرس ایمیل قبلاً ثبت شده است'
                ];
            }
            
            // هش کردن رمز عبور
            $hashedPassword = password_hash($userData['password'], PASSWORD_BCRYPT, ['cost' => 12]);
            
            $sql = "INSERT INTO users (
                email, password_hash, persian_name, english_name, 
                role, status, phone, preferences
            ) VALUES (
                :email, :password_hash, :persian_name, :english_name,
                :role, :status, :phone, :preferences
            )";
            
            $stmt = $this->db->prepare($sql);
            $result = $stmt->execute([
                'email' => $userData['email'],
                'password_hash' => $hashedPassword,
                'persian_name' => $userData['persian_name'],
                'english_name' => $userData['english_name'] ?? null,
                'role' => $userData['role'] ?? 'user',
                'status' => $userData['status'] ?? 'pending',
                'phone' => $userData['phone'] ?? null,
                'preferences' => isset($userData['preferences']) ? json_encode($userData['preferences'], JSON_UNESCAPED_UNICODE) : null
            ]);
            
            if ($result) {
                $userId = $this->db->lastInsertId();
                
                // لاگ عملیات
                $this->logger->info('USER_MANAGEMENT', 'کاربر جدید ایجاد شد', [
                    'user_id' => $userId,
                    'email' => $userData['email'],
                    'role' => $userData['role'] ?? 'user'
                ]);
                
                return [
                    'success' => true,
                    'message' => 'کاربر با موفقیت ایجاد شد',
                    'user_id' => (int)$userId
                ];
            }
            
            return [
                'success' => false,
                'message' => 'خطا در ایجاد کاربر'
            ];
            
        } catch (Exception $e) {
            $this->logger->error('USER_MANAGEMENT', 'خطا در ایجاد کاربر', [
                'error' => $e->getMessage(),
                'email' => $userData['email'] ?? 'unknown'
            ]);
            
            return [
                'success' => false,
                'message' => 'خطای سیستم در ایجاد کاربر'
            ];
        }
    }
    
    /**
     * احراز هویت کاربر
     * @param string $email آدرس ایمیل
     * @param string $password رمز عبور
     * @return array نتیجه احراز هویت
     */
    public function authenticate(string $email, string $password): array {
        try {
            $sql = "SELECT id, email, password_hash, persian_name, role, status, last_login_at 
                    FROM users 
                    WHERE email = :email AND deleted_at IS NULL";
            
            $stmt = $this->db->prepare($sql);
            $stmt->execute(['email' => $email]);
            $user = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$user) {
                return [
                    'success' => false,
                    'message' => 'کاربر یافت نشد'
                ];
            }
            
            if ($user['status'] !== 'active') {
                return [
                    'success' => false,
                    'message' => 'حساب کاربری غیرفعال است'
                ];
            }
            
            if (!password_verify($password, $user['password_hash'])) {
                $this->logger->warning('USER_MANAGEMENT', 'تلاش ورود ناموفق', [
                    'email' => $email,
                    'ip' => $_SERVER['REMOTE_ADDR'] ?? 'unknown'
                ]);
                
                return [
                    'success' => false,
                    'message' => 'رمز عبور اشتباه است'
                ];
            }
            
            // بروزرسانی زمان آخرین ورود
            $this->updateLastLogin($user['id']);
            
            // لاگ ورود موفق
            $this->logger->info('USER_MANAGEMENT', 'ورود موفق کاربر', [
                'user_id' => $user['id'],
                'email' => $email,
                'role' => $user['role']
            ]);
            
            return [
                'success' => true,
                'message' => 'ورود موفق',
                'user' => [
                    'id' => (int)$user['id'],
                    'email' => $user['email'],
                    'persian_name' => $user['persian_name'],
                    'role' => $user['role']
                ]
            ];
            
        } catch (Exception $e) {
            $this->logger->error('USER_MANAGEMENT', 'خطا در احراز هویت', [
                'error' => $e->getMessage(),
                'email' => $email
            ]);
            
            return [
                'success' => false,
                'message' => 'خطای سیستم در احراز هویت'
            ];
        }
    }
    
    /**
     * دریافت اطلاعات کاربر
     * @param int $userId شناسه کاربر
     * @return array|null اطلاعات کاربر
     */
    public function getUserById(int $userId): ?array {
        try {
            $sql = "SELECT id, email, persian_name, english_name, role, status, 
                           phone, avatar_url, preferences, email_verified_at,
                           last_login_at, created_at, updated_at
                    FROM users 
                    WHERE id = :user_id AND deleted_at IS NULL";
            
            $stmt = $this->db->prepare($sql);
            $stmt->execute(['user_id' => $userId]);
            $user = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if ($user) {
                // تبدیل JSON preferences
                if ($user['preferences']) {
                    $user['preferences'] = json_decode($user['preferences'], true);
                }
                
                // تبدیل آی‌دی به عدد
                $user['id'] = (int)$user['id'];
                
                return $user;
            }
            
            return null;
            
        } catch (Exception $e) {
            $this->logger->error('USER_MANAGEMENT', 'خطا در دریافت کاربر', [
                'error' => $e->getMessage(),
                'user_id' => $userId
            ]);
            return null;
        }
    }
    
    /**
     * بروزرسانی اطلاعات کاربر
     * @param int $userId شناسه کاربر
     * @param array $updateData داده‌های بروزرسانی
     * @return bool نتیجه عملیات
     */
    public function updateUser(int $userId, array $updateData): bool {
        try {
            $allowedFields = ['persian_name', 'english_name', 'phone', 'avatar_url', 'preferences'];
            $updates = [];
            $params = ['user_id' => $userId];
            
            foreach ($updateData as $field => $value) {
                if (in_array($field, $allowedFields)) {
                    $updates[] = "$field = :$field";
                    
                    if ($field === 'preferences' && is_array($value)) {
                        $params[$field] = json_encode($value, JSON_UNESCAPED_UNICODE);
                    } else {
                        $params[$field] = $value;
                    }
                }
            }
            
            if (empty($updates)) {
                return false;
            }
            
            $sql = "UPDATE users SET " . implode(', ', $updates) . " WHERE id = :user_id AND deleted_at IS NULL";
            $stmt = $this->db->prepare($sql);
            $result = $stmt->execute($params);
            
            if ($result) {
                $this->logger->info('USER_MANAGEMENT', 'اطلاعات کاربر بروزرسانی شد', [
                    'user_id' => $userId,
                    'updated_fields' => array_keys($updateData)
                ]);
            }
            
            return $result;
            
        } catch (Exception $e) {
            $this->logger->error('USER_MANAGEMENT', 'خطا در بروزرسانی کاربر', [
                'error' => $e->getMessage(),
                'user_id' => $userId
            ]);
            return false;
        }
    }
    
    /**
     * حذف نرم کاربر (Soft Delete)
     * @param int $userId شناسه کاربر
     * @param int $deletedBy شناسه کاربر حذف کننده
     * @return bool نتیجه عملیات
     */
    public function softDeleteUser(int $userId, int $deletedBy): bool {
        try {
            $sql = "UPDATE users 
                    SET deleted_at = NOW(), deleted_by = :deleted_by, status = 'inactive'
                    WHERE id = :user_id AND deleted_at IS NULL";
            
            $stmt = $this->db->prepare($sql);
            $result = $stmt->execute([
                'user_id' => $userId,
                'deleted_by' => $deletedBy
            ]);
            
            if ($result) {
                $this->logger->warning('USER_MANAGEMENT', 'کاربر حذف شد (نرم)', [
                    'user_id' => $userId,
                    'deleted_by' => $deletedBy
                ]);
            }
            
            return $result;
            
        } catch (Exception $e) {
            $this->logger->error('USER_MANAGEMENT', 'خطا در حذف کاربر', [
                'error' => $e->getMessage(),
                'user_id' => $userId
            ]);
            return false;
        }
    }
    
    /**
     * دریافت لیست کاربران با فیلتر
     * @param array $filters فیلترها
     * @param int $limit محدودیت تعداد
     * @param int $offset جهش
     * @return array لیست کاربران
     */
    public function getUsers(array $filters = [], int $limit = 50, int $offset = 0): array {
        try {
            $conditions = ['deleted_at IS NULL'];
            $params = [];
            
            // اعمال فیلترها
            if (!empty($filters['role'])) {
                $conditions[] = 'role = :role';
                $params['role'] = $filters['role'];
            }
            
            if (!empty($filters['status'])) {
                $conditions[] = 'status = :status';
                $params['status'] = $filters['status'];
            }
            
            if (!empty($filters['search'])) {
                $conditions[] = '(persian_name LIKE :search OR english_name LIKE :search OR email LIKE :search)';
                $params['search'] = '%' . $filters['search'] . '%';
            }
            
            $sql = "SELECT id, email, persian_name, english_name, role, status,
                           last_login_at, created_at
                    FROM users 
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
            $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            // تبدیل IDs به عدد
            foreach ($users as &$user) {
                $user['id'] = (int)$user['id'];
            }
            
            return $users;
            
        } catch (Exception $e) {
            $this->logger->error('USER_MANAGEMENT', 'خطا در دریافت لیست کاربران', [
                'error' => $e->getMessage(),
                'filters' => $filters
            ]);
            return [];
        }
    }
    
    // === متدهای کمکی خصوصی ===
    
    /**
     * اعتبارسنجی داده‌های کاربر
     */
    private function validateUserData(array $data): array {
        $errors = [];
        
        // ایمیل اجباری
        if (empty($data['email'])) {
            $errors[] = 'آدرس ایمیل الزامی است';
        } elseif (!filter_var($data['email'], FILTER_VALIDATE_EMAIL)) {
            $errors[] = 'فرمت آدرس ایمیل نامعتبر است';
        }
        
        // رمز عبور اجباری
        if (empty($data['password'])) {
            $errors[] = 'رمز عبور الزامی است';
        } elseif (strlen($data['password']) < 8) {
            $errors[] = 'رمز عبور باید حداقل 8 کاراکتر باشد';
        }
        
        // نام فارسی اجباری
        if (empty($data['persian_name'])) {
            $errors[] = 'نام فارسی الزامی است';
        } elseif (strlen($data['persian_name']) < 2) {
            $errors[] = 'نام فارسی باید حداقل 2 کاراکتر باشد';
        }
        
        // نقش معتبر
        if (isset($data['role']) && !in_array($data['role'], ['admin', 'user', 'moderator'])) {
            $errors[] = 'نقش کاربر نامعتبر است';
        }
        
        return [
            'valid' => empty($errors),
            'errors' => $errors
        ];
    }
    
    /**
     * بررسی وجود ایمیل
     */
    private function emailExists(string $email): bool {
        $sql = "SELECT id FROM users WHERE email = :email AND deleted_at IS NULL";
        $stmt = $this->db->prepare($sql);
        $stmt->execute(['email' => $email]);
        return $stmt->fetch() !== false;
    }
    
    /**
     * بروزرسانی زمان آخرین ورود
     */
    private function updateLastLogin(int $userId): void {
        $sql = "UPDATE users SET last_login_at = NOW() WHERE id = :user_id";
        $stmt = $this->db->prepare($sql);
        $stmt->execute(['user_id' => $userId]);
    }
}
