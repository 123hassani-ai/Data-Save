# توسعه و گردش کار - Development Workflow

## 📊 Document Information
- **Created:** 2025-01-09
- **Last Updated:** 2025-01-09
- **Version:** 1.0
- **Maintainer:** DataSave Development Team

## 🎯 Overview
مستندات کامل گردش کار توسعه پروژه DataSave شامل محیط توسعه، استراتژی‌های تست، رویه‌های deployment، version control، و workflow‌های maintenance.

## 🛠️ Development Environment

### System Requirements
```yaml
Operating System:
  - macOS: 12+ (Monterey یا بالاتر)
  - Windows: 10+ (64-bit)
  - Linux: Ubuntu 18.04+ یا معادل

Flutter Requirements:
  - Flutter SDK: 3.16.0+
  - Dart SDK: 3.2.0+
  - Android SDK: API 21+ (Android 5.0)
  - Xcode: 14+ (برای iOS development)

Backend Requirements:
  - PHP: 8.0+
  - XAMPP: 8.2+ (Apache + MySQL + PHP)
  - MySQL: 8.0+
  - Composer: 2.0+

Additional Tools:
  - VS Code: 1.80+ (با extensions)
  - Git: 2.30+
  - Postman: API testing
  - Browser: Chrome 100+ (برای web testing)
```

### XAMPP Configuration
```yaml
XAMPP Setup (macOS):
  Location: /Applications/XAMPP/xamppfiles/
  Document Root: /Applications/XAMPP/xamppfiles/htdocs/
  
  Services:
    - Apache: Port 80 (HTTP), Port 443 (HTTPS)
    - MySQL: Port 3307 (Custom)
    - phpMyAdmin: http://localhost/phpmyadmin

MySQL Configuration:
  Host: localhost
  Port: 3307
  Username: root
  Password: Mojtab@123
  
  Default Settings:
    - Character Set: utf8mb4
    - Collation: utf8mb4_unicode_ci
    - Time Zone: Asia/Tehran
```

### VS Code Extensions
```yaml
Essential Extensions:
  - Flutter: Dart-Code.flutter
  - Dart: Dart-Code.dart-code
  - PHP Extension Pack: xdebug.php-pack
  - GitLens: eamodio.gitlens
  - Material Icon Theme: PKief.material-icon-theme

Persian Support:
  - Persian Calendar: persian-calendar
  - Vazirmatn Font: vazirmatn-vscode

Additional Tools:
  - Error Lens: usernamehw.errorlens
  - Prettier: esbenp.prettier-vscode
  - REST Client: humao.rest-client
  - SQLTools: mtxr.sqltools
```

## 🏗️ Project Structure & Setup

### Initial Setup
```bash
# Clone repository
git clone https://github.com/username/datasave.git
cd datasave

# Flutter setup
flutter pub get
flutter pub upgrade

# Backend setup (XAMPP)
sudo /Applications/XAMPP/xamppfiles/xampp startapache
sudo /Applications/XAMPP/xamppfiles/xampp startmysql

# Database setup
mysql -u root -p -h localhost -P 3307 < database_setup.sql

# Web server setup
cp -r backend/* /Applications/XAMPP/xamppfiles/htdocs/datasave-api/
```

### Project Configuration
```yaml
Flutter Configuration:
  pubspec.yaml:
    - Flutter SDK: ">=3.0.0 <4.0.0"
    - Persian Dependencies: persian_tools, shamsi_date
    - HTTP Client: http package
    - State Management: provider
    - UI Components: material design

Backend Configuration:
  config/database.php:
    - Host: localhost
    - Port: 3307
    - Database: datasave
    - Charset: utf8mb4
    - Persian Collation: utf8mb4_unicode_ci

Environment Variables:
  .env (create if not exists):
    OPENAI_API_KEY=your_openai_api_key
    MYSQL_HOST=localhost
    MYSQL_PORT=3307
    MYSQL_DATABASE=datasave
    MYSQL_USERNAME=root
    MYSQL_PASSWORD=Mojtab@123
```

## 📝 Coding Standards

