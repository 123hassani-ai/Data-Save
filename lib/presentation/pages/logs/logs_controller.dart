import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../core/logger/logger_service.dart';

/// کنترلر لاگ‌ها - برای مدیریت وضعیت لاگ‌ها و آنالیتیک
/// Logs controller for managing logs state and analytics
class LogsController extends ChangeNotifier {
  // وضعیت‌های لاگ - Logs states
  List<Map<String, dynamic>> _logs = [];
  Map<String, dynamic> _analytics = {};
  bool _isLoading = false;
  bool _isLoadingAnalytics = false;
  String? _error;
  String? _successMessage;
  
  // فیلترها و جستجو - Filters and search
  String _selectedFilter = 'ALL';
  String _searchQuery = '';
  int _currentPage = 1;
  int _totalPages = 1;
  final int _itemsPerPage = 20;

  // Getters
  List<Map<String, dynamic>> get logs => _logs;
  List<Map<String, dynamic>> get filteredLogs => _filterLogs();
  Map<String, dynamic> get analytics => _analytics;
  bool get isLoading => _isLoading;
  bool get isLoadingAnalytics => _isLoadingAnalytics;
  String? get error => _error;
  String? get successMessage => _successMessage;
  String get selectedFilter => _selectedFilter;
  String get searchQuery => _searchQuery;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;

  // Analytics getters - دسترسی آسان به آمار
  int get totalLogsCount => _analytics['total_logs'] ?? 0;
  int get errorLogsCount => _analytics['error_count'] ?? 0;
  int get warningLogsCount => _analytics['warning_count'] ?? 0;
  int get infoLogsCount => _analytics['info_count'] ?? 0;
  int get debugLogsCount => _analytics['debug_count'] ?? 0;
  int get todayLogsCount => _analytics['today_logs'] ?? 0;
  Map<String, int> get categoryCounts => Map<String, int>.from(_analytics['categories'] ?? {});

  /// بارگذاری لاگ‌ها - Load logs from server
  Future<void> loadLogs({int limit = 50}) async {
    _setLoading(true);
    _clearMessages();

    try {
      LoggerService.info('LogsController', 'شروع بارگذاری لاگ‌ها - Starting to load logs');

      final logs = await ApiService.getLogs(limit: limit);
      _logs = logs;
      _calculatePagination();

      LoggerService.info('LogsController', 
          'لاگ‌ها بارگذاری شد - Logs loaded: ${logs.length} items');

      notifyListeners();
    } catch (e) {
      _error = 'خطا در بارگذاری لاگ‌ها - Error loading logs: $e';
      LoggerService.error('LogsController', 'خطا در بارگذاری لاگ‌ها', e);
    } finally {
      _setLoading(false);
    }
  }

  /// بارگذاری آنالیتیک لاگ‌ها - Load log analytics
  Future<void> loadAnalytics() async {
    _isLoadingAnalytics = true;
    notifyListeners();

    try {
      LoggerService.info('LogsController', 'شروع بارگذاری آنالیتیک - Starting to load analytics');

      final analytics = await ApiService.getLogAnalytics();
      _analytics = analytics;

      LoggerService.info('LogsController', 'آنالیتیک بارگذاری شد - Analytics loaded');

      notifyListeners();
    } catch (e) {
      _error = 'خطا در بارگذاری آنالیتیک - Error loading analytics: $e';
      LoggerService.error('LogsController', 'خطا در بارگذاری آنالیتیک', e);
      notifyListeners();
    } finally {
      _isLoadingAnalytics = false;
      notifyListeners();
    }
  }

  /// تنظیم فیلتر - Set filter
  void setFilter(String filter) {
    _selectedFilter = filter;
    _currentPage = 1; // Reset to first page
    LoggerService.info('LogsController', 'فیلتر تنظیم شد - Filter set to: $filter');
    notifyListeners();
  }

