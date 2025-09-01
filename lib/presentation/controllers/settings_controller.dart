import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../core/logger/logger_service.dart';

/// کنترلر مدیریت تنظیمات - Settings management controller
class SettingsController with ChangeNotifier {
  // تنظیمات OpenAI API
  String _openaiApiKey = '';
  String _openaiModel = 'gpt-3.5-turbo';
  double _temperature = 0.7;
  int _maxTokens = 1000;
  double _topP = 1.0;
  double _presencePenalty = 0.0;
  double _frequencyPenalty = 0.0;
  
  // تنظیمات عمومی سیستم
  String _appLanguage = 'fa';
  String _appTheme = 'light';
  bool _autoSave = true;
  bool _enableNotifications = true;
  int _logLevel = 1;
  
  // وضعیت‌های لودینگ
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isTestingApi = false;
  
  // وضعیت تست API
  bool _apiTestResult = false;
  String _apiTestMessage = '';

  // Getters
  String get openaiApiKey => _openaiApiKey;
  String get openaiModel => _openaiModel;
  double get temperature => _temperature;
  int get maxTokens => _maxTokens;
  double get topP => _topP;
  double get presencePenalty => _presencePenalty;
  double get frequencyPenalty => _frequencyPenalty;
  String get appLanguage => _appLanguage;
  String get appTheme => _appTheme;
  bool get autoSave => _autoSave;
  bool get enableNotifications => _enableNotifications;
  int get logLevel => _logLevel;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isTestingApi => _isTestingApi;
  bool get apiTestResult => _apiTestResult;
  String get apiTestMessage => _apiTestMessage;

  /// بارگذاری تنظیمات از سرور - Load settings from server
  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      LoggerService.info('SettingsController', 'شروع بارگذاری تنظیمات - Loading settings');
      
      final settings = await ApiService.getSettings();
      
      for (final setting in settings) {
        final key = setting['setting_key'];
        final value = setting['setting_value'];
        
        switch (key) {
          case 'openai_api_key':
            _openaiApiKey = value ?? '';
            break;
          case 'openai_model':
            _openaiModel = value ?? 'gpt-3.5-turbo';
            break;
          case 'temperature':
            _temperature = double.tryParse(value ?? '0.7') ?? 0.7;
            break;
          case 'max_tokens':
            _maxTokens = int.tryParse(value ?? '1000') ?? 1000;
            break;
          case 'top_p':
            _topP = double.tryParse(value ?? '1.0') ?? 1.0;
            break;
          case 'presence_penalty':
            _presencePenalty = double.tryParse(value ?? '0.0') ?? 0.0;
            break;
          case 'frequency_penalty':
            _frequencyPenalty = double.tryParse(value ?? '0.0') ?? 0.0;
            break;
          case 'app_language':
            _appLanguage = value ?? 'fa';
            break;
          case 'app_theme':
            _appTheme = value ?? 'light';
            break;
          case 'auto_save':
            _autoSave = value == 'true' || value == '1';
            break;
          case 'enable_notifications':
            _enableNotifications = value == 'true' || value == '1';
            break;
          case 'log_level':
            _logLevel = int.tryParse(value ?? '1') ?? 1;
            break;
        }
      }
      
      LoggerService.info('SettingsController', 'تنظیمات با موفقیت بارگذاری شد - Settings loaded successfully');
    } catch (e) {
      LoggerService.error('SettingsController', 'خطا در بارگذاری تنظیمات', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ذخیره تنظیمات در سرور - Save settings to server
  Future<bool> saveSettings() async {
    _isSaving = true;
    notifyListeners();
    
    try {
      LoggerService.info('SettingsController', 'شروع ذخیره تنظیمات - Saving settings');
      
      final settingsToSave = {
        'openai_api_key': _openaiApiKey,
        'openai_model': _openaiModel,
        'temperature': _temperature.toString(),
        'max_tokens': _maxTokens.toString(),
        'top_p': _topP.toString(),
        'presence_penalty': _presencePenalty.toString(),
        'frequency_penalty': _frequencyPenalty.toString(),
        'app_language': _appLanguage,
        'app_theme': _appTheme,
        'auto_save': _autoSave.toString(),
        'enable_notifications': _enableNotifications.toString(),
        'log_level': _logLevel.toString(),
      };
      
      final success = await ApiService.updateMultipleSettings(settingsToSave);
      
      if (success) {
        LoggerService.info('SettingsController', 'تنظیمات با موفقیت ذخیره شد - Settings saved successfully');
      } else {
        LoggerService.error('SettingsController', 'خطا در ذخیره تنظیمات', null);
      }
      
      return success;
    } catch (e) {
      LoggerService.error('SettingsController', 'خطا در ذخیره تنظیمات', e);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// تست API کلید OpenAI - Test OpenAI API key
  Future<void> testOpenAIConnection() async {
    if (_openaiApiKey.isEmpty) {
      _apiTestResult = false;
      _apiTestMessage = 'کلید API وارد نشده است';
      notifyListeners();
      return;
    }
    
    _isTestingApi = true;
    notifyListeners();
    
    try {
      LoggerService.info('SettingsController', 'شروع تست اتصال OpenAI API - Testing OpenAI connection');
      
      final result = await ApiService.testOpenAIConnection(_openaiApiKey);
      
      _apiTestResult = result['success'] ?? false;
      _apiTestMessage = result['message'] ?? 'نتیجه نامشخص';
      
      LoggerService.info('SettingsController', 'تست OpenAI API: $_apiTestMessage');
    } catch (e) {
      _apiTestResult = false;
      _apiTestMessage = 'خطا در تست: $e';
      LoggerService.error('SettingsController', 'خطا در تست OpenAI API', e);
    } finally {
      _isTestingApi = false;
      notifyListeners();
    }
  }

  // Setters with validation
  void setOpenAIApiKey(String value) {
    _openaiApiKey = value.trim();
    _clearApiTestResults();
    notifyListeners();
  }

  void setOpenAIModel(String value) {
    _openaiModel = value;
    _clearApiTestResults();
    notifyListeners();
  }

  void setTemperature(double value) {
    _temperature = value.clamp(0.0, 2.0);
    notifyListeners();
  }

  void setMaxTokens(int value) {
    _maxTokens = value.clamp(1, 4000);
    notifyListeners();
  }

  void setTopP(double value) {
    _topP = value.clamp(0.0, 1.0);
    notifyListeners();
  }

  void setPresencePenalty(double value) {
    _presencePenalty = value.clamp(-2.0, 2.0);
    notifyListeners();
  }

  void setFrequencyPenalty(double value) {
    _frequencyPenalty = value.clamp(-2.0, 2.0);
    notifyListeners();
  }

  void setAppLanguage(String value) {
    _appLanguage = value;
    notifyListeners();
  }

  void setAppTheme(String value) {
    _appTheme = value;
    notifyListeners();
  }

  void setAutoSave(bool value) {
    _autoSave = value;
    notifyListeners();
  }

  void setEnableNotifications(bool value) {
    _enableNotifications = value;
    notifyListeners();
  }

  void setLogLevel(int value) {
    _logLevel = value.clamp(0, 3);
    notifyListeners();
  }

  void _clearApiTestResults() {
    _apiTestResult = false;
    _apiTestMessage = '';
  }
}