### Dart/Flutter Standards
```dart
// File naming: snake_case
// Class naming: PascalCase
// Variable naming: camelCase
// Constants: UPPER_CASE

// File structure example
class DataSaveService {
  static const String API_BASE_URL = 'http://localhost/datasave-api';
  
  final HttpClient _httpClient;
  final Logger _logger;
  
  DataSaveService({
    required HttpClient httpClient,
    required Logger logger,
  }) : _httpClient = httpClient, _logger = logger;
  
  Future<ApiResponse<T>> getData<T>() async {
    // Implementation
  }
}

// Comment standards (Persian + English)
/// سرویس اصلی DataSave برای ارتباط با API
/// Main DataSave service for API communication
class ApiService {
  // Implementation
}
```

### PHP Standards
```php
<?php
// File: ApiResponse.php
// Persian + English documentation

/**
 * کلاس پاسخ استاندارد API
 * Standard API Response Class
 */
class ApiResponse 
{
    private bool $success;
    private string $message;
    private mixed $data;
    private array $errors;
    
    public function __construct(
        bool $success = true,
        string $message = '',
        mixed $data = null,
        array $errors = []
    ) {
        $this->success = $success;
        $this->message = $message;
        $this->data = $data;
        $this->errors = $errors;
    }
    
    /**
     * تبدیل به JSON برای فرستادن به کلاینت
     * Convert to JSON for client response
     */
    public function toJson(): string 
    {
        return json_encode([
            'success' => $this->success,
            'message' => $this->message,
            'data' => $this->data,
            'errors' => $this->errors,
            'timestamp' => date('Y-m-d H:i:s')
        ], JSON_UNESCAPED_UNICODE);
    }
}
```

### Database Standards
```sql
-- Table naming: snake_case
-- Column naming: snake_case  
-- Persian content: UTF8MB4

CREATE TABLE system_settings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    setting_key VARCHAR(100) NOT NULL UNIQUE,
    setting_value TEXT NOT NULL,
    description TEXT COMMENT 'توضیحات فارسی',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_setting_key (setting_key),
    INDEX idx_active (is_active, created_at)
) ENGINE=InnoDB 
  CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci 
  COMMENT='تنظیمات سیستم';
```

## 🧪 Testing Strategy

### Unit Testing (Flutter)
```dart
// test/services/api_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:datasave/core/services/api_service.dart';

void main() {
  group('ApiService Tests', () {
    late ApiService apiService;
    late MockHttpClient mockHttpClient;
    
    setUp(() {
      mockHttpClient = MockHttpClient();
      apiService = ApiService(httpClient: mockHttpClient);
    });
    
    test('should return success response for valid request', () async {
      // تست موفقیت آمیز درخواست
      // Test successful request
      
      // Arrange
      when(mockHttpClient.get(any))
        .thenAnswer((_) async => MockHttpResponse(200, '{"success": true}'));
      
      // Act
      final result = await apiService.getSystemInfo();
      
      // Assert
      expect(result.success, true);
    });
    
    test('should handle Persian content correctly', () async {
      // تست محتوای فارسی
      // Test Persian content handling
      
      final persianText = 'سلام دنیا';
      final result = await apiService.processText(persianText);
      
      expect(result.data, contains('سلام'));
    });
  });
}
```

### Integration Testing
```dart
// integration_test/app_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:datasave/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('DataSave App Integration Tests', () {
    testWidgets('should load dashboard correctly', (tester) async {
      // شروع برنامه
      // Start app
      app.main();
      await tester.pumpAndSettle();
      
      // تست وجود عناصر اصلی
      // Test main elements exist
      expect(find.text('داشبورد'), findsOneWidget);
      expect(find.byType(StatCard), findsWidgets);
      
      // تست فارسی بودن محتوا
      // Test Persian content
      expect(find.textContaining('تنظیمات'), findsOneWidget);
    });
    
    testWidgets('should navigate to settings page', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // کلیک روی تنظیمات
      // Click on settings
      await tester.tap(find.text('تنظیمات'));
      await tester.pumpAndSettle();
      
      // تست نمایش صفحه تنظیمات
      // Test settings page display
      expect(find.text('تنظیمات سیستم'), findsOneWidget);
    });
  });
}
```

