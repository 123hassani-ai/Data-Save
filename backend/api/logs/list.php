<?php
require_once '../../config/cors.php';
require_once '../../config/database.php';
require_once '../../classes/ApiResponse.php';
require_once '../../classes/Logger.php';

try {
    $logger = new Logger();
    $limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 20;
    
    $logs = $logger->getRecentLogs($limit);
    
    ApiResponse::success($logs, 'لیست لاگ‌ها با موفقیت بارگذاری شد');
    
} catch (Exception $e) {
    ApiResponse::serverError('خطا در دریافت لاگ‌ها');
}
?>
