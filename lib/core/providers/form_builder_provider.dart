import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/form_api_service.dart';
import '../logger/logger_service.dart';

/// Provider فرم‌ساز - Form Builder Provider
/// مدیریت state کامل Form Builder UI Engine
class FormBuilderProvider with ChangeNotifier {
  // اطلاعات فرم فعلی - Current form information
  Map<String, dynamic>? _currentForm;
  int? _currentUserId;
  bool _isNewForm = true;
  
  // وضعیت بوم طراحی - Canvas state
  final List<Map<String, dynamic>> _canvasWidgets = [];
  Map<String, dynamic>? _selectedWidget;
  String? _selectedWidgetId;
  
  // حالت‌های UI - UI states
  bool _isPreviewMode = false;
  bool _isPropertiesPanelVisible = true;
  bool _isWidgetLibraryVisible = true;
  
  // وضعیت‌های عملیات - Operation states
  bool _isSaving = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  
  // تنظیمات فرم - Form settings
  Map<String, dynamic> _formConfig = {
    'theme': 'default',
    'direction': 'rtl',
    'language': 'fa',
  };
  
  Map<String, dynamic> _formSettings = {
    'allow_multiple_responses': true,
    'require_email': false,
    'auto_save': true,
  };

  // Schema فرم برای ذخیره - Form schema for saving
  Map<String, dynamic> _formSchema = {
    'version': '1.0',
    'widgets': [],
  };

  // Getters
  Map<String, dynamic>? get currentForm => _currentForm;
  int? get currentUserId => _currentUserId;
  bool get isNewForm => _isNewForm;
  List<Map<String, dynamic>> get canvasWidgets => _canvasWidgets;
  Map<String, dynamic>? get selectedWidget => _selectedWidget;
  String? get selectedWidgetId => _selectedWidgetId;
  bool get isPreviewMode => _isPreviewMode;
  bool get isPropertiesPanelVisible => _isPropertiesPanelVisible;
  bool get isWidgetLibraryVisible => _isWidgetLibraryVisible;
  bool get isSaving => _isSaving;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  Map<String, dynamic> get formConfig => _formConfig;
  Map<String, dynamic> get formSettings => _formSettings;
  Map<String, dynamic> get formSchema => _formSchema;
  bool get hasUnsavedChanges => _hasUnsavedChanges();

  /// چک کردن وجود تغییرات ذخیره نشده
  bool _hasUnsavedChanges() {
    if (_isNewForm && _canvasWidgets.isNotEmpty) return true;
    // TODO: مقایسه با فرم اصلی برای تشخیص تغییرات
    return false;
  }

  /// شروع ایجاد فرم جدید
  /// Start creating new form
  void startNewForm(int userId) {
    _currentUserId = userId;
    _isNewForm = true;
    _currentForm = null;
    _canvasWidgets.clear();
    _selectedWidget = null;
    _selectedWidgetId = null;
    _isPreviewMode = false;
    _formSchema = {
      'version': '1.0',
      'widgets': [],
    };
    
    _setError(null);
    _setSuccessMessage(null);
    
    notifyListeners();
    
    LoggerService.info('FormBuilderProvider', 'شروع ایجاد فرم جدید - Starting new form creation', {
      'user_id': userId,
    });
  }

  /// بارگذاری فرم موجود برای ویرایش
  /// Load existing form for editing
  Future<void> loadFormForEditing(int formId, int userId) async {
    _setLoading(true);
    _setError(null);
    
    try {
      LoggerService.info('FormBuilderProvider', 'بارگذاری فرم برای ویرایش - Loading form for editing', {
        'form_id': formId,
        'user_id': userId,
      });

      // در اینجا باید از API فرم خاص دریافت شود - فعلاً placeholder
      // final result = await FormApiService.getFormById(formId);
      
      // موقتاً فرم نمونه را بارگذاری می‌کنیم
      _currentForm = {
        'id': formId,
        'user_id': userId,
        'persian_title': 'فرم نمونه',
        'status': 'draft',
      };
      
      _currentUserId = userId;
      _isNewForm = false;
      _canvasWidgets.clear();
      _selectedWidget = null;
      _selectedWidgetId = null;
      _isPreviewMode = false;
      
      LoggerService.info('FormBuilderProvider', 'فرم برای ویرایش بارگذاری شد - Form loaded for editing', {
        'form_id': formId,
      });
      
    } catch (e) {
      _setError('خطا در بارگذاری فرم');
      LoggerService.error('FormBuilderProvider', 'خطا در بارگذاری فرم برای ویرایش', e);
    } finally {
      _setLoading(false);
    }
  }

