<?php
/**
 * API حذف فرم - Delete Form API
 * 
 * @version 5.2.0
 * @author DataSave Development Team  
 * @created 2025-09-01
 * @description حذف نرم (soft delete) فرم
 */

header('Content-Type: application/json; charset=utf-8');

// import اجزای مورد نیاز
require_once '../../config/cors.php';
require_once '../../classes/ApiResponse.php';
require_once '../../classes/Logger.php';
require_once '../../classes/Database/Form.php';

// بررسی method درخواست
if ($_SERVER['REQUEST_METHOD'] !== 'DELETE') {
    ApiResponse::error('متد درخواست باید DELETE باشد', 405);
    exit;
}

try {
    $logger = new Logger();
    $formModel = new Form();
    
    // دریافت شناسه فرم از URL
    $formId = $_GET['form_id'] ?? null;
    $userId = $_GET['user_id'] ?? null;
    
    // اعتبارسنجی شناسه فرم
    if (empty($formId) || !is_numeric($formId)) {
        ApiResponse::error('شناسه فرم الزامی و باید عدد باشد', 400);
        exit;
    }
    
    // اعتبارسنجی شناسه کاربر
    if (empty($userId) || !is_numeric($userId)) {
        ApiResponse::error('شناسه کاربر الزامی و باید عدد باشد', 400);
        exit;
    }
    
    $formId = (int)$formId;
    $userId = (int)$userId;
    
    // بررسی وجود فرم
    $existingForm = $formModel->getFormById($formId);
    if (!$existingForm) {
        $logger->warning('FORM_DELETE_API', 'فرم موردنظر یافت نشد', [
            'form_id' => $formId,
            'user_id' => $userId
        ]);
        ApiResponse::error('فرم موردنظر یافت نشد', 404);
        exit;
    }
    
    // بررسی مالکیت فرم
    if ($existingForm['user_id'] != $userId) {
        $logger->warning('FORM_DELETE_API', 'عدم مجوز حذف فرم', [
            'form_id' => $formId,
            'request_user_id' => $userId,
            'form_owner_id' => $existingForm['user_id']
        ]);
        ApiResponse::error('شما مجوز حذف این فرم را ندارید', 403);
        exit;
    }
    
    $logger->info('FORM_DELETE_API', 'درخواست حذف فرم', [
        'form_id' => $formId,
        'user_id' => $userId,
        'form_title' => $existingForm['persian_title'] ?? 'بدون عنوان'
    ]);
    
    // حذف نرم فرم
    $result = $formModel->softDeleteForm($formId, $userId);
    
    if ($result) {
        $logger->info('FORM_DELETE_API', 'فرم با موفقیت حذف شد', [
            'form_id' => $formId,
            'user_id' => $userId
        ]);
        
        ApiResponse::success([
            'form_id' => $formId,
            'deleted' => true
        ], 'فرم با موفقیت حذف شد');
        
    } else {
        $logger->error('FORM_DELETE_API', 'خطا در حذف فرم', [
            'form_id' => $formId,
            'user_id' => $userId
        ]);
        
        ApiResponse::error('خطا در حذف فرم', 500);
    }
    
} catch (Exception $e) {
    $logger = new Logger();
    $logger->error('FORM_DELETE_API', 'خطای سیستمی در حذف فرم', [
        'error' => $e->getMessage(),
        'trace' => $e->getTraceAsString()
    ]);
    
    ApiResponse::error('خطای سیستمی در حذف فرم', 500);
}
?>
