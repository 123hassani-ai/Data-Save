import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../core/logger/logger_service.dart';

/// کنترلر تنظیمات - برای مدیریت وضعیت تنظیمات
/// Settings controller for managing settings state
class SettingsController extends ChangeNotifier {
  // وضعیت‌های تنظیمات - Settings states
  final Map<String, String> _settings = {};
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;
  String? _successMessage;
  bool _showApiKey = false;

  // Getters
  Map<String, String> get settings => _settings;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;
  String? get successMessage => _successMessage;
  bool get showApiKey => _showApiKey;

  // تنظیمات خاص - Specific settings
  String get openaiApiKey => _settings['openai_api_key'] ?? '';
  String get openaiModel => _settings['openai_model'] ?? 'gpt-4';
  int get openaiMaxTokens => int.tryParse(_settings['openai_max_tokens'] ?? '2048') ?? 2048;
  double get openaiTemperature => double.tryParse(_settings['openai_temperature'] ?? '0.7') ?? 0.7;
  String get appLanguage => _settings['app_language'] ?? 'fa';
  String get appTheme => _settings['app_theme'] ?? 'light';
  bool get enableLogging => _settings['enable_logging'] == 'true';
  int get maxLogEntries => int.tryParse(_settings['max_log_entries'] ?? '1000') ?? 1000;
  bool get autoSave => _settings['auto_save'] == 'true';
  bool get backupEnabled => _settings['backup_enabled'] == 'true';

  /// بارگذاری تنظیمات از سرور - Load settings from server
  Future<void> loadSettings() async {
    _setLoading(true);
    _clearMessages();
    
    try {
      LoggerService.info('SettingsController', 'شروع بارگذاری تنظیمات - Starting to load settings');
      
      final settingsList = await ApiService.getSettings();
      
      // تبدیل لیست به نقشه - Convert list to map
      _settings.clear();
      for (final setting in settingsList) {
        _settings[setting['setting_key']] = setting['setting_value']?.toString() ?? '';
      }
      
      LoggerService.info('SettingsController', 
          'تنظیمات بارگذاری شد - Settings loaded: ${_settings.length} items');
      
      notifyListeners();
    } catch (e) {
      _error = 'خطا در بارگذاری تنظیمات - Error loading settings: $e';
      LoggerService.error('SettingsController', 'خطا در بارگذاری تنظیمات', e);
    } finally {
      _setLoading(false);
    }
  }

  /// بروزرسانی یک تنظیم - Update single setting
  Future<bool> updateSetting(String key, String value) async {
    try {
      LoggerService.info('SettingsController', 'بروزرسانی تنظیم - Updating setting: $key');
      
      final success = await ApiService.updateSetting(key, value);
      
      if (success) {
        _settings[key] = value;
        _successMessage = 'تنظیم با موفقیت بروزرسانی شد - Setting updated successfully';
        LoggerService.info('SettingsController', 'تنظیم بروزرسانی شد - Setting updated: $key = $value');
      } else {
        _error = 'خطا در بروزرسانی تنظیم - Error updating setting';
        LoggerService.error('SettingsController', 'خطا در بروزرسانی تنظیم', 'Failed to update $key');
      }
      
      notifyListeners();
      return success;
    } catch (e) {
      _error = 'خطا در بروزرسانی تنظیم - Error updating setting: $e';
      LoggerService.error('SettingsController', 'خطا در بروزرسانی تنظیم', e);
      notifyListeners();
      return false;
    }
  }

  /// ذخیره همه تنظیمات - Save all settings
  Future<bool> saveAllSettings() async {
    _setSaving(true);
    _clearMessages();
    
    try {
      LoggerService.info('SettingsController', 'شروع ذخیره همه تنظیمات - Starting to save all settings');
      
      final success = await ApiService.updateMultipleSettings(_settings);
      
      if (success) {
        _successMessage = 'همه تنظیمات با موفقیت ذخیره شد - All settings saved successfully';
        LoggerService.info('SettingsController', 'همه تنظیمات ذخیره شد - All settings saved');
      } else {
        _error = 'خطا در ذخیره تنظیمات - Error saving settings';
        LoggerService.error('SettingsController', 'خطا در ذخیره تنظیمات', 'Failed to save some settings');
      }
      
      notifyListeners();
      return success;
    } catch (e) {
      _error = 'خطا در ذخیره تنظیمات - Error saving settings: $e';
      LoggerService.error('SettingsController', 'خطا در ذخیره تنظیمات', e);
      notifyListeners();
      return false;
    } finally {
      _setSaving(false);
    }
  }

