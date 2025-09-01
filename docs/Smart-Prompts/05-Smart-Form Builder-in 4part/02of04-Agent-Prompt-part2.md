# 🎯 DataSave مرحله ۵.۲: Form Builder UI Engine
## نسخه سختگیرانه و قانونمند - STRICT MODE UI ENGINE

---

## 🚨 **قوانین مطلق پرامپت - NON-NEGOTIABLE RULES**

### ⛔ **STOP! کاملاً ممنوع:**
```yaml
❌ هیچ تغییری در Database Schema (مرحله 5.1 کامل است)
❌ هیچ تغییری در Backend PHP Classes موجود
❌ هیچ modification در API endpoints فعلی 
❌ هیچ package اضافی بدون تأیید صریح
❌ تغییر در آدرس‌ها و مسیرهای موجود
❌ پیش از دریافت تأیید، هیچ عمل اجرایی انجام ندهید
❌ تغییر در theme و typography موجود
❌ شکستن Clean Architecture patterns موجود
```

### ✅ **فقط مجاز به:**
```yaml
✅ ایجاد Flutter UI components جدید
✅ افزودن صفحات Form Builder 
✅ Integration با PHP APIs موجود
✅ استفاده از Provider state management
✅ رعایت Persian RTL standards موجود
✅ ایجاد مستندات مربوط به UI components
✅ توسعه Widget Library برای form builder
✅ پیاده‌سازی Drag & Drop interface
```

---

## 📋 **مأموریت دقیق مرحله ۵.۲**

### 🎯 هدف منحصراً:
**طراحی و پیاده‌سازی Form Builder UI Engine با استفاده از foundation مرحله ۵.۱**

### 🗺️ **نقشه راه مرحله ۵ - وضعیت فعلی:**
```yaml
Phase 5.1: Database Evolution & Schema        ← ✅ تکمیل شده
Phase 5.2: Form Builder UI Engine            ← 🎯 شما اینجا هستید  
Phase 5.3: AI Integration Engine (آینده)
Phase 5.4: Analytics & Optimization (آینده)

⚠️ تذکر: فقط روی 5.2 کار کنید. سایر مراحل فقط Context!
```

---

## 📊 **Context کامل - مرحله ۵.۱ تکمیل شده**

### ✅ **Database Schema آماده (دست نزنید):**
```sql
-- جداول عملیاتی مرحله 5.1
users (2 records):
  - admin@datasave.ir (admin role)
  - test@datasave.ir (user role)
  - bcrypt password hashing ✅
  - Persian name support ✅

forms (1 sample):
  - persian_title: "فرم تماس با ما"
  - JSON schema support ✅
  - user ownership ✅
  - status management ✅

form_widgets (10 widgets):
  - text, textarea, number, email, select
  - radio, checkbox, date, time, submit
  - Persian labels ✅
  - JSON configuration ✅

form_responses (ready):
  - response collection system ✅
  - IP tracking ✅
  - JSON data storage ✅

-- Views و Triggers فعال:
v_user_forms_stats, v_popular_widgets, v_recent_responses
trg_response_insert_stats, trg_response_delete_stats, trg_form_create_widget_stats
```

### ✅ **PHP Backend آماده (استفاده کنید):**
```php
Classes Available:
- backend/classes/User.php        ← Authentication + CRUD
- backend/classes/Form.php        ← Form management + publishing
- backend/classes/FormWidget.php  ← Widget library management
- backend/classes/FormResponse.php ← Response collection

API Endpoints موجود (استفاده کنید):
- GET/POST /api/settings/*        ← تنظیمات سیستم
- POST /api/logs/*                ← لاگینگ سیستم
- GET /api/system/*               ← وضعیت سیستم

⚠️ نیاز به API endpoints جدید برای Form Builder
```

