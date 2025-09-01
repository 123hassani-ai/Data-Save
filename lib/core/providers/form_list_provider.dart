import 'package:flutter/material.dart';
import '../services/form_api_service.dart';
import '../logger/logger_service.dart';

/// Provider لیست فرم‌ها - Form List Provider
/// مدیریت لیست فرم‌های کاربر و عملیات مرتبط
class FormListProvider with ChangeNotifier {
  // لیست فرم‌های کاربر - User forms list
  List<Map<String, dynamic>> _forms = [];
  Map<String, dynamic> _pagination = {};
  
  // وضعیت‌های UI - UI states
  bool _isLoading = false;
  String? _errorMessage;
  
  // فیلترها و جستجو - Filters and search
  int _currentPage = 1;
  int _perPage = 10;
  String _statusFilter = 'all';
  String _searchQuery = '';
  
  // کاربر فعلی - Current user
  int? _currentUserId;

  // Getters
  List<Map<String, dynamic>> get forms => _forms;
  Map<String, dynamic> get pagination => _pagination;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get perPage => _perPage;
  String get statusFilter => _statusFilter;
  String get searchQuery => _searchQuery;
  int? get currentUserId => _currentUserId;
  
  // محاسبه‌شده - Computed
  int get totalForms => _pagination['total_count'] ?? 0;
  int get totalPages => _pagination['total_pages'] ?? 1;
  bool get hasNextPage => _pagination['has_next'] ?? false;
  bool get hasPrevPage => _pagination['has_prev'] ?? false;

  /// تنظیم کاربر فعلی
  /// Set current user
  void setCurrentUser(int userId) {
    if (_currentUserId != userId) {
      _currentUserId = userId;
      _forms.clear();
      _pagination.clear();
      _currentPage = 1;
      _statusFilter = 'all';
      _searchQuery = '';
      notifyListeners();
      
      LoggerService.info('FormListProvider', 'کاربر فعلی تنظیم شد - Current user set', {
        'user_id': userId,
      });
    }
  }

  /// بارگذاری فرم‌های کاربر
  /// Load user forms
  Future<void> loadForms({bool showLoading = true}) async {
    if (_currentUserId == null) {
      _setError('شناسه کاربر مشخص نیست');
      return;
    }

    if (showLoading) _setLoading(true);
    _setError(null);

    try {
      LoggerService.info('FormListProvider', 'شروع بارگذاری فرم‌های کاربر - Starting user forms loading', {
        'user_id': _currentUserId,
        'page': _currentPage,
        'status_filter': _statusFilter,
        'search': _searchQuery,
      });

      final result = await FormApiService.getUserForms(
        userId: _currentUserId!,
        page: _currentPage,
        perPage: _perPage,
        status: _statusFilter,
        search: _searchQuery,
      );

      if (result['success'] == true) {
        final data = result['data'];
        _forms = List<Map<String, dynamic>>.from(data['forms'] ?? []);
        _pagination = Map<String, dynamic>.from(data['pagination'] ?? {});

        LoggerService.info('FormListProvider', 'فرم‌های کاربر بارگذاری شد - User forms loaded', {
          'forms_count': _forms.length,
          'total_count': totalForms,
          'current_page': _currentPage,
        });
      } else {
        _setError(result['message'] ?? 'خطا در بارگذاری فرم‌ها');
        LoggerService.warning('FormListProvider', 'خطا در بارگذاری فرم‌ها', {
          'error': result['message'],
        });
      }
    } catch (e) {
      _setError('خطای ارتباط با سرور');
      LoggerService.error('FormListProvider', 'خطای سیستمی در بارگذاری فرم‌ها', e);
    } finally {
      if (showLoading) _setLoading(false);
    }
  }

  /// رفتن به صفحه مشخص
  /// Go to specific page
  Future<void> goToPage(int page) async {
    if (page == _currentPage || page < 1 || page > totalPages) return;
    
    _currentPage = page;
    notifyListeners();
    
    await loadForms();
  }

  /// صفحه بعدی
  /// Next page
  Future<void> nextPage() async {
    if (hasNextPage) {
      await goToPage(_currentPage + 1);
    }
  }

  /// صفحه قبلی
  /// Previous page
  Future<void> previousPage() async {
    if (hasPrevPage) {
      await goToPage(_currentPage - 1);
    }
  }

  /// تغییر تعداد فرم در هر صفحه
  /// Change forms per page
  Future<void> changePerPage(int newPerPage) async {
    if (newPerPage == _perPage) return;
    
    _perPage = newPerPage;
    _currentPage = 1; // بازگشت به صفحه اول
    notifyListeners();
    
    await loadForms();
  }

  /// تغییر فیلتر وضعیت
  /// Change status filter
  Future<void> changeStatusFilter(String status) async {
    if (status == _statusFilter) return;
    
    _statusFilter = status;
    _currentPage = 1; // بازگشت به صفحه اول
    notifyListeners();
    
    await loadForms();
  }