  /// تست اتصال OpenAI - Test OpenAI connection
  Future<bool> testOpenAIConnection() async {
    _clearMessages();
    
    try {
      LoggerService.info('SettingsController', 'شروع تست اتصال OpenAI - Starting OpenAI connection test');
      
      final result = await ApiService.testOpenAIConnection(openaiApiKey);
      
      if (result['success']) {
        _successMessage = result['message'];
        LoggerService.info('SettingsController', 'تست اتصال OpenAI موفق - OpenAI connection test successful');
      } else {
        _error = result['message'];
        LoggerService.warning('SettingsController', 'تست اتصال OpenAI ناموفق - OpenAI connection test failed');
      }
      
      notifyListeners();
      return result['success'];
    } catch (e) {
      _error = 'خطا در تست اتصال OpenAI - Error testing OpenAI connection: $e';
      LoggerService.error('SettingsController', 'خطا در تست اتصال OpenAI', e);
      notifyListeners();
      return false;
    }
  }

  /// بازگردانی تنظیمات پیش‌فرض - Reset to default settings
  Future<bool> resetToDefaults() async {
    _clearMessages();
    
    try {
      LoggerService.info('SettingsController', 'بازگردانی تنظیمات پیش‌فرض - Resetting to default settings');
      
      final defaultSettings = {
        'openai_api_key': '',
        'openai_model': 'gpt-4',
        'openai_max_tokens': '2048',
        'openai_temperature': '0.7',
        'app_language': 'fa',
        'app_theme': 'light',
        'enable_logging': 'true',
        'max_log_entries': '1000',
        'auto_save': 'true',
        'backup_enabled': 'false',
      };
      
      final success = await ApiService.updateMultipleSettings(defaultSettings);
      
      if (success) {
        _settings.addAll(defaultSettings);
        _successMessage = 'تنظیمات به حالت پیش‌فرض بازگردانده شد - Settings reset to defaults';
        LoggerService.info('SettingsController', 'تنظیمات پیش‌فرض بازگردانده شد - Default settings restored');
      } else {
        _error = 'خطا در بازگردانی تنظیمات - Error resetting settings';
      }
      
      notifyListeners();
      return success;
    } catch (e) {
      _error = 'خطا در بازگردانی تنظیمات - Error resetting settings: $e';
      LoggerService.error('SettingsController', 'خطا در بازگردانی تنظیمات', e);
      notifyListeners();
      return false;
    }
  }

  /// تغییر نمایش کلید API - Toggle API key visibility
  void toggleApiKeyVisibility() {
    _showApiKey = !_showApiKey;
    notifyListeners();
  }

  /// پاکسازی پیام‌ها - Clear messages
  void clearMessages() {
    _clearMessages();
    notifyListeners();
  }

  /// متدهای کمکی خصوصی - Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) {
      _error = null;
      _successMessage = null;
    }
  }

  void _setSaving(bool saving) {
    _isSaving = saving;
    if (saving) {
      _error = null;
      _successMessage = null;
    }
  }

  void _clearMessages() {
    _error = null;
    _successMessage = null;
  }

  /// تولید فایل صادراتی تنظیمات - Generate settings export file
  Map<String, dynamic> exportSettings() {
    LoggerService.info('SettingsController', 'صادرات تنظیمات - Exporting settings');
    
    return {
      'export_date': DateTime.now().toIso8601String(),
      'settings': Map<String, String>.from(_settings),
      'version': '1.0.0',
    };
  }

  /// وارد کردن تنظیمات از فایل - Import settings from file
  Future<bool> importSettings(Map<String, dynamic> importData) async {
    try {
      LoggerService.info('SettingsController', 'وارد کردن تنظیمات - Importing settings');
      
      if (importData['settings'] != null) {
        final newSettings = Map<String, String>.from(importData['settings']);
        final success = await ApiService.updateMultipleSettings(newSettings);
        
        if (success) {
          _settings.addAll(newSettings);
          _successMessage = 'تنظیمات با موفقیت وارد شد - Settings imported successfully';
          notifyListeners();
        }
        
        return success;
      }
      
      return false;
    } catch (e) {
      _error = 'خطا در وارد کردن تنظیمات - Error importing settings: $e';
      LoggerService.error('SettingsController', 'خطا در وارد کردن تنظیمات', e);
      notifyListeners();
      return false;
    }
  }
}