### ✅ **Flutter Foundation موجود (گسترش دهید):**
```yaml
Current Structure:
lib/
├── core/
│   ├── config/app_config.dart          ← Config management ✅
│   ├── constants/app_constants.dart    ← Constants ✅ 
│   ├── theme/app_theme.dart           ← Material Design 3 + Vazirmatn ✅
│   └── utils/validators.dart          ← Validation utilities ✅
├── presentation/
│   ├── pages/home/home_page.dart      ← Dashboard موجود ✅
│   └── routes/app_routes.dart         ← Navigation ✅
└── main.dart                          ← Entry point ✅

Current Features:
- Persian RTL Support ✅
- Material Design 3 Theme ✅  
- Vazirmatn Font Integration ✅
- Provider State Management ✅
- Responsive Design Foundation ✅
```

---

## 🎯 **Requirements سختگیرانه مرحله ۵.۲**

### **۱. Form Builder Core Interface (اجباری):**

#### **صفحه اصلی Form Builder:**
```yaml
Location: lib/presentation/pages/form_builder/
Required Components:
  - form_builder_page.dart (صفحه اصلی)
  - widgets_library_panel.dart (پنل کتابخانه ویجت‌ها)
  - form_canvas.dart (بوم طراحی فرم)
  - form_preview_panel.dart (پنل پیش‌نمایش)
  - properties_panel.dart (پنل تنظیمات ویجت)

Persian Features:
  - تمام متن‌ها فارسی
  - RTL layout کامل
  - راست‌چین کردن پنل‌ها
  - فونت Vazirmatn
  - پیام‌های خطا فارسی

UI Requirements:
  - Material Design 3 consistency
  - Mobile-first responsive
  - Accessibility support
  - Loading states
  - Error handling UI
```

#### **Widget Library System:**
```yaml
Integration با form_widgets table:
  - دریافت 10 ویجت پایه از database
  - نمایش ویجت‌ها با برچسب‌های فارسی
  - Drag & Drop functionality
  - Icon display برای هر ویجت
  - Category grouping (text, selection, date, etc)

Widget Types پیاده‌سازی:
  text: کادر متن ساده
  textarea: کادر متن چندخط  
  number: ورودی عددی
  email: ورودی ایمیل
  select: لیست کشویی
  radio: دکمه رادیویی
  checkbox: چک‌باکس
  date: انتخاب تاریخ
  time: انتخاب زمان
  submit: دکمه ارسال
```

#### **Drag & Drop Form Designer:**
```yaml
Canvas Requirements:
  - Drop zone مشخص با visual indicators
  - Widget positioning system
  - Grid system برای alignment
  - Multi-select ویجت‌ها
  - Copy/Paste/Delete operations
  - Undo/Redo functionality (basic)

Drag & Drop Features:
  - Widget dragging از library به canvas
  - Reordering ویجت‌ها در canvas
  - Visual feedback هنگام drag
  - Snap to grid functionality
  - Persian tooltips و guides

Persian RTL Considerations:
  - Canvas layout راست‌چین
  - Widget positioning RTL-aware
  - Property panels در سمت چپ
  - Form preview در جهت صحیح
```

### **۲. API Integration Layer (ضروری):**

#### **نیاز به API Endpoints جدید:**
```php
Required New APIs:
POST /api/forms/create.php
  - ایجاد فرم جدید
  - ذخیره JSON schema
  - User ownership validation

GET /api/forms/user_forms.php  
  - دریافت فرم‌های کاربر
  - Pagination support
  - Status filtering

PUT /api/forms/update.php
  - بروزرسانی فرم موجود
  - Version control
  - Schema validation

GET /api/widgets/library.php
  - دریافت کتابخانه ویجت‌ها
  - Category filtering
  - Persian label support

DELETE /api/forms/delete.php
  - حذف فرم (soft delete)
  - Cascade considerations
  - Permission checking
```

