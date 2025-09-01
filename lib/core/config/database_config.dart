/// پیکربندی اتصال به پایگاه داده MySQL
/// 
/// این کلاس شامل تمام تنظیمات لازم برای اتصال به دیتابیس MySQL در XAMPP است.
/// تنظیمات شامل آدرس سرور، پورت، نام دیتابیس، نام کاربری و رمز عبور می‌باشد.
class DatabaseConfig {
  /// آدرس سرور MySQL - برای XAMPP محلی از localhost استفاده می‌کنیم
  static const String host = 'localhost';
  
  /// پورت اتصال MySQL - XAMPP از پورت 3307 استفاده می‌کند
  static const int port = 3307;
  
  /// نام دیتابیس اصلی پروژه DataSave
  static const String database = 'datasave_db';
  
  /// نام کاربری برای اتصال به MySQL
  static const String username = 'root';
  
  /// رمز عبور کاربر root در XAMPP
  static const String password = 'Mojtab@123';
  
  /// تنظیم character set برای پشتیبانی کامل از زبان فارسی
  static const String charset = 'utf8mb4';
  
  /// حداکثر تعداد اتصالات همزمان در Connection Pool
  static const int maxConnections = 5;
  
  /// زمان انتظار برای برقراری اتصال (30 ثانیه)
  static const Duration connectionTimeout = Duration(seconds: 30);
  
  /// زمان انتظار برای اجرای کوئری‌ها
  static const Duration queryTimeout = Duration(seconds: 60);
  
  /// آیا اتصال SSL فعال باشد (برای محیط توسعه false)
  static const bool useSSL = false;
}
