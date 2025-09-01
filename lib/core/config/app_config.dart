class AppConfig {
  // تعیین محیط برنامه
  static const bool isProduction = false;
  static const String environment = isProduction ? 'production' : 'development';
  
  // تنظیمات پایگاه داده
  static const String dbHost = 'localhost';
  static const String dbName = 'datasave_db';
  static const String dbUser = 'root';
  static const String dbPassword = '';
  static const int dbPort = 3306;
  
  // تنظیمات API
  static String get apiBaseUrl {
    return isProduction 
        ? 'https://api.datasave.ir'
        : 'http://localhost:8080';
  }
  
  // تنظیمات دیباگ
  static const bool enableLogging = !isProduction;
  static const bool enableDebugMode = !isProduction;
}
