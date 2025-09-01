# مرجع سریع API - API Quick Reference

## 📊 Document Information
- **Created:** 2025-01-09
- **Last Updated:** 2025-01-09
- **Version:** 1.0
- **Maintainer:** DataSave Development Team

## 🎯 Overview
مرجع سریع و خلاصه برای همه API endpoints موجود در DataSave.

## 🌐 Base URL & Headers
```
Base URL: http://localhost/datasave/backend/api/
Content-Type: application/json
Accept: application/json
```

## ⚙️ Settings API

### GET Settings
```http
GET /settings/get.php
```
**Response:** لیست تمام تنظیمات سیستم

### Update Setting
```http
POST /settings/update.php
Body: {"setting_key": "key", "setting_value": "value"}
```
**Response:** تایید بروزرسانی

### Test OpenAI
```http
GET /settings/test.php
```
**Response:** نتیجه تست اتصال OpenAI

## 📊 Logs API

### Get Logs
```http
GET /logs/list.php?limit=20&level=ERROR&category=API
```
**Parameters:**
- `limit`: تعداد (default: 20)
- `level`: سطح لاگ (optional)
- `category`: دسته‌بندی (optional)

### Create Log
```http
POST /logs/create.php
Body: {
  "log_level": "INFO",
  "log_category": "API", 
  "log_message": "پیام لاگ",
  "log_context": {}
}
```

### Log Statistics
```http
GET /logs/stats.php
```
**Response:** آمار کلی لاگ‌ها

### Clear Logs
```http
DELETE /logs/clear.php
Body: {"days": 30, "level": "DEBUG"}
```

## 🖥️ System API

### System Info
```http
GET /system/info.php
```
**Response:** اطلاعات سیستم و سرور

### System Status
```http
GET /system/status.php
```
**Response:** وضعیت سلامت سیستم

## 📝 Response Format
```json
{
  "success": true,
  "data": {},
  "message": "پیام موفقیت",
  "timestamp": "2025-01-09T12:00:00Z",
  "count": 0
}
```

## 🚨 Error Codes
| Code | Status | Description |
|------|--------|-------------|
| `200` | OK | موفق |
| `400` | Bad Request | داده نامعتبر |
| `404` | Not Found | یافت نشد |
| `500` | Server Error | خطای سرور |

## 🔧 Quick Examples

### JavaScript
```javascript
// Get settings
const response = await fetch('http://localhost/datasave/backend/api/settings/get.php');
const data = await response.json();

// Update setting
await fetch('http://localhost/datasave/backend/api/settings/update.php', {
  method: 'POST',
  headers: {'Content-Type': 'application/json'},
  body: JSON.stringify({setting_key: 'app_theme', setting_value: 'dark'})
});
```

### Dart/Flutter
```dart
// Get settings
final response = await http.get(
  Uri.parse('http://localhost/datasave/backend/api/settings/get.php')
);
final data = json.decode(response.body);

// Update setting
await http.post(
  Uri.parse('http://localhost/datasave/backend/api/settings/update.php'),
  headers: {'Content-Type': 'application/json'},
  body: json.encode({'setting_key': 'app_theme', 'setting_value': 'dark'})
);
```

### cURL
```bash
# Get settings
curl -X GET "http://localhost/datasave/backend/api/settings/get.php"

# Update setting
curl -X POST "http://localhost/datasave/backend/api/settings/update.php" \
  -H "Content-Type: application/json" \
  -d '{"setting_key": "app_theme", "setting_value": "dark"}'
```

## ⚠️ Important Notes
- فعلاً authentication ندارد (development only)
- CORS فقط برای localhost:8085 فعال
- همه پاسخ‌ها JSON format
- خطاها به فارسی نمایش داده می‌شوند

---
*Last updated: 2025-01-09*  
*File: /docs/99-Quick-Reference/api-quick-reference.md*
