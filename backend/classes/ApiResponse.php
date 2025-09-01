<?php
/**
 * کلاس استاندارد پاسخ‌های API
 */
class ApiResponse {
    public static function success($data = null, string $message = 'موفق'): void {
        http_response_code(200);
        echo json_encode([
            'success' => true,
            'message' => $message,
            'data' => $data,
            'timestamp' => date('Y-m-d H:i:s')
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }
    
    public static function error(string $message, int $code = 400, $details = null): void {
        http_response_code($code);
        echo json_encode([
            'success' => false,
            'message' => $message,
            'details' => $details,
            'timestamp' => date('Y-m-d H:i:s')
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }
    
    public static function notFound(string $message = 'یافت نشد'): void {
        self::error($message, 404);
    }
    
    public static function serverError(string $message = 'خطای سرور'): void {
        self::error($message, 500);
    }
}
?>
