# معماری Flutter - Flutter Architecture

## 📊 Document Information
- **Created:** 2025-01-09
- **Last Updated:** 2025-01-09
- **Version:** 1.0
- **Maintainer:** DataSave Development Team
- **Related Files:** `/lib/`, `/pubspec.yaml`, `/lib/main.dart`

## 🎯 Overview
معماری کامل Frontend Flutter در DataSave بر اساس Clean Architecture با تمرکز بر Persian RTL support و Material Design 3.

## 📋 Table of Contents
- [فلسفه معماری Flutter](#فلسفه-معماری-flutter)
- [ساختار فایل‌ها](#ساختار-فایلها)
- [Presentation Layer](#presentation-layer)
- [Core Layer](#core-layer)
- [State Management](#state-management)
- [Persian RTL Implementation](#persian-rtl-implementation)

## 🏗️ فلسفه معماری Flutter - Flutter Architecture Philosophy

### Clean Architecture در Flutter
```yaml
Architecture Pattern: Clean Architecture
Layers:
  - Presentation: UI Components & State Management
  - Domain: Business Logic (Future)
  - Data: API Services & Local Storage
  - Core: Configuration & Utilities

Benefits:
  - Testable and maintainable code
  - Clear separation of concerns
  - Independent of UI framework
  - Independent of external services
```

### Persian-First Flutter Design
```yaml
RTL Support:
  - Complete right-to-left layout
  - Vazirmatn Persian font family
  - Persian number formatting
  - Persian date/time handling
  - Contextual text direction

Material Design 3:
  - Dynamic color system
  - Updated typography scale
  - Enhanced accessibility
  - Modern component design
```

## 📁 ساختار فایل‌ها - File Structure

### Project Structure Overview
```
lib/
├── 📁 core/                          # هسته مرکزی سیستم
│   ├── 📁 config/                    # پیکربندی‌ها
│   │   ├── 📄 app_config.dart
│   │   └── 📄 database_config.dart
│   ├── 📁 constants/                 # ثابت‌های سیستم
│   │   └── 📄 app_constants.dart
│   ├── 📁 logger/                    # سیستم لاگینگ
│   │   └── 📄 logger_service.dart
│   ├── 📁 models/                    # مدل‌های داده
│   │   └── 📄 chat_message.dart
│   ├── 📁 services/                  # سرویس‌های خارجی
│   │   ├── 📄 api_service.dart
│   │   └── 📄 openai_service.dart
│   ├── 📁 theme/                     # تم و ظاهر
│   │   ├── 📄 app_theme.dart
│   │   └── 📄 persian_fonts.dart
│   └── 📁 utils/                     # ابزارها
│
├── 📁 presentation/                  # لایه نمایش
│   ├── 📁 controllers/               # کنترلرهای state
│   │   ├── 📄 settings_controller.dart
│   │   └── 📄 logs_controller.dart
│   ├── 📁 pages/                     # صفحات برنامه
│   │   ├── 📁 home/
│   │   ├── 📁 settings/
│   │   └── 📁 logs/
│   ├── 📁 routes/                    # مسیریابی
│   │   └── 📄 app_routes.dart
│   └── 📁 widgets/                   # کامپوننت‌های UI
│       ├── 📁 shared/                # ویجت‌های مشترک
│       └── 📁 chat/                  # ویجت‌های چت
│
├── 📁 widgets/                       # ویجت‌های سفارشی
│   └── 📄 font_test_widget.dart
│
└── 📄 main.dart                      # نقطه ورود برنامه
```

### File Naming Conventions
```yaml
Convention Rules:
  - snake_case for all Dart files
  - PascalCase for class names
  - camelCase for variables and methods
  - Persian comments for complex logic
  - English naming for technical terms

Examples:
  - settings_controller.dart
  - SettingsController (class)
  - loadSettings() (method)
  - _isLoading (private variable)
```

## 🎨 Presentation Layer

### Pages Architecture
```dart
// Base Page Structure
abstract class BasePage extends StatefulWidget {
  const BasePage({super.key});
}

// Page Implementation Example
class SettingsPage extends BasePage {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsController>(
      builder: (context, controller, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('تنظیمات'),
          ),
          body: _buildBody(controller),
        );
      },
    );
  }
}
```

### Controllers (State Management)
```dart
// Settings Controller Example
class SettingsController with ChangeNotifier {
  // Private state variables
  String _openaiApiKey = '';
  bool _isLoading = false;
  String? _error;
  
  // Public getters
  String get openaiApiKey => _openaiApiKey;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Business methods
  Future<void> loadSettings() async {
    _setLoading(true);
    try {
      final settings = await ApiService.getSettings();
      _updateSettingsFromApi(settings);
      _error = null;
    } catch (e) {
      _error = 'خطا در بارگذاری تنظیمات: ${e.toString()}';
      LoggerService.error('SettingsController', _error!);
    } finally {
      _setLoading(false);
    }
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
```

### Widget Architecture
```dart
// Shared Widget Example - StatCard
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = color ?? theme.colorScheme.primary;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                cardColor.withOpacity(0.1),
                cardColor.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 32, color: cardColor),
              const SizedBox(height: 8),
              Text(title, style: theme.textTheme.bodySmall),
              Text(value, style: theme.textTheme.headlineSmall),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Routing System
```dart
// App Routes Configuration
class AppRoutes {
  static const String home = '/';
  static const String settings = '/settings';
  static const String logs = '/logs';
  static const String chat = '/chat';

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
          settings: settings,
        );
      case AppRoutes.settings:
        return MaterialPageRoute(
          builder: (_) => const SettingsPage(),
          settings: settings,
        );
      case logs:
        return MaterialPageRoute(
          builder: (_) => const LogsPage(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const NotFoundPage(),
        );
    }
  }
}
```

## 🔧 Core Layer

### Services Architecture
```dart
// API Service Implementation
class ApiService {
  static const String _baseUrl = 'http://localhost/datasave/backend/api';
  
  static Future<List<Map<String, dynamic>>> getSettings() async {
    try {
      LoggerService.info('ApiService', 'درخواست دریافت تنظیمات');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/settings/get.php'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['success'] == true) {
          return List<Map<String, dynamic>>.from(result['data']);
        } else {
          throw ApiException(result['message'] ?? 'خطای نامشخص');
        }
      } else {
        throw ApiException('خطای HTTP: ${response.statusCode}');
      }
    } catch (e) {
      LoggerService.error('ApiService', 'خطا در getSettings: $e');
      rethrow;
    }
  }

  static Future<bool> updateSetting(String key, String value) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/settings/update.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'setting_key': key,
          'setting_value': value,
        }),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return result['success'] == true;
      }
      return false;
    } catch (e) {
      LoggerService.error('ApiService', 'خطا در updateSetting: $e');
      return false;
    }
  }
}
```

### Logger Service
```dart
// Logger Service Implementation
class LoggerService {
  static bool _enableConsoleLog = true;
  static bool _enableFileLog = false;
  
