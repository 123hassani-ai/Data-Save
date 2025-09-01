# 🎯 DataSave مرحله ۵.۱: Database Evolution & Form Schema
## نسخه سختگیرانه و قانونمند - STRICT MODE

---

## 🚨 **قوانین مطلق پرامپت - NON-NEGOTIABLE RULES**

### ⛔ **STOP! کاملاً ممنوع:**
```yaml
❌ هیچ کاری به صورت خودسرانه انجام ندهید
❌ هیچ فایل اضافی ایجاد نکنید  
❌ هیچ تغییری در ساختار موجود ندهید
❌ هیچ API endpoint اضافی ننویسید
❌ هیچ UI component ایجاد نکنید
❌ پیش از دریافت تأیید صریح، هیچ عمل اجرایی انجام ندهید
```

### ✅ **فقط مجاز به:**
```yaml
✅ تحلیل database schema موجود
✅ طراحی جداول جدید مطابق الزامات مشخص شده
✅ نوشتن SQL migrations دقیق
✅ ایجاد documentation مربوط به تغییرات database
✅ ارائه گزارش تأثیرات بر سیستم موجود
```

---

## 📋 **مأموریت دقیق مرحله ۵.۱**

### 🎯 هدف منحصراً:
**طراحی و پیاده‌سازی Database Evolution برای تبدیل DataSave به Form Builder Core Engine**

### 🗺️ **نقشه راه کل مرحله ۵ (فقط برای اطلاع - عمل ممنوع):**
```yaml
Phase 5.1: Database Evolution & Schema ← شما اینجا هستید
Phase 5.2: Form Builder UI Engine (آینده)
Phase 5.3: AI Integration Engine (آینده) 
Phase 5.4: Analytics & Optimization (آینده)

⚠️ تذکر: فقط روی 5.1 کار کنید. بقیه فقط Context است!
```

---

## 📊 **Context کامل پروژه (مرحله ۴ تکمیل شده)**

### ✅ **وضعیت فعلی Database:**
```sql
-- جداول موجود (100% تأیید شده - دست نزنید)
Table: system_settings
  - id (INT, PK, Auto Increment)
  - setting_key (VARCHAR(100), UNIQUE)
  - setting_value (TEXT)
  - setting_type (ENUM: string,json,boolean,number)
  - description (TEXT)
  - created_at, updated_at (TIMESTAMP)
  Status: 9 رکورد active + عملیاتی

Table: system_logs  
  - id (INT, PK, Auto Increment)
  - log_level (ENUM: DEBUG,INFO,WARNING,ERROR,SEVERE)
  - category (VARCHAR(50))
  - message (TEXT)
  - context (JSON)
  - created_at (TIMESTAMP)
  Status: Real-time logging + عملیاتی
```

### ✅ **API Endpoints موجود (دست نزنید):**
```php
GET  /api/settings/get.php     - دریافت تنظیمات
POST /api/settings/update.php  - بروزرسانی تنظیمات
POST /api/logs/create.php      - ثبت لاگ
GET  /api/logs/list.php        - دریافت لاگ‌ها
GET  /api/system/status.php    - وضعیت سیستم
GET  /api/system/info.php      - اطلاعات سرور
POST /api/logs/clear.php       - پاکسازی لاگ‌ها
POST /api/test/connection.php  - تست اتصالات
Status: 100% عملیاتی
```

### ✅ **Technical Stack (ثابت - تغییر ممنوع):**
```yaml
Database: MySQL 8.0 (Port 3307, Password: Mojtab@123)
Charset: utf8mb4_persian_ci
Backend: PHP 8+ with PDO
Server: XAMPP Local Development
Path: /Applications/XAMPP/xamppfiles/htdocs/datasave
Connection: mysqli + PDO mixed (نگه دارید)
```

---

## 🎯 **Requirements سختگیرانه مرحله ۵.۱**

### **۱. جداول جدید مورد نیاز (حتماً ایجاد کنید):**

#### **Table: users**
```sql
Requirements:
- مدیریت کاربران سیستم
- هش‌کردن رمز عبور با bcrypt
- سطح دسترسی‌های مختلف (admin, user)
- پشتیبانی فیلدهای فارسی
- Timestamp های ایجاد و بروزرسانی
- Soft delete capability
- Persian name fields support

Mandatory Fields:
- id (primary key)
- email (unique)
- password_hash 
- persian_name
- role (enum)
- status
- timestamps
```

#### **Table: forms**
```sql
Requirements:
- ذخیره اطلاعات پایه فرم‌ها
- پشتیبانی نام و توضیحات فارسی
- ارتباط با کاربر سازنده
- وضعیت فرم (active, draft, archived)
- JSON schema برای ساختار فرم
- Versioning support
- Persian RTL metadata

Mandatory Fields:
- id (primary key)
- user_id (foreign key)
- persian_title
- persian_description
- form_schema (JSON)
- status
- version
- timestamps
```

