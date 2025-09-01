import 'package:flutter/foundation.dart';
import '../../core/models/simple_widget_model.dart';
import '../../core/services/form_builder_service.dart';
import '../../core/services/form_api_service.dart';
import '../../core/logger/logger_service.dart';

/// کنترل‌کننده ساخت فرم - Form Builder Provider
/// مدیریت state ساخت و ویرایش فرم‌ها
class FormBuilderProvider with ChangeNotifier {
  // ویجت‌های فعلی فرم
  List<WidgetModel> _widgets = [];
  List<WidgetModel> get widgets => List.unmodifiable(_widgets);

  // اطلاعات فرم
  String _persianTitle = '';
  String _englishTitle = '';
  String _persianDescription = '';
  String _englishDescription = '';
  String _formStatus = 'draft';
  bool _isPublic = false;
  bool _requiresLogin = false;
  int? _maxResponses;

  // حالت UI
  bool _isLoading = false;
  String? _error;
  int? _currentFormId;
  String? _successMessage;

  // Getters
  String get persianTitle => _persianTitle;
  String get englishTitle => _englishTitle;
  String get persianDescription => _persianDescription;
  String get englishDescription => _englishDescription;
  String get formStatus => _formStatus;
  bool get isPublic => _isPublic;
  bool get requiresLogin => _requiresLogin;
  int? get maxResponses => _maxResponses;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;
  int? get currentFormId => _currentFormId;
  
  bool get hasWidgets => _widgets.isNotEmpty;
  int get widgetCount => _widgets.length;
  bool get hasUnsavedChanges => _widgets.isNotEmpty || _persianTitle.isNotEmpty;

  /// تنظیم اطلاعات فرم
  void setFormInfo({
    String? persianTitle,
    String? englishTitle,
    String? persianDescription,
    String? englishDescription,
    String? status,
    bool? isPublic,
    bool? requiresLogin,
    int? maxResponses,
  }) {
    if (persianTitle != null) _persianTitle = persianTitle;
    if (englishTitle != null) _englishTitle = englishTitle;
    if (persianDescription != null) _persianDescription = persianDescription;
    if (englishDescription != null) _englishDescription = englishDescription;
    if (status != null) _formStatus = status;
    if (isPublic != null) _isPublic = isPublic;
    if (requiresLogin != null) _requiresLogin = requiresLogin;
    if (maxResponses != null) _maxResponses = maxResponses;
    
    clearError();
    notifyListeners();
  }

  /// افزودن ویجت جدید
  void addWidget(WidgetModel widget) {
    try {
      // تنظیم order جدید
      final newWidget = widget.copyWith(order: _widgets.length);
      _widgets.add(newWidget);
      
      LoggerService.info('FormBuilderProvider', 'ویجت جدید اضافه شد - New widget added', {
        'widget_id': widget.id,
        'widget_type': widget.type,
        'total_widgets': _widgets.length,
      });
      
      clearError();
      notifyListeners();
    } catch (e) {
      setError('خطا در افزودن ویجت: ${e.toString()}');
    }
  }

  /// حذف ویجت
  void removeWidget(String widgetId) {
    try {
      final index = _widgets.indexWhere((w) => w.id == widgetId);
      if (index != -1) {
        final removedWidget = _widgets.removeAt(index);
        
        // تنظیم مجدد order های ویجت‌ها
        _reorderWidgets();
        
        LoggerService.info('FormBuilderProvider', 'ویجت حذف شد - Widget removed', {
          'widget_id': widgetId,
          'widget_type': removedWidget.type,
          'remaining_widgets': _widgets.length,
        });
        
        clearError();
        notifyListeners();
      }
    } catch (e) {
      setError('خطا در حذف ویجت: ${e.toString()}');
    }
  }

  /// بروزرسانی ویجت
  void updateWidget(String widgetId, WidgetModel updatedWidget) {
    try {
      final index = _widgets.indexWhere((w) => w.id == widgetId);
      if (index != -1) {
        _widgets[index] = updatedWidget.copyWith(order: index);
        
        LoggerService.info('FormBuilderProvider', 'ویجت بروزرسانی شد - Widget updated', {
          'widget_id': widgetId,
          'widget_type': updatedWidget.type,
        });
        
        clearError();
        notifyListeners();
      }
    } catch (e) {
      setError('خطا در بروزرسانی ویجت: ${e.toString()}');
    }
  }

  /// تغییر موقعیت ویجت
  void reorderWidget(int oldIndex, int newIndex) {
    try {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      
      final widget = _widgets.removeAt(oldIndex);
      _widgets.insert(newIndex, widget);
      
      // تنظیم مجدد order های ویجت‌ها
      _reorderWidgets();
      
      LoggerService.info('FormBuilderProvider', 'ترتیب ویجت تغییر کرد - Widget reordered', {
        'widget_id': widget.id,
        'old_index': oldIndex,
        'new_index': newIndex,
      });
      
      clearError();
      notifyListeners();
    } catch (e) {
      setError('خطا در تغییر ترتیب ویجت: ${e.toString()}');
    }
  }

