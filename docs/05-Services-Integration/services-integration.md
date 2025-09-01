# یکپارچه‌سازی سرویس‌ها - Services Integration

## 📊 Document Information
- **Created:** 2025-01-09
- **Last Updated:** 2025-01-09
- **Version:** 1.0
- **Maintainer:** DataSave Development Team
- **Related Files:** `/lib/core/services/`, `/backend/api/`

## 🎯 Overview
مستندات کامل یکپارچه‌سازی سرویس‌ها در DataSave شامل API service layer، OpenAI integration، و logging system.

## 📋 Table of Contents
- [معماری سرویس‌ها](#معماری-سرویسها)
- [API Service Layer](#api-service-layer)
- [OpenAI Integration](#openai-integration)
- [Logging System](#logging-system)
- [Error Handling](#error-handling)
- [Configuration Management](#configuration-management)

## 🏗️ معماری سرویس‌ها - Services Architecture

### Service Layer Overview
```yaml
Service Architecture:
  - ApiService: ارتباط با Backend PHP APIs
  - OpenAIService: یکپارچه‌سازی هوش مصنوعی
  - LoggerService: سیستم لاگینگ
  - ConfigService: مدیریت تنظیمات
  
Data Flow:
  Flutter Frontend → Service Layer → Backend APIs → Database
  Flutter Frontend → OpenAI Service → OpenAI API
  All Services → Logger Service → Backend Logs API
```

### Service Dependencies
```dart
// Service locator pattern
class ServiceLocator {
  static final _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  static ServiceLocator get instance => _instance;

  final Map<Type, dynamic> _services = {};

  void register<T>(T service) {
    _services[T] = service;
  }

  T get<T>() {
    final service = _services[T];
    if (service == null) {
      throw Exception('Service ${T.toString()} not registered');
    }
    return service as T;
  }

  void reset() {
    _services.clear();
  }
}

// Service initialization
void initializeServices() {
  ServiceLocator.instance.register<ApiService>(ApiService());
  ServiceLocator.instance.register<OpenAIService>(OpenAIService());
  ServiceLocator.instance.register<LoggerService>(LoggerService());
}
```

## 🌐 API Service Layer

### ApiService Implementation
```dart
/// سرویس ارتباط با Backend API
class ApiService {
  static const String _baseUrl = 'http://localhost/datasave/backend/api';
  static const Duration _timeout = Duration(seconds: 30);
  
  // HTTP Client with timeout
  static final http.Client _client = http.Client();
  
  /// دریافت تنظیمات سیستم
  static Future<List<Map<String, dynamic>>> getSettings() async {
    try {
      LoggerService.info('ApiService', 'درخواست دریافت تنظیمات');
      
      final response = await _client.get(
        Uri.parse('$_baseUrl/settings/get.php'),
        headers: _getHeaders(),
      ).timeout(_timeout);

      return _handleResponse<List<Map<String, dynamic>>>(
        response,
        'دریافت تنظیمات',
        (data) => List<Map<String, dynamic>>.from(data),
      );
    } catch (e) {
      LoggerService.error('ApiService', 'خطا در getSettings', e);
      rethrow;
    }
  }

  /// بروزرسانی تنظیم واحد
  static Future<bool> updateSetting(String key, String value) async {
    try {
      LoggerService.info('ApiService', 'بروزرسانی تنظیم: $key');
      
      final response = await _client.post(
        Uri.parse('$_baseUrl/settings/update.php'),
        headers: _getHeaders(),
        body: json.encode({
          'setting_key': key,
          'setting_value': value,
        }),
      ).timeout(_timeout);

      return _handleResponse<bool>(
        response,
        'بروزرسانی تنظیم',
        (data) => true,
      );
    } catch (e) {
      LoggerService.error('ApiService', 'خطا در updateSetting: $key', e);
      return false;
    }
  }

  /// دریافت لیست لاگ‌ها
  static Future<List<Map<String, dynamic>>?> getLogs({
    int limit = 20,
    String level = 'all',
  }) async {
    try {
      LoggerService.info('ApiService', 'درخواست لاگ‌ها: limit=$limit, level=$level');
      
      final uri = Uri.parse('$_baseUrl/logs/list.php').replace(
        queryParameters: {
          'limit': limit.toString(),
          if (level != 'all') 'level': level,
        },
      );

      final response = await _client.get(uri, headers: _getHeaders())
          .timeout(_timeout);

      return _handleResponse<List<Map<String, dynamic>>?>(
        response,
        'دریافت لاگ‌ها',
        (data) => List<Map<String, dynamic>>.from(data),
      );
    } catch (e) {
      LoggerService.error('ApiService', 'خطا در getLogs', e);
      return null;
    }
  }

  /// دریافت آمار لاگ‌ها
  static Future<Map<String, dynamic>?> getLogStats() async {
    try {
      LoggerService.info('ApiService', 'درخواست آمار لاگ‌ها');
      
      final response = await _client.get(
        Uri.parse('$_baseUrl/logs/stats.php'),
        headers: _getHeaders(),
      ).timeout(_timeout);

      return _handleResponse<Map<String, dynamic>?>(
        response,
        'آمار لاگ‌ها',
        (data) => Map<String, dynamic>.from(data),
      );
    } catch (e) {
      LoggerService.error('ApiService', 'خطا در getLogStats', e);
      return null;
    }
  }

  /// پاک کردن تمام لاگ‌ها
  static Future<bool> clearLogs() async {
    try {
      LoggerService.info('ApiService', 'درخواست پاک کردن لاگ‌ها');
      
      final response = await _client.post(
        Uri.parse('$_baseUrl/logs/clear.php'),
        headers: _getHeaders(),
      ).timeout(_timeout);

      return _handleResponse<bool>(
        response,
        'پاک کردن لاگ‌ها',
        (data) => true,
      );
    } catch (e) {
      LoggerService.error('ApiService', 'خطا در clearLogs', e);
      return false;
    }
  }

  /// ارسال لاگ به بک‌اند
  static Future<bool> sendLog(
    String level,
    String category, 
    String message,
    [Map<String, dynamic>? context]
  ) async {
    try {
      final body = json.encode({
        'level': level,
        'category': category,
        'message': message,
        'context': context,
      });
      
      final response = await _client.post(
        Uri.parse('$_baseUrl/logs/create.php'),
        headers: _getHeaders(),
        body: body,
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return result['success'] ?? false;
      }
      return false;
    } catch (e) {
      // Don't log errors for logging service to avoid recursion
      print('Error in sendLog: $e');
      return false;
    }
  }

  /// دریافت اطلاعات سیستم
  static Future<Map<String, dynamic>?> getSystemInfo() async {
    try {
      LoggerService.info('ApiService', 'درخواست اطلاعات سیستم');
      
      final response = await _client.get(
        Uri.parse('$_baseUrl/system/info.php'),
        headers: _getHeaders(),
      ).timeout(_timeout);

      return _handleResponse<Map<String, dynamic>?>(
        response,
        'اطلاعات سیستم',
        (data) => Map<String, dynamic>.from(data),
      );
    } catch (e) {
      LoggerService.error('ApiService', 'خطا در getSystemInfo', e);
      return null;
    }
  }

  /// تست وضعیت سرور
  static Future<Map<String, dynamic>?> getServerStatus() async {
    try {
      LoggerService.info('ApiService', 'بررسی وضعیت سرور');
      
      final response = await _client.get(
        Uri.parse('$_baseUrl/system/status.php'),
        headers: _getHeaders(),
      ).timeout(_timeout);

      return _handleResponse<Map<String, dynamic>?>(
        response,
        'وضعیت سرور',
        (data) => Map<String, dynamic>.from(data),
      );
    } catch (e) {
      LoggerService.error('ApiService', 'خطا در getServerStatus', e);
      return null;
    }
  }

  /// تست اتصال OpenAI از طریق بک‌اند
  static Future<bool> testOpenAi(String apiKey) async {
    try {
      LoggerService.info('ApiService', 'تست اتصال OpenAI از طریق بک‌اند');
      
      final response = await _client.post(
        Uri.parse('$_baseUrl/settings/test.php'),
        headers: _getHeaders(),
        body: json.encode({
          'api_key': apiKey,
        }),
      ).timeout(_timeout);

      return _handleResponse<bool>(
        response,
        'تست OpenAI',
        (data) => data['openai_status'] == 'success',
      );
    } catch (e) {
      LoggerService.error('ApiService', 'خطا در testOpenAi', e);
      return false;
    }
  }

  // Helper methods
  static Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
      'User-Agent': 'DataSave Flutter App v1.0',
    };
  }

  static T _handleResponse<T>(
    http.Response response,
    String operation,
    T Function(dynamic data) parser,
  ) {
    LoggerService.info('ApiService', '$operation - Status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      try {
        final result = json.decode(response.body);
        
        if (result['success'] == true) {
          LoggerService.info('ApiService', '$operation موفق');
          return parser(result['data']);
        } else {
          final errorMsg = result['message'] ?? 'خطای نامشخص';
          LoggerService.error('ApiService', '$operation ناموفق: $errorMsg');
          throw ApiException(errorMsg);
        }
      } catch (e) {
        if (e is ApiException) rethrow;
        
        LoggerService.error('ApiService', 'خطا در پارس پاسخ $operation', e);
        throw ApiException('خطا در پردازش پاسخ سرور');
      }
    } else {
      final errorMsg = 'خطای HTTP $operation: ${response.statusCode}';
      LoggerService.error('ApiService', errorMsg, response.body);
      throw ApiException(errorMsg, statusCode: response.statusCode);
    }
  }

  // Dispose client resources
  static void dispose() {
    _client.close();
  }
}

/// Exception مخصوص API
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  const ApiException(this.message, {this.statusCode, this.originalError});

  @override
  String toString() => 'ApiException: $message';
}
```

### API Error Handling
```dart
// Centralized API error handling
class ApiErrorHandler {
  static String handleError(dynamic error) {
    if (error is ApiException) {
      switch (error.statusCode) {
        case 400:
          return 'درخواست نامعتبر - لطفا ورودی‌ها را بررسی کنید';
        case 401:
          return 'خطای احراز هویت - دسترسی غیرمجاز';
        case 403:
          return 'عدم دسترسی - شما مجاز به این عملیات نیستید';
        case 404:
          return 'منبع مورد نظر یافت نشد';
        case 500:
          return 'خطای داخلی سرور - لطفا دوباره تلاش کنید';
        case 503:
          return 'سرویس در دسترس نیست - لطفا بعداً تلاش کنید';
        default:
          return 'خطای API: ${error.message}';
      }
    } else if (error is SocketException) {
      return 'خطای اتصال به اینترنت - لطفا اتصال خود را بررسی کنید';
    } else if (error is TimeoutException) {
      return 'زمان انتظار تمام شد - لطفا دوباره تلاش کنید';
    } else if (error is FormatException) {
      return 'خطا در پردازش داده‌های دریافتی از سرور';
    } else {
      return 'خطای غیرمنتظره: ${error.toString()}';
    }
  }

  static bool isRetriable(dynamic error) {
    if (error is ApiException) {
      return [500, 502, 503, 504].contains(error.statusCode);
    }
    return error is SocketException || error is TimeoutException;
  }
}
```

### API Retry Logic
```dart
// Retry mechanism for API calls
class ApiRetry {
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  static Future<T> withRetry<T>(Future<T> Function() apiCall) async {
    int attempts = 0;
    dynamic lastError;

    while (attempts < maxRetries) {
      try {
        return await apiCall();
      } catch (error) {
        lastError = error;
        attempts++;

        if (!ApiErrorHandler.isRetriable(error) || attempts >= maxRetries) {
          rethrow;
        }

        LoggerService.warning(
          'ApiRetry',
          'تلاش $attempts از $maxRetries ناموفق - تلاش مجدد در ${retryDelay.inSeconds} ثانیه',
        );

        await Future.delayed(Duration(
          milliseconds: retryDelay.inMilliseconds * attempts,
        ));
      }
    }

    throw lastError;
  }
}

// Usage example
Future<List<Map<String, dynamic>>> getSettingsWithRetry() async {
  return ApiRetry.withRetry(() => ApiService.getSettings());
}
```

## 🤖 OpenAI Integration

### OpenAIService Implementation
```dart
/// سرویس یکپارچه‌سازی OpenAI
class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1';
  static const Duration _timeout = Duration(seconds: 60);
  
  /// تست اتصال به OpenAI
  static Future<bool> testConnection(String apiKey) async {
    if (!_isValidApiKey(apiKey)) {
      LoggerService.error('OpenAIService', 'کلید API نامعتبر');
      return false;
    }

    try {
      LoggerService.info('OpenAIService', 'شروع تست اتصال OpenAI');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/models'),
        headers: _getHeaders(apiKey),
      ).timeout(_timeout);

      final success = response.statusCode == 200;
      
      if (success) {
        LoggerService.info('OpenAIService', 'اتصال OpenAI موفق');
        
        // Parse available models
        final result = json.decode(response.body);
        final models = result['data'] as List;
        LoggerService.info('OpenAIService', 
          'تعداد مدل‌های در دسترس: ${models.length}');
      } else {
        LoggerService.error('OpenAIService', 
          'خطا در اتصال OpenAI: ${response.statusCode}');
      }
      
      return success;
    } catch (e) {
      LoggerService.error('OpenAIService', 'خطا در تست اتصال OpenAI', e);
      return false;
    }
  }

  /// ارسال پیام به ChatGPT
  static Future<String?> sendMessage({
    required String apiKey,
    required String message,
    String model = 'gpt-4',
    int maxTokens = 2048,
    double temperature = 0.7,
    bool isFirstMessage = false,
  }) async {
    if (!_isValidApiKey(apiKey)) {
      LoggerService.error('OpenAIService', 'کلید API نامعتبر');
      return null;
    }

    try {
      LoggerService.info('OpenAIService', 
        'ارسال پیام به OpenAI - مدل: $model، طول پیام: ${message.length}');
      
      final messages = _buildMessages(message, model, isFirstMessage);
      
      final requestBody = {
        'model': model,
        'messages': messages,
        'max_tokens': maxTokens,
        'temperature': temperature,
        'stream': false,
      };

      LoggerService.debug('OpenAIService', 
        'درخواست OpenAI: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: _getHeaders(apiKey),
        body: json.encode(requestBody),
      ).timeout(_timeout);

      return _handleChatResponse(response);
    } catch (e) {
      LoggerService.error('OpenAIService', 'خطا در ارسال پیام', e);
      return null;
    }
  }

  /// تولید فرم با OpenAI
  static Future<Map<String, dynamic>?> generateForm({
    required String apiKey,
    required String description,
    String model = 'gpt-4',
    String language = 'persian',
  }) async {
    final prompt = _buildFormPrompt(description, language);
    
    try {
      LoggerService.info('OpenAIService', 
        'تولید فرم با OpenAI - زبان: $language');
      
      final response = await sendMessage(
        apiKey: apiKey,
        message: prompt,
        model: model,
        maxTokens: 3000,
        temperature: 0.3, // کمتر برای خروجی منسجم‌تر
      );

      if (response != null) {
        return _parseFormResponse(response);
      }
      return null;
    } catch (e) {
      LoggerService.error('OpenAIService', 'خطا در تولید فرم', e);
      return null;
    }
  }

  /// دریافت لیست مدل‌های موجود
  static Future<List<String>?> getAvailableModels(String apiKey) async {
    try {
      LoggerService.info('OpenAIService', 'دریافت لیست مدل‌ها');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/models'),
        headers: _getHeaders(apiKey),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        final models = result['data'] as List;
        
        // فیلتر مدل‌های chat
        final chatModels = models
            .where((model) => model['id'].toString().contains('gpt'))
            .map((model) => model['id'].toString())
            .toList();
        
        LoggerService.info('OpenAIService', 
          'مدل‌های chat موجود: ${chatModels.join(', ')}');
        
        return chatModels;
      }
      return null;
    } catch (e) {
      LoggerService.error('OpenAIService', 'خطا در دریافت مدل‌ها', e);
      return null;
    }
  }

  // Helper methods
  static bool _isValidApiKey(String apiKey) {
    return apiKey.isNotEmpty && 
           apiKey.startsWith('sk-') && 
           apiKey.length > 20;
  }

  static Map<String, String> _getHeaders(String apiKey) {
    return {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
      'User-Agent': 'DataSave/1.0',
    };
  }

  static List<Map<String, dynamic>> _buildMessages(
    String message,
    String model,
    bool isFirstMessage,
  ) {
    List<Map<String, dynamic>> messages = [];
    
    // System message
    String systemPrompt = '''
شما یک دستیار هوشمند برای ساخت فرم‌های آنلاین هستید.
لطفا همیشه به زبان فارسی پاسخ دهید.
''';
    
    if (isFirstMessage) {
      systemPrompt += _getModelIntroduction(model);
    }
    
    messages.add({
      "role": "system",
      "content": systemPrompt,
    });
    
    // User message
    messages.add({
      "role": "user",
      "content": message,
    });
    
    return messages;
  }

  static String _getModelIntroduction(String model) {
    switch (model) {
      case 'gpt-4':
        return 'من GPT-4 هستم، پیشرفته‌ترین مدل OpenAI با قابلیت‌های تحلیل و تولید محتوای پیشرفته.';
      case 'gpt-4-turbo':
        return 'من GPT-4 Turbo هستم، نسخه بهینه‌شده GPT-4 با سرعت بیشتر.';
      case 'gpt-3.5-turbo':
        return 'من GPT-3.5 Turbo هستم، مدل سریع و کارآمد OpenAI.';
      default:
        return 'من یک مدل زبانی OpenAI هستم و آماده کمک به شما‌ام.';
    }
  }

  static String _buildFormPrompt(String description, String language) {
    return '''
لطفا بر اساس توضیحات زیر یک فرم کامل طراحی کنید:

توضیحات: $description

فرم باید شامل موارد زیر باشد:
1. عنوان مناسب فرم
2. فیلدهای مورد نیاز با انواع مختلف (متن، ایمیل، شماره، انتخابی، چندانتخابی، تاریخ و...)
3. اعتبارسنجی مناسب برای هر فیلد
4. پیام‌های راهنما
5. دکمه‌های مناسب

لطفا پاسخ را به صورت JSON با ساختار زیر ارائه دهید:
{
  "title": "عنوان فرم",
  "description": "توضیح کوتاه فرم",
  "fields": [
    {
      "name": "نام فیلد",
      "type": "نوع فیلد",
      "label": "برچسب فیلد",
      "placeholder": "متن راهنما",
      "required": true/false,
      "validation": "قوانین اعتبارسنجی",
      "options": ["گزینه 1", "گزینه 2"] // فقط برای انتخابی
    }
  ],
  "submitText": "متن دکمه ارسال",
  "successMessage": "پیام موفقیت"
}

زبان فرم: $language
''';
  }

  static String? _handleChatResponse(http.Response response) {
    try {
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        
        if (result['choices'] != null && result['choices'].isNotEmpty) {
          final content = result['choices'][0]['message']['content'];
          LoggerService.info('OpenAIService', 
            'پاسخ OpenAI دریافت شد - طول: ${content.length}');
          return content;
        } else {
          LoggerService.error('OpenAIService', 'پاسخ خالی از OpenAI');
        }
      } else {
        final errorBody = response.body;
        LoggerService.error('OpenAIService', 
          'خطای HTTP ${response.statusCode}: $errorBody');
        
        // Parse error details
        try {
          final errorJson = json.decode(errorBody);
          final errorMsg = errorJson['error']['message'] ?? 'خطای نامشخص';
          LoggerService.error('OpenAIService', 'پیام خطا: $errorMsg');
        } catch (e) {
          // Ignore JSON parsing errors
        }
      }
      return null;
    } catch (e) {
      LoggerService.error('OpenAIService', 'خطا در پردازش پاسخ', e);
      return null;
    }
  }

  static Map<String, dynamic>? _parseFormResponse(String response) {
    try {
      // Extract JSON from response (remove markdown formatting if present)
      String cleanResponse = response.trim();
      
      if (cleanResponse.startsWith('```json')) {
        cleanResponse = cleanResponse.substring(7);
      }
      if (cleanResponse.endsWith('```')) {
        cleanResponse = cleanResponse.substring(0, cleanResponse.length - 3);
      }
      
      final formData = json.decode(cleanResponse) as Map<String, dynamic>;
      
      LoggerService.info('OpenAIService', 
        'فرم تولید شد: ${formData['title']} - ${formData['fields'].length} فیلد');
      
      return formData;
    } catch (e) {
      LoggerService.error('OpenAIService', 'خطا در تجزیه پاسخ فرم', e);
      
      // Return basic structure as fallback
      return {
        'title': 'فرم تولید شده',
        'description': 'فرم بر اساس درخواست شما',
        'fields': [],
        'submitText': 'ارسال',
        'successMessage': 'فرم با موفقیت ارسال شد',
        'error': 'خطا در تجزیه پاسخ AI',
        'rawResponse': response,
      };
    }
  }
}
```

## 📊 Logging System

### LoggerService Implementation
```dart
/// سرویس لاگینگ مرکزی
class LoggerService {
  static bool _initialized = false;
  static bool _enableConsoleLog = true;
  static bool _enableBackendLog = true;
  static String _logLevel = 'DEBUG';
  
  static final List<LogEntry> _logBuffer = [];
  static const int _maxBufferSize = 100;
  static Timer? _flushTimer;

  /// راه‌اندازی سرویس لاگ
  static Future<void> initialize({
    bool enableConsoleLog = true,
    bool enableBackendLog = true,
    String logLevel = 'DEBUG',
  }) async {
    _enableConsoleLog = enableConsoleLog;
    _enableBackendLog = enableBackendLog;
    _logLevel = logLevel;
    _initialized = true;

    // شروع timer برای flush کردن لاگ‌ها
    _startFlushTimer();

    info('LoggerService', 'سرویس لاگ راه‌اندازی شد');
  }

  /// لاگ سطح INFO
  static void info(String category, String message, [Map<String, dynamic>? context]) {
    _log(LogLevel.info, category, message, context);
  }

  /// لاگ سطح ERROR
  static void error(String category, String message, [dynamic error, Map<String, dynamic>? context]) {
    final errorContext = <String, dynamic>{};
    if (context != null) errorContext.addAll(context);
    if (error != null) errorContext['error'] = error.toString();
    
    _log(LogLevel.error, category, message, errorContext);
  }

  /// لاگ سطح WARNING
  static void warning(String category, String message, [Map<String, dynamic>? context]) {
    _log(LogLevel.warning, category, message, context);
  }

  /// لاگ سطح DEBUG
  static void debug(String category, String message, [Map<String, dynamic>? context]) {
    _log(LogLevel.debug, category, message, context);
  }

  /// لاگ سطح SEVERE
  static void severe(String category, String message, [dynamic error, Map<String, dynamic>? context]) {
    final errorContext = <String, dynamic>{};
    if (context != null) errorContext.addAll(context);
    if (error != null) errorContext['error'] = error.toString();
    
    _log(LogLevel.severe, category, message, errorContext);
  }

  static void _log(
    LogLevel level,
    String category,
    String message,
    Map<String, dynamic>? context,
  ) {
    if (!_initialized) {
      print('⚠️ LoggerService not initialized');
      return;
    }

    final logEntry = LogEntry(
      level: level,
      category: category,
      message: message,
      context: context,
      timestamp: DateTime.now(),
    );

    // Console logging
    if (_enableConsoleLog) {
      _logToConsole(logEntry);
    }

    // Buffer for backend logging
    if (_enableBackendLog) {
      _addToBuffer(logEntry);
    }
  }

  static void _logToConsole(LogEntry entry) {
    final timestamp = entry.timestamp.toIso8601String();
    final emoji = _getLevelEmoji(entry.level);
    final levelName = entry.level.name.toUpperCase().padRight(7);
    
    String logMessage = '$emoji [$timestamp] [$levelName] [${entry.category}] ${entry.message}';
    
    if (entry.context != null && entry.context!.isNotEmpty) {
      logMessage += ' - Context: ${json.encode(entry.context)}';
    }

    print(logMessage);
  }

  static void _addToBuffer(LogEntry entry) {
    _logBuffer.add(entry);
    
    if (_logBuffer.length > _maxBufferSize) {
      _logBuffer.removeAt(0); // Remove oldest entry
    }

    // Immediate send for error and severe levels
    if ([LogLevel.error, LogLevel.severe].contains(entry.level)) {
      _flushToBackend();
    }
  }

  static void _startFlushTimer() {
    _flushTimer?.cancel();
    _flushTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _flushToBackend();
    });
  }

  static Future<void> _flushToBackend() async {
    if (_logBuffer.isEmpty) return;

    final entries = List<LogEntry>.from(_logBuffer);
    _logBuffer.clear();

    for (final entry in entries) {
      try {
        await ApiService.sendLog(
          entry.level.name,
          entry.category,
          entry.message,
          entry.context,
        );
      } catch (e) {
        // Don't log errors for logging service to avoid recursion
        print('Error sending log to backend: $e');
        
        // Re-add to buffer if not too many failed attempts
        if (_logBuffer.length < _maxBufferSize) {
          _logBuffer.add(entry);
        }
      }
    }
  }

  static String _getLevelEmoji(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🔍';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
      case LogLevel.severe:
        return '💥';
    }
  }

  /// خاموش کردن سرویس
  static void dispose() {
    _flushTimer?.cancel();
    _flushToBackend(); // Final flush
    info('LoggerService', 'سرویس لاگ خاموش شد');
    _initialized = false;
  }

  /// دریافت آمار لاگ‌های محلی
  static Map<String, int> getLocalStats() {
    final stats = <String, int>{};
    for (final level in LogLevel.values) {
      stats[level.name] = 0;
    }
    
    for (final entry in _logBuffer) {
      stats[entry.level.name] = (stats[entry.level.name] ?? 0) + 1;
    }
    
    return stats;
  }
}

