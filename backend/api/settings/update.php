<?php
require_once '../../config/cors.php';
require_once '../../config/database.php';
require_once '../../classes/ApiResponse.php';
require_once '../../classes/Logger.php';

try {
    // دریافت داده‌های JSON
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!$input || !isset($input['setting_key']) || !isset($input['setting_value'])) {
        ApiResponse::error('داده‌های ناقص ارسال شده', 400);
    }
    
    $logger = new Logger();
    $logger->info('API', 'درخواست بروزرسانی تنظیمات: ' . $input['setting_key']);
    
    $db = Database::getConnection();
    
    // بررسی وجود تنظیمات
    $checkSql = "SELECT id FROM system_settings WHERE setting_key = :key";
    $checkStmt = $db->prepare($checkSql);
    $checkStmt->execute(['key' => $input['setting_key']]);
    
    if ($checkStmt->rowCount() > 0) {
        // بروزرسانی تنظیمات موجود
        $sql = "UPDATE system_settings SET setting_value = :value, updated_at = NOW() WHERE setting_key = :key";
        $stmt = $db->prepare($sql);
        $result = $stmt->execute([
            'key' => $input['setting_key'],
            'value' => $input['setting_value']
        ]);
        
        if ($result) {
            ApiResponse::success(null, 'تنظیمات با موفقیت بروزرسانی شد');
        } else {
            ApiResponse::error('خطا در بروزرسانی تنظیمات');
        }
    } else {
        ApiResponse::notFound('تنظیمات یافت نشد');
    }
    
} catch (Exception $e) {
    $logger->error('API', 'خطا در بروزرسانی تنظیمات: ' . $e->getMessage());
    ApiResponse::serverError('خطا در بروزرسانی تنظیمات');
}
?>
