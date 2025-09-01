import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/form_builder_provider.dart';
import '../widgets/form_builder/widget_library_panel.dart';
import '../widgets/form_builder/form_canvas.dart';
import '../widgets/form_builder/form_properties_panel.dart';
import '../widgets/common/loading_overlay.dart';
import '../../core/theme/app_theme.dart';

/// صفحه ساخت‌ساز فرم - Form Builder Page
class FormBuilderPage extends StatefulWidget {
  final int? formId; // برای ویرایش فرم موجود

  const FormBuilderPage({
    super.key,
    this.formId,
  });

  @override
  State<FormBuilderPage> createState() => _FormBuilderPageState();
}

class _FormBuilderPageState extends State<FormBuilderPage> {
  bool _isPropertiesPanelOpen = false;
  String? _selectedWidgetId;

  @override
  void initState() {
    super.initState();
    
    // بارگیری فرم برای ویرایش یا ایجاد فرم جدید
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final formProvider = context.read<FormBuilderProvider>();
      
      if (widget.formId != null) {
        // بارگیری فرم موجود
        formProvider.loadForm(widget.formId!);
      } else {
        // ایجاد فرم جدید
        formProvider.clearForm();
        formProvider.loadDefaultForm();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(context),
      body: Consumer<FormBuilderProvider>(
        builder: (context, formProvider, child) {
          return LoadingOverlay(
            isLoading: formProvider.isLoading,
            child: Row(
              children: [
                // پنل کتابخانه ویجت‌ها - سمت راست
                Container(
                  width: 320,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      left: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(-2, 0),
                      ),
                    ],
                  ),
                  child: const WidgetLibraryPanel(),
                ),
                
                // بوم اصلی فرم - وسط
                Expanded(
                  child: Container(
                    color: AppTheme.surfaceColor,
                    child: const FormCanvas(),
                  ),
                ),
                
                // پنل تنظیمات - سمت چپ (اختیاری)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _isPropertiesPanelOpen ? 320 : 0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      right: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    boxShadow: _isPropertiesPanelOpen ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(2, 0),
                      ),
                    ] : [],
                  ),
                  child: _isPropertiesPanelOpen && _selectedWidgetId != null
                    ? FormPropertiesPanel(
                        widgetId: _selectedWidgetId!,
                        onClose: () {
                          setState(() {
                            _isPropertiesPanelOpen = false;
                            _selectedWidgetId = null;
                          });
                        },
                      )
                    : null,
                ),
              ],
            ),
          );
        },
      ),
      
      // نوار ابزار پایین
      bottomNavigationBar: _buildBottomBar(context),
      
      // نمایش خطاها و پیام‌های موفقیت
      floatingActionButton: _buildFloatingMessages(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  /// ساخت AppBar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      shadowColor: Colors.grey.withOpacity(0.3),
      title: Consumer<FormBuilderProvider>(
        builder: (context, formProvider, child) {
          return Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.architecture,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.formId != null ? 'ویرایش فرم' : 'ساخت‌ساز فرم',
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (formProvider.persianTitle.isNotEmpty)
                      Text(
                        formProvider.persianTitle,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        // دکمه پیش‌نمایش
        Consumer<FormBuilderProvider>(
          builder: (context, formProvider, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: IconButton(
                onPressed: formProvider.hasWidgets ? () => _showPreview(context) : null,
                icon: const Icon(Icons.preview_outlined),
                tooltip: 'پیش‌نمایش فرم',
                style: IconButton.styleFrom(
                  backgroundColor: formProvider.hasWidgets 
                      ? AppTheme.primaryColor.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  foregroundColor: formProvider.hasWidgets 
                      ? AppTheme.primaryColor 
                      : Colors.grey,
                ),
              ),
            );
          },
        ),
        
        // دکمه ذخیره
        Consumer<FormBuilderProvider>(
          builder: (context, formProvider, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: TextButton.icon(
                onPressed: formProvider.hasUnsavedChanges && !formProvider.isLoading
                  ? () => _saveForm(context, asDraft: true)
                  : null,
                icon: const Icon(Icons.save_outlined, size: 18),
                label: const Text('ذخیره'),
                style: TextButton.styleFrom(
                  foregroundColor: formProvider.hasUnsavedChanges 
                      ? AppTheme.primaryColor 
                      : Colors.grey,
                  backgroundColor: formProvider.hasUnsavedChanges 
                      ? AppTheme.primaryColor.withOpacity(0.1)
                      : Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            );
          },
        ),
        
        // دکمه انتشار
        Consumer<FormBuilderProvider>(
          builder: (context, formProvider, child) {
            return Container(
              margin: const EdgeInsets.only(left: 8, right: 8),
              child: ElevatedButton.icon(
                onPressed: formProvider.hasWidgets && !formProvider.isLoading
                  ? () => _publishForm(context)
                  : null,
                icon: const Icon(Icons.publish_outlined, size: 18),
                label: Text(
                  widget.formId != null ? 'بروزرسانی' : 'انتشار',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: formProvider.hasWidgets 
                      ? AppTheme.successColor 
                      : Colors.grey.shade400,
                  foregroundColor: Colors.white,
                  elevation: formProvider.hasWidgets ? 2 : 0,
                  shadowColor: AppTheme.successColor.withOpacity(0.3),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// ساخت نوار ابزار پایین
  Widget _buildBottomBar(BuildContext context) {
    return Consumer<FormBuilderProvider>(
      builder: (context, formProvider, child) {
        return Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              
              // آیکون و تعداد ویجت‌ها
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.widgets,
                      size: 16,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${formProvider.widgetCount} ویجت',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 12),
              
              // وضعیت فرم
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(formProvider.formStatus).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getStatusColor(formProvider.formStatus),
                    width: 1,
                  ),
                ),
                child: Text(
                  _getStatusText(formProvider.formStatus),
                  style: TextStyle(
                    color: _getStatusColor(formProvider.formStatus),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              
              const Spacer(),
              
              // دکمه پاک کردن فرم
              if (formProvider.hasUnsavedChanges) ...[
                TextButton.icon(
                  onPressed: () => _clearForm(context),
                  icon: const Icon(Icons.clear_all, size: 18),
                  label: const Text('پاک کردن'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red.shade600,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              
              const SizedBox(width: 16),
            ],
          ),
        );
      },
    );
  }

  /// ساخت پیام‌های شناور
  Widget? _buildFloatingMessages(BuildContext context) {
    return Consumer<FormBuilderProvider>(
      builder: (context, formProvider, child) {
        if (formProvider.error != null) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.error, color: Colors.red.shade600, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    formProvider.error!,
                    style: TextStyle(
                      color: Colors.red.shade800,
                      fontSize: 14,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => formProvider.clearError(),
                  icon: Icon(Icons.close, color: Colors.red.shade600, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          );
        }
        
        if (formProvider.successMessage != null) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    formProvider.successMessage!,
                    style: TextStyle(
                      color: Colors.green.shade800,
                      fontSize: 14,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => formProvider.clearSuccess(),
                  icon: Icon(Icons.close, color: Colors.green.shade600, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          );
        }
        
        return const SizedBox.shrink();
      },
    );
  }

  /// ذخیره فرم
  Future<void> _saveForm(BuildContext context, {bool asDraft = true}) async {
    final formProvider = context.read<FormBuilderProvider>();
    
    // نمایش دیالوگ تنظیمات فرم اگر اطلاعات کامل نیست
    if (formProvider.persianTitle.isEmpty) {
      await _showFormSettingsDialog(context);
      return;
    }
    
    await formProvider.saveForm(asDraft: asDraft);
  }

  /// انتشار فرم
  Future<void> _publishForm(BuildContext context) async {
    final formProvider = context.read<FormBuilderProvider>();
    
    // اعتبارسنجی فرم
    final validation = formProvider.validateForm();
    if (!validation['valid']) {
      _showValidationDialog(context, validation);
      return;
    }
    
    // نمایش دیالوگ تأیید
    final confirmed = await _showPublishConfirmDialog(context);
    if (!confirmed) return;
    
    if (widget.formId != null) {
      await formProvider.updateForm();
    } else {
      await formProvider.saveForm(asDraft: false);
    }
  }

  /// نمایش پیش‌نمایش فرم
  void _showPreview(BuildContext context) {
    final formProvider = context.read<FormBuilderProvider>();
    final preview = formProvider.getFormPreview();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('پیش‌نمایش فرم'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('عنوان: ${preview['title']}'),
              if (preview['description'].isNotEmpty) 
                Text('توضیحات: ${preview['description']}'),
              const SizedBox(height: 16),
              Text('تعداد ویجت‌ها: ${preview['total_widgets']}'),
              Text('فیلدهای اجباری: ${preview['required_widgets']}'),
              const SizedBox(height: 16),
              const Text('انواع ویجت‌ها:'),
              ...Map<String, int>.from(preview['widget_types']).entries.map(
                (entry) => Text('• ${entry.key}: ${entry.value}'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('بستن'),
          ),
        ],
      ),
    );
  }

  /// پاک کردن فرم
  Future<void> _clearForm(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('پاک کردن فرم'),
        content: const Text('آیا مطمئن هستید که می‌خواهید فرم را پاک کنید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('پاک کردن'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      context.read<FormBuilderProvider>().clearForm();
    }
  }

  /// نمایش دیالوگ تنظیمات فرم
  Future<void> _showFormSettingsDialog(BuildContext context) async {
    // TODO: پیاده‌سازی دیالوگ تنظیمات فرم
  }

  /// نمایش دیالوگ اعتبارسنجی
  void _showValidationDialog(BuildContext context, Map<String, dynamic> validation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('خطاهای اعتبارسنجی'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (validation['errors'].isNotEmpty) ...[
                const Text('خطاها:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...List<String>.from(validation['errors']).map(
                  (error) => Text('• $error', style: const TextStyle(color: Colors.red)),
                ),
              ],
              if (validation['warnings'].isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text('هشدارها:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...List<String>.from(validation['warnings']).map(
                  (warning) => Text('• $warning', style: const TextStyle(color: Colors.orange)),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('باشه'),
          ),
        ],
      ),
    );
  }

  /// نمایش دیالوگ تأیید انتشار
  Future<bool> _showPublishConfirmDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.formId != null ? 'بروزرسانی فرم' : 'انتشار فرم'),
        content: Text(
          widget.formId != null 
            ? 'آیا مطمئن هستید که می‌خواهید فرم را بروزرسانی کنید؟'
            : 'آیا مطمئن هستید که می‌خواهید فرم را منتشر کنید؟'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
            ),
            child: Text(widget.formId != null ? 'بروزرسانی' : 'انتشار'),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }

  /// دریافت رنگ وضعیت
  Color _getStatusColor(String status) {
    switch (status) {
      case 'published':
        return Colors.green;
      case 'draft':
        return Colors.orange;
      case 'paused':
        return Colors.blue;
      case 'archived':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  /// دریافت متن وضعیت
  String _getStatusText(String status) {
    switch (status) {
      case 'published':
        return 'منتشر شده';
      case 'draft':
        return 'پیش‌نویس';
      case 'paused':
        return 'متوقف';
      case 'archived':
        return 'آرشیو';
      default:
        return 'نامشخص';
    }
  }
}
