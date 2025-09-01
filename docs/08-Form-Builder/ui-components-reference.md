# 📚 Form Builder - مستندات کامپوننت‌های UI

## 📊 Document Information
- **Created:** 2025-09-01
- **Last Updated:** 2025-09-01
- **Version:** 5.2.0
- **Maintainer:** DataSave Development Team
- **Related Files:** 
  - `lib/presentation/widgets/form_builder/`
  - `lib/core/providers/form_builder_provider.dart`
  - `backend/api/forms/`

## 🎯 Overview
**مستندات کامل UI Components مربوط به Form Builder Engine که در مرحله 5.2 پیاده‌سازی شد.**

---

## 📋 Table of Contents
1. [کامپوننت‌های UI اصلی](#main-components)
2. [FormCanvas - بوم طراحی](#form-canvas) 
3. [WidgetLibraryPanel - پنل کتابخانه](#widget-library)
4. [FormPropertiesPanel - پنل تنظیمات](#properties-panel)
5. [Provider Management](#providers)
6. [API Integration](#api-integration)
7. [Persian RTL Support](#rtl-support)

---

## 🧩 Main Components {#main-components}

### 📁 Structure Overview
```
lib/presentation/widgets/form_builder/
├── form_canvas.dart                    ✅ بوم کشیدن و رها کردن
├── widget_library_panel.dart          ✅ پنل کتابخانه ویجت‌ها  
├── form_properties_panel.dart         ✅ پنل تنظیمات ویجت
├── form_builder_app_bar.dart          ✅ نوار ابزار Form Builder
└── properties_panel.dart              ✅ پنل پیکربندی عمومی
```

### 🎨 UI Features 
- **Material Design 3** compliance
- **Persian RTL** layout support
- **Responsive design** (mobile & desktop)
- **Drag & Drop** interaction
- **Real-time preview** capability

---

## 🖼️ FormCanvas - بوم طراحی {#form-canvas}

### 📍 Location: `lib/presentation/widgets/form_builder/form_canvas.dart`

### 🎯 Purpose
**بوم اصلی برای کشیدن و رها کردن ویجت‌ها و ساخت فرم**

### ✨ Key Features
```dart
class FormCanvas extends StatelessWidget {
  // ✅ Drag & Drop support for FormWidgetModel
  // ✅ Real-time widget preview
  // ✅ Widget selection/deselection
  // ✅ Canvas state management
  // ✅ Persian RTL layout
}
```

### 📋 Supported Widget Types
| Type | Persian Label | Preview |
|------|---------------|---------|
| `text` | کادر متن | TextFormField |
| `textarea` | متن چندخط | Multi-line TextFormField |  
| `number` | ورودی عددی | Numeric TextFormField |
| `email` | ایمیل | Email TextFormField |
| `select` | لیست کشویی | DropdownButtonFormField |
| `radio` | دکمه رادیویی | RadioListTile group |
| `checkbox` | چک‌باکس | CheckboxListTile group |
| `date` | انتخاب تاریخ | Date TextFormField |
| `time` | انتخاب زمان | Time TextFormField |
| `submit` | دکمه ارسال | ElevatedButton |

### 🔄 Data Flow
```dart
// Widget Drop Process:
FormWidgetModel → Map<String, dynamic> → Provider.addWidgetToCanvas()

// Converted Data Structure:
{
  'id': 'unique_widget_id',
  'type': 'text|textarea|number...',
  'label': 'Persian widget label',
  'config': {...},
  'validation_rules': {...},
  'default_props': {...}
}
```

### 🎮 User Interactions
- **Drop Zone**: Active drag target with visual feedback
- **Widget Selection**: Click to select/deselect widgets
- **Widget Deletion**: Delete button for selected widgets  
- **Canvas Scrolling**: Vertical scroll for long forms

---

## 📚 WidgetLibraryPanel - پنل کتابخانه {#widget-library}

### 📍 Location: `lib/presentation/widgets/form_builder/widget_library_panel.dart`

### 🎯 Purpose  
**نمایش کتابخانه ویجت‌های قابل استفاده و امکان کشیدن آن‌ها به بوم**

### 🗂️ Category Management
```dart
// Available Categories:
- 'all' → همه ویجت‌ها
- 'basic' → ویجت‌های پایه  
- 'advanced' → ویجت‌های پیشرفته
- 'input' → ویجت‌های ورودی
- 'selection' → ویجت‌های انتخابی
```

### 📊 Provider Integration
```dart
Consumer<WidgetLibraryProvider>(
  builder: (context, provider, child) {
    // ✅ Access to filteredWidgets
    // ✅ Loading state management
    // ✅ Error handling
    // ✅ Category filtering
  }
)
```

### 🔍 Search & Filter
- **Real-time search** in Persian & English labels
- **Category filtering** with count display
- **Active/Inactive** widget filtering
- **Sort options**: display_order, usage_count, created_at

---

## ⚙️ FormPropertiesPanel - پنل تنظیمات {#properties-panel}

### 📍 Location: `lib/presentation/widgets/form_builder/form_properties_panel.dart`

### 🎯 Purpose
**تنظیمات و پیکربندی ویجت انتخاب شده روی بوم**

### 🔧 Configuration Options
- **Widget Label**: تغییر برچسب ویجت
- **Validation Rules**: قوانین اعتبارسنجی
- **Default Values**: مقادیر پیش‌فرض
- **Display Options**: تنظیمات نمایش
- **Advanced Settings**: تنظیمات پیشرفته

### 📝 Form Schema Generation
```dart
// Generated JSON Schema:
{
  "version": "1.0",
  "widgets": [
    {
      "id": "widget_1",
      "type": "text", 
      "label": "نام و نام خانوادگی",
      "required": true,
      "validation": {
        "minLength": 3,
        "maxLength": 50
      }
    }
  ]
}
```

---

## 🔄 Provider Management {#providers}

### 📍 FormBuilderProvider
**Location:** `lib/core/providers/form_builder_provider.dart`

#### ✅ Key Methods Fixed
```dart
class FormBuilderProvider with ChangeNotifier {
  // ✅ Canvas Management
  void addWidgetToCanvas(Map<String, dynamic> widgetData)
  void removeWidgetFromCanvas(String widgetId) 
  void selectWidget(String widgetId)
  
  // ✅ Form Operations  
  Future<bool> saveForm({...})
  Future<void> loadForm(int formId)
  
  // ✅ State Management
  List<Map<String, dynamic>> get canvasWidgets
  String? get selectedWidgetId
  bool get isPreviewMode
}
```

### 📍 WidgetLibraryProvider  
**Location:** `lib/core/providers/widget_library_provider.dart`

#### ✅ Key Methods Added
```dart
class WidgetLibraryProvider with ChangeNotifier {
  // ✅ Library Management
  Future<void> loadWidgetLibrary()
  List<Map<String, dynamic>> get filteredWidgets
  
  // ✅ Category & Search
  WidgetLibraryProvider setCategory(String category) // ✅ Fixed
  Future<void> searchWidgets(String query)
  
  // ✅ Error Handling
  String? get errorMessage // ✅ Property exists
}
```

---

## 🌐 API Integration {#api-integration}

### 📍 Backend Endpoints Status

#### ✅ All API Files Complete
```php
backend/api/forms/
├── create.php          ✅ Form creation
├── update.php          ✅ Form updating  
├── delete.php          ✅ Form deletion
├── user_forms.php      ✅ User forms list
```

```php
backend/api/widgets/  
└── library.php         ✅ Widget library
```

### 📊 API Data Flow
```
Flutter FormApiService ↔ PHP Backend ↔ MySQL Database

FormBuilderProvider.saveForm() → 
  FormApiService.createForm() →
    POST /api/forms/create.php →
      Form::create() → Database
```

---

## 🌙 Persian RTL Support {#rtl-support}

### ✅ RTL Implementation
- **Canvas Layout**: راست‌چین
- **Widget Positioning**: RTL-aware
- **Panel Layout**: سمت راست برای کتابخانه
- **Text Direction**: صحیح برای فارسی
- **Scrolling Direction**: طبیعی RTL

### 🎨 Typography
- **Font Family**: Vazirmatn
- **Text Alignment**: راست‌چین
- **UI Labels**: فارسی
- **Error Messages**: فارسی

---

## 🔄 Related Documentation

- [Form Builder API Reference](../02-Backend-APIs/api-endpoints-reference.md)
- [Database Schema](../03-Database-Schema/tables-reference.md)
- [Flutter Architecture](../04-Flutter-Frontend/flutter-architecture.md) 
- [State Management](../04-Flutter-Frontend/state-management.md)

---

## ✅ Implementation Status

### 🎯 Phase 5.2 Completion: **95%**
- ✅ **UI Components**: FormCanvas, WidgetLibraryPanel, PropertiesPanel
- ✅ **Provider Integration**: Form Builder & Widget Library providers
- ✅ **API Services**: Complete backend integration
- ✅ **Persian RTL**: Full support implemented
- ✅ **Navigation**: Integrated with app routing
- ⚠️ **Testing**: End-to-end testing pending

### 🚨 Minor Issues Remaining
- **Deprecated warnings**: Flutter SDK compatibility (non-blocking)
- **Unused variables**: Code cleanup needed (minor)
- **Performance optimization**: Can be improved in future phases

---

*Last updated: 2025-09-01 | Version: 5.2.0*
*🎯 Form Builder UI Engine - مرحله 5.2 تکمیل شده*
