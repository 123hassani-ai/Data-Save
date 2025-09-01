import 'package:flutter/material.dart';

/// ویجت ورودی چت - Chat input widget
class ChatInputWidget extends StatefulWidget {
  final Function(String) onSendMessage;
  final bool isLoading;
  final VoidCallback? onTestConnection;
  final bool hasApiKey;

  const ChatInputWidget({
    super.key,
    required this.onSendMessage,
    this.isLoading = false,
    this.onTestConnection,
    this.hasApiKey = false,
  });

  @override
  State<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isEmpty = true;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final isEmpty = _controller.text.trim().isEmpty;
    if (_isEmpty != isEmpty) {
      setState(() {
        _isEmpty = isEmpty;
      });
    }
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && !widget.isLoading) {
      widget.onSendMessage(text);
      _controller.clear();
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.dividerColor.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          if (!widget.hasApiKey)
            _buildApiKeyWarning(theme),
          
          Row(
            children: [
              // دکمه تست اتصال
              if (widget.onTestConnection != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: IconButton(
                    onPressed: widget.isLoading ? null : widget.onTestConnection,
                    icon: const Icon(Icons.wifi_protected_setup),
                    tooltip: 'تست اتصال',
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondaryContainer,
                      foregroundColor: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              
              // فیلد متن
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: widget.hasApiKey && !widget.isLoading,
                  decoration: InputDecoration(
                    hintText: widget.hasApiKey 
                        ? 'پیام خود را بنویسید...'
                        : 'ابتدا کلید API را وارد کنید',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    suffixIcon: _buildSendButton(theme),
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  maxLines: null,
                  minLines: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ساخت دکمه ارسال - Build send button
  Widget? _buildSendButton(ThemeData theme) {
    if (!widget.hasApiKey || _isEmpty) return null;

    return Padding(
      padding: const EdgeInsets.all(4),
      child: IconButton(
        onPressed: widget.isLoading ? null : _sendMessage,
        icon: widget.isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              )
            : const Icon(Icons.send),
        style: IconButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          minimumSize: const Size(40, 40),
        ),
      ),
    );
  }

  /// ساخت هشدار کلید API - Build API key warning
  Widget _buildApiKeyWarning(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity(0.1),
        border: Border.all(
          color: theme.colorScheme.error.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber,
            color: theme.colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'برای استفاده از چت، ابتدا کلید API OpenAI را در تنظیمات وارد کنید.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
