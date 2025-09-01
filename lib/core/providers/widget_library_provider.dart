import 'package:flutter/material.dart';
import '../services/widget_api_service.dart';
import '../logger/logger_service.dart';

/// Provider کتابخانه ویجت‌ها - Widget Library Provider
/// مدیریت state کتابخانه ویجت‌های فرم‌ساز
class WidgetLibraryProvider with ChangeNotifier {
  // وضعیت‌های کتابخانه ویجت - Widget library states
  List<Map<String, dynamic>> _widgets = [];
  Map<String, List<Map<String, dynamic>>> _categorizedWidgets = {};
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // فیلترها و تنظیمات - Filters and settings
  String _selectedCategory = 'all';
  String _sortBy = 'display_order';
  bool _activeOnly = true;
  String _searchQuery = '';

  // Getters
  List<Map<String, dynamic>> get widgets => _widgets;
  Map<String, List<Map<String, dynamic>>> get categorizedWidgets => _categorizedWidgets;
  List<Map<String, dynamic>> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  String get sortBy => _sortBy;
  bool get activeOnly => _activeOnly;
  String get searchQuery => _searchQuery;

  // فیلترشده و جستجو شده widgets
  List<Map<String, dynamic>> get filteredWidgets {
    var result = List<Map<String, dynamic>>.from(_widgets);

    // فیلتر بر اساس جستجو
    if (_searchQuery.isNotEmpty) {
      result = result.where((widget) {
        final persianLabel = (widget['persian_label'] ?? '').toString().toLowerCase();
        final englishLabel = (widget['english_label'] ?? '').toString().toLowerCase();
        final query = _searchQuery.toLowerCase();
        return persianLabel.contains(query) || englishLabel.contains(query);
      }).toList();
    }

    // فیلتر بر اساس دسته‌بندی
    if (_selectedCategory.isNotEmpty && _selectedCategory != 'all') {
      result = result.where((widget) {
        return widget['category_key'] == _selectedCategory;
      }).toList();
    }

    return result;
  }

  /// بارگذاری اولیه کتابخانه ویجت‌ها
  /// Initial loading of widget library
  Future<void> loadWidgetLibrary() async {
    if (_isLoading) return;
    
    _setLoading(true);
    _setError(null);

    try {
      LoggerService.info('WidgetLibraryProvider', 'شروع بارگذاری کتابخانه ویجت‌ها - Starting widget library loading');

      final result = await WidgetApiService.getWidgetLibrary(
        category: _selectedCategory,
        activeOnly: _activeOnly,
        sortBy: _sortBy,
        limit: 100,
      );

      if (result['success'] == true) {
        final data = result['data'];
        _widgets = List<Map<String, dynamic>>.from(data['widgets'] ?? []);
        _categorizedWidgets = Map<String, List<Map<String, dynamic>>>.from(
          (data['categorized_widgets'] as Map<String, dynamic>? ?? {}).map(
            (key, value) => MapEntry(key, List<Map<String, dynamic>>.from(value)),
          ),
        );
        
        // Convert categories from List<String> to List<Map<String, dynamic>>
        final categoriesList = data['categories'] as List<dynamic>? ?? [];
        _categories = categoriesList.map<Map<String, dynamic>>((category) {
          if (category is String) {
            return {
              'name': category,
              'label': category == 'basic' ? 'پایه' : category == 'advanced' ? 'پیشرفته' : category,
              'count': _categorizedWidgets[category]?.length ?? 0,
            };
          } else if (category is Map<String, dynamic>) {
            return category;
          } else {
            return {
              'name': category.toString(),
              'label': category.toString(),
              'count': 0,
            };
          }
        }).toList();

        LoggerService.info('WidgetLibraryProvider', 'کتابخانه ویجت‌ها با موفقیت بارگذاری شد - Widget library loaded successfully', {
          'total_widgets': _widgets.length,
          'categories_count': _categories.length,
        });
      } else {
        _setError(result['message'] ?? 'خطا در بارگذاری کتابخانه ویجت‌ها');
        LoggerService.warning('WidgetLibraryProvider', 'خطا در بارگذاری کتابخانه ویجت‌ها', {
          'error': result['message'],
        });
      }
    } catch (e) {
      _setError('خطای ارتباط با سرور');
      LoggerService.error('WidgetLibraryProvider', 'خطای سیستمی در بارگذاری کتابخانه ویجت‌ها', e);
    } finally {
      _setLoading(false);
    }
  }