  /// افزودن ویجت به بوم
  /// Add widget to canvas
  void addWidgetToCanvas(Map<String, dynamic> widgetTemplate) {
    final widgetId = 'widget_${DateTime.now().millisecondsSinceEpoch}';
    
    final canvasWidget = {
      'id': widgetId,
      'widget_type': widgetTemplate['widget_type'],
      'persian_label': widgetTemplate['persian_label'],
      'english_label': widgetTemplate['english_label'],
      'widget_config': Map<String, dynamic>.from(widgetTemplate['widget_config'] ?? {}),
      'validation_rules': Map<String, dynamic>.from(widgetTemplate['validation_rules'] ?? {}),
      'icon_name': widgetTemplate['icon_name'],
      'position': {
        'x': 0,
        'y': _canvasWidgets.length * 80, // فاصله عمودی پیش‌فرض
      },
      'size': {
        'width': 300,
        'height': 60,
      },
      'properties': {
        'label': widgetTemplate['persian_label'],
        'required': false,
        'placeholder': '',
        ...Map<String, dynamic>.from(widgetTemplate['widget_config'] ?? {}),
      }
    };

    _canvasWidgets.add(canvasWidget);
    _updateFormSchema();
    
    // انتخاب خودکار ویجت جدید
    selectWidget(widgetId);
    
    notifyListeners();
    
    LoggerService.info('FormBuilderProvider', 'ویجت به بوم اضافه شد - Widget added to canvas', {
      'widget_id': widgetId,
      'widget_type': widgetTemplate['widget_type'],
      'total_widgets': _canvasWidgets.length,
    });
  }

  /// حذف ویجت از بوم
  /// Remove widget from canvas
  void removeWidgetFromCanvas(String widgetId) {
    final initialCount = _canvasWidgets.length;
    _canvasWidgets.removeWhere((widget) => widget['id'] == widgetId);
    
    if (_selectedWidgetId == widgetId) {
      _selectedWidget = null;
      _selectedWidgetId = null;
    }
    
    _updateFormSchema();
    notifyListeners();
    
    LoggerService.info('FormBuilderProvider', 'ویجت از بوم حذف شد - Widget removed from canvas', {
      'widget_id': widgetId,
      'widgets_removed': initialCount - _canvasWidgets.length,
      'remaining_widgets': _canvasWidgets.length,
    });
  }

  /// انتخاب ویجت
  /// Select widget
  void selectWidget(String widgetId) {
    final widget = _canvasWidgets.firstWhere(
      (w) => w['id'] == widgetId,
      orElse: () => {},
    );
    
    if (widget.isNotEmpty) {
      _selectedWidget = widget;
      _selectedWidgetId = widgetId;
      
      // نمایش پنل تنظیمات در صورت مخفی بودن
      if (!_isPropertiesPanelVisible) {
        _isPropertiesPanelVisible = true;
      }
      
      notifyListeners();
      
      LoggerService.info('FormBuilderProvider', 'ویجت انتخاب شد - Widget selected', {
        'widget_id': widgetId,
        'widget_type': widget['widget_type'],
      });
    }
  }

  /// لغو انتخاب ویجت
  /// Deselect widget
  void deselectWidget() {
    _selectedWidget = null;
    _selectedWidgetId = null;
    notifyListeners();
    
    LoggerService.info('FormBuilderProvider', 'انتخاب ویجت لغو شد - Widget deselected');
  }

  /// بروزرسانی خصوصیات ویجت
  /// Update widget properties
  void updateWidgetProperties(String widgetId, Map<String, dynamic> properties) {
    final widgetIndex = _canvasWidgets.indexWhere((w) => w['id'] == widgetId);
    
    if (widgetIndex != -1) {
      _canvasWidgets[widgetIndex]['properties'] = {
        ..._canvasWidgets[widgetIndex]['properties'] ?? {},
        ...properties,
      };
      
      // اگر ویجت انتخاب شده است، آن را بروزرسانی کن
      if (_selectedWidgetId == widgetId) {
        _selectedWidget = _canvasWidgets[widgetIndex];
      }
      
      _updateFormSchema();
      notifyListeners();
      
      LoggerService.info('FormBuilderProvider', 'خصوصیات ویجت بروزرسانی شد - Widget properties updated', {
        'widget_id': widgetId,
        'updated_properties': properties.keys.toList(),
      });
    }
  }

  /// تغییر موقعیت ویجت
  /// Change widget position
  void updateWidgetPosition(String widgetId, double x, double y) {
    final widgetIndex = _canvasWidgets.indexWhere((w) => w['id'] == widgetId);
    
    if (widgetIndex != -1) {
      _canvasWidgets[widgetIndex]['position'] = {
        'x': x,
        'y': y,
      };
      
      notifyListeners();
      
      LoggerService.info('FormBuilderProvider', 'موقعیت ویجت تغییر یافت - Widget position updated', {
        'widget_id': widgetId,
        'x': x,
        'y': y,
      });
    }
  }