  static void initialize() {
    print('🚀 LoggerService initialized');
  }

  static void info(String category, String message) {
    _log('INFO', category, message);
  }

  static void error(String category, String message, [dynamic error]) {
    _log('ERROR', category, message, error);
  }

  static void warning(String category, String message) {
    _log('WARNING', category, message);
  }

  static void debug(String category, String message) {
    _log('DEBUG', category, message);
  }

  static void _log(String level, String category, String message, [dynamic error]) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] [$level] [$category] $message';
    
    if (error != null) {
      print('$logMessage - Error: $error');
    } else {
      print(logMessage);
    }

    // Send to backend if needed
    _sendToBackend(level, category, message);
  }

  static Future<void> _sendToBackend(String level, String category, String message) async {
    // Implementation for sending logs to backend
  }
}
```

### Configuration Management
```dart
// App Configuration
class AppConfig {
  static const String appName = 'DataSave';
  static const String appVersion = '1.0.0';
  static const bool isDebug = true;
  
  // API Configuration
  static const String apiBaseUrl = 'http://localhost/datasave/backend/api';
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // UI Configuration
  static const String defaultLanguage = 'fa';
  static const String defaultTheme = 'light';
  
  // Logging Configuration
  static const bool enableLogging = true;
  static const String logLevel = 'DEBUG';
}
```

## 📱 State Management

### Provider Pattern Implementation
```dart
// Main App with Providers
class DataSaveApp extends StatelessWidget {
  const DataSaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsController()),
        ChangeNotifierProvider(create: (_) => LogsController()),
        ChangeNotifierProvider(create: (_) => ChatController()),
      ],
      child: Consumer<SettingsController>(
        builder: (context, settingsController, child) {
          return MaterialApp(
            title: 'DataSave - فرم‌ساز هوشمند',
            debugShowCheckedModeBanner: false,
            
            // Localization
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('fa', 'IR')],
            
            // Theme
            theme: AppTheme.lightTheme,
            
            // Navigation
            initialRoute: AppRoutes.home,
            onGenerateRoute: AppRoutes.generateRoute,
          );
        },
      ),
    );
  }
}
```

### State Management Patterns
```dart
// Controller Base Class
abstract class BaseController extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

