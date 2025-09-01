import 'package:flutter/foundation.dart';
import '../../core/models/widget_model.dart';
import '../../core/logger/logger_service.dart';

/// کنترل‌کننده کتابخانه ویجت‌ها - Widget Library Provider
class WidgetLibraryProvider with ChangeNotifier {
  List<FormWidgetModel> _availableWidgets = [];
  String _selectedCategory = 'all';
  String _searchQuery = '';
  final bool _isLoading = false;
  String? _error;

  // Getters
  List<FormWidgetModel> get availableWidgets => _getFilteredWidgets();
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// دریافت ویجت‌های فیلتر شده
  List<FormWidgetModel> _getFilteredWidgets() {
    var widgets = _availableWidgets.where((widget) => widget.isActive).toList();

    // فیلتر بر اساس دسته‌بندی
    if (_selectedCategory != 'all') {
      widgets = widgets.where((w) => w.widgetCategory == _selectedCategory).toList();
    }

    // فیلتر بر اساس جستجو
    if (_searchQuery.isNotEmpty) {
      widgets = widgets.where((w) =>
        w.persianLabel.contains(_searchQuery) ||
        (w.englishLabel?.contains(_searchQuery) ?? false) ||
        (w.persianDescription?.contains(_searchQuery) ?? false)
      ).toList();
    }

    // مرتب‌سازی بر اساس displayOrder
    widgets.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    return widgets;
  }

  /// بارگیری ویجت‌های پیش‌فرض
  void loadDefaultWidgets() {
    _availableWidgets = _createDefaultWidgets();
    notifyListeners();
  }

  /// تنظیم دسته‌بندی انتخاب شده
  void setSelectedCategory(String category) {
    _selectedCategory = category;
    LoggerService.info('WidgetLibraryProvider', 'تغییر دسته‌بندی - Category changed', {
      'category': category,
    });
    notifyListeners();
  }

  /// تنظیم متن جستجو
  void setSearchQuery(String query) {
    _searchQuery = query;
    LoggerService.info('WidgetLibraryProvider', 'تغییر جستجو - Search changed', {
      'query': query,
    });
    notifyListeners();
  }

  /// دریافت دسته‌بندی‌های موجود
  List<String> getAvailableCategories() {
    final categories = _availableWidgets
        .where((w) => w.isActive)
        .map((w) => w.widgetCategory)
        .toSet()
        .toList();
    categories.sort();
    return ['all', ...categories];
  }

  /// دریافت نام فارسی دسته‌بندی
  String getCategoryName(String category) {
    switch (category) {
      case 'all':
        return 'همه';
      case 'basic':
        return 'پایه';
      case 'advanced':
        return 'پیشرفته';
      case 'input':
        return 'ورودی';
      case 'selection':
        return 'انتخابی';
      case 'display':
        return 'نمایشی';
      case 'layout':
        return 'چیدمان';
      default:
        return category;
    }
  }

