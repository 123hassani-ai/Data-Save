import '../models/simple_widget_model.dart';
import '../logger/logger_service.dart';
import 'form_api_service.dart';

/// سرویس ساخت فرم - Form Builder Service
/// مدیریت عملیات ساخت و ویرایش فرم‌ها
class FormBuilderService {
  
  /// ایجاد فرم جدید از ویجت‌ها
  /// Create new form from widgets
  static Future<Map<String, dynamic>> createFormFromBuilder({
    required int userId,
    required String persianTitle,
    String? englishTitle,
    String? persianDescription,
    String? englishDescription,
    required List<WidgetModel> widgets,
    Map<String, dynamic>? formConfig,
    Map<String, dynamic>? formSettings,
    String status = 'draft',
    bool isPublic = false,
    bool requiresLogin = false,
    int? maxResponses,
    String? expiresAt,
  }) async {
    try {
      LoggerService.info('FormBuilderService', 'ایجاد فرم از ساخت‌ساز - Creating form from builder', {
        'user_id': userId,
        'title': persianTitle,
        'widgets_count': widgets.length,
        'status': status,
      });

      // اعتبارسنجی اولیه
      if (widgets.isEmpty) {
        return {
          'success': false,
          'message': 'فرم باید حداقل یک ویجت داشته باشد',
          'error': 'no_widgets',
        };
      }

      // تبدیل ویجت‌ها به schema
      final formSchema = _buildFormSchema(widgets);

      // اعتبارسنجی schema
      final validation = FormApiService.validateFormData(
        persianTitle: persianTitle,
        formSchema: formSchema,
        persianDescription: persianDescription,
        maxResponses: maxResponses,
      );

      if (!validation['valid']) {
        return {
          'success': false,
          'message': 'داده‌های فرم نامعتبر هستند',
          'errors': validation['errors'],
          'error': 'validation_failed',
        };
      }

      // ایجاد فرم از طریق API
      final createResult = await FormApiService.createForm(
        userId: userId,
        persianTitle: persianTitle,
        englishTitle: englishTitle,
        persianDescription: persianDescription,
        englishDescription: englishDescription,
        formSchema: formSchema,
        formConfig: formConfig,
        formSettings: formSettings,
        status: status,
        isPublic: isPublic,
        requiresLogin: requiresLogin,
        maxResponses: maxResponses,
        expiresAt: expiresAt,
      );

      if (createResult['success']) {
        LoggerService.info('FormBuilderService', 'فرم با موفقیت از ساخت‌ساز ایجاد شد - Form created successfully from builder', {
          'form_id': createResult['data']?['form_id'],
          'widgets_count': widgets.length,
        });

        return {
          'success': true,
          'data': {
            ...createResult['data'],
            'widgets_count': widgets.length,
            'form_schema': formSchema,
          },
          'message': createResult['message'],
        };
      } else {
        LoggerService.warning('FormBuilderService', 'خطا در ایجاد فرم از ساخت‌ساز - Failed to create form from builder', {
          'error': createResult['message'],
        });

        return createResult;
      }
    } catch (e) {
      LoggerService.error('FormBuilderService', 'خطای سیستمی در ایجاد فرم از ساخت‌ساز - System error in form creation', e);
      
      return {
        'success': false,
        'message': 'خطای سیستمی در ایجاد فرم',
        'error': e.toString(),
      };
    }
  }