  /// تغییر به حالت پیش‌نمایش
  /// Toggle preview mode
  void togglePreviewMode() {
    _isPreviewMode = !_isPreviewMode;
    notifyListeners();
    
    LoggerService.info('FormBuilderProvider', 'حالت پیش‌نمایش تغییر یافت - Preview mode toggled', {
      'is_preview_mode': _isPreviewMode,
    });
  }

  /// تغییر نمایش پنل تنظیمات
  /// Toggle properties panel visibility
  void togglePropertiesPanel() {
    _isPropertiesPanelVisible = !_isPropertiesPanelVisible;
    notifyListeners();
    
    LoggerService.info('FormBuilderProvider', 'نمایش پنل تنظیمات تغییر یافت - Properties panel visibility toggled', {
      'is_visible': _isPropertiesPanelVisible,
    });
  }

  /// تغییر نمایش پنل تنظیمات (متد مستعار)
  void togglePropertiesPanelVisibility() => togglePropertiesPanel();

  /// تغییر نمایش کتابخانه ویجت‌ها
  /// Toggle widget library visibility
  void toggleWidgetLibrary() {
    _isWidgetLibraryVisible = !_isWidgetLibraryVisible;
    notifyListeners();
    
    LoggerService.info('FormBuilderProvider', 'نمایش کتابخانه ویجت‌ها تغییر یافت - Widget library visibility toggled', {
      'is_visible': _isWidgetLibraryVisible,
    });
  }

  /// تغییر نمایش کتابخانه ویجت‌ها (متد مستعار)
  void toggleWidgetLibraryVisibility() => toggleWidgetLibrary();

  /// پاک کردن فرم
  /// Clear form
  void clearForm() {
    _canvasWidgets.clear();
    _selectedWidget = null;
    _selectedWidgetId = null;
    _formSchema = {
      'version': '1.0',
      'widgets': [],
    };
    
    notifyListeners();
    
    LoggerService.info('FormBuilderProvider', 'فرم پاک شد - Form cleared');
  }

  /// خروجی JSON فرم
  /// Export form as JSON
  String exportFormAsJson() {
    _updateFormSchema();
    
    final exportData = {
      'form_info': _currentForm,
      'config': _formConfig,
      'settings': _formSettings,
      'schema': _formSchema,
      'export_date': DateTime.now().toIso8601String(),
    };
    
    LoggerService.info('FormBuilderProvider', 'خروجی JSON فرم تولید شد - Form JSON exported');
    
    return JsonEncoder.withIndent('  ').convert(exportData);
  }

  /// ذخیره فرم
  /// Save form
  Future<bool> saveForm({
    String? persianTitle,
    String? englishTitle,
    String? persianDescription,
    String? englishDescription,
    String status = 'draft',
  }) async {
    if (_currentUserId == null) {
      _setError('شناسه کاربر مشخص نیست');
      return false;
    }

    _setSaving(true);
    _setError(null);
    _setSuccessMessage(null);

    try {
      _updateFormSchema();
      
      // استفاده از عنوان فعلی اگر عنوان جدید داده نشده
      final finalPersianTitle = persianTitle ?? _currentForm?['persian_title'] ?? 'فرم جدید';
      
      LoggerService.info('FormBuilderProvider', 'شروع ذخیره فرم - Starting form save', {
        'is_new_form': _isNewForm,
        'widgets_count': _canvasWidgets.length,
        'form_id': _currentForm?['id'],
      });

      Map<String, dynamic> result;
      
      if (_isNewForm) {
        // ایجاد فرم جدید
        result = await FormApiService.createForm(
          userId: _currentUserId!,
          persianTitle: finalPersianTitle,
          englishTitle: englishTitle,
          persianDescription: persianDescription,
          englishDescription: englishDescription,
          formSchema: _formSchema,
          formConfig: _formConfig,
          formSettings: _formSettings,
          status: status,
        );
        
        if (result['success'] == true) {
          _currentForm = result['data'];
          _isNewForm = false;
        }
      } else {
        // بروزرسانی فرم موجود
        result = await FormApiService.updateForm(
          formId: _currentForm!['id'],
          userId: _currentUserId!,
          persianTitle: finalPersianTitle,
          englishTitle: englishTitle,
          persianDescription: persianDescription,
          englishDescription: englishDescription,
          formSchema: _formSchema,
          formConfig: _formConfig,
          formSettings: _formSettings,
          status: status,
        );
        
        if (result['success'] == true) {
          _currentForm = result['data'];
        }
      }

      if (result['success'] == true) {
        _setSuccessMessage('فرم با موفقیت ذخیره شد');
        LoggerService.info('FormBuilderProvider', 'فرم با موفقیت ذخیره شد - Form saved successfully', {
          'form_id': _currentForm?['id'],
        });
        return true;
      } else {
        _setError(result['message'] ?? 'خطا در ذخیره فرم');
        return false;
      }
    } catch (e) {
      _setError('خطای ارتباط با سرور');
      LoggerService.error('FormBuilderProvider', 'خطا در ذخیره فرم', e);
      return false;
    } finally {
      _setSaving(false);
    }
  }

