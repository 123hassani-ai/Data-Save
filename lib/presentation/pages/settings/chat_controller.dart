import 'package:flutter/material.dart';
import '../../../core/models/chat_message.dart';
import '../../../core/services/openai_service.dart';
import '../../../core/logger/logger_service.dart';

/// کنترلر چت OpenAI - OpenAI chat controller
class ChatController extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _error;
  
  // تنظیمات OpenAI
  String _apiKey = '';
  String _model = 'gpt-4';
  int _maxTokens = 2048;
  double _temperature = 0.7;

  // Getters
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasApiKey => _apiKey.isNotEmpty;
  String get currentModel => _model;

  /// بروزرسانی تنظیمات OpenAI - Update OpenAI settings
  void updateSettings({
    required String apiKey,
    required String model,
    required int maxTokens,
    required double temperature,
  }) {
    _apiKey = apiKey;
    _model = model;
    _maxTokens = maxTokens;
    _temperature = temperature;
    notifyListeners();
  }

  /// ارسال پیام - Send message
  Future<void> sendMessage(String content, {bool isFirstMessage = false}) async {
    if (content.trim().isEmpty) return;
    
    if (_apiKey.isEmpty) {
      _error = 'کلید OpenAI API تنظیم نشده است';
      notifyListeners();
      LoggerService.severe('ChatController', 'تلاش برای ارسال پیام بدون کلید API');
      return;
    }

    _clearError();
    
    // اضافه کردن پیام کاربر
    final userMessage = ChatMessage.user(content.trim());
    _messages.add(userMessage);
    notifyListeners();

    // اضافه کردن پیام در حال بارگذاری
    final loadingMessage = ChatMessage.loading();
    _messages.add(loadingMessage);
    _setLoading(true);

    try {
      LoggerService.info('ChatController', 'ارسال پیام به OpenAI: ${content.substring(0, content.length > 30 ? 30 : content.length)}...');

      final response = await OpenAIService.sendMessage(
        apiKey: _apiKey,
        message: content,
        model: _model,
        maxTokens: _maxTokens,
        temperature: _temperature,
        isFirstMessage: isFirstMessage,
      );

      // حذف پیام در حال بارگذاری
      _messages.removeWhere((msg) => msg.id == loadingMessage.id);

      if (response != null) {
        final botMessage = ChatMessage.bot(response);
        _messages.add(botMessage);
        LoggerService.info('ChatController', 'پاسخ OpenAI دریافت شد');
      } else {
        _error = 'خطا در دریافت پاسخ از OpenAI';
        final errorMessage = ChatMessage.bot('متأسفم، خطایی در ارتباط با سرور رخ داد. لطفاً دوباره تلاش کنید.');
        _messages.add(errorMessage);
        LoggerService.severe('ChatController', 'خطا در دریافت پاسخ OpenAI - پاسخ null دریافت شد');
      }
    } catch (e) {
      // حذف پیام در حال بارگذاری
      _messages.removeWhere((msg) => msg.id == loadingMessage.id);
      
      _error = 'خطا در ارسال پیام: $e';
      final errorMessage = ChatMessage.bot('متأسفم، خطایی رخ داد. لطفاً کلید API و اتصال اینترنت خود را بررسی کنید.');
      _messages.add(errorMessage);
      LoggerService.severe('ChatController', 'خطا در ارسال پیام به OpenAI', e);
    } finally {
      _setLoading(false);
    }
  }

  /// تست اتصال OpenAI - Test OpenAI connection
  Future<bool> testConnection() async {
    if (_apiKey.isEmpty) {
      _error = 'کلید API وارد نشده است';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      LoggerService.info('ChatController', 'تست اتصال OpenAI');
      
      final success = await OpenAIService.testConnection(_apiKey);
      
      if (success) {
        final testMessage = ChatMessage.bot('✅ اتصال به OpenAI برقرار شد! مدل $_model آماده استفاده است.');
        _messages.add(testMessage);
        LoggerService.info('ChatController', 'تست اتصال موفق');
      } else {
        _error = 'خطا در اتصال به OpenAI. کلید API را بررسی کنید.';
        final errorMessage = ChatMessage.bot('❌ خطا در اتصال به OpenAI. لطفاً کلید API خود را بررسی کنید.');
        _messages.add(errorMessage);
        LoggerService.error('ChatController', 'تست اتصال ناموفق', null);
      }
      
      notifyListeners();
      return success;
    } catch (e) {
      _error = 'خطا در تست اتصال: $e';
      final errorMessage = ChatMessage.bot('❌ خطا در تست اتصال. لطفاً اتصال اینترنت خود را بررسی کنید.');
      _messages.add(errorMessage);
      LoggerService.error('ChatController', 'خطا در تست اتصال', e);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// پاک کردن چت - Clear chat
  void clearChat() {
    _messages.clear();
    _clearError();
    notifyListeners();
    LoggerService.info('ChatController', 'چت پاک شد');
  }

  /// اضافه کردن پیام خوشامدگویی - Add welcome message
  void addWelcomeMessage() {
    if (_messages.isEmpty) {
      // ارسال پیام خوشامدگویی با معرفی مدل
      sendMessage('سلام', isFirstMessage: true);
      
      LoggerService.info('ChatController', 'پیام خوشامدگویی با معرفی مدل $_model ارسال شد');
    }
  }

  // متدهای کمکی
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// پاک کردن خطا - Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
