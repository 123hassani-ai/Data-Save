class AppConstants {
  // اطلاعات کلی برنامه
  static const String appName = 'DataSave';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'پلتفرم هوشمند فرم‌ساز';
  
  // آدرس‌های API
  static const String baseUrl = 'https://api.datasave.ir';
  static const String apiVersion = '/api/v1';
  
  // تنظیمات پیش‌فرض
  static const int defaultTimeout = 30000; // 30 ثانیه
  static const int maxFileSize = 10 * 1024 * 1024; // 10 مگابایت
  
  // کلیدهای ذخیره‌سازی محلی
  static const String keyUserToken = 'user_token';
  static const String keyUserData = 'user_data';
  static const String keySettings = 'app_settings';
  
  // پیام‌های خطای رایج
  static const String errorNetworkConnection = 'خطا در اتصال به اینترنت';
  static const String errorServerError = 'خطا در سرور';
  static const String errorUnknown = 'خطای نامشخص';
}