#### **Flutter API Service Layer:**
```yaml
Location: lib/core/services/
Required Services:
  - form_api_service.dart (Form CRUD operations)
  - widget_api_service.dart (Widget library access)
  - user_service.dart (User management - future)

Integration Pattern:
  - استفاده از Dio package موجود
  - Error handling مطابق patterns موجود
  - Provider state management
  - Response caching برای widgets
  - Persian error messages

Service Methods:
  - Future<List<Form>> getUserForms(int userId)
  - Future<Form> createForm(Form formData)
  - Future<Form> updateForm(int formId, Form formData)
  - Future<List<Widget>> getWidgetLibrary()
  - Future<bool> deleteForm(int formId)
```

### **۳. State Management Architecture (الزامی):**

#### **Provider Classes جدید:**
```yaml
Location: lib/core/providers/
Required Providers:
  - form_builder_provider.dart (حالت Form Builder)
  - widget_library_provider.dart (مدیریت Widget Library)
  - form_list_provider.dart (لیست فرم‌های کاربر)
  - canvas_provider.dart (وضعیت Canvas)

FormBuilderProvider Features:
  - currentForm: Form? (فرم در حال ویرایش)
  - selectedWidget: FormWidget? (ویجت انتخاب شده)
  - canvasWidgets: List<FormWidget> (ویجت‌های روی canvas)
  - isPreviewMode: bool (حالت پیش‌نمایش)
  - formSchema: Map<String, dynamic> (JSON schema)

State Management Methods:
  - addWidgetToCanvas(FormWidget widget)
  - removeWidgetFromCanvas(String widgetId)  
  - updateWidgetProperties(String widgetId, Map properties)
  - selectWidget(String widgetId)
  - togglePreviewMode()
  - saveForm()
  - loadForm(int formId)
```

#### **Error Handling State:**
```yaml
Error Provider Integration:
  - Persian error messages
  - User-friendly error display
  - Retry mechanisms
  - Offline state handling
  - Network connectivity awareness

Loading States:
  - Form loading indicators
  - Widget library loading
  - Save operation feedback
  - Real-time validation states
```

### **۴. UI/UX Implementation (دقیق):**

#### **Navigation Integration:**
```yaml
Route Updates در app_routes.dart:
  '/form-builder': Form Builder main page
  '/form-builder/new': New form creation
  '/form-builder/edit/{id}': Edit existing form
  '/form-library': Form library/templates
  '/form-preview/{id}': Form preview mode

Bottom Navigation Enhancement:
  - اضافه کردن tab برای Form Builder
  - Icon: Icons.build_rounded
  - Label: "فرم‌ساز"
  - Integration با home_page.dart

Drawer Menu Updates:
  - "فرم‌های من" menu item
  - "کتابخانه ویجت‌ها" menu item
  - "قالب‌های آماده" (future)
```

#### **Responsive Design Requirements:**
```yaml
Mobile (< 768px):
  - Single panel view
  - Bottom sheet برای properties  
  - Simplified widget library
  - Touch-optimized drag & drop
  - Persian keyboard support

Tablet (768-1024px):
  - Two panel layout
  - Widget library + canvas visible
  - Collapsible properties panel
  - Enhanced touch interactions

Desktop (> 1024px):
  - Three panel layout
  - Widget library | Canvas | Properties
  - Full drag & drop experience
  - Keyboard shortcuts support
  - Context menus
```

#### **Persian RTL Excellence:**
```yaml
Typography:
  - Vazirmatn font در تمام texts
  - صحیح sizing برای Persian characters
  - Line height optimization
  - Letter spacing مناسب

Layout:
  - Canvas alignment RTL
  - Panel positioning راست‌چین
  - Button placement مناسب
  - Icon direction awareness
  - Text field alignment

Content:
  - تمام labels و instructions فارسی
  - Error messages Persian
  - Tooltips و help texts فارسی  
  - Placeholder texts مناسب
  - Success messages Persian
```

---

## 🏗️ **Architecture Integration (اجباری)**

