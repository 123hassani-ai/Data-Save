import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/widget_library_provider.dart';
import '../../../core/models/simple_widget_model.dart';
import '../../../core/theme/app_theme.dart';

/// پنل کتابخانه ویجت‌ها - Widget Library Panel
class WidgetLibraryPanel extends StatefulWidget {
  const WidgetLibraryPanel({super.key});

  @override
  State<WidgetLibraryPanel> createState() => _WidgetLibraryPanelState();
}

class _WidgetLibraryPanelState extends State<WidgetLibraryPanel> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'همه';

  final Map<String, String> _categories = {
    'همه': 'all',
    'فیلدهای متن': 'text',
    'انتخاب': 'selection',
    'تاریخ و زمان': 'datetime',
    'فایل': 'file',
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(-2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // هدر با گرادیان زیبا
          _buildHeader(),
          
          // جستجو با طراحی مدرن
          _buildSearchBar(),
          
          // دسته‌بندی‌ها با تب‌های زیبا
          _buildCategoryTabs(),
          
          // لیست ویجت‌ها
          Expanded(
            child: _buildWidgetList(),
          ),
        ],
      ),
    );
  }

  /// ساخت هدر
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.widgets_outlined,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'کتابخانه ویجت‌ها',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'اجزای فرم',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ساخت نوار جستجو
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          hintText: 'جستجوی ویجت...',
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey.shade500,
            size: 20,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Colors.grey.shade500,
                    size: 18,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }

  /// ساخت تب‌های دسته‌بندی
  Widget _buildCategoryTabs() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _categories.keys.length,
        itemBuilder: (context, index) {
          final categoryName = _categories.keys.elementAt(index);
          final isSelected = _selectedCategory == categoryName;
          
          return Container(
            margin: const EdgeInsets.only(left: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedCategory = categoryName;
                  });
                  context.read<WidgetLibraryProvider>()
                      .changeCategory(_categories[categoryName]!);
                },
                borderRadius: BorderRadius.circular(25),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected 
                        ? LinearGradient(
                            colors: [
                              AppTheme.primaryColor,
                              AppTheme.primaryColor.withOpacity(0.8),
                            ],
                          )
                        : null,
                    color: isSelected 
                        ? null 
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                    border: !isSelected
                        ? Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          )
                        : null,
                  ),
                  child: Text(
                    categoryName,
                    style: TextStyle(
                      color: isSelected 
                          ? Colors.white 
                          : Colors.grey.shade700,
                      fontSize: 13,
                      fontWeight: isSelected 
                          ? FontWeight.w600 
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// ساخت لیست ویجت‌ها
  Widget _buildWidgetList() {
    return Consumer<WidgetLibraryProvider>(
      builder: (context, provider, child) {
        final widgets = provider.filteredWidgets;
        
        if (widgets.isEmpty) {
          return _buildEmptyState();
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: widgets.length,
          itemBuilder: (context, index) {
            return _buildWidgetItem(widgets[index]);
          },
        );
      },
    );
  }

  /// ساخت آیتم ویجت
  Widget _buildWidgetItem(Map<String, dynamic> widgetData) {
    // تبدیل Map به WidgetModel برای سازگاری
    final widget = WidgetModel(
      id: widgetData['id']?.toString() ?? 'unknown',
      type: widgetData['widget_type'] ?? widgetData['type'] ?? 'text',
      persianLabel: widgetData['persian_label'] ?? widgetData['label'] ?? 'ویجت',
      englishLabel: widgetData['english_label'] ?? '',
      isRequired: widgetData['is_required'] ?? false,
      order: widgetData['display_order'] ?? 0,
      validationRules: Map<String, dynamic>.from(widgetData['validation_rules'] ?? {}),
      config: Map<String, dynamic>.from(widgetData['widget_config'] ?? {}),
    );
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Draggable<WidgetModel>(
        data: widget,
        feedback: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 200,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.primaryColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getWidgetIcon(widget.type),
                  color: AppTheme.primaryColor,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.persianLabel,
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.5,
          child: _buildWidgetCard(widget),
        ),
        child: _buildWidgetCard(widget),
      ),
    );
  }

  /// ساخت کارت ویجت
  Widget _buildWidgetCard(WidgetModel widget) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getWidgetIcon(widget.type),
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.persianLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (widget.englishLabel.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              widget.englishLabel,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 8),
          _buildWidgetPreview(widget),
        ],
      ),
    );
  }

  /// ساخت پیش‌نمایش کوچک ویجت
  Widget _buildWidgetPreview(WidgetModel widget) {
    switch (widget.type) {
      case 'text_field':
        return Container(
          height: 32,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              'متن نمونه',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
              ),
            ),
          ),
        );
      
      case 'textarea':
        return Container(
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.all(6),
          child: Align(
            alignment: Alignment.topRight,
            child: Text(
              'متن چندخطی...',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
              ),
            ),
          ),
        );
      
      case 'dropdown':
        return Container(
          height: 32,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'انتخاب کنید',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_drop_down,
                color: Colors.grey.shade500,
                size: 16,
              ),
            ],
          ),
        );
      
      case 'radio':
        return Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade400),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'گزینه',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        );
      
      case 'checkbox':
        return Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                border: Border.all(color: Colors.grey.shade400),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'گزینه',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        );
      
      case 'date':
        return Container(
          height: 32,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '1402/01/01',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
              Icon(
                Icons.calendar_today_outlined,
                color: Colors.grey.shade500,
                size: 14,
              ),
            ],
          ),
        );
      
      default:
        return Container(
          height: 32,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Icon(
              _getWidgetIcon(widget.type),
              color: Colors.grey.shade400,
              size: 16,
            ),
          ),
        );
    }
  }

  /// حالت خالی
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'ویجتی یافت نشد',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'جستجوی خود را تغییر دهید',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
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
}
