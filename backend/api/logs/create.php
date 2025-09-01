<?php
require_once '../../config/cors.php';
require_once '../../config/database.php';
require_once '../../classes/ApiResponse.php';
require_once '../../classes/Logger.php';

try {
    // دریافت داده‌های JSON
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!$input || !isset($input['level']) || !isset($input['category']) || !isset($input['message'])) {
        ApiResponse::error('داده‌های ناقص ارسال شده', 400);
    }
    
    $logger = new Logger();
    $result = $logger->log(
        $input['level'],
        $input['category'],
        $input['message'],
        $input['context'] ?? null
    );
    
    if ($result) {
        ApiResponse::success(null, 'لاگ با موفقیت ثبت شد');
    } else {
        ApiResponse::error('خطا در ثبت لاگ');
    }
    
} catch (Exception $e) {
    ApiResponse::serverError('خطای سرور در ثبت لاگ');
}
?>
