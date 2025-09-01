import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../core/logger/logger_service.dart';

/// صفحه اصلی برنامه DataSave با تست Backend PHP
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _serverConnected = false;
  String _connectionStatus = 'در حال بررسی...';
  List<Map<String, dynamic>> _systemSettings = [];
  bool _isLoading = true;
  Map<String, dynamic>? _systemInfo;

  @override
  void initState() {
    super.initState();
    _testSystemComponents();
  }

  Future<void> _testSystemComponents() async {
    setState(() {
      _isLoading = true;
      _connectionStatus = 'در حال تست اتصال به Backend...';
    });

    print('🔍 شروع تست سیستم‌های Backend');
    LoggerService.info('HomePage', 'شروع تست سیستم‌های Backend');

    try {
      await _testBackendConnection();
      await _loadSystemSettings();
      print('✅ تمام تست‌های سیستم با موفقیت انجام شد');
      LoggerService.info('HomePage', 'تمام تست‌های سیستم با موفقیت انجام شد');
    } catch (e) {
      print('❌ خطا در تست سیستم: $e');
      LoggerService.error('HomePage', 'خطا در تست سیستم', e);
      setState(() {
        _connectionStatus = 'خطا در اتصال: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testBackendConnection() async {
    try {
      final result = await ApiService.testConnection();
      setState(() {
        _serverConnected = result['success'] ?? false;
        _connectionStatus = result['message'] ?? 'نامشخص';
        _systemInfo = result['data'];
      });

      if (_serverConnected) {
        print('✅ اتصال Backend برقرار است');
      } else {
        print('⚠️ مشکل در اتصال Backend');
      }
    } catch (e) {
      setState(() {
        _serverConnected = false;
        _connectionStatus = 'خطا در اتصال: $e';
      });
      print('❌ خطا در تست اتصال Backend: $e');
    }
  }

  Future<void> _loadSystemSettings() async {
    try {
      final settings = await ApiService.getSettings();
      setState(() {
        _systemSettings = settings;
      });
      print('📋 تنظیمات بارگذاری شد: ${settings.length} مورد');
    } catch (e) {
      print('❌ خطا در بارگذاری تنظیمات: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DataSave - Backend PHP'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'در حال بارگذاری سیستم...',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _testSystemComponents,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBackendStatusCard(),
                    const SizedBox(height: 16),
                    _buildSystemInfoCard(),
                    const SizedBox(height: 16),
                    _buildSettingsCard(),
                    const SizedBox(height: 16),
                    _buildActionsCard(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBackendStatusCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _serverConnected ? Icons.check_circle : Icons.error,
                  color: _serverConnected ? Colors.green : Colors.red,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'وضعیت Backend PHP',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _connectionStatus,
              style: TextStyle(
                fontSize: 14,
                color: _serverConnected ? Colors.green[700] : Colors.red[700],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _testBackendConnection,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('تست مجدد'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openBackendInBrowser(),
                    icon: const Icon(Icons.open_in_browser, size: 18),
                    label: const Text('مشاهده API'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemInfoCard() {
    if (_systemInfo == null) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'اطلاعات سیستم',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            _buildInfoRow('نسخه PHP', _systemInfo!['php_version'] ?? 'نامشخص'),
            _buildInfoRow('زمان سرور', _systemInfo!['server_time'] ?? 'نامشخص'),
            _buildInfoRow('حافظه', _systemInfo!['memory_limit'] ?? 'نامشخص'),
            if (_systemInfo!['database'] != null)
              _buildInfoRow('دیتابیس', 
                _systemInfo!['database']['success'] ? '✅ متصل' : '❌ قطع'),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'تنظیمات سیستم (${_systemSettings.length})',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  onPressed: _loadSystemSettings,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'بروزرسانی',
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_systemSettings.isEmpty)
              const Text('تنظیماتی یافت نشد')
            else
              ...(_systemSettings.take(5).map((setting) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: _buildInfoRow(
                      setting['setting_key'] ?? 'نامشخص',
                      setting['setting_value'] ?? 'خالی',
                    ),
                  ))),
            if (_systemSettings.length > 5)
              TextButton(
                onPressed: () => _showAllSettings(),
                child: const Text('مشاهده همه تنظیمات'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'اقدامات تست',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _sendTestLog(),
                    icon: const Icon(Icons.bug_report, size: 18),
                    label: const Text('ارسال لاگ تست'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _testSystemComponents,
                icon: const Icon(Icons.system_update, size: 18),
                label: const Text('تست کامل سیستم'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[600],
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _sendTestLog() async {
    try {
      await ApiService.sendLog('INFO', 'Test', 'این یک لاگ تستی است از Flutter');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لاگ تست ارسال شد'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در ارسال لاگ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAllSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تمام تنظیمات سیستم'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: _systemSettings.length,
            itemBuilder: (context, index) {
              final setting = _systemSettings[index];
              return ListTile(
                title: Text(setting['setting_key'] ?? 'نامشخص'),
                subtitle: Text(setting['setting_value'] ?? 'خالی'),
                trailing: Chip(
                  label: Text(setting['setting_type'] ?? 'string'),
                  backgroundColor: Colors.blue[100],
                ),
              );
            },
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

  void _openBackendInBrowser() {
    print('🌐 درخواست باز کردن Backend در مرورگر');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('برای مشاهده API به: http://localhost/datasave/backend/ بروید'),
        duration: Duration(seconds: 4),
      ),
    );
  }
}
