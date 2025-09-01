import 'package:flutter/material.dart';
import '../pages/home/home_page.dart';
import '../pages/test_font_page.dart';
import '../pages/settings/settings_page.dart';
import '../pages/logs/logs_page.dart';
import '../pages/form_builder/form_builder_page.dart';

class AppRoutes {
  // مسیرهای اصلی برنامه - Main application routes
  static const String home = '/';
  static const String testFont = '/test-font';
  static const String settings = '/settings';
  static const String logs = '/logs';
  static const String formBuilder = '/form-builder';
  static const String formList = '/forms';
  static const String analytics = '/analytics';
  static const String about = '/about';
  
  // نقشه مسیرهای برنامه - Application routes map
  static Map<String, WidgetBuilder> get routes {
    return {
      home: (context) => const HomePage(),
      settings: (context) => const SettingsPage(),
      logs: (context) => const LogsPage(),
      // سایر مسیرها در مراحل بعدی اضافه خواهند شد
      // Other routes will be added in future phases
    };
  }

  /// تولید مسیر - Generate route
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case testFont:
        return MaterialPageRoute(builder: (_) => const TestFontPage());
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      case AppRoutes.logs:
        return MaterialPageRoute(builder: (_) => const LogsPage());
      case formBuilder:
        // پارامترها از arguments دریافت می‌شود
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => FormBuilderPage(
            formId: args?['formId'] as int?,
            userId: args?['userId'] as int? ?? 1, // پیش‌فرض
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('صفحه یافت نشد!'),
            ),
          ),
        );
    }
  }
}

/// کلاس کمکی برای navigation - Navigation helper class
class NavigationHelper {
  /// رفتن به صفحه تنظیمات - Navigate to settings page
  static void navigateToSettings(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.settings);
  }
  
  /// رفتن به صفحه لاگ‌ها - Navigate to logs page
  static void navigateToLogs(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.logs);
  }
  
  /// رفتن به صفحه اصلی - Navigate to home page
  static void navigateHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context, 
      AppRoutes.home, 
      (route) => false
    );
  }

  /// بازگشت به صفحه قبل - Go back to previous page
  static void goBack(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      navigateHome(context);
    }
  }

  /// نمایش about dialog - Show about dialog
  static void showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AboutDialog(
        applicationName: 'DataSave',
        applicationVersion: '1.0.0',
        applicationLegalese: '© 2024 DataSave. تمامی حقوق محفوظ است.',
        children: const [
          Text(
            'سیستم مدیریت داده‌های پیشرفته با قابلیت‌های هوش مصنوعی\n\n'
            'ویژگی‌ها:\n'
            '• داشبورد پیشرفته\n'
            '• سیستم لاگینگ حرفه‌ای\n'
            '• تنظیمات کامل OpenAI\n'
            '• رابط کاربری RTL فارسی\n'
            '• طراحی ریسپانسیو',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
