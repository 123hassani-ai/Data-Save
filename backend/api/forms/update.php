<?php
/**
 * API بروزرسانی فرم - Update Form API
 * 
 * @version 5.2.0
 * @author DataSave Development Team  
 * @created 2025-09-01
 * @description بروزرسانی فرم موجود در Form Builder
 */

header('Content-Type: application/json; charset=utf-8');

// import اجزای مورد نیاز
require_once '../../config/cors.php';
require_once '../../classes/ApiResponse.php';
require_once '../../classes/Logger.php';
require_once '../../classes/Database/Form.php';

// بررسی method درخواست
if ($_SERVER['REQUEST_METHOD'] !== 'PUT') {
    ApiResponse::error('متد درخواست باید PUT باشد', 405);
    exit;
}

try {
    $logger = new Logger();
    $formModel = new Form();
    
    // دریافت و اعتبارسنجی JSON input
    $input = file_get_contents('php://input');
    $data = json_decode($input, true);
    
    if (json_last_error() !== JSON_ERROR_NONE) {
        $logger->warning('FORM_UPDATE_API', 'JSON نامعتبر دریافت شد', [
            'json_error' => json_last_error_msg(),
            'input_length' => strlen($input)
        ]);
        ApiResponse::error('فرمت JSON نامعتبر است', 400);
        exit;
    }
    
    // اعتبارسنجی شناسه فرم و کاربر
    $formId = $data['form_id'] ?? null;
    $userId = $data['user_id'] ?? null;
    
    if (empty($formId) || !is_numeric($formId)) {
        ApiResponse::error('شناسه فرم الزامی و باید عدد باشد', 400);
        exit;
    }
    
    if (empty($userId) || !is_numeric($userId)) {
        ApiResponse::error('شناسه کاربر الزامی و باید عدد باشد', 400);
        exit;
    }
    
    $formId = (int)$formId;
    $userId = (int)$userId;
    
    // بررسی وجود فرم
    $existingForm = $formModel->getFormById($formId);
    if (!$existingForm) {
        $logger->warning('FORM_UPDATE_API', 'فرم موردنظر یافت نشد', [
            'form_id' => $formId
        ]);
        ApiResponse::error('فرم موردنظر یافت نشد', 404);
        exit;
    }
    
    // آماده‌سازی داده‌های بروزرسانی (فقط فیلدهای ارسال شده)
    $updateData = [];
    
    $allowedFields = [
        'persian_title', 'english_title', 'persian_description', 'english_description',
        'form_schema', 'form_config', 'form_settings', 'status', 'is_public',
        'requires_login', 'max_responses', 'expires_at'
    ];
    
    foreach ($allowedFields as $field) {
        if (array_key_exists($field, $data)) {
            $updateData[$field] = $data[$field];
        }
    }
    
    // حداقل یک فیلد باید برای بروزرسانی ارسال شده باشد
    if (empty($updateData)) {
        ApiResponse::error('حداقل یک فیلد برای بروزرسانی ضروری است', 400);
        exit;
    }
    
    // اعتبارسنجی عنوان فارسی (اگر ارسال شده)
    if (isset($updateData['persian_title']) && mb_strlen(trim($updateData['persian_title'])) < 3) {
        ApiResponse::error('عنوان فرم باید حداقل ۳ کاراکتر باشد', 400);
        exit;
    }
    
    $logger->info('FORM_UPDATE_API', 'درخواست بروزرسانی فرم', [
        'form_id' => $formId,
        'update_fields' => array_keys($updateData)
    ]);
    
    // بروزرسانی فرم
    $result = $formModel->updateForm($formId, $updateData, $userId);
    
    if ($result) {
        $logger->info('FORM_UPDATE_API', 'فرم با موفقیت بروزرسانی شد', [
            'form_id' => $formId,
            'user_id' => $userId,
            'updated_fields' => array_keys($updateData)
        ]);
        
        // دریافت اطلاعات بروزرسانی شده فرم
        $updatedForm = $formModel->getFormById($formId);
        
        ApiResponse::success($updatedForm, 'فرم با موفقیت بروزرسانی شد');
        
    } else {
        $logger->error('FORM_UPDATE_API', 'خطا در بروزرسانی فرم', [
            'form_id' => $formId,
            'user_id' => $userId,
            'update_data' => $updateData
        ]);
        
        ApiResponse::error('خطا در بروزرسانی فرم', 500);
    }
    
} catch (Exception $e) {
    $logger = new Logger();
    $logger->error('FORM_UPDATE_API', 'خطای سیستمی در بروزرسانی فرم', [
        'error' => $e->getMessage(),
        'trace' => $e->getTraceAsString()
    ]);
    
    ApiResponse::error('خطای سیستمی در بروزرسانی فرم', 500);
}
?>