  /// تغییر دسته‌بندی انتخاب شده
  /// Change selected category
  Future<void> changeCategory(String category) async {
    if (_selectedCategory == category) return;
    
    _selectedCategory = category;
    notifyListeners();
    
    await loadWidgetLibrary();
  }

  /// تنظیم دسته‌بندی (alias for changeCategory for compatibility)
  WidgetLibraryProvider setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
    return this;
  }

  /// تغییر نحوه مرتب‌سازی
  /// Change sort method
  Future<void> changeSortBy(String sortBy) async {
    if (_sortBy == sortBy) return;
    
    _sortBy = sortBy;
    notifyListeners();
    
    await loadWidgetLibrary();
  }

  /// تغییر فیلتر فعال/غیرفعال
  /// Change active filter
  Future<void> changeActiveOnly(bool activeOnly) async {
    if (_activeOnly == activeOnly) return;
    
    _activeOnly = activeOnly;
    notifyListeners();
    
    await loadWidgetLibrary();
  }

  /// جستجو در ویجت‌ها
  /// Search widgets  
  Future<void> searchWidgets(String query) async {
    _searchQuery = query.trim();
    notifyListeners();
    
    // اگر کوئری خالی باشد، همه را نمایش بده
    if (_searchQuery.isEmpty) {
      await loadWidgetLibrary();
      return;
    }

    // بدون درخواست جدید API جستجو کن
    notifyListeners();
  }

  /// فیلتر بر اساس دسته‌بندی (بدون API call)
  void filterByCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// دریافت ویجت‌های یک دسته (متد جایگزین)
  List<Map<String, dynamic>> getWidgetsByCategory(String categoryKey) {
    if (categoryKey.isEmpty || categoryKey == 'all') {
      return _widgets;
    }
    return _widgets.where((widget) {
      return widget['category_key'] == categoryKey;
    }).toList();
  }  /// پاک کردن جستجو
  /// Clear search
  Future<void> clearSearch() async {
    if (_searchQuery.isEmpty) return;
    
    _searchQuery = '';
    notifyListeners();
    
    await loadWidgetLibrary();
  }

  /// دریافت ویجت بر اساس نوع
  /// Get widget by type
  Map<String, dynamic>? getWidgetByType(String widgetType) {
    try {
      return _widgets.firstWhere(
        (widget) => widget['widget_type'] == widgetType,
      );
    } catch (e) {
      return null;
    }
  }


  /// دریافت تنظیمات پیش‌فرض ویجت
  /// Get widget default config
  Map<String, dynamic> getWidgetDefaultConfig(String widgetType) {
    final widget = getWidgetByType(widgetType);
    if (widget != null && widget['widget_config'] != null) {
      return Map<String, dynamic>.from(widget['widget_config']);
    }
    
    return WidgetApiService.getDefaultWidgetConfig(widgetType);
  }

  /// تنظیم وضعیت بارگذاری
  /// Set loading state
  void _setLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  /// تنظیم پیام خطا
  /// Set error message
  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// بازنشانی وضعیت‌ها
  /// Reset states
  void reset() {
    _widgets.clear();
    _categorizedWidgets.clear();
    _categories.clear();
    _selectedCategory = 'all';
    _sortBy = 'display_order';
    _activeOnly = true;
    _searchQuery = '';
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
    
    LoggerService.info('WidgetLibraryProvider', 'وضعیت‌های provider بازنشانی شد - Provider states reset');
  }

  /// تازه‌سازی کتابخانه
  /// Refresh library
  Future<void> refresh() async {
    LoggerService.info('WidgetLibraryProvider', 'تازه‌سازی کتابخانه ویجت‌ها - Refreshing widget library');
    await loadWidgetLibrary();
  }
}
