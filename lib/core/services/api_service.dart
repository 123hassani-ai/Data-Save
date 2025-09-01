/// سرویس ارتباط با Backend API
library;
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://localhost/datasave/backend/api';
  
  /// دریافت تنظیمات از سرور
  static Future<List<Map<String, dynamic>>> getSettings() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/settings/get.php'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success']) {
          return List<Map<String, dynamic>>.from(jsonResponse['data']);
        }
      }
      throw Exception('خطا در دریافت تنظیمات');
    } catch (e) {
      throw Exception('خطا در ارتباط با سرور: $e');
    }
  }
  
  /// ارسال لاگ به سرور
  static Future<bool> sendLog(String level, String category, String message, [Map<String, dynamic>? context]) async {
    try {
      final body = json.encode({
        'level': level,
        'category': category,
        'message': message,
        'context': context,
      });
      
      print('🔍 ارسال لاگ: $level - $category - ${message.substring(0, message.length > 50 ? 50 : message.length)}...');
      print('🔍 داده ارسالی: $body');
      
      final response = await http.post(
        Uri.parse('$baseUrl/logs/create.php'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json',
        },
        body: body,
      );
      
      print('📡 پاسخ لاگ: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final success = jsonResponse['success'] ?? false;
        if (!success) {
          print('❌ خطا در پاسخ لاگ: ${jsonResponse['message']}');
        }
        return success;
      } else {
        print('❌ خطای HTTP لاگ: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Exception در ارسال لاگ: $e');
      return false;
    }
  }
  
  /// تست اتصال سرور
  static Future<Map<String, dynamic>> testConnection() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/system/status.php'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'message': 'سرور در دسترس نیست'};
    } catch (e) {
      return {'success': false, 'message': 'خطا در اتصال: $e'};
    }
  }
  
  /// بروزرسانی تنظیمات
  static Future<bool> updateSetting(String key, String value) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/settings/update.php'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: json.encode({
          'setting_key': key,
          'setting_value': value,
        }),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('خطا در بروزرسانی تنظیمات: $e');
      return false;
    }
  }
  
  /// دریافت لیست لاگ‌ها
  static Future<List<Map<String, dynamic>>> getLogs({int limit = 20}) async {
    try {
      final url = '$baseUrl/logs/list.php?limit=$limit';
      print('🔍 درخواست لاگ‌ها از: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      );
      
      print('📋 وضعیت HTTP: ${response.statusCode}');
      print('📋 پاسخ خام: ${response.body}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print('📋 پاسخ JSON: $jsonResponse');
        
        if (jsonResponse['success']) {
          final logs = List<Map<String, dynamic>>.from(jsonResponse['data']);
          print('✅ لاگ‌های دریافت شده: ${logs.length} مورد');
          return logs;
        } else {
          print('❌ درخواست ناموفق: ${jsonResponse['message']}');
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
      }
      return [];
    } catch (e) {
      print('❌ خطا در دریافت لاگ‌ها: $e');
      return [];
    }
  }

  /// دریافت آمار لاگ‌ها - Get logs statistics
  static Future<Map<String, dynamic>> getLogsStats() async {
    try {
      final url = '$baseUrl/logs/stats.php';
      print('📊 درخواست آمار لاگ‌ها از: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      );
      
      print('📊 وضعیت HTTP: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success']) {
          print('✅ آمار لاگ‌ها دریافت شد: ${jsonResponse['data']}');
          return jsonResponse['data'];
        }
      }
      print('❌ خطا در دریافت آمار لاگ‌ها');
      return {};
    } catch (e) {
      print('❌ خطا در دریافت آمار لاگ‌ها: $e');
      return {};
    }
  }
  
  /// تست اتصال OpenAI API - Test OpenAI API connection
  static Future<Map<String, dynamic>> testOpenAIConnection(String apiKey) async {
    if (apiKey.isEmpty || !apiKey.startsWith('sk-')) {
      return {
        'success': false,
        'message': 'کلید API نامعتبر است - API key is invalid'
      };
    }
    
    try {
      final response = await http.get(
        Uri.parse('https://api.openai.com/v1/models'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      );
      
      return {
        'success': response.statusCode == 200,
        'message': response.statusCode == 200 
            ? 'اتصال موفق - Connection successful' 
            : 'کلید نامعتبر - Invalid API key',
        'statusCode': response.statusCode,
      };
    } catch (e) {
      return {
        'success': false, 
        'message': 'خطا در اتصال - Connection error: $e'
      };
    }
  }
  
  /// بروزرسانی چندین تنظیم همزمان - Update multiple settings at once
  static Future<bool> updateMultipleSettings(Map<String, String> settings) async {
    bool allSuccessful = true;
    
    for (final entry in settings.entries) {
      final success = await updateSetting(entry.key, entry.value);
      if (!success) allSuccessful = false;
    }
    
    return allSuccessful;
  }
  
  /// دریافت آمار لاگ‌ها - Get log analytics
  static Future<Map<String, dynamic>> getLogAnalytics() async {
    try {
      final logs = await getLogs(limit: 1000); // Get recent logs for analysis
      
      final analytics = {
        'total_logs': logs.length,
        'error_count': logs.where((log) => log['log_level'] == 'ERROR').length,
        'warning_count': logs.where((log) => log['log_level'] == 'WARNING').length,
        'info_count': logs.where((log) => log['log_level'] == 'INFO').length,
        'debug_count': logs.where((log) => log['log_level'] == 'DEBUG').length,
        'categories': _getCategoryCounts(logs),
        'today_logs': _getTodayLogsCount(logs),
      };
      
      return analytics;
    } catch (e) {
      return {};
    }
  }
  
  /// پاکسازی لاگ‌های قدیمی - Clear old logs
  static Future<bool> clearOldLogs({int keepCount = 100}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/logs/clear.php'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: json.encode({'keep_count': keepCount}),
      );
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['success'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  /// دریافت اطلاعات سیستم - Get system information
  static Future<Map<String, dynamic>> getSystemInfo() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/system/info.php'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      );
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['data'] ?? {};
      }
      return {};
    } catch (e) {
      return {};
    }
  }
  
  /// محاسبه تعداد لاگ‌های هر دسته - Calculate category counts
  static Map<String, int> _getCategoryCounts(List<Map<String, dynamic>> logs) {
    final Map<String, int> categories = {};
    for (final log in logs) {
      final category = log['log_category']?.toString() ?? 'General';
      categories[category] = (categories[category] ?? 0) + 1;
    }
    return categories;
  }
  
  /// محاسبه تعداد لاگ‌های امروز - Calculate today's log count
  static int _getTodayLogsCount(List<Map<String, dynamic>> logs) {
    final today = DateTime.now();
    int count = 0;
    
    for (final log in logs) {
      try {
        final logDate = DateTime.parse(log['created_at']);
        if (logDate.year == today.year &&
            logDate.month == today.month &&
            logDate.day == today.day) {
          count++;
        }
      } catch (e) {
        // Skip invalid dates
      }
    }
    
    return count;
  }
}