  /// بروزرسانی فرم با ویجت‌های جدید
  /// Update form with new widgets
  static Future<Map<String, dynamic>> updateFormFromBuilder({
    required int formId,
    required int userId,
    String? persianTitle,
    String? englishTitle,
    String? persianDescription,
    String? englishDescription,
    List<WidgetModel>? widgets,
    Map<String, dynamic>? formConfig,
    Map<String, dynamic>? formSettings,
    String? status,
    bool? isPublic,
    bool? requiresLogin,
    int? maxResponses,
    String? expiresAt,
  }) async {
    try {
      LoggerService.info('FormBuilderService', 'بروزرسانی فرم از ساخت‌ساز - Updating form from builder', {
        'form_id': formId,
        'user_id': userId,
        'widgets_count': widgets?.length,
        'status': status,
      });

      Map<String, dynamic>? formSchema;

      // اگر ویجت‌های جدید ارسال شده، schema جدید بساز
      if (widgets != null) {
        if (widgets.isEmpty) {
          return {
            'success': false,
            'message': 'فرم باید حداقل یک ویجت داشته باشد',
            'error': 'no_widgets',
          };
        }

        formSchema = _buildFormSchema(widgets);

        // اعتبارسنجی schema جدید
        if (persianTitle != null) {
          final validation = FormApiService.validateFormData(
            persianTitle: persianTitle,
            formSchema: formSchema,
            persianDescription: persianDescription,
            maxResponses: maxResponses,
          );

          if (!validation['valid']) {
            return {
              'success': false,
              'message': 'داده‌های فرم نامعتبر هستند',
              'errors': validation['errors'],
              'error': 'validation_failed',
            };
          }
        }
      }

      // بروزرسانی فرم از طریق API
      final updateResult = await FormApiService.updateForm(
        formId: formId,
        userId: userId,
        persianTitle: persianTitle,
        englishTitle: englishTitle,
        persianDescription: persianDescription,
        englishDescription: englishDescription,
        formSchema: formSchema,
        formConfig: formConfig,
        formSettings: formSettings,
        status: status,
        isPublic: isPublic,
        requiresLogin: requiresLogin,
        maxResponses: maxResponses,
        expiresAt: expiresAt,
      );

      if (updateResult['success']) {
        LoggerService.info('FormBuilderService', 'فرم با موفقیت از ساخت‌ساز بروزرسانی شد - Form updated successfully from builder', {
          'form_id': formId,
          'widgets_count': widgets?.length,
        });

        return {
          'success': true,
          'data': {
            ...updateResult['data'],
            'widgets_count': widgets?.length,
            'form_schema': formSchema,
          },
          'message': updateResult['message'],
        };
      } else {
        LoggerService.warning('FormBuilderService', 'خطا در بروزرسانی فرم از ساخت‌ساز - Failed to update form from builder', {
          'error': updateResult['message'],
        });

        return updateResult;
      }
    } catch (e) {
      LoggerService.error('FormBuilderService', 'خطای سیستمی در بروزرسانی فرم از ساخت‌ساز - System error in form update', e);
      
      return {
        'success': false,
        'message': 'خطای سیستمی در بروزرسانی فرم',
        'error': e.toString(),
      };
    }
  }

  /// تبدیل ویجت‌ها به schema
  /// Convert widgets to form schema
  static Map<String, dynamic> _buildFormSchema(List<WidgetModel> widgets) {
    return {
      'widgets': widgets.map((widget) => widget.toJson()).toList(),
      'version': '2.0',
      'created_at': DateTime.now().toIso8601String(),
      'builder_info': {
        'total_widgets': widgets.length,
        'widget_types': _getWidgetTypesCounts(widgets),
        'has_required_fields': widgets.any((w) => w.isRequired),
        'has_validation': widgets.any((w) => w.validationRules.isNotEmpty),
      },
    };
  }

  /// شمارش انواع ویجت‌ها
  /// Count widget types
  static Map<String, int> _getWidgetTypesCounts(List<WidgetModel> widgets) {
    final counts = <String, int>{};
    
    for (final widget in widgets) {
      counts[widget.type] = (counts[widget.type] ?? 0) + 1;
    }
    
    return counts;
  }

  /// بازیابی ویجت‌ها از schema
  /// Recover widgets from schema
  static List<WidgetModel> parseWidgetsFromSchema(Map<String, dynamic> formSchema) {
    try {
      final widgets = <WidgetModel>[];
      
      if (formSchema.containsKey('widgets') && formSchema['widgets'] is List) {
        final widgetsData = formSchema['widgets'] as List;
        
        for (final widgetData in widgetsData) {
          if (widgetData is Map<String, dynamic>) {
            try {
              final widget = WidgetModel.fromJson(widgetData);
              widgets.add(widget);
            } catch (e) {
              LoggerService.warning('FormBuilderService', 'خطا در پارس ویجت - Widget parsing error', {
                'widget_data': widgetData.toString(),
                'error': e.toString(),
              });
            }
          }
        }
      }
      
      LoggerService.info('FormBuilderService', 'ویجت‌ها از schema بازیابی شدند - Widgets recovered from schema', {
        'total_widgets': widgets.length,
      });
      
      return widgets;
    } catch (e) {
      LoggerService.error('FormBuilderService', 'خطا در بازیابی ویجت‌ها از schema - Error recovering widgets from schema', e);
      return <WidgetModel>[];
    }
  }