### API Testing (PHP)
```php
<?php
// tests/api/SettingsApiTest.php
use PHPUnit\Framework\TestCase;

class SettingsApiTest extends TestCase 
{
    private $apiBase = 'http://localhost/datasave-api';
    
    public function testGetSettings(): void 
    {
        $response = $this->makeRequest('/api/settings/get.php');
        
        $this->assertTrue($response['success']);
        $this->assertIsArray($response['data']);
        $this->assertArrayHasKey('openai_api_key', $response['data']);
    }
    
    public function testUpdateSettingWithPersianContent(): void 
    {
        $persianValue = 'مقدار فارسی';
        
        $response = $this->makeRequest('/api/settings/update.php', [
            'key' => 'test_persian',
            'value' => $persianValue
        ]);
        
        $this->assertTrue($response['success']);
        $this->assertEquals($persianValue, $response['data']['value']);
    }
    
    private function makeRequest(string $endpoint, array $data = []): array 
    {
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $this->apiBase . $endpoint);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Content-Type: application/json; charset=utf-8'
        ]);
        
        $response = curl_exec($ch);
        curl_close($ch);
        
        return json_decode($response, true);
    }
}
```

## 🚀 Build & Deployment

### Flutter Web Build
```bash
# Development build
flutter build web --debug --web-renderer html

# Production build  
flutter build web --release --web-renderer html --base-href="/datasave/"

# Build with Persian optimization
flutter build web \
  --release \
  --web-renderer html \
  --dart-define=FLUTTER_WEB_USE_SKIA=false \
  --base-href="/datasave/" \
  --source-maps
```

### Backend Deployment (XAMPP)
```yaml
Deployment Steps:
  1. Code Review:
     - Persian RTL compatibility
     - Security validation  
     - Performance optimization
     - Error handling
  
  2. File Copy:
     - Source: ./backend/*
     - Destination: /Applications/XAMPP/xamppfiles/htdocs/datasave-api/
     - Permissions: 755 for directories, 644 for files
  
  3. Database Migration:
     - Backup current database
     - Run migration scripts
     - Verify Persian content integrity
  
  4. Configuration:
     - Update config/database.php
     - Set environment variables
     - Configure CORS settings
  
  5. Testing:
     - API endpoint testing
     - Persian content validation
     - Performance benchmarks
```

### Production Checklist
```yaml
Pre-Deployment:
  ✓ All tests passing
  ✓ Persian content validated
  ✓ Security review completed
  ✓ Performance optimization
  ✓ Documentation updated
  
  ✓ Database backup created
  ✓ API endpoints tested
  ✓ Error handling verified
  ✓ Logs configured
  ✓ Monitoring setup

Flutter Web:
  ✓ Release build successful
  ✓ Vazirmatn fonts loading
  ✓ RTL layout correct
  ✓ Persian numbers displaying
  ✓ Service worker updated

Backend API:
  ✓ PHP version compatibility
  ✓ MySQL connection tested
  ✓ CORS configured
  ✓ Error logging enabled
  ✓ Security headers set
```

## 🔄 Version Control (Git)

### Branching Strategy
```yaml
Branch Structure:
  main: 
    - Production-ready code
    - Protected branch
    - Require pull request reviews
  
  develop:
    - Integration branch
    - Feature testing
    - Pre-production code
  
  feature/*:
    - New feature development
    - Branch from develop
    - Merge back to develop
  
  hotfix/*:
    - Critical bug fixes
    - Branch from main
    - Merge to main and develop
  
  release/*:
    - Release preparation
    - Version tagging
    - Final testing

Persian Naming:
  feature/persian-rtl-support
  feature/vazirmatn-font-integration
  hotfix/persian-number-display
  release/v1.0.0-persian-launch
```

### Commit Message Standards
```yaml
Format: <type>(scope): <description>

Types:
  feat: ویژگی جدید (new feature)
  fix: رفع باگ (bug fix)  
  docs: مستندات (documentation)
  style: فرمت کد (code style)
  refactor: بازساختاری (refactoring)
  test: تست (testing)
  chore: کارهای جانبی (maintenance)

Examples:
  feat(ui): add Persian RTL support to dashboard
  fix(api): resolve Persian text encoding in database
  docs(readme): update installation guide in Persian
  style(theme): improve Vazirmatn font loading
  test(integration): add Persian content validation tests

Persian Commits (when appropriate):
  feat: اضافه کردن پشتیبانی RTL فارسی
  fix: رفع مشکل نمایش اعداد فارسی
  docs: بروزرسانی مستندات نصب
```

