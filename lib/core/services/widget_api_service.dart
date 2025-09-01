import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../logger/logger_service.dart';

/// سرویس API کتابخانه ویجت‌ها - Widget Library API Service
/// مدیریت دریافت و کار با ویجت‌های فرم‌ساز
class WidgetApiService {
  static String get _baseUrl => '${AppConfig.apiBaseUrl}/api/widgets';
  
  /// دریافت کتابخانه کامل ویجت‌ها
  /// Get complete widget library
  static Future<Map<String, dynamic>> getWidgetLibrary({
    String category = 'all',
    bool activeOnly = true,
    String sortBy = 'display_order',
    int limit = 50,
  }) async {
    try {
      LoggerService.info('WidgetApiService', 'دریافت کتابخانه ویجت‌ها - Getting widget library', {
        'category': category,
        'active_only': activeOnly,
        'sort_by': sortBy,
        'limit': limit,
      });

      final queryParams = {
        'category': category,
        'active_only': activeOnly.toString(),
        'sort_by': sortBy,
        'limit': limit.toString(),
      };

      final uri = Uri.parse('$_baseUrl/library.php').replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json',
        },
      );

      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200 && responseData['success'] == true) {
        LoggerService.info('WidgetApiService', 'کتابخانه ویجت‌ها دریافت شد - Widget library retrieved', {
          'total_widgets': responseData['data']['total_count'],
          'categories': responseData['data']['categories'],
        });
        
        return {
          'success': true,
          'data': responseData['data'],
          'message': responseData['message'],
        };
      } else {
        LoggerService.warning('WidgetApiService', 'خطا در دریافت کتابخانه ویجت‌ها - Failed to get widget library', {
          'status_code': response.statusCode,
          'error': responseData['message'],
        });
        
        return {
          'success': false,
          'message': responseData['message'] ?? 'خطا در دریافت کتابخانه ویجت‌ها',
        };
      }
    } catch (e) {
      LoggerService.error('WidgetApiService', 'خطای سیستمی در دریافت کتابخانه ویجت‌ها - System error in getting widget library', e);
      
      return {
        'success': false,
        'message': 'خطای ارتباط با سرور',
        'error': e.toString(),
      };
    }
  }

  /// دریافت ویجت‌های یک دسته‌بندی خاص
  /// Get widgets by category
  static Future<Map<String, dynamic>> getWidgetsByCategory(String category) async {
    return await getWidgetLibrary(
      category: category,
      activeOnly: true,
      sortBy: 'display_order',
    );
  }

  /// دریافت ویجت‌های محبوب
  /// Get popular widgets
  static Future<Map<String, dynamic>> getPopularWidgets({int limit = 10}) async {
    return await getWidgetLibrary(
      category: 'all',
      activeOnly: true,
      sortBy: 'usage_count',
      limit: limit,
    );
  }

  /// جستجو در ویجت‌ها
  /// Search widgets (این feature در API موجود نیست - برای آینده)
  static Future<Map<String, dynamic>> searchWidgets(String query) async {
    // برای الان از getWidgetLibrary استفاده می‌کنیم
    // در آینده API جداگانه‌ای برای search اضافه می‌شود
    final result = await getWidgetLibrary();
    
    if (result['success'] == true) {
      final widgets = (result['data']['widgets'] as List? ?? []);
      final filteredWidgets = widgets.where((widget) {
        final persianLabel = widget['persian_label']?.toString().toLowerCase() ?? '';
        final englishLabel = widget['english_label']?.toString().toLowerCase() ?? '';
        final widgetType = widget['widget_type']?.toString().toLowerCase() ?? '';
        final searchQuery = query.toLowerCase();
        
        return persianLabel.contains(searchQuery) || 
               englishLabel.contains(searchQuery) ||
               widgetType.contains(searchQuery);
      }).toList();
      
      LoggerService.info('WidgetApiService', 'جستجوی ویجت‌ها انجام شد - Widget search completed', {
        'query': query,
        'total_results': filteredWidgets.length,
      });
      
      return {
        'success': true,
        'data': {
          'widgets': filteredWidgets,
          'total_count': filteredWidgets.length,
          'search_query': query,
        },
        'message': 'جستجو با موفقیت انجام شد',
      };
    }
    
    return result;
  }

  /// دریافت تنظیمات پیش‌فرض ویجت
  /// Get widget default config
  static Map<String, dynamic> getDefaultWidgetConfig(String widgetType) {
    // تنظیمات پیش‌فرض برای انواع مختلف ویجت
    final defaultConfigs = {
      'text': {
        'placeholder': 'متن خود را وارد کنید',
        'maxLength': null,
        'required': false,
        'validation': {'type': 'text'},
      },
      'textarea': {
        'placeholder': 'متن خود را وارد کنید',
        'rows': 3,
        'maxLength': null,
        'required': false,
        'validation': {'type': 'text'},
      },
      'number': {
        'placeholder': 'عدد مورد نظر را وارد کنید',
        'min': null,
        'max': null,
        'step': 1,
        'required': false,
        'validation': {'type': 'number'},
      },
      'email': {
        'placeholder': 'ایمیل خود را وارد کنید',
        'required': false,
        'validation': {'type': 'email'},
      },
      'select': {
        'options': [
          {'label': 'گزینه ۱', 'value': '1'},
          {'label': 'گزینه ۲', 'value': '2'},
        ],
        'multiple': false,
        'required': false,
        'validation': {'type': 'selection'},
      },
      'radio': {
        'options': [
          {'label': 'گزینه ۱', 'value': '1'},
          {'label': 'گزینه ۲', 'value': '2'},
        ],
        'required': false,
        'validation': {'type': 'selection'},
      },
      'checkbox': {
        'options': [
          {'label': 'گزینه ۱', 'value': '1'},
          {'label': 'گزینه ۲', 'value': '2'},
        ],
        'required': false,
        'validation': {'type': 'selection'},
      },
      'date': {
        'format': 'yyyy/MM/dd',
        'persian_calendar': true,
        'min_date': null,
        'max_date': null,
        'required': false,
        'validation': {'type': 'date'},
      },
      'time': {
        'format': '24h',
        'persian_digits': true,
        'required': false,
        'validation': {'type': 'time'},
      },
      'submit': {
        'text': 'ارسال فرم',
        'style': 'primary',
        'full_width': true,
      },
    };

    return defaultConfigs[widgetType] ?? {};
  }

  /// اعتبارسنجی تنظیمات ویجت
  /// Validate widget configuration
  static bool validateWidgetConfig(String widgetType, Map<String, dynamic> config) {
    // اعتبارسنجی پایه - در آینده گسترش‌یافته می‌شود
    try {
      switch (widgetType) {
        case 'text':
        case 'textarea':
          if (config['maxLength'] != null && config['maxLength'] is! int) {
            return false;
          }
          break;
        case 'number':
          if (config['min'] != null && config['min'] is! num) return false;
          if (config['max'] != null && config['max'] is! num) return false;
          if (config['step'] != null && config['step'] is! num) return false;
          break;
        case 'select':
        case 'radio':
        case 'checkbox':
          if (config['options'] == null || config['options'] is! List) return false;
          final options = config['options'] as List;
          if (options.isEmpty) return false;
          for (var option in options) {
            if (option is! Map || !option.containsKey('label') || !option.containsKey('value')) {
              return false;
            }
          }
          break;
      }
      return true;
    } catch (e) {
      LoggerService.warning('WidgetApiService', 'خطا در اعتبارسنجی تنظیمات ویجت', {
        'widget_type': widgetType,
        'error': e.toString(),
      });
      return false;
    }
  }
}
