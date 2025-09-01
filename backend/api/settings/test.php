<?php
require_once '../../config/cors.php';
require_once '../../config/database.php';
require_once '../../classes/ApiResponse.php';

try {
    $dbTest = Database::testConnection();
    ApiResponse::success($dbTest, 'تست اتصال دیتابیس انجام شد');
    
} catch (Exception $e) {
    ApiResponse::serverError('خطا در تست اتصال دیتابیس');
}
?>
