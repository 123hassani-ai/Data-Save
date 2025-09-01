# مدیریت State - State Management

## 📊 Document Information
- **Created:** 2025-01-09
- **Last Updated:** 2025-01-09
- **Version:** 1.0
- **Maintainer:** DataSave Development Team
- **Related Files:** `/lib/presentation/controllers/`, `/lib/main.dart`

## 🎯 Overview
مستندات کامل مدیریت State در DataSave با استفاده از Provider pattern و ChangeNotifier.

## 📋 Table of Contents
- [فلسفه State Management](#فلسفه-state-management)
- [Provider Pattern](#provider-pattern)
- [Controllers Architecture](#controllers-architecture)
- [State Management Patterns](#state-management-patterns)
- [Error Handling](#error-handling)
- [Persian Support در State](#persian-support-در-state)

## 🧠 فلسفه State Management - State Management Philosophy

### چرا Provider Pattern؟
```yaml
Benefits:
  - Simple and intuitive API
  - Excellent performance with selective rebuilds
  - Built-in dependency injection
  - Great for small to medium apps
  - Persian RTL friendly
  - Easy testing and debugging

Alternatives Considered:
  - BLoC: Too complex for current needs
  - Riverpod: Learning curve and migration cost
  - setState: Not scalable
  - GetX: Non-standard patterns

Decision: Provider for simplicity and reliability
```

### State Architecture Overview
```
UI Layer (Widgets)
    ↕️ Consumer/Selector
Controller Layer (ChangeNotifier)
    ↕️ API Calls
Service Layer (ApiService)
    ↕️ HTTP Requests  
Backend (PHP APIs)
```

## 📦 Provider Pattern

### MultiProvider Setup
```dart
// Main App Provider Configuration
class DataSaveApp extends StatelessWidget {
  const DataSaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Settings Management
        ChangeNotifierProvider(
          create: (_) => SettingsController()..loadSettings(),
        ),
        
        // Logs Management
        ChangeNotifierProvider(
          create: (_) => LogsController()..loadLogs(),
        ),
        
        // System Information
        ChangeNotifierProvider(
          create: (_) => SystemController()..loadSystemInfo(),
        ),
        
        // Chat/AI Integration (Future)
        ChangeNotifierProvider(
          create: (_) => ChatController(),
        ),
      ],
      child: MaterialApp(
        title: 'DataSave - فرم‌ساز هوشمند',
        theme: AppTheme.lightTheme,
        home: const HomePage(),
      ),
    );
  }
}
```

### Provider Hierarchy
```yaml
Root MultiProvider:
  - SettingsController: مدیریت تنظیمات سیستم
  - LogsController: مدیریت لاگ‌ها و آمارها
  - SystemController: اطلاعات سیستم و وضعیت
  - ChatController: مدیریت چت و AI (آینده)

Benefits:
  - All providers available throughout app
  - Automatic dependency injection
  - Proper lifecycle management
  - Memory efficient disposal
```

## 🎛️ Controllers Architecture

### Base Controller Pattern
```dart
// Abstract base class برای همه کنترلرها
abstract class BaseController extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  bool _isDisposed = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;
  bool get isDisposed => _isDisposed;

  // Protected methods for subclasses
  @protected
  void setLoading(bool loading) {
    if (_isDisposed) return;
    _isLoading = loading;
    notifyListeners();
  }

  @protected
  void setError(String? error) {
    if (_isDisposed) return;
    _error = error;
    notifyListeners();
  }

  @protected
  void clearError() {
    if (_isDisposed) return;
    _error = null;
    notifyListeners();
  }

  // Logging helper
  @protected
  void logAction(String action, {String? details}) {
    final controllerName = runtimeType.toString();
    LoggerService.info(controllerName, '$action${details != null ? ' - $details' : ''}');
  }

  @protected
  void logError(String action, dynamic error) {
    final controllerName = runtimeType.toString();
    LoggerService.error(controllerName, '$action - Error: $error');
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
```

### Settings Controller
```dart
// تنظیمات سیستم و API keys
class SettingsController extends BaseController {
  // Private state
  List<Map<String, dynamic>> _settings = [];
  String _openaiApiKey = '';
  String _openaiModel = 'gpt-4';
  int _maxTokens = 1000;
  double _temperature = 0.7;

  // Public getters
  List<Map<String, dynamic>> get settings => _settings;
  String get openaiApiKey => _openaiApiKey;
  String get openaiModel => _openaiModel;
  int get maxTokens => _maxTokens;
  double get temperature => _temperature;

  // Computed properties
  bool get isOpenAiConfigured => _openaiApiKey.isNotEmpty;
  Map<String, String> get settingsMap {
    Map<String, String> map = {};
    for (var setting in _settings) {
      map[setting['setting_key']] = setting['setting_value'] ?? '';
    }
    return map;
  }

  // Initialize and load settings
  Future<void> loadSettings() async {
    logAction('بارگذاری تنظیمات شروع شد');
    setLoading(true);
    
    try {
      _settings = await ApiService.getSettings();
      _updateLocalVariables();
      clearError();
      logAction('بارگذاری تنظیمات موفق', details: '${_settings.length} تنظیم بارگذاری شد');
    } catch (e) {
      final errorMsg = 'خطا در بارگذاری تنظیمات: ${e.toString()}';
      setError(errorMsg);
      logError('بارگذاری تنظیمات', e);
    } finally {
      setLoading(false);
    }
  }

  // Update specific setting
  Future<bool> updateSetting(String key, String value) async {
    logAction('بروزرسانی تنظیم', details: '$key = $value');
    
    try {
      final success = await ApiService.updateSetting(key, value);
      
      if (success) {
        // Update local state
        final index = _settings.indexWhere((s) => s['setting_key'] == key);
        if (index != -1) {
          _settings[index]['setting_value'] = value;
        } else {
          _settings.add({
            'setting_key': key,
            'setting_value': value,
            'created_at': DateTime.now().toIso8601String(),
          });
        }
        
        _updateLocalVariables();
        clearError();
        logAction('بروزرسانی تنظیم موفق', details: key);
        return true;
      } else {
        setError('خطا در بروزرسانی تنظیم: $key');
        return false;
      }
    } catch (e) {
      final errorMsg = 'خطا در بروزرسانی $key: ${e.toString()}';
      setError(errorMsg);
      logError('بروزرسانی تنظیم', e);
      return false;
    }
  }

  // Test OpenAI connection
  Future<bool> testOpenAiConnection() async {
    if (_openaiApiKey.isEmpty) {
      setError('کلید API OpenAI وارد نشده است');
      return false;
    }

    logAction('تست اتصال OpenAI');
    setLoading(true);

    try {
      final result = await ApiService.testOpenAi(_openaiApiKey);
      clearError();
      logAction('تست اتصال OpenAI موفق');
      return result;
    } catch (e) {
      final errorMsg = 'خطا در تست اتصال OpenAI: ${e.toString()}';
      setError(errorMsg);
      logError('تست اتصال OpenAI', e);
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Update OpenAI settings batch
  Future<bool> updateOpenAiSettings({
    String? apiKey,
    String? model,
    int? maxTokens,
    double? temperature,
  }) async {
    logAction('بروزرسانی تنظیمات OpenAI');
    
    bool allSuccess = true;
    
    if (apiKey != null) {
      allSuccess &= await updateSetting('openai_api_key', apiKey);
    }
    if (model != null) {
      allSuccess &= await updateSetting('openai_model', model);
    }
    if (maxTokens != null) {
      allSuccess &= await updateSetting('openai_max_tokens', maxTokens.toString());
    }
    if (temperature != null) {
      allSuccess &= await updateSetting('openai_temperature', temperature.toString());
    }

    if (allSuccess) {
      logAction('بروزرسانی تنظیمات OpenAI موفق');
    } else {
      logError('بروزرسانی تنظیمات OpenAI', 'برخی تنظیمات بروزرسانی نشدند');
    }

    return allSuccess;
  }

  // Private helper methods
  void _updateLocalVariables() {
    final map = settingsMap;
    _openaiApiKey = map['openai_api_key'] ?? '';
    _openaiModel = map['openai_model'] ?? 'gpt-4';
    _maxTokens = int.tryParse(map['openai_max_tokens'] ?? '1000') ?? 1000;
    _temperature = double.tryParse(map['openai_temperature'] ?? '0.7') ?? 0.7;
    notifyListeners();
  }

  // Reset to defaults
  void resetToDefaults() {
    logAction('بازنشانی تنظیمات به پیش‌فرض');
    _openaiApiKey = '';
    _openaiModel = 'gpt-4';
    _maxTokens = 1000;
    _temperature = 0.7;
    clearError();
    notifyListeners();
  }
}
```

### Logs Controller
```dart
// مدیریت لاگ‌ها و آمار سیستم
class LogsController extends BaseController {
  // Private state
  List<Map<String, dynamic>> _logs = [];
  Map<String, dynamic>? _stats;
  int _currentLimit = 20;
  String _currentLevel = 'all';

  // Public getters
  List<Map<String, dynamic>> get logs => _logs;
  Map<String, dynamic>? get stats => _stats;
  int get totalLogs => _stats?['total_logs'] ?? 0;
  int get errorLogs => _stats?['error_logs'] ?? 0;
  int get warningLogs => _stats?['warning_logs'] ?? 0;
  int get infoLogs => _stats?['info_logs'] ?? 0;
  int get currentLimit => _currentLimit;
  String get currentLevel => _currentLevel;

  // Computed properties
  bool get hasLogs => _logs.isNotEmpty;
  bool get hasStats => _stats != null;
  double get errorRate {
    if (totalLogs == 0) return 0.0;
    return (errorLogs / totalLogs) * 100;
  }

  // Load logs with optional filters
  Future<void> loadLogs({
    int limit = 20,
    String level = 'all',
    bool resetList = true,
  }) async {
    logAction('بارگذاری لاگ‌ها', details: 'limit: $limit, level: $level');
    
    if (resetList) {
      _currentLimit = limit;
      _currentLevel = level;
      setLoading(true);
    }

    try {
      final newLogs = await ApiService.getLogs(
        limit: limit,
        level: level,
      );

      if (resetList) {
        _logs = newLogs ?? [];
      } else {
        _logs.addAll(newLogs ?? []);
      }

      clearError();
      logAction('بارگذاری لاگ‌ها موفق', details: '${_logs.length} لاگ بارگذاری شد');
    } catch (e) {
      final errorMsg = 'خطا در بارگذاری لاگ‌ها: ${e.toString()}';
      setError(errorMsg);
      logError('بارگذاری لاگ‌ها', e);
    } finally {
      if (resetList) {
        setLoading(false);
      }
    }
  }

  // Load more logs (pagination)
  Future<void> loadMoreLogs() async {
    if (isLoading) return;
    
    final newLimit = _currentLimit + 20;
    await loadLogs(
      limit: newLimit,
      level: _currentLevel,
      resetList: false,
    );
    _currentLimit = newLimit;
  }

  // Load statistics
  Future<void> loadStats() async {
    logAction('بارگذاری آمار لاگ‌ها');
    
    try {
      _stats = await ApiService.getLogStats();
      clearError();
      logAction('بارگذاری آمار موفق', 
        details: 'کل: ${totalLogs}, خطا: ${errorLogs}');
    } catch (e) {
      final errorMsg = 'خطا در بارگذاری آمار: ${e.toString()}';
      logError('بارگذاری آمار', e);
      // Don't set error for stats, it's not critical
    }
    notifyListeners();
  }

  // Filter logs by level
  Future<void> filterByLevel(String level) async {
    if (_currentLevel == level) return;
    
    logAction('فیلتر لاگ‌ها', details: 'سطح: $level');
    await loadLogs(level: level);
  }

  // Clear all logs (with confirmation in UI)
  Future<bool> clearAllLogs() async {
    logAction('پاک کردن تمام لاگ‌ها');
    setLoading(true);

    try {
      final success = await ApiService.clearLogs();
      
      if (success) {
        _logs.clear();
        _stats = null;
        await loadStats(); // Reload stats
        clearError();
        logAction('پاک کردن لاگ‌ها موفق');
        return true;
      } else {
        setError('خطا در پاک کردن لاگ‌ها');
        return false;
      }
    } catch (e) {
      final errorMsg = 'خطا در پاک کردن لاگ‌ها: ${e.toString()}';
      setError(errorMsg);
      logError('پاک کردن لاگ‌ها', e);
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Refresh all data
  Future<void> refresh() async {
    logAction('بازخوانی کامل داده‌ها');
    await Future.wait([
      loadLogs(limit: _currentLimit, level: _currentLevel),
      loadStats(),
    ]);
  }

  // Get logs by date range (future feature)
  List<Map<String, dynamic>> getLogsByDateRange(
    DateTime start,
    DateTime end,
  ) {
    return _logs.where((log) {
      final logDate = DateTime.tryParse(log['created_at'] ?? '');
      return logDate != null &&
             logDate.isAfter(start) &&
             logDate.isBefore(end);
    }).toList();
  }
}
```

### System Controller
```dart
// اطلاعات سیستم و وضعیت سرور
class SystemController extends BaseController {
  // Private state
  Map<String, dynamic>? _systemInfo;
  Map<String, dynamic>? _serverStatus;
  DateTime? _lastUpdateTime;

  // Public getters
  Map<String, dynamic>? get systemInfo => _systemInfo;
  Map<String, dynamic>? get serverStatus => _serverStatus;
  DateTime? get lastUpdateTime => _lastUpdateTime;

  // Computed properties
  bool get hasSystemInfo => _systemInfo != null;
  bool get hasServerStatus => _serverStatus != null;
  bool get isSystemHealthy {
    if (_serverStatus == null) return false;
    return _serverStatus!['database_status'] == 'connected' &&
           _serverStatus!['api_status'] == 'active';
  }

  String get phpVersion => _systemInfo?['php_version'] ?? 'نامشخص';
  String get mysqlVersion => _systemInfo?['mysql_version'] ?? 'نامشخص';
  String get serverTime => _systemInfo?['server_time'] ?? 'نامشخص';
  int get totalSettings => _serverStatus?['total_settings'] ?? 0;
  int get totalLogs => _serverStatus?['total_logs'] ?? 0;

  // Load system information
  Future<void> loadSystemInfo() async {
    logAction('بارگذاری اطلاعات سیستم');
    setLoading(true);

    try {
      _systemInfo = await ApiService.getSystemInfo();
      _lastUpdateTime = DateTime.now();
      clearError();
      logAction('بارگذاری اطلاعات سیستم موفق');
    } catch (e) {
      final errorMsg = 'خطا در بارگذاری اطلاعات سیستم: ${e.toString()}';
      setError(errorMsg);
      logError('بارگذاری اطلاعات سیستم', e);
    } finally {
      setLoading(false);
    }
  }

  // Load server status
  Future<void> loadServerStatus() async {
    logAction('بررسی وضعیت سرور');

    try {
      _serverStatus = await ApiService.getServerStatus();
      _lastUpdateTime = DateTime.now();
      clearError();
      
      final status = isSystemHealthy ? 'سالم' : 'مشکل‌دار';
      logAction('بررسی وضعیت سرور موفق', details: 'وضعیت: $status');
    } catch (e) {
      logError('بررسی وضعیت سرور', e);
      // Don't set error for status check
    }
    notifyListeners();
  }

  // Refresh all system data
  Future<void> refresh() async {
    logAction('بازخوانی کامل اطلاعات سیستم');
    await Future.wait([
      loadSystemInfo(),
      loadServerStatus(),
    ]);
  }

  // Auto-refresh system status periodically
  void startPeriodicRefresh({Duration interval = const Duration(minutes: 5)}) {
    Timer.periodic(interval, (_) {
      if (!isDisposed) {
        loadServerStatus();
      }
    });
  }
}
```

## 🎯 State Management Patterns

### Consumer Pattern
```dart
// Basic Consumer usage
class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تنظیمات')),
      body: Consumer<SettingsController>(
        builder: (context, settingsController, child) {
          // Widget rebuilds when any property of SettingsController changes
          if (settingsController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (settingsController.hasError) {
            return ErrorWidget(
              error: settingsController.error!,
              onRetry: settingsController.loadSettings,
            );
          }

          return _buildSettingsForm(settingsController);
        },
      ),
    );
  }
}
```

### Selector Pattern (Optimized Rebuilds)
```dart
// Selective rebuilds with Selector
class LogsStatsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          // Only rebuilds when stats change
          Selector<LogsController, Map<String, dynamic>?>(
            selector: (_, controller) => controller.stats,
            builder: (context, stats, child) {
              if (stats == null) return const SizedBox.shrink();
              
              return Column(
                children: [
                  StatCard(
                    title: 'کل لاگ‌ها',
                    value: PersianUtils.formatNumber(stats['total_logs'] ?? 0),
                    icon: Icons.list_alt,
                  ),
                  StatCard(
                    title: 'خطاها',
                    value: PersianUtils.formatNumber(stats['error_logs'] ?? 0),
                    icon: Icons.error,
                    color: Colors.red,
                  ),
                ],
              );
            },
          ),
          
          // Only rebuilds when loading state changes
          Selector<LogsController, bool>(
            selector: (_, controller) => controller.isLoading,
            builder: (context, isLoading, child) {
              return isLoading 
                ? const LinearProgressIndicator()
                : const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
```

### Context.watch vs Context.read
```dart
class SettingsForm extends StatefulWidget {
  @override
  _SettingsFormState createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {
  late final TextEditingController _apiKeyController;

  @override
  void initState() {
    super.initState();
    
    // Initialize controller with current value (one-time read)
    final settingsController = context.read<SettingsController>();
    _apiKeyController = TextEditingController(
      text: settingsController.openaiApiKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch for changes to rebuild when needed
    final settingsController = context.watch<SettingsController>();
    
    return Form(
      child: Column(
        children: [
          TextFormField(
            controller: _apiKeyController,
            decoration: const InputDecoration(
              labelText: 'کلید API OpenAI',
            ),
            onChanged: (value) {
              // Use read for actions (no rebuild needed)
              context.read<SettingsController>().updateSetting(
                'openai_api_key',
                value,
              );
            },
          ),
          
          ElevatedButton(
            // Button state depends on controller state
            onPressed: settingsController.isLoading 
              ? null 
              : () => _testConnection(),
            child: settingsController.isLoading
              ? const CircularProgressIndicator()
              : const Text('تست اتصال'),
          ),
        ],
      ),
    );
  }

  void _testConnection() {
    // Use read for actions
    context.read<SettingsController>().testOpenAiConnection();
  }
}
```

### Multiple Controllers
```dart
// Using multiple controllers in one widget
class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // System status section
          Consumer<SystemController>(
            builder: (context, systemController, child) {
              return SystemStatusCard(
                isHealthy: systemController.isSystemHealthy,
                lastUpdate: systemController.lastUpdateTime,
              );
            },
          ),
          
          // Settings summary section
          Consumer<SettingsController>(
            builder: (context, settingsController, child) {
              return SettingsSummaryCard(
                isConfigured: settingsController.isOpenAiConfigured,
                settingsCount: settingsController.settings.length,
              );
            },
          ),
          
          // Logs statistics section
          Consumer<LogsController>(
            builder: (context, logsController, child) {
              return LogsStatsCard(
                totalLogs: logsController.totalLogs,
                errorRate: logsController.errorRate,
              );
            },
          ),
          
          // Refresh button affecting all controllers
          Consumer3<SystemController, SettingsController, LogsController>(
            builder: (context, systemCtrl, settingsCtrl, logsCtrl, child) {
              final isAnyLoading = systemCtrl.isLoading ||
                                 settingsCtrl.isLoading ||
                                 logsCtrl.isLoading;
              
              return FloatingActionButton(
                onPressed: isAnyLoading ? null : () => _refreshAll(context),
                child: isAnyLoading
                  ? const CircularProgressIndicator()
                  : const Icon(Icons.refresh),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _refreshAll(BuildContext context) async {
    await Future.wait([
      context.read<SystemController>().refresh(),
      context.read<SettingsController>().loadSettings(),
      context.read<LogsController>().refresh(),
    ]);
  }
}
```

## 🚨 Error Handling

### Centralized Error Management
```dart
// Custom exception classes
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  const ApiException(this.message, {this.statusCode, this.originalError});

  @override
  String toString() => 'ApiException: $message';
}

class NetworkException extends ApiException {
  const NetworkException(String message) : super(message);
}

class ValidationException extends ApiException {
  final Map<String, List<String>> errors;
  
  const ValidationException(String message, this.errors) : super(message);
}
```

### Error Handling in Controllers
```dart
// Enhanced error handling in base controller
abstract class BaseController extends ChangeNotifier {
  String? _error;
  ErrorType _errorType = ErrorType.unknown;

  String? get error => _error;
  ErrorType get errorType => _errorType;
  bool get hasError => _error != null;

  @protected
  void setError(String error, {ErrorType type = ErrorType.unknown}) {
    _error = error;
    _errorType = type;
    notifyListeners();
    
    // Log error with proper category
    LoggerService.error(
      runtimeType.toString(),
      error,
      {'type': type.name, 'timestamp': DateTime.now().toIso8601String()},
    );
  }

  @protected
  void handleApiError(dynamic error) {
    if (error is ApiException) {
      switch (error.statusCode) {
        case 401:
          setError('خطای احراز هویت', type: ErrorType.authentication);
          break;
        case 403:
          setError('عدم دسترسی', type: ErrorType.authorization);
          break;
        case 404:
          setError('منبع مورد نظر یافت نشد', type: ErrorType.notFound);
          break;
        case 500:
          setError('خطای داخلی سرور', type: ErrorType.server);
          break;
        default:
          setError('خطای API: ${error.message}', type: ErrorType.api);
      }
    } else if (error is NetworkException) {
      setError('خطای شبکه: بررسی اتصال اینترنت', type: ErrorType.network);
    } else {
      setError('خطای غیرمنتظره: ${error.toString()}', type: ErrorType.unknown);
    }
  }
}

enum ErrorType {
  unknown,
  network,
  api,
  authentication,
  authorization,
  validation,
  notFound,
  server,
}
```

### Error Display Component
```dart
// Reusable error widget
class ErrorDisplayWidget extends StatelessWidget {
  final String error;
  final ErrorType errorType;
  final VoidCallback? onRetry;
  final bool showDetails;

  const ErrorDisplayWidget({
    super.key,
    required this.error,
    this.errorType = ErrorType.unknown,
    this.onRetry,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _getErrorColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getErrorColor()),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(_getErrorIcon(), color: _getErrorColor()),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getErrorTitle(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: _getErrorColor(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('تلاش مجدد'),
            ),
          ],
        ],
      ),
    );
  }

  Color _getErrorColor() {
    switch (errorType) {
      case ErrorType.network:
        return Colors.orange;
      case ErrorType.authentication:
      case ErrorType.authorization:
        return Colors.red;
      case ErrorType.validation:
        return Colors.amber;
      case ErrorType.server:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getErrorIcon() {
    switch (errorType) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.authentication:
        return Icons.lock;
      case ErrorType.authorization:
        return Icons.security;
      case ErrorType.validation:
        return Icons.warning;
      case ErrorType.server:
        return Icons.dns;
      default:
        return Icons.error;
    }
  }

  String _getErrorTitle() {
    switch (errorType) {
      case ErrorType.network:
        return 'مشکل شبکه';
      case ErrorType.authentication:
        return 'احراز هویت';
      case ErrorType.authorization:
        return 'عدم دسترسی';
      case ErrorType.validation:
        return 'خطای اعتبارسنجی';
      case ErrorType.server:
        return 'خطای سرور';
      default:
        return 'خطا';
    }
  }
}
```

## 🇮🇷 Persian Support در State

### Persian Text Handling
```dart
// Persian text utilities در state management
extension PersianStateUtils on BaseController {
  String formatPersianNumber(int number) {
    return PersianUtils.formatNumber(number);
  }

  String formatPersianDateTime(DateTime dateTime) {
    return PersianUtils.formatDateTime(dateTime);
  }

  String formatPersianDate(DateTime date) {
    return PersianUtils.formatDate(date);
  }
}

// Usage در controllers
class LogsController extends BaseController {
  String get formattedTotalLogs => formatPersianNumber(totalLogs);
  String get formattedErrorLogs => formatPersianNumber(errorLogs);
  
  String getFormattedLogTime(Map<String, dynamic> log) {
    final createdAt = DateTime.tryParse(log['created_at'] ?? '');
    return createdAt != null 
      ? formatPersianDateTime(createdAt)
      : 'نامشخص';
  }
}
```

### Persian Validation
```dart
// Persian input validation در controllers
class SettingsController extends BaseController {
  bool _validatePersianInput(String input) {
    // Persian character validation
    final persianRegex = RegExp(r'^[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF\s\d\.\-_]+$');
    return persianRegex.hasMatch(input);
  }

  Future<bool> updatePersianSetting(String key, String value) async {
    if (!_validatePersianInput(value)) {
      setError('مقدار وارد شده شامل کاراکترهای غیرمجاز است');
      return false;
    }

    return await updateSetting(key, value);
  }
}
```

### RTL State Handling
```dart
// RTL-aware state management
class ChatController extends BaseController {
  List<ChatMessage> _messages = [];
  TextDirection _currentDirection = TextDirection.rtl;

  TextDirection get currentDirection => _currentDirection;
  List<ChatMessage> get messages => _messages;

  void addMessage(String content, {bool isUser = true}) {
    // Detect text direction
    final direction = _detectTextDirection(content);
    
    final message = ChatMessage(
      content: content,
      isUser: isUser,
      direction: direction,
      timestamp: DateTime.now(),
    );

    _messages.add(message);
    _currentDirection = direction;
    notifyListeners();

    logAction('پیام جدید اضافه شد', 
      details: 'جهت: ${direction.name}, طول: ${content.length}');
  }

  TextDirection _detectTextDirection(String text) {
    // Simple Persian/Arabic detection
    final persianRegex = RegExp(r'[\u0600-\u06FF]');
    final persianMatches = persianRegex.allMatches(text).length;
    final totalLength = text.length;
    
    return (persianMatches / totalLength) > 0.3 
      ? TextDirection.rtl 
      : TextDirection.ltr;
  }
}
```

## 🔧 Advanced Patterns

### Dependency Injection
```dart
// Service locator for dependency injection
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  static ServiceLocator get instance => _instance;

  final Map<Type, dynamic> _services = {};

  void register<T>(T service) {
    _services[T] = service;
  }

  T get<T>() {
    final service = _services[T];
    if (service == null) {
      throw Exception('Service of type $T not registered');
    }
    return service as T;
  }
}

// Enhanced controller with dependency injection
class AdvancedSettingsController extends BaseController {
  late final ApiService _apiService;
  late final LoggerService _loggerService;

  AdvancedSettingsController({
    ApiService? apiService,
    LoggerService? loggerService,
  }) {
    _apiService = apiService ?? ServiceLocator.instance.get<ApiService>();
    _loggerService = loggerService ?? ServiceLocator.instance.get<LoggerService>();
  }

  // Rest of implementation...
}
```

### Controller Composition
```dart
// Compose multiple controllers
class AppStateController extends BaseController {
  final SettingsController settingsController;
  final LogsController logsController;
  final SystemController systemController;

  AppStateController({
    required this.settingsController,
    required this.logsController,
    required this.systemController,
  }) {
    // Listen to all controllers
    settingsController.addListener(_onSettingsChanged);
    logsController.addListener(_onLogsChanged);
    systemController.addListener(_onSystemChanged);
  }

  bool get isAppReady {
    return settingsController.isOpenAiConfigured &&
           systemController.isSystemHealthy &&
           !hasError;
  }

  AppStatus get appStatus {
    if (isLoading) return AppStatus.loading;
    if (hasError) return AppStatus.error;
    if (isAppReady) return AppStatus.ready;
    return AppStatus.configuring;
  }

  void _onSettingsChanged() {
    // React to settings changes
    if (settingsController.isOpenAiConfigured) {
      logAction('OpenAI پیکربندی شد');
    }
    notifyListeners();
  }

  void _onLogsChanged() {
    // React to logs changes
    if (logsController.errorRate > 10.0) {
      setError('نرخ خطا بیش از حد مجاز است', type: ErrorType.validation);
    }
    notifyListeners();
  }

  void _onSystemChanged() {
    // React to system changes
    if (!systemController.isSystemHealthy) {
      setError('سیستم در وضعیت سالم نیست', type: ErrorType.system);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    settingsController.removeListener(_onSettingsChanged);
    logsController.removeListener(_onLogsChanged);
    systemController.removeListener(_onSystemChanged);
    super.dispose();
  }
}

enum AppStatus { loading, configuring, ready, error }
```

## 📊 Performance Optimization

### Selective Notifiers
```dart
// Custom change notifier with selective updates
class OptimizedSettingsController extends ChangeNotifier {
  String _openaiApiKey = '';
  String _openaiModel = 'gpt-4';
  bool _isLoading = false;

  // Separate notifiers for different aspects
  final ValueNotifier<String> _apiKeyNotifier = ValueNotifier('');
  final ValueNotifier<bool> _loadingNotifier = ValueNotifier(false);

  ValueListenable<String> get apiKeyListenable => _apiKeyNotifier;
  ValueListenable<bool> get loadingListenable => _loadingNotifier;

  set openaiApiKey(String value) {
    if (_openaiApiKey != value) {
      _openaiApiKey = value;
      _apiKeyNotifier.value = value;
      // Don't call notifyListeners() here
    }
  }

  set isLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      _loadingNotifier.value = value;
      notifyListeners(); // Only notify for loading changes
    }
  }

  @override
  void dispose() {
    _apiKeyNotifier.dispose();
    _loadingNotifier.dispose();
    super.dispose();
  }
}
```

### Debounced Updates
```dart
// Debounced controller for frequent updates
class DebouncedSettingsController extends BaseController {
  Timer? _debounceTimer;
  final Duration _debounceDuration = const Duration(milliseconds: 500);

  void updateSettingDebounced(String key, String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      updateSetting(key, value);
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
```

## ⚠️ Important Notes

### Best Practices
1. **Always use Provider**: نه از setState در complex widgets
2. **Selective Rebuilds**: از Selector استفاده کنید
3. **Error Handling**: همه خطاها به فارسی
4. **Logging**: همه actions را log کنید
5. **Disposal**: همه controllers را properly dispose کنید

### Common Mistakes
1. **Calling notifyListeners() too often**: Performance issues
2. **Not handling disposal**: Memory leaks
3. **Using context.watch in event handlers**: Unnecessary rebuilds
4. **Not catching exceptions**: App crashes

### Future Improvements
- **Repository Pattern**: Abstraction برای data access
- **Use Cases**: Clean architecture use cases
- **Caching**: Local state caching
- **Offline Support**: State persistence

## 🔄 Related Documentation
- [Flutter Architecture](./flutter-architecture.md)
- [UI Components Library](./ui-components-library.md)
- [API Integration](../05-Services-Integration/api-integration.md)
- [Error Handling Guide](./error-handling-guide.md)

---
*Last updated: 2025-01-09*  
*File: /docs/04-Flutter-Frontend/state-management.md*
