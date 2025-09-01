<?php
/**
 * API ایجاد فرم جدید - Create New Form API
 * 
 * @version 5.2.0
 * @author DataSave Development Team  
 * @created 2025-09-01
 * @description Form Builder ایجاد فرم جدید
 */

header('Content-Type: application/json; charset=utf-8');

// import اجزای مورد نیاز
require_once '../../config/cors.php';
require_once '../../classes/ApiResponse.php';
require_once '../../classes/Logger.php';
require_once '../../classes/Database/Form.php';

// بررسی method درخواست
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    ApiResponse::error('متد درخواست باید POST باشد', 405);
    exit;
}

try {
    $logger = new Logger();
    $formModel = new Form();
    
    // دریافت و اعتبارسنجی JSON input
    $input = file_get_contents('php://input');
    $data = json_decode($input, true);
    
    if (json_last_error() !== JSON_ERROR_NONE) {
        $logger->warning('FORM_CREATE_API', 'JSON نامعتبر دریافت شد', [
            'json_error' => json_last_error_msg(),
            'input_length' => strlen($input)
        ]);
        ApiResponse::error('فرمت JSON نامعتبر است', 400);
        exit;
    }
    
    // اعتبارسنجی فیلدهای الزامی
    $requiredFields = ['persian_title', 'user_id'];
    $missingFields = [];
    
    foreach ($requiredFields as $field) {
        if (empty($data[$field])) {
            $missingFields[] = $field;
        }
    }
    
    if (!empty($missingFields)) {
        $logger->warning('FORM_CREATE_API', 'فیلدهای الزامی مفقود', [
            'missing_fields' => $missingFields
        ]);
        ApiResponse::error('فیلدهای الزامی مفقود: ' . implode(', ', $missingFields), 400);
        exit;
    }
    
    // اعتبارسنجی عنوان فارسی
    if (mb_strlen(trim($data['persian_title'])) < 3) {
        ApiResponse::error('عنوان فرم باید حداقل ۳ کاراکتر باشد', 400);
        exit;
    }
    
    // آماده‌سازی داده‌های فرم
    $formData = [
        'user_id' => (int)$data['user_id'],
        'persian_title' => trim($data['persian_title']),
        'english_title' => $data['english_title'] ?? null,
        'persian_description' => $data['persian_description'] ?? null,
        'english_description' => $data['english_description'] ?? null,
        'form_schema' => $data['form_schema'] ?? null,
        'form_config' => $data['form_config'] ?? [
            'theme' => 'default',
            'direction' => 'rtl',
            'language' => 'fa'
        ],
        'form_settings' => $data['form_settings'] ?? [
            'allow_multiple_responses' => true,
            'require_email' => false,
            'auto_save' => true
        ],
        'status' => $data['status'] ?? 'draft'
    ];
    
    // ایجاد فرم
    $result = $formModel->createForm($formData);
    
    if ($result['success']) {
        $logger->info('FORM_CREATE_API', 'فرم جدید با موفقیت ایجاد شد', [
            'form_id' => $result['data']['id'],
            'title' => $formData['persian_title'],
            'user_id' => $formData['user_id']
        ]);
        
        ApiResponse::success('فرم با موفقیت ایجاد شد', $result['data']);
    } else {
        $logger->error('FORM_CREATE_API', 'خطا در ایجاد فرم', [
            'error' => $result['message'],
            'form_data' => $formData
        ]);
        
        ApiResponse::error($result['message'], 500);
    }
    
} catch (Exception $e) {
    $logger = new Logger();
    $logger->error('FORM_CREATE_API', 'خطای سیستمی در ایجاد فرم', [
        'error' => $e->getMessage(),
        'trace' => $e->getTraceAsString()
    ]);
    
    ApiResponse::error('خطای سیستمی در ایجاد فرم', 500);
}
?>