  /// تنظیم مجدد order های ویجت‌ها
  void _reorderWidgets() {
    for (int i = 0; i < _widgets.length; i++) {
      _widgets[i] = _widgets[i].copyWith(order: i);
    }
  }

  /// درج ویجت در موقعیت مشخص
  void insertWidgetAt(WidgetModel widget, int index) {
    try {
      final newWidget = widget.copyWith(
        id: widget.id.isEmpty ? 'widget_${DateTime.now().millisecondsSinceEpoch}' : widget.id,
        order: index,
      );
      
      if (index >= _widgets.length) {
        _widgets.add(newWidget);
      } else {
        _widgets.insert(index, newWidget);
      }
      
      _reorderWidgets();
      
      LoggerService.info('FormBuilderProvider', 'ویجت در موقعیت مشخص درج شد - Widget inserted at index', {
        'widget_id': newWidget.id,
        'widget_type': newWidget.type,
        'index': index,
        'total_widgets': _widgets.length,
      });
      
      clearError();
      notifyListeners();
    } catch (e) {
      setError('خطا در درج ویجت: ${e.toString()}');
    }
  }

  /// جابجایی ویجت
  void moveWidget(int fromIndex, int toIndex) {
    try {
      if (fromIndex < 0 || fromIndex >= _widgets.length ||
          toIndex < 0 || toIndex >= _widgets.length) {
        return;
      }
      
      if (fromIndex == toIndex) return;
      
      final widget = _widgets.removeAt(fromIndex);
      _widgets.insert(toIndex, widget);
      
      _reorderWidgets();
      
      LoggerService.info('FormBuilderProvider', 'ویجت جابجا شد - Widget moved', {
        'widget_id': widget.id,
        'from_index': fromIndex,
        'to_index': toIndex,
      });
      
      clearError();
      notifyListeners();
    } catch (e) {
      setError('خطا در جابجایی ویجت: ${e.toString()}');
    }
  }

