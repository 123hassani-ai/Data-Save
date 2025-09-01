# Frontend Flutter - Flutter Frontend Documentation

## 📊 Document Information
- **Created:** 2025-01-09
- **Last Updated:** 2025-01-09  
- **Version:** 1.0
- **Maintainer:** DataSave Development Team

## 🎯 Overview
مستندات کامل Frontend Flutter در پروژه DataSave شامل معماری، مدیریت state، کامپوننت‌های UI و پیاده‌سازی Persian RTL.

## 📚 Documentation Sections

### 🏗️ [Flutter Architecture](./flutter-architecture.md)
معماری کامل Flutter Frontend با تمرکز بر Clean Architecture و Persian support:
- فلسفه معماری Flutter و Clean Architecture
- ساختار فایل‌ها و naming conventions  
- Presentation Layer و Pages Architecture
- Core Layer و Services Architecture
- Persian RTL Implementation کامل
- Performance optimization و best practices

**Key Features:**
- Clean Architecture pattern
- Provider state management
- Persian-first design
- Material Design 3
- RTL layout support

### 📱 [State Management](./state-management.md)
مدیریت State کامل با Provider pattern و ChangeNotifier:
- فلسفه Provider Pattern و مقایسه با alternatives
- Controllers Architecture با BaseController
- Error Handling centralized
- Persian support در state management
- Performance optimization با Selector
- Advanced patterns و dependency injection

**Key Features:**
- Provider-based state management
- Centralized error handling
- Persian text handling
- Debounced updates
- Selective rebuilds

### 🎨 [UI Components Library](./ui-components-library.md)
کتابخانه کامل کامپوننت‌های UI بهینه شده برای فارسی:
- Design System philosophy و Material Design 3
- Shared Components (StatCard، SettingsCard)
- Form Components (PersianTextField، PersianDropdown)
- Navigation Components (PersianAppBar، PersianBottomNav)
- Persian-Specific Components
- Theme integration و responsive design

**Key Features:**
- Material Design 3 components
- Persian RTL components
- Responsive design
- Accessibility support
- Theme integration

## 🛠️ Technical Stack

### Frontend Technologies
```yaml
Framework: Flutter 3.x Web
State Management: Provider Pattern
Architecture: Clean Architecture
UI Framework: Material Design 3
Font: Vazirmatn Persian Font
Localization: Persian (fa_IR)
Text Direction: RTL Support
```

### Key Dependencies
```yaml
flutter: ^3.0.0
provider: ^6.0.5
http: ^0.13.5
flutter_localizations: Flutter SDK
material_design_icons_flutter: ^7.0.0
```

## 📁 Project Structure

```
lib/
├── 📁 core/                          # هسته مرکزی
│   ├── 📁 config/                    # پیکربندی‌ها
│   ├── 📁 constants/                 # ثابت‌های سیستم
│   ├── 📁 logger/                    # سیستم لاگینگ
│   ├── 📁 models/                    # مدل‌های داده
│   ├── 📁 services/                  # سرویس‌های خارجی
│   ├── 📁 theme/                     # تم و ظاهر فارسی
│   └── 📁 utils/                     # ابزارها
├── 📁 presentation/                  # لایه نمایش
│   ├── 📁 controllers/               # کنترلرهای state
│   ├── 📁 pages/                     # صفحات برنامه
│   ├── 📁 routes/                    # مسیریابی
│   └── 📁 widgets/                   # کامپوننت‌های UI
└── 📄 main.dart                      # نقطه ورود
```

## 🇮🇷 Persian Support Features

### RTL Implementation
- ✅ Complete right-to-left layout
- ✅ Vazirmatn Persian font integration  
- ✅ Persian number formatting
- ✅ Persian date/time handling
- ✅ Contextual text direction detection

### UI Components
- ✅ Persian-optimized TextField
- ✅ Persian Dropdown components
- ✅ Persian DatePicker
- ✅ Persian NumberField with formatting
- ✅ RTL-aware navigation

### State Management
- ✅ Persian text validation
- ✅ Persian error messages
- ✅ Persian logging system
- ✅ Persian number utilities
- ✅ Cultural adaptations

## 🎨 Design System

### Material Design 3
- **Dynamic Color System**: Adaptive color schemes
- **Typography Scale**: Persian font hierarchy
- **Component Updates**: Modern Material 3 components
- **Accessibility**: Enhanced accessibility features

### Persian Adaptations
- **Font Family**: Vazirmatn for optimal Persian reading
- **Color Palette**: Culturally appropriate colors
- **Spacing**: 8dp grid system adapted for Persian text
- **Icons**: RTL-appropriate icon directions

