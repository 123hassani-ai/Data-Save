# راهنمای مهاجرت MVP 4.0 - Migration Guide

## 📊 Document Information
- **Created:** 2025-03-03
- **Last Updated:** 2025-03-03
- **Version:** 1.0.0
- **Target:** MVP 4.0 Business Intelligence Platform
- **Maintainer:** DataSave Development Team

## 🎯 Overview
راهنمای کامل مهاجرت DataSave از Form Builder به Business Intelligence Platform بدون وقفه در سرویس و با حفظ کامل داده‌های موجود.

## 📋 Table of Contents
- [استراتژی مهاجرت](#استراتژی-مهاجرت)
- [پیش‌نیازها](#پیشنیازها)
- [مراحل مهاجرت](#مراحل-مهاجرت)
- [تست و اعتبارسنجی](#تست-و-اعتبارسنجی)
- [Rollback Strategy](#rollback-strategy)

---

## 🏗️ استراتژی مهاجرت - Migration Strategy

### **اصول کلیدی:**
```yaml
Foundation Preservation: ✅
  - هیچ جدول موجود تغییر نمی‌کند
  - همه API های موجود حفظ می‌شوند
  - UI فعلی دست‌نخورده باقی می‌ماند

Progressive Enhancement: ✅
  - افزودن جداول جدید
  - ایجاد API های جدید
  - توسعه UI components جدید
  - Migration مرحله‌ای

Zero Downtime: ✅
  - عملیات در ساعات کم‌ترافیک
  - Hot deployment برای API های جدید
  - Database migration بدون قفل جداول
  - Instant rollback capability
```

### **Timeline Overview:**
```yaml
Week 1-2: Database Schema Extension
Week 3-4: Backend Services Development
Week 5-8: Frontend Components Implementation
Week 9-10: Integration & Testing
Week 11-12: Production Deployment & Monitoring
```

---

## 🔧 پیش‌نیازها - Prerequisites

### **Database Backup:**
```sql
-- Complete database backup
mysqldump -u root -pMojtab@123 -h localhost -P 3307 datasave > datasave_backup_before_mvp4.sql

-- Verify backup integrity
mysql -u root -pMojtab@123 -h localhost -P 3307 -e "CREATE DATABASE datasave_test;"
mysql -u root -pMojtab@123 -h localhost -P 3307 datasave_test < datasave_backup_before_mvp4.sql
mysql -u root -pMojtab@123 -h localhost -P 3307 -e "DROP DATABASE datasave_test;"
```

### **Git Branch Strategy:**
```bash
# Create MVP 4.0 branch
git checkout main
git pull origin main
git checkout -b feature/mvp-4.0-bi-platform

# Create sub-branches for each phase
git checkout -b feature/mvp-4.0-database
git checkout -b feature/mvp-4.0-backend
git checkout -b feature/mvp-4.0-frontend
```

### **Environment Preparation:**
```yaml
XAMPP Configuration:
  - MySQL 8.0 on port 3307 ✅
  - PHP 8.x enabled ✅
  - Apache running ✅
  - Enough disk space (5GB recommended)

Development Tools:
  - VS Code with Flutter/PHP extensions ✅
  - Git version control ✅
  - Database management tool (phpMyAdmin/MySQL Workbench)

OpenAI Integration:
  - API key verified ✅
  - Rate limits understood ✅
  - Billing setup for increased usage
```

---

## 📈 مراحل مهاجرت - Migration Phases

### **🗄️ Phase 1: Database Schema Extension (Week 1-2)**

#### **Step 1.1: New Tables Creation**
```sql
-- Execute in sequence (backup first!)

-- 1. AI Conversations
CREATE TABLE `ai_conversations` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `user_id` INT UNSIGNED,
  `conversation_type` ENUM('form_creation', 'data_query', 'insight_request', 'general_chat') NOT NULL,
  `messages` JSON NOT NULL COMMENT 'آرایه پیام‌های مکالمه',
  `context` JSON COMMENT 'Context اطلاعات مکالمه',
  `status` ENUM('active', 'completed', 'error') DEFAULT 'active',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user_type (user_id, conversation_type),
  INDEX idx_created_at (created_at),
  INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci
COMMENT='مکالمات AI برای Chat Explorer و Form Wizard';

-- 2. Form Embeds
CREATE TABLE `form_embeds` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `form_id` INT UNSIGNED NOT NULL,
  `embed_domain` VARCHAR(255) COMMENT 'دامنه وبسایت embed شده',
  `embed_type` ENUM('wordpress', 'html', 'javascript', 'iframe') NOT NULL,
  `embed_config` JSON COMMENT 'تنظیمات embed',
  `usage_stats` JSON COMMENT 'آمار استفاده',
  `is_active` BOOLEAN DEFAULT TRUE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `last_accessed` TIMESTAMP,
  
  FOREIGN KEY (form_id) REFERENCES forms(id) ON DELETE CASCADE,
  INDEX idx_form_domain (form_id, embed_domain),
  INDEX idx_embed_type (embed_type),
  INDEX idx_active_created (is_active, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci
COMMENT='ردیابی فرم‌های embed شده در وبسایت‌های خارجی';

-- 3. Analytics Cache
CREATE TABLE `analytics_cache` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `cache_key` VARCHAR(255) UNIQUE NOT NULL,
  `query_hash` VARCHAR(64) NOT NULL COMMENT 'MD5 hash of original query',
  `query_type` VARCHAR(50) COMMENT 'نوع query (dashboard, insight, custom)',
  `result_data` JSON NOT NULL COMMENT 'نتیجه query',
  `metadata` JSON COMMENT 'metadata اضافی',
  `expires_at` TIMESTAMP NOT NULL,
  `hit_count` INT UNSIGNED DEFAULT 0,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `last_accessed` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  UNIQUE KEY uk_cache_key (cache_key),
  INDEX idx_query_hash (query_hash),
  INDEX idx_expires_at (expires_at),
  INDEX idx_query_type (query_type),
  INDEX idx_hit_count (hit_count)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci
COMMENT='کش Analytics queries برای بهبود عملکرد';

-- 4. AI Insights
CREATE TABLE `ai_insights` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `insight_type` VARCHAR(100) NOT NULL COMMENT 'نوع insight (pattern, prediction, recommendation)',
  `title` VARCHAR(255) NOT NULL COMMENT 'عنوان insight',
  `description` TEXT COMMENT 'توضیحات تفصیلی',
  `data` JSON NOT NULL COMMENT 'داده‌های insight',
  `confidence_score` DECIMAL(3,2) COMMENT 'امتیاز اطمینان (0.00-1.00)',
  `related_forms` JSON COMMENT 'فرم‌های مرتبط',
  `is_active` BOOLEAN DEFAULT TRUE,
  `expires_at` TIMESTAMP COMMENT 'زمان انقضای insight',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  INDEX idx_insight_type (insight_type),
  INDEX idx_confidence_score (confidence_score),
  INDEX idx_active_created (is_active, created_at),
  INDEX idx_expires_at (expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci
COMMENT='AI Insights تولید شده توسط Analytics Consultant';

-- 5. External Integrations
CREATE TABLE `external_integrations` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `integration_type` VARCHAR(50) NOT NULL COMMENT 'نوع integration (wordpress, cdn, webhook)',
  `integration_name` VARCHAR(100) NOT NULL,
  `config` JSON NOT NULL COMMENT 'تنظیمات integration',
  `credentials` JSON COMMENT 'اطلاعات احراز هویت (encrypted)',
  `status` ENUM('active', 'inactive', 'error', 'pending') DEFAULT 'pending',
  `last_sync` TIMESTAMP COMMENT 'آخرین sync موفق',
  `error_log` TEXT COMMENT 'لاگ خطاهای اخیر',
  `usage_stats` JSON COMMENT 'آمار استفاده',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  INDEX idx_integration_type (integration_type),
  INDEX idx_status (status),
  INDEX idx_last_sync (last_sync)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_persian_ci
COMMENT='مدیریت integration های خارجی';
```

#### **Step 1.2: Enhanced System Settings**
```sql
-- Add MVP 4.0 specific settings
INSERT INTO system_settings (setting_key, setting_value, setting_type, description, is_system) VALUES
('ai_enabled', 'true', 'boolean', 'فعال‌سازی قابلیت‌های هوش مصنوعی', TRUE),
('ai_chat_model', 'gpt-4', 'string', 'مدل AI برای چت', TRUE),
('analytics_cache_ttl', '3600', 'number', 'مدت زمان کش analytics (ثانیه)', FALSE),
('embed_allowed_domains', '[]', 'json', 'دامنه‌های مجاز برای embed', FALSE),
('wordpress_integration', 'false', 'boolean', 'فعال‌سازی پلاگین وردپرس', FALSE),
('realtime_updates', 'true', 'boolean', 'بروزرسانی زنده داشبورد', FALSE),
('voice_input_enabled', 'false', 'boolean', 'فعال‌سازی ورودی صوتی', FALSE);
```

#### **Step 1.3: Data Integrity Verification**
```sql
-- Verify foreign keys
SELECT 
  CONSTRAINT_NAME,
  TABLE_NAME,
  COLUMN_NAME,
  REFERENCED_TABLE_NAME,
  REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE 
WHERE TABLE_SCHEMA = 'datasave' 
  AND REFERENCED_TABLE_NAME IS NOT NULL;

-- Verify indexes
SELECT 
  TABLE_NAME,
  INDEX_NAME,
  COLUMN_NAME,
  INDEX_TYPE
FROM information_schema.STATISTICS 
WHERE TABLE_SCHEMA = 'datasave'
ORDER BY TABLE_NAME, INDEX_NAME;
```

### **🔧 Phase 2: Backend Services Development (Week 3-4)**

#### **Step 2.1: Create Services Directory Structure**
```bash
mkdir -p backend/services/ai
mkdir -p backend/services/embed  
mkdir -p backend/services/analytics
mkdir -p backend/classes/Database
```

#### **Step 2.2: AI Services Implementation**
```php
<?php
// backend/services/ai/AINLPService.php
class AINLPService {
    private OpenAIService $openai;
    private Logger $logger;
    
    public function __construct() {
        $this->openai = new OpenAIService();
        $this->logger = new Logger();
    }
    
    public function processNaturalLanguageQuery(string $question): array {
        try {
            $systemPrompt = "You are a Persian data analyst...";
            $response = $this->openai->chat([
                ['role' => 'system', 'content' => $systemPrompt],
                ['role' => 'user', 'content' => $question]
            ]);
            
            return $this->parseAIResponse($response);
        } catch (Exception $e) {
            $this->logger->error('AI_NLP', 'خطا در پردازش سوال', ['error' => $e->getMessage()]);
            throw $e;
        }
    }
    
    private function parseAIResponse(array $response): array {
        // Parse AI response and extract SQL query, visualization type, etc.
        return [
            'sql' => $this->extractSQL($response),
            'chart_type' => $this->extractChartType($response),
            'description' => $response['choices'][0]['message']['content']
        ];
    }
}
?>
```

#### **Step 2.3: New API Endpoints Creation**
```bash
# Create new API endpoint directories
mkdir -p backend/api/ai
mkdir -p backend/api/analytics
mkdir -p backend/api/embed
mkdir -p backend/api/wordpress
mkdir -p backend/api/insights
```

### **📱 Phase 3: Frontend Components Implementation (Week 5-8)**

#### **Step 3.1: New Controller Classes**
```dart
// Create new controllers
touch lib/presentation/controllers/dashboard_controller.dart
touch lib/presentation/controllers/ai_chat_controller.dart
touch lib/presentation/controllers/form_wizard_controller.dart
touch lib/presentation/controllers/analytics_controller.dart
```

#### **Step 3.2: Enhanced Services**
```dart
// lib/core/services/analytics_service.dart
class AnalyticsService {
  static const String _baseUrl = 'http://localhost/datasave/backend/api';
  
  static Future<Map<String, dynamic>?> getDashboardData() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/analytics/dashboard-data.php'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['success'] == true) {
          return result['data'];
        }
      }
      return null;
    } catch (e) {
      LoggerService.error('AnalyticsService', 'Error in getDashboardData: $e');
      return null;
    }
  }
  
  static Future<List<ChartData>?> executeCustomQuery(String query) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/analytics/custom-query.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'question': query}),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['success'] == true) {
          return (result['data']['chart_data'] as List)
              .map((item) => ChartData.fromJson(item))
              .toList();
        }
      }
      return null;
    } catch (e) {
      LoggerService.error('AnalyticsService', 'Error in executeCustomQuery: $e');
      return null;
    }
  }
}
```

---

## 🧪 تست و اعتبارسنجی - Testing & Validation

### **Database Testing:**
```sql
-- Test new tables
SELECT COUNT(*) FROM ai_conversations;
SELECT COUNT(*) FROM form_embeds; 
SELECT COUNT(*) FROM analytics_cache;
SELECT COUNT(*) FROM ai_insights;
SELECT COUNT(*) FROM external_integrations;

-- Test foreign key constraints
INSERT INTO ai_conversations (user_id, conversation_type, messages) 
VALUES (999, 'form_creation', '{}'); -- Should fail

-- Test JSON fields
INSERT INTO ai_conversations (user_id, conversation_type, messages, context) 
VALUES (1, 'data_query', '[{"role":"user","message":"test"}]', '{"test":true}');
```

### **API Testing:**
```bash
# Test existing APIs (should work unchanged)
curl -X GET "http://localhost/datasave/backend/api/settings/get.php"
curl -X GET "http://localhost/datasave/backend/api/logs/list.php"
curl -X GET "http://localhost/datasave/backend/api/system/info.php"

# Test new APIs  
curl -X POST "http://localhost/datasave/backend/api/ai/chat.php" \
  -H "Content-Type: application/json" \
  -d '{"message":"چند فرم دارم؟"}'

curl -X GET "http://localhost/datasave/backend/api/analytics/dashboard-data.php"
```

### **Frontend Testing:**
```dart
void main() {
  testWidgets('Dashboard Intelligence loads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    await tester.tap(find.byIcon(Icons.dashboard));
    await tester.pumpAndSettle();
    
    expect(find.text('داشبورد هوشمند'), findsOneWidget);
    expect(find.byType(LivingStatsPanel), findsOneWidget);
  });
}
```

---

## 🔄 Rollback Strategy

### **Immediate Rollback (if needed during migration):**
```sql
-- Drop new tables (if migration fails)
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS external_integrations;
DROP TABLE IF EXISTS ai_insights;
DROP TABLE IF EXISTS analytics_cache;
DROP TABLE IF EXISTS form_embeds;  
DROP TABLE IF EXISTS ai_conversations;
SET FOREIGN_KEY_CHECKS = 1;

-- Remove new settings
DELETE FROM system_settings WHERE setting_key IN (
  'ai_enabled', 'ai_chat_model', 'analytics_cache_ttl', 
  'embed_allowed_domains', 'wordpress_integration', 
  'realtime_updates', 'voice_input_enabled'
);
```

### **Git Rollback:**
```bash
# Rollback to main branch
git checkout main
git branch -D feature/mvp-4.0-bi-platform

# Or rollback specific commits
git reset --hard HEAD~5
git push --force-with-lease origin feature/mvp-4.0-bi-platform
```

### **Complete Database Restore:**
```sql
-- If complete rollback needed
mysql -u root -pMojtab@123 -h localhost -P 3307 -e "DROP DATABASE datasave;"
mysql -u root -pMojtab@123 -h localhost -P 3307 -e "CREATE DATABASE datasave CHARACTER SET utf8mb4 COLLATE utf8mb4_persian_ci;"
mysql -u root -pMojtab@123 -h localhost -P 3307 datasave < datasave_backup_before_mvp4.sql
```

---

## ✅ Success Criteria

### **Database Migration Success:**
- [ ] All 5 new tables created successfully
- [ ] Foreign keys working correctly  
- [ ] Indexes created and optimized
- [ ] Data integrity maintained
- [ ] No performance degradation on existing queries

### **Backend Development Success:**
- [ ] All new API endpoints responding correctly
- [ ] Existing APIs unchanged and functional
- [ ] AI services integration working
- [ ] Error handling comprehensive
- [ ] Logging system capturing new events

### **Frontend Development Success:**
- [ ] New pages/widgets rendering correctly
- [ ] State management working smoothly
- [ ] Persian RTL support maintained
- [ ] Real-time updates functioning
- [ ] Performance acceptable (< 3s load time)

### **Integration Success:**
- [ ] End-to-end AI chat working
- [ ] Form wizard generating forms
- [ ] Analytics dashboard displaying data
- [ ] Embed functionality working
- [ ] WordPress integration tested

---

## ⚠️ Important Notes

### **Production Considerations:**
1. **Backup Strategy:** Daily backups during migration period
2. **Monitoring:** Enhanced logging for all new features
3. **Performance:** Database query optimization critical
4. **Security:** Input validation for all AI interactions
5. **Capacity:** Monitor OpenAI API usage and costs

### **Team Coordination:**
1. **Communication:** Daily standup during migration
2. **Documentation:** Update docs immediately after changes
3. **Code Review:** All changes reviewed before merge
4. **Testing:** Both manual and automated testing

### **Risk Mitigation:**
1. **Phased Rollout:** Deploy features progressively
2. **Feature Flags:** Ability to disable new features quickly
3. **Monitoring:** Real-time alerts for errors
4. **Rollback Plan:** Tested and ready to execute

---

**📅 Migration Timeline:** 12 weeks from start to production  
**👥 Team:** DataSave Development Team  
**🎯 Goal:** Zero-downtime migration to Business Intelligence Platform  
**🔒 Status:** Ready for Implementation

---

*Last updated: 2025-03-03*  
*Document version: 1.0*  
*File: /docs/MVP-4.0-Business-Intelligence/migration-guide.md*
