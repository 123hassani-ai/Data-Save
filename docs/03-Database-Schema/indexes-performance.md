# اندیس‌ها و بهینه‌سازی - Database Indexes & Performance Optimization

## 📊 Document Information
- **Created:** 2025-09-01
- **Last Updated:** 2025-09-01
- **Version:** 1.0
- **Maintainer:** DataSave Development Team
- **Related Files:** `/database_setup.sql`, query optimization files

## 🎯 Overview
راهنمای جامع بهینه‌سازی عملکرد دیتابیس DataSave شامل استراتژی اندیکس‌گذاری، بهینه‌سازی کوئری، و monitoring عملکرد با تمرکز بر پشتیبانی از متن فارسی.

## 📋 Table of Contents
- [استراتژی اندیکس‌گذاری](#استراتژی-اندیکسگذاری)
- [اندیس‌های فعلی](#اندیسهای-فعلی)
- [بهینه‌سازی کوئری](#بهینهسازی-کوئری)
- [Persian Text Indexing](#persian-text-indexing)
- [Performance Monitoring](#performance-monitoring)
- [Query Optimization](#query-optimization)
- [Partitioning Strategy](#partitioning-strategy)

## 🎯 استراتژی اندیکس‌گذاری - Indexing Strategy

### Indexing Philosophy
```yaml
Primary Goals:
  - Fast query execution for common operations
  - Optimized JOIN performance
  - Efficient Persian text search
  - Minimal storage overhead
  - Balanced read/write performance

Index Types Used:
  - PRIMARY KEY: Unique identification
  - UNIQUE KEY: Data integrity constraints
  - KEY (Standard): Query optimization
  - FULLTEXT: Persian text search
  - COMPOSITE: Multi-column queries

Persian Considerations:
  - utf8mb4_persian_ci collation for all text indexes
  - FULLTEXT indexes for Persian search
  - Proper character handling in LIKE queries
```

### Index Naming Conventions
```sql
-- نامگذاری استاندارد اندیکس‌ها
Naming Pattern:
  - idx_[column_name] : Single column index
  - idx_[col1]_[col2] : Composite index
  - uk_[column_name]  : Unique key
  - ft_[column_name]  : FULLTEXT index
  
Examples:
  - idx_setting_key
  - idx_level_category
  - uk_setting_key
  - ft_log_message
```

## 📈 اندیس‌های فعلی - Current Database Indexes

### 1️⃣ system_settings Table Indexes
```sql
-- جدول system_settings (9 records)
-- Storage Engine: InnoDB
-- Charset: utf8mb4_persian_ci

SHOW INDEX FROM system_settings;

-- اندیس‌های فعلی:
PRIMARY KEY (id)                                    -- Primary key
UNIQUE KEY uk_setting_key (setting_key)            -- Unique constraint
KEY idx_setting_key (setting_key)                  -- Fast key lookup
KEY idx_setting_type (setting_type)                -- Type-based filtering
KEY idx_is_system (is_system)                      -- System/user settings
KEY idx_created_at (created_at)                    -- Time-based queries

-- اندیس‌های ترکیبی پیشنهادی:
KEY idx_key_type (setting_key, setting_type)       -- Key + type lookup
KEY idx_system_readonly (is_system, is_readonly)   -- Access control
KEY idx_type_system (setting_type, is_system)      -- Type filtering
```

#### Performance Analysis:
```sql
-- تحلیل عملکرد کوئری‌های رایج
EXPLAIN SELECT setting_value FROM system_settings WHERE setting_key = 'openai_model';
-- Result: Using index uk_setting_key (PERFECT)

EXPLAIN SELECT * FROM system_settings WHERE is_system = TRUE ORDER BY setting_key;
-- Result: Using index idx_is_system + filesort (GOOD)

EXPLAIN SELECT * FROM system_settings WHERE setting_type = 'encrypted' AND is_system = TRUE;
-- Result: Using index intersection (OPTIMAL with composite index)
```

### 2️⃣ system_logs Table Indexes
```sql
-- جدول system_logs (500+ records, partitioned)
-- Storage Engine: InnoDB
-- Charset: utf8mb4_persian_ci
-- Partitioning: BY RANGE (YEAR)

SHOW INDEX FROM system_logs;

-- اندیس‌های فعلی:
PRIMARY KEY (log_id)                                -- Primary key
KEY idx_log_level (log_level)                      -- Level filtering
KEY idx_log_category (log_category)                -- Category filtering  
KEY idx_created_at (created_at)                    -- Time-based queries
KEY idx_level_category (log_level, log_category)   -- Combined filtering
KEY idx_user_session (user_id, session_id)        -- User tracking

-- اندیس‌های بهینه‌سازی اضافی:
KEY idx_level_time (log_level, created_at)         -- Level + time
KEY idx_category_time (log_category, created_at)   -- Category + time  
KEY idx_message_prefix (log_message(100))          -- Message prefix search
FULLTEXT KEY ft_log_message (log_message)          -- Full-text search
```

#### Partitioning Performance:
```sql
-- بررسی عملکرد partitioning
SELECT 
    TABLE_NAME, 
    PARTITION_NAME, 
    TABLE_ROWS, 
    DATA_LENGTH, 
    INDEX_LENGTH
FROM information_schema.PARTITIONS 
WHERE TABLE_NAME = 'system_logs' 
  AND TABLE_SCHEMA = 'datasave';

-- Query performance بر روی partition
EXPLAIN PARTITIONS 
SELECT * FROM system_logs 
WHERE created_at >= '2025-01-01' 
  AND log_level = 'ERROR';
-- Result: Only p2025 partition scanned (EXCELLENT)
```

## 🔍 Persian Text Indexing & Search

### Persian FULLTEXT Search Setup
```sql
-- پیکربندی FULLTEXT برای متن فارسی
-- MySQL 8.0+ با پشتیبانی بهتر از utf8mb4

-- بررسی تنظیمات FULLTEXT فعلی
SHOW VARIABLES LIKE 'ft_%';

-- تنظیمات بهینه برای Persian:
SET GLOBAL ft_min_word_len = 2;          -- کلمات کوتاه فارسی
SET GLOBAL ft_boolean_syntax = '+ -><()~*:""&|';
SET GLOBAL ft_max_word_len = 84;         -- کلمات طولانی فارسی

-- ایجاد FULLTEXT index برای جستجوی فارسی
ALTER TABLE system_logs 
ADD FULLTEXT KEY ft_log_message (log_message);

-- تست جستجوی فارسی
SELECT log_id, log_message, 
       MATCH(log_message) AGAINST('OpenAI' IN BOOLEAN MODE) as relevance
FROM system_logs 
WHERE MATCH(log_message) AGAINST('OpenAI' IN BOOLEAN MODE)
ORDER BY relevance DESC;

-- جستجوی پیشرفته فارسی
SELECT * FROM system_logs 
WHERE MATCH(log_message) AGAINST('+تنظیمات +API' IN BOOLEAN MODE);
```

### Persian Text Search Optimization
```php
<?php
// کلاس بهینه‌سازی جستجوی فارسی
class PersianSearchOptimizer {
    
    public static function optimizeSearchTerm(string $term): string {
        // حذف نویسه‌های اضافی
        $term = trim($term);
        
        // تبدیل ی/ك عربی به فارسی  
        $term = str_replace(['ي', 'ك'], ['ی', 'ک'], $term);
        
        // حذف zero-width characters
        $term = preg_replace('/[\x{200C}\x{200D}\x{FEFF}]/u', '', $term);
        
        return $term;
    }
    
    public static function buildFulltextQuery(array $terms): string {
        $optimizedTerms = array_map([self::class, 'optimizeSearchTerm'], $terms);
        return '+' . implode(' +', $optimizedTerms);
    }
    
    public static function searchLogs(string $searchTerm, string $level = null): array {
        $db = DatabaseConfig::getInstance();
        
        $optimizedTerm = self::buildFulltextQuery([$searchTerm]);
        
        $sql = "SELECT log_id, log_level, log_message, created_at,
                       MATCH(log_message) AGAINST(? IN BOOLEAN MODE) as relevance
                FROM system_logs 
                WHERE MATCH(log_message) AGAINST(? IN BOOLEAN MODE)";
        
        $params = [$optimizedTerm, $optimizedTerm];
        
        if ($level) {
            $sql .= " AND log_level = ?";
            $params[] = $level;
        }
        
        $sql .= " ORDER BY relevance DESC, created_at DESC LIMIT 50";
        
        $stmt = $db->prepare($sql);
        $stmt->execute($params);
        
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
}
?>
```

## 📊 Performance Monitoring & Analysis

### Query Performance Monitoring
```sql
-- فعال‌سازی Performance Schema
SET GLOBAL performance_schema = ON;

-- نمایش کوئری‌های کند
SELECT 
    DIGEST_TEXT,
    COUNT_STAR as exec_count,
    AVG_TIMER_WAIT/1000000000 as avg_time_sec,
    MAX_TIMER_WAIT/1000000000 as max_time_sec
FROM performance_schema.events_statements_summary_by_digest
WHERE SCHEMA_NAME = 'datasave'
ORDER BY AVG_TIMER_WAIT DESC
LIMIT 10;

-- آمار استفاده از اندیکس‌ها
SELECT 
    OBJECT_SCHEMA,
    OBJECT_NAME,
    INDEX_NAME,
    COUNT_FETCH,
    COUNT_INSERT,
    COUNT_UPDATE,
    COUNT_DELETE
FROM performance_schema.table_io_waits_summary_by_index_usage
WHERE OBJECT_SCHEMA = 'datasave'
ORDER BY COUNT_FETCH DESC;

-- شناسایی جداول پرکاربرد
SELECT 
    OBJECT_NAME as table_name,
    COUNT_READ,
    COUNT_WRITE,
    SUM_TIMER_READ/1000000000 as read_time_sec,
    SUM_TIMER_WRITE/1000000000 as write_time_sec
FROM performance_schema.table_io_waits_summary_by_table
WHERE OBJECT_SCHEMA = 'datasave'
ORDER BY COUNT_READ DESC;
```

### Automated Performance Monitoring
```php
<?php
// کلاس monitoring خودکار عملکرد
class DatabasePerformanceMonitor {
    
    public static function analyzeSlowQueries(): array {
        $db = DatabaseConfig::getInstance();
        
        $sql = "SELECT 
                    DIGEST_TEXT as query_pattern,
                    COUNT_STAR as execution_count,
                    ROUND(AVG_TIMER_WAIT/1000000000, 3) as avg_time_sec,
                    ROUND(MAX_TIMER_WAIT/1000000000, 3) as max_time_sec,
                    ROUND(SUM_TIMER_WAIT/1000000000, 3) as total_time_sec
                FROM performance_schema.events_statements_summary_by_digest
                WHERE SCHEMA_NAME = 'datasave' 
                  AND AVG_TIMER_WAIT > 1000000000
                ORDER BY AVG_TIMER_WAIT DESC
                LIMIT 20";
        
        $stmt = $db->query($sql);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
    
    public static function checkIndexUsage(): array {
        $db = DatabaseConfig::getInstance();
        
        $sql = "SELECT 
                    CONCAT(OBJECT_SCHEMA, '.', OBJECT_NAME) as table_name,
                    INDEX_NAME,
                    COUNT_FETCH as reads,
                    COUNT_INSERT as inserts,
                    COUNT_UPDATE as updates,
                    COUNT_DELETE as deletes,
                    ROUND(COUNT_FETCH / (COUNT_FETCH + COUNT_INSERT + COUNT_UPDATE + COUNT_DELETE) * 100, 2) as read_ratio
                FROM performance_schema.table_io_waits_summary_by_index_usage
                WHERE OBJECT_SCHEMA = 'datasave'
                  AND INDEX_NAME IS NOT NULL
                ORDER BY COUNT_FETCH DESC";
        
        $stmt = $db->query($sql);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
    
    public static function generatePerformanceReport(): array {
        return [
            'timestamp' => date('c'),
            'slow_queries' => self::analyzeSlowQueries(),
            'index_usage' => self::checkIndexUsage(),
            'table_stats' => self::getTableStatistics(),
            'recommendations' => self::generateRecommendations()
        ];
    }
}
?>
```

## ⚡ Query Optimization Strategies

### Common Query Patterns & Optimization
```sql
-- Pattern 1: تنظیمات سیستمی (بسیار متداول)
-- Query اصلی:
SELECT setting_value FROM system_settings WHERE setting_key = 'openai_model';
-- Optimization: ✅ از UNIQUE index استفاده می‌کند

-- Pattern 2: فیلتر لاگ‌ها بر اساس سطح و زمان
-- Query اصلی:
SELECT * FROM system_logs 
WHERE log_level = 'ERROR' 
  AND created_at >= DATE_SUB(NOW(), INTERVAL 1 DAY)
ORDER BY created_at DESC;

-- بهینه‌سازی شده:
-- ✅ از composite index استفاده می‌کند: idx_level_time
EXPLAIN SELECT * FROM system_logs 
WHERE log_level = 'ERROR' 
  AND created_at >= '2025-09-01 00:00:00'
ORDER BY created_at DESC
LIMIT 50;

-- Pattern 3: جستجو در متن لاگ‌ها
-- Query اصلی (کند):
SELECT * FROM system_logs WHERE log_message LIKE '%OpenAI%';

-- بهینه‌سازی شده با FULLTEXT:
SELECT log_id, log_message, created_at,
       MATCH(log_message) AGAINST('OpenAI' IN BOOLEAN MODE) as score
FROM system_logs 
WHERE MATCH(log_message) AGAINST('OpenAI' IN BOOLEAN MODE)
ORDER BY score DESC, created_at DESC;
```

### Query Rewriting for Persian Text
```sql
-- بهینه‌سازی جستجوی متن فارسی
-- LIKE query (کند برای جداول بزرگ):
SELECT * FROM system_logs 
WHERE log_message LIKE '%تنظیمات%' 
   OR log_message LIKE '%API%';

-- FULLTEXT equivalent (سریع):
SELECT * FROM system_logs 
WHERE MATCH(log_message) AGAINST('+تنظیمات +API' IN BOOLEAN MODE);

-- ترکیب FULLTEXT با فیلترهای معمولی:
SELECT * FROM system_logs 
WHERE MATCH(log_message) AGAINST('OpenAI' IN BOOLEAN MODE)
  AND log_level IN ('ERROR', 'WARNING')
  AND created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY);
```

## 🎯 Future Indexing Strategy

### Planned Indexes for Form Tables
```sql
-- برای جداول آینده (forms, form_responses)

-- جدول forms
KEY idx_forms_created_by (created_by)
KEY idx_forms_active_public (is_active, is_public)  
KEY idx_forms_name_active (form_name, is_active)
FULLTEXT KEY ft_forms_search (form_title, form_description)

-- جدول form_responses  
KEY idx_responses_form_id (form_id)
KEY idx_responses_form_time (form_id, created_at)
KEY idx_responses_submitted_by (submitted_by)
KEY idx_responses_time (created_at)

-- جدول users
KEY idx_users_username (username)
KEY idx_users_email (email)
KEY idx_users_role_active (user_role, is_active)
KEY idx_users_last_login (last_login)
```

### Composite Index Strategy
```yaml
High-Traffic Query Patterns:
  1. "تنظیمات سیستمی فعال":
     - Columns: (is_system, is_active, setting_key)
     - Usage: Admin dashboard, configuration loading
     
  2. "لاگ‌های اخیر بر اساس سطح":
     - Columns: (log_level, created_at) 
     - Usage: Error monitoring, debugging
     
  3. "فرم‌های کاربر فعال":
     - Columns: (created_by, is_active, created_at)
     - Usage: User dashboard, form management
     
  4. "پاسخ‌های فرم در بازه زمانی":
     - Columns: (form_id, created_at)
     - Usage: Analytics, reporting
```

## 📈 Storage & Performance Metrics

### Current Database Size Analysis
```sql
-- آمار فضای مصرفی جداول
SELECT 
    TABLE_NAME,
    TABLE_ROWS,
    ROUND(DATA_LENGTH / 1024 / 1024, 2) as data_mb,
    ROUND(INDEX_LENGTH / 1024 / 1024, 2) as index_mb,
    ROUND((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024, 2) as total_mb,
    ROUND(INDEX_LENGTH / DATA_LENGTH * 100, 2) as index_ratio
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'datasave'
ORDER BY (DATA_LENGTH + INDEX_LENGTH) DESC;

-- Current Results:
-- system_logs:     ~2.5 MB data, ~1.2 MB indexes (48% ratio)
-- system_settings: ~0.1 MB data, ~0.05 MB indexes (50% ratio)
```

### Growth Projections
```yaml
Estimated Growth (Next 6 Months):
  system_logs:
    - Current: 500 records/month
    - Projected: 2000 records/month  
    - Size growth: ~10 MB/month
    - Partitioning: Essential for performance
    
  forms (Future):
    - Estimated: 100 forms/month
    - form_responses: 1000 responses/month
    - Size growth: ~50 MB/month
    - Index strategy: Critical for query performance

Performance Targets:
  - Query response time: < 50ms (95% percentile)
  - Index hit ratio: > 95%
  - Full table scans: < 5% of queries
  - Disk I/O: Optimized through proper indexing
```

## ⚠️ Important Notes

### Index Maintenance
- Regular ANALYZE TABLE برای آمار دقیق
- Monitor index fragmentation روزانه
- Rebuild indexes ماهانه در production
- Performance testing قبل از تغییر index

### Persian Text Considerations
- utf8mb4_persian_ci در همه text indexes
- FULLTEXT min_word_len = 2 برای کلمات فارسی کوتاه
- Character normalization در application layer

### Performance Monitoring
- Weekly performance reports
- Slow query log analysis
- Index usage statistics
- Proactive optimization based on usage patterns

## 🔄 Related Documentation
- [Database Design](database-design.md)
- [Tables Reference](tables-reference.md)
- [Migration Scripts](migration-scripts.md)
- [PHP Backend Overview](../02-Backend-APIs/php-backend-overview.md)

## 📚 References
- [MySQL 8.0 Index Optimization](https://dev.mysql.com/doc/refman/8.0/en/optimization-indexes.html)
- [MySQL FULLTEXT Search](https://dev.mysql.com/doc/refman/8.0/en/fulltext-search.html)
- [Persian Text Search Best Practices](https://dev.mysql.com/doc/refman/8.0/en/charset-unicode-utf8mb4.html)
- [Performance Schema Guide](https://dev.mysql.com/doc/refman/8.0/en/performance-schema.html)

---
*Last updated: 2025-09-01*
*File: docs/03-Database-Schema/indexes-performance.md*