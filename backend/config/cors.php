<?php
/**
 * تنظیمات CORS برای Flutter Web - Development Mode
 * تنها این فایل CORS headers تنظیم می‌کند
 */

// پاک کردن header های قبلی
if (!headers_sent()) {
    // تنظیمات CORS - فقط یکبار
    header('Access-Control-Allow-Origin: *');
    header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
    header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With, Origin, Accept');
    header('Access-Control-Allow-Credentials: false');
    header('Content-Type: application/json; charset=utf-8');
    
    // Cache control برای API
    header('Cache-Control: no-cache, must-revalidate');
    header('Expires: Thu, 01 Jan 1970 00:00:00 GMT');
}

// پاسخ به درخواست‌های OPTIONS (Preflight)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}
?>
