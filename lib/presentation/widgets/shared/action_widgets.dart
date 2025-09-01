import 'package:flutter/material.dart';

/// کارت اقدامات سریع - برای نمایش دکمه‌های اقدامات سریع
/// Quick actions card for dashboard shortcuts
class QuickActionsCard extends StatelessWidget {
  final List<ActionButton> actions;

  const QuickActionsCard({
    super.key,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عنوان کارت
            Row(
              children: [
                Icon(
                  Icons.speed,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'اقدامات سریع',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // دکمه‌های اقدامات
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: actions.map((action) => action).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

/// دکمه اقدام - برای اقدامات سریع
/// Action button for quick actions
class ActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final bool isLoading;

  const ActionButton(
    this.text,
    this.icon,
    this.onPressed, {
    super.key,
    this.color,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = color ?? theme.colorScheme.primary;

    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.onPrimary,
              ),
            )
          : Icon(icon),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: theme.colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

/// منوی درپ‌داون سفارشی برای تنظیمات
/// Custom dropdown menu for settings
class SettingsDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final IconData? prefixIcon;

  const SettingsDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<T>(
        initialValue: value,
        items: items,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
      ),
    );
  }
}

/// سوئیچ تنظیمات با عنوان و توضیحات
/// Settings switch with title and description
class SettingsSwitch extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData? icon;

  const SettingsSwitch({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SwitchListTile(
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        value: value,
        onChanged: onChanged,
        secondary: icon != null ? Icon(icon) : null,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}

/// باکس اطلاعات - برای نمایش اطلاعات اضافی
/// Info box for additional information display
class InfoBox extends StatelessWidget {
  final String message;
  final InfoBoxType type;
  final IconData? icon;

  const InfoBox({
    super.key,
    required this.message,
    this.type = InfoBoxType.info,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color backgroundColor;
    Color textColor;
    Color borderColor;
    IconData defaultIcon;

    switch (type) {
      case InfoBoxType.success:
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green.shade700;
        borderColor = Colors.green.withOpacity(0.3);
        defaultIcon = Icons.check_circle;
        break;
      case InfoBoxType.warning:
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange.shade700;
        borderColor = Colors.orange.withOpacity(0.3);
        defaultIcon = Icons.warning;
        break;
      case InfoBoxType.error:
        backgroundColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red.shade700;
        borderColor = Colors.red.withOpacity(0.3);
        defaultIcon = Icons.error;
        break;
      case InfoBoxType.info:
        backgroundColor = theme.colorScheme.primary.withOpacity(0.1);
        textColor = theme.colorScheme.primary;
        borderColor = theme.colorScheme.primary.withOpacity(0.3);
        defaultIcon = Icons.info;
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon ?? defaultIcon,
            color: textColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// انواع باکس اطلاعات
/// Info box types
enum InfoBoxType {
  info,
  success,
  warning,
  error,
}