### **Clean Architecture Compliance:**
```yaml
Presentation Layer:
  - Pages در presentation/pages/form_builder/
  - Widgets در presentation/widgets/form_builder/
  - Provider classes برای state management
  - Route definitions در app_routes.dart

Core Layer Integration:
  - Services در core/services/
  - Utils در core/utils/ 
  - Constants در core/constants/
  - Theme consistency در core/theme/

Code Organization:
  - هر component جداگانه file
  - Persian comments برای business logic
  - Error handling mطابق patterns موجود
  - Testing readiness (basic structure)
```

### **Performance Requirements:**
```yaml
UI Performance:
  - 60 FPS drag & drop operations
  - Smooth animations و transitions
  - Lazy loading برای widget library
  - Efficient canvas rendering
  - Memory management برای large forms

API Performance:
  - Response caching برای widgets
  - Debounced save operations
  - Optimistic UI updates
  - Background sync capabilities
  - Error recovery mechanisms

Bundle Size:
  - حداکثر +2MB increase
  - Tree-shaking optimization
  - Asset optimization
  - Code splitting considerations
```

---

## 📐 **Security & Validation (غیرقابل مذاکره)**

### **Client-Side Validation:**
```yaml
Form Validation:
  - Required field validation
  - Persian text validation
  - Email format validation (Persian-aware)
  - Number range validation
  - JSON schema validation

Widget Configuration:
  - Property type checking
  - Value range validation
  - Persian character support
  - XSS prevention در text fields
  - Safe JSON parsing
```

### **API Security Integration:**
```yaml
Authentication:
  - User session validation (prepare for future)
  - Form ownership verification  
  - Permission checking
  - CSRF protection awareness

Data Validation:
  - Server-side validation مطابقت
  - SQL injection prevention
  - Input sanitization
  - JSON schema validation
  - Persian encoding safety
```

---

## 🛠️ **Deliverables مورد انتظار (دقیقاً همین‌ها)**

### **۱. Flutter UI Components (اجباری):**
```yaml
Core Pages:
1. lib/presentation/pages/form_builder/form_builder_page.dart
2. lib/presentation/pages/form_builder/form_list_page.dart
3. lib/presentation/pages/form_builder/form_preview_page.dart

Widget Components:
4. lib/presentation/widgets/form_builder/widget_library_panel.dart
5. lib/presentation/widgets/form_builder/form_canvas.dart
6. lib/presentation/widgets/form_builder/properties_panel.dart
7. lib/presentation/widgets/form_builder/draggable_widget.dart
8. lib/presentation/widgets/form_builder/form_preview.dart

State Management:
9. lib/core/providers/form_builder_provider.dart
10. lib/core/providers/widget_library_provider.dart
11. lib/core/providers/form_list_provider.dart

Services:
12. lib/core/services/form_api_service.dart
13. lib/core/services/widget_api_service.dart
```

### **۲. PHP API Endpoints (ضروری):**
```yaml
New API Files:
1. backend/api/forms/create.php
2. backend/api/forms/user_forms.php
3. backend/api/forms/update.php
4. backend/api/forms/delete.php
5. backend/api/widgets/library.php

Integration:
- استفاده از classes موجود در backend/classes/
- Error handling مطابق patterns موجود
- CORS configuration consistency  
- JSON response format مطابقت
- Persian error messages
```

### **۳. Navigation & Routing:**
```yaml
Updates Required:
1. lib/presentation/routes/app_routes.dart
   - اضافه کردن routes جدید
   - Parameter handling برای form editing

2. lib/presentation/pages/home/home_page.dart
   - Bottom navigation update
   - Dashboard statistics update
   - Form Builder entry point

3. Persian Navigation Labels:
   - "فرم‌ساز" for Form Builder
   - "فرم‌های من" for My Forms
   - "پیش‌نمایش" for Preview
```