### Pre-commit Hooks
```bash
#!/bin/sh
# .git/hooks/pre-commit

# Run Flutter formatting
flutter format --set-exit-if-changed lib/ test/

# Run Dart analysis
flutter analyze

# Run tests
flutter test

# Check Persian text encoding
grep -r $'[^\x00-\x7F]' lib/ | grep -v '\.dart:.*//.*فارسی'

# PHP formatting and validation
if [ -d "backend" ]; then
    php -l backend/**/*.php
    phpcs backend/ --standard=PSR12
fi

echo "✅ Pre-commit checks passed"
```

## 📊 Monitoring & Maintenance

### Performance Monitoring
```yaml
Flutter Web Metrics:
  - First Contentful Paint (FCP): < 2s
  - Largest Contentful Paint (LCP): < 3s  
  - Persian Font Loading: < 1s
  - Time to Interactive (TTI): < 4s
  - Bundle Size: < 2MB compressed

API Performance:
  - Response Time: < 500ms average
  - Database Query Time: < 100ms
  - Persian Text Processing: < 50ms
  - Error Rate: < 1%
  - Uptime: > 99.5%

Tools:
  - Flutter DevTools: Performance profiling
  - Chrome DevTools: Web performance
  - MySQL Slow Query Log: Database optimization
  - PHP Error Log: Backend monitoring
```

### Logging Strategy
```yaml
Flutter Logging:
  - Debug: Development issues
  - Info: User actions, system events
  - Warning: Non-critical issues  
  - Error: Critical failures
  - Persian: Log messages in appropriate language

PHP Logging:
  - Access Log: Request tracking
  - Error Log: PHP errors and exceptions
  - Query Log: Database performance
  - Custom Log: Business logic events

Log Rotation:
  - Daily rotation for high-volume logs
  - Weekly archival for analysis logs
  - Monthly cleanup for debug logs
  - Persian date format in log names
```

### Database Maintenance
```sql
-- Daily maintenance tasks
-- تسک‌های نگهداری روزانه

-- Optimize Persian text indexes
OPTIMIZE TABLE system_settings, system_logs;

-- Update table statistics
ANALYZE TABLE system_settings, system_logs;

-- Clean old logs (keep last 30 days)
DELETE FROM system_logs 
WHERE created_at < DATE_SUB(NOW(), INTERVAL 30 DAY);

-- Backup Persian content
mysqldump -u root -p --default-character-set=utf8mb4 \
  --single-transaction datasave > backup_$(date +%Y%m%d).sql
```

### Update Procedures
```yaml
Flutter Updates:
  1. Check Flutter version compatibility
  2. Update pubspec.yaml dependencies
  3. Run flutter pub upgrade
  4. Test Persian functionality
  5. Update documentation

Backend Updates:
  1. Test PHP version compatibility
  2. Update Composer dependencies
  3. Run database migrations
  4. Validate Persian content
  5. Deploy to staging first

Persian Content Updates:
  1. Validate UTF-8 encoding
  2. Check RTL layout correctness
  3. Test font rendering
  4. Verify number formatting
  5. Update translation files
```

## 🐛 Debugging & Troubleshooting

### Common Issues & Solutions
```yaml
Persian Font Not Loading:
  Problem: Vazirmatn font not displaying
  Check: web/fonts/ directory exists
  Solution: Preload fonts in index.html
  Verify: DevTools Network tab for font requests

RTL Layout Issues:
  Problem: Components not RTL-aligned
  Check: Directionality widget wrapping
  Solution: Add Directionality(textDirection: TextDirection.rtl)
  Verify: Element positioning in browser inspector

Database Persian Content:
  Problem: Persian text showing as ????
  Check: Connection charset=utf8mb4
  Solution: ALTER DATABASE datasave CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
  Verify: SELECT @@character_set_database;

API CORS Issues:
  Problem: Web app can't connect to API
  Check: CORS headers in PHP responses
  Solution: Add Access-Control-Allow-Origin headers
  Verify: Network tab in browser DevTools
```

### Debug Tools & Commands
```bash
# Flutter debugging
flutter doctor -v
flutter logs
flutter run -d web-server --web-port 8080

# Database debugging
mysql -u root -p -h localhost -P 3307 -e "SHOW VARIABLES LIKE 'character_set%'"

# PHP debugging
php -m | grep mbstring
php -i | grep -i charset

# Web server debugging
tail -f /Applications/XAMPP/xamppfiles/logs/access_log
tail -f /Applications/XAMPP/xamppfiles/logs/error_log
```

