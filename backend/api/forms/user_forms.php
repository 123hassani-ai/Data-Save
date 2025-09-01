<?php
/**
 * API دریافت فرم‌های کاربر - Get User Forms API
 * 
 * @version 5.2.0
 * @author DataSave Development Team  
 * @created 2025-09-01
 * @description دریافت لیست فرم‌های مخصوص کاربر
 */

header('Content-Type: application/json; charset=utf-8');

// import اجزای مورد نیاز
require_once '../../config/cors.php';
require_once '../../classes/ApiResponse.php';
require_once '../../classes/Logger.php';
require_once '../../classes/Database/Form.php';

// بررسی method درخواست
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    ApiResponse::error('متد درخواست باید GET باشد', 405);
    exit;
}

try {
    $logger = new Logger();
    $formModel = new Form();
    
    // دریافت پارامترهای URL
    $userId = $_GET['user_id'] ?? null;
    $page = max(1, (int)($_GET['page'] ?? 1));
    $limit = max(1, min(100, (int)($_GET['limit'] ?? 10))); // حداکثر 100 رکورد
    $status = $_GET['status'] ?? 'all';
    $search = $_GET['search'] ?? '';
    
    // اعتبارسنجی user_id
    if (empty($userId) || !is_numeric($userId)) {
        $logger->warning('USER_FORMS_API', 'شناسه کاربر نامعتبر', [
            'user_id' => $userId
        ]);
        ApiResponse::error('شناسه کاربر الزامی و باید عدد باشد', 400);
        exit;
    }
    
    $userId = (int)$userId;
    
    // محاسبه offset برای pagination
    $offset = ($page - 1) * $limit;
    
    // آماده‌سازی فیلترها
    $filters = [];
    if ($status !== 'all' && in_array($status, ['draft', 'published', 'archived'])) {
        $filters['status'] = $status;
    }
    if ($search) {
        $filters['search'] = $search;
    }
    
    $logger->info('USER_FORMS_API', 'درخواست دریافت فرم‌های کاربر', [
        'user_id' => $userId,
        'page' => $page,
        'limit' => $limit,
        'status' => $status,
        'search' => $search
    ]);
    
    // دریافت فرم‌های کاربر
    $forms = $formModel->getUserForms($userId, $filters, $limit, $offset);
    
    // محاسبه تعداد کل (برای الان همین تعداد موجود - بعداً باید count جداگانه اضافه کنیم)
    $totalCount = count($forms);
    
    // آماده‌سازی response با pagination info
    $responseData = [
        'forms' => $forms,
        'pagination' => [
            'current_page' => $page,
            'per_page' => $limit,
            'total_count' => $totalCount,
            'total_pages' => max(1, ceil($totalCount / $limit)),
            'has_next' => ($page * $limit) < $totalCount,
            'has_prev' => $page > 1
        ],
        'filters' => [
            'status' => $status,
            'search' => $search
        ]
    ];
    
    $logger->info('USER_FORMS_API', 'فرم‌های کاربر با موفقیت دریافت شد', [
        'user_id' => $userId,
        'forms_count' => count($forms),
        'total_count' => $totalCount
    ]);
    
    // ارسال پاسخ با فرمت صحیح ApiResponse
    ApiResponse::success($responseData, 'فرم‌های کاربر با موفقیت دریافت شد');
    
} catch (Exception $e) {
    $logger = new Logger();
    $logger->error('USER_FORMS_API', 'خطای سیستمی در دریافت فرم‌های کاربر', [
        'error' => $e->getMessage(),
        'trace' => $e->getTraceAsString()
    ]);
    
    ApiResponse::error('خطای سیستمی در دریافت فرم‌ها', 500);
}
?>
