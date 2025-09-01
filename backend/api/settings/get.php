<?php
require_once '../../config/cors.php';
require_once '../../config/database.php';
require_once '../../classes/ApiResponse.php';
require_once '../../classes/Logger.php';

try {
    $logger = new Logger();
    $logger->info('API', 'درخواست دریافت تنظیمات');
    
    $db = Database::getConnection();
    $sql = "SELECT * FROM system_settings ORDER BY setting_key";
    $stmt = $db->query($sql);
    $settings = $stmt->fetchAll();
    
    // رمزگشایی فیلدهای encrypted (در صورت نیاز)
    foreach ($settings as &$setting) {
        if ($setting['setting_type'] === 'encrypted' && !empty($setting['setting_value'])) {
            $setting['setting_value'] = '***مخفی***'; // عدم نمایش مقادیر حساس
        }
    }
    
    ApiResponse::success($settings, 'تنظیمات با موفقیت بارگذاری شد');
    
} catch (Exception $e) {
    $logger->error('API', 'خطا در دریافت تنظیمات: ' . $e->getMessage());
    ApiResponse::serverError('خطا در دریافت تنظیمات');
}
?>