#### **Table: form_widgets**
```sql
Requirements:
- کتابخانه ویجت‌های فرم
- پشتیبانی انواع ویجت (text, select, checkbox, etc)
- تنظیمات ویجت به صورت JSON
- برچسب‌های فارسی
- اعتبارسنجی‌های مخصوص هر ویجت
- Icon و styling information

Mandatory Fields:
- id (primary key)
- widget_type
- persian_label
- widget_config (JSON)
- validation_rules (JSON)
- icon_name
- timestamps
```

#### **Table: form_responses**
```sql
Requirements:
- ذخیره پاسخ‌های کاربران
- ارتباط با فرم مربوطه
- IP address و user agent
- Timestamp دقیق ثبت
- JSON برای ذخیره داده‌های متغیر
- Persian content support

Mandatory Fields:
- id (primary key)
- form_id (foreign key)
- response_data (JSON)
- respondent_ip
- user_agent
- submitted_at
```

### **۲. Migration Strategy (حتماً رعایت کنید):**
```yaml
Step 1: بررسی compatibility با جداول موجود
Step 2: ایجاد backup script برای جداول موجود
Step 3: تعریف foreign keys و indexes
Step 4: تست migration روی database test
Step 5: rollback plan در صورت مشکل

⚠️ Zero Downtime: سیستم فعلی باید بدون اختلال کار کند
```

### **۳. Data Consistency Rules (قانون):**
```yaml
Encoding: همه جداول utf8mb4_persian_ci
Foreign Keys: همیشه با ON DELETE CASCADE/SET NULL
Indexes: روی فیلدهای پرکاربرد حتماً
Persian Fields: VARCHAR به اندازه کافی برای فارسی
JSON Fields: validation در application layer
Timestamps: CURRENT_TIMESTAMP و ON UPDATE
```

---

## 📐 **Architecture Integration (اجباری)**

### **Integration با سیستم موجود:**
```yaml
system_settings compatibility:
  - فیلد جدید برای form builder settings
  - max_forms_per_user, default_form_template, etc

system_logs enhancement:
  - کتگوری جدید: FORM_BUILDER, USER_MANAGEMENT
  - لاگ‌های عملیات form creation, user registration

API readiness:
  - آماده‌سازی برای API endpoints آینده
  - database methods مطابق با pattern موجود

Performance considerations:
  - indexes روی join fields
  - query optimization برای form listing
  - caching strategy برای widgets
```

### **Security Requirements (غیرقابل مذاکره):**
```yaml
Password Security:
  - bcrypt hashing برای passwords
  - salt منحصر به فرد برای هر password

Data Validation:
  - input sanitization برای فیلدهای فارسی
  - XSS protection در JSON fields
  - SQL injection prevention

Access Control:
  - user ownership validation
  - role-based permissions
  - session management preparation
```

---

## 🛠️ **Deliverables مورد انتظار (دقیقاً همین‌ها)**

### **۱. SQL Migration Scripts:**
```yaml
Required Files:
1. migration_v5_1_create_users_table.sql
2. migration_v5_1_create_forms_table.sql  
3. migration_v5_1_create_form_widgets_table.sql
4. migration_v5_1_create_form_responses_table.sql
5. migration_v5_1_indexes_and_relations.sql
6. migration_v5_1_default_data.sql
7. rollback_v5_1_complete.sql

Format: 
- هر فایل شامل IF NOT EXISTS checks
- Persian comments در SQL
- Error handling
- Performance optimizations
```

### **۲. Database Documentation:**
```yaml
Required Documentation:
1. جدول ERD جدید (text format)
2. Schema changes explanation (فارسی)
3. Migration impact analysis
4. Performance implications
5. Security considerations
6. Rollback procedures

Format: Markdown با استانداردهای موجود پروژه
```

### **۳. PHP Database Classes (آماده‌سازی):**
```yaml
Required Classes:
1. Database/User.php - مدل کاربران
2. Database/Form.php - مدل فرم‌ها  
3. Database/FormWidget.php - مدل ویجت‌ها
4. Database/FormResponse.php - مدل پاسخ‌ها

Format:
- مطابق pattern موجود در Database/SystemSettings.php
- Persian comments
- Error handling consistency
- PDO prepared statements
```

### **۴. Testing & Validation:**
```yaml
Test Requirements:
1. Insert test data برای تمام جداول
2. Foreign key constraints validation
3. Character encoding test (Persian)
4. Performance benchmark queries
5. Error scenarios testing

Format: SQL test scripts + results documentation
```

---

## ⚡ **Performance & Optimization Requirements**

### **Mandatory Performance Standards:**
```yaml
Query Performance:
- Form listing: < 50ms برای 1000 فرم
- User lookup: < 10ms با index
- Widget loading: < 30ms برای کل library
- Response insertion: < 20ms per record

Index Strategy:
- forms.user_id (برای listing سریع)
- forms.status (برای filtering)
- form_responses.form_id (برای analytics)
- users.email (برای login)

Memory Usage:
- هر query حداکثر 10MB memory
- JSON fields حداکثر 1MB per record
- Efficient pagination برای بزرگ datasets
```