  /// جستجو در فرم‌ها
  /// Search forms
  Future<void> searchForms(String query) async {
    if (query == _searchQuery) return;
    
    _searchQuery = query;
    _currentPage = 1; // بازگشت به صفحه اول
    notifyListeners();
    
    await loadForms();
  }

  /// پاک کردن جستجو
  /// Clear search
  Future<void> clearSearch() async {
    if (_searchQuery.isEmpty) return;
    
    _searchQuery = '';
    _currentPage = 1;
    notifyListeners();
    
    await loadForms();
  }

  /// حذف فرم
  /// Delete form
  Future<bool> deleteForm(int formId) async {
    if (_currentUserId == null) return false;
    
    try {
      LoggerService.info('FormListProvider', 'شروع حذف فرم - Starting form deletion', {
        'form_id': formId,
        'user_id': _currentUserId,
      });

      final result = await FormApiService.deleteForm(
        formId: formId,
        userId: _currentUserId!,
      );

      if (result['success'] == true) {
        // حذف فرم از لیست محلی
        _forms.removeWhere((form) => form['id'] == formId);
        
        // اگر صفحه فعلی خالی شد، به صفحه قبل برو
        if (_forms.isEmpty && _currentPage > 1) {
          _currentPage--;
        }
        
        notifyListeners();
        
        // بارگذاری مجدد برای اطمینان از sync
        await loadForms(showLoading: false);

        LoggerService.info('FormListProvider', 'فرم با موفقیت حذف شد - Form deleted successfully', {
          'form_id': formId,
        });
        
        return true;
      } else {
        LoggerService.warning('FormListProvider', 'خطا در حذف فرم', {
          'error': result['message'],
          'form_id': formId,
        });
        return false;
      }
    } catch (e) {
      LoggerService.error('FormListProvider', 'خطای سیستمی در حذف فرم', e);
      return false;
    }
  }

  /// کپی کردن فرم
  /// Duplicate form
  Future<bool> duplicateForm(Map<String, dynamic> originalForm) async {
    if (_currentUserId == null) return false;
    
    try {
      LoggerService.info('FormListProvider', 'شروع کپی فرم - Starting form duplication', {
        'original_form_id': originalForm['id'],
        'user_id': _currentUserId,
      });

      final result = await FormApiService.createForm(
        userId: _currentUserId!,
        persianTitle: 'کپی از ${originalForm['persian_title']}',
        englishTitle: originalForm['english_title'] != null 
          ? 'Copy of ${originalForm['english_title']}' 
          : null,
        persianDescription: originalForm['persian_description'],
        englishDescription: originalForm['english_description'],
        formSchema: originalForm['form_schema'],
        formConfig: originalForm['form_config'],
        formSettings: originalForm['form_settings'],
        status: 'draft', // فرم کپی شده همیشه draft
      );

      if (result['success'] == true) {
        // بارگذاری مجدد فرم‌ها برای نمایش فرم جدید
        await loadForms(showLoading: false);

        LoggerService.info('FormListProvider', 'فرم با موفقیت کپی شد - Form duplicated successfully', {
          'new_form_id': result['data']?['form_id'],
          'original_form_id': originalForm['id'],
        });
        
        return true;
      } else {
        LoggerService.warning('FormListProvider', 'خطا در کپی فرم', {
          'error': result['message'],
          'original_form_id': originalForm['id'],
        });
        return false;
      }
    } catch (e) {
      LoggerService.error('FormListProvider', 'خطای سیستمی در کپی فرم', e);
      return false;
    }
  }

  /// دریافت فرم بر اساس ID
  /// Get form by ID
  Map<String, dynamic>? getFormById(int formId) {
    try {
      return _forms.firstWhere((form) => form['id'] == formId);
    } catch (e) {
      return null;
    }
  }

  /// فیلتر فرم‌ها بر اساس وضعیت
  /// Filter forms by status
  List<Map<String, dynamic>> getFormsByStatus(String status) {
    if (status == 'all') return _forms;
    return _forms.where((form) => form['status'] == status).toList();
  }

  /// آمار فرم‌ها
  /// Forms statistics
  Map<String, int> getFormStats() {
    final stats = <String, int>{
      'total': _forms.length,
      'draft': 0,
      'published': 0,
      'archived': 0,
    };

    for (final form in _forms) {
      final status = form['status'] ?? 'draft';
      if (stats.containsKey(status)) {
        stats[status] = stats[status]! + 1;
      }
    }

    return stats;
  }

  /// تازه‌سازی فرم‌ها
  /// Refresh forms
  Future<void> refresh() async {
    LoggerService.info('FormListProvider', 'تازه‌سازی لیست فرم‌ها - Refreshing forms list');
    await loadForms();
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

  /// پاک کردن خطا
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// بازنشانی
  void reset() {
    _forms.clear();
    _pagination.clear();
    _currentPage = 1;
    _perPage = 10;
    _statusFilter = 'all';
    _searchQuery = '';
    _isLoading = false;
    _errorMessage = null;
    _currentUserId = null;
    notifyListeners();
    
    LoggerService.info('FormListProvider', 'وضعیت‌های provider بازنشانی شد - Provider states reset');
  }
}
