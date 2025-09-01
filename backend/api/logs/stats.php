<?php
require_once '../../config/cors.php';
require_once '../../config/database.php';
require_once '../../classes/ApiResponse.php';

try {
    $db = Database::getConnection();
    
    // کل لاگ‌ها
    $totalQuery = "SELECT COUNT(*) as total FROM system_logs";
    $totalStmt = $db->query($totalQuery);
    $totalLogs = $totalStmt->fetch()['total'];
    
    // تعداد خطاها
    $errorQuery = "SELECT COUNT(*) as errors FROM system_logs WHERE log_level = 'ERROR'";
    $errorStmt = $db->query($errorQuery);
    $errorLogs = $errorStmt->fetch()['errors'];
    
    // تعداد هشدارها
    $warningQuery = "SELECT COUNT(*) as warnings FROM system_logs WHERE log_level = 'WARNING'";
    $warningStmt = $db->query($warningQuery);
    $warningLogs = $warningStmt->fetch()['warnings'];
    
    // تعداد اطلاعات
    $infoQuery = "SELECT COUNT(*) as info FROM system_logs WHERE log_level = 'INFO'";
    $infoStmt = $db->query($infoQuery);
    $infoLogs = $infoStmt->fetch()['info'];
    
    // لاگ‌های امروز
    $todayQuery = "SELECT COUNT(*) as today FROM system_logs WHERE DATE(created_at) = CURDATE()";
    $todayStmt = $db->query($todayQuery);
    $todayLogs = $todayStmt->fetch()['today'];
    
    $stats = [
        'total_logs' => (int)$totalLogs,
        'error_logs' => (int)$errorLogs,
        'warning_logs' => (int)$warningLogs,
        'info_logs' => (int)$infoLogs,
        'today_logs' => (int)$todayLogs,
    ];
    
    ApiResponse::success($stats, 'آمار لاگ‌ها با موفقیت بارگذاری شد');
    
} catch (Exception $e) {
    ApiResponse::serverError('خطا در دریافت آمار لاگ‌ها: ' . $e->getMessage());
}
?>
