# مرجع سریع Flutter - Flutter Quick Reference

## 📊 Document Information  
- **Created:** 2025-09-01
- **Last Updated:** 2025-09-01 (Form Builder Update)
- **Version:** 5.2.0
- **Maintainer:** DataSave Development Team
- **Related Files:** `pubspec.yaml`, `/lib/`, Flutter documentation

## 🎯 Overview
مرجع سریع کامل Flutter برای پروژه DataSave شامل Form Builder components، command های مفید، widget های پرکاربرد، debugging techniques، و best practices.

## ⚡ Form Builder Quick Commands

### 🎯 Form Builder Navigation
```dart
// Navigate to Form Builder
Navigator.pushNamed(context, AppRoutes.formBuilder, arguments: {
  'formId': formId, // null for new form
  'userId': userId,
});

// Form Builder with specific form
Navigator.pushNamed(context, '/form-builder', arguments: {
  'formId': 123,
  'userId': 1,
});
```

### 🧩 Key Components Usage
```dart
// Form Canvas - بوم طراحی
FormCanvas() // Auto-handles drag & drop

// Widget Library Panel  
WidgetLibraryPanel() // Shows available widgets

// Properties Panel
FormPropertiesPanel() // Configure selected widget

// Complete Form Builder Page
FormBuilderPage(formId: null, userId: 1)
```

### 🔄 Provider Quick Access
```dart
// Form Builder Provider
final formProvider = context.read<FormBuilderProvider>();
formProvider.addWidgetToCanvas(widgetData);
formProvider.selectWidget(widgetId);
formProvider.saveForm();

// Widget Library Provider  
final widgetProvider = context.read<WidgetLibraryProvider>();
await widgetProvider.loadWidgetLibrary();
final widgets = widgetProvider.filteredWidgets;
```

