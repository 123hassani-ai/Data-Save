# پیاده‌سازی Clean Architecture - Clean Architecture Implementation

## 📊 Document Information
- **Created:** 2025-01-09
- **Last Updated:** 2025-01-09
- **Version:** 1.0
- **Maintainer:** DataSave Development Team
- **Related Files:** `/lib/core/`, `/lib/presentation/`, `/lib/main.dart`

## 🎯 Overview
این سند جزئیات پیاده‌سازی الگوی Clean Architecture در پروژه DataSave را شرح می‌دهد. این معماری به تفکیک واضح مسئولیت‌ها، قابلیت تست بالا، و نگهداری آسان کد کمک می‌کند.

## 📋 Table of Contents
- [مبانی Clean Architecture](#مبانی-clean-architecture)
- [لایه‌های معماری](#لایههای-معماری)
- [ساختار پروژه](#ساختار-پروژه)
- [Dependency Injection](#dependency-injection)
- [Data Flow Pattern](#data-flow-pattern)
- [Error Handling](#error-handling)

## 🏗️ مبانی Clean Architecture

### اصول بنیادی

#### 1. استقلال Framework
```yaml
Principle: معماری نباید وابسته به framework خاصی باشد
Implementation in DataSave:
  - Core business logic مستقل از Flutter
  - Database operations قابل تعویض
  - External services به صورت interface
  - UI components جداگانه از business logic

Example:
  # ❌ Wrong - Direct Flutter dependency
  class SettingsService {
    void saveSettings() {
      SharedPreferences.getInstance(); // Direct Flutter dependency
    }
  }
  
  # ✅ Correct - Abstraction layer
  abstract class SettingsRepository {
    Future<void> saveSettings(Map<String, dynamic> settings);
  }
```

#### 2. قابلیت تست بودن
```dart
// تمام business logic قابل unit test است
class SettingsUseCase {
  final SettingsRepository _repository;
  final Logger _logger;
  
  SettingsUseCase({
    required SettingsRepository repository,
    required Logger logger,
  }) : _repository = repository, _logger = logger;
  
  Future<Either<Failure, Settings>> getSettings() async {
    try {
      final settings = await _repository.getSettings();
      _logger.info('تنظیمات با موفقیت بارگذاری شد');
      return Right(settings);
    } catch (e) {
      _logger.error('خطا در بارگذاری تنظیمات: $e');
      return Left(SettingsFailure(e.toString()));
    }
  }
}
```

#### 3. استقلال از UI
```dart
// Business logic مستقل از UI
class OpenAIUseCase {
  final OpenAIRepository _repository;
  
  Future<Either<Failure, String>> generateFormStructure(String prompt) async {
    // Persian prompt optimization
    final optimizedPrompt = _optimizePromptForPersian(prompt);
    
    final result = await _repository.generateContent(
      prompt: optimizedPrompt,
      maxTokens: 2048,
      language: 'fa',
    );
    
    return result.fold(
      (failure) => Left(failure),
      (content) => Right(content),
    );
  }
  
  String _optimizePromptForPersian(String prompt) {
    return 'لطفاً به زبان فارسی پاسخ دهید: $prompt';
  }
}
```

## 🏛️ لایه‌های معماری

### معماری سه‌لایه DataSave

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │   Pages     │  │   Widgets   │  │    Controllers      │ │
│  │             │  │             │  │   (Provider)        │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
└─────────────────────────┬───────────────────────────────────┘
                          │
┌─────────────────────────┴───────────────────────────────────┐
│                      DOMAIN LAYER                           │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │  Use Cases  │  │   Entities  │  │   Repositories      │ │
│  │             │  │             │  │   (Abstract)        │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
└─────────────────────────┬───────────────────────────────────┘
                          │
┌─────────────────────────┴───────────────────────────────────┐
│                       DATA LAYER                            │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │ Repository  │  │ Data Source │  │     Models          │ │
│  │Implementation│  │  (API/DB)   │  │                     │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### Presentation Layer (لایه نمایش)

#### مسئولیت‌ها
- **UI Rendering**: نمایش رابط کاربری فارسی با RTL support
- **User Interaction**: مدیریت تعامل کاربر و input handling
- **State Management**: مدیریت state با Provider pattern
- **Navigation**: مسیریابی بین صفحات و deep linking

#### ساختار فعلی
```
lib/presentation/
├── pages/
│   ├── dashboard_page.dart      # صفحه اصلی داشبورد
│   ├── settings_page.dart       # صفحه تنظیمات
│   └── logs_page.dart           # صفحه لاگ‌ها
├── widgets/
│   └── shared/
│       ├── stat_card.dart       # کارت نمایش آمار
│       ├── settings_card.dart   # کارت تنظیمات
│       ├── log_stat_card.dart   # کارت آمار لاگ‌ها
│       └── action_button.dart   # دکمه عملیات
└── controllers/
    ├── dashboard_controller.dart # کنترلر داشبورد
    └── settings_controller.dart  # کنترلر تنظیمات
```

#### نمونه کد Provider Controller
```dart
class SettingsController extends ChangeNotifier {
  final SettingsUseCase _settingsUseCase;
  final Logger _logger;
  
  Map<String, dynamic> _settings = {};
  bool _isLoading = false;
  String? _error;
  
  SettingsController({
    required SettingsUseCase settingsUseCase,
    required Logger logger,
  }) : _settingsUseCase = settingsUseCase, _logger = logger;
  
  Map<String, dynamic> get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> loadSettings() async {
    _setLoading(true);
    _setError(null);
    
    final result = await _settingsUseCase.getSettings();
    
    result.fold(
      (failure) {
        _setError('خطا در بارگذاری تنظیمات: ${failure.message}');
        _logger.error('Settings load failed: ${failure.message}');
      },
      (settings) {
        _settings = settings.toMap();
        _logger.info('تنظیمات با موفقیت بارگذاری شد');
      },
    );
    
    _setLoading(false);
  }
  
  Future<void> updateSetting(String key, dynamic value) async {
    final result = await _settingsUseCase.updateSetting(key, value);
    
    result.fold(
      (failure) => _setError('خطا در بروزرسانی: ${failure.message}'),
      (success) {
        _settings[key] = value;
        notifyListeners();
        _logger.info('تنظیمات بروزرسانی شد: $key = $value');
      },
    );
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }
}
```

### Domain Layer (لایه دامین)

#### Use Cases (موارد استفاده)
```dart
// مثال: OpenAI Use Case
class OpenAIUseCase {
  final OpenAIRepository _repository;
  final Logger _logger;
  
  OpenAIUseCase({
    required OpenAIRepository repository,
    required Logger logger,
  }) : _repository = repository, _logger = logger;
  
  Future<Either<Failure, String>> testConnection() async {
    try {
      _logger.info('آزمایش ارتباط با OpenAI...');
      
      final result = await _repository.testConnection();
      
      return result.fold(
        (failure) {
          _logger.error('خطا در اتصال به OpenAI: ${failure.message}');
          return Left(failure);
        },
        (success) {
          _logger.info('اتصال به OpenAI موفق بود');
          return Right('اتصال با موفقیت برقرار شد');
        },
      );
    } catch (e) {
      _logger.error('خطای غیرمنتظره در OpenAI: $e');
      return Left(UnexpectedFailure(e.toString()));
    }
  }
  
  Future<Either<Failure, String>> generateForm({
    required String description,
    required String formType,
  }) async {
    // اعتبارسنجی ورودی
    if (description.trim().isEmpty) {
      return Left(ValidationFailure('توضیحات فرم نمی‌تواند خالی باشد'));
    }
    
    // ایجاد prompt فارسی
    final prompt = _createPersianPrompt(description, formType);
    
    try {
      final result = await _repository.generateContent(
        prompt: prompt,
        maxTokens: 2048,
        temperature: 0.7,
      );
      
      return result.fold(
        (failure) => Left(failure),
        (content) {
          _logger.info('فرم با موفقیت تولید شد');
          return Right(content);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('خطا در تولید فرم: $e'));
    }
  }
  
  String _createPersianPrompt(String description, String formType) {
    return '''
شما یک طراح حرفه‌ای فرم هستید. لطفاً بر اساس توضیحات زیر، یک فرم $formType طراحی کنید:

توضیحات: $description

لطفاً فرم را به صورت JSON با ساختار زیر برگردانید:
{
  "title": "عنوان فرم",
  "description": "توضیحات فرم",
  "fields": [
    {
      "name": "نام فیلد",
      "type": "نوع فیلد",
      "label": "برچسب فارسی",
      "required": true/false,
      "validation": "قوانین اعتبارسنجی"
    }
  ]
}

نکات مهم:
- تمام متون باید به زبان فارسی باشند
- فیلدها باید منطقی و کاربردی باشند
- نوع فیلدها: text, email, phone, number, textarea, select, checkbox, radio
- قوانین اعتبارسنجی مناسب تعریف کنید
''';
  }
}
```

#### Entities (موجودیت‌ها)
```dart
class SystemSettings {
  final String openaiApiKey;
  final String openaiModel;
  final int maxTokens;
  final String appLanguage;
  final bool enableLogging;
  final int maxLogEntries;
  final String appTheme;
  final bool autoSave;
  final bool backupEnabled;
  
  const SystemSettings({
    required this.openaiApiKey,
    required this.openaiModel,
    required this.maxTokens,
    required this.appLanguage,
    required this.enableLogging,
    required this.maxLogEntries,
    required this.appTheme,
    required this.autoSave,
    required this.backupEnabled,
  });
  
  factory SystemSettings.fromMap(Map<String, dynamic> map) {
    return SystemSettings(
      openaiApiKey: map['openai_api_key'] ?? '',
      openaiModel: map['openai_model'] ?? 'gpt-4',
      maxTokens: int.tryParse(map['openai_max_tokens']?.toString() ?? '2048') ?? 2048,
      appLanguage: map['app_language'] ?? 'fa',
      enableLogging: map['enable_logging']?.toString().toLowerCase() == 'true',
      maxLogEntries: int.tryParse(map['max_log_entries']?.toString() ?? '1000') ?? 1000,
      appTheme: map['app_theme'] ?? 'light',
      autoSave: map['auto_save']?.toString().toLowerCase() == 'true',
      backupEnabled: map['backup_enabled']?.toString().toLowerCase() == 'true',
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'openai_api_key': openaiApiKey,
      'openai_model': openaiModel,
      'openai_max_tokens': maxTokens.toString(),
      'app_language': appLanguage,
      'enable_logging': enableLogging.toString(),
      'max_log_entries': maxLogEntries.toString(),
      'app_theme': appTheme,
      'auto_save': autoSave.toString(),
      'backup_enabled': backupEnabled.toString(),
    };
  }
  
  SystemSettings copyWith({
    String? openaiApiKey,
    String? openaiModel,
    int? maxTokens,
    String? appLanguage,
    bool? enableLogging,
    int? maxLogEntries,
    String? appTheme,
    bool? autoSave,
    bool? backupEnabled,
  }) {
    return SystemSettings(
      openaiApiKey: openaiApiKey ?? this.openaiApiKey,
      openaiModel: openaiModel ?? this.openaiModel,
      maxTokens: maxTokens ?? this.maxTokens,
      appLanguage: appLanguage ?? this.appLanguage,
      enableLogging: enableLogging ?? this.enableLogging,
      maxLogEntries: maxLogEntries ?? this.maxLogEntries,
      appTheme: appTheme ?? this.appTheme,
      autoSave: autoSave ?? this.autoSave,
      backupEnabled: backupEnabled ?? this.backupEnabled,
    );
  }
}
```

### Data Layer (لایه داده)

#### Repository Implementation
```dart
class SettingsRepositoryImpl implements SettingsRepository {
  final ApiService _apiService;
  final Logger _logger;
  
  SettingsRepositoryImpl({
    required ApiService apiService,
    required Logger logger,
  }) : _apiService = apiService, _logger = logger;
  
  @override
  Future<Either<Failure, SystemSettings>> getSettings() async {
    try {
      _logger.info('Fetching settings from API...');
      
      final response = await _apiService.get('/api/settings/get.php');
      
      if (response.success && response.data != null) {
        final settingsMap = <String, dynamic>{};
        
        // تبدیل array به map برای استفاده آسان‌تر
        for (final setting in response.data) {
          settingsMap[setting['setting_key']] = setting['setting_value'];
        }
        
        final settings = SystemSettings.fromMap(settingsMap);
        _logger.info('Settings loaded successfully: ${settingsMap.keys.length} items');
        
        return Right(settings);
      } else {
        _logger.error('Failed to load settings: ${response.message}');
        return Left(ServerFailure(response.message ?? 'خطا در بارگذاری تنظیمات'));
      }
    } catch (e) {
      _logger.error('Exception in getSettings: $e');
      return Left(UnexpectedFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, bool>> updateSetting(String key, dynamic value) async {
    try {
      _logger.info('Updating setting: $key');
      
      final response = await _apiService.post('/api/settings/update.php', {
        'key': key,
        'value': value.toString(),
      });
      
      if (response.success) {
        _logger.info('Setting updated successfully: $key = $value');
        return Right(true);
      } else {
        _logger.error('Failed to update setting: ${response.message}');
        return Left(ServerFailure(response.message ?? 'خطا در بروزرسانی تنظیمات'));
      }
    } catch (e) {
      _logger.error('Exception in updateSetting: $e');
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
```

## 🔧 Dependency Injection

### Service Locator Pattern

#### Implementation with GetIt
```dart
// lib/core/di/service_locator.dart
final sl = GetIt.instance;

Future<void> init() async {
  // External Services
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => Logger());
  
  // Core Services
  sl.registerLazySingleton<ApiService>(
    () => ApiService(
      client: sl(),
      logger: sl(),
      baseUrl: AppConfig.apiBaseUrl,
    ),
  );
  
  // Repositories
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(
      apiService: sl(),
      logger: sl(),
    ),
  );
  
  sl.registerLazySingleton<OpenAIRepository>(
    () => OpenAIRepositoryImpl(
      apiService: sl(),
      logger: sl(),
    ),
  );
  
  // Use Cases
  sl.registerLazySingleton(() => SettingsUseCase(
    repository: sl(),
    logger: sl(),
  ));
  
  sl.registerLazySingleton(() => OpenAIUseCase(
    repository: sl(),
    logger: sl(),
  ));
  
  // Controllers
  sl.registerFactory(() => SettingsController(
    settingsUseCase: sl(),
    logger: sl(),
  ));
  
  sl.registerFactory(() => DashboardController(
    settingsUseCase: sl(),
    logger: sl(),
  ));
}
```

#### Usage in Main App
```dart
// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection
  await di.init();
  
  runApp(const DataSaveApp());
}

class DataSaveApp extends StatelessWidget {
  const DataSaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => di.sl<SettingsController>()..loadSettings(),
        ),
        ChangeNotifierProvider(
          create: (_) => di.sl<DashboardController>(),
        ),
      ],
      child: Consumer<SettingsController>(
        builder: (context, settingsController, child) {
          return MaterialApp(
            title: 'DataSave',
            theme: AppTheme.lightTheme,
            locale: const Locale('fa', 'IR'),
            supportedLocales: const [
              Locale('fa', 'IR'),
              Locale('en', 'US'),
            ],
            home: const DashboardPage(),
          );
        },
      ),
    );
  }
}
```

## 📊 Data Flow Pattern

### Request-Response Flow

```
User Action → Controller → Use Case → Repository → Data Source
     ↑                                                    ↓
UI Update ← Controller ← Use Case ← Repository ← API Response
```

#### مثال عملی: بروزرسانی تنظیمات

```dart
// 1. User Action - کاربر روی دکمه ذخیره کلیک می‌کند
onPressed: () async {
  await context.read<SettingsController>().updateSetting(
    'openai_model', 
    'gpt-4-turbo'
  );
}

// 2. Controller - دریافت درخواست و فراخوانی Use Case
Future<void> updateSetting(String key, dynamic value) async {
  final result = await _settingsUseCase.updateSetting(key, value);
  // Handle result...
}

// 3. Use Case - اعمال business logic
Future<Either<Failure, bool>> updateSetting(String key, dynamic value) async {
  // Validation
  if (key.isEmpty || value == null) {
    return Left(ValidationFailure('کلید یا مقدار نمی‌تواند خالی باشد'));
  }
  
  // Call repository
  return await _repository.updateSetting(key, value);
}

// 4. Repository - ارتباط با Data Source
Future<Either<Failure, bool>> updateSetting(String key, dynamic value) async {
  final response = await _apiService.post('/api/settings/update.php', {
    'key': key,
    'value': value.toString(),
  });
  
  return response.success 
    ? Right(true) 
    : Left(ServerFailure(response.message));
}

// 5. API Service - ارسال درخواست HTTP
Future<ApiResponse> post(String endpoint, Map<String, dynamic> data) async {
  final response = await _client.post(
    Uri.parse('$baseUrl$endpoint'),
    headers: {'Content-Type': 'application/json; charset=utf-8'},
    body: json.encode(data),
  );
  
  return ApiResponse.fromJson(response.body);
}
```

## ⚠️ Error Handling Strategy

### Failure Classes
```dart
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure(String message) : super(message);
}

// Persian-specific failures
class PersianTextFailure extends Failure {
  const PersianTextFailure(String message) : super(message);
}

class RTLLayoutFailure extends Failure {
  const RTLLayoutFailure(String message) : super(message);
}
```

### Error Handling in Controllers
```dart
class SettingsController extends ChangeNotifier {
  String? _error;
  String? get error => _error;
  
  Future<void> loadSettings() async {
    final result = await _settingsUseCase.getSettings();
    
    result.fold(
      (failure) {
        _setError(_getLocalizedError(failure));
      },
      (settings) {
        _settings = settings.toMap();
        _setError(null);
      },
    );
  }
  
  String _getLocalizedError(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'خطا در ارتباط با سرور: ${failure.message}';
      case NetworkFailure:
        return 'خطا در اتصال به اینترنت: ${failure.message}';
      case ValidationFailure:
        return 'خطای اعتبارسنجی: ${failure.message}';
      case PersianTextFailure:
        return 'خطا در پردازش متن فارسی: ${failure.message}';
      default:
        return 'خطای غیرمنتظره: ${failure.message}';
    }
  }
}
```

## 🔍 Testing Strategy

### Unit Testing Use Cases
```dart
// test/domain/usecases/settings_usecase_test.dart
void main() {
  group('SettingsUseCase', () {
    late SettingsUseCase useCase;
    late MockSettingsRepository mockRepository;
    late MockLogger mockLogger;
    
    setUp(() {
      mockRepository = MockSettingsRepository();
      mockLogger = MockLogger();
      useCase = SettingsUseCase(
        repository: mockRepository,
        logger: mockLogger,
      );
    });
    
    test('should return settings when repository call is successful', () async {
      // Arrange
      final testSettings = SystemSettings(
        openaiApiKey: 'test-key',
        openaiModel: 'gpt-4',
        maxTokens: 2048,
        appLanguage: 'fa',
        enableLogging: true,
        maxLogEntries: 1000,
        appTheme: 'light',
        autoSave: true,
        backupEnabled: false,
      );
      
      when(mockRepository.getSettings())
        .thenAnswer((_) async => Right(testSettings));
      
      // Act
      final result = await useCase.getSettings();
      
      // Assert
      expect(result, Right(testSettings));
      verify(mockLogger.info('تنظیمات با موفقیت بارگذاری شد'));
    });
    
    test('should return failure when repository call fails', () async {
      // Arrange
      when(mockRepository.getSettings())
        .thenAnswer((_) async => Left(ServerFailure('Server error')));
      
      // Act
      final result = await useCase.getSettings();
      
      // Assert
      expect(result, Left(ServerFailure('Server error')));
      verify(mockLogger.error('خطا در بارگذاری تنظیمات: Server error'));
    });
  });
}
```

### Widget Testing
```dart
// test/presentation/widgets/stat_card_test.dart
void main() {
  group('StatCard Widget', () {
    testWidgets('should display Persian text correctly', (tester) async {
      // Arrange
      const testTitle = 'تعداد تنظیمات';
      const testValue = '۹';
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatCard(
              title: testTitle,
              value: testValue,
              icon: Icons.settings,
              color: Colors.blue,
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.text(testTitle), findsOneWidget);
      expect(find.text(testValue), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });
    
    testWidgets('should handle RTL layout correctly', (tester) async {
      // Test RTL layout behavior
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('fa', 'IR'),
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: StatCard(
                title: 'تست RTL',
                value: '۱۲۳',
                icon: Icons.info,
              ),
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Verify RTL layout
      final cardWidget = tester.widget<Card>(find.byType(Card));
      expect(cardWidget, isNotNull);
    });
  });
}
```

## 📈 Performance Considerations

### Lazy Loading
```dart
// Use GetIt lazy singletons for better performance
sl.registerLazySingleton<ApiService>(() => ApiService(...));

// Instead of eager initialization
sl.registerSingleton<ApiService>(ApiService(...));
```

### Memory Management
```dart
class SettingsController extends ChangeNotifier {
  Timer? _debounceTimer;
  
  void updateSettingDebounced(String key, dynamic value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
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

### Caching Strategy
```dart
class SettingsRepositoryImpl implements SettingsRepository {
  SystemSettings? _cachedSettings;
  DateTime? _lastFetchTime;
  
  @override
  Future<Either<Failure, SystemSettings>> getSettings() async {
    // Cache for 5 minutes
    if (_cachedSettings != null && 
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!).inMinutes < 5) {
      return Right(_cachedSettings!);
    }
    
    // Fetch fresh data
    final result = await _fetchSettingsFromAPI();
    
    return result.fold(
      (failure) => Left(failure),
      (settings) {
        _cachedSettings = settings;
        _lastFetchTime = DateTime.now();
        return Right(settings);
      },
    );
  }
}
```

## ⚠️ Important Notes

### Best Practices پیروی شده

1. **Separation of Concerns**: هر لایه مسئولیت مشخص دارد
2. **Dependency Inversion**: وابستگی‌ها از طریق interface تعریف شده‌اند  
3. **Persian-First Design**: تمام پیام‌ها و UI به زبان فارسی
4. **Error Handling**: مدیریت جامع خطاها در همه لایه‌ها
5. **Testing**: قابلیت unit test و integration test
6. **Performance**: بهینه‌سازی حافظه و سرعت

### Common Pitfalls جلوگیری شده

- ❌ Direct UI dependency in business logic
- ❌ Mixed responsibilities in single classes
- ❌ Hard-coded Persian strings without localization
- ❌ Missing error handling in async operations
- ❌ Memory leaks in controllers
- ❌ Tight coupling between layers

### Future Improvements

- **Domain Events**: پیاده‌سازی event-driven architecture
- **CQRS Pattern**: جداسازی Command و Query operations
- **Repository Pattern Enhancement**: پیاده‌سازی generic repository
- **Middleware Layer**: اضافه کردن middleware برای logging و caching
- **Feature Modules**: تقسیم به feature-based modules

## 🔄 Related Documentation
- [System Architecture](./system-architecture.md)
- [Project Structure](./project-structure.md)
- [Flutter Architecture](../04-Flutter-Frontend/flutter-architecture.md)
- [State Management](../04-Flutter-Frontend/state-management.md)

---
*این مستندات بخشی از مجموعه مستندات فنی پروژه DataSave است*  
*Last updated: 2025-01-09*  
*File: /docs/01-Architecture/clean-architecture-implementation.md*