### **Storage Optimization:**
```yaml
JSON Storage:
- Compressed JSON برای form_schema
- Indexed JSON keys برای جستجوی سریع
- Validation rules در application layer

Text Fields:
- VARCHAR lengths optimized برای Persian
- TEXT fields فقط جایی که ضروری
- BLOB fields اجتناب کنید

Archival Strategy:
- Soft delete برای forms و users
- Archive strategy برای old responses
- Cleanup procedures برای logs
```

---

## 🔍 **Quality Assurance Checklist**

### **Pre-Implementation Validation:**
```yaml
- [ ] تمام جداول موجود بررسی شده
- [ ] Foreign key relationships تأیید شده
- [ ] Character encoding compatibility چک شده
- [ ] Migration rollback plan آماده شده
- [ ] Test database environment آماده
```

### **Post-Implementation Testing:**
```yaml
- [ ] تمام migrations بدون خطا اجرا شده
- [ ] Foreign keys درست کار می‌کنند
- [ ] Persian text input/output صحیح
- [ ] Performance benchmarks قابل قبول
- [ ] Rollback script تست شده
```

### **Documentation Quality:**
```yaml
- [ ] ERD جدید کامل و دقیق
- [ ] همه تغییرات مستند شده
- [ ] Persian comments در SQL موجود
- [ ] Security considerations ذکر شده
- [ ] Performance implications توضیح شده
```

---

## 🚫 **Red Lines - خطوط قرمز**

### **هرگز این کارها را نکنید:**
```yaml
❌ تغییر در جداول system_settings یا system_logs
❌ ایجاد API endpoint جدید (فعلاً نه!)
❌ تغییر در ساختار فایل‌های موجود
❌ اضافه کردن library یا dependency جدید
❌ تغییر در پیکربندی XAMPP یا MySQL
❌ ایجاد UI component (مربوط به مرحله بعد!)
❌ تغییر در authentication (مرحله آینده!)
```

### **تأیید اجباری قبل از اقدام:**
```yaml
✅ آیا migration scripts آماده است؟
✅ آیا rollback plan مطمئن است؟  
✅ آیا test database موجود است؟
✅ آیا backup از جداول موجود گرفته شده؟
✅ آیا performance impact بررسی شده؟
```

---

## 📊 **Success Criteria مرحله ۵.۱**

### **Technical Success:**
```yaml
Database:
- 4 جدول جدید بدون خطا ایجاد شده
- Foreign keys و indexes عملیاتی
- Persian character support تایید شده
- Migration rollback tested

Performance:
- Query response times در محدوده مجاز
- Database size increase < 50MB
- No impact بر عملکرد فعلی system
- Memory usage optimized

Documentation:
- Complete ERD جدید
- Migration procedures documented  
- Security considerations covered
- Persian technical documentation
```

### **Business Success:**
```yaml
Foundation:
- User management system آماده
- Form structure definition کامل
- Widget library foundation موجود
- Response collection قابلیت فراهم
- Clean migration path برای production
```

---

## 🎭 **Final Instructions - دستورات نهایی**

### **مرحله‌به‌مرحله اجرا:**
```yaml
Step 1: Database schema analysis (موجود)
Step 2: Design new tables (طراحی دقیق)
Step 3: Write migration scripts (با rollback)
Step 4: Create PHP model classes (pattern-based)
Step 5: Test everything (comprehensive)
Step 6: Document everything (Persian)
Step 7: Report results (detailed)

⚠️ هر مرحله باید تأیید شود قبل از ادامه
```

### **Communication Protocol:**
```yaml
Progress Updates:
- هر SQL script آماده شد → گزارش
- هر test تکمیل شد → نتیجه
- مشکل پیش آمد → فوری اطلاع
- مرحله تکمیل شد → خلاصه کامل

Format: مشخص، مختصر، با Persian explanations
```

---

## 🎊 **Ready to Execute? - آماده اجرا؟**

```yaml
✅ Mission Clear: Database Evolution برای Form Builder
✅ Boundaries Set: فقط database layer
✅ Quality Standards: سختگیرانه تعین شده
✅ Success Criteria: مشخص و قابل سنجش
✅ Red Lines: واضح و غیرقابل عبور

🚀 اجرای مرحله ۵.۱ آغاز می‌شود...

⚠️ یادآوری: هیچ کار اضافی انجام ندهید
⚠️ یادآوری: فقط database evolution
⚠️ یادآوری: مستندسازی دقیق الزامی
```

---

**📅 Created:** 2025-09-01  
**👤 Author:** DataSave Project Manager - مجتبی حسنی  
**🎯 Phase:** 5.1 Database Evolution - STRICT MODE  
**🔒 Status:** READY FOR EXECUTION

---

**منتظر تأیید شروع عملیات هستیم... ⏳**