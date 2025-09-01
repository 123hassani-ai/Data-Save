import 'package:flutter/material.dart';
import '../pages/home/home_page.dart';

class AppRoutes {
  // مسیرهای اصلی برنامه
  static const String home = '/';
  static const String formBuilder = '/form-builder';
  static const String formList = '/forms';
  static const String analytics = '/analytics';
  static const String settings = '/settings';
  
  // نقشه مسیرهای برنامه
  static Map<String, WidgetBuilder> get routes {
    return {
      home: (context) => const HomePage(),
      // سایر مسیرها در مراحل بعدی اضافه خواهند شد
    };
  }
}
