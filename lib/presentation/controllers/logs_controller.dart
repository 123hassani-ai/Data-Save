import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../core/logger/logger_service.dart';

/// کنترلر مدیریت لاگ‌ها - Logs management controller
class LogsController with ChangeNotifier {
  // لیست لاگ‌ها
  List<Map<String, dynamic>> _logs = [];
  List<Map<String, dynamic>> _filteredLogs = [];
  
  // آمار لاگ‌ها
  final Map<String, int> _logStats = {};
  
  // فیلترها و جستجو
  String _searchQuery = '';
  String _selectedLevel = 'ALL';
  String _selectedCategory = 'ALL';
  DateTime? _startDate;
  DateTime? _endDate;
  
  // pagination
  int _currentPage = 1;
  final int _itemsPerPage = 50;
  int _totalPages = 1;
  
  // وضعیت‌های لودینگ
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isClearing = false;
  
  // لیست سطح‌های لاگ
  final List<String> logLevels = ['ALL', 'INFO', 'WARNING', 'ERROR', 'DEBUG'];
  
  // لیست دسته‌بندی‌های لاگ
  List<String> _categories = ['ALL'];

  // Getters
  List<Map<String, dynamic>> get logs => _filteredLogs;
  Map<String, int> get logStats => _logStats;
  String get searchQuery => _searchQuery;
  String get selectedLevel => _selectedLevel;
  String get selectedCategory => _selectedCategory;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  int get currentPage => _currentPage;
  int get itemsPerPage => _itemsPerPage;
  int get totalPages => _totalPages;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isClearing => _isClearing;
  List<String> get categories => _categories;

