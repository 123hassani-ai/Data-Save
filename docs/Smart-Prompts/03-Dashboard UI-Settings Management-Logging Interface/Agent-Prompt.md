# 🚀 DataSave مرحله ۳: Dashboard UI + Settings Management + Logging Interface

## 🎯 Mission Overview
Create 3 professional, modern UI sections for DataSave:
1. **Enhanced Dashboard** with analytics and system monitoring
2. **Settings Management Page** for OpenAI API and system configuration
3. **Professional Logging Dashboard** for monitoring and log management

## 📊 Current Project Status - VERIFIED ✅

### Backend API (100% Operational)
```bash
✅ GET  /datasave/backend/api/settings/get.php      # Returns 9 settings
✅ POST /datasave/backend/api/settings/update.php   # Update single setting
✅ POST /datasave/backend/api/logs/create.php       # Create new log entry
✅ GET  /datasave/backend/api/logs/list.php?limit=X # Get logs with pagination
✅ GET  /datasave/backend/api/system/status.php     # System health check
✅ GET  /datasave/backend/api/system/info.php       # Detailed server info
✅ POST /datasave/backend/api/logs/clear.php        # Clear old logs
```

### Database Schema (Confirmed Active)
```sql
-- system_settings table (9 active records)
Fields: id, setting_key, setting_value, setting_type, description, is_system, created_at, updated_at

Current settings:
- openai_api_key (encrypted, empty)
- openai_model (gpt-4) 
- openai_max_tokens (2048)
- app_language (fa)
- enable_logging (true)
- max_log_entries (1000)
- app_theme (light)
- auto_save (true)
- backup_enabled (false)

-- system_logs table (fully operational)
Fields: log_id, log_level, log_category, log_message, log_context, ip_address, user_agent, created_at
```

### Flutter Services (Ready to Use)
```dart
// lib/core/services/api_service.dart - CONFIRMED WORKING
ApiService.getSettings()          // Returns List<Map<String, dynamic>>
ApiService.updateSetting(k, v)    // Returns bool
ApiService.sendLog(l, c, m, ctx)  // Returns bool  
ApiService.getLogs(limit: X)      // Returns List<Map<String, dynamic>>
ApiService.testConnection()       // Returns Map<String, dynamic>
```

## 🎨 UI/UX Requirements

