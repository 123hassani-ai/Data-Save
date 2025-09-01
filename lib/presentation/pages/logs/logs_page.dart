import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'logs_controller.dart';
import '../../widgets/shared/log_widgets.dart';

/// صفحه داشبورد لاگینگ و مانیتورینگ - Logging and monitoring dashboard page
class LogsPage extends StatefulWidget {
  const LogsPage({super.key});

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  late LogsController _controller;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = LogsController();
    _loadInitialData();
  }

  /// بارگذاری داده‌های اولیه - Load initial data
  Future<void> _loadInitialData() async {
    await _controller.refreshAll();
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(),
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  /// ساخت AppBar - Build app bar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('داشبورد لاگینگ و مانیتورینگ'),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      actions: [
        Consumer<LogsController>(
          builder: (context, controller, child) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: controller.isLoading
                      ? null
                      : () => controller.refreshAll(),
                  icon: controller.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  tooltip: 'بروزرسانی',
                ),
                IconButton(
                  onPressed: controller.isLoading
                      ? null
                      : () => _showClearLogsDialog(),
                  icon: const Icon(Icons.clear_all),
                  tooltip: 'پاکسازی لاگ‌ها',
                ),
                IconButton(
                  onPressed: controller.isLoading
                      ? null
                      : () => _exportLogs(controller),
                  icon: const Icon(Icons.download),
                  tooltip: 'صادرات لاگ‌ها',
                ),
                IconButton(
                  onPressed: () => _showMoreOptions(),
                  icon: const Icon(Icons.more_vert),
                  tooltip: 'گزینه‌های بیشتر',
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  /// ساخت بدنه صفحه - Build page body
  Widget _buildBody() {
    return Consumer<LogsController>(
      builder: (context, controller, child) {
        return RefreshIndicator(
          onRefresh: () => controller.refreshAll(),
          child: Column(
            children: [
              // کارت‌های آمار - Statistics cards
              _buildAnalyticsSection(controller),
              
              // بخش فیلترها و جستجو - Filters and search section
              _buildFiltersSection(controller),
              
              // لیست لاگ‌ها - Logs list
              Expanded(
                child: _buildLogsList(controller),
              ),
              
              // کنترل‌های صفحه‌بندی - Pagination controls
              if (controller.totalPages > 1)
                _buildPaginationControls(controller),
            ],
          ),
        );
      },
    );
  }

  /// ساخت بخش آنالیتیک - Build analytics section
  Widget _buildAnalyticsSection(LogsController controller) {
    if (controller.isLoadingAnalytics) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      height: 140,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: [
          LogStatCard(
            title: 'کل لاگ‌ها امروز',
            count: controller.todayLogsCount,
            icon: Icons.today,
            color: Colors.blue,
            onTap: () => controller.setFilter('ALL'),
          ),
          LogStatCard(
            title: 'خطاهای جدی',
            count: controller.errorLogsCount,
            icon: Icons.error,
            color: Colors.red,
            onTap: () => controller.setFilter('ERROR'),
          ),
          LogStatCard(
            title: 'هشدارها',
            count: controller.warningLogsCount,
            icon: Icons.warning,
            color: Colors.orange,
            onTap: () => controller.setFilter('WARNING'),
          ),
          LogStatCard(
            title: 'اطلاعات',
            count: controller.infoLogsCount,
            icon: Icons.info,
            color: Colors.green,
            onTap: () => controller.setFilter('INFO'),
          ),
          LogStatCard(
            title: 'دیباگ',
            count: controller.debugLogsCount,
            icon: Icons.bug_report,
            color: Colors.purple,
            onTap: () => controller.setFilter('DEBUG'),
          ),
        ],
      ),
    );
  }

  /// ساخت بخش فیلترها - Build filters section
  Widget _buildFiltersSection(LogsController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // نوار جستجو - Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'جستجو در لاگ‌ها...',
              hintText: 'نام دسته، پیام، یا IP را جستجو کنید',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        controller.setSearchQuery('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
            onChanged: (value) {
              controller.setSearchQuery(value);
            },
          ),

          const SizedBox(height: 12),

          // چیپ‌های فیلتر - Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  'همه',
                  'ALL',
                  controller.selectedFilter == 'ALL',
                  controller,
                  Colors.grey,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'خطا',
                  'ERROR',
                  controller.selectedFilter == 'ERROR',
                  controller,
                  Colors.red,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'هشدار',
                  'WARNING',
                  controller.selectedFilter == 'WARNING',
                  controller,
                  Colors.orange,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'اطلاعات',
                  'INFO',
                  controller.selectedFilter == 'INFO',
                  controller,
                  Colors.green,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'دیباگ',
                  'DEBUG',
                  controller.selectedFilter == 'DEBUG',
                  controller,
                  Colors.purple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ساخت چیپ فیلتر - Build filter chip
  Widget _buildFilterChip(
    String label,
    String filter,
    bool isSelected,
    LogsController controller,
    Color color,
  ) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          controller.setFilter(filter);
        }
      },
      selectedColor: color.withOpacity(0.2),
      checkmarkColor: color,
      backgroundColor: Theme.of(context).colorScheme.surface,
      side: BorderSide(
        color: isSelected ? color : Colors.transparent,
        width: 1,
      ),
    );
  }

  /// ساخت لیست لاگ‌ها - Build logs list
  Widget _buildLogsList(LogsController controller) {
    if (controller.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('در حال بارگذاری لاگ‌ها...'),
          ],
        ),
      );
    }

    if (controller.error != null) {
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
              'خطا در بارگذاری لاگ‌ها',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              controller.error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => controller.refreshAll(),
              icon: const Icon(Icons.refresh),
              label: const Text('تلاش مجدد'),
            ),
          ],
        ),
      );
    }

    if (controller.filteredLogs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'هیچ لاگی یافت نشد',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'لاگی با فیلترهای انتخاب شده وجود ندارد',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                controller.setFilter('ALL');
                _searchController.clear();
                controller.setSearchQuery('');
              },
              icon: const Icon(Icons.clear_all),
              label: const Text('پاکسازی فیلترها'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: controller.filteredLogs.length,
      itemBuilder: (context, index) {
        final log = controller.filteredLogs[index];
        return LogItemCard(
          logEntry: log,
          onTap: () => _showLogDetails(log),
        );
      },
    );
  }

  /// ساخت کنترل‌های صفحه‌بندی - Build pagination controls
  Widget _buildPaginationControls(LogsController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            onPressed: controller.currentPage > 1 ? controller.previousPage : null,
            icon: const Icon(Icons.chevron_left),
            label: const Text('صفحه قبل'),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'صفحه ${controller.currentPage} از ${controller.totalPages}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: controller.currentPage < controller.totalPages
                ? controller.nextPage
                : null,
            icon: const Icon(Icons.chevron_right),
            label: const Text('صفحه بعد'),
          ),
        ],
      ),
    );
  }

  /// ساخت دکمه شناور - Build floating action button
  Widget _buildFloatingActionButton() {
    return Consumer<LogsController>(
      builder: (context, controller, child) {
        return FloatingActionButton.extended(
          onPressed: () => _showQuickActions(controller),
          label: const Text('اقدامات سریع'),
          icon: const Icon(Icons.speed),
        );
      },
    );
  }

  /// نمایش جزئیات لاگ - Show log details
  Future<void> _showLogDetails(Map<String, dynamic> log) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getLogLevelIcon(log['log_level']),
              color: _getLogLevelColor(log['log_level']),
            ),
            const SizedBox(width: 8),
            Text('جزئیات لاگ'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('سطح', log['log_level']?.toString() ?? 'نامشخص'),
              _buildDetailRow('دسته', log['log_category']?.toString() ?? 'عمومی'),
              _buildDetailRow('پیام', log['log_message']?.toString() ?? 'پیام خالی'),
              _buildDetailRow('زمان', log['created_at']?.toString() ?? 'نامشخص'),
              if (log['ip_address'] != null)
                _buildDetailRow('آدرس IP', log['ip_address'].toString()),
              if (log['user_agent'] != null)
                _buildDetailRow('مرورگر', log['user_agent'].toString()),
              if (log['log_context'] != null)
                _buildDetailRow('کنتکست', log['log_context'].toString()),
            ],
          ),
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

  /// ساخت ردیف جزئیات - Build detail row
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          SelectableText(value),
          const Divider(),
        ],
      ),
    );
  }

  /// دریافت آیکون سطح لاگ - Get log level icon
  IconData _getLogLevelIcon(dynamic level) {
    switch (level?.toString().toUpperCase()) {
      case 'ERROR':
        return Icons.error;
      case 'WARNING':
        return Icons.warning;
      case 'INFO':
        return Icons.info;
      case 'DEBUG':
        return Icons.bug_report;
      default:
        return Icons.circle;
    }
  }

  /// دریافت رنگ سطح لاگ - Get log level color
  Color _getLogLevelColor(dynamic level) {
    switch (level?.toString().toUpperCase()) {
      case 'ERROR':
        return Colors.red;
      case 'WARNING':
        return Colors.orange;
      case 'INFO':
        return Colors.blue;
      case 'DEBUG':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  /// نمایش اقدامات سریع - Show quick actions
  Future<void> _showQuickActions(LogsController controller) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'اقدامات سریع',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.refresh, color: Colors.blue),
              title: const Text('بروزرسانی لاگ‌ها'),
              onTap: () {
                Navigator.pop(context);
                controller.refreshAll();
              },
            ),
            ListTile(
              leading: const Icon(Icons.clear_all, color: Colors.orange),
              title: const Text('پاکسازی لاگ‌های قدیمی'),
              onTap: () {
                Navigator.pop(context);
                _showClearLogsDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.download, color: Colors.green),
              title: const Text('صادرات لاگ‌ها'),
              onTap: () {
                Navigator.pop(context);
                _exportLogs(controller);
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics, color: Colors.purple),
              title: const Text('آنالیتیک پیشرفته'),
              onTap: () {
                Navigator.pop(context);
                _showAdvancedAnalytics(controller);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// نمایش دیالوگ پاکسازی لاگ‌ها - Show clear logs dialog
  Future<void> _showClearLogsDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('پاکسازی لاگ‌های قدیمی'),
        content: const Text(
          'آیا مطمئن هستید که می‌خواهید لاگ‌های قدیمی را پاکسازی کنید؟\n\n'
          'این عملیات تنها ۱۰۰ لاگ اخیر را نگه می‌دارد و بقیه را حذف می‌کند.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('پاکسازی'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await _controller.clearOldLogs();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success 
              ? 'لاگ‌های قدیمی پاکسازی شد!' 
              : 'خطا در پاکسازی لاگ‌ها!'
          ),
          backgroundColor: success ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// صادرات لاگ‌ها - Export logs
  Future<void> _exportLogs(LogsController controller) async {
    try {
      final exportData = controller.exportLogs();
      
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('صادرات لاگ‌ها'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('تعداد لاگ‌ها: ${exportData['logs']?.length ?? 0}'),
                Text('تاریخ صادرات: ${exportData['export_date']}'),
                const SizedBox(height: 16),
                const Text('داده‌های صادراتی:'),
                const SizedBox(height: 8),
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      exportData.toString(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('بستن'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطا در صادرات لاگ‌ها: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// نمایش آنالیتیک پیشرفته - Show advanced analytics
  Future<void> _showAdvancedAnalytics(LogsController controller) async {
    final dailyStats = controller.getDailyStats();
    final categoryStats = controller.categoryCounts;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('آنالیتیک پیشرفته'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'آمار روزانه:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              ...dailyStats.entries.map((entry) => 
                Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Text('${entry.key}: ${entry.value} لاگ'),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'آمار دسته‌ها:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              ...categoryStats.entries.map((entry) => 
                Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Text('${entry.key}: ${entry.value} لاگ'),
                ),
              ),
            ],
          ),
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

  /// نمایش گزینه‌های بیشتر - Show more options
  Future<void> _showMoreOptions() async {
    await showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'گزینه‌های بیشتر',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.filter_alt),
              title: const Text('فیلترهای پیشرفته'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('فیلترهای پیشرفته در نسخه‌های آتی اضافه خواهد شد'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('لاگ‌های زمان‌بندی شده'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('لاگ‌های زمان‌بندی شده در نسخه‌های آتی اضافه خواهد شد'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('تنظیمات لاگینگ'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('درباره لاگینگ'),
              onTap: () {
                Navigator.pop(context);
                _showAboutLogging();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// نمایش درباره لاگینگ - Show about logging
  Future<void> _showAboutLogging() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('درباره سیستم لاگینگ'),
        content: const Text(
          'سیستم لاگینگ DataSave تمامی فعالیت‌های سیستم را ثبت می‌کند:\n\n'
          '• خطاهای سیستم و برنامه\n'
          '• هشدارهای مهم\n'
          '• اطلاعات عملکرد سیستم\n'
          '• پیام‌های دیباگ\n\n'
          'شما می‌توانید لاگ‌ها را فیلتر، جستجو و صادر کنید.\n\n'
          'لاگ‌ها به صورت خودکار مدیریت شده و لاگ‌های قدیمی پاک می‌شوند.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('فهمیدم'),
          ),
        ],
      ),
    );
  }
}
