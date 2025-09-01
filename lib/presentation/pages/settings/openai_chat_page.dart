import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'chat_controller.dart';
import 'settings_controller.dart';
import '../../widgets/chat/chat_message_widget.dart';
import '../../widgets/chat/chat_input_widget.dart';

/// صفحه چت OpenAI - OpenAI chat page
class OpenAIChatPage extends StatefulWidget {
  const OpenAIChatPage({super.key});

  @override
  State<OpenAIChatPage> createState() => _OpenAIChatPageState();
}

class _OpenAIChatPageState extends State<OpenAIChatPage> {
  late ChatController _chatController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _chatController = ChatController();
    _scrollController = ScrollController();
    
    // بارگذاری تنظیمات و نمایش پیام خوشامدگویی
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSettingsAndInitialize();
    });
  }

  @override
  void dispose() {
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// بارگذاری تنظیمات و مقداردهی اولیه - Load settings and initialize
  void _loadSettingsAndInitialize() async {
    final settingsController = context.read<SettingsController>();
    
    // اطمینان از بارگذاری تنظیمات
    if (settingsController.settings.isEmpty) {
      await settingsController.loadSettings();
    }
    
    _chatController.updateSettings(
      apiKey: settingsController.openaiApiKey,
      model: settingsController.openaiModel,
      maxTokens: settingsController.openaiMaxTokens,
      temperature: settingsController.openaiTemperature,
    );
    
    _chatController.addWelcomeMessage();
  }

  /// اسکرول به پایین - Scroll to bottom
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _chatController),
      ],
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  /// ساخت AppBar - Build app bar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('چت تست OpenAI'),
          Consumer<ChatController>(
            builder: (context, controller, child) {
              return Text(
                controller.hasApiKey 
                    ? 'مدل: ${controller.currentModel}'
                    : 'کلید API مورد نیاز است',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              );
            },
          ),
        ],
      ),
      centerTitle: false,
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      actions: [
        Consumer<ChatController>(
          builder: (context, controller, child) {
            return IconButton(
              onPressed: controller.messages.isEmpty
                  ? null
                  : () => _showClearDialog(),
              icon: const Icon(Icons.clear_all),
              tooltip: 'پاک کردن چت',
            );
          },
        ),
        IconButton(
          onPressed: () => _showSettingsDialog(),
          icon: const Icon(Icons.settings),
          tooltip: 'تنظیمات سریع',
        ),
      ],
    );
  }

  /// ساخت بدنه صفحه - Build page body
  Widget _buildBody() {
    return Consumer<ChatController>(
      builder: (context, controller, child) {
        return Column(
          children: [
            // نمایش خطا
            if (controller.error != null)
              _buildErrorBanner(controller.error!),
            
            // لیست پیام‌ها
            Expanded(
              child: controller.messages.isEmpty
                  ? _buildEmptyState()
                  : _buildMessagesList(controller),
            ),
            
            // ورودی چت
            Consumer<SettingsController>(
              builder: (context, settingsController, child) {
                return ChatInputWidget(
                  onSendMessage: (message) {
                    controller.sendMessage(message);
                    _scrollToBottom();
                  },
                  isLoading: controller.isLoading,
                  onTestConnection: () async {
                    final success = await controller.testConnection();
                    if (success) {
                      _scrollToBottom();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ اتصال به OpenAI برقرار شد'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  },
                  hasApiKey: settingsController.openaiApiKey.isNotEmpty,
                );
              },
            ),
          ],
        );
      },
    );
  }

  /// ساخت پیغام خطا - Build error banner
  Widget _buildErrorBanner(String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _chatController.clearError(),
            icon: Icon(
              Icons.close,
              color: Theme.of(context).colorScheme.error,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  /// ساخت وضعیت خالی - Build empty state
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.smart_toy_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'محیط تست OpenAI',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'برای شروع گفتگو، ابتدا کلید API خود را در تنظیمات وارد کنید',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ساخت لیست پیام‌ها - Build messages list
  Widget _buildMessagesList(ChatController controller) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: controller.messages.length,
      itemBuilder: (context, index) {
        final message = controller.messages[index];
        return ChatMessageWidget(
          message: message,
          onCopy: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('پیام کپی شد'),
                duration: Duration(seconds: 1),
              ),
            );
          },
        );
      },
    );
  }

  /// نمایش دیالوگ پاک کردن - Show clear dialog
  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('پاک کردن چت'),
          content: const Text('آیا مطمئن هستید که می‌خواهید تمام پیام‌ها را پاک کنید؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('لغو'),
            ),
            TextButton(
              onPressed: () {
                _chatController.clearChat();
                Navigator.of(context).pop();
              },
              child: const Text('پاک کردن'),
            ),
          ],
        );
      },
    );
  }

  /// نمایش دیالوگ تنظیمات - Show settings dialog
  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<SettingsController>(
          builder: (context, settingsController, child) {
            return AlertDialog(
              title: const Text('تنظیمات سریع'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.key),
                    title: const Text('کلید API'),
                    subtitle: Text(
                      settingsController.openaiApiKey.isEmpty
                          ? 'وارد نشده'
                          : '${settingsController.openaiApiKey.substring(0, 7)}...',
                    ),
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  ListTile(
                    leading: const Icon(Icons.model_training),
                    title: const Text('مدل'),
                    subtitle: Text(settingsController.openaiModel),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('بستن'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushNamed('/settings');
                  },
                  child: const Text('تنظیمات کامل'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
