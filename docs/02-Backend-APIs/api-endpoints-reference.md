# مرجع کامل API Endpoints - API Endpoints Reference

## 📊 Document Information
- **Created:** 2025-01-09
- **Last Updated:** 2025-03-03 (MVP 4.0 Analysis)
- **Version:** 2.0.0 (MVP 4.0 Business Intelligence APIs)
- **Maintainer:** DataSave Development Team
- **Related Files:** `/backend/api/`, `/backend/classes/ApiResponse.php`, MVP 4.0 API Extensions

## 🎯 Overview
مرجع کامل تمام API endpoints موجود در DataSave با جزئیات کامل درخواست‌ها، پاسخ‌ها، و نمونه کدها.

## 📋 Table of Contents
- [مشخصات کلی API](#مشخصات-کلی-api)
- [Authentication](#authentication)
- [Settings API](#settings-api)
- [Logs API](#logs-api)
- [System API](#system-api)
- [MVP 4.0 API Extensions](#mvp-40-api-extensions)
- [Error Handling](#error-handling)
- [نمونه کدهای Integration](#نمونه-کدهای-integration)

## 🌐 مشخصات کلی API - General API Specifications

### Base Configuration
```yaml
Base URL: http://localhost/datasave/backend/api/
Protocol: HTTP (Development), HTTPS (Production)
Content-Type: application/json
CORS: Enabled for localhost:8085
Charset: UTF-8
Language: Persian/English mixed
```

### Request/Response Format
```json
{
  "success": true,
  "data": {},
  "message": "پیام موفقیت",
  "timestamp": "2025-01-09T12:00:00Z",
  "count": 5
}
```

### HTTP Status Codes
| Code | Status | Description |
|------|--------|-------------|
| `200` | OK | درخواست موفق |
| `400` | Bad Request | داده‌های ورودی نامعتبر |
| `404` | Not Found | منبع یافت نشد |
| `405` | Method Not Allowed | متد HTTP مجاز نیست |
| `500` | Internal Server Error | خطای سرور |

## 🔐 Authentication

### Current Status
```yaml
Authentication: None (Development Only)
Authorization: None (Development Only)
CORS Policy: localhost:8085 only
Security: Basic validation only

Planned (Production):
  - JWT Token Authentication
  - Role-based Authorization  
  - API Key Management
  - Rate Limiting
```

### Future Authentication Header
```http
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
X-API-Key: datasave_api_key_here
Content-Type: application/json
Accept: application/json
```

## ⚙️ Settings API

### GET /api/settings/get.php

#### Description
دریافت تمام تنظیمات سیستم از جدول system_settings

#### Request
```http
GET /api/settings/get.php
Content-Type: application/json
```

#### Response Success (200)
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "setting_key": "openai_api_key",
      "setting_value": "sk-proj-VCZePdc2BFlqLTWg...",
      "setting_type": "encrypted",
      "description": "کلید API سرویس OpenAI",
      "is_system": true,
      "is_readonly": false,
      "created_at": "2024-12-01 10:00:00",
      "updated_at": "2025-01-09 12:00:00"
    },
    {
      "id": 2,
      "setting_key": "openai_model",
      "setting_value": "gpt-4",
      "setting_type": "string",
      "description": "مدل پیش‌فرض OpenAI برای درخواست‌ها",
      "is_system": true,
      "is_readonly": false,
      "created_at": "2024-12-01 10:00:00",
      "updated_at": "2024-12-01 10:00:00"
    }
  ],
  "message": "تنظیمات با موفقیت بارگذاری شد",
  "count": 9,
  "timestamp": "2025-01-09T12:00:00Z"
}
```

#### Response Error (500)
```json
{
  "success": false,
  "data": null,
  "message": "خطا در دریافت تنظیمات",
  "error": "Database connection failed",
  "timestamp": "2025-01-09T12:00:00Z"
}
```

#### Usage Example (JavaScript)
```javascript
// Fetch settings using JavaScript
async function getSettings() {
  try {
    const response = await fetch('http://localhost/datasave/backend/api/settings/get.php');
    const result = await response.json();
    
    if (result.success) {
      console.log('Settings loaded:', result.data);
      return result.data;
    } else {
      console.error('Failed to load settings:', result.message);
    }
  } catch (error) {
    console.error('Network error:', error);
  }
}
```

#### Usage Example (Dart/Flutter)
```dart
// Fetch settings in Flutter
Future<List<Map<String, dynamic>>?> getSettings() async {
  try {
    final response = await http.get(
      Uri.parse('http://localhost/datasave/backend/api/settings/get.php'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['success'] == true) {
        return List<Map<String, dynamic>>.from(result['data']);
      }
    }
  } catch (e) {
    print('Error fetching settings: $e');
  }
  return null;
}
```

### POST /api/settings/update.php

#### Description
بروزرسانی تنظیمات سیستم

#### Request
```http
POST /api/settings/update.php
Content-Type: application/json
```

#### Request Body
```json
{
  "setting_key": "openai_max_tokens",
  "setting_value": "4096"
}
```

#### Response Success (200)
```json
{
  "success": true,
  "data": {
    "setting_key": "openai_max_tokens",
    "old_value": "2048",
    "new_value": "4096",
    "updated_at": "2025-01-09T12:00:00Z"
  },
  "message": "تنظیمات با موفقیت بروزرسانی شد",
  "timestamp": "2025-01-09T12:00:00Z"
}
```

#### Usage Example (JavaScript)
```javascript
async function updateSetting(key, value) {
  try {
    const response = await fetch('http://localhost/datasave/backend/api/settings/update.php', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        setting_key: key,
        setting_value: value
      })
    });
    
    const result = await response.json();
    return result.success;
  } catch (error) {
    console.error('Update failed:', error);
    return false;
  }
}
```

### GET /api/settings/test.php

#### Description
تست اتصال به OpenAI API با تنظیمات فعلی

#### Request
```http
GET /api/settings/test.php
```

#### Response Success (200)
```json
{
  "success": true,
  "data": {
    "api_status": "connected",
    "model": "gpt-4",
    "test_response": "سلام! من GPT-4 هستم و به زبان فارسی پاسخ می‌دهم.",
    "response_time": 1.234,
    "token_usage": {
      "prompt_tokens": 15,
      "completion_tokens": 20,
      "total_tokens": 35
    }
  },
  "message": "اتصال OpenAI موفق بود",
  "timestamp": "2025-01-09T12:00:00Z"
}
```

#### Response Error (500)
```json
{
  "success": false,
  "data": {
    "api_status": "failed",
    "error_type": "authentication_error",
    "error_details": "Invalid API key provided"
  },
  "message": "خطا در اتصال به OpenAI",
  "timestamp": "2025-01-09T12:00:00Z"
}
```

## 📊 Logs API

### GET /api/logs/list.php

#### Description
دریافت لیست لاگ‌های اخیر سیستم

#### Request
```http
GET /api/logs/list.php?limit=20&level=ERROR&category=API
```

#### Query Parameters
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `limit` | integer | 20 | تعداد لاگ‌های برگشتی |
| `level` | string | all | فیلتر سطح لاگ (DEBUG, INFO, WARNING, ERROR, CRITICAL) |
| `category` | string | all | فیلتر دسته‌بندی (API, Database, System, Frontend) |

#### Response Success (200)
```json
{
  "success": true,
  "data": [
    {
      "log_id": 1234,
      "log_level": "INFO",
      "log_category": "API",
      "log_message": "درخواست دریافت تنظیمات",
      "log_context": {
        "endpoint": "/api/settings/get.php",
        "response_time": 0.123,
        "memory_usage": "2.5MB"
      },
      "ip_address": "127.0.0.1",
      "user_agent": "Mozilla/5.0...",
      "created_at": "2025-01-09T12:00:00Z"
    }
  ],
  "message": "لیست لاگ‌ها با موفقیت بارگذاری شد",
  "count": 20,
  "timestamp": "2025-01-09T12:00:00Z"
}
```

### POST /api/logs/create.php

#### Description
ثبت لاگ جدید در سیستم

#### Request
```http
POST /api/logs/create.php
Content-Type: application/json
```

#### Request Body
```json
{
  "log_level": "ERROR",
  "log_category": "Database", 
  "log_message": "خطا در اتصال به دیتابیس",
  "log_context": {
    "query": "SELECT * FROM users",
    "error_code": 2006,
    "connection_id": "db_conn_123"
  }
}
```

#### Response Success (200)
```json
{
  "success": true,
  "data": {
    "log_id": 1235,
    "created_at": "2025-01-09T12:00:00Z"
  },
  "message": "لاگ با موفقیت ثبت شد",
  "timestamp": "2025-01-09T12:00:00Z"
}
```

### GET /api/logs/stats.php

#### Description
آمار لاگ‌های سیستم

#### Response Success (200)
```json
{
  "success": true,
  "data": {
    "total_logs": 1567,
    "today_logs": 89,
    "levels": {
      "DEBUG": 45,
      "INFO": 35,
      "WARNING": 6,
      "ERROR": 2,
      "CRITICAL": 1
    },
    "categories": {
      "API": 25,
      "Database": 20,
      "System": 15,
      "Frontend": 18,
      "Backend": 11
    },
    "recent_errors": 3,
    "last_critical": "2025-01-08T14:30:00Z"
  },
  "message": "آمار لاگ‌ها با موفقیت محاسبه شد",
  "timestamp": "2025-01-09T12:00:00Z"
}
```

### DELETE /api/logs/clear.php

#### Description
پاک کردن لاگ‌های قدیمی

#### Request
```http
DELETE /api/logs/clear.php
Content-Type: application/json
```

#### Request Body (Optional)
```json
{
  "days": 30,
  "level": "DEBUG"
}
```

#### Response Success (200)
```json
{
  "success": true,
  "data": {
    "deleted_count": 456,
    "remaining_count": 1111
  },
  "message": "لاگ‌های قدیمی پاک شدند",
  "timestamp": "2025-01-09T12:00:00Z"
}
```

## 🖥️ System API

### GET /api/system/info.php

#### Description
اطلاعات کلی سیستم و وضعیت سرور

#### Response Success (200)
```json
{
  "success": true,
  "data": {
    "system": {
      "name": "DataSave",
      "version": "2.0.0",
      "environment": "development",
      "uptime": "15 days, 4 hours"
    },
    "database": {
      "status": "connected",
      "host": "localhost:3307",
      "database": "datasave_db",
      "charset": "utf8mb4_persian_ci",
      "tables": 2,
      "records": 509
    },
    "php": {
      "version": "8.2.4",
      "memory_limit": "256M",
      "memory_usage": "12.5MB",
      "extensions": ["pdo_mysql", "json", "curl"]
    },
    "disk": {
      "total": "512GB",
      "used": "125GB",
      "free": "387GB",
      "usage_percent": 24.4
    }
  },
  "message": "اطلاعات سیستم با موفقیت دریافت شد",
  "timestamp": "2025-01-09T12:00:00Z"
}
```

### GET /api/system/status.php

#### Description
بررسی سلامت سیستم و سرویس‌های مرتبط

#### Response Success (200)
```json
{
  "success": true,
  "data": {
    "overall_status": "healthy",
    "services": {
      "database": {
        "status": "up",
        "response_time": 0.023,
        "last_check": "2025-01-09T12:00:00Z"
      },
      "openai_api": {
        "status": "up", 
        "response_time": 1.234,
        "last_check": "2025-01-09T11:55:00Z"
      },
      "file_system": {
        "status": "up",
        "write_permissions": true,
        "disk_space": "387GB free"
      }
    },
    "performance": {
      "cpu_usage": "15%",
      "memory_usage": "45%",
      "active_connections": 3,
      "requests_per_minute": 25
    }
  },
  "message": "وضعیت سیستم بررسی شد",
  "timestamp": "2025-01-09T12:00:00Z"
}
```

## � MVP 4.0 API Extensions

### 🎯 Business Intelligence Platform APIs

#### **🤖 AI Services API**

##### POST /api/ai/chat
**Description:** چت interface برای AI Analytics Consultant

**Request:**
```json
{
  "message": "چند تا فرم امروز ثبت‌نام داشت؟",
  "conversation_id": 123,
  "context": {
    "user_id": 1,
    "form_id": 456
  }
}
```

**Response Success (200):**
```json
{
  "success": true,
  "data": {
    "response": "امروز ۱۵ فرم جدید ثبت‌نام شده است. این رقم نسبت به دیروز ۲۰٪ افزایش داشته.",
    "query_executed": "SELECT COUNT(*) FROM forms WHERE DATE(created_at) = CURDATE()",
    "visualization": {
      "type": "number_card",
      "value": 15,
      "trend": "+20%"
    },
    "confidence_score": 0.98
  },
  "message": "پاسخ با موفقیت تولید شد"
}
```

##### POST /api/ai/generate-form
**Description:** تولید فرم با AI Form Designer Wizard

**Request:**
```json
{
  "description": "یک فرم ثبت‌نام دوره آموزشی با فیلدهای نام، ایمیل، شماره تماس و سطح مهارت",
  "context": {
    "target_audience": "دانشجویان",
    "form_purpose": "ثبت‌نام دوره"
  }
}
```

#### **📊 Analytics API**

##### GET /api/analytics/dashboard-data
**Description:** داده‌های Dashboard Intelligence Hub

**Response Success (200):**
```json
{
  "success": true,
  "data": {
    "living_stats": {
      "total_forms": 45,
      "active_forms": 32,
      "total_responses": 1250,
      "today_responses": 89
    },
    "predictions": {
      "tomorrow_responses": 95,
      "confidence": 0.87,
      "trend": "increasing"
    },
    "insights": [
      {
        "type": "recommendation",
        "title": "بهترین زمان انتشار فرم",
        "description": "فرم‌های منتشر شده بین ساعت ۹-۱۱ صبح ۴۰٪ بیشتر پاسخ دریافت می‌کنند"
      }
    ]
  }
}
```

##### POST /api/analytics/custom-query
**Description:** اجرای query سفارشی با Natural Language

**Request:**
```json
{
  "question": "متوسط زمان تکمیل فرم‌ها در هفته گذشته چقدر بوده؟",
  "filters": {
    "date_range": "last_week",
    "form_type": "all"
  }
}
```

#### **🌐 Form as a Service API**

##### GET /api/embed/form/{id}
**Description:** رندر فرم برای embed در وبسایت‌های خارجی

**Request:**
```http
GET /api/embed/form/123?theme=minimal&lang=fa
```

**Response Success (200):**
```json
{
  "success": true,
  "data": {
    "html": "<form class='datasave-form'>...</form>",
    "css": ".datasave-form { direction: rtl; font-family: 'Vazirmatn'; }",
    "javascript": "window.DataSaveForm = { init: function() {...} }",
    "config": {
      "form_id": 123,
      "theme": "minimal",
      "language": "fa",
      "rtl": true
    }
  }
}
```

##### POST /api/embed/submit/{id}
**Description:** ارسال پاسخ فرم از وبسایت خارجی

**Request:**
```json
{
  "form_data": {
    "name": "علی احمدی", 
    "email": "ali@example.com"
  },
  "embed_info": {
    "domain": "example.com",
    "page_url": "https://example.com/contact",
    "embed_type": "javascript"
  }
}
```

#### **🔌 WordPress Integration API**

##### POST /api/wordpress/plugin-auth
**Description:** احراز هویت WordPress Plugin

**Request:**
```json
{
  "site_url": "https://mysite.com",
  "api_key": "wp_datasave_key_123",
  "plugin_version": "1.0.0"
}
```

##### GET /api/wordpress/forms-list
**Description:** لیست فرم‌ها برای WordPress Plugin

**Response Success (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 123,
      "title": "فرم تماس با ما",
      "shortcode": "[datasave-form id='123']",
      "embed_code": "<script>...</script>",
      "status": "published"
    }
  ]
}
```

#### **💡 Insights API**

##### GET /api/insights/patterns
**Description:** الگوهای شناسایی شده توسط AI

**Response Success (200):**
```json
{
  "success": true,
  "data": [
    {
      "pattern_type": "time_based",
      "title": "پیک ساعات پاسخ‌دهی",
      "description": "بیشتر کاربران بین ساعت ۱۴-۱۶ فرم پر می‌کنند",
      "confidence": 0.92,
      "recommendation": "فرم‌های مهم را در این بازه زمانی منتشر کنید"
    }
  ]
}
```

### 📊 API Enhancement Summary

#### **موجود (حفظ می‌شود):**
```yaml
✅ /api/settings/* - تنظیمات سیستم
✅ /api/logs/* - مدیریت لاگ‌ها  
✅ /api/system/* - اطلاعات سیستم
```

#### **جدید در MVP 4.0:**
```yaml
🆕 /api/ai/* - هوش مصنوعی
  - POST /api/ai/chat
  - POST /api/ai/generate-form
  - POST /api/ai/analyze-data
  - GET /api/ai/suggestions

🆕 /api/analytics/* - تحلیل داده‌ها
  - GET /api/analytics/dashboard-data
  - POST /api/analytics/custom-query
  - GET /api/analytics/insights
  - GET /api/analytics/predictions

🆕 /api/embed/* - فرم به عنوان سرویس
  - GET /api/embed/form/{id}
  - POST /api/embed/submit/{id}
  - GET /api/embed/analytics/{id}
  - GET /api/embed/config/{id}

🆕 /api/wordpress/* - پلاگین وردپرس
  - POST /api/wordpress/plugin-auth
  - GET /api/wordpress/forms-list
  - POST /api/wordpress/embed-form
  - GET /api/wordpress/analytics

🆕 /api/insights/* - بینش‌های هوشمند
  - GET /api/insights/patterns
  - POST /api/insights/query
  - GET /api/insights/predictions
  - GET /api/insights/recommendations
```

## �🚨 Error Handling

### Standard Error Response Format
```json
{
  "success": false,
  "data": null,
  "message": "پیام خطا به فارسی",
  "error": "Technical error message in English",
  "error_code": "API_ERROR_001",
  "timestamp": "2025-01-09T12:00:00Z",
  "debug_info": {
    "file": "/path/to/error/file.php",
    "line": 45,
    "trace": "Stack trace information"
  }
}
```

### Common Error Codes
| Code | HTTP Status | Description |
|------|-------------|-------------|
| `API_ERROR_001` | 400 | Invalid request parameters |
| `API_ERROR_002` | 404 | Endpoint not found |
| `API_ERROR_003` | 405 | Method not allowed |
| `DB_ERROR_001` | 500 | Database connection error |
| `DB_ERROR_002` | 500 | SQL query error |
| `OPENAI_ERROR_001` | 500 | OpenAI API authentication error |
| `OPENAI_ERROR_002` | 429 | OpenAI API rate limit exceeded |

### Error Handling Best Practices

#### PHP Backend
```php
<?php
try {
    // API logic here
    $result = performDatabaseOperation();
    ApiResponse::success($result, 'عملیات موفق');
    
} catch (PDOException $e) {
    error_log("Database Error: " . $e->getMessage());
    ApiResponse::serverError('خطا در دیتابیس', 'DB_ERROR_001');
    
} catch (Exception $e) {
    error_log("General Error: " . $e->getMessage());
    ApiResponse::serverError('خطای سرور', 'API_ERROR_001');
}
?>
```

#### Flutter Frontend
```dart
Future<ApiResult<List<Setting>>> getSettings() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/api/settings/get.php'),
      headers: {'Content-Type': 'application/json'},
    );

    final Map<String, dynamic> data = json.decode(response.body);
    
    if (data['success'] == true) {
      final List<Setting> settings = (data['data'] as List)
          .map((item) => Setting.fromJson(item))
          .toList();
      return ApiResult.success(settings);
    } else {
      return ApiResult.error(data['message'] ?? 'خطای نامشخص');
    }
  } on SocketException {
    return ApiResult.error('خطا در اتصال به سرور');
  } on FormatException {
    return ApiResult.error('خطا در پردازش داده‌ها');
  } catch (e) {
    return ApiResult.error('خطای غیرمنتظره: ${e.toString()}');
  }
}
```

## 🔧 نمونه کدهای Integration

### Complete API Service (Dart)
```dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost/datasave/backend/api';
  
  // Settings API
  static Future<List<Map<String, dynamic>>?> getSettings() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/settings/get.php'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['success'] == true) {
          return List<Map<String, dynamic>>.from(result['data']);
        }
      }
    } catch (e) {
      print('Error in getSettings: $e');
    }
    return null;
  }

  static Future<bool> updateSetting(String key, String value) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/settings/update.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'setting_key': key,
          'setting_value': value,
        }),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return result['success'] == true;
      }
    } catch (e) {
      print('Error in updateSetting: $e');
    }
    return false;
  }

  // Logs API  
  static Future<List<Map<String, dynamic>>?> getLogs({int limit = 20}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/logs/list.php?limit=$limit'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['success'] == true) {
          return List<Map<String, dynamic>>.from(result['data']);
        }
      }
    } catch (e) {
      print('Error in getLogs: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> getLogStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/logs/stats.php'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['success'] == true) {
          return result['data'];
        }
      }
    } catch (e) {
      print('Error in getLogStats: $e');
    }
    return null;
  }

  // System API
  static Future<Map<String, dynamic>?> getSystemInfo() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/system/info.php'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['success'] == true) {
          return result['data'];
        }
      }
    } catch (e) {
      print('Error in getSystemInfo: $e');
    }
    return null;
  }

  static Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/system/status.php'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }
}
```

### JavaScript Integration
```javascript
class DataSaveAPI {
  constructor() {
    this.baseUrl = 'http://localhost/datasave/backend/api';
  }

  async makeRequest(endpoint, options = {}) {
    const url = `${this.baseUrl}${endpoint}`;
    const config = {
      headers: {
        'Content-Type': 'application/json',
        ...options.headers
      },
      ...options
    };

    try {
      const response = await fetch(url, config);
      const data = await response.json();
      
      if (data.success) {
        return { success: true, data: data.data, message: data.message };
      } else {
        return { success: false, error: data.message };
      }
    } catch (error) {
      return { success: false, error: 'Network error: ' + error.message };
    }
  }

  // Settings
  async getSettings() {
    return await this.makeRequest('/settings/get.php');
  }

  async updateSetting(key, value) {
    return await this.makeRequest('/settings/update.php', {
      method: 'POST',
      body: JSON.stringify({ setting_key: key, setting_value: value })
    });
  }

  // Logs
  async getLogs(limit = 20) {
    return await this.makeRequest(`/logs/list.php?limit=${limit}`);
  }

  async getLogStats() {
    return await this.makeRequest('/logs/stats.php');
  }

  // System
  async getSystemInfo() {
    return await this.makeRequest('/system/info.php');
  }
}

// Usage
const api = new DataSaveAPI();

// Get settings
api.getSettings().then(result => {
  if (result.success) {
    console.log('Settings:', result.data);
  } else {
    console.error('Error:', result.error);
  }
});
```

## ⚠️ Important Notes

### Development vs Production
- **Current**: Development only (localhost)
- **CORS**: Configured for localhost:8085
- **Authentication**: None currently
- **Rate Limiting**: Not implemented
- **Caching**: Basic browser caching only

### Performance Considerations
- **Response Time**: Most APIs < 500ms
- **Database Queries**: Optimized with indexes
- **JSON Size**: Kept minimal for mobile
- **Error Logging**: All errors logged automatically

### Security Notes
- **Input Validation**: Basic PHP validation
- **SQL Injection**: Using prepared statements
- **XSS Protection**: Output encoding implemented
- **HTTPS**: Required for production

## 🔄 Related Documentation
- [PHP Backend Overview](./php-backend-overview.md)
- [Database Integration](./database-integration.md)
- [Error Handling](./error-handling.md)
- [Security Implementation](./security-implementation.md)

---
*Last updated: 2025-01-09*  
*File: /docs/02-Backend-APIs/api-endpoints-reference.md*