  /// ذخیره فرم
  Future<void> saveForm({bool asDraft = true}) async {
    if (_persianTitle.isEmpty) {
      setError('عنوان فرم نباید خالی باشد');
      return;
    }

    if (_widgets.isEmpty) {
      setError('فرم باید حداقل یک ویجت داشته باشد');
      return;
    }

    setLoading(true);
    
    try {
      final result = await FormBuilderService.createFormFromBuilder(
        userId: 1, // TODO: دریافت از authentication
        persianTitle: _persianTitle,
        englishTitle: _englishTitle.isEmpty ? null : _englishTitle,
        persianDescription: _persianDescription.isEmpty ? null : _persianDescription,
        englishDescription: _englishDescription.isEmpty ? null : _englishDescription,
        widgets: _widgets,
        status: asDraft ? 'draft' : _formStatus,
        isPublic: _isPublic,
        requiresLogin: _requiresLogin,
        maxResponses: _maxResponses,
      );

      if (result['success']) {
        _currentFormId = result['data']?['form_id'];
        setSuccess('فرم با موفقیت ذخیره شد');
        
        LoggerService.info('FormBuilderProvider', 'فرم با موفقیت ذخیره شد - Form saved successfully', {
          'form_id': _currentFormId,
          'title': _persianTitle,
          'widgets_count': _widgets.length,
        });
      } else {
        setError(result['message'] ?? 'خطا در ذخیره فرم');
      }
    } catch (e) {
      setError('خطای سیستمی در ذخیره فرم: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  /// بروزرسانی فرم موجود
  Future<void> updateForm() async {
    if (_currentFormId == null) {
      setError('شناسه فرم برای بروزرسانی موجود نیست');
      return;
    }

    if (_persianTitle.isEmpty) {
      setError('عنوان فرم نباید خالی باشد');
      return;
    }

    setLoading(true);
    
    try {
      final result = await FormBuilderService.updateFormFromBuilder(
        formId: _currentFormId!,
        userId: 1, // TODO: دریافت از authentication
        persianTitle: _persianTitle,
        englishTitle: _englishTitle.isEmpty ? null : _englishTitle,
        persianDescription: _persianDescription.isEmpty ? null : _persianDescription,
        englishDescription: _englishDescription.isEmpty ? null : _englishDescription,
        widgets: _widgets,
        status: _formStatus,
        isPublic: _isPublic,
        requiresLogin: _requiresLogin,
        maxResponses: _maxResponses,
      );

      if (result['success']) {
        setSuccess('فرم با موفقیت بروزرسانی شد');
        
        LoggerService.info('FormBuilderProvider', 'فرم با موفقیت بروزرسانی شد - Form updated successfully', {
          'form_id': _currentFormId,
          'title': _persianTitle,
          'widgets_count': _widgets.length,
        });
      } else {
        setError(result['message'] ?? 'خطا در بروزرسانی فرم');
      }
    } catch (e) {
      setError('خطای سیستمی در بروزرسانی فرم: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  /// بارگیری فرم برای ویرایش
  Future<void> loadForm(int formId) async {
    setLoading(true);
    clearError();

    try {
      final result = await FormApiService.getFormById(formId: formId);

      if (result['success']) {
        final formData = result['data']['form'];
        
        // تنظیم اطلاعات فرم
        _currentFormId = formId;
        _persianTitle = formData['persian_title'] ?? '';
        _englishTitle = formData['english_title'] ?? '';
        _persianDescription = formData['persian_description'] ?? '';
        _englishDescription = formData['english_description'] ?? '';
        _formStatus = formData['status'] ?? 'draft';
        _isPublic = formData['is_public'] ?? false;
        _requiresLogin = formData['requires_login'] ?? false;
        _maxResponses = formData['max_responses'];

        // بازیابی ویجت‌ها
        _widgets = FormBuilderService.parseWidgetsFromSchema(formData['form_schema'] ?? {});

        setSuccess('فرم با موفقیت بارگیری شد');
        
        LoggerService.info('FormBuilderProvider', 'فرم برای ویرایش بارگیری شد - Form loaded for editing', {
          'form_id': formId,
          'title': _persianTitle,
          'widgets_count': _widgets.length,
        });
      } else {
        setError(result['message'] ?? 'خطا در بارگیری فرم');
      }
    } catch (e) {
      setError('خطای سیستمی در بارگیری فرم: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  /// انتشار فرم
  Future<void> publishForm() async {
    if (_currentFormId == null) {
      setError('شناسه فرم برای انتشار موجود نیست');
      return;
    }

    setLoading(true);

    try {
      final result = await FormApiService.publishForm(
        formId: _currentFormId!,
        userId: 1, // TODO: دریافت از authentication
      );

      if (result['success']) {
        _formStatus = 'published';
        setSuccess('فرم با موفقیت منتشر شد');
        
        LoggerService.info('FormBuilderProvider', 'فرم منتشر شد - Form published', {
          'form_id': _currentFormId,
          'title': _persianTitle,
        });
      } else {
        setError(result['message'] ?? 'خطا در انتشار فرم');
      }
    } catch (e) {
      setError('خطای سیستمی در انتشار فرم: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  /// پیش‌نمایش فرم
  Map<String, dynamic> getFormPreview() {
    return {
      'title': _persianTitle,
      'description': _persianDescription,
      'widgets': _widgets.map((w) => w.toJson()).toList(),
      'total_widgets': _widgets.length,
      'required_widgets': _widgets.where((w) => w.isRequired).length,
      'widget_types': _getWidgetTypeCounts(),
    };
  }

  /// شمارش انواع ویجت‌ها
  Map<String, int> _getWidgetTypeCounts() {
    final counts = <String, int>{};
    for (final widget in _widgets) {
      counts[widget.type] = (counts[widget.type] ?? 0) + 1;
    }
    return counts;
  }

  /// پاکسازی فرم
  void clearForm() {
    _widgets.clear();
    _persianTitle = '';
    _englishTitle = '';
    _persianDescription = '';
    _englishDescription = '';
    _formStatus = 'draft';
    _isPublic = false;
    _requiresLogin = false;
    _maxResponses = null;
    _currentFormId = null;
    
    clearError();
    clearSuccess();
    
    LoggerService.info('FormBuilderProvider', 'فرم پاک شد - Form cleared');
    notifyListeners();
  }

  /// تنظیم حالت loading
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// تنظیم خطا
  void setError(String error) {
    _error = error;
    _successMessage = null;
    LoggerService.error('FormBuilderProvider', 'خطا در FormBuilderProvider', _error);
    notifyListeners();
  }

  /// پاکسازی خطا
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// تنظیم پیام موفقیت
  void setSuccess(String message) {
    _successMessage = message;
    _error = null;
    notifyListeners();
  }

  /// پاکسازی پیام موفقیت
  void clearSuccess() {
    _successMessage = null;
    notifyListeners();
  }

  /// ایجاد فرم پیش‌فرض
  void loadDefaultForm() {
    _widgets = FormBuilderService.createDefaultForm();
    _persianTitle = 'فرم جدید';
    _englishTitle = 'New Form';
    
    LoggerService.info('FormBuilderProvider', 'فرم پیش‌فرض بارگیری شد - Default form loaded', {
      'widgets_count': _widgets.length,
    });
    
    clearError();
    notifyListeners();
  }

  /// اعتبارسنجی فرم
  Map<String, dynamic> validateForm() {
    final errors = <String>[];
    final warnings = <String>[];

    // بررسی عنوان
    if (_persianTitle.trim().isEmpty) {
      errors.add('عنوان فرم نباید خالی باشد');
    }

    // بررسی ویجت‌ها
    if (_widgets.isEmpty) {
      errors.add('فرم باید حداقل یک ویجت داشته باشد');
    }

    // بررسی ID های تکراری
    final ids = _widgets.map((w) => w.id).toSet();
    if (ids.length != _widgets.length) {
      errors.add('شناسه‌های ویجت‌ها نباید تکراری باشند');
    }

    // بررسی فیلدهای اجباری
    final requiredWidgets = _widgets.where((w) => w.isRequired).toList();
    if (requiredWidgets.isEmpty) {
      warnings.add('فرم هیچ فیلد اجباری ندارد');
    }

    return {
      'valid': errors.isEmpty,
      'errors': errors,
      'warnings': warnings,
    };
  }
}