  /// بارگذاری لاگ‌ها از سرور - Load logs from server
  Future<void> loadLogs({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _logs.clear();
      _filteredLogs.clear();
    }
    
    _isLoading = refresh;
    _isLoadingMore = !refresh;
    notifyListeners();
    
    try {
      LoggerService.info('LogsController', 'شروع بارگذاری لاگ‌ها - Loading logs page $_currentPage');
      
      final newLogs = await ApiService.getLogs(limit: _itemsPerPage);
      
      if (refresh) {
        _logs = newLogs;
      } else {
        _logs.addAll(newLogs);
      }
      
      _updateCategories();
      _applyFilters();
      _updateStats();
      
      LoggerService.info('LogsController', 'لاگ‌ها بارگذاری شد: ${newLogs.length} آیتم - Loaded ${newLogs.length} logs');
    } catch (e) {
      LoggerService.error('LogsController', 'خطا در بارگذاری لاگ‌ها', e);
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// بارگذاری صفحه بعدی - Load next page
  Future<void> loadMoreLogs() async {
    if (_isLoadingMore) return;
    
    _currentPage++;
    await loadLogs();
  }

  /// اعمال فیلترها - Apply filters
  void _applyFilters() {
    _filteredLogs = _logs.where((log) {
      // فیلتر جستجو
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final message = (log['log_message'] ?? '').toString().toLowerCase();
        final category = (log['log_category'] ?? '').toString().toLowerCase();
        
        if (!message.contains(query) && !category.contains(query)) {
          return false;
        }
      }
      
      // فیلتر سطح لاگ
      if (_selectedLevel != 'ALL') {
        if ((log['log_level'] ?? '').toString().toUpperCase() != _selectedLevel) {
          return false;
        }
      }
      
      // فیلتر دسته‌بندی
      if (_selectedCategory != 'ALL') {
        if ((log['log_category'] ?? '').toString() != _selectedCategory) {
          return false;
        }
      }
      
      // فیلتر تاریخ
      if (_startDate != null || _endDate != null) {
        try {
          final logDate = DateTime.parse(log['created_at']);
          
          if (_startDate != null && logDate.isBefore(_startDate!)) {
            return false;
          }
          
          if (_endDate != null && logDate.isAfter(_endDate!.add(const Duration(days: 1)))) {
            return false;
          }
        } catch (e) {
          return false;
        }
      }
      
      return true;
    }).toList();
    
    _calculatePagination();
  }

  /// محاسبه pagination - Calculate pagination
  void _calculatePagination() {
    _totalPages = (_filteredLogs.length / _itemsPerPage).ceil();
    if (_totalPages == 0) _totalPages = 1;
  }

  /// بروزرسانی دسته‌بندی‌ها - Update categories
  void _updateCategories() {
    final categorySet = <String>{'ALL'};
    
    for (final log in _logs) {
      final category = log['log_category']?.toString();
      if (category != null && category.isNotEmpty) {
        categorySet.add(category);
      }
    }
    
    _categories = categorySet.toList()..sort();
  }

  /// بروزرسانی آمار - Update statistics
  void _updateStats() {
    _logStats.clear();
    
    for (final log in _logs) {
      final level = (log['log_level'] ?? 'UNKNOWN').toString().toUpperCase();
      _logStats[level] = (_logStats[level] ?? 0) + 1;
    }
  }

  /// تنظیم جستجو - Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  /// تنظیم فیلتر سطح - Set level filter
  void setLevelFilter(String level) {
    _selectedLevel = level;
    _applyFilters();
    notifyListeners();
  }

  /// تنظیم فیلتر دسته‌بندی - Set category filter
  void setCategoryFilter(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  /// تنظیم فیلتر تاریخ شروع - Set start date filter
  void setStartDate(DateTime? date) {
    _startDate = date;
    _applyFilters();
    notifyListeners();
  }

  /// تنظیم فیلتر تاریخ پایان - Set end date filter
  void setEndDate(DateTime? date) {
    _endDate = date;
    _applyFilters();
    notifyListeners();
  }

  /// پاک کردن همه فیلترها - Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _selectedLevel = 'ALL';
    _selectedCategory = 'ALL';
    _startDate = null;
    _endDate = null;
    _applyFilters();
    notifyListeners();
  }

  /// پاکسازی لاگ‌های قدیمی - Clear old logs
  Future<bool> clearOldLogs() async {
    _isClearing = true;
    notifyListeners();
    
    try {
      LoggerService.info('LogsController', 'شروع پاکسازی لاگ‌های قدیمی - Clearing old logs');
      
      final success = await ApiService.clearOldLogs();
      
      if (success) {
        await loadLogs(refresh: true);
        LoggerService.info('LogsController', 'لاگ‌های قدیمی پاکسازی شد - Old logs cleared');
      }
      
      return success;
    } catch (e) {
      LoggerService.error('LogsController', 'خطا در پاکسازی لاگ‌ها', e);
      return false;
    } finally {
      _isClearing = false;
      notifyListeners();
    }
  }

  /// دریافت آمار تفصیلی - Get detailed analytics
  Map<String, dynamic> getAnalytics() {
    final total = _logs.length;
    final today = DateTime.now();
    final todayLogs = _logs.where((log) {
      try {
        final logDate = DateTime.parse(log['created_at']);
        return logDate.year == today.year &&
               logDate.month == today.month &&
               logDate.day == today.day;
      } catch (e) {
        return false;
      }
    }).length;
    
    final thisWeekLogs = _logs.where((log) {
      try {
        final logDate = DateTime.parse(log['created_at']);
        final weekAgo = today.subtract(const Duration(days: 7));
        return logDate.isAfter(weekAgo);
      } catch (e) {
        return false;
      }
    }).length;
    
    return {
      'total': total,
      'today': todayLogs,
      'thisWeek': thisWeekLogs,
      'byLevel': Map.from(_logStats),
      'categories': _categories.length - 1, // -1 برای حذف ALL
    };
  }

  /// صادر کردن لاگ‌ها - Export logs
  String exportLogs({String format = 'csv'}) {
    if (format == 'csv') {
      final buffer = StringBuffer();
      buffer.writeln('تاریخ,سطح,دسته‌بندی,پیام');
      
      for (final log in _filteredLogs) {
        final date = log['created_at'] ?? '';
        final level = log['log_level'] ?? '';
        final category = log['log_category'] ?? '';
        final message = (log['log_message'] ?? '').toString().replaceAll(',', ';');
        
        buffer.writeln('$date,$level,$category,$message');
      }
      
      return buffer.toString();
    }
    
    return '';
  }
}