  /// ایجاد ویجت‌های پیش‌فرض
  List<FormWidgetModel> _createDefaultWidgets() {
    return [
      // ویجت‌های پایه
      FormWidgetModel(
        widgetType: 'text_field',
        widgetCode: 'text_field',
        widgetCategory: 'basic',
        persianLabel: 'فیلد متن',
        englishLabel: 'Text Field',
        persianDescription: 'فیلد ورود متن تک‌خطی',
        englishDescription: 'Single line text input field',
        widgetConfig: {
          'input_type': 'text',
          'max_length': 255,
          'placeholder': 'متن خود را وارد کنید...',
        },
        validationRules: {
          'min_length': 0,
          'max_length': 255,
          'required': false,
        },
        defaultProps: {
          'label': 'فیلد متن',
          'placeholder': 'متن خود را وارد کنید...',
          'required': false,
        },
        iconName: 'text_fields',
        iconColor: '#2196F3',
        displayOrder: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),

      FormWidgetModel(
        widgetType: 'textarea',
        widgetCode: 'textarea',
        widgetCategory: 'basic',
        persianLabel: 'متن چندخطی',
        englishLabel: 'Text Area',
        persianDescription: 'فیلد ورود متن چندخطی',
        englishDescription: 'Multi-line text input field',
        widgetConfig: {
          'rows': 4,
          'max_length': 1000,
          'placeholder': 'متن خود را بنویسید...',
        },
        validationRules: {
          'min_length': 0,
          'max_length': 1000,
          'required': false,
        },
        defaultProps: {
          'label': 'متن چندخطی',
          'placeholder': 'متن خود را بنویسید...',
          'rows': 4,
          'required': false,
        },
        iconName: 'text_snippet',
        iconColor: '#4CAF50',
        displayOrder: 2,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),

      FormWidgetModel(
        widgetType: 'email',
        widgetCode: 'email',
        widgetCategory: 'input',
        persianLabel: 'ایمیل',
        englishLabel: 'Email',
        persianDescription: 'فیلد ورود آدرس ایمیل',
        englishDescription: 'Email address input field',
        widgetConfig: {
          'placeholder': 'example@email.com',
          'validation': 'email',
        },
        validationRules: {
          'email_format': true,
          'required': false,
        },
        defaultProps: {
          'label': 'ایمیل',
          'placeholder': 'example@email.com',
          'required': false,
        },
        iconName: 'email',
        iconColor: '#FF9800',
        displayOrder: 3,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),

      FormWidgetModel(
        widgetType: 'phone',
        widgetCode: 'phone',
        widgetCategory: 'input',
        persianLabel: 'شماره تلفن',
        englishLabel: 'Phone',
        persianDescription: 'فیلد ورود شماره تلفن',
        englishDescription: 'Phone number input field',
        widgetConfig: {
          'placeholder': '09123456789',
          'format': 'iranian',
        },
        validationRules: {
          'phone_format': true,
          'required': false,
        },
        defaultProps: {
          'label': 'شماره تلفن',
          'placeholder': '09123456789',
          'required': false,
        },
        iconName: 'phone',
        iconColor: '#9C27B0',
        displayOrder: 4,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),

      FormWidgetModel(
        widgetType: 'number',
        widgetCode: 'number',
        widgetCategory: 'input',
        persianLabel: 'عدد',
        englishLabel: 'Number',
        persianDescription: 'فیلد ورود عدد',
        englishDescription: 'Number input field',
        widgetConfig: {
          'placeholder': 'عدد وارد کنید...',
          'min': 0,
          'max': 999999,
        },
        validationRules: {
          'numeric': true,
          'required': false,
        },
        defaultProps: {
          'label': 'عدد',
          'placeholder': 'عدد وارد کنید...',
          'required': false,
        },
        iconName: 'numbers',
        iconColor: '#607D8B',
        displayOrder: 5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),

      // ویجت‌های انتخابی
      FormWidgetModel(
        widgetType: 'dropdown',
        widgetCode: 'dropdown',
        widgetCategory: 'selection',
        persianLabel: 'لیست کشویی',
        englishLabel: 'Dropdown',
        persianDescription: 'لیست کشویی برای انتخاب یکی از گزینه‌ها',
        englishDescription: 'Dropdown list for single selection',
        widgetConfig: {
          'placeholder': 'انتخاب کنید...',
          'options': [
            {'value': 'option1', 'label': 'گزینه ۱'},
            {'value': 'option2', 'label': 'گزینه ۲'},
            {'value': 'option3', 'label': 'گزینه ۳'},
          ],
        },
        validationRules: {
          'required': false,
        },
        defaultProps: {
          'label': 'لیست کشویی',
          'placeholder': 'انتخاب کنید...',
          'options': [
            {'value': 'option1', 'label': 'گزینه ۱'},
            {'value': 'option2', 'label': 'گزینه ۲'},
            {'value': 'option3', 'label': 'گزینه ۳'},
          ],
          'required': false,
        },
        iconName: 'arrow_drop_down_circle',
        iconColor: '#3F51B5',
        displayOrder: 6,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),

      FormWidgetModel(
        widgetType: 'radio',
        widgetCode: 'radio',
        widgetCategory: 'selection',
        persianLabel: 'رادیو باتن',
        englishLabel: 'Radio Button',
        persianDescription: 'دکمه‌های رادیویی برای انتخاب یکی از گزینه‌ها',
        englishDescription: 'Radio buttons for single selection',
        widgetConfig: {
          'options': [
            {'value': 'option1', 'label': 'گزینه ۱'},
            {'value': 'option2', 'label': 'گزینه ۲'},
            {'value': 'option3', 'label': 'گزینه ۳'},
          ],
        },
        validationRules: {
          'required': false,
        },
        defaultProps: {
          'label': 'رادیو باتن',
          'options': [
            {'value': 'option1', 'label': 'گزینه ۱'},
            {'value': 'option2', 'label': 'گزینه ۲'},
            {'value': 'option3', 'label': 'گزینه ۳'},
          ],
          'required': false,
        },
        iconName: 'radio_button_checked',
        iconColor: '#E91E63',
        displayOrder: 7,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),

      FormWidgetModel(
        widgetType: 'checkbox',
        widgetCode: 'checkbox',
        widgetCategory: 'selection',
        persianLabel: 'چک‌باکس',
        englishLabel: 'Checkbox',
        persianDescription: 'چک‌باکس‌ها برای انتخاب چند گزینه',
        englishDescription: 'Checkboxes for multiple selection',
        widgetConfig: {
          'options': [
            {'value': 'option1', 'label': 'گزینه ۱'},
            {'value': 'option2', 'label': 'گزینه ۲'},
            {'value': 'option3', 'label': 'گزینه ۳'},
          ],
        },
        validationRules: {
          'required': false,
        },
        defaultProps: {
          'label': 'چک‌باکس',
          'options': [
            {'value': 'option1', 'label': 'گزینه ۱'},
            {'value': 'option2', 'label': 'گزینه ۲'},
            {'value': 'option3', 'label': 'گزینه ۳'},
          ],
          'required': false,
        },
        iconName: 'check_box',
        iconColor: '#4CAF50',
        displayOrder: 8,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),

      // ویجت‌های تاریخ و زمان
      FormWidgetModel(
        widgetType: 'date',
        widgetCode: 'date',
        widgetCategory: 'advanced',
        persianLabel: 'تاریخ',
        englishLabel: 'Date',
        persianDescription: 'انتخابگر تاریخ',
        englishDescription: 'Date picker',
        widgetConfig: {
          'placeholder': 'تاریخ انتخاب کنید...',
          'format': 'persian',
          'calendar_type': 'persian',
        },
        validationRules: {
          'date_format': true,
          'required': false,
        },
        defaultProps: {
          'label': 'تاریخ',
          'placeholder': 'تاریخ انتخاب کنید...',
          'required': false,
        },
        iconName: 'calendar_today',
        iconColor: '#795548',
        displayOrder: 9,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),

      FormWidgetModel(
        widgetType: 'time',
        widgetCode: 'time',
        widgetCategory: 'advanced',
        persianLabel: 'زمان',
        englishLabel: 'Time',
        persianDescription: 'انتخابگر زمان',
        englishDescription: 'Time picker',
        widgetConfig: {
          'placeholder': 'زمان انتخاب کنید...',
          'format': '24h',
        },
        validationRules: {
          'time_format': true,
          'required': false,
        },
        defaultProps: {
          'label': 'زمان',
          'placeholder': 'زمان انتخاب کنید...',
          'required': false,
        },
        iconName: 'access_time',
        iconColor: '#FF5722',
        displayOrder: 10,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),

      FormWidgetModel(
        widgetType: 'file',
        widgetCode: 'file',
        widgetCategory: 'advanced',
        persianLabel: 'آپلود فایل',
        englishLabel: 'File Upload',
        persianDescription: 'آپلود فایل',
        englishDescription: 'File upload field',
        widgetConfig: {
          'accept_types': ['image/*', 'application/pdf'],
          'max_size': 5, // MB
          'multiple': false,
        },
        validationRules: {
          'file_size': 5242880, // 5MB in bytes
          'file_types': ['jpg', 'jpeg', 'png', 'pdf'],
          'required': false,
        },
        defaultProps: {
          'label': 'آپلود فایل',
          'placeholder': 'فایل انتخاب کنید...',
          'required': false,
        },
        iconName: 'attach_file',
        iconColor: '#009688',
        displayOrder: 11,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  /// افزایش شمارنده استفاده
  void incrementUsageCount(String widgetType) {
    final widgetIndex = _availableWidgets.indexWhere((w) => w.widgetType == widgetType);
    if (widgetIndex != -1) {
      final widget = _availableWidgets[widgetIndex];
      _availableWidgets[widgetIndex] = widget.copyWith(
        usageCount: widget.usageCount + 1,
        lastUsedAt: DateTime.now(),
      );
      
      LoggerService.info('WidgetLibraryProvider', 'افزایش شمارنده استفاده - Usage count incremented', {
        'widget_type': widgetType,
        'new_count': widget.usageCount + 1,
      });
      
      notifyListeners();
    }
  }

  /// دریافت پرکاربردترین ویجت‌ها
  List<FormWidgetModel> getMostUsedWidgets({int limit = 5}) {
    final widgets = List<FormWidgetModel>.from(_availableWidgets);
    widgets.sort((a, b) => b.usageCount.compareTo(a.usageCount));
    return widgets.take(limit).toList();
  }

  /// دریافت آخرین ویجت‌های استفاده شده
  List<FormWidgetModel> getRecentlyUsedWidgets({int limit = 5}) {
    final widgets = _availableWidgets
        .where((w) => w.lastUsedAt != null)
        .toList();
    widgets.sort((a, b) => b.lastUsedAt!.compareTo(a.lastUsedAt!));
    return widgets.take(limit).toList();
  }

  /// پاک کردن جستجو
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  /// بازنشانی فیلترها
  void resetFilters() {
    _selectedCategory = 'all';
    _searchQuery = '';
    LoggerService.info('WidgetLibraryProvider', 'بازنشانی فیلترها - Filters reset');
    notifyListeners();
  }
}
