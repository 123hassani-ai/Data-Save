import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

/// سیستم لاگینگ ساده با ارسال به Backend PHP
class LoggerService {
  /// Logger اصلی برای DataSave
  static final Logger _logger = Logger('DataSave');
  
  /// وضعیت راه‌اندازی سیستم لاگ
  static bool _initialized = false;
  
  /// لیست لاگ‌های محلی برای نمایش در UI
  static final List<LogEntry> _localLogs = [];
  
  /// حداکثر تعداد لاگ‌های محلی که نگهداری می‌شود
  static const int _maxLocalLogs = 50;

  /// راه‌اندازی سیستم Logger
  static void initialize() {
    if (_initialized) return;
    
    // تنظیمات سطح لاگ
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen(_handleLogRecord);
    
    _initialized = true;
    
    if (kDebugMode) {
      print('✅ سیستم Logger راه‌اندازی شد');
    }
  }

  /// ثبت و ارسال لاگ‌ها
  static void _handleLogRecord(LogRecord record) {
    try {
      // ساخت LogEntry
      final logEntry = LogEntry(
        level: record.level.name,
        message: record.message,
        category: record.loggerName,
        timestamp: DateTime.now(),
        error: record.error?.toString(),
        stackTrace: record.stackTrace?.toString(),
      );
      
      // افزودن به لیست محلی
      _addToLocalLogs(logEntry);
      
      // ارسال به Backend PHP (async بدون انتظار)
      _sendLogToBackend(logEntry);
      
    } catch (e) {
      // جلوگیری از حلقه بی‌نهایت خطا
      if (kDebugMode) {
        print('خطا در ثبت لاگ: $e');
      }
    }
  }
  
  /// ارسال لاگ به Backend PHP
  static void _sendLogToBackend(LogEntry entry) {
    // اجرای async بدون انتظار
    Future.delayed(const Duration(milliseconds: 100), () async {
      try {
        final success = await ApiService.sendLog(
          entry.level,
          entry.category,
          entry.message,
          entry.error != null ? {'error': entry.error} : null,
        );
        
        if (!success && kDebugMode) {
          print('⚠️ ارسال لاگ به سرور ناموفق بود: ${entry.message}');
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ خطا در ارسال لاگ به سرور: $e');
          print('   📋 لاگ ناموفق: [${entry.level}] ${entry.category}: ${entry.message}');
        }
        
        // اگر خطای مهمی است، بیافراینیم تلاش کنیم دوباره ارسال کنیم
        if (entry.level == 'SEVERE' || entry.level == 'ERROR') {
          _retryLogSend(entry, 1);
        }
      }
    });
  }
  
  /// تلاش مجدد برای ارسال لاگ‌های مهم
  static void _retryLogSend(LogEntry entry, int attempt) {
    if (attempt > 3) return; // حداکثر 3 تلاش
    
    Future.delayed(Duration(seconds: attempt * 2), () async {
      try {
        final success = await ApiService.sendLog(
          entry.level,
          entry.category,
          entry.message,
          entry.error != null ? {'error': entry.error} : null,
        );
        
        if (!success && attempt < 3) {
          _retryLogSend(entry, attempt + 1);
        }
      } catch (e) {
        if (attempt < 3) {
          _retryLogSend(entry, attempt + 1);
        }
      }
    });
  }

  /// افزودن لاگ به لیست محلی
  static void _addToLocalLogs(LogEntry entry) {
    _localLogs.add(entry);
    
    // حفظ حداکثر تعداد لاگ‌ها
    if (_localLogs.length > _maxLocalLogs) {
      _localLogs.removeAt(0);
    }
  }

  /// ثبت لاگ INFO
  static void info(String category, String message, [Map<String, dynamic>? context]) {
    _logger.info('[$category] $message');
    
    if (context != null && kDebugMode) {
      print('Context: ${jsonEncode(context)}');
    }
  }

  /// ثبت لاگ ERROR
  static void error(String category, String message, [dynamic error]) {
    _logger.severe('[$category] $message', error);
  }

  /// ثبت لاگ SEVERE (خطاهای بحرانی)
  static void severe(String category, String message, [dynamic error]) {
    _logger.severe('[$category] $message', error);
  }

  /// ثبت لاگ WARNING
  static void warning(String category, String message, [Map<String, dynamic>? context]) {
    _logger.warning('[$category] $message');
    
    if (context != null && kDebugMode) {
      print('Context: ${jsonEncode(context)}');
    }
  }

  /// دریافت لیست لاگ‌های محلی
  static List<LogEntry> getLocalLogs() {
    return List.unmodifiable(_localLogs.reversed.toList());
  }

  /// دریافت آخرین لاگ‌ها
  static List<LogEntry> getRecentLogs([int count = 10]) {
    final logs = getLocalLogs();
    return logs.length > count ? logs.sublist(0, count) : logs;
  }

  /// پاکسازی لاگ‌های محلی
  static void clearLocalLogs() {
    _localLogs.clear();
    info('Logger', 'لاگ‌های محلی پاکسازی شدند');
  }

  /// بررسی وضعیت سیستم لاگ
  static bool get isInitialized => _initialized;

  /// تعداد لاگ‌های محلی
  static int get localLogCount => _localLogs.length;
}

/// مدل LogEntry برای نمایش لاگ‌ها
class LogEntry {
  final String level;
  final String message;
  final String category;
  final DateTime timestamp;
  final String? error;
  final String? stackTrace;

  LogEntry({
    required this.level,
    required this.message,
    required this.category,
    required this.timestamp,
    this.error,
    this.stackTrace,
  });

  /// فرمت نمایش
  String get displayText {
    final timeStr = '${timestamp.hour.toString().padLeft(2, '0')}:'
                   '${timestamp.minute.toString().padLeft(2, '0')}:'
                   '${timestamp.second.toString().padLeft(2, '0')}';
    return '$timeStr [$level] $category: $message';
  }

  @override
  String toString() {
    return 'LogEntry($level, $category, $message, $timestamp)';
  }
}