## 📋 Table of Contents
- [Commands مفید](#commands-مفید)
- [Widgets اساسی](#widgets-اساسی)
- [State Management](#state-management)
- [Navigation](#navigation)
- [Styling & Theming](#styling--theming)
- [Persian/RTL](#persianrtl)
- [Debugging](#debugging)
- [Performance](#performance)

## 🚀 Commands مفید

### Project Management
```bash
# ایجاد پروژه جدید
flutter create my_app
flutter create --org com.example my_app

# اطلاعات Flutter
flutter --version
flutter doctor
flutter doctor -v

# Dependencies
flutter pub get
flutter pub upgrade
flutter pub outdated
flutter pub deps

# Clean
flutter clean
flutter pub cache clean
```

### Development
```bash
# اجرا
flutter run
flutter run --debug
flutter run --profile
flutter run --release

# Hot Reload/Restart
# در terminal: r (hot reload), R (hot restart), q (quit)

# اجرا در دستگاه خاص
flutter devices
flutter run -d chrome
flutter run -d "iPhone 14"

# Debug
flutter run --verbose
flutter logs
flutter analyze
```

### Build Commands
```bash
# Android
flutter build apk
flutter build apk --release
flutter build appbundle --release
flutter build apk --split-per-abi

# iOS
flutter build ios
flutter build ipa

# Web
flutter build web
flutter build web --release
flutter build web --web-renderer html

# Desktop
flutter build windows
flutter build macos
flutter build linux
```

### Testing
```bash
# تست ها
flutter test
flutter test --coverage
flutter test test/widget_test.dart

# Integration tests
flutter drive --target=test_driver/app.dart
```

## 🧩 Widgets اساسی

### Layout Widgets
```dart
// Column & Row
Column(
  mainAxisAlignment: MainAxisAlignment.center,
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text('آیتم 1'),
    Text('آیتم 2'),
  ],
)

Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    Icon(Icons.star),
    Text('متن'),
    IconButton(onPressed: () {}, icon: Icon(Icons.add)),
  ],
)

// Container
Container(
  width: 100,
  height: 100,
  padding: EdgeInsets.all(16),
  margin: EdgeInsets.symmetric(vertical: 8),
  decoration: BoxDecoration(
    color: Colors.blue,
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.5),
        spreadRadius: 2,
        blurRadius: 5,
        offset: Offset(0, 3),
      ),
    ],
  ),
  child: Text('محتوا'),
)

// Padding
Padding(
  padding: EdgeInsets.only(left: 16, right: 16, top: 8),
  child: Text('متن با padding'),
)

// Expanded & Flexible
Row(
  children: [
    Expanded(
      flex: 2,
      child: Container(color: Colors.red, height: 50),
    ),
    Expanded(
      flex: 1,
      child: Container(color: Colors.blue, height: 50),
    ),
  ],
)

// Stack
Stack(
  alignment: Alignment.center,
  children: [
    Container(width: 100, height: 100, color: Colors.red),
    Positioned(
      top: 10,
      right: 10,
      child: Icon(Icons.close),
    ),
    Text('روی همه'),
  ],
)

// Wrap
Wrap(
  spacing: 8.0,
  runSpacing: 4.0,
  children: [
    Chip(label: Text('تگ 1')),
    Chip(label: Text('تگ 2')),
    Chip(label: Text('تگ 3')),
  ],
)
```

### Input Widgets
```dart
// TextField
TextField(
  decoration: InputDecoration(
    labelText: 'نام کاربری',
    hintText: 'نام کاربری خود را وارد کنید',
    prefixIcon: Icon(Icons.person),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  textDirection: TextDirection.rtl,
  onChanged: (value) {
    print('مقدار: $value');
  },
)

// TextFormField (برای Form)
TextFormField(
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'این فیلد الزامی است';
    }
    return null;
  },
  decoration: InputDecoration(
    labelText: 'ایمیل',
    suffixIcon: Icon(Icons.email),
  ),
)

// Button های مختلف
ElevatedButton(
  onPressed: () {
    print('دکمه کلیک شد');
  },
  child: Text('ذخیره'),
)

OutlinedButton(
  onPressed: () {},
  child: Text('لغو'),
)

TextButton(
  onPressed: () {},
  child: Text('ویرایش'),
)

IconButton(
  onPressed: () {},
  icon: Icon(Icons.favorite),
)

FloatingActionButton(
  onPressed: () {},
  child: Icon(Icons.add),
)

// Checkbox
bool isChecked = false;
Checkbox(
  value: isChecked,
  onChanged: (bool? value) {
    setState(() {
      isChecked = value ?? false;
    });
  },
)

// Radio
int selectedValue = 1;
Radio<int>(
  value: 1,
  groupValue: selectedValue,
  onChanged: (int? value) {
    setState(() {
      selectedValue = value ?? 1;
    });
  },
)

// Switch
bool isEnabled = true;
Switch(
  value: isEnabled,
  onChanged: (bool value) {
    setState(() {
      isEnabled = value;
    });
  },
)

// Slider
double currentValue = 0.5;
Slider(
  value: currentValue,
  min: 0,
  max: 1,
  divisions: 10,
  label: currentValue.round().toString(),
  onChanged: (double value) {
    setState(() {
      currentValue = value;
    });
  },
)

// DropdownButton
String selectedItem = 'گزینه 1';
DropdownButton<String>(
  value: selectedItem,
  items: ['گزینه 1', 'گزینه 2', 'گزینه 3']
      .map((String value) {
    return DropdownMenuItem<String>(
      value: value,
      child: Text(value),
    );
  }).toList(),
  onChanged: (String? newValue) {
    setState(() {
      selectedItem = newValue!;
    });
  },
)
```

### Display Widgets
```dart
// Text
Text(
  'متن فارسی',
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.blue,
    fontFamily: 'Vazirmatn',
  ),
  textDirection: TextDirection.rtl,
  textAlign: TextAlign.center,
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
)

// RichText
RichText(
  textDirection: TextDirection.rtl,
  text: TextSpan(
    text: 'متن معمولی ',
    style: DefaultTextStyle.of(context).style,
    children: [
      TextSpan(
        text: 'متن پررنگ',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(text: ' و ادامه متن'),
    ],
  ),
)

// Image
Image.asset(
  'assets/images/logo.png',
  width: 100,
  height: 100,
  fit: BoxFit.cover,
)

Image.network(
  'https://example.com/image.jpg',
  loadingBuilder: (context, child, loadingProgress) {
    if (loadingProgress == null) return child;
    return Center(
      child: CircularProgressIndicator(
        value: loadingProgress.expectedTotalBytes != null
            ? loadingProgress.cumulativeBytesLoaded /
                loadingProgress.expectedTotalBytes!
            : null,
      ),
    );
  },
)

// Icon
Icon(
  Icons.star,
  color: Colors.amber,
  size: 30,
)

// Card
Card(
  elevation: 4,
  margin: EdgeInsets.all(8),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      children: [
        Text('عنوان کارت'),
        SizedBox(height: 8),
        Text('محتوای کارت'),
      ],
    ),
  ),
)

// ListTile
ListTile(
  leading: CircleAvatar(
    child: Icon(Icons.person),
  ),
  title: Text('عنوان'),
  subtitle: Text('زیرعنوان'),
  trailing: Icon(Icons.arrow_forward_ios),
  onTap: () {
    print('ListTile کلیک شد');
  },
)

// Chip
Chip(
  avatar: Icon(Icons.tag),
  label: Text('برچسب'),
  deleteIcon: Icon(Icons.close),
  onDeleted: () {
    print('حذف شد');
  },
)

// Divider
Divider(
  height: 20,
  thickness: 2,
  color: Colors.grey,
)
```

### Scrollable Widgets
```dart
// ListView
ListView(
  children: [
    ListTile(title: Text('آیتم 1')),
    ListTile(title: Text('آیتم 2')),
    ListTile(title: Text('آیتم 3')),
  ],
)

// ListView.builder (برای لیست‌های بزرگ)
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListTile(
      title: Text(items[index]),
    );
  },
)

// ListView.separated
ListView.separated(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListTile(title: Text(items[index]));
  },
  separatorBuilder: (context, index) => Divider(),
)

// GridView
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: 8,
    mainAxisSpacing: 8,
  ),
  itemCount: items.length,
  itemBuilder: (context, index) {
    return Card(
      child: Center(child: Text(items[index])),
    );
  },
)

// SingleChildScrollView
SingleChildScrollView(
  child: Column(
    children: [
      // محتوای طولانی
    ],
  ),
)

// PageView
PageView(
  children: [
    Container(color: Colors.red),
    Container(color: Colors.green),
    Container(color: Colors.blue),
  ],
)

// RefreshIndicator
RefreshIndicator(
  onRefresh: () async {
    // عملیات refresh
    await Future.delayed(Duration(seconds: 2));
  },
  child: ListView(
    children: [
      // آیتم‌های لیست
    ],
  ),
)
```

## 📊 State Management

### StatefulWidget Basic
```dart
class CounterWidget extends StatefulWidget {
  @override
  _CounterWidgetState createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int _counter = 0;
  
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('شمارنده: $_counter'),
        ElevatedButton(
          onPressed: _incrementCounter,
          child: Text('افزایش'),
        ),
      ],
    );
  }
}
```

### Provider (مدیریت state ساده)
```dart
// Model
class Counter extends ChangeNotifier {
  int _count = 0;
  int get count => _count;
  
  void increment() {
    _count++;
    notifyListeners();
  }
}

// در main.dart
ChangeNotifierProvider(
  create: (context) => Counter(),
  child: MyApp(),
)

// استفاده
Consumer<Counter>(
  builder: (context, counter, child) {
    return Text('شمارنده: ${counter.count}');
  },
)

// یا
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final counter = Provider.of<Counter>(context);
    return Text('شمارنده: ${counter.count}');
  }
}
```

### Bloc Pattern
```dart
// Event
abstract class CounterEvent {}
class Increment extends CounterEvent {}
class Decrement extends CounterEvent {}

// State
class CounterState {
  final int count;
  CounterState(this.count);
}

// Bloc
class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(CounterState(0)) {
    on<Increment>((event, emit) {
      emit(CounterState(state.count + 1));
    });
    
    on<Decrement>((event, emit) {
      emit(CounterState(state.count - 1));
    });
  }
}

// استفاده
BlocBuilder<CounterBloc, CounterState>(
  builder: (context, state) {
    return Column(
      children: [
        Text('شمارنده: ${state.count}'),
        Row(
          children: [
            ElevatedButton(
              onPressed: () => context.read<CounterBloc>().add(Increment()),
              child: Text('+'),
            ),
            ElevatedButton(
              onPressed: () => context.read<CounterBloc>().add(Decrement()),
              child: Text('-'),
            ),
          ],
        ),
      ],
    );
  },
)
```

## 🧭 Navigation

### Basic Navigation
```dart
// رفتن به صفحه جدید
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => NewScreen()),
);

// برگشت
Navigator.pop(context);

// برگشت با مقدار
Navigator.pop(context, 'نتیجه');

// رفتن و جایگزین کردن
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => NewScreen()),
);

// پاک کردن تمام stack و رفتن به صفحه جدید
Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (context) => HomeScreen()),
  (route) => false,
);
```

### Named Routes
```dart
// در main.dart
MaterialApp(
  initialRoute: '/',
  routes: {
    '/': (context) => HomeScreen(),
    '/profile': (context) => ProfileScreen(),
    '/settings': (context) => SettingsScreen(),
  },
)

// استفاده
Navigator.pushNamed(context, '/profile');
Navigator.pushReplacementNamed(context, '/settings');

// با arguments
Navigator.pushNamed(
  context, 
  '/profile',
  arguments: {'userId': 123},
);

// دریافت arguments
class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final userId = args['userId'];
    
    return Scaffold(
      appBar: AppBar(title: Text('پروفایل $userId')),
      body: Text('محتوای پروفایل'),
    );
  }
}
```

### Dialog & BottomSheet
```dart
// AlertDialog
showDialog(
  context: context,
  builder: (BuildContext context) {
    return AlertDialog(
      title: Text('تأیید'),
      content: Text('آیا مطمئن هستید؟'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('خیر'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            // عملیات مورد نظر
          },
          child: Text('بله'),
        ),
      ],
    );
  },
);

// BottomSheet
showModalBottomSheet(
  context: context,
  builder: (BuildContext context) {
    return Container(
      height: 200,
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.share),
            title: Text('اشتراک‌گذاری'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.delete),
            title: Text('حذف'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  },
);

// SnackBar
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('پیام موفقیت'),
    duration: Duration(seconds: 3),
    action: SnackBarAction(
      label: 'باشه',
      onPressed: () {},
    ),
  ),
);
```

## 🎨 Styling & Theming

### Theme Configuration
```dart
// در main.dart
MaterialApp(
  theme: ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    fontFamily: 'Vazirmatn',
    
    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      elevation: 4,
    ),
    
    // Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    
    // Input Theme
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      filled: true,
      fillColor: Colors.grey[100],
    ),
  ),
  
  // Dark Theme
  darkTheme: ThemeData.dark().copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
  ),
  
  themeMode: ThemeMode.system,
)

// استفاده از Theme در widget
Container(
  color: Theme.of(context).colorScheme.primary,
  child: Text(
    'متن',
    style: Theme.of(context).textTheme.headlineSmall,
  ),
)
```

### Custom Styling
```dart
// TextStyle
TextStyle myTextStyle = TextStyle(
  fontFamily: 'Vazirmatn',
  fontSize: 16,
  fontWeight: FontWeight.w600,
  color: Colors.blue[800],
  letterSpacing: 0.5,
  height: 1.5,
);

// BoxDecoration
BoxDecoration myDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(12),
  border: Border.all(color: Colors.grey[300]!),
  boxShadow: [
    BoxShadow(
      color: Colors.grey.withOpacity(0.1),
      spreadRadius: 1,
      blurRadius: 3,
      offset: Offset(0, 2),
    ),
  ],
  gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.blue[100]!, Colors.blue[50]!],
  ),
);

// Material Style
Material(
  elevation: 4,
  borderRadius: BorderRadius.circular(8),
  color: Colors.white,
  child: InkWell(
    borderRadius: BorderRadius.circular(8),
    onTap: () {},
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Text('کلیک کنید'),
    ),
  ),
)
```

## 🌍 Persian/RTL

### RTL Configuration
```dart
// در main.dart
import 'package:flutter_localizations/flutter_localizations.dart';

MaterialApp(
  localizationsDelegates: [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: [
    Locale('fa', 'IR'), // فارسی
    Locale('en', 'US'), // انگلیسی
  ],
  locale: Locale('fa', 'IR'),
)

// Directionality
Directionality(
  textDirection: TextDirection.rtl,
  child: MyWidget(),
)

// Auto Direction
Widget buildText(String text) {
  bool isPersian = RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  return Directionality(
    textDirection: isPersian ? TextDirection.rtl : TextDirection.ltr,
    child: Text(text),
  );
}
```

### Persian Widgets
```dart
// TextField فارسی
TextField(
  textDirection: TextDirection.rtl,
  decoration: InputDecoration(
    labelText: 'نام کاربری',
    hintText: 'نام کاربری را وارد کنید',
  ),
)

// Persian Date
import 'package:persian_tools/persian_tools.dart';

Text(PersianTools.formatDate(DateTime.now()))

// Persian Numbers
Text(PersianTools.formatNumber('1234567'))

// Currency
Text(PersianTools.formatCurrency(1000000))
```

## 🐛 Debugging

### Debug Console
```dart
// Print
print('مقدار: $value');

// Debug Print (فقط در debug mode)
debugPrint('پیام debug');

// Assert (فقط در debug mode)
assert(value > 0, 'مقدار باید مثبت باشد');

// Developer Log
import 'dart:developer' as developer;
developer.log('پیام log', name: 'MyApp');
```

### Flutter Inspector
```dart
// در widget
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Debug Example'),
    ),
    body: Column(
      children: [
        // برای debug کردن widget خاص
        Container(
          key: Key('my-container'),
          child: Text('Debug این container'),
        ),
      ],
    ),
  );
}
```

### Debug Information
```bash
# اطلاعات دستگاه
flutter devices

# لاگ های دستگاه
flutter logs

# Performance profiling
flutter run --profile

# Memory debugging
flutter run --enable-vm-service
```

### Common Debug Widgets
```dart
// حاشیه برای debug
Container(
  decoration: BoxDecoration(
    border: Border.all(color: Colors.red), // برای دیدن مرز
  ),
  child: MyWidget(),
)

// نمایش اندازه
LayoutBuilder(
  builder: (context, constraints) {
    print('عرض: ${constraints.maxWidth}');
    print('ارتفاع: ${constraints.maxHeight}');
    return MyWidget();
  },
)

// Debug بندی
if (kDebugMode) {
  return Text('Debug Mode');
} else {
  return Text('Release Mode');
}
```

## ⚡ Performance

### Best Practices
```dart
// استفاده از const
const Text('متن ثابت')
const SizedBox(height: 16)

// ListView.builder برای لیست‌های بزرگ
ListView.builder(
  itemCount: 1000,
  itemBuilder: (context, index) {
    return ListTile(title: Text('آیتم $index'));
  },
)

// RepaintBoundary برای جلوگیری از repaint غیرضروری
RepaintBoundary(
  child: ExpensiveWidget(),
)

// AutomaticKeepAlive برای حفظ state
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> 
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  
  @override
  Widget build(BuildContext context) {
    super.build(context); // مهم!
    return MyExpensiveWidget();
  }
}

// Lazy loading برای تصاویر
Image.network(
  imageUrl,
  loadingBuilder: (context, child, loadingProgress) {
    if (loadingProgress == null) return child;
    return CircularProgressIndicator();
  },
)
```

### Performance Monitoring
```bash
# Performance profiling
flutter run --profile

# Performance overlay
flutter run --enable-vm-service

# در کد برای نمایش Performance overlay
import 'package:flutter/rendering.dart';

void main() {
  debugProfileBuildsEnabled = true; // نمایش rebuild ها
  runApp(MyApp());
}
```

### Memory Management
```dart
// صحیح: dispose کردن controllers
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late TextEditingController _controller;
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _animationController = AnimationController(vsync: this);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return TextField(controller: _controller);
  }
}
```

## 🔧 Useful Extensions

### String Extensions
```dart
extension StringExtension on String {
  bool get isPersian => RegExp(r'[\u0600-\u06FF]').hasMatch(this);
  
  String get toPersianDigits {
    String persianDigits = this;
    const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const persianDigits_ = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    
    for (int i = 0; i < englishDigits.length; i++) {
      persianDigits = persianDigits.replaceAll(englishDigits[i], persianDigits_[i]);
    }
    return persianDigits;
  }
  
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }
}

// استفاده
String text = "123 test";
if (text.isPersian) {
  print('متن فارسی است');
}
print(text.toPersianDigits); // ۱۲۳ test
```

### Context Extensions
```dart
extension ContextExtension on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  
  void showSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
  
  void hideKeyboard() {
    FocusScope.of(this).unfocus();
  }
}

// استفاده
if (context.screenWidth > 600) {
  // Layout برای صفحه بزرگ
}

context.showSnackBar('پیام موفقیت');
context.hideKeyboard();
```

## 🛠️ Development Tips

### Hot Reload Rules
```dart
// ✅ تغییرات که Hot Reload پشتیبانی می‌کند:
- تغییر متن و رنگ
- اضافه/حذف widget ها
- تغییر در build method
- تغییر در styling

// ❌ تغییراتی که نیاز به Hot Restart دارند:
- تغییر در main() function
- تغییر در initState()
- تغییر در class declarations
- اضافه کردن package جدید
- تغییر در assets
```

### Code Organization
```
lib/
├── main.dart
├── core/
│   ├── constants/
│   ├── utils/
│   ├── extensions/
│   └── widgets/
├── data/
│   ├── models/
│   ├── repositories/
│   └── services/
├── presentation/
│   ├── screens/
│   ├── widgets/
│   └── bloc/
└── gen/
    └── assets.gen.dart
```

### Code Snippets (VS Code)
```json
// در settings.json
{
  "flutter-stateless-widget": {
    "prefix": "stl",
    "body": [
      "class $1 extends StatelessWidget {",
      "  const $1({Key? key}) : super(key: key);",
      "",
      "  @override",
      "  Widget build(BuildContext context) {",
      "    return $0;",
      "  }",
      "}"
    ]
  }
}
```

## 🔄 Related Documentation
- [Flutter Architecture](../04-Flutter-Frontend/flutter-architecture.md)
- [Persian RTL Implementation](../04-Flutter-Frontend/persian-rtl-implementation.md)
- [State Management](../04-Flutter-Frontend/state-management.md)
- [UI Components Library](../04-Flutter-Frontend/ui-components-library.md)

---
*Last updated: 2025-09-01*  
*File: docs/99-Quick-Reference/flutter-quick-reference.md*