import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/form_builder_provider.dart';

/// نوار ابزار فرم‌ساز - Form Builder App Bar
/// شامل دکمه‌های ذخیره، پیش‌نمایش و تنظیمات
class FormBuilderAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FormBuilderAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Consumer<FormBuilderProvider>(
      builder: (context, formProvider, child) {
        return AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 1,
          shadowColor: Colors.black.withOpacity(0.1),
          title: Expanded(
            child: Row(
              children: [
                Icon(
                  Icons.dashboard_customize,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'فرم‌ساز هوشمند',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (formProvider.currentForm != null)
                        Text(
                          formProvider.currentForm?['persian_title'] ?? 'فرم جدید',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontSize: 10,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            // دکمه‌های کنترل پنل‌ها
            _buildPanelToggleButtons(context, formProvider),
            
            const SizedBox(width: 4),
            
            // دکمه پیش‌نمایش
            _buildPreviewButton(context, formProvider),
            
            const SizedBox(width: 4),
            
            // دکمه ذخیره
            _buildSaveButton(context, formProvider),
            
            const SizedBox(width: 4),
            
            // منوی اضافی
            _buildMoreMenu(context, formProvider),
            
            const SizedBox(width: 8),
          ],
        );
      },
    );
  }

  /// دکمه‌های کنترل پنل‌ها
  Widget _buildPanelToggleButtons(BuildContext context, FormBuilderProvider formProvider) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // دکمه کتابخانه ویجت‌ها
        Tooltip(
          message: 'کتابخانه ویجت‌ها',
          child: IconButton(
            onPressed: formProvider.toggleWidgetLibraryVisibility,
            iconSize: 20,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            icon: Icon(
              formProvider.isWidgetLibraryVisible
                  ? Icons.widgets
                  : Icons.widgets_outlined,
              color: formProvider.isWidgetLibraryVisible
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        
        // دکمه پنل تنظیمات
        Tooltip(
          message: 'پنل تنظیمات',
          child: IconButton(
            onPressed: formProvider.togglePropertiesPanelVisibility,
            iconSize: 20,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            icon: Icon(
              formProvider.isPropertiesPanelVisible
                  ? Icons.tune
                  : Icons.tune_outlined,
              color: formProvider.isPropertiesPanelVisible
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  /// دکمه پیش‌نمایش
  Widget _buildPreviewButton(BuildContext context, FormBuilderProvider formProvider) {
    return Tooltip(
      message: formProvider.isPreviewMode ? 'بازگشت به ویرایش' : 'پیش‌نمایش',
      child: TextButton.icon(
        onPressed: formProvider.togglePreviewMode,
        icon: Icon(
          formProvider.isPreviewMode
              ? Icons.edit
              : Icons.preview,
          size: 20,
        ),
        label: Text(
          formProvider.isPreviewMode ? 'ویرایش' : 'پیش‌نمایش',
        ),
        style: TextButton.styleFrom(
          backgroundColor: formProvider.isPreviewMode
              ? Theme.of(context).colorScheme.secondaryContainer
              : null,
          foregroundColor: formProvider.isPreviewMode
              ? Theme.of(context).colorScheme.onSecondaryContainer
              : Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  /// دکمه ذخیره
  Widget _buildSaveButton(BuildContext context, FormBuilderProvider formProvider) {
    final bool hasChanges = formProvider.hasUnsavedChanges;
    final bool isSaving = formProvider.isSaving;

    return Tooltip(
      message: 'ذخیره فرم',
      child: ElevatedButton.icon(
        onPressed: (hasChanges || formProvider.currentForm == null) && !isSaving
            ? () => _saveForm(context, formProvider)
            : null,
        icon: isSaving
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              )
            : Icon(
                hasChanges ? Icons.save : Icons.check,
                size: 20,
              ),
        label: Text(
          isSaving
              ? 'در حال ذخیره...'
              : hasChanges
                  ? 'ذخیره'
                  : 'ذخیره شده',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: hasChanges || formProvider.currentForm == null
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          foregroundColor: hasChanges || formProvider.currentForm == null
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  /// منوی اضافی
  Widget _buildMoreMenu(BuildContext context, FormBuilderProvider formProvider) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      tooltip: 'منوی بیشتر',
      onSelected: (value) => _handleMenuAction(context, formProvider, value),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'clear',
          child: Row(
            children: [
              Icon(Icons.clear_all),
              SizedBox(width: 12),
              Text('پاک کردن فرم'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'export',
          child: Row(
            children: [
              Icon(Icons.file_download),
              SizedBox(width: 12),
              Text('خروجی JSON'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'import',
          child: Row(
            children: [
              Icon(Icons.file_upload),
              SizedBox(width: 12),
              Text('وارد کردن JSON'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              Icon(Icons.settings),
              SizedBox(width: 12),
              Text('تنظیمات فرم'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'help',
          child: Row(
            children: [
              Icon(Icons.help_outline),
              SizedBox(width: 12),
              Text('راهنما'),
            ],
          ),
        ),
      ],
    );
  }

  /// ذخیره فرم
  Future<void> _saveForm(BuildContext context, FormBuilderProvider formProvider) async {
    try {
      await formProvider.saveForm();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('فرم با موفقیت ذخیره شد'),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('خطا در ذخیره: $e')),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// پردازش عملیات منو
  void _handleMenuAction(BuildContext context, FormBuilderProvider formProvider, String action) {
    switch (action) {
      case 'clear':
        _showClearConfirmation(context, formProvider);
        break;
      case 'export':
        _exportFormJson(context, formProvider);
        break;
      case 'import':
        _importFormJson(context, formProvider);
        break;
      case 'settings':
        _showFormSettings(context, formProvider);
        break;
      case 'help':
        _showHelp(context);
        break;
    }
  }

  /// نمایش تأیید پاک کردن
  void _showClearConfirmation(BuildContext context, FormBuilderProvider formProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('پاک کردن فرم'),
        content: const Text('آیا مطمئن هستید که می‌خواهید تمام محتویات فرم را پاک کنید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () {
              formProvider.clearForm();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('پاک کردن'),
          ),
        ],
      ),
    );
  }

  /// خروجی JSON
  void _exportFormJson(BuildContext context, FormBuilderProvider formProvider) {
    final jsonData = formProvider.exportFormAsJson();
    // TODO: پیاده‌سازی download file
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('خروجی JSON'),
        content: SingleChildScrollView(
          child: SelectableText(jsonData),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('بستن'),
          ),
        ],
      ),
    );
  }

  /// وارد کردن JSON
  void _importFormJson(BuildContext context, FormBuilderProvider formProvider) {
    // TODO: پیاده‌سازی file picker و import
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('این قابلیت در آپدیت بعدی اضافه خواهد شد'),
      ),
    );
  }

  /// تنظیمات فرم
  void _showFormSettings(BuildContext context, FormBuilderProvider formProvider) {
    // TODO: پیاده‌سازی صفحه تنظیمات
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('صفحه تنظیمات در حال توسعه است'),
      ),
    );
  }

  /// راهنما
  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('راهنمای فرم‌ساز'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🎯 نحوه استفاده:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• از پنل سمت راست ویجت‌ها را به بوم اضافه کنید'),
              Text('• روی ویجت‌ها کلیک کنید تا تنظیمات آن‌ها را ببینید'),
              Text('• با drag & drop ویجت‌ها را مرتب کنید'),
              Text('• از دکمه پیش‌نمایش برای مشاهده نتیجه استفاده کنید'),
              SizedBox(height: 16),
              Text(
                '⚡ میانبرهای کیبورد:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Ctrl+S: ذخیره فرم'),
              Text('• Ctrl+P: پیش‌نمایش'),
              Text('• Delete: حذف ویجت انتخابی'),
              Text('• Ctrl+Z: بازگشت به قبل'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('متوجه شدم'),
          ),
        ],
      ),
    );
  }
}
