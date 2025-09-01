import 'package:flutter/material.dart';
import '../../../core/logger/logger_service.dart';
import '../../../core/services/api_service.dart';
import '../../widgets/shared/stat_card.dart';
import '../../widgets/shared/log_widgets.dart';
import '../../widgets/shared/action_widgets.dart';
import '../../routes/app_routes.dart';

/// صفحه اصلی برنامه DataSave - داشبورد حرفه‌ای
/// DataSave main page - Professional dashboard
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // وضعیت‌های سیستم - System states
  bool _serverConnected = false;
  bool _databaseConnected = false;
  String _connectionStatus = 'در حال بررسی...';
  List<Map<String, dynamic>> _systemSettings = [];
  List<Map<String, dynamic>> _recentLogs = [];
  bool _isLoading = true;
  Map<String, dynamic>? _systemInfo;
  String? _responseTime;

  // آمار داشبورد - Dashboard statistics
  int _totalLogs = 0;
  int _errorLogs = 0;
  int _warningLogs = 0;
  int _infoLogs = 0;
  int _todayLogs = 0;
  
  @override
  void initState() {
    super.initState();
    _initializeDashboard();
  }

  /// مقداردهی اولیه داشبورد - Initialize dashboard
  Future<void> _initializeDashboard() async {
    setState(() {
      _isLoading = true;
      _connectionStatus = 'در حال بررسی سیستم...';
    });

    LoggerService.info('HomePage', 'شروع بارگذاری داشبورد - Starting dashboard initialization');

    try {
      // بارگذاری موازی داده‌ها - Parallel data loading
      await Future.wait([
        _testSystemHealth().catchError((e) {
          LoggerService.error('HomePage', 'خطا در تست سلامت سیستم', e);
        }),
        _loadSystemSettings().catchError((e) {
          LoggerService.error('HomePage', 'خطا در بارگذاری تنظیمات', e);
        }),
        _loadRecentLogs().catchError((e) {
          LoggerService.error('HomePage', 'خطا در بارگذاری لاگ‌ها', e);
        }),
        _loadLogsStats().catchError((e) {
          LoggerService.error('HomePage', 'خطا در بارگذاری آمار لاگ‌ها', e);
        }),
        _loadSystemInfo().catchError((e) {
          LoggerService.error('HomePage', 'خطا در بارگذاری اطلاعات سیستم', e);
        }),
      ]);

      LoggerService.info('HomePage', 'داشبورد با موفقیت بارگذاری شد - Dashboard loaded successfully');
    } catch (e) {
      LoggerService.error('HomePage', 'خطا در بارگذاری داشبورد', e);
      setState(() {
        _connectionStatus = 'خطا در بارگذاری: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// پیمایش به فرم‌ساز - Navigate to Form Builder
  void _navigateToFormBuilder(BuildContext context) {
    Navigator.of(context).pushNamed(
      AppRoutes.formBuilder,
      arguments: {
        'userId': 1, // شناسه کاربر فعلی - فعلاً ثابت
        'formId': null, // null برای فرم جدید
      },
    );
    LoggerService.info('HomePage', 'پیمایش به فرم‌ساز - Navigating to Form Builder');
  }

  /// تست سلامت سیستم - Test system health
  Future<void> _testSystemHealth() async {
    final startTime = DateTime.now();
    
    try {
      final result = await ApiService.testConnection();
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      
      setState(() {
        _serverConnected = result['success'] ?? false;
        _databaseConnected = _serverConnected;
        _connectionStatus = result['message'] ?? 'نامشخص';
        _systemInfo = result['data'];
        _responseTime = '${duration.inMilliseconds}ms';
      });

      if (_serverConnected) {
        LoggerService.info('HomePage', 'سیستم سالم است - System is healthy');
      } else {
        LoggerService.warning('HomePage', 'مشکل در اتصال سیستم - System connection issue');
      }
    } catch (e) {
      setState(() {
        _serverConnected = false;
        _databaseConnected = false;
        _connectionStatus = 'خطا در اتصال: $e';
        _responseTime = null;
      });
      LoggerService.error('HomePage', 'خطا در تست سلامت سیستم', e);
    }
  }

  /// بارگذاری تنظیمات سیستم - Load system settings
  Future<void> _loadSystemSettings() async {
    try {
      final settings = await ApiService.getSettings();
      setState(() {
        _systemSettings = settings;
      });
      LoggerService.info('HomePage', 'تنظیمات بارگذاری شد - Settings loaded: ${settings.length} items');
    } catch (e) {
      LoggerService.error('HomePage', 'خطا در بارگذاری تنظیمات', e);
    }
  }

  /// بارگذاری لاگ‌های اخیر - Load recent logs
  Future<void> _loadRecentLogs() async {
    try {
      final logs = await ApiService.getLogs(limit: 10);
      setState(() {
        _recentLogs = logs;
      });
      LoggerService.info('HomePage', 'لاگ‌های اخیر بارگذاری شد - Recent logs loaded: ${logs.length} items');
    } catch (e) {
      LoggerService.error('HomePage', 'خطا در بارگذاری لاگ‌ها', e);
    }
  }

  /// بارگذاری آمار لاگ‌ها - Load logs statistics
  Future<void> _loadLogsStats() async {
    try {
      final stats = await ApiService.getLogsStats();
      setState(() {
        _totalLogs = stats['total_logs'] ?? 0;
        _errorLogs = stats['error_logs'] ?? 0;
        _warningLogs = stats['warning_logs'] ?? 0;
        _infoLogs = stats['info_logs'] ?? 0;
        _todayLogs = stats['today_logs'] ?? 0;
      });
      LoggerService.info('HomePage', 'آمار لاگ‌ها بارگذاری شد - Stats loaded: Total=$_totalLogs, Errors=$_errorLogs, Warnings=$_warningLogs');
    } catch (e) {
      LoggerService.error('HomePage', 'خطا در بارگذاری آمار لاگ‌ها', e);
    }
  }

  /// بارگذاری اطلاعات سیستم - Load system info
  Future<void> _loadSystemInfo() async {
    try {
      final info = await ApiService.getSystemInfo();
      setState(() {
        _systemInfo = info;
      });
      LoggerService.info('HomePage', 'اطلاعات سیستم بارگذاری شد - System info loaded');
    } catch (e) {
      LoggerService.error('HomePage', 'خطا در بارگذاری اطلاعات سیستم', e);
    }
  }

  /// محاسبه تعداد لاگ‌های امروز - Calculate today's logs count
  int _getTodayLogsCount(List<Map<String, dynamic>> logs) {
    final today = DateTime.now();
    return logs.where((log) {
      try {
        final logDate = DateTime.parse(log['created_at']);
        return logDate.year == today.year &&
               logDate.month == today.month &&
               logDate.day == today.day;
      } catch (e) {
        return false;
      }
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  /// ساخت AppBar - Build app bar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('DataSave - داشبورد اصلی'),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      actions: [
        IconButton(
          icon: const Icon(Icons.font_download),
          onPressed: () => Navigator.pushNamed(context, '/test-font'),
          tooltip: 'تست فونت‌های فارسی',
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => NavigationHelper.navigateToSettings(context),
          tooltip: 'تنظیمات',
        ),
        IconButton(
          icon: const Icon(Icons.analytics),
          onPressed: () => NavigationHelper.navigateToLogs(context),
          tooltip: 'لاگ‌ها و آنالیتیک',
        ),
        IconButton(
          icon: const Icon(Icons.info),
          onPressed: () => NavigationHelper.showAboutDialog(context),
          tooltip: 'درباره برنامه',
        ),
      ],
    );
  }

  /// ساخت بدنه صفحه - Build page body
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'در حال بارگذاری داشبورد...',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _initializeDashboard,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHeader(),
            const SizedBox(height: 20),
            _buildSystemStatsRow(),
            const SizedBox(height: 20),
            SystemHealthCard(
              backendStatus: _serverConnected,
              databaseStatus: _databaseConnected,
              responseTime: _responseTime,
            ),
            const SizedBox(height: 20),
            RecentLogsCard(
              logs: _recentLogs,
              onViewAll: () => NavigationHelper.navigateToLogs(context),
            ),
            const SizedBox(height: 20),
            _buildQuickActionsCard(),
            const SizedBox(height: 20),
            if (_systemInfo != null) _buildSystemInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    final now = DateTime.now();
    final hour = now.hour;
    String greeting;
    
    if (hour < 12) {
      greeting = 'صبح بخیر! 🌅';
    } else if (hour < 17) {
      greeting = 'روز بخیر! ☀️';
    } else {
      greeting = 'عصر بخیر! 🌆';
    }

    return Card(
      elevation: 2,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'به داشبورد DataSave خوش آمدید',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'وضعیت سیستم: $_connectionStatus',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: _serverConnected ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemStatsRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 768;
        
        if (isWide) {
          return Row(
            children: [
              Expanded(child: _buildServerStatusCard()),
              const SizedBox(width: 12),
              Expanded(child: _buildInfoLogsCard()),
              const SizedBox(width: 12),
              Expanded(child: _buildWarningLogsCard()),
              const SizedBox(width: 12),
              Expanded(child: _buildErrorLogsCard()),
              const SizedBox(width: 12),
              Expanded(child: _buildTodayLogsCard()),
            ],
          );
        } else {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildServerStatusCard()),
                  const SizedBox(width: 12),
                  Expanded(child: _buildInfoLogsCard()),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildWarningLogsCard()),
                  const SizedBox(width: 12),
                  Expanded(child: _buildErrorLogsCard()),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildTodayLogsCard()),
                ],
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildServerStatusCard() {
    return StatCard(
      title: 'وضعیت سرور',
      value: _serverConnected ? 'فعال' : 'غیرفعال',
      icon: Icons.dns,
      color: _serverConnected ? Colors.green : Colors.red,
      onTap: _testSystemHealth,
    );
  }

  Widget _buildLogsCountCard() {
    return StatCard(
      title: 'کل لاگ‌ها',
      value: _totalLogs.toString(),
      icon: Icons.list_alt,
      color: Colors.blue,
      onTap: () => NavigationHelper.navigateToLogs(context),
    );
  }

  Widget _buildInfoLogsCard() {
    return StatCard(
      title: 'اطلاعات',
      value: _infoLogs.toString(),
      icon: Icons.info,
      color: Colors.green,
      onTap: () => NavigationHelper.navigateToLogs(context),
    );
  }

  Widget _buildWarningLogsCard() {
    return StatCard(
      title: 'هشدارها',
      value: _warningLogs.toString(),
      icon: Icons.warning,
      color: Colors.orange,
      onTap: () => NavigationHelper.navigateToLogs(context),
    );
  }

  Widget _buildErrorLogsCard() {
    return StatCard(
      title: 'خطاهای حدی',
      value: _errorLogs.toString(),
      icon: Icons.error,
      color: Colors.red,
      onTap: () => NavigationHelper.navigateToLogs(context),
    );
  }

  Widget _buildTodayLogsCard() {
    return StatCard(
      title: 'کل لاگ‌ها امروز',
      value: _todayLogs.toString(),
      icon: Icons.today,
      color: Colors.blue,
      onTap: () => NavigationHelper.navigateToLogs(context),
    );
  }

  Widget _buildQuickActionsCard() {
    return QuickActionsCard(
      actions: [
        ActionButton(
          'فرم‌ساز هوشمند',
          Icons.dashboard_customize,
          _isLoading ? null : () => _navigateToFormBuilder(context),
          color: Colors.purple,
        ),
        ActionButton(
          'تست سیستم',
          Icons.system_update,
          _isLoading ? null : _testAllSystems,
          color: Colors.blue,
        ),
        ActionButton(
          'پاکسازی لاگ‌ها',
          Icons.clear_all,
          _isLoading ? null : _clearOldLogs,
          color: Colors.orange,
        ),
        ActionButton(
          'تنظیمات',
          Icons.settings,
          () => NavigationHelper.navigateToSettings(context),
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildSystemInfoCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'اطلاعات سیستم',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_systemInfo != null) ...[
              _buildInfoRow('نسخه PHP', _systemInfo!['php_version']?.toString() ?? 'نامشخص'),
              _buildInfoRow('نسخه MySQL', _systemInfo!['mysql_version']?.toString() ?? 'نامشخص'),
              _buildInfoRow('حافظه مصرفی', _systemInfo!['memory_usage']?.toString() ?? 'نامشخص'),
              _buildInfoRow('زمان سرور', _systemInfo!['server_time']?.toString() ?? 'نامشخص'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _testAllSystems() async {
    LoggerService.info('HomePage', 'شروع تست همه سیستم‌ها - Starting comprehensive system test');
    
    try {
      await _initializeDashboard();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_serverConnected 
                ? 'تست سیستم موفقیت‌آمیز بود!' 
                : 'مشکلاتی در سیستم شناسایی شد!'
            ),
            backgroundColor: _serverConnected ? Colors.green : Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      LoggerService.error('HomePage', 'خطا در تست سیستم‌ها', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در تست سیستم: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _clearOldLogs() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('پاکسازی لاگ‌های قدیمی'),
        content: const Text(
          'آیا مطمئن هستید که می‌خواهید لاگ‌های قدیمی را پاکسازی کنید؟'
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
      try {
        LoggerService.info('HomePage', 'شروع پاکسازی لاگ‌ها - Starting log cleanup');
        
        final success = await ApiService.clearOldLogs();
        
        if (success) {
          await _loadRecentLogs();
        }
        
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
      } catch (e) {
        LoggerService.error('HomePage', 'خطا در پاکسازی لاگ‌ها', e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در پاکسازی: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
