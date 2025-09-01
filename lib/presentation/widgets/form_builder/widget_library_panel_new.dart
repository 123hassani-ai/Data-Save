import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/form_builder_provider.dart';
import '../../../core/providers/widget_library_provider.dart';

/// پنل کتابخانه ویجت‌ها برای Form Builder
class WidgetLibraryPanel extends StatefulWidget {
  const WidgetLibraryPanel({super.key});

  @override
  State<WidgetLibraryPanel> createState() => _WidgetLibraryPanelState();
}

class _WidgetLibraryPanelState extends State<WidgetLibraryPanel> {
  String _selectedCategory = 'all';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // هدر پنل
          _buildHeader(context),
          
          // بار جستجو
          _buildSearchBar(context),
          
          // فیلتر دسته‌بندی
          _buildCategoryFilter(context),
          
          // لیست ویجت‌ها
          Expanded(
            child: _buildWidgetsList(context),
          ),
        ],
      ),
    );
  }

  /// هدر پنل
  Widget _buildHeader(BuildContext context) {
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
            Icons.widgets,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'کتابخانه ویجت‌ها',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// بار جستجو
  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
        decoration: InputDecoration(
          hintText: 'جستجو در ویجت‌ها...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        ),
      ),
    );
  }

  /// فیلتر دسته‌بندی
  Widget _buildCategoryFilter(BuildContext context) {
    return Consumer<WidgetLibraryProvider>(
      builder: (context, provider, child) {
        // تبدیل categories به List<String>
        final categoryNames = provider.categories
            .map((cat) => (cat['name'] as String? ?? 'unknown'))
            .toList();
        final categories = ['all', ...categoryNames];
        
        return Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = category == _selectedCategory;
              
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(_getCategoryLabel(category)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  selectedColor: Theme.of(context).colorScheme.primaryContainer,
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// لیست ویجت‌ها
  Widget _buildWidgetsList(BuildContext context) {
    return Consumer2<WidgetLibraryProvider, FormBuilderProvider>(
      builder: (context, widgetProvider, formProvider, child) {
        if (widgetProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (widgetProvider.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'خطا در بارگذاری ویجت‌ها',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widgetProvider.errorMessage!,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => widgetProvider.loadWidgetLibrary(),
                  child: const Text('تلاش مجدد'),
                ),
              ],
            ),
          );
        }

        final widgets = _getFilteredWidgets(widgetProvider.widgets);

        if (widgets.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 48,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'ویجتی یافت نشد',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return _buildWidgetsGrid(context, widgets, formProvider);
      },
    );
  }

  /// گرید ویجت‌ها
  Widget _buildWidgetsGrid(BuildContext context, List<Map<String, dynamic>> widgets, FormBuilderProvider formProvider) {
    // تعریف responsive breakpoints
    int crossAxisCount = 2;
    
    return Padding(
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 0.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: widgets.length,
        itemBuilder: (context, index) {
          final widget = widgets[index];
          return _buildModernWidgetCard(context, widget, formProvider);
        },
      ),
    );
  }

  /// کارت ویجت مدرن و زیبا  
  Widget _buildModernWidgetCard(
    BuildContext context,
    Map<String, dynamic> widget,
    FormBuilderProvider formProvider,
  ) {
    final persianLabel = widget['persian_label'] ?? 'ویجت نامشخص';
    final englishLabel = widget['english_label'] ?? '';
    final iconName = widget['icon_name'] ?? 'text_fields';

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => formProvider.addWidgetToCanvas(widget),
          onLongPress: () => _showWidgetInfo(context, widget),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // آیکون با پس‌زمینه گرادیانت
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primaryContainer,
                        Theme.of(context).colorScheme.secondaryContainer,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    _getIconData(iconName),
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    size: 28,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // نام ویجت
                Column(
                  children: [
                    Text(
                      persianLabel,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    if (englishLabel.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        englishLabel,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // دکمه اضافه کردن
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: ElevatedButton.icon(
                    onPressed: () => formProvider.addWidgetToCanvas(widget),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    icon: const Icon(
                      Icons.add_circle_outline,
                      size: 18,
                    ),
                    label: const Text(
                      'اضافه',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// نمایش اطلاعات ویجت
  void _showWidgetInfo(BuildContext context, Map<String, dynamic> widget) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget['persian_label'] ?? 'اطلاعات ویجت'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget['english_label']?.isNotEmpty == true) ...[
              Text('نام انگلیسی: ${widget['english_label']}'),
              const SizedBox(height: 8),
            ],
            Text('نوع: ${widget['widget_type'] ?? 'نامشخص'}'),
            const SizedBox(height: 8),
            if (widget['persian_description']?.isNotEmpty == true ||
                widget['english_description']?.isNotEmpty == true) ...[
              const SizedBox(height: 4),
              Text(
                widget['persian_description'] ??
                    widget['english_description'] ??
                    '',
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('بستن'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<FormBuilderProvider>().addWidgetToCanvas(widget);
            },
            child: const Text('اضافه کردن'),
          ),
        ],
      ),
    );
  }

  /// فیلتر ویجت‌ها
  List<Map<String, dynamic>> _getFilteredWidgets(List<Map<String, dynamic>> widgets) {
    return widgets.where((widget) {
      // فیلتر دسته‌بندی
      bool categoryMatch = _selectedCategory == 'all' || 
          widget['category'] == _selectedCategory;
      
      // فیلتر جستجو
      bool searchMatch = _searchQuery.isEmpty ||
          (widget['persian_label']?.toLowerCase() ?? '').contains(_searchQuery) ||
          (widget['english_label']?.toLowerCase() ?? '').contains(_searchQuery) ||
          (widget['persian_description']?.toLowerCase() ?? '').contains(_searchQuery) ||
          (widget['english_description']?.toLowerCase() ?? '').contains(_searchQuery);
      
      return categoryMatch && searchMatch;
    }).toList();
  }

  /// برچسب دسته‌بندی
  String _getCategoryLabel(String category) {
    switch (category) {
      case 'all':
        return 'همه';
      case 'basic':
        return 'پایه';
      case 'advanced':
        return 'پیشرفته';
      case 'form':
        return 'فرم';
      case 'input':
        return 'ورودی';
      case 'display':
        return 'نمایشی';
      default:
        return category;
    }
  }

  /// تبدیل نام آیکون به IconData
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'text_fields':
        return Icons.text_fields;
      case 'subject':
        return Icons.subject;
      case 'numbers':
        return Icons.numbers;
      case 'email':
        return Icons.email;
      case 'phone':
        return Icons.phone;
      case 'calendar_today':
        return Icons.calendar_today;
      case 'schedule':
        return Icons.schedule;
      case 'arrow_drop_down_circle':
        return Icons.arrow_drop_down_circle;
      case 'radio_button_checked':
        return Icons.radio_button_checked;
      case 'check_box':
        return Icons.check_box;
      case 'upload_file':
        return Icons.upload_file;
      case 'send':
        return Icons.send;
      default:
        return Icons.extension;
    }
  }
}