// Logs Controller Example
class LogsController extends BaseController {
  List<Map<String, dynamic>> _logs = [];
  Map<String, dynamic>? _stats;

  List<Map<String, dynamic>> get logs => _logs;
  Map<String, dynamic>? get stats => _stats;

  Future<void> loadLogs({int limit = 20}) async {
    setLoading(true);
    try {
      _logs = await ApiService.getLogs(limit: limit) ?? [];
      clearError();
    } catch (e) {
      setError('خطا در بارگذاری لاگ‌ها: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  Future<void> loadStats() async {
    try {
      _stats = await ApiService.getLogStats();
      notifyListeners();
    } catch (e) {
      LoggerService.error('LogsController', 'خطا در بارگذاری آمار: $e');
    }
  }
}
```

### Widget State Management
```dart
// Using Consumer for State Listening
class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تنظیمات')),
      body: Consumer<SettingsController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (controller.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    controller.error!,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: controller.loadSettings,
                    child: const Text('تلاش مجدد'),
                  ),
                ],
              ),
            );
          }

          return _buildSettingsForm(context, controller);
        },
      ),
    );
  }
}
```

## 🇮🇷 Persian RTL Implementation

### Theme Configuration for Persian
```dart
// Persian Theme Implementation
class AppTheme {
  static const String fontFamily = 'Vazirmatn';
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      
      // Persian font for entire app
      fontFamily: fontFamily,
      
      // RTL text theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w300,
          fontSize: 57,
          height: 1.12,
        ),
        headlineLarge: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w400,
          fontSize: 32,
          height: 1.25,
        ),
        titleLarge: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w400,
          fontSize: 22,
          height: 1.27,
        ),
        bodyLarge: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w400,
          fontSize: 16,
          height: 1.5,
        ),
      ),
      
      // App Bar with Persian font
      appBarTheme: const AppBarTheme(
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 22,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      // Input decoration for Persian
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: const TextStyle(fontFamily: fontFamily),
        hintStyle: const TextStyle(fontFamily: fontFamily),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
```

### Persian Font Configuration
```dart
// Persian Fonts Definition
class PersianFonts {
  static const String _fontFamily = 'Vazirmatn';
  
  static const TextStyle displayLarge = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w300,
    fontSize: 57,
    height: 1.12,
    letterSpacing: -0.25,
  );
  
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 32,
    height: 1.25,
  );
  
  static const TextStyle titleLarge = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 22,
    height: 1.27,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 1.5,
    letterSpacing: 0.15,
  );
}
```

### RTL Layout Handling
```dart
// Directional Widget Usage
class PersianLayout extends StatelessWidget {
  final Widget child;
  
