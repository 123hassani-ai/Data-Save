import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/models/chat_message.dart';

/// ویجت نمایش پیام چت - Chat message widget
class ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onCopy;

  const ChatMessageWidget({
    super.key,
    required this.message,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.type == ChatMessageType.user;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            _buildAvatar(context, false),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser 
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomRight: isUser ? const Radius.circular(4) : null,
                  bottomLeft: !isUser ? const Radius.circular(4) : null,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.isLoading)
                    _buildLoadingContent(theme)
                  else
                    _buildMessageContent(theme, isUser),
                  const SizedBox(height: 4),
                  _buildMessageFooter(theme, isUser),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            _buildAvatar(context, true),
          ],
        ],
      ),
    );
  }

  /// ساخت آواتار - Build avatar
  Widget _buildAvatar(BuildContext context, bool isUser) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isUser 
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.secondary,
        shape: BoxShape.circle,
      ),
      child: Icon(
        isUser ? Icons.person : Icons.smart_toy,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  /// ساخت محتوای در حال بارگذاری - Build loading content
  Widget _buildLoadingContent(ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'در حال تایپ...',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  /// ساخت محتوای پیام - Build message content
  Widget _buildMessageContent(ThemeData theme, bool isUser) {
    return GestureDetector(
      onLongPress: _copyToClipboard,
      child: SelectableText(
        message.content,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: isUser 
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurfaceVariant,
          height: 1.4,
        ),
      ),
    );
  }

  /// ساخت پاورقی پیام - Build message footer
  Widget _buildMessageFooter(ThemeData theme, bool isUser) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formatTime(message.timestamp),
          style: theme.textTheme.bodySmall?.copyWith(
            color: (isUser 
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurfaceVariant).withOpacity(0.7),
            fontSize: 11,
          ),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: _copyToClipboard,
          child: Icon(
            Icons.copy,
            size: 14,
            color: (isUser 
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurfaceVariant).withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  /// کپی کردن متن - Copy text to clipboard
  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: message.content));
    if (onCopy != null) {
      onCopy!();
    }
  }

  /// فرمت کردن زمان - Format time
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
