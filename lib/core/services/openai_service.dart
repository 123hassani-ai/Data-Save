import 'dart:convert';
import 'package:http/http.dart' as http;
import '../logger/logger_service.dart';

/// سرویس OpenAI API - OpenAI API service
class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1';
  static const int _timeoutSeconds = 30;

  /// تست اتصال به OpenAI - Test OpenAI connection
  static Future<bool> testConnection(String apiKey) async {
    try {
      LoggerService.info('OpenAIService', 'شروع تست اتصال OpenAI');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/models'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: _timeoutSeconds));

      final success = response.statusCode == 200;
      
      if (success) {
        LoggerService.info('OpenAIService', 'اتصال OpenAI موفق');
      } else {
        LoggerService.error('OpenAIService', 'خطا در اتصال OpenAI', 
            'Status: ${response.statusCode}, Body: ${response.body}');
      }
      
      return success;
    } catch (e) {
      LoggerService.error('OpenAIService', 'خطا در تست اتصال OpenAI', e);
      return false;
    }
  }

  /// ارسال پیام به OpenAI ChatGPT - Send message to OpenAI ChatGPT
  static Future<String?> sendMessage({
    required String apiKey,
    required String message,
    String model = 'gpt-4',
    int maxTokens = 2048,
    double temperature = 0.7,
    bool isFirstMessage = false,
  }) async {
    if (apiKey.isEmpty || !apiKey.startsWith('sk-')) {
      LoggerService.severe('OpenAIService', 'کلید API نامعتبر است');
      return null;
    }

    try {
      LoggerService.info('OpenAIService', 'شروع ارسال پیام به OpenAI: ${message.substring(0, message.length > 30 ? 30 : message.length)}...');
      LoggerService.info('OpenAIService', 'مدل: $model, MaxTokens: $maxTokens, Temperature: $temperature');
      
      // تنظیم system message برای معرفی مدل در پیام اول
      List<Map<String, dynamic>> messages;
      if (isFirstMessage) {
        final modelIntro = _getModelIntroduction(model);
        messages = [
          {
            "role": "system",
            "content": "You are a helpful AI assistant. $modelIntro Please respond in Persian."
          },
          {
            "role": "user",
            "content": message
          }
        ];
      } else {
        messages = [
          {
            "role": "system",
            "content": "You are a helpful AI assistant. Please respond in Persian."
          },
          {
            "role": "user",
            "content": message
          }
        ];
      }

      final requestBody = {
        "model": model,
        "messages": messages,
        "max_tokens": maxTokens,
        "temperature": temperature,
      };

      LoggerService.info('OpenAIService', 'ارسال درخواست HTTP به OpenAI...');
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode(requestBody),
      );

      LoggerService.info('OpenAIService', 'پاسخ HTTP دریافت شد: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
        
        if (jsonResponse['choices'] != null && 
            jsonResponse['choices'].isNotEmpty &&
            jsonResponse['choices'][0]['message'] != null) {
          
          final content = jsonResponse['choices'][0]['message']['content'] as String?;
          if (content != null && content.isNotEmpty) {
            LoggerService.info('OpenAIService', 'پاسخ OpenAI با موفقیت دریافت شد');
            return content;
          }
        }
        
        LoggerService.error('OpenAIService', 'پاسخ OpenAI خالی یا نامعتبر است');
        return null;
        
      } else {
        final errorBody = response.body;
        LoggerService.severe('OpenAIService', 'خطای HTTP از OpenAI: ${response.statusCode}');
        LoggerService.severe('OpenAIService', 'پیام خطای OpenAI: $errorBody');
        
        // تلاش برای پارس کردن پیام خطای دقیق
        try {
          final errorJson = json.decode(errorBody);
          final errorMessage = errorJson['error']?['message'] ?? 'خطای نامشخص';
          LoggerService.severe('OpenAIService', 'جزئیات خطا: $errorMessage');
        } catch (e) {
          LoggerService.severe('OpenAIService', 'خطا در پارس کردن پیام خطا');
        }
        
        return null;
      }
    } catch (e) {
      LoggerService.severe('OpenAIService', 'خطا در ارسال درخواست به OpenAI', e);
      return null;
    }
  }
  
  /// دریافت معرفی مدل - Get model introduction
  static String _getModelIntroduction(String model) {
    switch (model.toLowerCase()) {
      case 'gpt-4':
      case 'gpt-4-turbo':
        return 'من GPT-4 هستم، یک مدل زبانی پیشرفته از شرکت OpenAI با قابلیت پردازش متون پیچیده و ارائه پاسخ‌های دقیق و خلاقانه. توکن‌های ورودی من تا 128,000 و خروجی تا 4,096 توکن است.';
      case 'gpt-3.5-turbo':
        return 'من GPT-3.5 Turbo هستم، یک مدل زبانی سریع و کارآمد از شرکت OpenAI که برای مکالمات و پاسخ‌دهی بهینه‌سازی شده‌ام. توکن‌های من تا 4,096 توکن است.';
      case 'gpt-4o':
        return 'من GPT-4o هستم، جدیدترین مدل چندرسانه‌ای OpenAI با قابلیت پردازش متن، تصویر و صدا. توکن‌های ورودی من تا 128,000 و خروجی تا 4,096 توکن است.';
      default:
        return 'من یک مدل زبانی OpenAI هستم که برای کمک به شما طراحی شده‌ام.';
    }
  }

  /// دریافت لیست مدل‌های موجود - Get available models
  static Future<List<String>> getAvailableModels(String apiKey) async {
    try {
      LoggerService.info('OpenAIService', 'دریافت لیست مدل‌های OpenAI');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/models'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: _timeoutSeconds));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final models = data['data'] as List;
        
        // فیلتر کردن مدل‌های چت
        final chatModels = models
            .where((model) => model['id'].toString().contains('gpt'))
            .map((model) => model['id'].toString())
            .where((id) => id.startsWith('gpt-'))
            .toList();
        
        chatModels.sort();
        LoggerService.info('OpenAIService', 'مدل‌های OpenAI دریافت شد: ${chatModels.length}');
        
        return chatModels;
      } else {
        LoggerService.error('OpenAIService', 'خطا در دریافت مدل‌های OpenAI', 
            'Status: ${response.statusCode}');
        return _getDefaultModels();
      }
    } catch (e) {
      LoggerService.error('OpenAIService', 'خطا در دریافت مدل‌های OpenAI', e);
      return _getDefaultModels();
    }
  }

  /// مدل‌های پیش‌فرض - Default models
  static List<String> _getDefaultModels() {
    return [
      'gpt-4',
      'gpt-4-turbo',
      'gpt-3.5-turbo',
      'gpt-4o',
      'gpt-4o-mini',
    ];
  }
}
