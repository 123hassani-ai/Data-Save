<?php
require_once '../../config/cors.php';
require_once '../../config/database.php';
require_once '../../classes/ApiResponse.php';

try {
    $db = Database::getConnection();
    
    // پاکسازی لاگ‌های قدیمی (نگهداری ۱۰۰ لاگ آخر)
    $sql = "DELETE FROM system_logs WHERE log_id NOT IN (
        SELECT log_id FROM (
            SELECT log_id FROM system_logs ORDER BY created_at DESC LIMIT 100
        ) as keep_logs
    )";
    
    $stmt = $db->prepare($sql);
    $result = $stmt->execute();
    $deletedCount = $stmt->rowCount();
    
    if ($result) {
        ApiResponse::success(['deleted_count' => $deletedCount], 'لاگ‌های قدیمی پاکسازی شدند');
    } else {
        ApiResponse::error('خطا در پاکسازی لاگ‌ها');
    }
    
} catch (Exception $e) {
    ApiResponse::serverError('خطای سرور در پاکسازی لاگ‌ها');
}
?>
