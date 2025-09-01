# استراتژی تست - Testing Strategy

## 📊 Document Information
- **Created:** 2025-09-01
- **Last Updated:** 2025-09-01
- **Version:** 1.0
- **Maintainer:** DataSave Development Team
- **Related Files:** `/test/`, `/backend/tests/`

## 🎯 Overview
استراتژی جامع تست در DataSave شامل Unit Testing، Widget Testing، Integration Testing و End-to-End Testing برای اطمینان از کیفیت کد و عملکرد صحیح سیستم.

## 📋 Table of Contents
- [فلسفه تست](#فلسفه-تست)
- [انواع تست](#انواع-تست)
- [Test Structure](#test-structure)
- [Flutter Testing](#flutter-testing)
- [PHP Backend Testing](#php-backend-testing)
- [API Testing](#api-testing)
- [Performance Testing](#performance-testing)
- [Automation & CI/CD](#automation--cicd)

## 🧪 فلسفه تست - Testing Philosophy

### Testing Pyramid
```yaml
Testing Levels:
  Unit Tests (70%):
    - Business logic
    - Utility functions
    - Data models
    - Services
    
  Integration Tests (20%):
    - API integrations
    - Database operations
    - Service interactions
    - Widget interactions
    
  End-to-End Tests (10%):
    - Complete user workflows
    - Cross-platform scenarios
    - Performance benchmarks
    - UI/UX validation

Goals:
  - Fast feedback loop
  - High code coverage (80%+)
  - Reliable and stable tests
  - Easy maintenance
  - Persian RTL compatibility
```

### Test Principles
```yaml
Quality Standards:
  - AAA Pattern (Arrange, Act, Assert)
  - Single responsibility per test
  - Clear and descriptive test names
  - Independent and isolated tests
  - Repeatable and deterministic

Persian Testing:
  - RTL layout testing
  - Persian text rendering
  - Number formatting (Persian digits)
  - Date/time localization
  - Keyboard input (Persian)
```

---

## 🔬 انواع تست - Test Types

### Unit Tests
```dart
// test/unit/services/api_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:datasave/core/services/api_service.dart';

class MockHttpClient extends Mock implements HttpClient {}

void main() {
  group('ApiService', () {
    late ApiService apiService;
    late MockHttpClient mockHttpClient;

    setUp(() {
      mockHttpClient = MockHttpClient();
      apiService = ApiService(httpClient: mockHttpClient);
    });

    tearDown(() {
      // Cleanup after each test
    });

    test('should return settings when API call is successful', () async {
      // Arrange
      final expectedResponse = {
        'success': true,
        'data': [
          {
            'setting_key': 'openai_api_key',
            'setting_value': 'test-key',
            'setting_type': 'encrypted'
          }
        ]
      };

      when(mockHttpClient.get(any))
          .thenAnswer((_) async => MockResponse(expectedResponse));

      // Act
      final result = await apiService.getSettings();

      // Assert
      expect(result, isNotNull);
      expect(result!.length, equals(1));
      expect(result[0]['setting_key'], equals('openai_api_key'));
    });

    test('should handle API errors gracefully', () async {
      // Arrange
      when(mockHttpClient.get(any))
          .thenThrow(Exception('Network error'));

      // Act & Assert
      expect(() => apiService.getSettings(), throwsException);
    });

    test('should format Persian numbers correctly', () {
      // Arrange
      const input = '12345';
      const expected = '۱۲۳۴۵';

      // Act
      final result = PersianNumberFormatter.format(input);

      // Assert
      expect(result, equals(expected));
    });
  });
}
```

### Widget Tests
```dart
// test/widget/components/stat_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:datasave/presentation/widgets/shared/stat_card.dart';

void main() {
  group('StatCard Widget', () {
    testWidgets('should display title and value correctly', (WidgetTester tester) async {
      // Arrange
      const title = 'تنظیمات';
      const value = '9';
      const icon = Icons.settings;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatCard(
              title: title,
              value: value,
              icon: icon,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(title), findsOneWidget);
      expect(find.text(value), findsOneWidget);
      expect(find.byIcon(icon), findsOneWidget);
    });

    testWidgets('should handle tap events', (WidgetTester tester) async {
      // Arrange
      bool tapped = false;
      void onTap() => tapped = true;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatCard(
              title: 'تست',
              value: '1',
              icon: Icons.test_tube,
              onTap: onTap,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(StatCard));
      await tester.pump();

      // Assert
      expect(tapped, isTrue);
    });

    testWidgets('should support RTL layout', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale('fa', 'IR'),
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: StatCard(
                title: 'آزمون',
                value: '۱۲۳',
                icon: Icons.test_tube,
              ),
            ),
          ),
        ),
      );

      // Assert
      final directionality = tester.widget<Directionality>(
        find.ancestor(
          of: find.byType(StatCard),
          matching: find.byType(Directionality),
        ),
      );
      expect(directionality.textDirection, equals(TextDirection.rtl));
    });

    testWidgets('should apply color correctly', (WidgetTester tester) async {
      // Arrange
      const testColor = Colors.green;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatCard(
              title: 'تست',
              value: '1',
              icon: Icons.check,
              color: testColor,
            ),
          ),
        ),
      );

      // Act & Assert
      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.color, equals(testColor));
    });
  });
}
```

### Integration Tests
```dart
// test/integration/app_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:datasave/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('DataSave App Integration', () {
    testWidgets('complete app flow test', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();

      // Test 1: App loads successfully
      expect(find.text('داشبورد'), findsOneWidget);

      // Test 2: Navigate to Settings
      await tester.tap(find.text('تنظیمات'));
      await tester.pumpAndSettle();
      expect(find.text('تنظیمات سیستم'), findsOneWidget);

      // Test 3: Modify OpenAI settings
      final apiKeyField = find.byKey(Key('openai_api_key_field'));
      await tester.enterText(apiKeyField, 'test-api-key');
      await tester.pump();

      // Test 4: Save settings
      await tester.tap(find.byKey(Key('save_settings_button')));
      await tester.pumpAndSettle();

      // Test 5: Verify success message
      expect(find.text('تنظیمات با موفقیت ذخیره شد'), findsOneWidget);

      // Test 6: Navigate to Logs
      await tester.tap(find.text('گزارش‌ها'));
      await tester.pumpAndSettle();
      expect(find.text('گزارش‌های سیستم'), findsOneWidget);

      // Test 7: Check logs are loaded
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('API integration test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test API connection
      await tester.tap(find.byKey(Key('test_connection_button')));
      await tester.pumpAndSettle(Duration(seconds: 3));

      // Verify connection result
      expect(find.textContaining('اتصال'), findsOneWidget);
    });
  });
}
```

---

## 📱 Flutter Testing

### Mock Data & Services
```dart
// test/mocks/mock_services.dart
import 'package:mockito/mockito.dart';
import 'package:datasave/core/services/api_service.dart';
import 'package:datasave/core/services/openai_service.dart';

// Mock API Service
class MockApiService extends Mock implements ApiService {
  @override
  Future<List<Map<String, dynamic>>?> getSettings() async {
    return [
      {
        'id': 1,
        'setting_key': 'openai_api_key',
        'setting_value': 'mock-key',
        'setting_type': 'encrypted',
        'description': 'Mock OpenAI Key',
        'is_system': true,
      }
    ];
  }

  @override
  Future<bool> saveSettings(Map<String, dynamic> settings) async {
    return true; // Always successful in tests
  }

  @override
  Future<List<Map<String, dynamic>>?> getLogs() async {
    return [
      {
        'id': 1,
        'level': 'info',
        'category': 'System',
        'message': 'Test log message',
        'created_at': DateTime.now().toIso8601String(),
      }
    ];
  }
}

// Mock OpenAI Service
class MockOpenAIService extends Mock implements OpenAIService {
  @override
  Future<String?> chatCompletion({
    required String message,
    List<Map<String, String>>? conversationHistory,
    String? systemPrompt,
  }) async {
    return 'Mock AI Response: $message';
  }

  @override
  Future<Map<String, dynamic>?> generateForm({
    required String description,
    String? formType,
    List<String>? requiredFields,
  }) async {
    return {
      'title': 'فرم تستی',
      'description': 'فرم تولید شده برای تست',
      'fields': [
        {
          'id': 'name',
          'type': 'text',
          'label': 'نام',
          'required': true,
        }
      ]
    };
  }
}
```

### Golden Tests
```dart
// test/golden/widgets/stat_card_golden_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:datasave/presentation/widgets/shared/stat_card.dart';

void main() {
  group('StatCard Golden Tests', () {
    testGoldens('StatCard various states', (WidgetTester tester) async {
      final builder = DeviceBuilder()
        ..overrideDevicesForAllScenarios(devices: [Device.phone])
        ..addScenario(
          widget: StatCard(
            title: 'تنظیمات',
            value: '9',
            icon: Icons.settings,
            color: Colors.blue,
          ),
          name: 'default_state',
        )
        ..addScenario(
          widget: StatCard(
            title: 'اطلاعات',
            value: '۱۰۷',
            icon: Icons.info,
            color: Colors.green,
          ),
          name: 'persian_numbers',
        )
        ..addScenario(
          widget: StatCard(
            title: 'خطا',
            value: '۰',
            icon: Icons.error,
            color: Colors.red,
          ),
          name: 'error_state',
        );

      await tester.pumpDeviceBuilder(builder);
      await screenMatchesGolden(tester, 'stat_card_variations');
    });

    testGoldens('StatCard RTL support', (WidgetTester tester) async {
      await tester.pumpWidgetBuilder(
        Directionality(
          textDirection: TextDirection.rtl,
          child: StatCard(
            title: 'آزمون راست به چپ',
            value: '۱۲۳',
            icon: Icons.language,
          ),
        ),
        wrapper: materialAppWrapper(
          locale: Locale('fa', 'IR'),
        ),
      );

      await screenMatchesGolden(tester, 'stat_card_rtl');
    });
  });
}
```

### Performance Tests
```dart
// test/performance/widget_performance_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:datasave/presentation/pages/dashboard_page.dart';

void main() {
  group('Performance Tests', () {
    testWidgets('Dashboard page rendering performance', (WidgetTester tester) async {
      // Measure build time
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(home: DashboardPage()),
      );
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Assert reasonable build time (< 100ms)
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    testWidgets('StatCard list scrolling performance', (WidgetTester tester) async {
      // Create list with many StatCards
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: 100,
              itemBuilder: (context, index) => StatCard(
                title: 'آیتم $index',
                value: '$index',
                icon: Icons.star,
              ),
            ),
          ),
        ),
      );

      // Measure scroll performance
      await tester.fling(find.byType(ListView), Offset(0, -500), 1000);
      await tester.pumpAndSettle();

      // No specific assertions - mainly checking for crashes/jank
    });
  });
}
```

---

## 🔧 PHP Backend Testing

### Unit Tests (PHP)
```php
<?php
// backend/tests/ApiResponseTest.php
require_once '../classes/ApiResponse.php';

class ApiResponseTest extends PHPUnit\Framework\TestCase {
    
    public function testSuccessResponse() {
        // Arrange
        $data = ['key' => 'value'];
        $message = 'تست موفق';
        
        // Act
        ob_start();
        ApiResponse::success($data, $message);
        $output = ob_get_clean();
        
        // Assert
        $response = json_decode($output, true);
        $this->assertTrue($response['success']);
        $this->assertEquals($message, $response['message']);
        $this->assertEquals($data, $response['data']);
    }
    
    public function testErrorResponse() {
        // Arrange
        $message = 'خطای تست';
        $code = 400;
        
        // Act
        ob_start();
        ApiResponse::clientError($message, $code);
        $output = ob_get_clean();
        
        // Assert  
        $response = json_decode($output, true);
        $this->assertFalse($response['success']);
        $this->assertEquals($message, $response['message']);
        $this->assertEquals($code, $response['code']);
    }
    
    public function testValidateJsonData() {
        // Test valid JSON
        $validJson = '{"key": "value"}';
        $this->assertTrue(ApiResponse::validateJson($validJson));
        
        // Test invalid JSON
        $invalidJson = '{"key": value}';
        $this->assertFalse(ApiResponse::validateJson($invalidJson));
    }
}
```

### API Endpoint Tests
```php
<?php
// backend/tests/SettingsApiTest.php
require_once '../api/settings/get.php';
require_once '../config/database.php';

class SettingsApiTest extends PHPUnit\Framework\TestCase {
    
    protected $db;
    
    protected function setUp(): void {
        // Create test database connection
        $this->db = Database::getTestConnection();
        
        // Insert test data
        $sql = "INSERT INTO system_settings (setting_key, setting_value, setting_type) VALUES (?, ?, ?)";
        $stmt = $this->db->prepare($sql);
        $stmt->execute(['test_key', 'test_value', 'string']);
    }
    
    protected function tearDown(): void {
        // Clean test data
        $this->db->query("DELETE FROM system_settings WHERE setting_key = 'test_key'");
    }
    
    public function testGetSettingsSuccess() {
        // Act
        ob_start();
        include '../api/settings/get.php';
        $output = ob_get_clean();
        
        // Assert
        $response = json_decode($output, true);
        $this->assertTrue($response['success']);
        $this->assertIsArray($response['data']);
        $this->assertGreaterThan(0, count($response['data']));
    }
    
    public function testGetSettingsWithDatabase() {
        // Test direct database query
        $sql = "SELECT * FROM system_settings WHERE setting_key = 'test_key'";
        $stmt = $this->db->query($sql);
        $result = $stmt->fetchAll();
        
        $this->assertCount(1, $result);
        $this->assertEquals('test_key', $result[0]['setting_key']);
        $this->assertEquals('test_value', $result[0]['setting_value']);
    }
}
```

### Database Tests
```php
<?php
// backend/tests/DatabaseTest.php
require_once '../config/database.php';

class DatabaseTest extends PHPUnit\Framework\TestCase {
    
    public function testDatabaseConnection() {
        // Act
        $db = Database::getConnection();
        
        // Assert
        $this->assertInstanceOf(PDO::class, $db);
        $this->assertEquals(PDO::ERRMODE_EXCEPTION, $db->getAttribute(PDO::ATTR_ERRMODE));
    }
    
    public function testDatabaseCharset() {
        // Act
        $db = Database::getConnection();
        $charset = $db->query("SELECT @@character_set_database")->fetchColumn();
        
        // Assert
        $this->assertEquals('utf8mb4', $charset);
    }
    
    public function testTableExists() {
        // Test system_settings table exists
        $db = Database::getConnection();
        $sql = "SHOW TABLES LIKE 'system_settings'";
        $result = $db->query($sql)->fetchAll();
        
        $this->assertCount(1, $result);
    }
    
    public function testPersianDataStorage() {
        // Test Persian text storage and retrieval
        $db = Database::getConnection();
        $persian_text = 'متن فارسی تست ۱۲۳۴۵';
        
        // Insert Persian text
        $sql = "INSERT INTO system_settings (setting_key, setting_value, setting_type) VALUES (?, ?, ?)";
        $stmt = $db->prepare($sql);
        $stmt->execute(['persian_test', $persian_text, 'string']);
        
        // Retrieve and verify
        $sql = "SELECT setting_value FROM system_settings WHERE setting_key = 'persian_test'";
        $result = $db->query($sql)->fetchColumn();
        
        $this->assertEquals($persian_text, $result);
        
        // Cleanup
        $db->query("DELETE FROM system_settings WHERE setting_key = 'persian_test'");
    }
}
```

---

## 🌐 API Testing

### Postman Collections
```json
{
  "info": {
    "name": "DataSave API Tests",
    "description": "Complete API test suite for DataSave",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item": [
    {
      "name": "Settings API",
      "item": [
        {
          "name": "Get All Settings",
          "request": {
            "method": "GET",
            "header": [],
            "url": {
              "raw": "{{base_url}}/api/settings/get.php",
              "host": ["{{base_url}}"],
              "path": ["api", "settings", "get.php"]
            }
          },
          "event": [
            {
              "listen": "test",
              "script": {
                "exec": [
                  "pm.test('Status code is 200', function () {",
                  "    pm.response.to.have.status(200);",
                  "});",
                  "",
                  "pm.test('Response has success property', function () {",
                  "    var jsonData = pm.response.json();",
                  "    pm.expect(jsonData).to.have.property('success');",
                  "    pm.expect(jsonData.success).to.be.true;",
                  "});",
                  "",
                  "pm.test('Response contains data array', function () {",
                  "    var jsonData = pm.response.json();",
                  "    pm.expect(jsonData).to.have.property('data');",
                  "    pm.expect(jsonData.data).to.be.an('array');",
                  "});",
                  "",
                  "pm.test('Contains OpenAI settings', function () {",
                  "    var jsonData = pm.response.json();",
                  "    var hasOpenAIKey = jsonData.data.some(item => item.setting_key === 'openai_api_key');",
                  "    pm.expect(hasOpenAIKey).to.be.true;",
                  "});"
                ]
              }
            }
          ]
        },
        {
          "name": "Update Settings",
          "request": {
            "method": "POST",
            "header": [
              {
                "key": "Content-Type",
                "value": "application/json"
              }
            ],
            "body": {
              "mode": "raw",
              "raw": "{
  "openai_model": "gpt-3.5-turbo",
  "openai_max_tokens": "1500"
}"
            },
            "url": {
              "raw": "{{base_url}}/api/settings/update.php",
              "host": ["{{base_url}}"],
              "path": ["api", "settings", "update.php"]
            }
          },
          "event": [
            {
              "listen": "test",
              "script": {
                "exec": [
                  "pm.test('Update successful', function () {",
                  "    pm.response.to.have.status(200);",
                  "    var jsonData = pm.response.json();",
                  "    pm.expect(jsonData.success).to.be.true;",
                  "});"
                ]
              }
            }
          ]
        }
      ]
    },
    {
      "name": "Logs API",
      "item": [
        {
          "name": "Get System Logs",
          "request": {
            "method": "GET",
            "url": {
              "raw": "{{base_url}}/api/logs/get.php?limit=50&level=info",
              "host": ["{{base_url}}"],
              "path": ["api", "logs", "get.php"],
              "query": [
                {
                  "key": "limit",
                  "value": "50"
                },
                {
                  "key": "level",
                  "value": "info"
                }
              ]
            }
          }
        }
      ]
    }
  ],
  "variable": [
    {
      "key": "base_url",
      "value": "http://localhost/datasave/backend"
    }
  ]
}
```

### Newman CLI Testing
```bash
#!/bin/bash
# scripts/run_api_tests.sh

echo "🧪 شروع تست‌های API..."

# نصب Newman (اگر نصب نشده)
if ! command -v newman &> /dev/null; then
    echo "نصب Newman..."
    npm install -g newman
fi

# اجرای تست‌های Postman
newman run tests/postman/DataSave-API-Tests.json 
    --environment tests/postman/environments/local.json 
    --reporters cli,html 
    --reporter-html-export reports/api-test-report.html

# بررسی نتیجه
if [ $? -eq 0 ]; then
    echo "✅ تمام تست‌های API موفق بودند"
else
    echo "❌ برخی تست‌های API ناموفق بودند"
    exit 1
fi
```

---

## 🚀 Performance Testing

### Load Testing with K6
```javascript
// tests/performance/api_load_test.js
import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  stages: [
    { duration: '1m', target: 10 },  // Ramp up
    { duration: '3m', target: 20 },  // Stay at 20 users
    { duration: '1m', target: 0 },   // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95% of requests under 500ms
    http_req_failed: ['rate<0.05'],   // Error rate under 5%
  },
};

const BASE_URL = 'http://localhost/datasave/backend';

export default function() {
  // Test Get Settings API
  let response = http.get(`${BASE_URL}/api/settings/get.php`);
  check(response, {
    'Settings API status is 200': (r) => r.status === 200,
    'Settings API response time < 200ms': (r) => r.timings.duration < 200,
    'Settings API contains data': (r) => {
      const body = JSON.parse(r.body);
      return body.success === true && Array.isArray(body.data);
    },
  });

  sleep(1);

  // Test Logs API
  response = http.get(`${BASE_URL}/api/logs/get.php?limit=10`);
  check(response, {
    'Logs API status is 200': (r) => r.status === 200,
    'Logs API response time < 300ms': (r) => r.timings.duration < 300,
  });

  sleep(1);
}

export function handleSummary(data) {
  return {
    'reports/load-test-summary.html': htmlReport(data),
    'reports/load-test-summary.json': JSON.stringify(data),
  };
}
```

### Memory & Performance Profiling
```dart
// test/performance/memory_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:datasave/presentation/pages/dashboard_page.dart';

void main() {
  group('Memory Performance', () {
    testWidgets('Dashboard memory usage', (WidgetTester tester) async {
      // Measure memory before
      final memoryBefore = await tester.binding.defaultBinaryMessenger
          .send('flutter/platform', null);

      // Build dashboard multiple times
      for (int i = 0; i < 10; i++) {
        await tester.pumpWidget(MaterialApp(home: DashboardPage()));
        await tester.pumpAndSettle();
      }

      // Measure memory after
      final memoryAfter = await tester.binding.defaultBinaryMessenger
          .send('flutter/platform', null);

      // Verify no significant memory leaks
      // This is a basic example - real memory testing requires more sophisticated tools
    });
  });
}
```

---

## ⚡ Automation & CI/CD

### GitHub Actions Workflow
```yaml
# .github/workflows/test.yml
name: 🧪 Run Tests

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  flutter_tests:
    name: Flutter Tests
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
        
    - name: Install dependencies
      run: flutter pub get
      
    - name: Analyze code
      run: flutter analyze
      
    - name: Run unit tests
      run: flutter test --coverage
      
    - name: Run integration tests
      run: flutter test integration_test/
      
    - name: Upload coverage
      uses: codecov/codecov-action@v3
      with:
        file: coverage/lcov.info

  php_tests:
    name: PHP Backend Tests
    runs-on: ubuntu-latest
    
    services:
      mysql:
        image: mysql:8.0
        env:
          MYSQL_ROOT_PASSWORD: password
          MYSQL_DATABASE: datasave_test
        ports:
          - 3306:3306
        options: --health-cmd="mysqladmin ping" --health-interval=10s --health-timeout=5s --health-retries=3
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup PHP
      uses: shivammathur/setup-php@v2
      with:
        php-version: '8.1'
        extensions: mbstring, xml, ctype, iconv, intl, pdo, pdo_mysql
        
    - name: Install Composer dependencies
      run: |
        cd backend
        composer install --no-progress --prefer-dist --optimize-autoloader
        
    - name: Setup test database
      run: |
        mysql -h 127.0.0.1 -u root -ppassword -e "CREATE DATABASE IF NOT EXISTS datasave_test;"
        mysql -h 127.0.0.1 -u root -ppassword datasave_test < database_setup.sql
        
    - name: Run PHP tests
      run: |
        cd backend
        ./vendor/bin/phpunit tests/ --coverage-html reports/coverage

  api_tests:
    name: API Tests
    runs-on: ubuntu-latest
    needs: php_tests
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
        
    - name: Install Newman
      run: npm install -g newman
      
    - name: Start PHP server
      run: |
        cd backend
        php -S localhost:8000 &
        sleep 5
        
    - name: Run API tests
      run: |
        newman run tests/postman/DataSave-API-Tests.json 
          --environment tests/postman/environments/ci.json 
          --reporters cli,junit 
          --reporter-junit-export reports/newman-report.xml

  performance_tests:
    name: Performance Tests
    runs-on: ubuntu-latest
    if: github.event_name == 'pull_request'
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Install k6
      run: |
        sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D69
        echo "deb https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list
        sudo apt-get update
        sudo apt-get install k6
        
    - name: Run load tests
      run: k6 run tests/performance/api_load_test.js
```

### Test Coverage Reports
```bash
#!/bin/bash
# scripts/generate_coverage_report.sh

echo "📊 تولید گزارش Coverage..."

# Flutter test coverage
flutter test --coverage
genhtml coverage/lcov.info -o reports/flutter-coverage

# PHP test coverage (PHPUnit)
cd backend
./vendor/bin/phpunit --coverage-html reports/php-coverage

# Combined coverage report
echo "✅ گزارش‌های Coverage تولید شدند:"
echo "   - Flutter: reports/flutter-coverage/index.html"
echo "   - PHP: backend/reports/php-coverage/index.html"

# Open reports
open reports/flutter-coverage/index.html
open backend/reports/php-coverage/index.html
```

---

## ⚠️ Important Notes

### Best Practices
- تست‌ها باید سریع و قابل اعتماد باشند
- نام‌گذاری واضح و توصیفی برای تست‌ها
- Mock کردن dependencies خارجی
- تست‌های مستقل و ایزوله
- پوشش کد بالا (80%+)

### Common Pitfalls
- تست‌های وابسته به ترتیب اجرا
- Hard-coded values بجای test fixtures
- نادیده گرفتن edge cases
- تست‌های طولانی و کند
- عدم تست RTL layout

### Maintenance
- بروزرسانی منظم test data
- حذف تست‌های deprecated
- بهینه‌سازی performance تست‌ها
- مستندسازی test scenarios
- Review منظم test coverage

---

## 🔄 Related Documentation
- [Development Environment](development-environment.md)
- [Build Deployment](build-deployment.md)
- [Code Standards](code-standards.md)
- [Version Control](version-control.md)
- [Flutter Architecture](../04-Flutter-Frontend/flutter-architecture.md)

## 📚 References
- [Flutter Testing Guide](https://docs.flutter.dev/testing)
- [PHPUnit Documentation](https://phpunit.de/documentation.html)
- [Newman CLI](https://learning.postman.com/docs/running-collections/using-newman-cli/)
- [K6 Performance Testing](https://k6.io/docs/)
- [GitHub Actions](https://docs.github.com/en/actions)

---
*Last updated: 2025-09-01*  
*File: docs/07-Development-Workflow/testing-strategy.md*