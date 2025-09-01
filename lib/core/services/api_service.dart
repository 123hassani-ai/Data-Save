/// سرویس ارتباط با Backend API
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
      final response = await http.post(
        Uri.parse('$baseUrl/logs/create.php'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: json.encode({
          'level': level,
          'category': category,
          'message': message,
          'context': context,
        }),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('خطا در ارسال لاگ: $e');
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
      final response = await http.get(
        Uri.parse('$baseUrl/logs/list.php?limit=$limit'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success']) {
          return List<Map<String, dynamic>>.from(jsonResponse['data']);
        }
      }
      return [];
    } catch (e) {
      print('خطا در دریافت لاگ‌ها: $e');
      return [];
    }
  }
}
