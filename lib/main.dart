import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'presentation/pages/home/home_page.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const DataSaveApp());
}

class DataSaveApp extends StatelessWidget {
  const DataSaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      
      // صفحه اصلی
      home: const HomePage(),
    );
  }
}