  const PersianLayout({super.key, required this.child});
  
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: child,
    );
  }
}

// Usage in main app
class DataSaveApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Force RTL for entire app
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? Container(),
        );
      },
      
      // Persian locale
      locale: const Locale('fa', 'IR'),
      supportedLocales: const [Locale('fa', 'IR')],
      
      // Localization delegates
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
```

### Persian Number Formatting
```dart
// Persian Number Utilities
class PersianUtils {
  static const Map<String, String> englishToPersian = {
    '0': '۰', '1': '۱', '2': '۲', '3': '۳', '4': '۴',
    '5': '۵', '6': '۶', '7': '۷', '8': '۸', '9': '۹',
  };
  
  static const Map<String, String> persianToEnglish = {
    '۰': '0', '۱': '1', '۲': '2', '۳': '3', '۴': '4',
    '۵': '5', '۶': '6', '۷': '7', '۸': '8', '۹': '9',
  };
  
  static String toPersianNumbers(String input) {
    String result = input;
    englishToPersian.forEach((english, persian) {
      result = result.replaceAll(english, persian);
    });
    return result;
  }
  
  static String toEnglishNumbers(String input) {
    String result = input;
    persianToEnglish.forEach((persian, english) {
      result = result.replaceAll(persian, english);
    });
    return result;
  }
  
  // Format numbers with Persian separators
  static String formatNumber(int number) {
    final formatter = NumberFormat('#,###', 'fa');
    return toPersianNumbers(formatter.format(number));
  }
}

// Usage in widgets
Text(
  PersianUtils.formatNumber(1234567), // نمایش: ۱,۲۳۴,۵۶۷
  style: Theme.of(context).textTheme.headlineMedium,
)
```

## 📊 Performance Optimization

### Widget Optimization
```dart
// Efficient StatCard with const constructor
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: _buildCardContent(context),
      ),
    );
  }
  
  Widget _buildCardContent(BuildContext context) {
    // Separate build method for optimization
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(title),
          Text(value),
        ],
      ),
    );
  }
}
```

### State Management Optimization
```dart
// Selective rebuild with Selector
class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Only rebuild when isLoading changes
          Selector<SettingsController, bool>(
            selector: (_, controller) => controller.isLoading,
            builder: (context, isLoading, child) {
              return isLoading 
                ? const LinearProgressIndicator()
                : const SizedBox.shrink();
            },
          ),
          
          // Only rebuild when specific setting changes
          Selector<SettingsController, String>(
            selector: (_, controller) => controller.openaiApiKey,
            builder: (context, apiKey, child) {
              return TextFormField(
                initialValue: apiKey,
                decoration: const InputDecoration(
                  labelText: 'کلید API OpenAI',
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
```

## ⚠️ Important Notes

### Development Best Practices
1. **Persian-First**: همه UI اول برای فارسی طراحی شود
2. **State Management**: از Provider به جای setState استفاده کنید
3. **Error Handling**: همه خطاها به فارسی نمایش داده شوند
4. **Performance**: از const constructors استفاده کنید
5. **Testing**: همه ویجت‌ها باید قابل تست باشند

### Current Limitations
- **No Domain Layer**: Business logic در controllers است
- **Basic Error Handling**: نیاز به بهبود دارد
- **No Offline Support**: همه داده‌ها از API می‌آید
- **Limited Testing**: فقط manual testing انجام شده

### Future Enhancements
- **Domain Layer**: جداسازی business logic
- **Repository Pattern**: abstraction برای data access
- **Offline Support**: caching و offline capabilities
- **Automated Testing**: unit و widget tests

## 🔄 Related Documentation
- [State Management](./state-management.md)
- [UI Components Library](./ui-components-library.md)
- [Persian RTL Implementation](./persian-rtl-implementation.md)
- [System Architecture](../01-Architecture/system-architecture.md)

---
*Last updated: 2025-01-09*  
*File: /docs/04-Flutter-Frontend/flutter-architecture.md*