  /// بروزرسانی schema فرم
  /// Update form schema
  void _updateFormSchema() {
    _formSchema = {
      'version': '1.0',
      'widgets': _canvasWidgets.map((widget) => {
        'id': widget['id'],
        'type': widget['widget_type'],
        'label': widget['properties']?['label'] ?? widget['persian_label'],
        'position': widget['position'],
        'size': widget['size'],
        'properties': widget['properties'],
        'validation': widget['validation_rules'],
      }).toList(),
    };
  }

  /// تنظیم وضعیت ذخیره
  void _setSaving(bool isSaving) {
    _isSaving = isSaving;
    notifyListeners();
  }

  /// تنظیم وضعیت بارگذاری
  void _setLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  /// تنظیم پیام خطا
  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// تنظیم پیام موفقیت
  void _setSuccessMessage(String? message) {
    _successMessage = message;
    notifyListeners();
  }

  /// پاک کردن پیام‌ها
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  /// بازنشانی کامل
  void reset() {
    _currentForm = null;
    _currentUserId = null;
    _isNewForm = true;
    _canvasWidgets.clear();
    _selectedWidget = null;
    _selectedWidgetId = null;
    _isPreviewMode = false;
    _isPropertiesPanelVisible = true;
    _isWidgetLibraryVisible = true;
    _isSaving = false;
    _isLoading = false;
    _errorMessage = null;
    _successMessage = null;
    
    _formConfig = {
      'theme': 'default',
      'direction': 'rtl',
      'language': 'fa',
    };
    
    _formSettings = {
      'allow_multiple_responses': true,
      'require_email': false,
      'auto_save': true,
    };
    
    _formSchema = {
      'version': '1.0',
      'widgets': [],
    };
    
    notifyListeners();
    
    LoggerService.info('FormBuilderProvider', 'وضعیت‌های provider بازنشانی شد - Provider states reset');
  }

  /// ترتیب مجدد ویجت‌ها
  void reorderWidgets(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;
    final widget = _canvasWidgets.removeAt(oldIndex);
    _canvasWidgets.insert(newIndex, widget);
    _updateFormSchema();
    notifyListeners();
    
    LoggerService.info('FormBuilderProvider', 'ترتیب ویجت‌ها تغییر یافت - Widgets reordered', {
      'old_index': oldIndex,
      'new_index': newIndex,
    });
  }

  /// انتقال ویجت به بالا
  void moveWidgetUp(String widgetId) {
    final index = _canvasWidgets.indexWhere((w) => w['id'] == widgetId);
    if (index > 0) {
      reorderWidgets(index, index - 1);
    }
  }

  /// انتقال ویجت به پایین  
  void moveWidgetDown(String widgetId) {
    final index = _canvasWidgets.indexWhere((w) => w['id'] == widgetId);
    if (index < _canvasWidgets.length - 1 && index >= 0) {
      reorderWidgets(index, index + 1);
    }
  }

  /// کپی ویجت
  void duplicateWidget(String widgetId) {
    final originalWidget = _canvasWidgets.firstWhere(
      (w) => w['id'] == widgetId,
      orElse: () => {},
    );
    
    if (originalWidget.isNotEmpty) {
      final duplicatedWidget = Map<String, dynamic>.from(originalWidget);
      duplicatedWidget['id'] = DateTime.now().millisecondsSinceEpoch.toString();
      
      // تنظیم موقعیت جدید
      final position = Map<String, dynamic>.from(duplicatedWidget['position'] ?? {});
      position['y'] = (position['y'] ?? 0) + 80;
      duplicatedWidget['position'] = position;
      
      _canvasWidgets.add(duplicatedWidget);
      selectWidget(duplicatedWidget['id']);
      _updateFormSchema();
      notifyListeners();
      
      LoggerService.info('FormBuilderProvider', 'ویجت کپی شد - Widget duplicated', {
        'original_id': widgetId,
        'new_id': duplicatedWidget['id'],
      });
    }
  }
}
