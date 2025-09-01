<?php
require_once '../../config/cors.php';
require_once '../../config/database.php';
require_once '../../classes/ApiResponse.php';
require_once '../../classes/Logger.php';

// تنظیم encoding
header('Content-Type: application/json; charset=utf-8');
ini_set('default_charset', 'utf-8');
mb_internal_encoding('UTF-8');

try {
    // دریافت داده‌های JSON
    $raw_input = file_get_contents('php://input');
    
    // نوشتن برای دیباگ
    error_log("Raw input: " . $raw_input);
    
    if (empty($raw_input)) {
        ApiResponse::error('هیچ داده‌ای ارسال نشده', 400);
        exit;
    }
    
    $input = json_decode($raw_input, true);
    
    // نوشتن برای دیباگ
    error_log("Decoded input: " . print_r($input, true));
    
    if (json_last_error() !== JSON_ERROR_NONE) {
        ApiResponse::error('خطا در پردازش JSON: ' . json_last_error_msg(), 400);
        exit;
    }
    
    if (!$input || !isset($input['level']) || !isset($input['category']) || !isset($input['message'])) {
        $missing = [];
        if (!isset($input['level'])) $missing[] = 'level';
        if (!isset($input['category'])) $missing[] = 'category';
        if (!isset($input['message'])) $missing[] = 'message';
        
        error_log("Missing fields. Available fields: " . print_r(array_keys($input ?: []), true));
        ApiResponse::error('فیلدهای ضروری موجود نیست: ' . implode(', ', $missing), 400);
        exit;
    }
    
    $logger = new Logger();
    $result = $logger->log(
        trim($input['level']),
        trim($input['category']),
        trim($input['message']),
        isset($input['context']) ? $input['context'] : null
    );
    
    if ($result) {
        ApiResponse::success(null, 'لاگ با موفقیت ثبت شد');
    } else {
        ApiResponse::error('خطا در ثبت لاگ در پایگاه داده');
    }
    
} catch (Exception $e) {
    error_log("Log API Error: " . $e->getMessage());
    ApiResponse::serverError('خطای سرور در ثبت لاگ: ' . $e->getMessage());
}
?>