### **۴. Documentation Updates:**
```yaml
New Documentation Folder: docs/08-Form-Builder/
Required Files:
1. form-builder-architecture.md
2. ui-components-reference.md  
3. drag-drop-implementation.md
4. widget-library-system.md
5. api-integration-guide.md
6. persian-rtl-considerations.md
7. responsive-design-specs.md
8. testing-strategy.md

Update Existing Files:
- docs/04-Flutter-Frontend/flutter-architecture.md
- docs/99-Quick-Reference/api-quick-reference.md
- docs/00-Project-Overview/ (add phase 5.2 report)
```

---

## ⚡ **Performance & Quality Standards**

### **UI/UX Performance Benchmarks:**
```yaml
Interaction Response:
- Widget drag start: < 16ms (60 FPS)
- Drop operation: < 50ms
- Property panel update: < 100ms
- Form save operation: < 2 seconds
- Canvas render: < 200ms for 50 widgets

Memory Usage:
- Base Form Builder: < 50MB
- Per widget in canvas: < 1MB
- Widget library cache: < 10MB
- Maximum form size: 100 widgets

Network Performance:
- Widget library load: < 500ms
- Form save: < 1 second
- Form load: < 800ms
- API timeout: 10 seconds
```

### **Code Quality Requirements:**
```yaml
Dart Code:
- Dartfmt compliance: 100%
- Linting rules: strict mode
- Persian comments: business logic فقط
- Error handling: comprehensive
- Null safety: strict compliance

File Organization:
- Clean Architecture layers
- Single responsibility principle
- Persian naming for UI strings
- English naming for technical code
- Consistent import ordering
```

---

## 🔍 **Testing & Validation Strategy**

### **UI Testing Requirements:**
```yaml
Widget Testing:
- تمام form builder widgets
- Drag & drop functionality
- Persian text rendering
- RTL layout correctness
- Error state displays

Integration Testing:
- Form creation flow
- Widget library interaction
- API integration flows
- State management correctness
- Navigation flows

Manual Testing:
- Persian keyboard input
- Touch interactions
- Responsive breakpoints
- Performance on low-end devices
- Persian content validation
```

### **API Testing Requirements:**
```yaml
Endpoint Testing:
- تمام CRUD operations
- Error response handling
- Persian character support
- JSON schema validation
- Permission checking

Database Integration:
- Foreign key constraints
- Transaction handling
- Persian data storage
- Performance with large datasets
- Concurrent access handling
```

---

## 🚫 **Red Lines - خطوط قرمز مرحله ۵.۲**

### **هرگز این کارها را نکنید:**
```yaml
❌ تغییر در Database Schema مرحله 5.1
❌ Modification در PHP classes موجود (User.php, Form.php, etc)
❌ تغییر در API endpoints فعلی
❌ شکستن Clean Architecture patterns
❌ تغییر theme یا typography فعلی
❌ اضافه کردن package های سنگین
❌ تغییر در XAMPP configuration
❌ ایجاد authentication system (مرحله آینده!)
❌ پیاده‌سازی AI features (مرحله 5.3!)
```

### **قانون‌های اجباری:**
```yaml
✅ هر component باید Persian RTL باشد
✅ تمام API calls باید error handling داشته باشد
✅ Provider pattern برای state management
✅ Material Design 3 consistency
✅ Mobile-first responsive design
✅ Clean Architecture compliance
✅ Performance benchmarks رعایت شود
✅ Documentation همزمان با کد
```

---

## 📊 **Success Criteria مرحله ۵.۲**

### **Technical Success:**
```yaml
UI Implementation:
- Form Builder interface کاملاً کارکرد
- Drag & Drop عملیاتی
- Widget Library integration موفق
- Persian RTL excellence
- Responsive design working

API Integration:
- 5 API endpoints جدید عملیاتی
- Flutter services integration موفق
- Error handling شامل Persian messages
- Performance benchmarks achieved

State Management:
- Provider classes working smoothly
- Form data persistence
- Canvas state management
- Widget selection & properties
```

