<?php
require_once '../../config/cors.php';
require_once '../../config/database.php';
require_once '../../classes/ApiResponse.php';

try {
    $dbTest = Database::testConnection();
    
    $systemInfo = [
        'php_version' => phpversion(),
        'server_time' => date('Y-m-d H:i:s'),
        'memory_usage' => memory_get_usage(true),
        'memory_limit' => ini_get('memory_limit'),
        'database' => $dbTest
    ];
    
    ApiResponse::success($systemInfo, 'وضعیت سیستم');
    
} catch (Exception $e) {
    ApiResponse::serverError('خطا در دریافت وضعیت سیستم');
}
?>
