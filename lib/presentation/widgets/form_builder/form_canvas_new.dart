import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/form_builder_provider.dart';
import '../../../core/models/widget_model.dart';

/// بوم طراحی فرم - Form Design Canvas
/// محل کشیدن و رها کردن ویجت‌ها برای ساخت فرم
class FormCanvas extends StatelessWidget {
  const FormCanvas({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Consumer<FormBuilderProvider>(
      builder: (context, provider, child) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.2),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: provider.canvasWidgets.isEmpty
              ? _buildEmptyCanvas(context)
              : _buildCanvasWithWidgets(context, provider),
        );
      },
    );
  }

  /// بوم خالی - Empty canvas placeholder
  Widget _buildEmptyCanvas(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return DragTarget<FormWidgetModel>(
      onAccept: (widget) {
        final provider = context.read<FormBuilderProvider>();
        // تبدیل widget به Map format که provider انتظار دارد
        final widgetData = {
          'id': widget.id?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
          'type': widget.widgetType,
          'label': widget.persianLabel,
          'config': widget.widgetConfig,
          'validation_rules': widget.validationRules ?? {},
          'default_props': widget.defaultProps ?? {},
        };
        provider.addWidgetToCanvas(widgetData);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        
        return Container(
          decoration: BoxDecoration(
            color: isHovering 
                ? colorScheme.primaryContainer.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.drag_indicator_outlined,
                  size: 64,
                  color: colorScheme.outline.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'ویجت‌ها را اینجا بکشید',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.outline,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'برای ساخت فرم، ویجت‌های مورد نظر را از کتابخانه به اینجا بکشید',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.outline.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// بوم با ویجت‌ها - Canvas with widgets
  Widget _buildCanvasWithWidgets(BuildContext context, FormBuilderProvider provider) {
    return DragTarget<FormWidgetModel>(
      onAccept: (widget) {
        // تبدیل widget به Map format که provider انتظار دارد
        final widgetData = {
          'id': widget.id?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
          'type': widget.widgetType,
          'label': widget.persianLabel,
          'config': widget.widgetConfig,
          'validation_rules': widget.validationRules ?? {},
          'default_props': widget.defaultProps ?? {},
        };
        provider.addWidgetToCanvas(widgetData);
      },
      builder: (context, candidateData, rejectedData) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // نمایش ویجت‌های اضافه شده
              ...provider.canvasWidgets.asMap().entries.map((entry) {
                final index = entry.key;
                final widget = entry.value;
                return _buildCanvasWidget(context, widget, index, provider);
              }),
              
              // منطقه اضافه کردن ویجت جدید
              const SizedBox(height: 24),
              _buildAddWidgetZone(context, candidateData.isNotEmpty),
            ],
          ),
        );
      },
    );
  }

  /// ویجت روی بوم - Widget on canvas
  Widget _buildCanvasWidget(
    BuildContext context, 
    Map<String, dynamic> widget, 
    int index, 
    FormBuilderProvider provider
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final widgetId = widget['id'] as String? ?? index.toString();
    final isSelected = provider.selectedWidgetId == widgetId;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected 
              ? colorScheme.primary 
              : colorScheme.outline.withValues(alpha: 0.3),
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: isSelected 
            ? colorScheme.primaryContainer.withValues(alpha: 0.1)
            : colorScheme.surface,
      ),
      child: Stack(
        children: [
          // محتوای ویجت
          GestureDetector(
            onTap: () => provider.selectWidget(widgetId),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              child: _buildWidgetPreview(context, widget),
            ),
          ),
          
          // دکمه حذف
          if (isSelected)
            Positioned(
              top: 4,
              left: 4,
              child: GestureDetector(
                onTap: () => provider.removeWidgetFromCanvas(widgetId),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colorScheme.error,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: colorScheme.onError,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// پیش‌نمایش ویجت - Widget preview
  Widget _buildWidgetPreview(BuildContext context, Map<String, dynamic> widget) {
    final theme = Theme.of(context);
    final widgetType = widget['type'] as String? ?? 'text';
    final widgetLabel = widget['label'] as String? ?? 'ویجت';
    
    switch (widgetType) {
      case 'text':
        return TextFormField(
          decoration: InputDecoration(
            labelText: widgetLabel,
            hintText: 'متن خود را وارد کنید...',
            border: const OutlineInputBorder(),
          ),
          enabled: false,
        );
        
      case 'textarea':
        return TextFormField(
          decoration: InputDecoration(
            labelText: widgetLabel,
            hintText: 'متن طولانی خود را وارد کنید...',
            border: const OutlineInputBorder(),
          ),
          maxLines: 3,
          enabled: false,
        );
        
      case 'number':
        return TextFormField(
          decoration: InputDecoration(
            labelText: widgetLabel,
            hintText: '۰',
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.numbers),
          ),
          keyboardType: TextInputType.number,
          enabled: false,
        );
        
      case 'email':
        return TextFormField(
          decoration: InputDecoration(
            labelText: widgetLabel,
            hintText: 'example@domain.com',
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.email_outlined),
          ),
          keyboardType: TextInputType.emailAddress,
          enabled: false,
        );
        
      case 'select':
        return DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: widgetLabel,
            border: const OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: '1', child: Text('گزینه ۱')),
            DropdownMenuItem(value: '2', child: Text('گزینه ۲')),
            DropdownMenuItem(value: '3', child: Text('گزینه ۳')),
          ],
          onChanged: null,
        );
        
      case 'radio':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widgetLabel, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            ...['گزینه ۱', 'گزینه ۲', 'گزینه ۳'].map((option) => 
              RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: 'گزینه ۱',
                onChanged: null,
                dense: true,
              ),
            ),
          ],
        );
        
      case 'checkbox':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widgetLabel, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            ...['گزینه ۱', 'گزینه ۲', 'گزینه ۳'].map((option) => 
              CheckboxListTile(
                title: Text(option),
                value: option == 'گزینه ۱',
                onChanged: null,
                dense: true,
              ),
            ),
          ],
        );
        
      case 'date':
        return TextFormField(
          decoration: InputDecoration(
            labelText: widgetLabel,
            hintText: '۱۴۰۳/۰۶/۱۰',
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          enabled: false,
        );
        
      case 'time':
        return TextFormField(
          decoration: InputDecoration(
            labelText: widgetLabel,
            hintText: '۱۴:۳۰',
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.access_time),
          ),
          enabled: false,
        );
        
      case 'submit':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: null,
            child: Text(widgetLabel),
          ),
        );
        
      default:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'ویجت $widgetType',
            style: theme.textTheme.bodyMedium,
          ),
        );
    }
  }

  /// منطقه اضافه کردن ویجت - Add widget zone
  Widget _buildAddWidgetZone(BuildContext context, bool isHovering) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: isHovering 
            ? colorScheme.primaryContainer.withValues(alpha: 0.1)
            : Colors.transparent,
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.3),
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              color: colorScheme.outline.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 8),
            Text(
              'ویجت جدید اضافه کنید',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.outline.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
