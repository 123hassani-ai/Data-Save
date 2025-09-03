import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:html' as html;

void main() {
  runApp(const DataSaveApp());
}

class DataSaveApp extends StatelessWidget {
  const DataSaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DataSave - فرم‌ساز هوشمند',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Vazirmatn',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 16),
          bodyMedium: TextStyle(fontSize: 14),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = true;
  bool _serverConnected = false;
  String _connectionStatus = 'در حال بررسی...';
  List<dynamic> _settings = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _testConnection();
  }

  Future<void> _testConnection() async {
    try {
      // ایجاد درخواست HTTP ساده
      final request = html.HttpRequest();

      request.open(
          'GET', 'http://localhost/datasave/backend/api/settings/test.php');
      request.setRequestHeader('Content-Type', 'application/json');

      request.onLoad.listen((event) {
        if (request.status == 200) {
          final response = jsonDecode(request.responseText!);
          setState(() {
            _serverConnected = response['success'] ?? false;
            _connectionStatus = response['message'] ?? 'نامشخص';
            _isLoading = false;
          });

          if (_serverConnected) {
            _loadSettings();
          }
        }
      });

      request.onError.listen((event) {
        setState(() {
          _serverConnected = false;
          _connectionStatus = 'خطا در اتصال به سرور';
          _isLoading = false;
          _error = 'خطا در درخواست HTTP';
        });
      });

      request.send();
    } catch (e) {
      setState(() {
        _serverConnected = false;
        _connectionStatus = 'خطا: $e';
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _loadSettings() async {
    try {
      final request = html.HttpRequest();

      request.open(
          'GET', 'http://localhost/datasave/backend/api/settings/get.php');
      request.setRequestHeader('Content-Type', 'application/json');

      request.onLoad.listen((event) {
        if (request.status == 200) {
          final response = jsonDecode(request.responseText!);
          setState(() {
            _settings = response['data'] ?? [];
          });
        }
      });

      request.send();
    } catch (e) {
      setState(() {
        _error = 'خطا در بارگذاری تنظیمات: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DataSave - داشبورد اصلی'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('در حال بررسی سیستم...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeCard(),
                  const SizedBox(height: 20),
                  _buildConnectionCard(),
                  const SizedBox(height: 20),
                  if (_settings.isNotEmpty) _buildSettingsCard(),
                  if (_error != null) _buildErrorCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🎉 خوش آمدید به DataSave!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'پلتفرم هوشمند فرم‌ساز با قدرت هوش مصنوعی',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'وضعیت: $_connectionStatus',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: _serverConnected ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'وضعیت اتصال سیستم',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  _serverConnected ? Icons.check_circle : Icons.error,
                  color: _serverConnected ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  _serverConnected ? 'سرور فعال است ✅' : 'سرور غیرفعال است ❌',
                  style: TextStyle(
                    color: _serverConnected ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  _serverConnected ? Icons.storage : Icons.storage_outlined,
                  color: _serverConnected ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  _serverConnected ? 'دیتابیس متصل ✅' : 'دیتابیس قطع ❌',
                  style: TextStyle(
                    color: _serverConnected ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                });
                _testConnection();
              },
              child: const Text('تست مجدد اتصال'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'تنظیمات سیستم',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text('تعداد تنظیمات بارگذاری شده: ${_settings.length}'),
            const SizedBox(height: 8),
            if (_settings.length > 0) ...[
              const Text('نمونه تنظیمات:'),
              const SizedBox(height: 4),
              for (int i = 0;
                  i < (_settings.length > 3 ? 3 : _settings.length);
                  i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    '• ${_settings[i]['setting_key']}: ${_settings[i]['setting_value']}',
                    style:
                        const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Card(
      color: Colors.red.shade50,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'خطا',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