## 🏃‍♂️ Quick Start Guide

### 1. Setup Development Environment
```bash
# Install Flutter dependencies
flutter pub get

# Run the application
flutter run -d chrome --web-renderer html
```

### 2. Basic Component Usage
```dart
// StatCard example
StatCard(
  title: 'کل کاربران',
  value: PersianUtils.formatNumber(1234),
  icon: Icons.people,
  color: Colors.blue,
  onTap: () => navigateToUsers(),
)

// Persian TextField
PersianTextField(
  label: 'نام کاربری',
  hint: 'نام خود را وارد کنید',
  onChanged: (value) => controller.updateUsername(value),
)
```

### 3. State Management Setup
```dart
// Controller usage
Consumer<SettingsController>(
  builder: (context, controller, child) {
    if (controller.isLoading) {
      return const LoadingCard(message: 'در حال بارگذاری...');
    }
    return SettingsForm(controller: controller);
  },
)
```

## 📊 Performance Considerations

### Optimization Techniques
- **Const Constructors**: همه widgets از const استفاده می‌کنند
- **Selective Rebuilds**: Selector برای کنترل بازسازی
- **Widget Caching**: AutomaticKeepAlive برای صفحات پیچیده
- **Image Optimization**: تصاویر بهینه شده برای web
- **Code Splitting**: Lazy loading برای صفحات

### Memory Management
- **Controller Disposal**: مدیریت صحیح lifecycle controllers
- **Stream Subscriptions**: لغو subscription‌ها
- **Cache Management**: مدیریت حافظه cache
- **Listener Cleanup**: پاک‌سازی event listeners

## 🧪 Testing Strategy

### Unit Testing
```dart
// Controller testing example
test('SettingsController loads settings correctly', () async {
  final controller = SettingsController();
  await controller.loadSettings();
  
  expect(controller.settings.isNotEmpty, true);
  expect(controller.error, null);
});
```

### Widget Testing
```dart
// Widget testing example  
testWidgets('StatCard displays Persian numbers', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: StatCard(
        title: 'تست',
        value: '۱,۲۳۴',
        icon: Icons.test,
      ),
    ),
  );
  
  expect(find.text('۱,۲۳۴'), findsOneWidget);
});
```

## 🚀 Deployment

### Web Deployment
```bash
# Build for production
flutter build web --release --web-renderer html

# Deploy to server
cp -r build/web/* /var/www/html/datasave/
```

### Performance Optimization
- **Web Renderer**: HTML renderer برای compatibility
- **Tree Shaking**: حذف کد غیرضروری  
- **Minification**: فشرده‌سازی assets
- **Caching**: Browser caching optimization

## 📚 Learning Resources

### Flutter Resources
- [Flutter Documentation](https://flutter.dev/docs)
- [Material Design 3](https://m3.material.io/)
- [Provider Documentation](https://pub.dev/packages/provider)

### Persian Development
- [Persian Fonts Guide](https://github.com/rastikerdar/vazirmatn)
- [RTL Development Best Practices](https://developer.android.com/training/basics/supporting-devices/languages#rtl-best-practices)
- [Persian Localization](https://flutter.dev/docs/development/accessibility-and-localization/internationalization)

## ⚠️ Important Notes

### Development Best Practices
1. **Persian-First Design**: همه UI اول برای فارسی طراحی شود
2. **Consistent State Management**: همیشه از Provider استفاده کنید
3. **Error Handling**: همه خطاها به فارسی نمایش داده شوند  
4. **Performance**: از const constructors و optimization استفاده کنید
5. **Accessibility**: semantic labels برای screen readers

### Common Issues & Solutions
1. **Font Loading**: اطمینان از بارگذاری صحیح فونت Vazirmatn
2. **RTL Layout**: تست در هر دو جهت LTR و RTL
3. **State Sync**: همگام‌سازی state بین components
4. **Memory Leaks**: dispose کردن controllers و listeners

### Future Roadmap
- **Domain Layer**: اضافه کردن business logic layer
- **Repository Pattern**: abstraction برای data access
- **Offline Support**: پشتیبانی offline و caching
- **Advanced Testing**: integration و e2e testing
- **Performance Monitoring**: monitoring و analytics

## 🔄 Related Documentation
- [Services Integration](../05-Services-Integration/README.md)
- [UI/UX Design System](../06-UI-UX-Design/README.md)  
- [System Architecture](../01-Architecture/system-architecture.md)
- [Database Schema](../03-Database-Schema/README.md)

---
*این مستندات بخشی از مجموعه مستندات فنی پروژه DataSave است*  
*Last updated: 2025-01-09*  
*File: /docs/04-Flutter-Frontend/README.md*
