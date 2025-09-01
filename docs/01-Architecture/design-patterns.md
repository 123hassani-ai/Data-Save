# الگوهای طراحی استفاده شده - Design Patterns

## 📊 Document Information
- **Created:** 2025-01-09
- **Last Updated:** 2025-01-09
- **Version:** 1.0
- **Maintainer:** DataSave Development Team
- **Related Files:** `/lib/core/`, `/backend/classes/`, `/lib/presentation/`

## 🎯 Overview
این سند الگوهای طراحی (Design Patterns) استفاده شده در پروژه DataSave را شرح می‌دهد. این الگوها برای حل مشکلات مختلف در معماری، مدیریت state، ارتباط با API، و سایر جنبه‌های سیستم بکار رفته‌اند.

## 📋 Table of Contents
- [Repository Pattern](#repository-pattern)
- [Service Locator Pattern](#service-locator-pattern)
- [Provider Pattern](#provider-pattern)
- [Singleton Pattern](#singleton-pattern)
- [Factory Pattern](#factory-pattern)
- [Observer Pattern](#observer-pattern)
- [Strategy Pattern](#strategy-pattern)
- [Adapter Pattern](#adapter-pattern)

## 🗄️ Repository Pattern

### تعریف و هدف
Repository Pattern لایه‌ای از abstraction بین business logic و data access فراهم می‌کند. این الگو در DataSave برای جداسازی منطق دریافت داده از منبع داده‌ها (API، Database) استفاده شده است.

### پیاده‌سازی در DataSave

#### Abstract Repository
```dart
// lib/core/repositories/settings_repository.dart
abstract class SettingsRepository {
  Future<Either<Failure, SystemSettings>> getSettings();
  Future<Either<Failure, bool>> updateSetting(String key, dynamic value);
  Future<Either<Failure, bool>> resetSettings();
  Future<Either<Failure, Map<String, dynamic>>> getSettingsByCategory(String category);
}
```

#### Concrete Implementation
```dart
// lib/data/repositories/settings_repository_impl.dart
class SettingsRepositoryImpl implements SettingsRepository {
  final ApiService _apiService;
  final Logger _logger;
  final CacheManager _cacheManager;
  
  SettingsRepositoryImpl({
    required ApiService apiService,
    required Logger logger,
    required CacheManager cacheManager,
  }) : _apiService = apiService,
       _logger = logger,
       _cacheManager = cacheManager;

  @override
  Future<Either<Failure, SystemSettings>> getSettings() async {
    try {
      // بررسی کش محلی
      final cachedSettings = _cacheManager.getSettings();
      if (cachedSettings != null && !_cacheManager.isExpired('settings')) {
        _logger.info('تنظیمات از کش بارگذاری شد');
        return Right(cachedSettings);
      }

      // درخواست از API
      _logger.info('درخواست تنظیمات از API...');
      final response = await _apiService.get('/api/settings/get.php');
      
      if (response.success && response.data != null) {
        final settingsData = _processSettingsData(response.data);
        final settings = SystemSettings.fromMap(settingsData);
        
        // ذخیره در کش
        _cacheManager.saveSettings(settings);
        
        _logger.info('تنظیمات با موفقیت دریافت شد: ${settingsData.keys.length} آیتم');
        return Right(settings);
      } else {
        _logger.error('خطا در دریافت تنظیمات: ${response.message}');
        return Left(ServerFailure(response.message ?? 'خطا در دریافت تنظیمات'));
      }
    } catch (e) {
      _logger.error('خطای غیرمنتظره در getSettings: $e');
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateSetting(String key, dynamic value) async {
    try {
      // اعتبارسنجی ورودی
      if (key.isEmpty) {
        return Left(ValidationFailure('کلید تنظیمات نمی‌تواند خالی باشد'));
      }

      _logger.info('بروزرسانی تنظیمات: $key = $value');
      
      final response = await _apiService.post('/api/settings/update.php', {
        'key': key,
        'value': value.toString(),
      });

      if (response.success) {
        // بروزرسانی کش
        _cacheManager.updateSettingInCache(key, value);
        
        _logger.info('تنظیمات با موفقیت بروزرسانی شد: $key');
        return Right(true);
      } else {
        _logger.error('خطا در بروزرسانی: ${response.message}');
        return Left(ServerFailure(response.message ?? 'خطا در بروزرسانی'));
      }
    } catch (e) {
      _logger.error('خطای غیرمنتظره در updateSetting: $e');
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  Map<String, dynamic> _processSettingsData(dynamic data) {
    final Map<String, dynamic> processed = {};
    
    if (data is List) {
      for (final item in data) {
        if (item is Map<String, dynamic>) {
          final key = item['setting_key']?.toString() ?? '';
          final value = item['setting_value'];
          if (key.isNotEmpty) {
            processed[key] = value;
          }
        }
      }
    }
    
    return processed;
  }
}
```

### مزایای Repository Pattern
1. **جداسازی concerns**: Business logic مستقل از data source
2. **قابلیت تست**: Mock repositories برای testing
3. **انعطاف**: تعویض آسان data source
4. **کش**: مدیریت کش در یک مکان مرکزی
5. **Persian Support**: پردازش مناسب محتوای فارسی

## 🔧 Service Locator Pattern

### تعریف و کاربرد
Service Locator برای مدیریت dependency injection و lifecycle اشیاء استفاده می‌شود. در DataSave از کتابخانه GetIt برای پیاده‌سازی این الگو استفاده شده است.

### Implementation
```dart
// lib/core/di/service_locator.dart
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

class ServiceLocator {
  static Future<void> init() async {
    // External Dependencies
    _registerExternalDependencies();
    
    // Core Services
    _registerCoreServices();
    
    // Repositories
    _registerRepositories();
    
    // Use Cases
    _registerUseCases();
    
    // Controllers/Providers
    _registerControllers();
  }

  static void _registerExternalDependencies() {
    // HTTP Client
    sl.registerLazySingleton(() => http.Client());
    
    // Logger - Singleton برای logging مرکزی
    sl.registerLazySingleton(() => Logger(
      filter: ProductionFilter(),
      printer: PersianLogPrinter(), // Custom printer for Persian logs
      output: MultiOutput([
        ConsoleOutput(),
        FileOutput(file: File('datasave_logs.txt')),
      ]),
    ));
    
    // Cache Manager
    sl.registerLazySingleton(() => CacheManager());
  }

  static void _registerCoreServices() {
    // API Service
    sl.registerLazySingleton<ApiService>(() => ApiService(
      client: sl<http.Client>(),
      logger: sl<Logger>(),
      baseUrl: AppConfig.apiBaseUrl,
      defaultHeaders: {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json',
        'Accept-Language': 'fa-IR',
      },
    ));
    
    // OpenAI Service
    sl.registerLazySingleton<OpenAIService>(() => OpenAIService(
      apiService: sl<ApiService>(),
      logger: sl<Logger>(),
    ));
  }

  static void _registerRepositories() {
    // Settings Repository
    sl.registerLazySingleton<SettingsRepository>(() => SettingsRepositoryImpl(
      apiService: sl<ApiService>(),
      logger: sl<Logger>(),
      cacheManager: sl<CacheManager>(),
    ));
    
    // Logs Repository
    sl.registerLazySingleton<LogsRepository>(() => LogsRepositoryImpl(
      apiService: sl<ApiService>(),
      logger: sl<Logger>(),
    ));
    
    // OpenAI Repository
    sl.registerLazySingleton<OpenAIRepository>(() => OpenAIRepositoryImpl(
      openaiService: sl<OpenAIService>(),
      logger: sl<Logger>(),
    ));
  }

  static void _registerUseCases() {
    // Settings Use Cases
    sl.registerLazySingleton(() => GetSettingsUseCase(
      repository: sl<SettingsRepository>(),
    ));
    
    sl.registerLazySingleton(() => UpdateSettingUseCase(
      repository: sl<SettingsRepository>(),
    ));
    
    // OpenAI Use Cases
    sl.registerLazySingleton(() => TestOpenAIConnectionUseCase(
      repository: sl<OpenAIRepository>(),
    ));
    
    sl.registerLazySingleton(() => GenerateFormUseCase(
      repository: sl<OpenAIRepository>(),
    ));
  }

  static void _registerControllers() {
    // Factory برای controllers - هر بار instance جدید
    sl.registerFactory(() => SettingsController(
      getSettingsUseCase: sl<GetSettingsUseCase>(),
      updateSettingUseCase: sl<UpdateSettingUseCase>(),
      logger: sl<Logger>(),
    ));
    
    sl.registerFactory(() => DashboardController(
      getSettingsUseCase: sl<GetSettingsUseCase>(),
      logger: sl<Logger>(),
    ));
    
    sl.registerFactory(() => OpenAIController(
      testConnectionUseCase: sl<TestOpenAIConnectionUseCase>(),
      generateFormUseCase: sl<GenerateFormUseCase>(),
      logger: sl<Logger>(),
    ));
  }
}

// Custom Persian Log Printer
class PersianLogPrinter extends PrettyPrinter {
  @override
  List<String> log(LogEvent event) {
    final time = DateTime.now();
    final persianTime = PersianDateTime.fromDateTime(time).toString();
    
    return [
      '[$persianTime] ${event.level.name}: ${event.message}',
      if (event.error != null) 'خطا: ${event.error}',
      if (event.stackTrace != null) 'Stack Trace: ${event.stackTrace}',
    ];
  }
}
```

### Usage در Main App
```dart
// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize service locator
  await ServiceLocator.init();
  
  runApp(const DataSaveApp());
}

class DataSaveApp extends StatelessWidget {
  const DataSaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => sl<SettingsController>()..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => sl<DashboardController>(),
        ),
        ChangeNotifierProvider(
          create: (_) => sl<OpenAIController>(),
        ),
      ],
      child: Consumer<SettingsController>(
        builder: (context, settingsController, _) {
          return MaterialApp(
            title: 'DataSave',
            theme: AppTheme.create(
              language: settingsController.appLanguage,
              themeMode: settingsController.themeMode,
            ),
            locale: Locale(settingsController.appLanguage, 'IR'),
            home: const DashboardPage(),
          );
        },
      ),
    );
  }
}
```

## 📱 Provider Pattern (State Management)

### تعریف و کاربرد
Provider Pattern برای مدیریت state در Flutter استفاده می‌شود. در DataSave برای مدیریت state صفحات مختلف و ارتباط بین UI و business logic بکار رفته است.

### Controller Implementation
```dart
// lib/presentation/controllers/settings_controller.dart
class SettingsController extends ChangeNotifier {
  final GetSettingsUseCase _getSettingsUseCase;
  final UpdateSettingUseCase _updateSettingUseCase;
  final Logger _logger;
  
  // State variables
  SystemSettings? _settings;
  bool _isLoading = false;
  String? _error;
  Map<String, bool> _updateStates = {};
  
  // Constructor
  SettingsController({
    required GetSettingsUseCase getSettingsUseCase,
    required UpdateSettingUseCase updateSettingUseCase,
    required Logger logger,
  }) : _getSettingsUseCase = getSettingsUseCase,
       _updateSettingUseCase = updateSettingUseCase,
       _logger = logger;

  // Getters
  SystemSettings? get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get appLanguage => _settings?.appLanguage ?? 'fa';
  ThemeMode get themeMode => _settings?.appTheme == 'dark' 
    ? ThemeMode.dark 
    : ThemeMode.light;
  
  bool isUpdating(String key) => _updateStates[key] ?? false;

  // Initialization
  Future<void> init() async {
    await loadSettings();
  }

  // Load settings
  Future<void> loadSettings() async {
    _setLoading(true);
    _setError(null);
    
    _logger.info('شروع بارگذاری تنظیمات...');
    
    final result = await _getSettingsUseCase.execute();
    
    result.fold(
      (failure) {
        final errorMessage = _getLocalizedError(failure);
        _setError(errorMessage);
        _logger.error('خطا در بارگذاری تنظیمات: $errorMessage');
      },
      (settings) {
        _settings = settings;
        _logger.info('تنظیمات با موفقیت بارگذاری شد');
      },
    );
    
    _setLoading(false);
  }

  // Update single setting
  Future<void> updateSetting(String key, dynamic value) async {
    if (_settings == null) {
      _setError('تنظیمات هنوز بارگذاری نشده است');
      return;
    }

    _setUpdateState(key, true);
    _setError(null);
    
    _logger.info('بروزرسانی تنظیمات: $key = $value');
    
    final result = await _updateSettingUseCase.execute(
      UpdateSettingParams(key: key, value: value),
    );
    
    result.fold(
      (failure) {
        final errorMessage = _getLocalizedError(failure);
        _setError(errorMessage);
        _logger.error('خطا در بروزرسانی $key: $errorMessage');
      },
      (success) {
        // Update local state
        _settings = _settings!.copyWith(
          key: key,
          value: value,
        );
        _logger.info('تنظیمات $key با موفقیت بروزرسانی شد');
        
        // Show success message
        _showSuccessMessage('تنظیمات با موفقیت بروزرسانی شد');
      },
    );
    
    _setUpdateState(key, false);
  }

  // Batch update multiple settings
  Future<void> updateMultipleSettings(Map<String, dynamic> updates) async {
    _setLoading(true);
    _setError(null);
    
    for (final entry in updates.entries) {
      await updateSetting(entry.key, entry.value);
      if (_error != null) break; // Stop on first error
    }
    
    _setLoading(false);
  }

  // Reset settings to default
  Future<void> resetSettings() async {
    _setLoading(true);
    _setError(null);
    
    final defaultSettings = SystemSettings.defaultSettings();
    await updateMultipleSettings(defaultSettings.toMap());
    
    _setLoading(false);
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _setUpdateState(String key, bool updating) {
    _updateStates[key] = updating;
    notifyListeners();
  }

  String _getLocalizedError(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'خطا در ارتباط با سرور: ${failure.message}';
      case NetworkFailure:
        return 'خطا در اتصال به اینترنت: ${failure.message}';
      case ValidationFailure:
        return 'خطای اعتبارسنجی: ${failure.message}';
      case CacheFailure:
        return 'خطا در کش محلی: ${failure.message}';
      default:
        return 'خطای غیرمنتظره: ${failure.message}';
    }
  }

  void _showSuccessMessage(String message) {
    // This could trigger a success snackbar
    // Implementation depends on UI requirements
    _logger.info('پیام موفقیت: $message');
  }

  @override
  void dispose() {
    _logger.info('SettingsController disposed');
    super.dispose();
  }
}
```

### UI Integration
```dart
// lib/presentation/pages/settings_page.dart
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تنظیمات سیستم'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<SettingsController>(
        builder: (context, controller, child) {
          if (controller.isLoading && controller.settings == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('در حال بارگذاری تنظیمات...'),
                ],
              ),
            );
          }

          if (controller.error != null && controller.settings == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    controller.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: controller.loadSettings,
                    child: const Text('تلاش مجدد'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (controller.error != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error, color: Colors.red[400]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            controller.error!,
                            style: TextStyle(color: Colors.red[700]),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => controller._setError(null),
                        ),
                      ],
                    ),
                  ),
                
                // OpenAI Settings
                SettingsCard(
                  title: 'تنظیمات هوش مصنوعی',
                  icon: Icons.psychology,
                  children: [
                    _buildSettingTile(
                      title: 'مدل OpenAI',
                      subtitle: 'انتخاب مدل هوش مصنوعی',
                      value: controller.settings?.openaiModel ?? '',
                      onChanged: (value) => controller.updateSetting('openai_model', value),
                      isUpdating: controller.isUpdating('openai_model'),
                      options: ['gpt-4', 'gpt-4-turbo', 'gpt-3.5-turbo'],
                    ),
                    _buildSettingTile(
                      title: 'حداکثر توکن‌ها',
                      subtitle: 'تعداد حداکثر توکن برای پاسخ',
                      value: controller.settings?.maxTokens.toString() ?? '',
                      onChanged: (value) => controller.updateSetting(
                        'openai_max_tokens', 
                        int.tryParse(value) ?? 2048,
                      ),
                      isUpdating: controller.isUpdating('openai_max_tokens'),
                      inputType: TextInputType.number,
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // App Settings
                SettingsCard(
                  title: 'تنظیمات اپلیکیشن',
                  icon: Icons.settings,
                  children: [
                    _buildSwitchTile(
                      title: 'فعال‌سازی لاگ‌ها',
                      subtitle: 'ذخیره گزارش‌های سیستم',
                      value: controller.settings?.enableLogging ?? true,
                      onChanged: (value) => controller.updateSetting('enable_logging', value),
                      isUpdating: controller.isUpdating('enable_logging'),
                    ),
                    _buildSwitchTile(
                      title: 'ذخیره خودکار',
                      subtitle: 'ذخیره خودکار تغییرات',
                      value: controller.settings?.autoSave ?? true,
                      onChanged: (value) => controller.updateSetting('auto_save', value),
                      isUpdating: controller.isUpdating('auto_save'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required String value,
    required Function(String) onChanged,
    required bool isUpdating,
    List<String>? options,
    TextInputType inputType = TextInputType.text,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: SizedBox(
        width: 200,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (isUpdating)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Expanded(
                child: options != null
                  ? DropdownButtonFormField<String>(
                      value: options.contains(value) ? value : options.first,
                      items: options.map((option) => DropdownMenuItem(
                        value: option,
                        child: Text(option),
                      )).toList(),
                      onChanged: (newValue) {
                        if (newValue != null) onChanged(newValue);
                      },
                      decoration: const InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                    )
                  : TextFormField(
                      initialValue: value,
                      keyboardType: inputType,
                      textAlign: TextAlign.right,
                      onFieldSubmitted: onChanged,
                      decoration: const InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required bool isUpdating,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: isUpdating
        ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Switch(
            value: value,
            onChanged: onChanged,
          ),
    );
  }
}
```

## 🏭 Singleton Pattern

### Logger Service Implementation
```dart
// lib/core/logger/logger_service.dart
class LoggerService {
  static LoggerService? _instance;
  static final Logger _logger = Logger(
    filter: ProductionFilter(),
    printer: PersianLogPrinter(),
    output: MultiOutput([
      ConsoleOutput(),
      FileOutput(file: File('logs/datasave.log')),
    ]),
  );

  LoggerService._internal();

  static LoggerService get instance {
    _instance ??= LoggerService._internal();
    return _instance!;
  }

  // Log methods with Persian support
  void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  // Persian-specific logging
  void logPersianAction(String action, Map<String, dynamic>? context) {
    final message = 'عملیات: $action';
    final contextString = context != null 
      ? ' - جزئیات: ${json.encode(context)}'
      : '';
    _logger.i('$message$contextString');
  }

  void logApiRequest(String endpoint, String method, [Map<String, dynamic>? data]) {
    _logger.i('درخواست API: $method $endpoint${data != null ? ' - داده: ${json.encode(data)}' : ''}');
  }

  void logApiResponse(String endpoint, bool success, String message) {
    if (success) {
      _logger.i('پاسخ موفق API: $endpoint - $message');
    } else {
      _logger.e('پاسخ ناموفق API: $endpoint - $message');
    }
  }
}
```

## 🏭 Factory Pattern

### API Response Factory
```dart
// lib/core/models/api_response.dart
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final List<String> errors;
  final String timestamp;

  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors = const [],
    required this.timestamp,
  });

  // Factory constructors
  factory ApiResponse.success({
    required T data,
    String message = '',
  }) {
    return ApiResponse<T>(
      success: true,
      message: message.isEmpty ? 'عملیات با موفقیت انجام شد' : message,
      data: data,
      timestamp: DateTime.now().toIso8601String(),
    );
  }

  factory ApiResponse.error({
    required String message,
    List<String> errors = const [],
  }) {
    return ApiResponse<T>(
      success: false,
      message: message,
      errors: errors,
      timestamp: DateTime.now().toIso8601String(),
    );
  }

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic)? dataParser) {
    try {
      return ApiResponse<T>(
        success: json['success'] ?? false,
        message: json['message'] ?? '',
        data: dataParser != null && json['data'] != null 
          ? dataParser(json['data'])
          : json['data'] as T?,
        errors: (json['errors'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
        timestamp: json['timestamp'] ?? DateTime.now().toIso8601String(),
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'خطا در تجزیه پاسخ: $e',
        errors: [e.toString()],
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
      'errors': errors,
      'timestamp': timestamp,
    };
  }

  // Convenience methods
  bool get isSuccess => success;
  bool get isError => !success;
  bool get hasData => data != null;
  bool get hasErrors => errors.isNotEmpty;
}
```

## 👁️ Observer Pattern

### Event Bus Implementation
```dart
// lib/core/events/event_bus.dart
class DataSaveEventBus {
  static final DataSaveEventBus _instance = DataSaveEventBus._internal();
  factory DataSaveEventBus() => _instance;
  DataSaveEventBus._internal();

  final StreamController<DataSaveEvent> _eventController = StreamController.broadcast();
  
  Stream<DataSaveEvent> get events => _eventController.stream;
  
  void fire(DataSaveEvent event) {
    _eventController.add(event);
  }
  
  void dispose() {
    _eventController.close();
  }
}

// Event base class
abstract class DataSaveEvent {
  final DateTime timestamp;
  final String eventType;
  
  DataSaveEvent(this.eventType) : timestamp = DateTime.now();
}

// Specific events
class SettingsUpdatedEvent extends DataSaveEvent {
  final String settingKey;
  final dynamic oldValue;
  final dynamic newValue;
  
  SettingsUpdatedEvent({
    required this.settingKey,
    required this.oldValue,
    required this.newValue,
  }) : super('settings_updated');
}

class OpenAIRequestEvent extends DataSaveEvent {
  final String prompt;
  final String model;
  final int tokens;
  
  OpenAIRequestEvent({
    required this.prompt,
    required this.model,
    required this.tokens,
  }) : super('openai_request');
}

// Usage in controllers
class SettingsController extends ChangeNotifier {
  final DataSaveEventBus _eventBus = DataSaveEventBus();
  
  Future<void> updateSetting(String key, dynamic value) async {
    final oldValue = _settings?.getValue(key);
    
    // Update logic...
    
    // Fire event
    _eventBus.fire(SettingsUpdatedEvent(
      settingKey: key,
      oldValue: oldValue,
      newValue: value,
    ));
  }
}
```

## 🎯 Strategy Pattern

### Persian Text Processing Strategy
```dart
// lib/core/strategies/text_processing_strategy.dart
abstract class TextProcessingStrategy {
  String processText(String input);
  bool isValidForLanguage(String text);
}

class PersianTextStrategy implements TextProcessingStrategy {
  @override
  String processText(String input) {
    return input
      .replaceAll(RegExp(r'[0-9]'), (match) => _convertToPersianDigit(match.group(0)!))
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  }
  
  @override
  bool isValidForLanguage(String text) {
    // Check if text contains Persian characters
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }
  
  String _convertToPersianDigit(String digit) {
    const persianDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    final index = int.tryParse(digit);
    return index != null ? persianDigits[index] : digit;
  }
}

class EnglishTextStrategy implements TextProcessingStrategy {
  @override
  String processText(String input) {
    return input
      .replaceAll(RegExp(r'[۰-۹]'), (match) => _convertToEnglishDigit(match.group(0)!))
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  }
  
  @override
  bool isValidForLanguage(String text) {
    // Check if text contains Latin characters
    return RegExp(r'[a-zA-Z]').hasMatch(text);
  }
  
  String _convertToEnglishDigit(String digit) {
    const persianToEnglish = {
      '۰': '0', '۱': '1', '۲': '2', '۳': '3', '۴': '4',
      '۵': '5', '۶': '6', '۷': '7', '۸': '8', '۹': '9'
    };
    return persianToEnglish[digit] ?? digit;
  }
}

// Context class
class TextProcessor {
  late TextProcessingStrategy _strategy;
  
  TextProcessor(TextProcessingStrategy strategy) : _strategy = strategy;
  
  void setStrategy(TextProcessingStrategy strategy) {
    _strategy = strategy;
  }
  
  String process(String text) {
    return _strategy.processText(text);
  }
  
  bool isValid(String text) {
    return _strategy.isValidForLanguage(text);
  }
}

// Usage
final processor = TextProcessor(PersianTextStrategy());
final processedText = processor.process('سلام ۱۲۳ دنیا');
// Result: "سلام ۱۲۳ دنیا"

processor.setStrategy(EnglishTextStrategy());
final englishText = processor.process('Hello ۱۲۳ World');
// Result: "Hello 123 World"
```

## 🔌 Adapter Pattern

### API Adapter for Different Response Formats
```dart
// lib/core/adapters/api_adapter.dart
abstract class ApiAdapter<T> {
  T adaptResponse(Map<String, dynamic> response);
}

// Settings API Adapter
class SettingsApiAdapter implements ApiAdapter<List<SettingSetting>> {
  @override
  List<SystemSetting> adaptResponse(Map<String, dynamic> response) {
    final data = response['data'] as List<dynamic>?;
    if (data == null) return [];
    
    return data.map((item) {
      final settingData = item as Map<String, dynamic>;
      return SystemSetting(
        key: settingData['setting_key'] ?? '',
        value: settingData['setting_value'] ?? '',
        description: settingData['description'] ?? '',
        type: _parseSettingType(settingData['setting_type']),
        isSystem: settingData['is_system'] == 1,
        createdAt: DateTime.tryParse(settingData['created_at'] ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(settingData['updated_at'] ?? '') ?? DateTime.now(),
      );
    }).toList();
  }
  
  SettingType _parseSettingType(dynamic type) {
    switch (type?.toString().toLowerCase()) {
      case 'string':
        return SettingType.string;
      case 'number':
        return SettingType.number;
      case 'boolean':
        return SettingType.boolean;
      case 'encrypted':
        return SettingType.encrypted;
      default:
        return SettingType.string;
    }
  }
}

// OpenAI API Adapter
class OpenAIApiAdapter implements ApiAdapter<OpenAIResponse> {
  @override
  OpenAIResponse adaptResponse(Map<String, dynamic> response) {
    return OpenAIResponse(
      success: response['success'] ?? false,
      content: response['choices']?[0]?['message']?['content'] ?? '',
      model: response['model'] ?? '',
      usage: OpenAIUsage(
        promptTokens: response['usage']?['prompt_tokens'] ?? 0,
        completionTokens: response['usage']?['completion_tokens'] ?? 0,
        totalTokens: response['usage']?['total_tokens'] ?? 0,
      ),
      finishReason: response['choices']?[0]?['finish_reason'] ?? '',
    );
  }
}

// Generic API Service with Adapter
class AdaptableApiService {
  final ApiService _apiService;
  final Map<String, ApiAdapter> _adapters = {};
  
  AdaptableApiService(this._apiService);
  
  void registerAdapter<T>(String endpoint, ApiAdapter<T> adapter) {
    _adapters[endpoint] = adapter;
  }
  
  Future<T?> getAdapted<T>(String endpoint) async {
    final adapter = _adapters[endpoint] as ApiAdapter<T>?;
    if (adapter == null) {
      throw Exception('No adapter registered for endpoint: $endpoint');
    }
    
    final response = await _apiService.get(endpoint);
    if (response.success && response.data != null) {
      return adapter.adaptResponse(response.data);
    }
    
    return null;
  }
}

// Usage
final adaptableService = AdaptableApiService(apiService);

// Register adapters
adaptableService.registerAdapter('/api/settings/get.php', SettingsApiAdapter());
adaptableService.registerAdapter('/api/openai/generate', OpenAIApiAdapter());

// Use with type safety
final settings = await adaptableService.getAdapted<List<SystemSetting>>('/api/settings/get.php');
final openaiResponse = await adaptableService.getAdapted<OpenAIResponse>('/api/openai/generate');
```

## 📊 Benefits of Design Patterns in DataSave

### Code Organization
1. **مسئولیت‌های واضح**: هر pattern مسئولیت مشخص دارد
2. **قابل نگهداری**: کد organized و قابل فهم
3. **قابل توسعه**: اضافه کردن features جدید آسان‌تر است
4. **قابل تست**: هر component مستقل قابل test است

### Persian Language Support
1. **Text Processing**: Strategies برای پردازش متن فارسی
2. **Localized Logging**: پیام‌های log به زبان فارسی
3. **RTL Support**: Adapters برای RTL layout
4. **Cultural Adaptation**: Patterns مناسب با فرهنگ ایرانی

### Performance Benefits
1. **Lazy Loading**: Service Locator با lazy initialization
2. **Caching**: Repository pattern با cache layer
3. **Memory Management**: Proper disposal در controllers
4. **Event Handling**: Efficient event system

### Development Benefits
1. **Team Collaboration**: Clear patterns برای team work
2. **Code Reuse**: Reusable components و services
3. **Testing**: Mockable dependencies
4. **Documentation**: Self-documenting code structure

## ⚠️ Important Notes

### Best Practices Followed
- **SOLID Principles**: تمام patterns از SOLID پیروی می‌کنند
- **Persian-First**: همه patterns برای فارسی optimize شده‌اند
- **Error Handling**: Comprehensive error handling در همه patterns
- **Logging**: Centralized logging با Persian support
- **Testing**: همه patterns به صورت unit test قابل آزمایش هستند

### Common Pitfalls Avoided
- ❌ God Objects - تک کلاس با مسئولیت زیاد
- ❌ Tight Coupling - وابستگی مستقیم بین components
- ❌ Memory Leaks - proper disposal pattern
- ❌ Mixed Languages - consistent Persian/English usage
- ❌ Over-Engineering - استفاده مناسب از patterns

### Future Pattern Enhancements
- **MVVM Pattern**: برای صفحات پیچیده‌تر
- **Command Pattern**: برای undo/redo functionality
- **Decorator Pattern**: برای middleware layers
- **Composite Pattern**: برای form builder components
- **State Pattern**: برای complex state management

## 🔄 Related Documentation
- [Clean Architecture Implementation](./clean-architecture-implementation.md)
- [System Architecture](./system-architecture.md)
- [Flutter State Management](../04-Flutter-Frontend/state-management.md)
- [Services Integration](../05-Services-Integration/services-integration.md)

---
*این مستندات بخشی از مجموعه مستندات فنی پروژه DataSave است*  
*Last updated: 2025-01-09*  
*File: /docs/01-Architecture/design-patterns.md*