### Performance Debugging
```yaml
Flutter Web Performance:
  - Use flutter run --profile
  - Enable Performance overlay
  - Monitor memory usage in DevTools
  - Profile Persian text rendering
  - Check font loading timeline

Database Performance:
  - Enable slow query log
  - Monitor Persian text queries
  - Check index usage: EXPLAIN SELECT
  - Profile UTF-8 operations
  - Monitor connection pools

API Performance:
  - Use PHP profiling tools (Xdebug)
  - Monitor response times
  - Check Persian text processing
  - Profile JSON encoding/decoding
  - Monitor memory usage
```

## 📋 Development Workflow

### Daily Workflow
```yaml
Start of Day:
  1. Pull latest changes: git pull origin develop
  2. Start XAMPP services: xampp startapache startmysql
  3. Check system status: flutter doctor
  4. Run tests: flutter test
  5. Start development server: flutter run -d web

During Development:
  1. Create feature branch: git checkout -b feature/new-feature
  2. Write code with Persian comments
  3. Test Persian functionality regularly
  4. Commit frequently with descriptive messages
  5. Push to remote: git push origin feature/new-feature

End of Day:
  1. Run full test suite
  2. Check Persian content validation
  3. Update documentation if needed
  4. Create pull request for review
  5. Stop XAMPP services
```

### Code Review Process
```yaml
Pull Request Requirements:
  ✓ All tests passing
  ✓ Persian RTL functionality tested
  ✓ Code follows standards
  ✓ Documentation updated
  ✓ Performance impact assessed

Review Checklist:
  - Persian content handling correct
  - RTL layout implementation proper
  - Font loading optimization
  - Security validation complete
  - Error handling comprehensive
  - Performance within limits

Approval Process:
  1. Author self-review
  2. Automated tests pass
  3. Peer review by team member
  4. Persian content specialist review
  5. Final approval by lead developer
```

### Release Workflow
```yaml
Pre-Release (1 week before):
  - Code freeze on develop branch
  - Create release branch: release/v1.x.x
  - Final testing phase
  - Persian content validation
  - Performance benchmarking

Release Day:
  1. Final tests on release branch
  2. Merge release to main: git merge --no-ff release/v1.x.x
  3. Create release tag: git tag v1.x.x
  4. Build production version
  5. Deploy to production
  6. Update documentation
  7. Announce release

Post-Release:
  - Monitor system performance
  - Check Persian functionality
  - Gather user feedback
  - Plan next iteration
  - Update issue tracker
```

## ⚠️ Important Notes

### Security Considerations
```yaml
API Security:
  - Input validation for Persian text
  - SQL injection prevention
  - XSS protection for Persian content
  - Rate limiting implementation
  - Authentication & authorization

Data Security:
  - Persian text encryption at rest
  - Secure database connections
  - API key protection
  - User data privacy
  - GDPR compliance considerations

Web Security:
  - HTTPS enforcement
  - Content Security Policy
  - CORS configuration
  - Secure font loading
  - Persian keyboard input protection
```

### Performance Best Practices
1. **Font Optimization**: Preload Vazirmatn fonts
2. **Persian Text**: Optimize UTF-8 processing
3. **RTL Layout**: Cache layout calculations  
4. **Database**: Index Persian content columns
5. **API**: Compress Persian responses

### Maintenance Schedule
```yaml
Daily:
  - Monitor system logs
  - Check Persian functionality
  - Performance metrics review

Weekly:  
  - Database optimization
  - Security updates check
  - Persian content backup

Monthly:
  - Full system backup
  - Performance audit
  - Documentation review
  - Dependency updates

Quarterly:
  - Security audit
  - Persian localization review
  - Architecture assessment
  - Team training updates
```

## 🔄 Related Documentation
- [Project Overview](../00-Project-Overview/README.md)
- [Backend APIs](../02-Backend-APIs/README.md)  
- [Flutter Architecture](../04-Flutter-Frontend/README.md)
- [UI/UX Design](../06-UI-UX-Design/README.md)

---
*این مستندات بخشی از مجموعه مستندات فنی پروژه DataSave است*  
*Last updated: 2025-01-09*  
*File: /docs/07-Development-Workflow/README.md*
