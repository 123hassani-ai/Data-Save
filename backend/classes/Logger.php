<?php
/**
 * سیستم لاگینگ PHP
 */
class Logger {
    private PDO $db;
    
    public function __construct() {
        $this->db = Database::getConnection();
    }
    
    public function log(string $level, string $category, string $message, ?array $context = null): bool {
        try {
            $sql = "INSERT INTO system_logs (log_level, log_category, log_message, log_context, ip_address, user_agent) 
                    VALUES (:level, :category, :message, :context, :ip, :user_agent)";
            
            $stmt = $this->db->prepare($sql);
            return $stmt->execute([
                'level' => strtoupper($level),
                'category' => $category,
                'message' => $message,
                'context' => $context ? json_encode($context, JSON_UNESCAPED_UNICODE) : null,
                'ip' => $_SERVER['REMOTE_ADDR'] ?? 'Unknown',
                'user_agent' => $_SERVER['HTTP_USER_AGENT'] ?? 'Unknown'
            ]);
        } catch (Exception $e) {
            error_log("Logger Error: " . $e->getMessage());
            return false;
        }
    }
    
    public function info(string $category, string $message, ?array $context = null): bool {
        return $this->log('INFO', $category, $message, $context);
    }
    
    public function error(string $category, string $message, ?array $context = null): bool {
        return $this->log('ERROR', $category, $message, $context);
    }
    
    public function warning(string $category, string $message, ?array $context = null): bool {
        return $this->log('WARNING', $category, $message, $context);
    }
    
    public function getRecentLogs(int $limit = 20): array {
        try {
            $sql = "SELECT * FROM system_logs ORDER BY created_at DESC LIMIT :limit";
            $stmt = $this->db->prepare($sql);
            $stmt->bindValue('limit', $limit, PDO::PARAM_INT);
            $stmt->execute();
            
            return $stmt->fetchAll();
        } catch (Exception $e) {
            error_log("Get Logs Error: " . $e->getMessage());
            return [];
        }
    }
}
?>
