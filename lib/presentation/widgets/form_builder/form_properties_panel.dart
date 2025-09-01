import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/form_builder_provider.dart';
import '../../../core/models/simple_widget_model.dart';
import '../../../core/theme/app_theme.dart';

/// پنل تنظیمات ویجت - Widget Properties Panel
class FormPropertiesPanel extends StatefulWidget {
  final String widgetId;
  final VoidCallback onClose;

  const FormPropertiesPanel({
    super.key,
    required this.widgetId,
    required this.onClose,
  });

  @override
  State<FormPropertiesPanel> createState() => _FormPropertiesPanelState();
}

class _FormPropertiesPanelState extends State<FormPropertiesPanel> {
  late TextEditingController _labelController;
  late TextEditingController _placeholderController;
  late TextEditingController _hintController;
  bool _isRequired = false;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController();
    _placeholderController = TextEditingController();
    _hintController = TextEditingController();

    // بارگیری اطلاعات ویجت
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWidgetData();
    });
  }

  @override
  void dispose() {
    _labelController.dispose();
    _placeholderController.dispose();
    _hintController.dispose();
    super.dispose();
  }

  void _loadWidgetData() {
    final formProvider = context.read<FormBuilderProvider>();
    final foundWidget = formProvider.widgets.firstWhere(
      (w) => w.id == widget.widgetId,
      orElse: () => const WidgetModel(
        id: '',
        type: 'text_field',
        persianLabel: '',
        englishLabel: '',
      ),
    );

    if (foundWidget.id.isNotEmpty) {
      _labelController.text = foundWidget.persianLabel;
      _placeholderController.text = foundWidget.config['placeholder'] ?? '';
      _hintController.text = foundWidget.config['hint'] ?? '';
      _isRequired = foundWidget.isRequired;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      height: double.infinity,
      color: Colors.white,
      child: Column(
        children: [
          // هدر
          _buildHeader(),
          
          // محتوا
          Expanded(
            child: Consumer<FormBuilderProvider>(
              builder: (context, formProvider, child) {
                final selectedWidget = formProvider.widgets.firstWhere(
                  (w) => w.id == widget.widgetId,
                  orElse: () => const WidgetModel(
                    id: '',
                    type: 'text_field',
                    persianLabel: '',
                    englishLabel: '',
                  ),
                );

                if (selectedWidget.id.isEmpty) {
                  return const Center(
                    child: Text('ویجت یافت نشد'),
                  );
                }

                return _buildPropertiesForm(selectedWidget, formProvider);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// ساخت هدر
  Widget _buildHeader() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.settings,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 8),
          const Text(
            'تنظیمات ویجت',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: widget.onClose,
            icon: const Icon(Icons.close),
            iconSize: 20,
          ),
        ],
      ),
    );
  }

  /// ساخت فرم تنظیمات
  Widget _buildPropertiesForm(WidgetModel widget, FormBuilderProvider formProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // نوع ویجت
          _buildInfoCard(widget),
          
          const SizedBox(height: 16),
          
          // عنوان ویجت
          _buildTextField(
            label: 'عنوان ویجت',
            controller: _labelController,
            onChanged: (value) {
              _updateWidget(formProvider, widget.copyWith(
                persianLabel: value,
              ));
            },
          ),
          
          const SizedBox(height: 16),
          
          // متن راهنما
          _buildTextField(
            label: 'متن راهنما (Placeholder)',
            controller: _placeholderController,
            onChanged: (value) {
              _updateWidget(formProvider, widget.copyWith(
                config: {
                  ...widget.config,
                  'placeholder': value,
                },
              ));
            },
          ),
          
          const SizedBox(height: 16),
          
          // راهنمای کمکی
          _buildTextField(
            label: 'راهنمای کمکی',
            controller: _hintController,
            maxLines: 2,
            onChanged: (value) {
              _updateWidget(formProvider, widget.copyWith(
                config: {
                  ...widget.config,
                  'hint': value,
                },
              ));
            },
          ),
          
          const SizedBox(height: 20),
          
          // تنظیمات بولی
          _buildSwitchTile(
            title: 'فیلد اجباری',
            subtitle: 'کاربر باید این فیلد را پر کند',
            value: _isRequired,
            onChanged: (value) {
              setState(() {
                _isRequired = value;
              });
              _updateWidget(formProvider, widget.copyWith(
                isRequired: value,
              ));
            },
          ),
          
          const SizedBox(height: 16),
          
          // تنظیمات مخصوص نوع ویجت
          ..._buildWidgetSpecificSettings(widget, formProvider),
          
          const SizedBox(height: 20),
          
          // دکمه‌های عملیات
          _buildActionButtons(formProvider, widget),
        ],
      ),
    );
  }

  /// کارت اطلاعات ویجت
  Widget _buildInfoCard(WidgetModel widget) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getWidgetIcon(widget.type),
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getWidgetTypeName(widget.type),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'شناسه: ${widget.id}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// فیلد متنی
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppTheme.primaryColor),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
          textDirection: TextDirection.rtl,
        ),
      ],
    );
  }

  /// کلید تغییر حالت
  Widget _buildSwitchTile({
    required String title,
    String? subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  /// تنظیمات مخصوص نوع ویجت
  List<Widget> _buildWidgetSpecificSettings(WidgetModel widget, FormBuilderProvider formProvider) {
    switch (widget.type) {
      case 'dropdown':
      case 'radio':
      case 'checkbox':
        return [_buildOptionsEditor(widget, formProvider)];
      case 'textarea':
        return [_buildTextAreaSettings(widget, formProvider)];
      case 'number':
        return [_buildNumberSettings(widget, formProvider)];
      default:
        return [];
    }
  }

  /// ویرایشگر گزینه‌ها
  Widget _buildOptionsEditor(WidgetModel widget, FormBuilderProvider formProvider) {
    final options = List<Map<String, dynamic>>.from(widget.options ?? []);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'گزینه‌ها',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        ...options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: option['label'] ?? '',
                    decoration: InputDecoration(
                      hintText: 'گزینه ${index + 1}',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onChanged: (value) {
                      options[index] = {
                        'value': 'option_${index + 1}',
                        'label': value,
                      };
                      _updateWidget(formProvider, widget.copyWith(
                        options: options,
                      ));
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    options.removeAt(index);
                    _updateWidget(formProvider, widget.copyWith(
                      options: options,
                    ));
                  },
                  icon: const Icon(Icons.remove_circle_outline),
                  iconSize: 20,
                  color: Colors.red,
                ),
              ],
            ),
          );
        }),
        
        // دکمه افزودن گزینه
        OutlinedButton.icon(
          onPressed: () {
            options.add({
              'value': 'option_${options.length + 1}',
              'label': 'گزینه ${options.length + 1}',
            });
            _updateWidget(formProvider, widget.copyWith(
              options: options,
            ));
          },
          icon: const Icon(Icons.add),
          label: const Text('افزودن گزینه'),
        ),
      ],
    );
  }

  /// تنظیمات متن چندخطی
  Widget _buildTextAreaSettings(WidgetModel widget, FormBuilderProvider formProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'تعداد خطوط',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: (widget.config['rows'] ?? 4).toString(),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
          onChanged: (value) {
            final rows = int.tryParse(value) ?? 4;
            _updateWidget(formProvider, widget.copyWith(
              config: {
                ...widget.config,
                'rows': rows,
              },
            ));
          },
        ),
      ],
    );
  }

  /// تنظیمات عدد
  Widget _buildNumberSettings(WidgetModel widget, FormBuilderProvider formProvider) {
    return Column(
      children: [
        _buildTextField(
          label: 'حداقل مقدار',
          controller: TextEditingController(
            text: widget.config['min']?.toString() ?? '',
          ),
          onChanged: (value) {
            final min = int.tryParse(value);
            _updateWidget(formProvider, widget.copyWith(
              config: {
                ...widget.config,
                'min': min,
              },
            ));
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'حداکثر مقدار',
          controller: TextEditingController(
            text: widget.config['max']?.toString() ?? '',
          ),
          onChanged: (value) {
            final max = int.tryParse(value);
            _updateWidget(formProvider, widget.copyWith(
              config: {
                ...widget.config,
                'max': max,
              },
            ));
          },
        ),
      ],
    );
  }

  /// دکمه‌های عملیات
  Widget _buildActionButtons(FormBuilderProvider formProvider, WidgetModel widget) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              formProvider.removeWidget(widget.id);
              this.widget.onClose();
            },
            icon: const Icon(Icons.delete_outline),
            label: const Text('حذف ویجت'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: کپی ویجت
            },
            icon: const Icon(Icons.copy_outlined),
            label: const Text('کپی ویجت'),
          ),
        ),
      ],
    );
  }

  /// بروزرسانی ویجت
  void _updateWidget(FormBuilderProvider formProvider, WidgetModel updatedWidget) {
    formProvider.updateWidget(widget.widgetId, updatedWidget);
  }

  /// دریافت آیکون ویجت
  IconData _getWidgetIcon(String type) {
    switch (type) {
      case 'text_field':
        return Icons.text_fields;
      case 'textarea':
        return Icons.text_snippet_outlined;
      case 'email':
        return Icons.email_outlined;
      case 'phone':
        return Icons.phone_outlined;
      case 'number':
        return Icons.numbers;
      case 'dropdown':
        return Icons.arrow_drop_down_circle_outlined;
      case 'radio':
        return Icons.radio_button_checked;
      case 'checkbox':
        return Icons.check_box_outlined;
      case 'date':
        return Icons.calendar_today_outlined;
      case 'time':
        return Icons.access_time_outlined;
      case 'file':
        return Icons.attach_file_outlined;
      default:
        return Icons.widgets;
    }
  }

  /// دریافت نام نوع ویجت
  String _getWidgetTypeName(String type) {
    switch (type) {
      case 'text_field':
        return 'فیلد متن';
      case 'textarea':
        return 'متن چندخطی';
      case 'email':
        return 'ایمیل';
      case 'phone':
        return 'شماره تلفن';
      case 'number':
        return 'عدد';
      case 'dropdown':
        return 'لیست کشویی';
      case 'radio':
        return 'رادیو باتن';
      case 'checkbox':
        return 'چک‌باکس';
      case 'date':
        return 'تاریخ';
      case 'time':
        return 'زمان';
      case 'file':
        return 'آپلود فایل';
      default:
        return 'ویجت';
    }
  }
}