  /// اعتبارسنجی ساختار فرم
  /// Validate form structure
  static Map<String, dynamic> validateFormStructure(List<WidgetModel> widgets) {
    final errors = <String>[];
    final warnings = <String>[];
    
    // بررسی‌های اساسی
    if (widgets.isEmpty) {
      errors.add('فرم باید حداقل یک ویجت داشته باشد');
      return {
        'valid': false,
        'errors': errors,
        'warnings': warnings,
      };
    }

    // بررسی ID های تکراری
    final ids = widgets.map((w) => w.id).toSet();
    if (ids.length != widgets.length) {
      errors.add('شناسه‌های ویجت‌ها نباید تکراری باشند');
    }

    // بررسی ترتیب
    for (int i = 0; i < widgets.length; i++) {
      if (widgets[i].order != i) {
        warnings.add('ترتیب ویجت‌ها بهینه نیست');
        break;
      }
    }

    // بررسی ویجت‌های ضروری
    final requiredWidgets = widgets.where((w) => w.isRequired).toList();
    if (requiredWidgets.isEmpty) {
      warnings.add('فرم هیچ فیلد اجباری ندارد');
    }

    // بررسی طول عنوان‌ها
    for (final widget in widgets) {
      if (widget.persianLabel.length > 100) {
        warnings.add('عنوان ویجت "${widget.persianLabel}" خیلی طولانی است');
      }
    }

    return {
      'valid': errors.isEmpty,
      'errors': errors,
      'warnings': warnings,
      'stats': {
        'total_widgets': widgets.length,
        'required_widgets': requiredWidgets.length,
        'widget_types': _getWidgetTypesCounts(widgets),
      },
    };
  }

  /// ایجاد فرم پیش‌فرض
  /// Create default form
  static List<WidgetModel> createDefaultForm() {
    return [
      WidgetModel(
        id: 'widget_1',
        type: 'text_field',
        persianLabel: 'نام و نام خانوادگی',
        englishLabel: 'Full Name',
        isRequired: true,
        order: 0,
        validationRules: {
          'min_length': 2,
          'max_length': 100,
        },
        config: {
          'placeholder': 'نام خود را وارد کنید',
          'hint': 'نام و نام خانوادگی کامل',
        },
      ),
      WidgetModel(
        id: 'widget_2',
        type: 'email',
        persianLabel: 'ایمیل',
        englishLabel: 'Email',
        isRequired: true,
        order: 1,
        validationRules: {
          'email_format': true,
        },
        config: {
          'placeholder': 'example@email.com',
          'hint': 'آدرس ایمیل معتبر وارد کنید',
        },
      ),
      WidgetModel(
        id: 'widget_3',
        type: 'textarea',
        persianLabel: 'پیام',
        englishLabel: 'Message',
        isRequired: false,
        order: 2,
        validationRules: {
          'max_length': 500,
        },
        config: {
          'placeholder': 'پیام خود را بنویسید...',
          'rows': 4,
        },
      ),
    ];
  }

  /// کپی فرم با ویجت‌های جدید
  /// Duplicate form with new widgets
  static Future<Map<String, dynamic>> duplicateFormFromBuilder({
    required int sourceFormId,
    required int userId,
    required String newPersianTitle,
    String? newEnglishTitle,
    List<WidgetModel>? modifiedWidgets,
  }) async {
    try {
      LoggerService.info('FormBuilderService', 'کپی فرم از ساخت‌ساز - Duplicating form from builder', {
        'source_form_id': sourceFormId,
        'user_id': userId,
        'new_title': newPersianTitle,
        'modified_widgets': modifiedWidgets?.length,
      });

      // دریافت فرم اصلی
      final sourceFormResponse = await FormApiService.getFormById(formId: sourceFormId);
      
      if (!sourceFormResponse['success']) {
        return sourceFormResponse;
      }

      final sourceForm = sourceFormResponse['data']['form'];
      
      // استفاده از ویجت‌های تغییر یافته یا بازیابی از schema اصلی
      final widgets = modifiedWidgets ?? parseWidgetsFromSchema(sourceForm['form_schema']);
      
      // ایجاد فرم جدید
      return createFormFromBuilder(
        userId: userId,
        persianTitle: newPersianTitle,
        englishTitle: newEnglishTitle,
        persianDescription: sourceForm['persian_description'],
        englishDescription: sourceForm['english_description'],
        widgets: widgets,
        formConfig: sourceForm['form_config'],
        formSettings: sourceForm['form_settings'],
        status: 'draft', // فرم کپی شده همیشه draft است
        isPublic: false, // فرم کپی شده همیشه private است
        requiresLogin: sourceForm['requires_login'] ?? false,
        maxResponses: sourceForm['max_responses'],
      );
    } catch (e) {
      LoggerService.error('FormBuilderService', 'خطا در کپی فرم از ساخت‌ساز - Error duplicating form from builder', e);
      
      return {
        'success': false,
        'message': 'خطا در کپی فرم: ${e.toString()}',
        'error': 'duplication_error',
      };
    }
  }
}