### **Business Success:**
```yaml
User Experience:
- کاربر قادر به ایجاد فرم ساده
- Widget library قابل استفاده
- Form preview functional
- Persian user interface excellent

Foundation:
- آماده برای AI integration (Phase 5.3)
- Scalable architecture برای widgets بیشتر
- Documentation جامع برای developers
- Testing strategy اجرایی
```

---

## 🎭 **Final Instructions - دستورات نهایی**

### **مرحله‌به‌مرحله اجرا:**
```yaml
Step 1: API Endpoints creation (5 فایل PHP)
Step 2: Flutter service layer implementation
Step 3: Provider classes development  
Step 4: Core UI components creation
Step 5: Form Builder main interface
Step 6: Drag & Drop functionality
Step 7: Navigation integration
Step 8: Persian RTL validation
Step 9: Responsive testing
Step 10: Documentation creation

⚠️ هر مرحله باید test شود قبل از ادامه
⚠️ Persian RTL در هر مرحله validation شود
⚠️ Performance benchmarks در هر مرحله check شود
```

### **Quality Gates:**
```yaml
Gate 1: API endpoints (POST/GET tests successful)
Gate 2: Service layer (Flutter-PHP communication)
Gate 3: Provider integration (State management working)
Gate 4: Basic UI (Persian RTL rendering)
Gate 5: Drag & Drop (Core functionality)
Gate 6: Form Builder (Complete interface)
Gate 7: Integration (End-to-end workflow)
Gate 8: Performance (Benchmarks achieved)
Gate 9: Documentation (Complete coverage)
Gate 10: Final validation (User acceptance)
```

---

## 🎊 **Ready to Execute? - آماده اجرا؟**

```yaml
✅ Mission Clear: Form Builder UI Engine
✅ Foundation Ready: Database + PHP Models از 5.1  
✅ Quality Standards: سختگیرانه و دقیق
✅ Success Criteria: قابل سنجش و واضح
✅ Red Lines: مشخص و غیرقابل عبور
✅ Architecture: Clean و consistent
✅ Persian RTL: اولویت اول
✅ Performance: Benchmarked و optimized

🚀 اجرای مرحله ۵.۲ آغاز می‌شود...

⚠️ یادآوری: فقط UI Engine - نه AI، نه Authentication
⚠️ یادآوری: Persian RTL excellence در همه‌جا
⚠️ یادآوری: Clean Architecture patterns حفظ شود
⚠️ یادآوری: Database Schema مرحله 5.1 دست نخورد
```

---

**📅 Created:** 2025-09-01  
**👤 Author:** DataSave Project Manager - مجتبی حسنی  
**🎯 Phase:** 5.2 Form Builder UI Engine - STRICT MODE  
**🔗 Dependencies:** Phase 5.1 Database Evolution ✅ COMPLETED  
**🔒 Status:** READY FOR EXECUTION  

---

**منتظر تأیید شروع عملیات Form Builder UI Engine هستیم... ⏳**

## 📁 **پیشنهاد نهایی: ایجاد docs/08-Form-Builder/**

```yaml
📁 docs/08-Form-Builder/
├── 01-architecture/
│   ├── form-builder-overview.md
│   ├── ui-components-hierarchy.md
│   └── state-management-strategy.md
├── 02-implementation/
│   ├── drag-drop-system.md
│   ├── widget-library-integration.md
│   └── canvas-management.md
├── 03-api-integration/
│   ├── form-crud-apis.md
│   ├── widget-library-api.md
│   └── error-handling-strategy.md
└── 04-user-experience/
    ├── persian-rtl-implementation.md
    ├── responsive-design-guide.md
    └── accessibility-considerations.md

🎯 آماده برای تخصصی‌ترین مستندسازی Form Builder! ✨
```