# نحوه ارتباط با دیتابیس - Database Integration

## 📊 Document Information
- **Created:** 2025-09-01
- **Last Updated:** 2025-09-01
- **Version:** 1.0
- **Maintainer:** DataSave Development Team
- **Related Files:** `/backend/config/database.php`, `/database_setup.sql`, `/backend/classes/`

## 🎯 Overview
راهنمای کامل ارتباط با دیتابیس MySQL در پروژه DataSave شامل تنظیمات اتصال، ORM pattern، query optimization، و مدیریت transactions با پشتیبانی کامل فارسی.

## 📋 Table of Contents
- [Database Configuration](#database-configuration)
- [Connection Management](#connection-management)
- [Persian Character Support](#persian-character-support)
- [Query Builder Pattern](#query-builder-pattern)
- [Transaction Management](#transaction-management)
- [Error Handling](#error-handling)
- [Performance Optimization](#performance-optimization)
- [Security Best Practices](#security-best-practices)

## ⚙️ Database Configuration

### Connection Settings
```php
// backend/config/database.php
class Database {
    // XAMPP MySQL Configuration (طبق دستورالعمل‌ها)
    private static $host = 'localhost';
    private static $port = '3307';  // XAMPP MySQL port
    private static $database = 'datasave';
    private static $username = 'root';
    private static $password = 'Mojtab@123';  // از roles.instructions.md
    private static $charset = 'utf8mb4';
    private static $collation = 'utf8mb4_persian_ci';
    
    // Connection options for Persian support
    private static $options = [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
        PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8mb4 COLLATE utf8mb4_persian_ci",
        PDO::MYSQL_ATTR_USE_BUFFERED_QUERY => true,
    ];
```

### DSN Configuration
```php
    /**
     * ساخت DSN string برای اتصال MySQL
     * @return string
     */
    private static function getDSN(): string {
        return sprintf(
            'mysql:host=%s;port=%s;dbname=%s;charset=%s',
            self::$host,
            self::$port,
            self::$database,
            self::$charset
        );
    }
```

---

## 🔗 Connection Management

### Singleton Connection Pattern
```php
class Database {
    private static $connection = null;
    private static $logger = null;

    /**
     * دریافت اتصال یکتا به دیتابیس
     * @return PDO
     * @throws PDOException
     */
    public static function getConnection(): PDO {
        if (self::$connection === null) {
            try {
                self::initializeLogger();
                
                self::$logger->info('Database', 'شروع اتصال به دیتابیس MySQL');
                
                self::$connection = new PDO(
                    self::getDSN(),
                    self::$username,
                    self::$password,
                    self::$options
                );
                
                // تنظیم charset و collation برای Persian
                self::$connection->exec("SET charset utf8mb4");
                self::$connection->exec("SET collation_connection = utf8mb4_persian_ci");
                
                self::$logger->info('Database', 'اتصال به دیتابیس با موفقیت برقرار شد');
                
                return self::$connection;
                
            } catch (PDOException $e) {
                self::$logger->error('Database', 'خطا در اتصال به دیتابیس: ' . $e->getMessage());
                throw new PDOException('Database connection failed: ' . $e->getMessage());
            }
        }
        
        return self::$connection;
    }

    /**
     * تست اتصال دیتابیس
     * @return bool
     */
    public static function testConnection(): bool {
        try {
            $pdo = self::getConnection();
            $stmt = $pdo->query('SELECT 1');
            return $stmt !== false;
        } catch (Exception $e) {
            return false;
        }
    }

    /**
     * بستن اتصال دیتابیس
     */
    public static function closeConnection(): void {
        self::$connection = null;
        if (self::$logger) {
            self::$logger->info('Database', 'اتصال دیتابیس بسته شد');
        }
    }

    /**
     * راه‌اندازی Logger
     */
    private static function initializeLogger(): void {
        if (self::$logger === null) {
            require_once __DIR__ . '/../classes/Logger.php';
            self::$logger = new Logger();
        }
    }
}
```

### Connection Pool Management
```php
class DatabasePool {
    private static $pool = [];
    private static $maxConnections = 10;
    private static $currentConnections = 0;

    /**
     * دریافت اتصال از Pool
     * @return PDO
     */
    public static function getConnection(): PDO {
        if (self::$currentConnections < self::$maxConnections) {
            $connection = Database::getConnection();
            self::$pool[] = $connection;
            self::$currentConnections++;
            return $connection;
        }
        
        // استفاده مجدد از اتصال موجود
        return self::$pool[array_rand(self::$pool)];
    }

    /**
     * آزادسازی اتصال
     * @param PDO $connection
     */
    public static function releaseConnection(PDO $connection): void {
        $key = array_search($connection, self::$pool, true);
        if ($key !== false) {
            unset(self::$pool[$key]);
            self::$currentConnections--;
        }
    }
}
```

---

## 🇮🇷 Persian Character Support

### Character Set Configuration
```sql
-- تنظیم charset دیتابیس برای پشتیبانی فارسی
ALTER DATABASE datasave CHARACTER SET utf8mb4 COLLATE utf8mb4_persian_ci;

-- تنظیم charset جداول
ALTER TABLE system_settings CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_persian_ci;
ALTER TABLE system_logs CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_persian_ci;

-- بررسی charset فعلی
SHOW VARIABLES LIKE 'character_set%';
SHOW VARIABLES LIKE 'collation%';
```

### PHP Persian Text Handling
```php
class PersianTextHandler {
    
    /**
     * پاک‌سازی متن فارسی قبل از ذخیره
     * @param string $text
     * @return string
     */
    public static function sanitizePersianText(string $text): string {
        // حذف کاراکترهای اضافی
        $text = trim($text);
        
        // تبدیل اعداد انگلیسی به فارسی
        $text = self::convertToPersianNumbers($text);
        
        // تنظیم فاصله‌گذاری فارسی
        $text = self::fixPersianSpacing($text);
        
        return $text;
    }

    /**
     * تبدیل اعداد انگلیسی به فارسی
     * @param string $text
     * @return string
     */
    public static function convertToPersianNumbers(string $text): string {
        $english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
        $persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
        
        return str_replace($english, $persian, $text);
    }

    /**
     * تنظیم فاصله‌گذاری فارسی
     * @param string $text
     * @return string
     */
    public static function fixPersianSpacing(string $text): string {
        // حذف فاصله‌های اضافی
        $text = preg_replace('/\s+/', ' ', $text);
        
        // تنظیم فاصله قبل و بعد از علائم نگارشی
        $text = preg_replace('/\s*([،؛؟!])\s*/', '$1 ', $text);
        
        return trim($text);
    }

    /**
     * اعتبارسنجی متن فارسی
     * @param string $text
     * @return bool
     */
    public static function isPersianText(string $text): bool {
        // بررسی وجود حروف فارسی
        return preg_match('/[\x{0600}-\x{06FF}]/u', $text) > 0;
    }
}
```

---

## 🏗️ Query Builder Pattern

### BaseModel Class
```php
abstract class BaseModel {
    protected $db;
    protected $table;
    protected $primaryKey = 'id';
    protected $logger;

    public function __construct() {
        $this->db = Database::getConnection();
        $this->logger = new Logger();
    }

    /**
     * دریافت همه رکوردها
     * @param array $conditions
     * @param array $orderBy
     * @param int|null $limit
     * @return array
     */
    public function getAll(array $conditions = [], array $orderBy = [], ?int $limit = null): array {
        try {
            $sql = "SELECT * FROM `{$this->table}`";
            $params = [];

            // اضافه کردن شرایط WHERE
            if (!empty($conditions)) {
                $whereClauses = [];
                foreach ($conditions as $field => $value) {
                    $whereClauses[] = "`{$field}` = :{$field}";
                    $params[$field] = $value;
                }
                $sql .= " WHERE " . implode(" AND ", $whereClauses);
            }

            // اضافه کردن ORDER BY
            if (!empty($orderBy)) {
                $orderClauses = [];
                foreach ($orderBy as $field => $direction) {
                    $orderClauses[] = "`{$field}` {$direction}";
                }
                $sql .= " ORDER BY " . implode(", ", $orderClauses);
            }

            // اضافه کردن LIMIT
            if ($limit !== null) {
                $sql .= " LIMIT :limit";
                $params['limit'] = $limit;
            }

            $this->logger->info('Database', "اجرای Query: {$sql}");

            $stmt = $this->db->prepare($sql);
            
            // Bind parameters
            foreach ($params as $key => $value) {
                $stmt->bindValue(":{$key}", $value, $this->getPDOType($value));
            }
            
            $stmt->execute();
            $result = $stmt->fetchAll();

            $this->logger->info('Database', "تعداد رکوردهای یافت شده: " . count($result));
            
            return $result;

        } catch (PDOException $e) {
            $this->logger->error('Database', "خطا در Query: " . $e->getMessage());
            throw $e;
        }
    }

    /**
     * ایجاد رکورد جدید
     * @param array $data
     * @return int|false
     */
    public function create(array $data) {
        try {
            // پاک‌سازی داده‌های فارسی
            $data = $this->sanitizeData($data);

            $fields = array_keys($data);
            $placeholders = array_map(fn($field) => ":{$field}", $fields);

            $sql = "INSERT INTO `{$this->table}` (`" . 
                   implode("`, `", $fields) . 
                   "`) VALUES (" . 
                   implode(", ", $placeholders) . 
                   ")";

            $this->logger->info('Database', "ایجاد رکورد جدید در جدول {$this->table}");

            $stmt = $this->db->prepare($sql);
            
            foreach ($data as $key => $value) {
                $stmt->bindValue(":{$key}", $value, $this->getPDOType($value));
            }
            
            $stmt->execute();
            $insertId = $this->db->lastInsertId();

            $this->logger->info('Database', "رکورد جدید با ID {$insertId} ایجاد شد");
            
            return $insertId;

        } catch (PDOException $e) {
            $this->logger->error('Database', "خطا در ایجاد رکورد: " . $e->getMessage());
            return false;
        }
    }

    /**
     * بروزرسانی رکورد
     * @param int $id
     * @param array $data
     * @return bool
     */
    public function update(int $id, array $data): bool {
        try {
            // پاک‌سازی داده‌های فارسی
            $data = $this->sanitizeData($data);

            $setClauses = [];
            foreach (array_keys($data) as $field) {
                $setClauses[] = "`{$field}` = :{$field}";
            }

            $sql = "UPDATE `{$this->table}` SET " . 
                   implode(", ", $setClauses) . 
                   " WHERE `{$this->primaryKey}` = :id";

            $this->logger->info('Database', "بروزرسانی رکورد ID {$id} در جدول {$this->table}");

            $stmt = $this->db->prepare($sql);
            
            foreach ($data as $key => $value) {
                $stmt->bindValue(":{$key}", $value, $this->getPDOType($value));
            }
            $stmt->bindValue(":id", $id, PDO::PARAM_INT);
            
            $result = $stmt->execute();
            $affectedRows = $stmt->rowCount();

            $this->logger->info('Database', "تعداد رکوردهای بروزرسانی شده: {$affectedRows}");
            
            return $result && $affectedRows > 0;

        } catch (PDOException $e) {
            $this->logger->error('Database', "خطا در بروزرسانی: " . $e->getMessage());
            return false;
        }
    }

    /**
     * حذف رکورد
     * @param int $id
     * @return bool
     */
    public function delete(int $id): bool {
        try {
            $sql = "DELETE FROM `{$this->table}` WHERE `{$this->primaryKey}` = :id";

            $this->logger->info('Database', "حذف رکورد ID {$id} از جدول {$this->table}");

            $stmt = $this->db->prepare($sql);
            $stmt->bindValue(":id", $id, PDO::PARAM_INT);
            
            $result = $stmt->execute();
            $affectedRows = $stmt->rowCount();

            $this->logger->info('Database', "تعداد رکوردهای حذف شده: {$affectedRows}");
            
            return $result && $affectedRows > 0;

        } catch (PDOException $e) {
            $this->logger->error('Database', "خطا در حذف: " . $e->getMessage());
            return false;
        }
    }

    /**
     * پاک‌سازی داده‌ها برای ذخیره
     * @param array $data
     * @return array
     */
    protected function sanitizeData(array $data): array {
        $sanitized = [];
        
        foreach ($data as $key => $value) {
            if (is_string($value)) {
                $sanitized[$key] = PersianTextHandler::sanitizePersianText($value);
            } else {
                $sanitized[$key] = $value;
            }
        }
        
        return $sanitized;
    }

    /**
     * تشخیص نوع PDO برای bind
     * @param mixed $value
     * @return int
     */
    protected function getPDOType($value): int {
        switch (true) {
            case is_int($value):
                return PDO::PARAM_INT;
            case is_bool($value):
                return PDO::PARAM_BOOL;
            case is_null($value):
                return PDO::PARAM_NULL;
            default:
                return PDO::PARAM_STR;
        }
    }
}
```

### Specific Model Implementation
```php
class SettingsModel extends BaseModel {
    protected $table = 'system_settings';

    /**
     * دریافت تنظیمات بر اساس کلید
     * @param string $settingKey
     * @return array|null
     */
    public function getByKey(string $settingKey): ?array {
        try {
            $sql = "SELECT * FROM `{$this->table}` WHERE `setting_key` = :setting_key";
            
            $stmt = $this->db->prepare($sql);
            $stmt->bindValue(':setting_key', $settingKey, PDO::PARAM_STR);
            $stmt->execute();
            
            $result = $stmt->fetch();
            return $result ?: null;

        } catch (PDOException $e) {
            $this->logger->error('Database', "خطا در دریافت تنظیمات: " . $e->getMessage());
            return null;
        }
    }

    /**
     * بروزرسانی یا ایجاد تنظیمات
     * @param string $key
     * @param mixed $value
     * @param string $type
     * @param string|null $description
     * @return bool
     */
    public function upsertSetting(string $key, $value, string $type = 'string', ?string $description = null): bool {
        try {
            $existing = $this->getByKey($key);
            
            $data = [
                'setting_value' => is_string($value) ? $value : json_encode($value),
                'setting_type' => $type,
                'updated_at' => date('Y-m-d H:i:s')
            ];

            if ($description !== null) {
                $data['description'] = $description;
            }

            if ($existing) {
                return $this->update($existing['id'], $data);
            } else {
                $data['setting_key'] = $key;
                $data['created_at'] = date('Y-m-d H:i:s');
                return $this->create($data) !== false;
            }

        } catch (Exception $e) {
            $this->logger->error('Database', "خطا در upsert تنظیمات: " . $e->getMessage());
            return false;
        }
    }
}
```

---

## 💰 Transaction Management

### Transaction Wrapper Class
```php
class DatabaseTransaction {
    private $db;
    private $logger;
    private $isActive = false;

    public function __construct() {
        $this->db = Database::getConnection();
        $this->logger = new Logger();
    }

    /**
     * شروع Transaction
     * @return bool
     */
    public function begin(): bool {
        try {
            if ($this->isActive) {
                $this->logger->warning('Database', 'Transaction از قبل فعال است');
                return false;
            }

            $result = $this->db->beginTransaction();
            $this->isActive = true;
            
            $this->logger->info('Database', 'Transaction شروع شد');
            return $result;

        } catch (PDOException $e) {
            $this->logger->error('Database', 'خطا در شروع Transaction: ' . $e->getMessage());
            return false;
        }
    }

    /**
     * تایید Transaction
     * @return bool
     */
    public function commit(): bool {
        try {
            if (!$this->isActive) {
                $this->logger->warning('Database', 'Transaction فعال نیست');
                return false;
            }

            $result = $this->db->commit();
            $this->isActive = false;
            
            $this->logger->info('Database', 'Transaction تایید شد');
            return $result;

        } catch (PDOException $e) {
            $this->logger->error('Database', 'خطا در commit: ' . $e->getMessage());
            return false;
        }
    }

    /**
     * لغو Transaction
     * @return bool
     */
    public function rollback(): bool {
        try {
            if (!$this->isActive) {
                $this->logger->warning('Database', 'Transaction فعال نیست');
                return false;
            }

            $result = $this->db->rollback();
            $this->isActive = false;
            
            $this->logger->info('Database', 'Transaction لغو شد');
            return $result;

        } catch (PDOException $e) {
            $this->logger->error('Database', 'خطا در rollback: ' . $e->getMessage());
            return false;
        }
    }

    /**
     * اجرای عملیات در Transaction
     * @param callable $callback
     * @return mixed
     * @throws Exception
     */
    public function execute(callable $callback) {
        $this->begin();
        
        try {
            $result = $callback($this->db);
            $this->commit();
            return $result;
            
        } catch (Exception $e) {
            $this->rollback();
            $this->logger->error('Database', 'خطا در Transaction: ' . $e->getMessage());
            throw $e;
        }
    }
}
```

### Usage Example
```php
// مثال استفاده از Transaction
$transaction = new DatabaseTransaction();

try {
    $result = $transaction->execute(function($db) {
        // عملیات 1: ایجاد تنظیمات جدید
        $settingsModel = new SettingsModel();
        $settingId = $settingsModel->create([
            'setting_key' => 'new_feature_enabled',
            'setting_value' => 'true',
            'setting_type' => 'boolean'
        ]);

        if (!$settingId) {
            throw new Exception('خطا در ایجاد تنظیمات');
        }

        // عملیات 2: لاگ کردن تغییرات
        $logModel = new LogsModel();
        $logId = $logModel->create([
            'level' => 'info',
            'category' => 'Settings',
            'message' => 'تنظیمات جدید اضافه شد: new_feature_enabled'
        ]);

        if (!$logId) {
            throw new Exception('خطا در ثبت لاگ');
        }

        return ['setting_id' => $settingId, 'log_id' => $logId];
    });

    echo "عملیات با موفقیت انجام شد. Setting ID: {$result['setting_id']}, Log ID: {$result['log_id']}";

} catch (Exception $e) {
    echo "خطا: " . $e->getMessage();
}
```

---

## ❌ Error Handling

### Database Exception Handler
```php
class DatabaseException extends Exception {
    private $sqlState;
    private $errorCode;

    public function __construct(string $message, string $sqlState = '', int $errorCode = 0, Exception $previous = null) {
        parent::__construct($message, 0, $previous);
        $this->sqlState = $sqlState;
        $this->errorCode = $errorCode;
    }

    public function getSQLState(): string {
        return $this->sqlState;
    }

    public function getErrorCode(): int {
        return $this->errorCode;
    }

    /**
     * تبدیل خطای MySQL به پیام فارسی
     * @return string
     */
    public function getPersianMessage(): string {
        switch ($this->errorCode) {
            case 1045:
                return 'خطا در احراز هویت دیتابیس - نام کاربری یا رمز عبور اشتباه است';
            case 1049:
                return 'دیتابیس مورد نظر وجود ندارد';
            case 1062:
                return 'داده تکراری - این مقدار قبلاً وجود دارد';
            case 1054:
                return 'ستون مورد نظر در جدول وجود ندارد';
            case 1146:
                return 'جدول مورد نظر وجود ندارد';
            case 2002:
                return 'عدم اتصال به سرور MySQL - آیا XAMPP فعال است؟';
            default:
                return $this->getMessage();
        }
    }
}

class DatabaseErrorHandler {
    private static $logger;

    /**
     * مدیریت خطاهای PDO
     * @param PDOException $e
     * @return DatabaseException
     */
    public static function handlePDOException(PDOException $e): DatabaseException {
        self::initLogger();
        
        $errorInfo = $e->errorInfo ?? [];
        $sqlState = $errorInfo[0] ?? '';
        $errorCode = $errorInfo[1] ?? 0;
        $message = $e->getMessage();

        // لاگ کردن خطا
        self::$logger->error('Database', "PDO Error: {$message}", [
            'sql_state' => $sqlState,
            'error_code' => $errorCode,
            'trace' => $e->getTraceAsString()
        ]);

        return new DatabaseException($message, $sqlState, $errorCode, $e);
    }

    /**
     * بررسی وضعیت اتصال دیتابیس
     * @return array
     */
    public static function checkDatabaseHealth(): array {
        $health = [
            'connection' => false,
            'charset' => false,
            'tables' => false,
            'permissions' => false,
            'message' => ''
        ];

        try {
            // تست اتصال
            $db = Database::getConnection();
            $health['connection'] = true;

            // بررسی charset
            $stmt = $db->query("SELECT @@character_set_database");
            $charset = $stmt->fetchColumn();
            $health['charset'] = ($charset === 'utf8mb4');

            // بررسی جداول
            $stmt = $db->query("SHOW TABLES LIKE 'system_%'");
            $tables = $stmt->fetchAll();
            $health['tables'] = (count($tables) >= 2); // system_settings, system_logs

            // بررسی مجوزها
            $stmt = $db->query("SELECT USER()");
            $user = $stmt->fetchColumn();
            $health['permissions'] = !empty($user);

            if ($health['connection'] && $health['charset'] && $health['tables'] && $health['permissions']) {
                $health['message'] = 'دیتابیس در وضعیت سالم است';
            } else {
                $health['message'] = 'مشکلاتی در تنظیمات دیتابیس وجود دارد';
            }

        } catch (Exception $e) {
            $health['message'] = 'خطا در اتصال به دیتابیس: ' . $e->getMessage();
        }

        return $health;
    }

    private static function initLogger(): void {
        if (self::$logger === null) {
            self::$logger = new Logger();
        }
    }
}
```

---

## ⚡ Performance Optimization

### Query Optimization
```php
class QueryOptimizer {
    private $db;
    private $logger;

    public function __construct() {
        $this->db = Database::getConnection();
        $this->logger = new Logger();
    }

    /**
     * تحلیل performance query
     * @param string $sql
     * @param array $params
     * @return array
     */
    public function analyzeQuery(string $sql, array $params = []): array {
        try {
            // اجرای EXPLAIN
            $explainSql = "EXPLAIN " . $sql;
            $stmt = $this->db->prepare($explainSql);
            
            foreach ($params as $key => $value) {
                $stmt->bindValue($key, $value);
            }
            
            $stmt->execute();
            $explainResult = $stmt->fetchAll();

            // محاسبه cost
            $totalRows = 0;
            $useIndex = true;
            
            foreach ($explainResult as $row) {
                $totalRows += $row['rows'] ?? 0;
                if (empty($row['key'])) {
                    $useIndex = false;
                }
            }

            return [
                'explain' => $explainResult,
                'total_rows' => $totalRows,
                'uses_index' => $useIndex,
                'performance' => $this->getPerformanceLevel($totalRows, $useIndex)
            ];

        } catch (PDOException $e) {
            $this->logger->error('Database', 'خطا در تحلیل Query: ' . $e->getMessage());
            return ['error' => $e->getMessage()];
        }
    }

    /**
     * تعیین سطح performance
     * @param int $rows
     * @param bool $useIndex
     * @return string
     */
    private function getPerformanceLevel(int $rows, bool $useIndex): string {
        if (!$useIndex) {
            return 'ضعیف - بدون استفاده از Index';
        }
        
        if ($rows > 10000) {
            return 'ضعیف - تعداد رکورد زیاد';
        } elseif ($rows > 1000) {
            return 'متوسط';
        } else {
            return 'عالی';
        }
    }

    /**
     * پیشنهاد بهینه‌سازی
     * @param string $table
     * @param array $whereFields
     * @return array
     */
    public function suggestOptimizations(string $table, array $whereFields): array {
        $suggestions = [];
        
        try {
            // بررسی indexes موجود
            $stmt = $this->db->query("SHOW INDEXES FROM `{$table}`");
            $existingIndexes = $stmt->fetchAll();
            
            $indexedColumns = array_column($existingIndexes, 'Column_name');
            
            // پیشنهاد indexes جدید
            foreach ($whereFields as $field) {
                if (!in_array($field, $indexedColumns)) {
                    $suggestions[] = [
                        'type' => 'index',
                        'message' => "پیشنهاد ایجاد index روی ستون `{$field}`",
                        'sql' => "ALTER TABLE `{$table}` ADD INDEX `idx_{$field}` (`{$field}`)"
                    ];
                }
            }

            // بررسی آمار جدول
            $stmt = $this->db->query("SHOW TABLE STATUS LIKE '{$table}'");
            $tableStats = $stmt->fetch();
            
            if ($tableStats && $tableStats['Data_free'] > 0) {
                $suggestions[] = [
                    'type' => 'maintenance',
                    'message' => 'پیشنهاد بهینه‌سازی جدول برای کاهش فضای اضافی',
                    'sql' => "OPTIMIZE TABLE `{$table}`"
                ];
            }

        } catch (PDOException $e) {
            $this->logger->error('Database', 'خطا در تحلیل بهینه‌سازی: ' . $e->getMessage());
        }

        return $suggestions;
    }
}
```

### Connection Pooling
```php
class OptimizedDatabase extends Database {
    private static $queryCache = [];
    private static $cacheSize = 100;

    /**
     * اجرای Query با Cache
     * @param string $sql
     * @param array $params
     * @param int $cacheTime seconds
     * @return array
     */
    public static function cachedQuery(string $sql, array $params = [], int $cacheTime = 300): array {
        $cacheKey = md5($sql . serialize($params));
        
        // بررسی Cache
        if (isset(self::$queryCache[$cacheKey])) {
            $cached = self::$queryCache[$cacheKey];
            if (time() - $cached['timestamp'] < $cacheTime) {
                return $cached['data'];
            }
        }

        // اجرای Query
        $db = self::getConnection();
        $stmt = $db->prepare($sql);
        
        foreach ($params as $key => $value) {
            $stmt->bindValue($key, $value);
        }
        
        $stmt->execute();
        $result = $stmt->fetchAll();

        // ذخیره در Cache
        self::$queryCache[$cacheKey] = [
            'data' => $result,
            'timestamp' => time()
        ];

        // محدود کردن اندازه Cache
        if (count(self::$queryCache) > self::$cacheSize) {
            array_shift(self::$queryCache);
        }

        return $result;
    }

    /**
     * پاک کردن Cache
     */
    public static function clearCache(): void {
        self::$queryCache = [];
    }
}
```

---

## 🔒 Security Best Practices

### SQL Injection Prevention
```php
class SecureQuery {
    
    /**
     * اجرای Query امن با Prepared Statements
     * @param string $sql
     * @param array $params
     * @return array
     */
    public static function executeSecure(string $sql, array $params = []): array {
        $db = Database::getConnection();
        
        // Whitelist validation برای نام جداول و ستون‌ها
        if (!self::validateSqlStructure($sql)) {
            throw new SecurityException('SQL Structure غیرمجاز شناسایی شد');
        }

        $stmt = $db->prepare($sql);
        
        foreach ($params as $key => $value) {
            // Sanitize کردن مقادیر
            $sanitizedValue = self::sanitizeValue($value);
            $stmt->bindValue($key, $sanitizedValue, self::getPDOType($sanitizedValue));
        }
        
        $stmt->execute();
        return $stmt->fetchAll();
    }

    /**
     * اعتبارسنجی ساختار SQL
     * @param string $sql
     * @return bool
     */
    private static function validateSqlStructure(string $sql): bool {
        // لیست جداول مجاز
        $allowedTables = ['system_settings', 'system_logs', 'users', 'forms', 'form_responses'];
        
        // بررسی نام جداول
        foreach ($allowedTables as $table) {
            if (strpos($sql, $table) !== false) {
                return true;
            }
        }
        
        return false;
    }

    /**
     * پاک‌سازی مقادیر ورودی
     * @param mixed $value
     * @return mixed
     */
    private static function sanitizeValue($value) {
        if (is_string($value)) {
            // حذف کاراکترهای خطرناک
            $value = str_replace(['<script>', '</script>', 'javascript:', 'onload='], '', $value);
            
            // پاک‌سازی HTML tags
            $value = strip_tags($value);
            
            // تنظیم encoding برای فارسی
            $value = mb_convert_encoding($value, 'UTF-8', 'auto');
        }
        
        return $value;
    }

    private static function getPDOType($value): int {
        switch (true) {
            case is_int($value):
                return PDO::PARAM_INT;
            case is_bool($value):
                return PDO::PARAM_BOOL;
            case is_null($value):
                return PDO::PARAM_NULL;
            default:
                return PDO::PARAM_STR;
        }
    }
}

class SecurityException extends Exception {}
```

### Data Encryption
```php
class DataEncryption {
    private static $encryptionKey;

    /**
     * رمزگذاری داده‌های حساس
     * @param string $data
     * @return string
     */
    public static function encrypt(string $data): string {
        $key = self::getEncryptionKey();
        $cipher = 'AES-256-CBC';
        $iv = random_bytes(16);
        
        $encrypted = openssl_encrypt($data, $cipher, $key, OPENSSL_RAW_DATA, $iv);
        return base64_encode($iv . $encrypted);
    }

    /**
     * رمزگشایی داده‌ها
     * @param string $encryptedData
     * @return string|false
     */
    public static function decrypt(string $encryptedData) {
        $key = self::getEncryptionKey();
        $cipher = 'AES-256-CBC';
        $data = base64_decode($encryptedData);
        
        $iv = substr($data, 0, 16);
        $encrypted = substr($data, 16);
        
        return openssl_decrypt($encrypted, $cipher, $key, OPENSSL_RAW_DATA, $iv);
    }

    /**
     * دریافت کلید رمزگذاری
     * @return string
     */
    private static function getEncryptionKey(): string {
        if (self::$encryptionKey === null) {
            // در production باید از environment variable استفاده شود
            self::$encryptionKey = hash('sha256', 'DataSave_Encryption_Key_2025');
        }
        return self::$encryptionKey;
    }
}
```

---

## ⚠️ Important Notes

### Performance Considerations
- همیشه از Prepared Statements استفاده کنید
- Indexes مناسب برای queries پرکاربرد تعریف کنید
- از Connection Pooling برای تعداد زیاد درخواست استفاده کنید
- Query Cache را برای داده‌های کم‌تغییر فعال کنید

### Security Best Practices
- هرگز raw SQL queries استفاده نکنید
- ورودی‌های کاربر را همیشه Validate و Sanitize کنید
- داده‌های حساس را رمزگذاری کنید
- لاگ‌های دیتابیس را منظماً بررسی کنید

### Persian Support
- همیشه از UTF-8 encoding استفاده کنید
- Character set دیتابیس را روی utf8mb4_persian_ci تنظیم کنید
- متن‌های فارسی را قبل از ذخیره پاک‌سازی کنید
- اعداد فارسی را در نظر بگیرید

---

## 🔄 Related Documentation
- [Database Design](../03-Database-Schema/database-design.md)
- [Tables Reference](../03-Database-Schema/tables-reference.md)
- [API Endpoints Reference](api-endpoints-reference.md)
- [Error Handling](error-handling.md)
- [Security Implementation](security-implementation.md)

## 📚 References
- [PHP PDO Documentation](https://www.php.net/manual/en/book.pdo.php)
- [MySQL 8.0 Reference](https://dev.mysql.com/doc/refman/8.0/en/)
- [Persian MySQL Configuration](https://github.com/Persian-Web-Tools/persian-mysql)
- [Database Security Best Practices](https://owasp.org/www-project-top-ten/)

---
*Last updated: 2025-09-01*  
*File: docs/02-Backend-APIs/database-integration.md*