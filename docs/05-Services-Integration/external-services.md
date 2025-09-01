# سرویس‌های خارجی - External Services Integration

## 📊 Document Information
- **Created:** 2025-09-01
- **Last Updated:** 2025-09-01  
- **Version:** 1.0
- **Maintainer:** DataSave Development Team
- **Related Files:** `lib/core/services/`, `backend/api/external/`, `lib/core/config/`

## 🎯 Overview
مدیریت و ادغام سرویس‌های خارجی در پلتفرم DataSave شامل OpenAI API، سرویس‌های ایمیل، SMS، payment gateways و سایر APIهای شخص ثالث.

## 📋 Table of Contents
- [سرویس‌های فعلی](#سرویس‌های-فعلی)
- [OpenAI Integration](#openai-integration)
- [سرویس‌های آینده](#سرویس‌های-آینده)
- [Authentication & Security](#authentication--security)
- [Rate Limiting & Throttling](#rate-limiting--throttling)
- [Error Handling](#error-handling)
- [Monitoring & Logging](#monitoring--logging)

## 🌐 سرویس‌های فعلی - Current External Services

### 1️⃣ OpenAI API Integration
**Status:** ✅ **Active**  
**Purpose:** هوش مصنوعی برای تولید فرم، پردازش متن، دستیار هوشمند  
**Version:** GPT-4  
**Configuration:**
```yaml
Service: OpenAI GPT-4
Endpoint: https://api.openai.com/v1/chat/completions
Model: gpt-4
Max Tokens: 2048
Temperature: 0.7
Authentication: Bearer Token (API Key)
Rate Limit: 10,000 requests/month
```

**Implementation Files:**
```dart
// Flutter Service
lib/core/services/openai_service.dart

class OpenAIService {
  static const String baseUrl = 'https://api.openai.com/v1';
  static const String model = 'gpt-4';
  
  static Future<String> generateFormSuggestion(String prompt) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat/completions'),
      headers: {
        'Authorization': 'Bearer ${await _getApiKey()}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': model,
        'messages': [
          {
            'role': 'system',
            'content': 'شما یک متخصص طراحی فرم هستید که فرم‌های فارسی می‌سازید.'
          },
          {
            'role': 'user',
            'content': prompt
          }
        ],
        'max_tokens': 2048,
        'temperature': 0.7,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    }
    throw Exception('خطا در ارتباط با OpenAI: ${response.statusCode}');
  }
}
```

**Security Considerations:**
- API Key encryption in database
- Request/response logging for monitoring
- User data privacy protection
- Token usage monitoring

## 🔄 سرویس‌های آینده - Future External Services

### 2️⃣ Iranian SMS Services
**Status:** 🚧 **Planned**  
**Purpose:** ارسال SMS تایید، notifications  
**Providers:** کاوه نگار، مرپ، آیپ‌دو، ملی پیامک

```yaml
Planned Integration:
  - KaveNegar API
  - SMS.ir API  
  - Multi-provider fallback
  - Persian text support
  - Delivery status tracking
```

### 3️⃣ Iranian Payment Gateways  
**Status:** 🚧 **Planned**
**Purpose:** پرداخت برای premium features
**Providers:** زرین‌پال، آیدی‌پی، پارسیان، سامان

```yaml
Planned Integration:
  - ZarinPal API (Primary)
  - IDPay API (Fallback)
  - Persian receipt generation
  - Multi-currency support (IRR, USD)
  - Subscription management
```

### 4️⃣ Email Services
**Status:** 🚧 **Planned**
**Purpose:** ارسال ایمیل، notifications، reports
**Provider:** SendGrid / AWS SES

```yaml
Features:
  - Persian email templates
  - SMTP configuration
  - Email analytics
  - Bounce handling
  - Unsubscribe management
```

### 5️⃣ Cloud Storage  
**Status:** 🚧 **Planned**
**Purpose:** ذخیره فایل‌های کاربران، backup
**Providers:** AWS S3, Google Cloud Storage, Arvan Cloud

```yaml
Integration Plan:
  - Multi-cloud strategy
  - Iranian cloud providers
  - File encryption
  - CDN integration
  - Automatic backup
```

## 🔐 Authentication & Security

### API Key Management
```php
<?php
// Backend - Secure API key storage
class ExternalServiceAuth {
    public function getApiKey(string $service): string {
        $sql = "SELECT setting_value FROM system_settings 
                WHERE setting_key = ? AND setting_type = 'encrypted'";
        $stmt = $this->db->prepare($sql);
        $stmt->execute(["{$service}_api_key"]);
        $encrypted = $stmt->fetchColumn();
        
        return $this->decrypt($encrypted);
    }
    
    private function decrypt(string $encrypted): string {
        return openssl_decrypt($encrypted, 'AES-256-CBC', 
                             $this->getEncryptionKey(), 0, $this->getIV());
    }
}
?>
```

### Service Health Monitoring
```dart
class ExternalServiceMonitor {
  static Future<Map<String, bool>> checkServicesHealth() async {
    final services = {
      'openai': _checkOpenAI(),
      'sms': _checkSMSService(),
      'payment': _checkPaymentGateway(),
      'email': _checkEmailService(),
    };
    
    final results = await Future.wait(services.values);
    return Map.fromIterables(services.keys, results);
  }
  
  static Future<bool> _checkOpenAI() async {
    try {
      final response = await OpenAIService.testConnection();
      return response != null;
    } catch (e) {
      LoggerService.error('ExternalServices', 'OpenAI health check failed: $e');
      return false;
    }
  }
}
```

## ⚡ Rate Limiting & Throttling

### Request Rate Management
```dart
class ApiRateLimiter {
  static final Map<String, List<DateTime>> _requests = {};
  static const int maxRequestsPerMinute = 60;
  
  static bool canMakeRequest(String service) {
    final now = DateTime.now();
    final key = service;
    
    // Initialize if not exists
    _requests[key] ??= [];
    
    // Remove old requests
    _requests[key]!.removeWhere(
      (time) => now.difference(time).inMinutes >= 1
    );
    
    if (_requests[key]!.length >= maxRequestsPerMinute) {
      LoggerService.warning('RateLimit', 'Rate limit exceeded for $service');
      return false;
    }
    
    _requests[key]!.add(now);
    return true;
  }
}
```

## 🚨 Error Handling & Retry Logic

### Resilient Service Calls
```dart
class ExternalServiceClient {
  static Future<T?> makeResilientRequest<T>(
    String serviceName,
    Future<T> Function() request,
    {int maxRetries = 3}
  ) async {
    int attempts = 0;
    Duration delay = const Duration(seconds: 1);
    
    while (attempts < maxRetries) {
      try {
        if (!ApiRateLimiter.canMakeRequest(serviceName)) {
          throw Exception('Rate limit exceeded');
        }
        
        final result = await request();
        LoggerService.info('ExternalService', 
          'Successful $serviceName request on attempt ${attempts + 1}');
        return result;
        
      } catch (e) {
        attempts++;
        LoggerService.error('ExternalService',
          '$serviceName attempt $attempts failed: $e');
        
        if (attempts >= maxRetries) {
          LoggerService.critical('ExternalService',
            '$serviceName failed after $maxRetries attempts');
          return null;
        }
        
        await Future.delayed(delay);
        delay *= 2; // Exponential backoff
      }
    }
    return null;
  }
}
```

## 📊 Monitoring & Analytics

### Service Usage Tracking
```sql
-- جدول آینده برای tracking
CREATE TABLE external_service_usage (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    service_name VARCHAR(50) NOT NULL,
    endpoint VARCHAR(255),
    request_method VARCHAR(10),
    response_code INT,
    response_time_ms INT,
    bytes_sent INT,
    bytes_received INT,
    success BOOLEAN,
    error_message TEXT,
    user_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    KEY idx_service_time (service_name, created_at),
    KEY idx_success_time (success, created_at),
    KEY idx_user_service (user_id, service_name)
);
```

### Performance Metrics Dashboard
```dart
class ExternalServiceMetrics {
  static Future<Map<String, dynamic>> getServiceStats(
    String serviceName, 
    Duration period
  ) async {
    final endTime = DateTime.now();
    final startTime = endTime.subtract(period);
    
    return {
      'total_requests': await _getTotalRequests(serviceName, startTime, endTime),
      'success_rate': await _getSuccessRate(serviceName, startTime, endTime),
      'avg_response_time': await _getAverageResponseTime(serviceName, startTime, endTime),
      'error_count': await _getErrorCount(serviceName, startTime, endTime),
      'rate_limit_hits': await _getRateLimitHits(serviceName, startTime, endTime),
    };
  }
}
```

## 🛠️ Configuration Management

### Service Configuration
```yaml
# config/external_services.yaml
external_services:
  openai:
    enabled: true
    base_url: "https://api.openai.com/v1"
    model: "gpt-4"
    max_tokens: 2048
    temperature: 0.7
    timeout: 30000
    retry_attempts: 3
    
  sms:
    enabled: false  # آینده
    primary_provider: "kavenegar"
    fallback_provider: "sms_ir"
    timeout: 10000
    
  payment:
    enabled: false  # آینده
    primary_gateway: "zarinpal"
    fallback_gateway: "idpay"
    currency: "IRR"
    
  email:
    enabled: false  # آینده
    provider: "sendgrid"
    from_address: "noreply@datasave.ir"
```

## ⚠️ Important Notes

### Development Environment
- تست API keys فقط در محیط development
- Mock services برای unit testing
- Rate limiting کمتر در development

### Production Considerations  
- API key rotation strategy
- Backup service providers
- Health check monitoring
- Cost tracking per service
- Persian language support verification

### Security Best Practices
- هرگز API keys را در کد ذخیره نکنید
- استفاده از encrypted storage برای credentials
- Regular security audits
- Request/response logging (without sensitive data)

## 🔄 Related Documentation
- [OpenAI Integration](openai-integration.md)
- [API Service Layer](api-service-layer.md)
- [Configuration Management](configuration-management.md)
- [Security Implementation](../02-Backend-APIs/security-implementation.md)

## 📚 References
- [OpenAI API Documentation](https://platform.openai.com/docs)
- [ZarinPal API Guide](https://www.zarinpal.com/docs)  
- [KaveNegar SMS API](https://kavenegar.com/rest.html)
- [Persian Text Processing Best Practices]

---
*Last updated: 2025-09-01*  
*File: docs/05-Services-Integration/external-services.md*