<?php
/**
 * مدل پاسخ‌های فرم - FormResponse Model
 * مدیریت پاسخ‌های دریافتی از فرم‌ها
 * 
 * @version 5.1.0
 * @author DataSave Development Team
 * @created 2025-09-01
 */

require_once __DIR__ . '/../../config/database.php';

class FormResponse {
    private PDO $db;
    private Logger $logger;
    
    public function __construct() {
        $this->db = Database::getConnection();
        $this->logger = new Logger();
    }
    
    /**
     * ثبت پاسخ جدید فرم
     * @param array $responseData اطلاعات پاسخ
     * @return array نتیجه عملیات
     */
    public function createResponse(array $responseData): array {
        try {
            // اعتبارسنجی داده‌های ورودی
            $validation = $this->validateResponseData($responseData);
            if (!$validation['valid']) {
                return [
                    'success' => false,
                    'message' => 'داده‌های ورودی نامعتبر',
                    'errors' => $validation['errors']
                ];
            }
            
            // بررسی وجود فرم
            if (!$this->formExists($responseData['form_id'])) {
                return [
                    'success' => false,
                    'message' => 'فرم موردنظر یافت نشد'
                ];
            }
            
            // تولید هش داده‌ها برای تشخیص تکرار
            $responseHash = $this->generateResponseHash($responseData['response_data']);
            
            // محاسبه زمان تکمیل
            $completionTime = null;
            if (isset($responseData['started_at']) && isset($responseData['submitted_at'])) {
                $startTime = strtotime($responseData['started_at']);
                $submitTime = strtotime($responseData['submitted_at']);
                $completionTime = $submitTime - $startTime;
            }
            
            $sql = "INSERT INTO form_responses (
                form_id, respondent_user_id, response_data, response_hash, form_version,
                session_id, respondent_ip, user_agent, device_info, started_at, submitted_at,
                completion_time, timezone, status, completeness_percent
            ) VALUES (
                :form_id, :respondent_user_id, :response_data, :response_hash, :form_version,
                :session_id, :respondent_ip, :user_agent, :device_info, :started_at, :submitted_at,
                :completion_time, :timezone, :status, :completeness_percent
            )";
            
            $stmt = $this->db->prepare($sql);
            $result = $stmt->execute([
                'form_id' => $responseData['form_id'],
                'respondent_user_id' => $responseData['respondent_user_id'] ?? null,
                'response_data' => json_encode($responseData['response_data'], JSON_UNESCAPED_UNICODE),
                'response_hash' => $responseHash,
                'form_version' => $responseData['form_version'] ?? null,
                'session_id' => $responseData['session_id'] ?? session_id(),
                'respondent_ip' => $responseData['respondent_ip'] ?? $_SERVER['REMOTE_ADDR'] ?? 'unknown',
                'user_agent' => $responseData['user_agent'] ?? $_SERVER['HTTP_USER_AGENT'] ?? null,
                'device_info' => isset($responseData['device_info']) ? json_encode($responseData['device_info'], JSON_UNESCAPED_UNICODE) : null,
                'started_at' => $responseData['started_at'] ?? null,
                'submitted_at' => $responseData['submitted_at'] ?? date('Y-m-d H:i:s'),
                'completion_time' => $completionTime,
                'timezone' => $responseData['timezone'] ?? date_default_timezone_get(),
                'status' => $responseData['status'] ?? 'submitted',
                'completeness_percent' => $this->calculateCompleteness($responseData['response_data'])
            ]);
            
            if ($result) {
                $responseId = $this->db->lastInsertId();
                
                // لاگ عملیات
                $this->logger->info('FORM_BUILDER', 'پاسخ جدید فرم ثبت شد', [
                    'response_id' => $responseId,
                    'form_id' => $responseData['form_id'],
                    'user_id' => $responseData['respondent_user_id'] ?? 'anonymous',
                    'ip' => $responseData['respondent_ip'] ?? $_SERVER['REMOTE_ADDR'] ?? 'unknown'
                ]);
                
                return [
                    'success' => true,
                    'message' => 'پاسخ فرم با موفقیت ثبت شد',
                    'response_id' => (int)$responseId
                ];
            }
            
            return [
                'success' => false,
                'message' => 'خطا در ثبت پاسخ فرم'
            ];
            
        } catch (Exception $e) {
            $this->logger->error('FORM_BUILDER', 'خطا در ثبت پاسخ فرم', [
                'error' => $e->getMessage(),
                'form_id' => $responseData['form_id'] ?? 'unknown'
            ]);
            
            return [
                'success' => false,
                'message' => 'خطای سیستم در ثبت پاسخ'
            ];
        }
    }
    
    /**
     * دریافت اطلاعات پاسخ
     * @param int $responseId شناسه پاسخ
     * @return array|null اطلاعات پاسخ
     */
    public function getResponseById(int $responseId): ?array {
        try {
            $sql = "SELECT fr.*, f.persian_title as form_title, f.user_id as form_owner_id,
                           u.persian_name as respondent_name, u.email as respondent_email
                    FROM form_responses fr
                    JOIN forms f ON fr.form_id = f.id
                    LEFT JOIN users u ON fr.respondent_user_id = u.id
                    WHERE fr.id = :response_id AND fr.deleted_at IS NULL";
            
            $stmt = $this->db->prepare($sql);
            $stmt->execute(['response_id' => $responseId]);
            $response = $stmt->fetch(PDO::FETCH_ASSOC);
            
            if (!$response) {
                return null;
            }
            
            // تبدیل JSON fields
            if ($response['response_data']) {
                $response['response_data'] = json_decode($response['response_data'], true);
            }
            if ($response['device_info']) {
                $response['device_info'] = json_decode($response['device_info'], true);
            }
            if ($response['flags']) {
                $response['flags'] = json_decode($response['flags'], true);
            }
            
            // تبدیل ID ها و اعداد
            $response['id'] = (int)$response['id'];
            $response['form_id'] = (int)$response['form_id'];
            $response['form_owner_id'] = (int)$response['form_owner_id'];
            $response['respondent_user_id'] = $response['respondent_user_id'] ? (int)$response['respondent_user_id'] : null;
            $response['completion_time'] = $response['completion_time'] ? (int)$response['completion_time'] : null;
            $response['quality_score'] = $response['quality_score'] ? (float)$response['quality_score'] : null;
            $response['completeness_percent'] = (float)$response['completeness_percent'];
            $response['is_verified'] = (bool)$response['is_verified'];
            
            return $response;
            
        } catch (Exception $e) {
            $this->logger->error('FORM_BUILDER', 'خطا در دریافت پاسخ', [
                'error' => $e->getMessage(),
                'response_id' => $responseId
            ]);
            return null;
        }
    }
    
    /**
     * دریافت پاسخ‌های یک فرم
     * @param int $formId شناسه فرم
     * @param int $userId شناسه کاربر (برای بررسی مالکیت)
     * @param array $filters فیلترها
     * @param int $limit محدودیت تعداد
     * @param int $offset جهش
     * @return array لیست پاسخ‌ها
     */
    public function getFormResponses(int $formId, int $userId, array $filters = [], int $limit = 50, int $offset = 0): array {
        try {
            // بررسی مالکیت فرم
            if (!$this->checkFormOwnership($formId, $userId)) {
                return [];
            }
            
            $conditions = ['fr.form_id = :form_id', 'fr.deleted_at IS NULL'];
            $params = ['form_id' => $formId];
            
            // اعمال فیلترها
            if (!empty($filters['status'])) {
                $conditions[] = 'fr.status = :status';
                $params['status'] = $filters['status'];
            }
            
            if (!empty($filters['date_from'])) {
                $conditions[] = 'fr.submitted_at >= :date_from';
                $params['date_from'] = $filters['date_from'];
            }
            
            if (!empty($filters['date_to'])) {
                $conditions[] = 'fr.submitted_at <= :date_to';
                $params['date_to'] = $filters['date_to'];
            }
            
            if (isset($filters['is_verified'])) {
                $conditions[] = 'fr.is_verified = :is_verified';
                $params['is_verified'] = $filters['is_verified'];
            }
            
            $sql = "SELECT fr.id, fr.submitted_at, fr.status, fr.is_verified, 
                           fr.quality_score, fr.completeness_percent, fr.completion_time,
                           fr.respondent_ip, u.persian_name as respondent_name
                    FROM form_responses fr
                    LEFT JOIN users u ON fr.respondent_user_id = u.id
                    WHERE " . implode(' AND ', $conditions) . "
                    ORDER BY fr.submitted_at DESC
                    LIMIT :limit OFFSET :offset";
            
            $stmt = $this->db->prepare($sql);
            
            foreach ($params as $key => $value) {
                $stmt->bindValue(":$key", $value);
            }
            $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
            $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
            
            $stmt->execute();
            $responses = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            // تبدیل اعداد
            foreach ($responses as &$response) {
                $response['id'] = (int)$response['id'];
                $response['completion_time'] = $response['completion_time'] ? (int)$response['completion_time'] : null;
                $response['quality_score'] = $response['quality_score'] ? (float)$response['quality_score'] : null;
                $response['completeness_percent'] = (float)$response['completeness_percent'];
                $response['is_verified'] = (bool)$response['is_verified'];
            }
            
            return $responses;
            
        } catch (Exception $e) {
            $this->logger->error('FORM_BUILDER', 'خطا در دریافت پاسخ‌های فرم', [
                'error' => $e->getMessage(),
                'form_id' => $formId,
                'user_id' => $userId
            ]);
            return [];
        }
    }
    
    /**
     * بروزرسانی وضعیت پاسخ
     * @param int $responseId شناسه پاسخ
     * @param string $status وضعیت جدید
     * @param int $reviewedBy شناسه کاربر بررسی کننده
     * @param string|null $reviewNotes یادداشت‌های بررسی
     * @return bool نتیجه عملیات
     */
    public function updateResponseStatus(int $responseId, string $status, int $reviewedBy, ?string $reviewNotes = null): bool {
        try {
            $validStatuses = ['submitted', 'reviewed', 'approved', 'rejected', 'flagged'];
            if (!in_array($status, $validStatuses)) {
                return false;
            }
            
            $sql = "UPDATE form_responses 
                    SET status = :status, reviewed_by = :reviewed_by, reviewed_at = NOW(), 
                        review_notes = :review_notes, is_verified = :is_verified
                    WHERE id = :response_id AND deleted_at IS NULL";
            
            $isVerified = in_array($status, ['reviewed', 'approved']);
            
            $stmt = $this->db->prepare($sql);
            $result = $stmt->execute([
                'response_id' => $responseId,
                'status' => $status,
                'reviewed_by' => $reviewedBy,
                'review_notes' => $reviewNotes,
                'is_verified' => $isVerified
            ]);
            
            if ($result) {
                $this->logger->info('FORM_BUILDER', 'وضعیت پاسخ فرم بروزرسانی شد', [
                    'response_id' => $responseId,
                    'new_status' => $status,
                    'reviewed_by' => $reviewedBy
                ]);
            }
            
            return $result;
            
        } catch (Exception $e) {
            $this->logger->error('FORM_BUILDER', 'خطا در بروزرسانی وضعیت پاسخ', [
                'error' => $e->getMessage(),
                'response_id' => $responseId,
                'status' => $status
            ]);
            return false;
        }
    }
    
    /**
     * امتیازدهی به پاسخ
     * @param int $responseId شناسه پاسخ
     * @param float $qualityScore امتیاز کیفیت (0-10)
     * @param int $reviewedBy شناسه کاربر امتیازدهنده
     * @return bool نتیجه عملیات
     */
    public function rateResponse(int $responseId, float $qualityScore, int $reviewedBy): bool {
        try {
            if ($qualityScore < 0 || $qualityScore > 10) {
                return false;
            }
            
            $sql = "UPDATE form_responses 
                    SET quality_score = :quality_score, reviewed_by = :reviewed_by, reviewed_at = NOW()
                    WHERE id = :response_id AND deleted_at IS NULL";
            
            $stmt = $this->db->prepare($sql);
            $result = $stmt->execute([
                'response_id' => $responseId,
                'quality_score' => $qualityScore,
                'reviewed_by' => $reviewedBy
            ]);
            
            if ($result) {
                $this->logger->info('FORM_BUILDER', 'پاسخ فرم امتیازدهی شد', [
                    'response_id' => $responseId,
                    'quality_score' => $qualityScore,
                    'reviewed_by' => $reviewedBy
                ]);
            }
            
            return $result;
            
        } catch (Exception $e) {
            $this->logger->error('FORM_BUILDER', 'خطا در امتیازدهی پاسخ', [
                'error' => $e->getMessage(),
                'response_id' => $responseId,
                'quality_score' => $qualityScore
            ]);
            return false;
        }
    }
    
    /**
     * حذف نرم پاسخ
     * @param int $responseId شناسه پاسخ
     * @param int $deletedBy شناسه کاربر حذف کننده
     * @return bool نتیجه عملیات
     */
    public function softDeleteResponse(int $responseId, int $deletedBy): bool {
        try {
            $sql = "UPDATE form_responses 
                    SET deleted_at = NOW(), deleted_by = :deleted_by
                    WHERE id = :response_id AND deleted_at IS NULL";
            
            $stmt = $this->db->prepare($sql);
            $result = $stmt->execute([
                'response_id' => $responseId,
                'deleted_by' => $deletedBy
            ]);
            
            if ($result) {
                $this->logger->warning('FORM_BUILDER', 'پاسخ فرم حذف شد (نرم)', [
                    'response_id' => $responseId,
                    'deleted_by' => $deletedBy
                ]);
            }
            
            return $result;
            
        } catch (Exception $e) {
            $this->logger->error('FORM_BUILDER', 'خطا در حذف پاسخ', [
                'error' => $e->getMessage(),
                'response_id' => $responseId
            ]);
            return false;
        }
    }
    
    /**
     * دریافت آمار پاسخ‌های فرم
     * @param int $formId شناسه فرم
     * @param int $userId شناسه کاربر (برای بررسی مالکیت)
     * @return array آمار پاسخ‌ها
     */
    public function getFormResponseStats(int $formId, int $userId): array {
        try {
            // بررسی مالکیت فرم
            if (!$this->checkFormOwnership($formId, $userId)) {
                return [];
            }
            
            $sql = "SELECT 
                        COUNT(*) as total_responses,
                        COUNT(CASE WHEN status = 'submitted' THEN 1 END) as submitted_count,
                        COUNT(CASE WHEN status = 'reviewed' THEN 1 END) as reviewed_count,
                        COUNT(CASE WHEN status = 'approved' THEN 1 END) as approved_count,
                        COUNT(CASE WHEN status = 'rejected' THEN 1 END) as rejected_count,
                        COUNT(CASE WHEN is_verified = 1 THEN 1 END) as verified_count,
                        AVG(quality_score) as avg_quality_score,
                        AVG(completion_time) as avg_completion_time,
                        AVG(completeness_percent) as avg_completeness,
                        MIN(submitted_at) as first_response_at,
                        MAX(submitted_at) as last_response_at
                    FROM form_responses 
                    WHERE form_id = :form_id AND deleted_at IS NULL";
            
            $stmt = $this->db->prepare($sql);
            $stmt->execute(['form_id' => $formId]);
            $stats = $stmt->fetch(PDO::FETCH_ASSOC);
            
            return [
                'total_responses' => (int)($stats['total_responses'] ?? 0),
                'submitted_count' => (int)($stats['submitted_count'] ?? 0),
                'reviewed_count' => (int)($stats['reviewed_count'] ?? 0),
                'approved_count' => (int)($stats['approved_count'] ?? 0),
                'rejected_count' => (int)($stats['rejected_count'] ?? 0),
                'verified_count' => (int)($stats['verified_count'] ?? 0),
                'avg_quality_score' => round((float)($stats['avg_quality_score'] ?? 0), 2),
                'avg_completion_time' => round((float)($stats['avg_completion_time'] ?? 0), 2),
                'avg_completeness' => round((float)($stats['avg_completeness'] ?? 0), 2),
                'first_response_at' => $stats['first_response_at'],
                'last_response_at' => $stats['last_response_at']
            ];
            
        } catch (Exception $e) {
            $this->logger->error('FORM_BUILDER', 'خطا در دریافت آمار پاسخ‌ها', [
                'error' => $e->getMessage(),
                'form_id' => $formId
            ]);
            return [];
        }
    }
    
    /**
     * جستجو در پاسخ‌ها
     * @param int $formId شناسه فرم
     * @param string $searchTerm عبارت جستجو
     * @param int $userId شناسه کاربر
     * @return array نتایج جستجو
     */
    public function searchResponses(int $formId, string $searchTerm, int $userId): array {
        try {
            // بررسی مالکیت فرم
            if (!$this->checkFormOwnership($formId, $userId)) {
                return [];
            }
            
            $sql = "SELECT fr.id, fr.submitted_at, fr.status, fr.completeness_percent,
                           u.persian_name as respondent_name, fr.respondent_ip
                    FROM form_responses fr
                    LEFT JOIN users u ON fr.respondent_user_id = u.id
                    WHERE fr.form_id = :form_id 
                      AND fr.deleted_at IS NULL
                      AND (JSON_SEARCH(fr.response_data, 'one', :search_term) IS NOT NULL
                           OR u.persian_name LIKE :search_like
                           OR fr.respondent_ip LIKE :search_like)
                    ORDER BY fr.submitted_at DESC
                    LIMIT 100";
            
            $stmt = $this->db->prepare($sql);
            $stmt->execute([
                'form_id' => $formId,
                'search_term' => "%$searchTerm%",
                'search_like' => "%$searchTerm%"
            ]);
            
            $responses = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            foreach ($responses as &$response) {
                $response['id'] = (int)$response['id'];
                $response['completeness_percent'] = (float)$response['completeness_percent'];
            }
            
            return $responses;
            
        } catch (Exception $e) {
            $this->logger->error('FORM_BUILDER', 'خطا در جستجوی پاسخ‌ها', [
                'error' => $e->getMessage(),
                'form_id' => $formId,
                'search_term' => $searchTerm
            ]);
            return [];
        }
    }
    
    // === متدهای کمکی خصوصی ===
    
    /**
     * اعتبارسنجی داده‌های پاسخ
     */
    private function validateResponseData(array $data): array {
        $errors = [];
        
        if (empty($data['form_id'])) {
            $errors[] = 'شناسه فرم الزامی است';
        }
        
        if (empty($data['response_data'])) {
            $errors[] = 'داده‌های پاسخ الزامی است';
        } elseif (!is_array($data['response_data'])) {
            $errors[] = 'داده‌های پاسخ باید آرایه باشد';
        }
        
        return [
            'valid' => empty($errors),
            'errors' => $errors
        ];
    }
    
    /**
     * بررسی وجود فرم
     */
    private function formExists(int $formId): bool {
        $sql = "SELECT id FROM forms WHERE id = :form_id AND deleted_at IS NULL";
        $stmt = $this->db->prepare($sql);
        $stmt->execute(['form_id' => $formId]);
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
     * تولید هش پاسخ
     */
    private function generateResponseHash(array $responseData): string {
        return hash('sha256', json_encode($responseData, JSON_UNESCAPED_UNICODE));
    }
    
    /**
     * محاسبه درصد تکمیل
     */
    private function calculateCompleteness(array $responseData): float {
        $totalFields = count($responseData);
        if ($totalFields === 0) {
            return 0;
        }
        
        $filledFields = 0;
        foreach ($responseData as $value) {
            if (!empty($value) && $value !== '' && $value !== null) {
                $filledFields++;
            }
        }
        
        return round(($filledFields / $totalFields) * 100, 2);
    }
}
