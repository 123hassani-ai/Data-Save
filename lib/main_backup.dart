import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'presentation/controllers/settings_controller.dart';
import 'presentation/controllers/logs_controller.dart';
import 'core/providers/form_builder_provider.dart';
import 'core/providers/widget_library_provider.dart';
import 'core/providers/form_list_provider.dart';
import 'presentation/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/logger/logger_service.dart';
import 'core/services/api_service.dart';

void main() async {
  // اطمینان از راه‌اندازی Flutter
  WidgetsFlutterBinding.ensureInitialized();
  
  // راه‌اندازی Logger
  LoggerService.initialize();
  
  print('🚀 شروع راه‌اندازی DataSave - PHP Backend');
  LoggerService.info('System', 'شروع راه‌اندازی DataSave - فرم‌ساز هوشمند');
  
  // تست اتصال Backend PHP
  try {
    LoggerService.info('System', 'شروع تست اتصال Backend PHP');
    final connectionTest = await ApiService.testConnection();
    
    if (connectionTest['success'] == true) {
      LoggerService.info('Backend', 'اتصال Backend PHP با موفقیت برقرار شد ✅');
      print('✅ Backend PHP متصل است');
    } else {
      LoggerService.warning('Backend', 'Backend PHP در دسترس نیست - احتمالاً XAMPP خاموش است');
      print('⚠️ Backend PHP در دسترس نیست');
    }
  } catch (e) {
    LoggerService.error('Backend', 'خطا در تست اتصال Backend PHP', e);
    print('❌ خطا در اتصال Backend: $e');
  }
  
  LoggerService.info('System', 'راه‌اندازی کامل - شروع برنامه');
  runApp(const DataSaveApp());
}

class DataSaveApp extends StatelessWidget {
  const DataSaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsController()),
        ChangeNotifierProvider(create: (_) => LogsController()),
        ChangeNotifierProvider(create: (_) => FormBuilderProvider()),
        ChangeNotifierProvider(create: (_) => WidgetLibraryProvider()),
        ChangeNotifierProvider(create: (_) => FormListProvider()),
      ],
      child: MaterialApp(
        title: 'DataSave - فرم‌ساز هوشمند',
        debugShowCheckedModeBanner: false,
        
        // پشتیبانی از زبان فارسی و RTL
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('fa', 'IR')],
        
        // اعمال تم سفارشی با فونت Vazirmatn
        theme: AppTheme.lightTheme,
        
        // تنظیم مسیرها
        initialRoute: AppRoutes.home,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}