/// سطوح لاگ
enum LogLevel {
  debug,
  info,
  warning,
  error,
  severe,
}

/// مدل لاگ
class LogEntry {
  final LogLevel level;
  final String category;
  final String message;
  final Map<String, dynamic>? context;
  final DateTime timestamp;

  LogEntry({
    required this.level,
    required this.category,
    required this.message,
    this.context,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'level': level.name,
      'category': category,
      'message': message,
      'context': context,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
```

## ⚙️ Configuration Management

### ConfigService Implementation
```dart
/// سرویس مدیریت تنظیمات
class ConfigService {
  static final Map<String, dynamic> _config = {};
  static bool _initialized = false;

  /// راه‌اندازی سرویس با تنظیمات پیش‌فرض
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      LoggerService.info('ConfigService', 'بارگذاری تنظیمات');
      
      // Load from backend
      final settings = await ApiService.getSettings();
      
      for (final setting in settings) {
        _config[setting['setting_key']] = setting['setting_value'];
      }
      
      _initialized = true;
      LoggerService.info('ConfigService', 
        'تنظیمات بارگذاری شد - ${_config.length} تنظیم');
    } catch (e) {
      LoggerService.error('ConfigService', 'خطا در بارگذاری تنظیمات', e);
      _loadDefaults();
      _initialized = true;
    }
  }

  /// دریافت تنظیم
  static T? get<T>(String key, {T? defaultValue}) {
    if (!_initialized) {
      LoggerService.warning('ConfigService', 
        'سرویس هنوز راه‌اندازی نشده - استفاده از مقدار پیش‌فرض');
      return defaultValue;
    }

    final value = _config[key];
    if (value == null) {
      return defaultValue;
    }

    // Type conversion
    if (T == int && value is String) {
      return int.tryParse(value) as T? ?? defaultValue;
    }
    if (T == double && value is String) {
      return double.tryParse(value) as T? ?? defaultValue;
    }
    if (T == bool && value is String) {
      return (value.toLowerCase() == 'true') as T? ?? defaultValue;
    }

    return value is T ? value : defaultValue;
  }

  /// تنظیم مقدار
  static Future<bool> set<T>(String key, T value) async {
    if (!_initialized) {
      LoggerService.error('ConfigService', 'سرویس راه‌اندازی نشده');
      return false;
    }

    try {
      final stringValue = value.toString();
      final success = await ApiService.updateSetting(key, stringValue);
      
      if (success) {
        _config[key] = stringValue;
        LoggerService.info('ConfigService', 'تنظیم بروزرسانی شد: $key = $value');
      }
      
      return success;
    } catch (e) {
      LoggerService.error('ConfigService', 'خطا در بروزرسانی تنظیم $key', e);
      return false;
    }
  }

  /// دریافت تمام تنظیمات
  static Map<String, dynamic> getAll() {
    return Map<String, dynamic>.from(_config);
  }

  /// تنظیمات OpenAI
  static String get openaiApiKey => get<String>('openai_api_key', defaultValue: '') ?? '';
  static String get openaiModel => get<String>('openai_model', defaultValue: 'gpt-4') ?? 'gpt-4';
  static int get openaiMaxTokens => get<int>('openai_max_tokens', defaultValue: 1000) ?? 1000;
  static double get openaiTemperature => get<double>('openai_temperature', defaultValue: 0.7) ?? 0.7;

  /// تنظیمات سیستم
  static String get appName => get<String>('app_name', defaultValue: 'DataSave') ?? 'DataSave';
  static String get appVersion => get<String>('app_version', defaultValue: '1.0.0') ?? '1.0.0';
  static bool get debugMode => get<bool>('debug_mode', defaultValue: true) ?? true;

  /// تنظیمات UI
  static String get defaultTheme => get<String>('default_theme', defaultValue: 'light') ?? 'light';
  static String get defaultLanguage => get<String>('default_language', defaultValue: 'fa') ?? 'fa';

  static void _loadDefaults() {
    LoggerService.info('ConfigService', 'بارگذاری تنظیمات پیش‌فرض');
    
    _config.addAll({
      'app_name': 'DataSave',
      'app_version': '1.0.0',
      'debug_mode': 'true',
      'default_theme': 'light',
      'default_language': 'fa',
      'openai_model': 'gpt-4',
      'openai_max_tokens': '1000',
      'openai_temperature': '0.7',
    });
  }

  /// بازخوانی تنظیمات از سرور
  static Future<bool> refresh() async {
    try {
      LoggerService.info('ConfigService', 'بازخوانی تنظیمات از سرور');
      
      final settings = await ApiService.getSettings();
      _config.clear();
      
      for (final setting in settings) {
        _config[setting['setting_key']] = setting['setting_value'];
      }
      
      LoggerService.info('ConfigService', 
        'تنظیمات بازخوانی شد - ${_config.length} تنظیم');
      return true;
    } catch (e) {
      LoggerService.error('ConfigService', 'خطا در بازخوانی تنظیمات', e);
      return false;
    }
  }
}
```

## 🛠️ Service Integration Examples

### Controller Integration
```dart
/// نمونه استفاده از سرویس‌ها در کنترلر
class AdvancedSettingsController extends BaseController {
  Future<void> testFullOpenAiIntegration() async {
    setLoading(true);
    
    try {
      LoggerService.info('SettingsController', 'شروع تست کامل OpenAI');
      
      final apiKey = ConfigService.openaiApiKey;
      if (apiKey.isEmpty) {
        throw Exception('کلید API تنظیم نشده است');
      }

      // 1. Test connection
      final connectionOk = await OpenAIService.testConnection(apiKey);
      if (!connectionOk) {
        throw Exception('اتصال به OpenAI برقرار نشد');
      }

      // 2. Get available models
      final models = await OpenAIService.getAvailableModels(apiKey);
      if (models == null || models.isEmpty) {
        throw Exception('هیچ مدلی در دسترس نیست');
      }

      // 3. Test message sending
      final response = await OpenAIService.sendMessage(
        apiKey: apiKey,
        message: 'سلام، لطفا به زبان فارسی پاسخ دهید.',
        model: ConfigService.openaiModel,
        isFirstMessage: true,
      );

      if (response == null) {
        throw Exception('پاسخی از OpenAI دریافت نشد');
      }

      // 4. Test form generation
      final formData = await OpenAIService.generateForm(
        apiKey: apiKey,
        description: 'فرم ثبت نام کاربر جدید با نام، ایمیل و رمز عبور',
      );

      if (formData == null) {
        throw Exception('فرم تولید نشد');
      }

      clearError();
      LoggerService.info('SettingsController', 
        'تست کامل OpenAI موفق - مدل‌ها: ${models.length}, فیلدهای فرم: ${formData['fields'].length}');
      
    } catch (e) {
      final errorMsg = 'خطا در تست کامل OpenAI: ${e.toString()}';
      setError(errorMsg);
      LoggerService.error('SettingsController', errorMsg, e);
    } finally {
      setLoading(false);
    }
  }
}
```

### Service Health Check
```dart
/// بررسی سلامت تمام سرویس‌ها
class ServiceHealthCheck {
  static Future<Map<String, bool>> checkAllServices() async {
    LoggerService.info('ServiceHealthCheck', 'شروع بررسی سلامت سرویس‌ها');
    
    final results = <String, bool>{};
    
    // Backend API Health
    try {
      final status = await ApiService.getServerStatus();
      results['backend_api'] = status?['success'] == true;
    } catch (e) {
      results['backend_api'] = false;
    }
    
    // Database Health
    try {
      final settings = await ApiService.getSettings();
      results['database'] = settings.isNotEmpty;
    } catch (e) {
      results['database'] = false;
    }
    
    // OpenAI Health
    try {
      final apiKey = ConfigService.openaiApiKey;
      if (apiKey.isNotEmpty) {
        results['openai'] = await OpenAIService.testConnection(apiKey);
      } else {
        results['openai'] = false;
      }
    } catch (e) {
      results['openai'] = false;
    }
    
    // Logging Health
    results['logging'] = LoggerService._initialized;
    
    // Config Health
    results['config'] = ConfigService._initialized;
    
    final healthy = results.values.every((health) => health);
    LoggerService.info('ServiceHealthCheck', 
      'بررسی سلامت کامل - وضعیت کلی: ${healthy ? "سالم" : "مشکل‌دار"}');
    
    return results;
  }
}
```

## ⚠️ Important Notes

### Best Practices
1. **Service Initialization**: همه services در main() initialize شوند
2. **Error Handling**: همه خطاها centralized handle شوند
3. **Logging**: همه عملیات مهم log شوند
4. **Configuration**: از ConfigService برای تنظیمات استفاده شود
5. **Retry Logic**: برای API calls از retry mechanism استفاده شود

### Performance Considerations
- **HTTP Client**: از singleton client استفاده کنید
- **Connection Pooling**: HTTP connections را reuse کنید
- **Timeouts**: مناسب timeout تنظیم کنید
- **Caching**: پاسخ‌های API را cache کنید

### Security Notes
- **API Keys**: هرگز در کد hard-code نکنید
- **HTTPS**: همیشه از HTTPS استفاده کنید
- **Input Validation**: همه ورودی‌ها را validate کنید
- **Error Messages**: اطلاعات حساس در خطاها نمایش ندهید

## 🔄 Related Documentation
- [Flutter Architecture](../04-Flutter-Frontend/flutter-architecture.md)
- [API Endpoints Reference](../02-Backend-APIs/api-endpoints-reference.md)
- [Database Schema](../03-Database-Schema/README.md)
- [Error Handling Guide](./error-handling-guide.md)

---
*Last updated: 2025-01-09*  
*File: /docs/05-Services-Integration/services-integration.md*
