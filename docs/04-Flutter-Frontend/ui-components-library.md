# کتابخانه کامپوننت‌های UI - UI Components Library

## 📊 Document Information
- **Created:** 2025-01-09
- **Last Updated:** 2025-09-01
- **Version:** 2.1
- **Maintainer:** DataSave Development Team
- **Related Files:** `/lib/presentation/widgets/`, `/lib/core/theme/`, [component-specifications.md](../06-UI-UX-Design/component-specifications.md)

## 🎯 Overview
مستندات کامل کتابخانه کامپوننت‌های UI در DataSave با تمرکز بر Material Design 3، Persian RTL support و بهبودهای جدید Form Builder.

## 📋 Table of Contents
- [فلسفه Design System](#فلسفه-design-system)
- [Form Builder Components (New)](#form-builder-components-new)
- [Enhanced Widget Library](#enhanced-widget-library)
- [Shared Components](#shared-components)
- [Card Components](#card-components)
- [Form Components](#form-components)
- [Navigation Components](#navigation-components)
- [Persian-Specific Components](#persian-specific-components)

## 🆕 Form Builder Components (New)

### FormBuilderPage - Enhanced UI
**مسیر:** `lib/presentation/pages/form_builder_page.dart`

**بهبودهای اصلی:**
- ✅ AppBar با طراحی مدرن و gradient background
- ✅ دکمه‌های حالت‌دار (Stateful Action Buttons)
- ✅ انیمیشن‌های smooth transitions
- ✅ بهبود تجربه کاربری RTL

```dart
// نمونه AppBar بهبود یافته
PreferredSizeWidget _buildAppBar(BuildContext context) {
  return AppBar(
    backgroundColor: Colors.white,
    elevation: 1,
    shadowColor: Colors.grey.withOpacity(0.3),
    title: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.architecture, color: AppTheme.primaryColor),
        ),
        // ... title content
      ],
    ),
  );
}
```

### WidgetLibraryPanel - Complete Redesign  
**مسیر:** `lib/presentation/widgets/form_builder/widget_library_panel.dart`

**ویژگی‌های جدید:**
- 🎨 Header با gradient زیبا
- 🔍 Search bar با طراحی مدرن و RTL support
- 📱 Category tabs با انیمیشن
- 🎯 بهبود کلی UX

```dart
// Header با gradient
Widget _buildHeader() {
  return Container(
    height: 70,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppTheme.primaryColor,
          AppTheme.primaryColor.withOpacity(0.8),
        ],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ),
      boxShadow: [
        BoxShadow(
          color: AppTheme.primaryColor.withOpacity(0.3),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: // ... header content
  );
}
```

### Form Canvas - Interactive Improvements
**مسیر:** `lib/presentation/widgets/form_builder/form_canvas.dart`

**بهبودهای drag & drop:**
- 🎭 انیمیشن hover states
- 📱 بهتر visual feedback  
- 🎨 Empty state زیباتر
- ⚡ Performance بهتر

```dart
// Empty state با انیمیشن
Widget _buildEmptyCanvas(BuildContext context) {
  return DragTarget<FormWidgetModel>(
    builder: (context, candidateData, rejectedData) {
      final isHovering = candidateData.isNotEmpty;
      
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: isHovering 
              ? primaryHoverGradient
              : neutralGradient,
          borderRadius: BorderRadius.circular(12),
          border: isHovering
              ? Border.all(color: primary.withValues(alpha: 0.3))
              : Border.all(color: outline.withValues(alpha: 0.2)),
          boxShadow: isHovering ? hoverShadow : null,
        ),
        // ... content
      );
    },
  );
}
```

## 🎨 فلسفه Design System - Design System Philosophy

### Material Design 3 Implementation
```yaml
Design Principles:
  - Material Design 3 guidelines
  - Persian RTL layout
  - Consistent spacing (8dp grid)
  - Semantic colors
  - Accessible components
  - Responsive design

Component Categories:
  - Layout: Cards, Containers, Dividers
  - Input: Forms, Fields, Buttons
  - Display: Text, Icons, Images
  - Navigation: AppBar, Drawer, Tabs
  - Feedback: Dialogs, Snackbars, Loading
```

### Persian Design Considerations
```yaml
RTL Layout:
  - Right-to-left text flow
  - Mirrored icons and layouts
  - Persian number formatting
  - Vazirmatn font family

Cultural Adaptations:
  - Persian color preferences
  - Local icon adaptations
  - Persian typography scale
  - Cultural interaction patterns
```

## 🧩 Shared Components

### StatCard Component
```dart
// آمار و اعداد - پایه‌ای برای نمایش آمار
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = color ?? theme.colorScheme.primary;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                cardColor.withOpacity(0.1),
                cardColor.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: cardColor),
              const SizedBox(height: 8),
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: cardColor,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

#### StatCard Usage Examples
```dart
// Dashboard statistics
StatCard(
  title: 'کل لاگ‌ها',
  value: PersianUtils.formatNumber(totalLogs),
  icon: Icons.list_alt,
  color: Colors.blue,
  onTap: () => navigateToLogs(),
),

StatCard(
  title: 'خطاها',
  value: PersianUtils.formatNumber(errorLogs),
  icon: Icons.error,
  color: Colors.red,
  onTap: () => navigateToErrors(),
),

StatCard(
  title: 'تنظیمات',
  value: PersianUtils.formatNumber(settingsCount),
  icon: Icons.settings,
  color: Colors.green,
  onTap: () => navigateToSettings(),
),
```

#### StatCard Variants
```dart
// Compact version
class CompactStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: Theme.of(context).textTheme.titleMedium),
              Text(title, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}

// Large version with description
class DetailedStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 12),
            Text(value, style: Theme.of(context).textTheme.headlineLarge),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            Text(description, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
```

### SettingsCard Component
```dart
// کارت تنظیمات - برای گروه‌بندی تنظیمات
class SettingsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final bool isExpanded;
  final VoidCallback? onExpandChanged;

  const SettingsCard({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    this.isExpanded = true,
    this.onExpandChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: onExpandChanged,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(icon, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  if (onExpandChanged != null)
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: theme.colorScheme.primary,
                    ),
                ],
              ),
            ),
          ),
          // Content
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: children),
            ),
        ],
      ),
    );
  }
}
```

#### SettingsCard Usage
```dart
SettingsCard(
  title: 'تنظیمات OpenAI',
  icon: Icons.smart_toy,
  children: [
    TextFormField(
      decoration: const InputDecoration(labelText: 'کلید API'),
      onChanged: (value) => controller.updateSetting('openai_api_key', value),
    ),
    const SizedBox(height: 16),
    DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: 'مدل'),
      value: controller.openaiModel,
      items: [
        DropdownMenuItem(value: 'gpt-4', child: Text('GPT-4')),
        DropdownMenuItem(value: 'gpt-3.5-turbo', child: Text('GPT-3.5 Turbo')),
      ],
      onChanged: (value) => controller.updateSetting('openai_model', value!),
    ),
  ],
),
```

## 📊 Card Components

### LogStatCard Component
```dart
// آمار لاگ‌ها - ویژه نمایش آمار لاگ‌ها
class LogStatCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const LogStatCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 160,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.1),
                  color.withOpacity(0.05),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 28, color: color),
                const SizedBox(height: 8),
                Text(
                  PersianUtils.formatNumber(count),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

### InfoCard Component
```dart
// کارت اطلاعاتی - برای نمایش اطلاعات کلی
class InfoCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData? icon;
  final Color? backgroundColor;
  final bool isSelectable;

  const InfoCard({
    super.key,
    required this.title,
    required this.content,
    this.icon,
    this.backgroundColor,
    this.isSelectable = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                ],
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            isSelectable
                ? SelectableText(
                    content,
                    style: theme.textTheme.bodyMedium,
                  )
                : Text(
                    content,
                    style: theme.textTheme.bodyMedium,
                  ),
          ],
        ),
      ),
    );
  }
}
```

### StatusCard Component
```dart
// کارت وضعیت - برای نمایش وضعیت سیستم
class StatusCard extends StatelessWidget {
  final String title;
  final SystemStatus status;
  final String? details;
  final VoidCallback? onRefresh;

  const StatusCard({
    super.key,
    required this.title,
    required this.status,
    this.details,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusInfo = _getStatusInfo(status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusInfo.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    statusInfo.icon,
                    color: statusInfo.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        statusInfo.text,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: statusInfo.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onRefresh != null)
                  IconButton(
                    onPressed: onRefresh,
                    icon: const Icon(Icons.refresh),
                  ),
              ],
            ),
            if (details != null) ...[
              const SizedBox(height: 8),
              Text(
                details!,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  StatusInfo _getStatusInfo(SystemStatus status) {
    switch (status) {
      case SystemStatus.healthy:
        return StatusInfo(
          text: 'سالم',
          color: Colors.green,
          icon: Icons.check_circle,
        );
      case SystemStatus.warning:
        return StatusInfo(
          text: 'هشدار',
          color: Colors.orange,
          icon: Icons.warning,
        );
      case SystemStatus.error:
        return StatusInfo(
          text: 'خطا',
          color: Colors.red,
          icon: Icons.error,
        );
      case SystemStatus.unknown:
        return StatusInfo(
          text: 'نامشخص',
          color: Colors.grey,
          icon: Icons.help,
        );
    }
  }
}

class StatusInfo {
  final String text;
  final Color color;
  final IconData icon;

  StatusInfo({
    required this.text,
    required this.color,
    required this.icon,
  });
}

enum SystemStatus { healthy, warning, error, unknown }
```

## 🎬 Action Components

### ActionButton Component
```dart
// دکمه اقدام - برای اقدامات سریع
class ActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final bool isLoading;
  final ButtonStyle? style;

  const ActionButton({
    super.key,
    required this.text,
    required this.icon,
    this.onPressed,
    this.color,
    this.isLoading = false,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      style: style ??
          ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
      icon: isLoading
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.onPrimary,
                ),
              ),
            )
          : Icon(icon),
      label: Text(text),
    );
  }
}
```

### QuickActionsCard Component
```dart
// کارت اقدامات سریع - برای dashboard
class QuickActionsCard extends StatelessWidget {
  final List<ActionButton> actions;
  final String? title;

  const QuickActionsCard({
    super.key,
    required this.actions,
    this.title,
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
            if (title != null) ...[
              Row(
                children: [
                  Icon(Icons.speed, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    title!,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: actions,
            ),
          ],
        ),
      ),
    );
  }
}
```

#### QuickActions Usage
```dart
QuickActionsCard(
  title: 'اقدامات سریع',
  actions: [
    ActionButton(
      text: 'پاک کردن لاگ‌ها',
      icon: Icons.clear_all,
      color: Colors.red,
      onPressed: () => _clearLogs(),
    ),
    ActionButton(
      text: 'بازخوانی',
      icon: Icons.refresh,
      color: Colors.blue,
      onPressed: () => _refresh(),
      isLoading: controller.isLoading,
    ),
    ActionButton(
      text: 'تست اتصال',
      icon: Icons.network_check,
      color: Colors.green,
      onPressed: () => _testConnection(),
    ),
  ],
),
```

## 📝 Form Components

### PersianTextField Component
```dart
// فیلد متن فارسی - بهینه شده برای فارسی
class PersianTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? initialValue;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final TextDirection? textDirection;
  final int? maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final Widget? prefixIcon;

  const PersianTextField({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.validator,
    this.textDirection,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: validator,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      textDirection: textDirection ?? TextDirection.rtl,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
      style: const TextStyle(
        fontFamily: 'Vazirmatn',
      ),
    );
  }
}
```

### PersianDropdown Component
```dart
// کشویی فارسی - dropdown بهینه برای فارسی
class PersianDropdown<T> extends StatelessWidget {
  final String? label;
  final String? hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final FormFieldValidator<T>? validator;

  const PersianDropdown({
    super.key,
    this.label,
    this.hint,
    this.value,
    required this.items,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
      style: const TextStyle(
        fontFamily: 'Vazirmatn',
      ),
      dropdownColor: Theme.of(context).colorScheme.surface,
    );
  }
}
```

### SettingsField Component
```dart
// فیلد تنظیمات - ترکیبی برای صفحه تنظیمات
class SettingsField extends StatelessWidget {
  final String label;
  final String? description;
  final Widget child;
  final bool isRequired;

  const SettingsField({
    super.key,
    required this.label,
    this.description,
    required this.child,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isRequired)
                Text(
                  ' *',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          if (description != null) ...[
            const SizedBox(height: 4),
            Text(
              description!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
```

#### Form Usage Examples
```dart
Column(
  children: [
    SettingsField(
      label: 'کلید API OpenAI',
      description: 'کلید API خود را از پنل OpenAI دریافت کنید',
      isRequired: true,
      child: PersianTextField(
        hint: 'sk-...',
        obscureText: true,
        onChanged: (value) => controller.updateSetting('openai_api_key', value),
      ),
    ),
    
    SettingsField(
      label: 'مدل OpenAI',
      description: 'مدل مورد استفاده برای تولید فرم',
      child: PersianDropdown<String>(
        value: controller.openaiModel,
        items: [
          DropdownMenuItem(value: 'gpt-4', child: Text('GPT-4')),
          DropdownMenuItem(value: 'gpt-3.5-turbo', child: Text('GPT-3.5 Turbo')),
        ],
        onChanged: (value) => controller.updateSetting('openai_model', value!),
      ),
    ),
  ],
),
```

## 🚦 Loading & Feedback Components

### LoadingCard Component
```dart
// کارت بارگذاری - برای نمایش حالت loading
class LoadingCard extends StatelessWidget {
  final String? message;
  final double? height;

  const LoadingCard({
    super.key,
    this.message,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Container(
        height: height ?? 200,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

### ErrorCard Component
```dart
// کارت خطا - برای نمایش خطاها
class ErrorCard extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;
  final bool showDetails;

  const ErrorCard({
    super.key,
    required this.error,
    this.onRetry,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.error,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'خطا',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              error,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('تلاش مجدد'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

### EmptyStateCard Component
```dart
// کارت حالت خالی - برای نمایش لیست‌های خالی
class EmptyStateCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyStateCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

## 🧭 Navigation Components

### PersianAppBar Component
```dart
// نوار برنامه فارسی - AppBar بهینه برای فارسی
class PersianAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;
  final PreferredSizeWidget? bottom;

  const PersianAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Vazirmatn',
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor,
      actions: actions,
      leading: leading,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
  );
}
```

### PersianBottomNav Component
```dart
// نوار پایین فارسی - BottomNavigationBar فارسی
class PersianBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavigationBarItem> items;

  const PersianBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: items,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: const TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 12,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 12,
      ),
    );
  }
}
```

## 🇮🇷 Persian-Specific Components

### PersianDatePicker Component
```dart
// انتخابگر تاریخ فارسی
class PersianDatePicker extends StatelessWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime>? onDateSelected;
  final String? label;

  const PersianDatePicker({
    super.key,
    this.selectedDate,
    this.onDateSelected,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showDatePicker(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label ?? 'انتخاب تاریخ',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          selectedDate != null
              ? PersianUtils.formatDate(selectedDate!)
              : 'تاریخ انتخاب نشده',
          style: const TextStyle(fontFamily: 'Vazirmatn'),
        ),
      ),
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1300),
      lastDate: DateTime(1450),
      locale: const Locale('fa', 'IR'),
    );

    if (date != null && onDateSelected != null) {
      onDateSelected!(date);
    }
  }
}
```

### PersianNumberField Component
```dart
// فیلد عدد فارسی - با فرمت فارسی
class PersianNumberField extends StatefulWidget {
  final String? label;
  final int? initialValue;
  final ValueChanged<int?>? onChanged;
  final FormFieldValidator<int>? validator;
  final int? min;
  final int? max;

