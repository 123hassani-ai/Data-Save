import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'settings_controller.dart';
import 'openai_chat_page.dart';
import '../../widgets/shared/settings_card.dart';
import '../../widgets/shared/action_widgets.dart';

/// صفحه تنظیمات سیستم - System settings page
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late SettingsController _controller;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = SettingsController();
    _loadInitialData();
  }

  /// بارگذاری داده‌های اولیه - Load initial data
  Future<void> _loadInitialData() async {
    await _controller.loadSettings();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  /// ساخت AppBar - Build app bar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('تنظیمات سیستم'),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      actions: [
        Consumer<SettingsController>(
          builder: (context, controller, child) {
            return IconButton(
              onPressed: controller.isLoading || controller.isSaving
                  ? null
                  : () => _showMoreActions(context),
              icon: const Icon(Icons.more_vert),
              tooltip: 'عملیات بیشتر',
            );
          },
        ),
      ],
    );
  }

  /// ساخت بدنه صفحه - Build page body
  Widget _buildBody() {
    return Consumer<SettingsController>(
      builder: (context, controller, child) {
        if (controller.isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('در حال بارگذاری تنظیمات...'),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadSettings(),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // نمایش پیام‌ها
                  if (controller.error != null || controller.successMessage != null)
                    _buildMessageBox(controller),
                  
                  const SizedBox(height: 8),
                  
                  // تنظیمات OpenAI
                  _buildOpenAISettings(controller),
                  
                  // تنظیمات عمومی سیستم
                  _buildSystemSettings(controller),
                  
                  // دکمه‌های عملیات
                  _buildActionButtons(controller),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// ساخت باکس پیام - Build message box
  Widget _buildMessageBox(SettingsController controller) {
    if (controller.error != null) {
      return InfoBox(
        message: controller.error!,
        type: InfoBoxType.error,
        icon: Icons.error_outline,
      );
    } else if (controller.successMessage != null) {
      return InfoBox(
        message: controller.successMessage!,
        type: InfoBoxType.success,
        icon: Icons.check_circle_outline,
      );
    }
    return const SizedBox.shrink();
  }

  /// ساخت تنظیمات OpenAI - Build OpenAI settings
  Widget _buildOpenAISettings(SettingsController controller) {
    return SettingsCard(
      title: 'تنظیمات هوش مصنوعی OpenAI',
      icon: Icons.psychology,
      children: [
        // کلید API OpenAI
        SettingsTextField(
          label: 'کلید API OpenAI',
          hint: 'sk-...',
          value: controller.openaiApiKey,
          obscureText: !controller.showApiKey,
          onChanged: (value) => controller.updateSetting('openai_api_key', value),
          validator: _validateApiKey,
          suffixIcon: IconButton(
            icon: Icon(
              controller.showApiKey ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: controller.toggleApiKeyVisibility,
            tooltip: controller.showApiKey ? 'مخفی کردن کلید' : 'نمایش کلید',
          ),
        ),

        // انتخاب مدل OpenAI
        SettingsDropdown<String>(
          label: 'مدل OpenAI',
          value: controller.openaiModel,
          prefixIcon: Icons.model_training,
          items: const [
            DropdownMenuItem(value: 'gpt-4', child: Text('GPT-4')),
            DropdownMenuItem(value: 'gpt-3.5-turbo', child: Text('GPT-3.5 Turbo')),
            DropdownMenuItem(value: 'gpt-4-turbo', child: Text('GPT-4 Turbo')),
          ],
          onChanged: (value) => controller.updateSetting('openai_model', value ?? 'gpt-4'),
        ),

        // اسلایدر حداکثر توکن‌ها
        SliderField(
          label: 'حداکثر توکن‌ها',
          value: controller.openaiMaxTokens.toDouble(),
          min: 100,
          max: 4096,
          divisions: 39,
          onChanged: (value) => controller.updateSetting(
            'openai_max_tokens', 
            value.toInt().toString(),
          ),
          valueFormatter: (value) => '${value.toInt()} توکن',
        ),

        // اسلایدر میزان خلاقیت
        SliderField(
          label: 'میزان خلاقیت (Temperature)',
          value: controller.openaiTemperature,
          min: 0.0,
          max: 1.0,
          divisions: 10,
          onChanged: (value) => controller.updateSetting(
            'openai_temperature', 
            value.toStringAsFixed(1),
          ),
          valueFormatter: (value) => value.toStringAsFixed(1),
        ),

        const SizedBox(height: 16),

        // دکمه‌های OpenAI
        Row(
          children: [
            // دکمه تست اتصال OpenAI
            Expanded(
              child: ElevatedButton.icon(
                onPressed: controller.openaiApiKey.isEmpty
                    ? null
                    : () => _testOpenAIConnection(controller),
                icon: const Icon(Icons.check_circle),
                label: const Text('تست اتصال'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // دکمه چت تست
            Expanded(
              child: ElevatedButton.icon(
                onPressed: controller.openaiApiKey.isEmpty
                    ? null
                    : () => _openChatTest(controller),
                icon: const Icon(Icons.chat),
                label: const Text('چت تست'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// ساخت تنظیمات عمومی سیستم - Build system settings
  Widget _buildSystemSettings(SettingsController controller) {
    return SettingsCard(
      title: 'تنظیمات عمومی سیستم',
      icon: Icons.settings_system_daydream,
      children: [
        // انتخاب زبان
        SettingsDropdown<String>(
          label: 'زبان سیستم',
          value: controller.appLanguage,
          prefixIcon: Icons.language,
          items: const [
            DropdownMenuItem(value: 'fa', child: Text('🇮🇷 فارسی')),
            DropdownMenuItem(value: 'en', child: Text('🇺🇸 English')),
            DropdownMenuItem(value: 'ar', child: Text('🇸🇦 العربية')),
          ],
          onChanged: (value) => controller.updateSetting('app_language', value ?? 'fa'),
        ),

        // انتخاب تم
        SettingsDropdown<String>(
          label: 'تم رنگی',
          value: controller.appTheme,
          prefixIcon: Icons.palette,
          items: const [
            DropdownMenuItem(value: 'light', child: Text('☀️ روشن')),
            DropdownMenuItem(value: 'dark', child: Text('🌙 تیره')),
            DropdownMenuItem(value: 'auto', child: Text('🤖 خودکار')),
          ],
          onChanged: (value) => controller.updateSetting('app_theme', value ?? 'light'),
        ),

        const SizedBox(height: 8),

        // سوئیچ فعال‌سازی لاگینگ
        SettingsSwitch(
          title: 'فعال‌سازی سیستم لاگینگ',
          subtitle: 'ثبت رویدادها و خطاهای سیستم',
          value: controller.enableLogging,
          icon: Icons.article,
          onChanged: (value) => controller.updateSetting('enable_logging', value.toString()),
        ),

        // اسلایدر حداکثر لاگ‌ها
        if (controller.enableLogging)
          SliderField(
            label: 'حداکثر تعداد لاگ‌های ذخیره شده',
            value: controller.maxLogEntries.toDouble(),
            min: 100,
            max: 10000,
            divisions: 99,
            onChanged: (value) => controller.updateSetting(
              'max_log_entries', 
              value.toInt().toString(),
            ),
            valueFormatter: (value) => '${value.toInt()} لاگ',
          ),

        // سوئیچ ذخیره خودکار
        SettingsSwitch(
          title: 'ذخیره خودکار',
          subtitle: 'ذخیره خودکار تغییرات فرم‌ها',
          value: controller.autoSave,
          icon: Icons.save,
          onChanged: (value) => controller.updateSetting('auto_save', value.toString()),
        ),

        // سوئیچ پشتیبان‌گیری
        SettingsSwitch(
          title: 'پشتیبان‌گیری خودکار',
          subtitle: 'پشتیبان‌گیری روزانه از داده‌ها',
          value: controller.backupEnabled,
          icon: Icons.backup,
          onChanged: (value) => controller.updateSetting('backup_enabled', value.toString()),
        ),
      ],
    );
  }

  /// ساخت دکمه‌های عملیات - Build action buttons
  Widget _buildActionButtons(SettingsController controller) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'عملیات',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionButton(
                  'ذخیره تغییرات',
                  Icons.save,
                  controller.isSaving
                      ? null
                      : () => _saveAllSettings(controller),
                  color: Colors.green,
                  isLoading: controller.isSaving,
                ),
                ActionButton(
                  'بازگردانی پیش‌فرض',
                  Icons.restore,
                  controller.isLoading || controller.isSaving
                      ? null
                      : () => _resetToDefaults(controller),
                  color: Colors.orange,
                ),
                ActionButton(
                  'خروجی تنظیمات',
                  Icons.download,
                  controller.isLoading
                      ? null
                      : () => _exportSettings(controller),
                  color: Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// اعتبارسنجی کلید API - Validate API key
  String? _validateApiKey(String? value) {
    if (value == null || value.isEmpty) {
      return null; // اختیاری است
    }
    if (!value.startsWith('sk-')) {
      return 'کلید API باید با sk- شروع شود';
    }
    if (value.length < 20) {
      return 'کلید API خیلی کوتاه است';
    }
    return null;
  }

  /// تست اتصال OpenAI - Test OpenAI connection
  Future<void> _testOpenAIConnection(SettingsController controller) async {
    final success = await controller.testOpenAIConnection();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'اتصال موفقیت‌آمیز!' : 'اتصال ناموفق!'),
          backgroundColor: success ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// ذخیره همه تنظیمات - Save all settings
  Future<void> _saveAllSettings(SettingsController controller) async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await controller.saveAllSettings();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'تنظیمات ذخیره شد!' : 'خطا در ذخیره تنظیمات!'),
            backgroundColor: success ? Colors.green : Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// بازگردانی پیش‌فرض - Reset to defaults
  Future<void> _resetToDefaults(SettingsController controller) async {
    final confirmed = await _showConfirmDialog(
      'بازگردانی پیش‌فرض',
      'آیا مطمئن هستید که می‌خواهید همه تنظیمات را به حالت پیش‌فرض بازگردانید؟',
    );
    
    if (confirmed == true) {
      final success = await controller.resetToDefaults();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success 
                ? 'تنظیمات به حالت پیش‌فرض بازگردانده شد!' 
                : 'خطا در بازگردانی تنظیمات!'
            ),
            backgroundColor: success ? Colors.green : Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// صادرات تنظیمات - Export settings
  Future<void> _exportSettings(SettingsController controller) async {
    try {
      final exportData = controller.exportSettings();
      
      // در اینجا می‌توان فایل را ذخیره کرد یا به کاربر نمایش داد
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('صادرات تنظیمات'),
          content: SingleChildScrollView(
            child: SelectableText(
              'داده‌های صادراتی:\n\n${exportData.toString()}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('بستن'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در صادرات تنظیمات: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// نمایش عملیات بیشتر - Show more actions
  Future<void> _showMoreActions(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('بارگذاری مجدد تنظیمات'),
              onTap: () {
                Navigator.pop(context);
                _controller.loadSettings();
              },
            ),
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text('وارد کردن تنظیمات'),
              onTap: () {
                Navigator.pop(context);
                _importSettings();
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('درباره تنظیمات'),
              onTap: () {
                Navigator.pop(context);
                _showAboutDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// وارد کردن تنظیمات - Import settings
  Future<void> _importSettings() async {
    // Placeholder برای وارد کردن تنظیمات
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('قابلیت وارد کردن تنظیمات در نسخه‌های آتی اضافه خواهد شد'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// نمایش درباره - Show about dialog
  Future<void> _showAboutDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('درباره تنظیمات'),
        content: const Text(
          'این صفحه به شما امکان مدیریت تمامی تنظیمات سیستم DataSave را می‌دهد.\n\n'
          '• تنظیمات OpenAI برای استفاده از هوش مصنوعی\n'
          '• تنظیمات عمومی برای کنترل رفتار سیستم\n'
          '• قابلیت صادرات و وارد کردن تنظیمات\n\n'
          'همه تغییرات به صورت خودکار در پایگاه داده ذخیره می‌شوند.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('فهمیدم'),
          ),
        ],
      ),
    );
  }

  /// نمایش دیالوگ تأیید - Show confirmation dialog
  Future<bool?> _showConfirmDialog(String title, String content) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('تأیید'),
          ),
        ],
      ),
    );
  }

  /// باز کردن صفحه چت تست - Open chat test page
  void _openChatTest(SettingsController controller) {
    // ایجاد صفحه چت تست به عنوان دیالوگ تمام صفحه
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: controller,
          child: const OpenAIChatPage(),
        ),
        fullscreenDialog: true,
      ),
    );
  }
}