### Design System Standards
- **Language**: Persian RTL (Primary)
- **Framework**: Flutter Web + Material Design 3
- **Font**: Vazirmatn (already loaded locally)
- **Colors**: Primary Blue (#1976D2) + Dynamic Color Scheme
- **Layout**: Mobile-First Responsive Design
- **Navigation**: Top AppBar + Tab/Navigation System

### Responsive Breakpoints
```dart
Mobile (< 768px):   Single column layout
Tablet (768-1024px): Two column layout
Desktop (> 1024px): Three column layout with sidebar
```

## 🏗️ Implementation Requirements

### 1️⃣ Enhanced Dashboard (Homepage Update)
**File to modify**: `lib/presentation/pages/home/home_page.dart`

**Current State**: Simple test page with backend connection status
**Target State**: Professional dashboard with analytics and navigation

**Required Features**:
```dart
// Top Navigation Bar
AppBar(
  title: 'DataSave - داشبورد اصلی',
  actions: [
    IconButton(icon: Icons.settings, onPressed: () => navigateToSettings()),
    IconButton(icon: Icons.analytics, onPressed: () => navigateToLogs()),
    IconButton(icon: Icons.info, onPressed: () => showAboutDialog()),
  ],
)

// Dashboard Content Layout
Column(
  children: [
    // System Status Row
    Row([
      StatCard(title: 'وضعیت سرور', value: serverStatus, icon: Icons.server),
      StatCard(title: 'تعداد لاگ‌ها', value: logCount, icon: Icons.list_alt),
      StatCard(title: 'آخرین فعالیت', value: lastActivity, icon: Icons.update),
    ]),
    
    // System Health Monitor
    SystemHealthCard(
      backendStatus: backendConnected,
      databaseStatus: databaseConnected, 
      responseTime: averageResponseTime,
    ),
    
    // Recent Activity Feed
    RecentLogsCard(
      logs: recentLogs, // Last 5 logs from API
      onViewAll: () => navigateToLogs(),
    ),
    
    // Quick Actions
    QuickActionsCard([
      ActionButton('تست سیستم', Icons.system_update, testAllSystems),
      ActionButton('پاکسازی لاگ‌ها', Icons.clear_all, clearOldLogs),
      ActionButton('تنظیمات', Icons.settings, navigateToSettings),
    ]),
  ],
)
```

### 2️⃣ Settings Management Page (NEW)
**New file**: `lib/presentation/pages/settings/settings_page.dart`

**Complete settings management interface with real-time validation**

**Required Features**:
```dart
// Settings Page Structure
Scaffold(
  appBar: AppBar(title: 'تنظیمات سیستم'),
  body: SingleChildScrollView(
    padding: EdgeInsets.all(16),
    children: [
      // OpenAI Configuration Section
      SettingsCard(
        title: 'تنظیمات هوش مصنوعی OpenAI',
        icon: Icons.psychology,
        children: [
          // API Key Field with show/hide functionality
          TextFormField(
            decoration: InputDecoration(
              labelText: 'کلید API OpenAI',
              hintText: 'sk-...',
              suffixIcon: IconButton(
                icon: Icon(showApiKey ? Icons.visibility_off : Icons.visibility),
                onPressed: () => toggleApiKeyVisibility(),
              ),
            ),
            obscureText: !showApiKey,
            validator: (value) => validateApiKey(value),
            onChanged: (value) => updateSetting('openai_api_key', value),
          ),
          
          // Model Selection Dropdown
          DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: 'مدل OpenAI'),
            value: currentModel,
            items: [
              DropdownMenuItem(value: 'gpt-4', child: Text('GPT-4')),
              DropdownMenuItem(value: 'gpt-3.5-turbo', child: Text('GPT-3.5 Turbo')),
            ],
            onChanged: (value) => updateSetting('openai_model', value),
          ),
          
          // Max Tokens Slider
          SliderField(
            label: 'حداکثر توکن‌ها',
            value: maxTokens.toDouble(),
            min: 100,
            max: 4096,
            divisions: 39,
            onChanged: (value) => updateSetting('openai_max_tokens', value.toInt().toString()),
          ),
          
          // Temperature Slider
          SliderField(
            label: 'میزان خلاقیت (Temperature)',
            value: temperature,
            min: 0.0,
            max: 1.0,
            divisions: 10,
            onChanged: (value) => updateSetting('openai_temperature', value.toString()),
          ),
          
          // Test Connection Button
          ElevatedButton.icon(
            onPressed: isLoading ? null : testOpenAIConnection,
            icon: isLoading ? CircularProgressIndicator() : Icon(Icons.check_circle),
            label: Text('تست اتصال به OpenAI'),
          ),
        ],
      ),
      
      SizedBox(height: 16),
      
      // System Settings Section
      SettingsCard(
        title: 'تنظیمات عمومی سیستم',
        icon: Icons.settings_system_daydream,
        children: [
          // Language Selection
          DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: 'زبان سیستم'),
            value: appLanguage,
            items: [
              DropdownMenuItem(value: 'fa', child: Text('🇮🇷 فارسی')),
              DropdownMenuItem(value: 'en', child: Text('🇺🇸 English')),
            ],
            onChanged: (value) => updateSetting('app_language', value),
          ),
          
          // Theme Selection
          DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: 'تم رنگی'),
            value: appTheme,
            items: [
              DropdownMenuItem(value: 'light', child: Text('☀️ روشن')),
              DropdownMenuItem(value: 'dark', child: Text('🌙 تیره')),
              DropdownMenuItem(value: 'auto', child: Text('🤖 خودکار')),
            ],
            onChanged: (value) => updateSetting('app_theme', value),
          ),
          
          // Logging Settings
          SwitchListTile(
            title: Text('فعال‌سازی سیستم لاگینگ'),
            subtitle: Text('ثبت رویدادها و خطاهای سیستم'),
            value: enableLogging,
            onChanged: (value) => updateSetting('enable_logging', value.toString()),
          ),
          
          // Max Log Entries
          SliderField(
            label: 'حداکثر تعداد لاگ‌های ذخیره شده',
            value: maxLogEntries.toDouble(),
            min: 100,
            max: 10000,
            divisions: 99,
            onChanged: (value) => updateSetting('max_log_entries', value.toInt().toString()),
          ),
          
          // Auto Save
          SwitchListTile(
            title: Text('ذخیره خودکار'),
            subtitle: Text('ذخیره خودکار تغییرات فرم‌ها'),
            value: autoSave,
            onChanged: (value) => updateSetting('auto_save', value.toString()),
          ),
          
          // Backup Settings
          SwitchListTile(
            title: Text('پشتیبان‌گیری خودکار'),
            subtitle: Text('پشتیبان‌گیری روزانه از داده‌ها'),
            value: backupEnabled,
            onChanged: (value) => updateSetting('backup_enabled', value.toString()),
          ),
        ],
      ),
      
      SizedBox(height: 24),
      
      // Action Buttons
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: saveAllSettings,
            icon: Icon(Icons.save),
            label: Text('ذخیره تغییرات'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
          OutlinedButton.icon(
            onPressed: resetToDefaults,
            icon: Icon(Icons.restore),
            label: Text('بازگردانی پیش‌فرض'),
          ),
          OutlinedButton.icon(
            onPressed: exportSettings,
            icon: Icon(Icons.download),
            label: Text('خروجی تنظیمات'),
          ),
        ],
      ),
    ],
  ),
)
```

### 3️⃣ Professional Logging Dashboard (NEW)
**New file**: `lib/presentation/pages/logs/logs_page.dart`

**Advanced logging interface with filtering, analytics, and real-time updates**

**Required Features**:
```dart
// Logs Dashboard Structure
Scaffold(
  appBar: AppBar(
    title: 'داشبورد لاگینگ و مانیتورینگ',
    actions: [
      IconButton(icon: Icons.refresh, onPressed: refreshLogs),
      IconButton(icon: Icons.clear_all, onPressed: clearOldLogs),
      IconButton(icon: Icons.download, onPressed: exportLogs),
    ],
  ),
  body: Column(
    children: [
      // Analytics Summary Cards
      Container(
        height: 120,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            LogStatCard(
              title: 'کل لاگ‌ها امروز',
              count: todayLogsCount,
              icon: Icons.today,
              color: Colors.blue,
            ),
            LogStatCard(
              title: 'خطاهای جدی',
              count: errorLogsCount, 
              icon: Icons.error,
              color: Colors.red,
            ),
            LogStatCard(
              title: 'هشدارها',
              count: warningLogsCount,
              icon: Icons.warning,
              color: Colors.orange,
            ),
            LogStatCard(
              title: 'اطلاعات',
              count: infoLogsCount,
              icon: Icons.info,
              color: Colors.green,
            ),
          ],
        ),
      ),
      
      // Filters and Search Bar
      Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                labelText: 'جستجو در لاگ‌ها...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) => filterLogs(searchQuery: value),
            ),
            
            SizedBox(height: 12),
            
            // Filter Chips Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: Text('همه'),
                    selected: selectedFilter == LogLevel.all,
                    onSelected: (selected) => setFilter(LogLevel.all),
                  ),
                  FilterChip(
                    label: Text('خطا'),
                    selected: selectedFilter == LogLevel.error,
                    onSelected: (selected) => setFilter(LogLevel.error),
                  ),
                  FilterChip(
                    label: Text('هشدار'),
                    selected: selectedFilter == LogLevel.warning,
                    onSelected: (selected) => setFilter(LogLevel.warning),
                  ),
                  FilterChip(
                    label: Text('اطلاعات'),
                    selected: selectedFilter == LogLevel.info,
                    onSelected: (selected) => setFilter(LogLevel.info),
                  ),
                  FilterChip(
                    label: Text('دیباگ'),
                    selected: selectedFilter == LogLevel.debug,
                    onSelected: (selected) => setFilter(LogLevel.debug),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      
      // Logs List/Table
      Expanded(
        child: ListView.builder(
          itemCount: filteredLogs.length,
          itemBuilder: (context, index) {
            final log = filteredLogs[index];
            return LogItemCard(
              logEntry: log,
              onTap: () => showLogDetails(log),
            );
          },
        ),
      ),
      
      // Pagination Controls (if needed)
      if (totalPages > 1)
        Container(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: currentPage > 1 ? previousPage : null,
                child: Text('صفحه قبل'),
              ),
              Text('صفحه $currentPage از $totalPages'),
              ElevatedButton(
                onPressed: currentPage < totalPages ? nextPage : null,
                child: Text('صفحه بعد'),
              ),
            ],
          ),
        ),
    ],
  ),
  
  // Floating Action Button for Quick Actions
  floatingActionButton: FloatingActionButton.extended(
    onPressed: showQuickActions,
    label: Text('اقدامات سریع'),
    icon: Icon(Icons.speed),
  ),
)
```

## 🔧 Required Widget Components

### Supporting Widgets to Create
```dart
// lib/presentation/widgets/shared/

// 1. StatCard Widget (for dashboard statistics)
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  
  // Implementation with Material Design 3 styling
}

// 2. SettingsCard Widget (for grouping settings)
class SettingsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  
  // Card container with consistent styling
}

// 3. SliderField Widget (custom slider with labels)
class SliderField extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;
  
  // Custom slider with Persian labels
}

// 4. LogItemCard Widget (individual log entry display)
class LogItemCard extends StatelessWidget {
  final Map<String, dynamic> logEntry;
  final VoidCallback? onTap;
  
  // Formatted log display with color coding
}

// 5. LogStatCard Widget (analytics cards)
class LogStatCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;
  
  // Statistics display card
}
```

## 🗂️ File Structure to Implement

```
lib/presentation/
├── pages/
│   ├── home/
│   │   └── home_page.dart                 # MODIFY existing file
│   ├── settings/                          # NEW directory
│   │   ├── settings_page.dart            # NEW - Main settings page
│   │   └── settings_controller.dart       # NEW - State management
│   └── logs/                             # NEW directory
│       ├── logs_page.dart                # NEW - Main logs page
│       └── logs_controller.dart           # NEW - State management
│
├── widgets/
│   └── shared/                           # NEW directory
│       ├── stat_card.dart                # NEW - Dashboard statistics
│       ├── settings_card.dart            # NEW - Settings grouping
│       ├── slider_field.dart             # NEW - Custom slider
│       ├── log_item_card.dart           # NEW - Log entry display
│       └── log_stat_card.dart           # NEW - Log analytics
│
└── routes/
    └── app_routes.dart                   # MODIFY - Add new routes
```

## 🔗 Navigation Implementation

### Update app_routes.dart
```dart
// Add new route constants
class AppRoutes {
  static const String home = '/';
  static const String settings = '/settings';
  static const String logs = '/logs';
  static const String about = '/about';
  
  static Map<String, WidgetBuilder> get routes {
    return {
      home: (context) => const HomePage(),
      settings: (context) => const SettingsPage(),
      logs: (context) => const LogsPage(),
    };
  }
}

// Helper navigation methods
class NavigationHelper {
  static void navigateToSettings(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.settings);
  }
  
  static void navigateToLogs(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.logs);
  }
  
  static void navigateHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
  }
}
```

## 🎯 State Management Strategy

### Controller Classes Structure
```dart
// Settings Controller
class SettingsController extends ChangeNotifier {
  Map<String, String> _settings = {};
  bool _isLoading = false;
  String? _error;
  
  // Getters
  Map<String, String> get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Methods
  Future<void> loadSettings() async;
  Future<bool> updateSetting(String key, String value) async;
  Future<bool> saveAllSettings() async;
  Future<bool> testOpenAIConnection() async;
}

// Logs Controller  
class LogsController extends ChangeNotifier {
  List<Map<String, dynamic>> _logs = [];
  String _selectedFilter = 'ALL';
  String _searchQuery = '';
  Map<String, dynamic> _analytics = {};
  
  // Getters
  List<Map<String, dynamic>> get filteredLogs => _filterLogs();
  Map<String, dynamic> get analytics => _analytics;
  
  // Methods
  Future<void> loadLogs({int limit = 50}) async;
  Future<void> loadAnalytics() async;
  void setFilter(String filter);
  void setSearchQuery(String query);
  Future<bool> clearOldLogs() async;
}
```

## 📊 Enhanced API Integration

### Additional API Methods (add to existing ApiService)
```dart
// Add these methods to lib/core/services/api_service.dart

/// Test OpenAI API connection
static Future<Map<String, dynamic>> testOpenAIConnection(String apiKey) async {
  try {
    // Call a simple OpenAI API endpoint to validate key
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/models'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
    );
    
    return {
      'success': response.statusCode == 200,
      'message': response.statusCode == 200 ? 'اتصال موفق' : 'کلید نامعتبر',
      'statusCode': response.statusCode,
    };
  } catch (e) {
    return {'success': false, 'message': 'خطا در اتصال: $e'};
  }
}

/// Update multiple settings at once
static Future<bool> updateMultipleSettings(Map<String, String> settings) async {
  bool allSuccessful = true;
  
  for (final entry in settings.entries) {
    final success = await updateSetting(entry.key, entry.value);
    if (!success) allSuccessful = false;
  }
  
  return allSuccessful;
}

/// Get log analytics
static Future<Map<String, dynamic>> getLogAnalytics() async {
  try {
    final logs = await getLogs(limit: 1000); // Get recent logs for analysis
    
    final analytics = {
      'total_logs': logs.length,
      'error_count': logs.where((log) => log['log_level'] == 'ERROR').length,
      'warning_count': logs.where((log) => log['log_level'] == 'WARNING').length,
      'info_count': logs.where((log) => log['log_level'] == 'INFO').length,
      'debug_count': logs.where((log) => log['log_level'] == 'DEBUG').length,
      'categories': _getCategoryCounts(logs),
      'today_logs': _getTodayLogsCount(logs),
    };
    
    return analytics;
  } catch (e) {
    return {};
  }
}

/// Clear old logs (keep last 100)
static Future<bool> clearOldLogs({int keepCount = 100}) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/logs/clear.php'),
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: json.encode({'keep_count': keepCount}),
    );
    
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['success'] ?? false;
    }
    return false;
  } catch (e) {
    return false;
  }
}
```

## ✅ Validation & Quality Requirements

### UI/UX Quality Checklist
- [ ] **RTL Support**: All text and layouts properly support Persian RTL
- [ ] **Responsive Design**: Works perfectly on mobile, tablet, desktop
- [ ] **Material Design 3**: Uses latest Material Design components
- [ ] **Loading States**: All API calls show appropriate loading indicators
- [ ] **Error Handling**: User-friendly error messages in Persian
- [ ] **Form Validation**: Real-time validation with clear feedback
- [ ] **Navigation**: Consistent and intuitive navigation throughout app
- [ ] **Performance**: Smooth 60fps animations and transitions

### Technical Quality Checklist  
- [ ] **State Management**: Proper use of Provider pattern
- [ ] **API Integration**: Robust error handling for all API calls
- [ ] **Data Validation**: Input validation before sending to backend
- [ ] **Memory Management**: No memory leaks or excessive resource usage
- [ ] **Code Organization**: Clean, maintainable code structure
- [ ] **Documentation**: All major classes and methods documented in Persian

### Functional Quality Checklist
- [ ] **Settings Persistence**: All settings properly save and reload
- [ ] **Real-time Updates**: Logs update in real-time or with refresh
- [ ] **Search & Filtering**: Log filtering and search work correctly
- [ ] **Data Accuracy**: All displayed data matches backend data
- [ ] **User Feedback**: Success/error notifications for all actions

## 🚀 Performance Targets

```dart
// Target Performance Metrics for Phase 3
class Phase3PerformanceTargets {
  static const Duration maxPageLoadTime = Duration(milliseconds: 400);
  static const Duration maxAPIResponseTime = Duration(milliseconds: 100);
  static const int maxMemoryIncrease = 15; // MB additional
  static const double minFrameRate = 58.0; // fps
  static const int maxAdditionalBundleSize = 200; // KB
}
```

## 📱 Progressive Enhancement Strategy

### Phase 3A (Essential Features)
1. Enhanced dashboard with navigation
2. Basic settings page with form fields
3. Simple logs list with basic filtering

### Phase 3B (Enhanced Features)  
1. Advanced analytics and charts
2. Real-time log monitoring
3. Export/import functionality

### Phase 3C (Polish & Optimization)
1. Advanced animations and transitions
2. Offline capability
3. Performance optimizations

## 🎊 Success Criteria & Deliverables

### ✅ Functional Success Criteria
1. **Complete Navigation**: Users can navigate between all 3 main sections
2. **Settings Management**: All 9 settings can be viewed, edited, and saved
3. **Log Management**: Logs can be viewed, filtered, searched, and managed
4. **Real-time Data**: All data synchronizes properly with backend
5. **Error Handling**: Graceful handling of all error scenarios

### 📸 Required Deliverables
1. **Screenshots**: Desktop and mobile views of all 3 pages
2. **Video Demo**: 2-3 minute walkthrough of complete user flow
3. **Performance Report**: Loading times, API response times, memory usage
4. **Code Documentation**: Comments and documentation for all new code
5. **Testing Report**: Results of manual testing on different screen sizes

### 🏆 Quality Standards
- **Visual Consistency**: Uniform design language across all pages
- **Persian RTL Excellence**: Perfect RTL layout and typography
- **Mobile Responsiveness**: Flawless experience on all device sizes  
- **Performance Excellence**: Fast loading and smooth interactions
- **Professional Polish**: Enterprise-grade UI/UX quality

## 🎯 Implementation Priority

**Start with Phase 3A**, then enhance with 3B and 3C features.

Focus on **core functionality first**, then **visual polish**, then **advanced features**.

---

## 🚀 Ready to Begin Phase 3

This prompt provides complete specifications for transforming DataSave from a simple test application into a **professional, enterprise-grade dashboard system**.

**Estimated Development Time**: 4-6 hours with GitHub Copilot
**Complexity Level**: Medium to Advanced
**Architecture Impact**: Significant UI layer expansion

✅ **All backend APIs are confirmed working**
✅ **Database schema is fully operational**  
✅ **Flutter foundation is solid**
✅ **Ready for immediate implementation**

**Let's build the most beautiful, functional dashboard for DataSave! 🎨✨**