  const PersianNumberField({
    super.key,
    this.label,
    this.initialValue,
    this.onChanged,
    this.validator,
    this.min,
    this.max,
  });

  @override
  _PersianNumberFieldState createState() => _PersianNumberFieldState();
}

class _PersianNumberFieldState extends State<PersianNumberField> {
  late TextEditingController _controller;
  int? _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
    _controller = TextEditingController(
      text: _currentValue != null 
        ? PersianUtils.formatNumber(_currentValue!) 
        : '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: widget.label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      style: const TextStyle(fontFamily: 'Vazirmatn'),
      onChanged: _onTextChanged,
      validator: (value) => _validateNumber(value),
    );
  }

  void _onTextChanged(String value) {
    final englishValue = PersianUtils.toEnglishNumbers(value);
    final intValue = int.tryParse(englishValue.replaceAll(',', ''));
    
    if (intValue != _currentValue) {
      _currentValue = intValue;
      widget.onChanged?.call(intValue);
    }

    // Format the display
    if (intValue != null) {
      final formatted = PersianUtils.formatNumber(intValue);
      if (_controller.text != formatted) {
        _controller.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    }
  }

  String? _validateNumber(String? value) {
    if (widget.validator != null) {
      final result = widget.validator!(_currentValue);
      if (result != null) return result;
    }

    if (_currentValue != null) {
      if (widget.min != null && _currentValue! < widget.min!) {
        return 'مقدار نباید کمتر از ${PersianUtils.formatNumber(widget.min!)} باشد';
      }
      if (widget.max != null && _currentValue! > widget.max!) {
        return 'مقدار نباید بیشتر از ${PersianUtils.formatNumber(widget.max!)} باشد';
      }
    }

    return null;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

## 🎨 Theme Integration

### Component Theming
```dart
// تم کامپوننت‌ها - استفاده از Material Design 3
class ComponentTheme {
  static CardTheme cardTheme(ColorScheme colorScheme) {
    return CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: colorScheme.surface,
    );
  }

  static InputDecorationTheme inputDecorationTheme(ColorScheme colorScheme) {
    return InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      filled: true,
      fillColor: colorScheme.surface,
      labelStyle: const TextStyle(fontFamily: 'Vazirmatn'),
      hintStyle: const TextStyle(fontFamily: 'Vazirmatn'),
    );
  }

  static ElevatedButtonThemeData elevatedButtonTheme(ColorScheme colorScheme) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontFamily: 'Vazirmatn',
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
```

### Responsive Design
```dart
// کامپوننت‌های responsive
class ResponsiveStatGrid extends StatelessWidget {
  final List<StatCard> cards;

  const ResponsiveStatGrid({super.key, required this.cards});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: cards.length,
          itemBuilder: (context, index) => cards[index],
        );
      },
    );
  }

  int _getCrossAxisCount(double width) {
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }
}
```

## 📱 Accessibility Support

### Accessible Components
```dart
// کامپوننت قابل دسترس
class AccessibleStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const AccessibleStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title: $value',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Semantics(
                excludeSemantics: true, // Icon is decorative
                child: Icon(icon, size: 32),
              ),
              const SizedBox(height: 8),
              Semantics(
                label: title,
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Semantics(
                label: value,
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## 🛠️ Usage Guidelines

### Component Selection Guide
```yaml
Layout Components:
  - StatCard: آمار و اعداد کلیدی
  - SettingsCard: گروه‌بندی تنظیمات
  - InfoCard: نمایش اطلاعات عمومی
  - StatusCard: وضعیت سیستم و سرویس‌ها

Form Components:
  - PersianTextField: ورودی متن فارسی
  - PersianDropdown: انتخاب از لیست
  - PersianNumberField: ورودی عدد با فرمت فارسی
  - SettingsField: wrapper برای فیلدهای تنظیمات

Action Components:
  - ActionButton: دکمه‌های اقدام سریع
  - QuickActionsCard: مجموعه دکمه‌های مرتبط

Feedback Components:
  - LoadingCard: نمایش حالت بارگذاری
  - ErrorCard: نمایش خطاها
  - EmptyStateCard: نمایش حالت خالی
```

### Performance Considerations
1. **Use const constructors**: همیشه از const استفاده کنید
2. **Avoid rebuilds**: از Selector برای کنترل بازسازی
3. **Optimize images**: تصاویر را بهینه کنید
4. **Cache widgets**: از AutomaticKeepAliveClientMixin استفاده کنید

### Persian Guidelines
1. **RTL Layout**: همه کامپوننت‌ها RTL-ready باشند
2. **Font Family**: همیشه Vazirmatn استفاده کنید
3. **Number Formatting**: اعداد فارسی استفاده کنید
4. **Cultural Colors**: رنگ‌های مناسب فرهنگ ایرانی

## ⚠️ Important Notes

### Best Practices
1. **Consistency**: همه کامپوننت‌ها با design system سازگار باشند
2. **Accessibility**: semantic labels اضافه کنید
3. **Performance**: از const و optimization patterns استفاده کنید
4. **Persian Support**: RTL و فونت‌های فارسی را در نظر بگیرید

### Common Mistakes
1. **Hardcoded colors**: همیشه از theme colors استفاده کنید
2. **English-only design**: کامپوننت‌ها باید فارسی-first باشند
3. **Missing accessibility**: semantic labels فراموش نکنید
4. **No responsive design**: برای سایزهای مختلف تست کنید

## 🔄 Related Documentation
- [Flutter Architecture](./flutter-architecture.md)
- [State Management](./state-management.md)
- [UI/UX Design System](../06-UI-UX-Design/design-system.md)
- [Material Design 3 Guide](../06-UI-UX-Design/material-design-3.md)

---
*Last updated: 2025-01-09*  
*File: /docs/04-Flutter-Frontend/ui-components-library.md*
