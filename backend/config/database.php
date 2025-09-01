<?php
/**
 * تنظیمات اتصال به پایگاه داده MySQL
 */
class DatabaseConfig {
    public const HOST = 'localhost';
    public const PORT = 3307;
    public const DATABASE = 'datasave_db';
    public const USERNAME = 'root';
    public const PASSWORD = 'Mojtab@123';
    public const CHARSET = 'utf8mb4';
    
    public static function getConnectionString(): string {
        return sprintf(
            "mysql:host=%s;port=%d;dbname=%s;charset=%s",
            self::HOST,
            self::PORT,
            self::DATABASE,
            self::CHARSET
        );
    }
}

/**
 * کلاس مدیریت دیتابیس
 */
class Database {
    private static ?PDO $connection = null;
    
    public static function getConnection(): PDO {
        if (self::$connection === null) {
            try {
                self::$connection = new PDO(
                    DatabaseConfig::getConnectionString(),
                    DatabaseConfig::USERNAME,
                    DatabaseConfig::PASSWORD,
                    [
                        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                        PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8mb4 COLLATE utf8mb4_persian_ci"
                    ]
                );
            } catch (PDOException $e) {
                throw new Exception("خطا در اتصال دیتابیس: " . $e->getMessage());
            }
        }
        
        return self::$connection;
    }
    
    public static function testConnection(): array {
        try {
            $pdo = self::getConnection();
            $stmt = $pdo->query("SELECT 1 as test, NOW() as server_time");
            $result = $stmt->fetch();
            
            return [
                'success' => true,
                'message' => 'اتصال دیتابیس برقرار است',
                'server_time' => $result['server_time'],
                'charset' => 'utf8mb4_persian_ci'
            ];
        } catch (Exception $e) {
            return [
                'success' => false,
                'message' => 'خطا در اتصال: ' . $e->getMessage()
            ];
        }
    }
}
?>