  /// تنظیم کوئری جستجو - Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    _currentPage = 1; // Reset to first page
    LoggerService.info('LogsController', 'کوئری جستجو تنظیم شد - Search query set to: $query');
    notifyListeners();
  }

  /// پاکسازی لاگ‌های قدیمی - Clear old logs
  Future<bool> clearOldLogs({int keepCount = 100}) async {
    _clearMessages();

    try {
      LoggerService.info('LogsController', 
          'شروع پاکسازی لاگ‌های قدیمی - Starting to clear old logs (keep: $keepCount)');

      final success = await ApiService.clearOldLogs(keepCount: keepCount);

      if (success) {
        _successMessage = 'لاگ‌های قدیمی پاکسازی شد - Old logs cleared successfully';
        LoggerService.info('LogsController', 'لاگ‌های قدیمی پاکسازی شد - Old logs cleared');
        
        // بارگذاری مجدد لاگ‌ها و آنالیتیک - Reload logs and analytics
        await loadLogs();
        await loadAnalytics();
      } else {
        _error = 'خطا در پاکسازی لاگ‌ها - Error clearing logs';
        LoggerService.error('LogsController', 'خطا در پاکسازی لاگ‌ها', 'Clear operation failed');
      }

      notifyListeners();
      return success;
    } catch (e) {
      _error = 'خطا در پاکسازی لاگ‌ها - Error clearing logs: $e';
      LoggerService.error('LogsController', 'خطا در پاکسازی لاگ‌ها', e);
      notifyListeners();
      return false;
    }
  }

  /// رفرش کامل داده‌ها - Full refresh of data
  Future<void> refreshAll() async {
    LoggerService.info('LogsController', 'شروع رفرش کامل - Starting full refresh');
    
    await Future.wait([
      loadLogs(),
      loadAnalytics(),
    ]);
    
    LoggerService.info('LogsController', 'رفرش کامل تمام شد - Full refresh completed');
  }

  /// تغییر صفحه - Change page
  void changePage(int page) {
    if (page >= 1 && page <= _totalPages) {
      _currentPage = page;
      LoggerService.info('LogsController', 'صفحه تغییر کرد - Page changed to: $page');
      notifyListeners();
    }
  }

  /// صفحه بعدی - Next page
  void nextPage() {
    if (_currentPage < _totalPages) {
      changePage(_currentPage + 1);
    }
  }

  /// صفحه قبلی - Previous page
  void previousPage() {
    if (_currentPage > 1) {
      changePage(_currentPage - 1);
    }
  }

  /// فیلتر کردن لاگ‌ها - Filter logs based on current filters
  List<Map<String, dynamic>> _filterLogs() {
    List<Map<String, dynamic>> filtered = List.from(_logs);

    // فیلتر بر اساس سطح - Filter by level
    if (_selectedFilter != 'ALL') {
      filtered = filtered.where((log) {
        final level = log['log_level']?.toString().toUpperCase() ?? 'INFO';
        return level == _selectedFilter.toUpperCase();
      }).toList();
    }

    // فیلتر بر اساس جستجو - Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((log) {
        final message = log['log_message']?.toString().toLowerCase() ?? '';
        final category = log['log_category']?.toString().toLowerCase() ?? '';
        return message.contains(query) || category.contains(query);
      }).toList();
    }

    // صفحه‌بندی - Pagination
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, filtered.length);
    
    if (startIndex >= filtered.length) {
      return [];
    }
    
    return filtered.sublist(startIndex, endIndex);
  }

  /// محاسبه صفحه‌بندی - Calculate pagination
  void _calculatePagination() {
    final totalItems = filteredLogs.length;
    _totalPages = (totalItems / _itemsPerPage).ceil().clamp(1, double.infinity).toInt();
    
    if (_currentPage > _totalPages) {
      _currentPage = _totalPages;
    }
  }

  /// پاکسازی پیام‌ها - Clear messages
  void clearMessages() {
    _clearMessages();
    notifyListeners();
  }

  /// تولید فایل صادراتی لاگ‌ها - Generate logs export file
  Map<String, dynamic> exportLogs() {
    LoggerService.info('LogsController', 'صادرات لاگ‌ها - Exporting logs');

    return {
      'export_date': DateTime.now().toIso8601String(),
      'logs': List.from(_logs),
      'analytics': Map.from(_analytics),
      'filters': {
        'selected_filter': _selectedFilter,
        'search_query': _searchQuery,
      },
      'version': '1.0.0',
    };
  }

  /// دریافت لاگ‌های یک دسته خاص - Get logs by specific category
  List<Map<String, dynamic>> getLogsByCategory(String category) {
    return _logs.where((log) {
      final logCategory = log['log_category']?.toString() ?? '';
      return logCategory.toLowerCase() == category.toLowerCase();
    }).toList();
  }

  /// دریافت لاگ‌های یک سطح خاص - Get logs by specific level
  List<Map<String, dynamic>> getLogsByLevel(String level) {
    return _logs.where((log) {
      final logLevel = log['log_level']?.toString().toUpperCase() ?? '';
      return logLevel == level.toUpperCase();
    }).toList();
  }

  /// دریافت لاگ‌های امروز - Get today's logs
  List<Map<String, dynamic>> getTodayLogs() {
    final today = DateTime.now();
    return _logs.where((log) {
      try {
        final logDate = DateTime.parse(log['created_at']);
        return logDate.year == today.year &&
               logDate.month == today.month &&
               logDate.day == today.day;
      } catch (e) {
        return false;
      }
    }).toList();
  }

  /// جستجوی سریع - Quick search
  Future<List<Map<String, dynamic>>> quickSearch(String query) async {
    LoggerService.info('LogsController', 'جستجوی سریع - Quick search: $query');
    
    if (query.isEmpty) return [];
    
    final searchQuery = query.toLowerCase();
    return _logs.where((log) {
      final message = log['log_message']?.toString().toLowerCase() ?? '';
      final category = log['log_category']?.toString().toLowerCase() ?? '';
      return message.contains(searchQuery) || category.contains(searchQuery);
    }).take(10).toList(); // محدود به 10 نتیجه اول
  }

  /// متدهای کمکی خصوصی - Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) {
      _error = null;
      _successMessage = null;
    }
  }

  void _clearMessages() {
    _error = null;
    _successMessage = null;
  }

  /// دریافت آمار روزانه - Get daily statistics
  Map<String, int> getDailyStats() {
    final Map<String, int> dailyStats = {};
    
    for (final log in _logs) {
      try {
        final logDate = DateTime.parse(log['created_at']);
        final dateKey = '${logDate.year}-${logDate.month.toString().padLeft(2, '0')}-${logDate.day.toString().padLeft(2, '0')}';
        dailyStats[dateKey] = (dailyStats[dateKey] ?? 0) + 1;
      } catch (e) {
        // Skip invalid dates
      }
    }
    
    return dailyStats;
  }
}
