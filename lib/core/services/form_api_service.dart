import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../logger/logger_service.dart';

/// سرویس API فرم‌ها - Forms API Service
/// مدیریت تمام عملیات CRUD فرم‌ها
class FormApiService {
  static String get _baseUrl => '${AppConfig.apiBaseUrl}/forms';
  
  /// ایجاد فرم جدید
  /// Create new form
  static Future<Map<String, dynamic>> createForm({
    required int userId,
    required String persianTitle,
    String? englishTitle,
    String? persianDescription,
    String? englishDescription,
    required Map<String, dynamic> formSchema,
    Map<String, dynamic>? formConfig,
    Map<String, dynamic>? formSettings,
    String status = 'draft',
    bool isPublic = false,
    bool requiresLogin = false,
    int? maxResponses,
    String? expiresAt,
    String version = '1.0',
  }) async {
    try {
      LoggerService.info('FormApiService', 'ایجاد فرم جدید - Creating new form', {
        'user_id': userId,
        'title': persianTitle,
        'status': status,
        'is_public': isPublic,
      });

      final requestData = {
        'user_id': userId,
        'persian_title': persianTitle,
        'english_title': englishTitle,
        'persian_description': persianDescription,
        'english_description': englishDescription,
        'form_schema': formSchema,
        'form_config': formConfig ?? {
          'theme': 'default',
          'rtl_support': true,
          'show_progress': false,
          'allow_draft_save': true,
        },
        'form_settings': formSettings ?? {
          'submit_button_text': 'ارسال فرم',
          'success_message': 'فرم با موفقیت ارسال شد',
          'redirect_url': null,
          'email_notifications': false,
        },
        'status': status,
        'is_public': isPublic,
        'requires_login': requiresLogin,
        'max_responses': maxResponses,
        'expires_at': expiresAt,
        'version': version,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/create.php'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json',
        },
        body: json.encode(requestData),
      );

      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200 && responseData['success'] == true) {
        LoggerService.info('FormApiService', 'فرم با موفقیت ایجاد شد - Form created successfully', {
          'form_id': responseData['data']?['form_id'],
        });
        
        return {
          'success': true,
          'data': responseData['data'],
          'message': responseData['message'],
        };
      } else {
        LoggerService.warning('FormApiService', 'خطا در ایجاد فرم - Form creation failed', {
          'status_code': response.statusCode,
          'error': responseData['message'],
        });
        
        return {
          'success': false,
          'message': responseData['message'] ?? 'خطا در ایجاد فرم',
        };
      }
    } catch (e) {
      LoggerService.error('FormApiService', 'خطای سیستمی در ایجاد فرم - System error in form creation', e);
      
      return {
        'success': false,
        'message': 'خطای ارتباط با سرور',
        'error': e.toString(),
      };
    }
  }

  /// دریافت فرم‌های کاربر
  /// Get user forms with pagination
  static Future<Map<String, dynamic>> getUserForms({
    required int userId,
    int page = 1,
    int perPage = 10,
    String status = 'all',
    String? search,
    String orderBy = 'created_at',
    String orderDirection = 'desc',
  }) async {
    try {
      LoggerService.info('FormApiService', 'دریافت فرم‌های کاربر - Getting user forms', {
        'user_id': userId,
        'page': page,
        'per_page': perPage,
        'status': status,
      });

      final queryParams = {
        'user_id': userId.toString(),
        'page': page.toString(),
        'per_page': perPage.toString(),
        'status': status,
        'order_by': orderBy,
        'order_direction': orderDirection,
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final uri = Uri.parse('$_baseUrl/user_forms.php')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: {
        'Accept': 'application/json',
      });

      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200 && responseData['success'] == true) {
        LoggerService.info('FormApiService', 'فرم‌های کاربر با موفقیت دریافت شد - User forms retrieved successfully');
        
        return {
          'success': true,
          'data': responseData['data'],
          'message': responseData['message'],
        };
      } else {
        LoggerService.warning('FormApiService', 'خطا در دریافت فرم‌های کاربر - Failed to get user forms', {
          'status_code': response.statusCode,
          'error': responseData['message'],
        });
        
        return {
          'success': false,
          'message': responseData['message'] ?? 'خطا در دریافت فرم‌ها',
        };
      }
    } catch (e) {
      LoggerService.error('FormApiService', 'خطای سیستمی در دریافت فرم‌ها - System error in getting forms', e);
      
      return {
        'success': false,
        'message': 'خطای ارتباط با سرور',
        'error': e.toString(),
      };
    }
  }

  /// دریافت اطلاعات یک فرم
  /// Get form by ID
  static Future<Map<String, dynamic>> getFormById({
    required int formId,
    bool includeStats = false,
  }) async {
    try {
      LoggerService.info('FormApiService', 'دریافت اطلاعات فرم - Getting form by ID', {
        'form_id': formId,
        'include_stats': includeStats,
      });

      final queryParams = {
        'form_id': formId.toString(),
        'include_stats': includeStats.toString(),
      };

      final uri = Uri.parse('$_baseUrl/get.php')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: {
        'Accept': 'application/json',
      });

      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200 && responseData['success'] == true) {
        LoggerService.info('FormApiService', 'فرم با موفقیت دریافت شد - Form retrieved successfully', {
          'form_id': formId,
        });
        
        return {
          'success': true,
          'data': responseData['data'],
          'message': responseData['message'],
        };
      } else {
        LoggerService.warning('FormApiService', 'خطا در دریافت فرم - Failed to get form', {
          'status_code': response.statusCode,
          'error': responseData['message'],
        });
        
        return {
          'success': false,
          'message': responseData['message'] ?? 'خطا در دریافت فرم',
        };
      }
    } catch (e) {
      LoggerService.error('FormApiService', 'خطای سیستمی در دریافت فرم - System error in getting form', e);
      
      return {
        'success': false,
        'message': 'خطای ارتباط با سرور',
        'error': e.toString(),
      };
    }
  }

  /// بروزرسانی فرم
  /// Update form
  static Future<Map<String, dynamic>> updateForm({
    required int formId,
    required int userId,
    String? persianTitle,
    String? englishTitle,
    String? persianDescription,
    String? englishDescription,
    Map<String, dynamic>? formSchema,
    Map<String, dynamic>? formConfig,
    Map<String, dynamic>? formSettings,
    String? status,
    bool? isPublic,
    bool? requiresLogin,
    int? maxResponses,
    String? expiresAt,
  }) async {
    try {
      LoggerService.info('FormApiService', 'بروزرسانی فرم - Updating form', {
        'form_id': formId,
        'user_id': userId,
        'status': status,
      });

      final requestData = <String, dynamic>{
        'form_id': formId,
        'user_id': userId,
      };

      // فقط فیلدهای ارسالی را اضافه کن
      if (persianTitle != null) requestData['persian_title'] = persianTitle;
      if (englishTitle != null) requestData['english_title'] = englishTitle;
      if (persianDescription != null) requestData['persian_description'] = persianDescription;
      if (englishDescription != null) requestData['english_description'] = englishDescription;
      if (formSchema != null) requestData['form_schema'] = formSchema;
      if (formConfig != null) requestData['form_config'] = formConfig;
      if (formSettings != null) requestData['form_settings'] = formSettings;
      if (status != null) requestData['status'] = status;
      if (isPublic != null) requestData['is_public'] = isPublic;
      if (requiresLogin != null) requestData['requires_login'] = requiresLogin;
      if (maxResponses != null) requestData['max_responses'] = maxResponses;
      if (expiresAt != null) requestData['expires_at'] = expiresAt;

      final response = await http.put(
        Uri.parse('$_baseUrl/update.php'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json',
        },
        body: json.encode(requestData),
      );

      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200 && responseData['success'] == true) {
        LoggerService.info('FormApiService', 'فرم با موفقیت بروزرسانی شد - Form updated successfully', {
          'form_id': formId,
        });
        
        return {
          'success': true,
          'data': responseData['data'],
          'message': responseData['message'],
        };
      } else {
        LoggerService.warning('FormApiService', 'خطا در بروزرسانی فرم - Form update failed', {
          'status_code': response.statusCode,
          'error': responseData['message'],
        });
        
        return {
          'success': false,
          'message': responseData['message'] ?? 'خطا در بروزرسانی فرم',
        };
      }
    } catch (e) {
      LoggerService.error('FormApiService', 'خطای سیستمی در بروزرسانی فرم - System error in form update', e);
      
      return {
        'success': false,
        'message': 'خطای ارتباط با سرور',
        'error': e.toString(),
      };
    }
  }

  /// حذف فرم
  /// Delete form
  static Future<Map<String, dynamic>> deleteForm({
    required int formId,
    required int userId,
    bool permanent = false,
  }) async {
    try {
      LoggerService.info('FormApiService', 'حذف فرم - Deleting form', {
        'form_id': formId,
        'user_id': userId,
        'permanent': permanent,
      });

      final requestData = {
        'form_id': formId,
        'user_id': userId,
        'permanent': permanent,
      };

      final response = await http.delete(
        Uri.parse('$_baseUrl/delete.php'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json',
        },
        body: json.encode(requestData),
      );

      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200 && responseData['success'] == true) {
        LoggerService.info('FormApiService', 'فرم با موفقیت حذف شد - Form deleted successfully', {
          'form_id': formId,
        });
        
        return {
          'success': true,
          'data': responseData['data'],
          'message': responseData['message'],
        };
      } else {
        LoggerService.warning('FormApiService', 'خطا در حذف فرم - Form deletion failed', {
          'status_code': response.statusCode,
          'error': responseData['message'],
        });
        
        return {
          'success': false,
          'message': responseData['message'] ?? 'خطا در حذف فرم',
        };
      }
    } catch (e) {
      LoggerService.error('FormApiService', 'خطای سیستمی در حذف فرم - System error in form deletion', e);
      
      return {
        'success': false,
        'message': 'خطای ارتباط با سرور',
        'error': e.toString(),
      };
    }
  }

  /// انتشار فرم
  /// Publish form
  static Future<Map<String, dynamic>> publishForm({
    required int formId,
    required int userId,
  }) async {
    return updateForm(
      formId: formId,
      userId: userId,
      status: 'published',
    );
  }

  /// توقف فرم
  /// Pause form
  static Future<Map<String, dynamic>> pauseForm({
    required int formId,
    required int userId,
  }) async {
    return updateForm(
      formId: formId,
      userId: userId,
      status: 'paused',
    );
  }

  /// آرشیو فرم
  /// Archive form
  static Future<Map<String, dynamic>> archiveForm({
    required int formId,
    required int userId,
  }) async {
    return updateForm(
      formId: formId,
      userId: userId,
      status: 'archived',
    );
  }

  /// اعتبارسنجی داده‌های فرم
  /// Validate form data
  static Map<String, dynamic> validateFormData({
    required String persianTitle,
    required Map<String, dynamic> formSchema,
    String? persianDescription,
    int? maxResponses,
  }) {
    final errors = <String>[];

    // اعتبارسنجی عنوان
    if (persianTitle.trim().length < 3) {
      errors.add('عنوان فرم باید حداقل ۳ کاراکتر باشد');
    }
    if (persianTitle.trim().length > 255) {
      errors.add('عنوان فرم نباید بیش از ۲۵۵ کاراکتر باشد');
    }

    // اعتبارسنجی schema
    if (!formSchema.containsKey('widgets')) {
      errors.add('ساختار فرم باید حداقل یک ویجت داشته باشد');
    } else {
      final widgets = formSchema['widgets'];
      if (widgets is! List || widgets.isEmpty) {
        errors.add('فرم باید حداقل یک ویجت داشته باشد');
      }
    }

    // اعتبارسنجی توضیحات
    if (persianDescription != null && persianDescription.length > 1000) {
      errors.add('توضیحات فرم نباید بیش از ۱۰۰۰ کاراکتر باشد');
    }

    // اعتبارسنجی حداکثر پاسخ
    if (maxResponses != null && maxResponses <= 0) {
      errors.add('حداکثر تعداد پاسخ باید عدد مثبت باشد');
    }

    return {
      'valid': errors.isEmpty,
      'errors': errors,
    };
  }
}
