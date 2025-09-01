import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/form_builder_provider.dart';

/// پنل تنظیمات ویجت - Properties Panel
/// تنظیمات و خصوصیات ویجت انتخاب شده
class PropertiesPanel extends StatefulWidget {
  const PropertiesPanel({super.key});

  @override
  State<PropertiesPanel> createState() => _PropertiesPanelState();
}

class _PropertiesPanelState extends State<PropertiesPanel> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _getController(String key, String initialValue) {
    if (!_controllers.containsKey(key)) {
      _controllers[key] = TextEditingController(text: initialValue);
    }
    return _controllers[key]!;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FormBuilderProvider>(
      builder: (context, formProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(
              color: Theme.of(context).dividerColor,
              width: 0.5,
            ),
          ),
          child: Column(
            children: [
              _buildHeader(context, formProvider),
              Expanded(
                child: formProvider.selectedWidget != null
                    ? _buildPropertiesContent(context, formProvider)
                    : _buildEmptyState(context),
              ),
            ],
          ),
        );
      },
    );
  }

  /// هدر پنل
  Widget _buildHeader(BuildContext context, FormBuilderProvider formProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.tune,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              formProvider.selectedWidget != null
                  ? 'تنظیمات ${_getWidgetTypeLabel(formProvider.selectedWidget!['widget_type'] ?? 'text')}'
                  : 'تنظیمات ویجت',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          // دکمه بستن در نسخه موبایل
          if (MediaQuery.of(context).size.width < 768)
            IconButton(
              onPressed: () => context.read<FormBuilderProvider>().deselectWidget(),
              icon: const Icon(Icons.close),
              iconSize: 18,
            ),
        ],
      ),
    );
  }

  /// محتوای تنظیمات
  Widget _buildPropertiesContent(BuildContext context, FormBuilderProvider formProvider) {
    final widget = formProvider.selectedWidget!;
    final widgetType = widget['widget_type'] ?? 'text';
    final properties = Map<String, dynamic>.from(widget['properties'] ?? {});

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // اطلاعات اولیه ویجت
          _buildBasicInfo(context, formProvider, widget, properties),
          
          const SizedBox(height: 24),
          
          // تنظیمات عمومی
          _buildGeneralSettings(context, formProvider, widget, properties),
          
          const SizedBox(height: 24),
          
          // تنظیمات اختصاصی بر اساس نوع ویجت
          _buildSpecificSettings(context, formProvider, widget, widgetType, properties),
          
          const SizedBox(height: 24),
          
          // تنظیمات اعتبارسنجی
          _buildValidationSettings(context, formProvider, widget, properties),
          
          const SizedBox(height: 24),
          
          // تنظیمات ظاهری
          _buildAppearanceSettings(context, formProvider, widget, properties),
          
          const SizedBox(height: 32),
          
          // دکمه‌های عملیات
          _buildActionButtons(context, formProvider, widget),
        ],
      ),
    );
  }

  /// اطلاعات اولیه ویجت
  Widget _buildBasicInfo(
    BuildContext context,
    FormBuilderProvider formProvider,
    Map<String, dynamic> widget,
    Map<String, dynamic> properties,
  ) {
    return _buildSection(
      context,
      'اطلاعات کلی',
      Icons.info_outline,
      [
        // برچسب
        _buildTextField(
          context,
          'برچسب',
          'label',
          properties['label'] ?? widget['persian_label'] ?? '',
          'نام فیلد را وارد کنید...',
          (value) => _updateProperty(formProvider, widget['id'], 'label', value),
        ),
        
        const SizedBox(height: 16),
        
        // نام فیلد (name attribute)
        _buildTextField(
          context,
          'نام فیلد (name)',
          'name',
          properties['name'] ?? _generateFieldName(properties['label'] ?? ''),
          'نام فیلد برای HTML...',
          (value) => _updateProperty(formProvider, widget['id'], 'name', value),
        ),
        
        const SizedBox(height: 16),
        
        // متن راهنما
        _buildTextField(
          context,
          'متن راهنما',
          'placeholder',
          properties['placeholder'] ?? '',
          'متن کمکی برای کاربر...',
          (value) => _updateProperty(formProvider, widget['id'], 'placeholder', value),
        ),
      ],
    );
  }

  /// تنظیمات عمومی
  Widget _buildGeneralSettings(
    BuildContext context,
    FormBuilderProvider formProvider,
    Map<String, dynamic> widget,
    Map<String, dynamic> properties,
  ) {
    return _buildSection(
      context,
      'تنظیمات عمومی',
      Icons.settings,
      [
        // اجباری بودن
        _buildSwitchTile(
          context,
          'فیلد اجباری',
          'این فیلد باید توسط کاربر پر شود',
          properties['required'] == true,
          (value) => _updateProperty(formProvider, widget['id'], 'required', value),
        ),
        
        const SizedBox(height: 8),
        
        // قابلیت ویرایش
        _buildSwitchTile(
          context,
          'قابل ویرایش',
          'کاربر می‌تواند در این فیلد تایپ کند',
          properties['enabled'] != false,
          (value) => _updateProperty(formProvider, widget['id'], 'enabled', value),
        ),
        
        const SizedBox(height: 8),
        
        // نمایش برچسب
        _buildSwitchTile(
          context,
          'نمایش برچسب',
          'برچسب فیلد نمایش داده شود',
          properties['show_label'] != false,
          (value) => _updateProperty(formProvider, widget['id'], 'show_label', value),
        ),
      ],
    );
  }

  /// تنظیمات اختصاصی
  Widget _buildSpecificSettings(
    BuildContext context,
    FormBuilderProvider formProvider,
    Map<String, dynamic> widget,
    String widgetType,
    Map<String, dynamic> properties,
  ) {
    switch (widgetType) {
      case 'textarea':
        return _buildTextAreaSettings(context, formProvider, widget, properties);
      case 'number':
        return _buildNumberSettings(context, formProvider, widget, properties);
      case 'select':
      case 'radio':
      case 'checkbox':
        return _buildOptionsSettings(context, formProvider, widget, properties);
      case 'file':
        return _buildFileSettings(context, formProvider, widget, properties);
      default:
        return _buildTextSettings(context, formProvider, widget, properties);
    }
  }

  /// تنظیمات متن چندخطی
  Widget _buildTextAreaSettings(
    BuildContext context,
    FormBuilderProvider formProvider,
    Map<String, dynamic> widget,
    Map<String, dynamic> properties,
  ) {
    return _buildSection(
      context,
      'تنظیمات متن چندخطی',
      Icons.subject,
      [
        Row(
          children: [
            Expanded(
              child: _buildNumberField(
                context,
                'حداقل ردیف',
                properties['min_lines']?.toString() ?? '2',
                (value) => _updateProperty(formProvider, widget['id'], 'min_lines', int.tryParse(value) ?? 2),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildNumberField(
                context,
                'حداکثر ردیف',
                properties['max_lines']?.toString() ?? '5',
                (value) => _updateProperty(formProvider, widget['id'], 'max_lines', int.tryParse(value) ?? 5),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        _buildNumberField(
          context,
          'حداکثر تعداد کاراکتر',
          properties['max_length']?.toString() ?? '',
          (value) => _updateProperty(
            formProvider,
            widget['id'],
            'max_length',
            value.isEmpty ? null : int.tryParse(value),
          ),
        ),
      ],
    );
  }

  /// تنظیمات عدد
  Widget _buildNumberSettings(
    BuildContext context,
    FormBuilderProvider formProvider,
    Map<String, dynamic> widget,
    Map<String, dynamic> properties,
  ) {
    return _buildSection(
      context,
      'تنظیمات عدد',
      Icons.numbers,
      [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                context,
                'حداقل مقدار',
                'min',
                properties['min']?.toString() ?? '',
                'کمترین عدد مجاز...',
                (value) => _updateProperty(
                  formProvider,
                  widget['id'],
                  'min',
                  value.isEmpty ? null : double.tryParse(value),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                context,
                'حداکثر مقدار',
                'max',
                properties['max']?.toString() ?? '',
                'بیشترین عدد مجاز...',
                (value) => _updateProperty(
                  formProvider,
                  widget['id'],
                  'max',
                  value.isEmpty ? null : double.tryParse(value),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        _buildTextField(
          context,
          'گام (Step)',
          'step',
          properties['step']?.toString() ?? '1',
          'گام افزایش/کاهش...',
          (value) => _updateProperty(
            formProvider,
            widget['id'],
            'step',
            double.tryParse(value) ?? 1,
          ),
        ),
        
        const SizedBox(height: 8),
        
        _buildSwitchTile(
          context,
          'اعداد اعشاری',
          'امکان وارد کردن اعداد اعشاری',
          properties['allow_decimal'] == true,
          (value) => _updateProperty(formProvider, widget['id'], 'allow_decimal', value),
        ),
      ],
    );
  }

  /// تنظیمات گزینه‌ای
  Widget _buildOptionsSettings(
    BuildContext context,
    FormBuilderProvider formProvider,
    Map<String, dynamic> widget,
    Map<String, dynamic> properties,
  ) {
    final options = List<String>.from(properties['options'] ?? ['گزینه ۱', 'گزینه ۲']);
    
    return _buildSection(
      context,
      'گزینه‌ها',
      Icons.list,
      [
        ...options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _getController('option_$index', option),
                    decoration: InputDecoration(
                      labelText: 'گزینه ${index + 1}',
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onChanged: (value) {
                      options[index] = value;
                      _updateProperty(formProvider, widget['id'], 'options', options);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: options.length > 1 ? () {
                    options.removeAt(index);
                    _updateProperty(formProvider, widget['id'], 'options', options);
                    setState(() {});
                  } : null,
                  icon: const Icon(Icons.delete_outline),
                  color: Theme.of(context).colorScheme.error,
                ),
              ],
            ),
          );
        }),
        
        const SizedBox(height: 16),
        
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              options.add('گزینه جدید');
              _updateProperty(formProvider, widget['id'], 'options', options);
              setState(() {});
            },
            icon: const Icon(Icons.add),
            label: const Text('افزودن گزینه'),
          ),
        ),
      ],
    );
  }

  /// تنظیمات فایل
  Widget _buildFileSettings(
    BuildContext context,
    FormBuilderProvider formProvider,
    Map<String, dynamic> widget,
    Map<String, dynamic> properties,
  ) {
    return _buildSection(
      context,
      'تنظیمات فایل',
      Icons.attach_file,
      [
        _buildTextField(
          context,
          'انواع فایل مجاز',
          'accept',
          properties['accept'] ?? '',
          'مثال: .pdf,.jpg,.png',
          (value) => _updateProperty(formProvider, widget['id'], 'accept', value),
        ),
        
        const SizedBox(height: 16),
        
        _buildNumberField(
          context,
          'حداکثر اندازه (مگابایت)',
          properties['max_size']?.toString() ?? '5',
          (value) => _updateProperty(
            formProvider,
            widget['id'],
            'max_size',
            double.tryParse(value) ?? 5,
          ),
        ),
        
        const SizedBox(height: 8),
        
        _buildSwitchTile(
          context,
          'چندین فایل',
          'امکان انتخاب چندین فایل همزمان',
          properties['multiple'] == true,
          (value) => _updateProperty(formProvider, widget['id'], 'multiple', value),
        ),
      ],
    );
  }

  /// تنظیمات متن ساده
  Widget _buildTextSettings(
    BuildContext context,
    FormBuilderProvider formProvider,
    Map<String, dynamic> widget,
    Map<String, dynamic> properties,
  ) {
    return _buildSection(
      context,
      'تنظیمات متن',
      Icons.text_fields,
      [
        Row(
          children: [
            Expanded(
              child: _buildNumberField(
                context,
                'حداقل طول',
                properties['min_length']?.toString() ?? '',
                (value) => _updateProperty(
                  formProvider,
                  widget['id'],
                  'min_length',
                  value.isEmpty ? null : int.tryParse(value),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildNumberField(
                context,
                'حداکثر طول',
                properties['max_length']?.toString() ?? '',
                (value) => _updateProperty(
                  formProvider,
                  widget['id'],
                  'max_length',
                  value.isEmpty ? null : int.tryParse(value),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// تنظیمات اعتبارسنجی
  Widget _buildValidationSettings(
    BuildContext context,
    FormBuilderProvider formProvider,
    Map<String, dynamic> widget,
    Map<String, dynamic> properties,
  ) {
    return _buildSection(
      context,
      'اعتبارسنجی',
      Icons.verified,
      [
        _buildTextField(
          context,
          'پیام خطا سفارشی',
          'error_message',
          properties['error_message'] ?? '',
          'پیام خطا برای اعتبارسنجی...',
          (value) => _updateProperty(formProvider, widget['id'], 'error_message', value),
        ),
        
        const SizedBox(height: 16),
        
        _buildTextField(
          context,
          'الگو (Regex)',
          'pattern',
          properties['pattern'] ?? '',
          'الگوی اعتبارسنجی...',
          (value) => _updateProperty(formProvider, widget['id'], 'pattern', value),
        ),
      ],
    );
  }

  /// تنظیمات ظاهری
  Widget _buildAppearanceSettings(
    BuildContext context,
    FormBuilderProvider formProvider,
    Map<String, dynamic> widget,
    Map<String, dynamic> properties,
  ) {
    return _buildSection(
      context,
      'ظاهر',
      Icons.palette,
      [
        _buildTextField(
          context,
          'کلاس CSS سفارشی',
          'css_class',
          properties['css_class'] ?? '',
          'کلاس‌های CSS اضافی...',
          (value) => _updateProperty(formProvider, widget['id'], 'css_class', value),
        ),
      ],
    );
  }

  /// حالت خالی
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.touch_app,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 24),
            Text(
              'ویجتی انتخاب نشده',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'برای مشاهده و ویرایش تنظیمات، روی یکی از ویجت‌های فرم کلیک کنید.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// دکمه‌های عملیات
  Widget _buildActionButtons(
    BuildContext context,
    FormBuilderProvider formProvider,
    Map<String, dynamic> widget,
  ) {
    return Column(
      children: [
        // دکمه کپی
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => formProvider.duplicateWidget(widget['id']),
            icon: const Icon(Icons.content_copy),
            label: const Text('کپی ویجت'),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // دکمه حذف
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _confirmDeleteWidget(context, formProvider, widget),
            icon: const Icon(Icons.delete_outline),
            label: const Text('حذف ویجت'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              side: BorderSide(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ),
      ],
    );
  }

  /// ساخت بخش
  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  /// ساخت فیلد متنی
  Widget _buildTextField(
    BuildContext context,
    String label,
    String key,
    String initialValue,
    String hint,
    Function(String) onChanged,
  ) {
    return TextField(
      controller: _getController(key, initialValue),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      onChanged: onChanged,
    );
  }

  /// ساخت فیلد عددی
  Widget _buildNumberField(
    BuildContext context,
    String label,
    String initialValue,
    Function(String) onChanged,
  ) {
    return TextField(
      controller: _getController('${label}_num', initialValue),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      keyboardType: TextInputType.number,
      onChanged: onChanged,
    );
  }

  /// ساخت تایل سوییچ
  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return SwitchListTile(
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
      value: value,
      onChanged: onChanged,
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }

  /// بروزرسانی خصوصیت ویجت
  void _updateProperty(
    FormBuilderProvider formProvider,
    String widgetId,
    String propertyKey,
    dynamic propertyValue,
  ) {
    final properties = Map<String, dynamic>.from(
      formProvider.selectedWidget?['properties'] ?? {},
    );
    properties[propertyKey] = propertyValue;
    formProvider.updateWidgetProperties(widgetId, properties);
  }

  /// برچسب نوع ویجت
  String _getWidgetTypeLabel(String widgetType) {
    switch (widgetType) {
      case 'text': return 'متن';
      case 'textarea': return 'متن چندخطی';
      case 'number': return 'عدد';
      case 'email': return 'ایمیل';
      case 'phone': return 'تلفن';
      case 'select': return 'انتخابی';
      case 'radio': return 'رادیو';
      case 'checkbox': return 'چندانتخابی';
      case 'date': return 'تاریخ';
      case 'time': return 'زمان';
      case 'file': return 'فایل';
      case 'submit': return 'ارسال';
      default: return 'نامشخص';
    }
  }

  /// تولید نام فیلد
  String _generateFieldName(String label) {
    return label
        .toLowerCase()
        .replaceAll(RegExp(r'[^\u0600-\u06FF\w\s]'), '') // حذف کاراکترهای خاص
        .replaceAll(' ', '_')
        .replaceAll('ی', 'i')
        .replaceAll('ک', 'k');
  }

  /// تأیید حذف ویجت
  void _confirmDeleteWidget(
    BuildContext context,
    FormBuilderProvider formProvider,
    Map<String, dynamic> widget,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف ویجت'),
        content: Text('آیا مطمئن هستید که می‌خواهید "${widget['persian_label']}" را حذف کنید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () {
              formProvider.removeWidgetFromCanvas(widget['id'] ?? '');
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
