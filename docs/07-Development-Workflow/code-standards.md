# استانداردهای کدنویسی - Code Standards

## 📊 Document Information
- **Created:** 2025-09-01
- **Last Updated:** 2025-09-01
- **Version:** 1.0
- **Maintainer:** DataSave Development Team
- **Related Files:** `analysis_options.yaml`, `.editorconfig`, `pubspec.yaml`

## 🎯 Overview
راهنمای جامع استانداردهای کدنویسی برای پروژه DataSave شامل قوانین Dart/Flutter، PHP، SQL، و بهترین شیوه‌های توسعه نرم‌افزار.

## 📋 Table of Contents
- [اصول کلی کدنویسی](#اصول-کلی-کدنویسی)
- [استانداردهای Dart/Flutter](#استانداردهای-dartflutter)
- [استانداردهای PHP](#استانداردهای-php)
- [استانداردهای SQL](#استانداردهای-sql)
- [نام‌گذاری و ساختار](#نامگذاری-و-ساختار)
- [مستندسازی کد](#مستندسازی-کد)
- [تست و Quality Assurance](#تست-و-quality-assurance)
- [Git Workflow](#git-workflow)
- [ابزارها و Linting](#ابزارها-و-linting)

---

## 🏗️ اصول کلی کدنویسی - General Principles

### کلیدی‌ترین اصول
```yaml
Clean Code Principles:
  - خوانایی اولویت دارد
  - DRY (Don't Repeat Yourself)
  - KISS (Keep It Simple, Stupid)  
  - SOLID Principles
  - Single Responsibility
  - Consistent Naming

Persian Development:
  - RTL Support در UI
  - Persian Comments برای توضیحات پیچیده
  - English کد و Variables
  - Bilingual Documentation
```

### کیفیت کد
```dart
// ❌ Bad - نام‌گذاری نامناسب
var d = DateTime.now();
if(u.n.isEmpty){return false;}

// ✅ Good - کد واضح و خواناaa
final currentDate = DateTime.now();
if (user.name.isEmpty) {
  return false;
}

/// فارسی: تابع بررسی اعتبار ایمیل کاربر
/// English: Validates user email format
bool validateUserEmail(String email) {
  return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
}
```

---

## 📱 استانداردهای Dart/Flutter - Dart/Flutter Standards

### Project Structure
```yaml
lib/
├── main.dart                    # Entry point
├── app/                        # App configuration
│   ├── app.dart
│   ├── routes.dart
│   └── themes.dart
├── core/                       # Core functionality
│   ├── constants/
│   ├── services/
│   ├── utils/
│   └── errors/
├── features/                   # Feature-based structure
│   └── forms/                  # مثال: فیچر فرم‌ساز
│       ├── data/              # Data layer
│       ├── domain/            # Business logic
│       └── presentation/      # UI layer
└── shared/                     # Shared components
    ├── widgets/
    ├── models/
    └── services/
```

### Naming Conventions
```dart
// Classes: PascalCase
class FormBuilderService {
  // Private variables: _camelCase
  final ApiService _apiService;
  
  // Public variables: camelCase
  final String formTitle;
  
  // Constants: SCREAMING_SNAKE_CASE
  static const int MAX_FORM_FIELDS = 50;
  
  // Methods: camelCase
  Future<List<FormField>> getFormFields() async {
    // Local variables: camelCase
    final List<FormField> formFields = [];
    return formFields;
  }
}

// Enums: PascalCase
enum FormFieldType {
  textField,    // camelCase values
  numericField,
  dropdownField,
  checkboxField,
}

// Extensions: PascalCase + Extension
extension StringExtensionPersian on String {
  bool get isPersian => RegExp(r'^[\u0600-\u06FF\s]+$').hasMatch(this);
}
```

### Widget Standards
```dart
/// Persian RTL Support Widget
class PersianTextField extends StatefulWidget {
  /// فارسی: متن placeholder
  final String placeholder;
  
  /// فارسی: جهت متن (راست به چپ)
  final TextDirection? textDirection;
  
  /// فارسی: کنترلر متن
  final TextEditingController controller;
  
  const PersianTextField({
    super.key,
    required this.placeholder,
    required this.controller,
    this.textDirection = TextDirection.rtl,
  });

  @override
  State<PersianTextField> createState() => _PersianTextFieldState();
}

class _PersianTextFieldState extends State<PersianTextField> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: widget.textDirection ?? TextDirection.rtl,
      child: TextField(
        controller: widget.controller,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          hintText: widget.placeholder,
          // Material Design 3 styling
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceVariant,
        ),
        style: TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 16,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
```

### State Management Pattern
```dart
// BLoC Pattern Implementation
abstract class FormEvent {}

class LoadFormFields extends FormEvent {}

class AddFormField extends FormEvent {
  final FormFieldData fieldData;
  AddFormField(this.fieldData);
}

// State definition
abstract class FormState {}

class FormLoading extends FormState {}

class FormLoaded extends FormState {
  final List<FormFieldData> fields;
  FormLoaded(this.fields);
}

class FormError extends FormState {
  final String message;
  FormError(this.message);
}

// BLoC implementation
class FormBloc extends Bloc<FormEvent, FormState> {
  final FormRepository _repository;
  
  FormBloc(this._repository) : super(FormLoading()) {
    on<LoadFormFields>(_onLoadFormFields);
    on<AddFormField>(_onAddFormField);
  }
  
  /// فارسی: بارگذاری فیلدهای فرم از دیتابیس
  Future<void> _onLoadFormFields(
    LoadFormFields event, 
    Emitter<FormState> emit
  ) async {
    try {
      emit(FormLoading());
      final fields = await _repository.getFormFields();
      emit(FormLoaded(fields));
    } catch (error) {
      emit(FormError('خطا در بارگذاری فیلدها: $error'));
    }
  }
  
  /// فارسی: افزودن فیلد جدید به فرم
  Future<void> _onAddFormField(
    AddFormField event,
    Emitter<FormState> emit
  ) async {
    if (state is FormLoaded) {
      final currentFields = (state as FormLoaded).fields;
      final updatedFields = [...currentFields, event.fieldData];
      emit(FormLoaded(updatedFields));
    }
  }
}
```

### Error Handling
```dart
// Custom Exception Classes
class DataSaveException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  
  const DataSaveException(
    this.message, {
    this.code,
    this.originalError,
  });
  
  @override
  String toString() => 'DataSaveException: $message';
}

class NetworkException extends DataSaveException {
  const NetworkException(String message) : super(message, code: 'NETWORK_ERROR');
}

class ValidationException extends DataSaveException {
  const ValidationException(String message) : super(message, code: 'VALIDATION_ERROR');
}

// Error Handler Service
class ErrorHandler {
  /// فارسی: مدیریت خطاها و نمایش پیام مناسب
  static String getLocalizedMessage(Exception error) {
    switch (error.runtimeType) {
      case NetworkException:
        return 'خطا در اتصال به شبکه. لطفاً اتصال اینترنت خود را بررسی کنید.';
      case ValidationException:
        return 'داده‌های ورودی نامعتبر است. لطفاً دوباره تلاش کنید.';
      case DataSaveException:
        return (error as DataSaveException).message;
      default:
        return 'خطای غیرمنتظره‌ای رخ داده است.';
    }
  }
  
  /// فارسی: گزارش خطا به سرویس لاگ
  static void reportError(Exception error, StackTrace? stackTrace) {
    // Log to console in debug mode
    if (kDebugMode) {
      debugPrint('ERROR: ${error.toString()}');
      if (stackTrace != null) {
        debugPrint('STACK TRACE: $stackTrace');
      }
    }
    
    // Send to logging service in production
    // LoggingService.logError(error, stackTrace);
  }
}
```

### Formatting & Linting
```yaml
# analysis_options.yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - build/**
    - lib/**.g.dart
    - lib/**.freezed.dart

linter:
  rules:
    # Style rules
    - prefer_const_constructors
    - prefer_const_literals_to_create_immutables
    - prefer_final_fields
    - prefer_final_locals
    - sort_child_properties_last
    
    # Documentation
    - public_member_api_docs
    - comment_references
    
    # Performance
    - avoid_unnecessary_containers
    - use_key_in_widget_constructors
    - prefer_const_constructors_in_immutables
    
    # Persian-specific
    - avoid_print  # Use proper logging instead
```

---

## 🐘 استانداردهای PHP - PHP Standards

### PSR Standards Compliance
```php
<?php
declare(strict_types=1);

namespace DataSave\Api\Services;

use DataSave\Core\Database\DatabaseConnection;
use DataSave\Core\Models\FormModel;
use DataSave\Core\Exceptions\ValidationException;

/**
 * فارسی: سرویس مدیریت فرم‌ها
 * English: Form management service
 * 
 * @package DataSave\Api\Services
 * @version 1.0
 * @since 2025-09-01
 */
class FormService
{
    private const MAX_FIELDS_PER_FORM = 50;
    private const PERSIAN_REGEX = '/^[\x{0600}-\x{06FF}\s]+$/u';
    
    private DatabaseConnection $db;
    private Logger $logger;
    
    /**
     * Constructor
     * 
     * @param DatabaseConnection $db Database connection instance
     * @param Logger $logger Logging service
     */
    public function __construct(DatabaseConnection $db, Logger $logger)
    {
        $this->db = $db;
        $this->logger = $logger;
    }
    
    /**
     * فارسی: ایجاد فرم جدید با پشتیبانی از متن فارسی
     * English: Create new form with Persian text support
     * 
     * @param array $formData Form configuration data
     * @return FormModel Created form instance
     * @throws ValidationException If form data is invalid
     */
    public function createForm(array $formData): FormModel
    {
        $this->validateFormData($formData);
        
        try {
            $formId = $this->db->insert('forms', [
                'title' => $formData['title'],
                'description' => $formData['description'] ?? null,
                'created_at' => date('Y-m-d H:i:s'),
                'is_active' => 1
            ]);
            
            $this->logger->info("فرم جدید ایجاد شد با ID: {$formId}");
            
            return new FormModel($formId, $formData);
            
        } catch (\Exception $e) {
            $this->logger->error("خطا در ایجاد فرم: " . $e->getMessage());
            throw new ValidationException('خطا در ایجاد فرم');
        }
    }
    
    /**
     * فارسی: اعتبارسنجی داده‌های فرم
     * English: Validate form data
     * 
     * @param array $formData Data to validate
     * @throws ValidationException If validation fails
     */
    private function validateFormData(array $formData): void
    {
        if (empty($formData['title'])) {
            throw new ValidationException('عنوان فرم الزامی است');
        }
        
        if (mb_strlen($formData['title']) > 100) {
            throw new ValidationException('عنوان فرم نباید بیشتر از ۱۰۰ کاراکتر باشد');
        }
        
        // Persian text validation
        if (isset($formData['description']) && 
            !preg_match(self::PERSIAN_REGEX, $formData['description'])) {
            $this->logger->warning('متن فارسی نامعتبر در توضیحات فرم');
        }
    }
    
    /**
     * فارسی: دریافت لیست فرم‌ها با پشتیبانی صفحه‌بندی
     * English: Get paginated forms list
     * 
     * @param int $page Page number (1-based)
     * @param int $limit Items per page
     * @return array Forms list with pagination info
     */
    public function getForms(int $page = 1, int $limit = 10): array
    {
        $offset = ($page - 1) * $limit;
        
        $query = "
            SELECT 
                id,
                title,
                description,
                created_at,
                is_active,
                (SELECT COUNT(*) FROM forms WHERE is_active = 1) as total_count
            FROM forms 
            WHERE is_active = 1 
            ORDER BY created_at DESC 
            LIMIT :limit OFFSET :offset
        ";
        
        $forms = $this->db->fetchAll($query, [
            'limit' => $limit,
            'offset' => $offset
        ]);
        
        return [
            'data' => $forms,
            'pagination' => [
                'current_page' => $page,
                'per_page' => $limit,
                'total' => $forms[0]['total_count'] ?? 0,
                'total_pages' => ceil(($forms[0]['total_count'] ?? 0) / $limit)
            ]
        ];
    }
}
```

### Error Handling در PHP
```php
<?php
declare(strict_types=1);

/**
 * فارسی: کلاس پاسخ API استاندارد
 * English: Standard API response class
 */
class ApiResponse
{
    private bool $success;
    private mixed $data;
    private ?string $message;
    private ?array $errors;
    private int $httpCode;
    
    public function __construct(
        bool $success = true,
        mixed $data = null,
        ?string $message = null,
        ?array $errors = null,
        int $httpCode = 200
    ) {
        $this->success = $success;
        $this->data = $data;
        $this->message = $message;
        $this->errors = $errors;
        $this->httpCode = $httpCode;
    }
    
    /**
     * فارسی: پاسخ موفق
     * English: Success response
     */
    public static function success(mixed $data = null, string $message = null): self
    {
        return new self(true, $data, $message);
    }
    
    /**
     * فارسی: پاسخ خطا
     * English: Error response
     */
    public static function error(string $message, array $errors = null, int $httpCode = 400): self
    {
        return new self(false, null, $message, $errors, $httpCode);
    }
    
    /**
     * فارسی: تبدیل به JSON و ارسال پاسخ
     * English: Convert to JSON and send response
     */
    public function send(): void
    {
        http_response_code($this->httpCode);
        
        header('Content-Type: application/json; charset=utf-8');
        header('Access-Control-Allow-Origin: http://localhost:8085');
        header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
        header('Access-Control-Allow-Headers: Content-Type, Authorization');
        
        echo json_encode([
            'success' => $this->success,
            'data' => $this->data,
            'message' => $this->message,
            'errors' => $this->errors,
            'timestamp' => date('Y-m-d H:i:s')
        ], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
    }
}

// استفاده در API endpoints
try {
    $formService = new FormService($db, $logger);
    $forms = $formService->getForms($page, $limit);
    
    ApiResponse::success($forms, 'لیست فرم‌ها با موفقیت دریافت شد')->send();
    
} catch (ValidationException $e) {
    ApiResponse::error($e->getMessage(), null, 400)->send();
} catch (\Exception $e) {
    $logger->error("خطای غیرمنتظره: " . $e->getMessage());
    ApiResponse::error('خطای سرور رخ داده است', null, 500)->send();
}
```

### Database Layer Standards
```php
<?php
declare(strict_types=1);

namespace DataSave\Core\Database;

/**
 * فارسی: کلاس پایه مدل‌ها
 * English: Base model class
 */
abstract class BaseModel
{
    protected DatabaseConnection $db;
    protected string $table;
    protected string $primaryKey = 'id';
    protected array $fillable = [];
    protected array $hidden = [];
    
    public function __construct(DatabaseConnection $db)
    {
        $this->db = $db;
    }
    
    /**
     * فارسی: جستجو بر اساس کلید اصلی
     * English: Find by primary key
     */
    public function find(int $id): ?array
    {
        $query = "SELECT * FROM {$this->table} WHERE {$this->primaryKey} = :id LIMIT 1";
        return $this->db->fetch($query, ['id' => $id]);
    }
    
    /**
     * فارسی: ایجاد رکورد جدید
     * English: Create new record
     */
    public function create(array $data): int
    {
        $filteredData = $this->filterFillable($data);
        return $this->db->insert($this->table, $filteredData);
    }
    
    /**
     * فارسی: بروزرسانی رکورد
     * English: Update record
     */
    public function update(int $id, array $data): bool
    {
        $filteredData = $this->filterFillable($data);
        return $this->db->update($this->table, $filteredData, "{$this->primaryKey} = :id", ['id' => $id]);
    }
    
    /**
     * فارسی: حذف رکورد (soft delete)
     * English: Delete record (soft delete)
     */
    public function delete(int $id): bool
    {
        return $this->update($id, ['is_active' => 0, 'deleted_at' => date('Y-m-d H:i:s')]);
    }
    
    /**
     * فارسی: فیلتر کردن فیلدهای قابل پر کردن
     * English: Filter fillable fields
     */
    private function filterFillable(array $data): array
    {
        return array_intersect_key($data, array_flip($this->fillable));
    }
}

/**
 * فارسی: مدل فرم‌ها
 * English: Forms model
 */
class FormModel extends BaseModel
{
    protected string $table = 'forms';
    protected array $fillable = ['title', 'description', 'settings', 'is_active'];
    protected array $hidden = ['deleted_at'];
    
    /**
     * فارسی: دریافت فرم‌های فعال
     * English: Get active forms
     */
    public function getActiveForms(int $limit = 10, int $offset = 0): array
    {
        $query = "
            SELECT * FROM {$this->table} 
            WHERE is_active = 1 AND deleted_at IS NULL
            ORDER BY created_at DESC 
            LIMIT :limit OFFSET :offset
        ";
        
        return $this->db->fetchAll($query, [
            'limit' => $limit,
            'offset' => $offset
        ]);
    }
}
```

---

## 🗄️ استانداردهای SQL - SQL Standards

### Database Schema Conventions
```sql
-- نام‌گذاری جداول: snake_case و جمع
CREATE TABLE form_fields (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    form_id BIGINT UNSIGNED NOT NULL,
    field_name VARCHAR(100) NOT NULL COMMENT 'نام فیلد انگلیسی',
    field_label VARCHAR(255) NOT NULL COMMENT 'برچسب فیلد فارسی',
    field_type ENUM('text', 'number', 'email', 'select', 'checkbox') NOT NULL,
    is_required TINYINT(1) DEFAULT 0 COMMENT 'آیا فیلد اجباری است',
    display_order INT UNSIGNED DEFAULT 0 COMMENT 'ترتیب نمایش',
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL DEFAULT NULL,
    
    -- Persian text support
    CHARSET utf8mb4 COLLATE utf8mb4_persian_ci,
    
    -- Indexes
    INDEX idx_form_id (form_id),
    INDEX idx_field_type (field_type),
    INDEX idx_display_order (display_order),
    
    -- Foreign keys
    FOREIGN KEY (form_id) REFERENCES forms(id) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='جدول فیلدهای فرم';

-- Persian text fields با charset صحیح
ALTER TABLE forms 
MODIFY COLUMN title VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_persian_ci,
MODIFY COLUMN description TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_persian_ci;
```

### Query Standards
```sql
-- ✅ Good: Readable and optimized query
SELECT 
    f.id AS form_id,
    f.title AS form_title,
    f.created_at,
    COUNT(ff.id) AS field_count,
    COUNT(fs.id) AS submission_count
FROM forms f
    LEFT JOIN form_fields ff ON f.id = ff.form_id 
        AND ff.deleted_at IS NULL
    LEFT JOIN form_submissions fs ON f.id = fs.form_id
        AND fs.created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
WHERE f.is_active = 1
    AND f.deleted_at IS NULL
GROUP BY f.id, f.title, f.created_at
ORDER BY f.created_at DESC
LIMIT 20;

-- ❌ Bad: Complex unreadable query
SELECT f.*,COUNT(ff.id),COUNT(fs.id) FROM forms f LEFT JOIN form_fields ff ON f.id=ff.form_id LEFT JOIN form_submissions fs ON f.id=fs.form_id WHERE f.is_active=1 GROUP BY f.id;

-- Persian search optimization
SELECT * FROM forms 
WHERE MATCH(title, description) AGAINST('+فرم +تماس' IN BOOLEAN MODE)
    OR title LIKE '%فرم%' 
    OR description LIKE '%تماس%'
ORDER BY 
    CASE 
        WHEN title LIKE '%فرم تماس%' THEN 1
        WHEN title LIKE '%فرم%' THEN 2
        ELSE 3
    END,
    created_at DESC;
```

### Migration Scripts
```sql
-- Migration: Add Persian RTL support
-- File: migrations/002_add_persian_rtl_support.sql

-- Add RTL direction field to forms
ALTER TABLE forms 
ADD COLUMN text_direction ENUM('ltr', 'rtl') DEFAULT 'rtl' COMMENT 'جهت متن فرم';

-- Add Persian validation rules
ALTER TABLE form_fields 
ADD COLUMN validation_rules JSON COMMENT 'قوانین اعتبارسنجی فیلد',
ADD COLUMN placeholder_text VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_persian_ci COMMENT 'متن placeholder فارسی';

-- Update existing records
UPDATE forms 
SET text_direction = 'rtl' 
WHERE title REGEXP '^[\x{0600}-\x{06FF}]';

-- Add indexes for Persian search
ALTER TABLE forms 
ADD FULLTEXT INDEX ft_persian_search (title, description);

-- Update character set for existing text columns
ALTER TABLE form_submissions 
MODIFY COLUMN submission_data JSON COMMENT 'داده‌های ثبت شده فرم',
MODIFY COLUMN user_agent TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_persian_ci;
```

---

## 🏷️ نام‌گذاری و ساختار - Naming & Structure

### File Organization
```yaml
# Project Structure Convention
datasave/
├── lib/                        # Flutter source code
│   ├── main.dart              # Entry point
│   ├── app/                   # App configuration
│   ├── core/                  # Core utilities
│   ├── features/              # Feature modules
│   │   ├── forms/            # Forms feature
│   │   │   ├── data/         # Data layer
│   │   │   ├── domain/       # Business logic
│   │   │   └── presentation/ # UI layer
│   │   └── settings/         # Settings feature
│   └── shared/                # Shared components
│
├── backend/                   # PHP backend
│   ├── api/                  # API endpoints
│   │   ├── forms/           # Forms API
│   │   ├── settings/        # Settings API
│   │   └── system/          # System API
│   ├── classes/             # PHP classes
│   ├── config/              # Configuration
│   └── sql/                 # SQL scripts
│
├── docs/                     # Documentation
│   ├── 01-Architecture/     # Architecture docs
│   ├── 02-Backend-APIs/     # Backend documentation
│   ├── 03-Database-Schema/  # Database docs
│   ├── 04-Flutter-Frontend/ # Frontend docs
│   └── 99-Quick-Reference/  # Quick reference
│
└── test/                    # Test files
    ├── unit/               # Unit tests
    ├── integration/        # Integration tests
    └── fixtures/          # Test data
```

### Variable Naming
```dart
// ✅ Good: Clear and descriptive
final String userEmailAddress = 'user@example.com';
final List<FormFieldData> formFieldsList = [];
final bool isFormValidationSuccessful = true;
final int maxAllowedFormFields = 50;

// Constants
class AppConstants {
  static const String appName = 'DataSave';
  static const int apiTimeoutSeconds = 30;
  static const String persianDateFormat = 'yyyy/MM/dd';
  
  // Persian-specific constants
  static const String defaultDirection = 'rtl';
  static const String persianFontFamily = 'Vazirmatn';
  static const RegExp persianTextPattern = RegExp(r'^[\u0600-\u06FF\s]+$');
}

// ❌ Bad: Unclear abbreviations
final String em = 'user@example.com';
final List<dynamic> lst = [];
final bool ok = true;
final int max = 50;
```

### Function Naming
```php
// ✅ Good: Action-oriented names
public function validateUserInput(array $inputData): bool
public function generateFormHtml(FormModel $form): string
public function sendEmailNotification(string $recipient, string $message): bool

// Boolean functions start with is/has/can
public function isFormActive(int $formId): bool
public function hasPermission(User $user, string $action): bool
public function canEditForm(int $userId, int $formId): bool

// Persian documentation with English code
/**
 * فارسی: بررسی صحت داده‌های ورودی کاربر
 * English: Validates user input data
 */
public function validatePersianText(string $text): bool
{
    return preg_match('/^[\x{0600}-\x{06FF}\s\d\p{P}]+$/u', $text);
}

// ❌ Bad: Vague names
public function process($data)
public function handle($input)
public function do($stuff)
```

---

## 📖 مستندسازی کد - Code Documentation

### PHPDoc Standards
```php
<?php
/**
 * فارسی: سرویس مدیریت کاربران با پشتیبانی فارسی
 * English: User management service with Persian support
 *
 * این کلاس مسئول مدیریت عملیات کاربران شامل ثبت‌نام، ورود، و احراز هویت است.
 * This class handles user operations including registration, login, and authentication.
 *
 * @package DataSave\Services
 * @version 1.0.0
 * @since 2025-09-01
 * @author DataSave Team
 * 
 * @example
 * ```php
 * $userService = new UserService($database, $logger);
 * $user = $userService->createUser($userData);
 * ```
 */
class UserService
{
    /**
     * فارسی: ایجاد کاربر جدید
     * English: Create new user account
     *
     * @param array $userData {
     *     @type string $name نام کاربر (اجباری)
     *     @type string $email ایمیل کاربر (اجباری)
     *     @type string $password رمز عبور (اجباری)
     *     @type string $phone شماره تلفن (اختیاری)
     * }
     * 
     * @return User|null نمونه کاربر ایجاد شده یا null در صورت شکست
     * 
     * @throws ValidationException اگر داده‌های ورودی نامعتبر باشد
     * @throws DatabaseException اگر خطای دیتابیس رخ دهد
     * 
     * @since 1.0.0
     * 
     * @example
     * ```php
     * try {
     *     $userData = [
     *         'name' => 'علی احمدی',
     *         'email' => 'ali@example.com',
     *         'password' => 'secure_password'
     *     ];
     *     $user = $userService->createUser($userData);
     *     echo "کاربر با ID {$user->getId()} ایجاد شد";
     * } catch (ValidationException $e) {
     *     echo "خطای اعتبارسنجی: " . $e->getMessage();
     * }
     * ```
     */
    public function createUser(array $userData): ?User
    {
        // Implementation here
    }
}
```

### Dart Documentation
```dart
/// فارسی: سرویس مدیریت فرم‌ها
/// English: Form management service
///
/// این کلاس عملیات CRUD فرم‌ها را مدیریت می‌کند و شامل:
/// This class manages form CRUD operations including:
/// - ایجاد فرم جدید (Creating new forms)
/// - ویرایش فرم موجود (Editing existing forms)  
/// - حذف فرم (Deleting forms)
/// - دریافت لیست فرم‌ها (Fetching forms list)
///
/// ## Usage Example:
/// ```dart
/// final formService = FormService(apiService);
/// final forms = await formService.getAllForms();
/// ```
///
/// ## Persian RTL Support:
/// تمام متون فارسی به صورت راست به چپ پشتیبانی می‌شوند
/// All Persian texts are supported right-to-left
class FormService {
  final ApiService _apiService;
  
  /// فارسی: سرویس API برای ارتباط با سرور
  /// English: API service for server communication
  FormService(this._apiService);
  
  /// فارسی: دریافت تمام فرم‌های فعال
  /// English: Get all active forms
  ///
  /// این متد لیست تمام فرم‌های فعال را از سرور دریافت می‌کند
  /// This method fetches all active forms from the server
  ///
  /// Returns:
  ///   Future<List<FormModel>> لیست فرم‌ها یا لیست خالی در صورت عدم وجود
  ///   Future<List<FormModel>> List of forms or empty list if none found
  ///
  /// Throws:
  ///   NetworkException اگر خطای شبکه رخ دهد
  ///   NetworkException if network error occurs
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   final forms = await formService.getAllForms();
  ///   if (forms.isNotEmpty) {
  ///     print('تعداد فرم‌ها: ${forms.length}');
  ///   }
  /// } catch (e) {
  ///   print('خطا در دریافت فرم‌ها: $e');
  /// }
  /// ```
  Future<List<FormModel>> getAllForms() async {
    try {
      final response = await _apiService.get('/api/forms/get.php');
      
      if (response.success) {
        return response.data
            .map<FormModel>((json) => FormModel.fromJson(json))
            .toList();
      }
      
      throw NetworkException('خطا در دریافت فرم‌ها');
    } catch (e) {
      throw NetworkException('اتصال به سرور برقرار نشد');
    }
  }
}
```

---

## 🧪 تست و Quality Assurance

### Unit Testing Standards
```dart
// Test file: test/services/form_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:datasave/services/form_service.dart';
import 'package:datasave/services/api_service.dart';
import 'package:datasave/models/form_model.dart';

// Mock classes
class MockApiService extends Mock implements ApiService {}

void main() {
  group('FormService Tests', () {
    late FormService formService;
    late MockApiService mockApiService;
    
    setUp(() {
      mockApiService = MockApiService();
      formService = FormService(mockApiService);
    });
    
    group('getAllForms', () {
      test('فارسی: باید لیست فرم‌ها را بازگرداند - should return list of forms', () async {
        // Arrange
        final mockResponse = ApiResponse(
          success: true,
          data: [
            {'id': 1, 'title': 'فرم تماس', 'description': 'فرم تماس با ما'},
            {'id': 2, 'title': 'فرم ثبت‌نام', 'description': 'فرم ثبت‌نام کاربران'},
          ],
        );
        
        when(mockApiService.get('/api/forms/get.php'))
            .thenAnswer((_) async => mockResponse);
        
        // Act
        final result = await formService.getAllForms();
        
        // Assert
        expect(result, isA<List<FormModel>>());
        expect(result.length, equals(2));
        expect(result[0].title, equals('فرم تماس'));
        expect(result[1].title, equals('فرم ثبت‌نام'));
        
        verify(mockApiService.get('/api/forms/get.php')).called(1);
      });
      
      test('فارسی: باید خطای شبکه پرتاب کند - should throw NetworkException on API failure', () async {
        // Arrange
        when(mockApiService.get('/api/forms/get.php'))
            .thenThrow(Exception('Connection failed'));
        
        // Act & Assert
        expect(
          () => formService.getAllForms(),
          throwsA(isA<NetworkException>()),
        );
      });
    });
  });
}
```

### Integration Testing
```dart
// test/integration/form_workflow_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:datasave/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Form Workflow Integration Tests', () {
    testWidgets('فارسی: کامل کردن فرایند ایجاد فرم - Complete form creation workflow', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();
      
      // Navigate to form creation
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      
      // Fill form title (Persian)
      await tester.enterText(
        find.byKey(const Key('form_title_field')), 
        'فرم تست تکاملی'
      );
      
      // Fill form description (Persian)
      await tester.enterText(
        find.byKey(const Key('form_description_field')), 
        'این یک فرم تست برای بررسی عملکرد سیستم است'
      );
      
      // Add a text field
      await tester.tap(find.byKey(const Key('add_field_button')));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('فیلد متنی'));
      await tester.pumpAndSettle();
      
      // Configure field
      await tester.enterText(
        find.byKey(const Key('field_label')), 
        'نام کامل'
      );
      
      await tester.tap(find.byKey(const Key('field_required_checkbox')));
      await tester.pumpAndSettle();
      
      // Save form
      await tester.tap(find.byKey(const Key('save_form_button')));
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Verify form was created
      expect(find.text('فرم با موفقیت ایجاد شد'), findsOneWidget);
      expect(find.text('فرم تست تکاملی'), findsOneWidget);
    });
  });
}
```

---

## 🔄 Git Workflow Standards

### Commit Message Format
```bash
# فرمت commit message
<type>(<scope>): <description in English>

<body in Persian and English>

<footer>

# Types:
feat:     ویژگی جدید (new feature)
fix:      رفع باگ (bug fix) 
docs:     تغییر مستندات (documentation)
style:    تغییرات فرمت کد (formatting)
refactor: بازنویسی کد (code refactoring)
test:     اضافه کردن تست (adding tests)
chore:    کارهای نگهداری (maintenance)

# Examples:
feat(forms): add Persian RTL support for form fields

فارسی: اضافه کردن پشتیبانی راست به چپ برای فیلدهای فرم
- اضافه کردن TextDirection.rtl
- تنظیم فونت Vazirmatn
- پشتیبانی از کیبورد فارسی

English: Add right-to-left support for form fields
- Added TextDirection.rtl support
- Set Vazirmatn font family
- Persian keyboard support

Closes #123

fix(api): resolve Persian text encoding issue

فارسی: حل مشکل کدگذاری متن فارسی در API
- تنظیم UTF-8 charset در headers
- اصلاح mysql connection encoding
- تست با متن‌های فارسی طولانی

English: Fix Persian text encoding in API responses
- Set UTF-8 charset in response headers
- Fix mysql connection encoding
- Test with long Persian texts

Fixes #456
```

### Branch Naming
```bash
# Branch naming convention:
<type>/<ticket-number>-<short-description>

# Examples:
feature/DS-123-persian-form-validation
bugfix/DS-456-api-encoding-issue
hotfix/DS-789-critical-security-patch
release/v1.2.0
docs/DS-234-api-documentation

# Persian branches (if needed):
feature/DS-345-فارسی-form-builder
bugfix/DS-567-رفع-مشکل-rtl
```

---

## 🛠️ ابزارها و Linting - Tools & Linting

### Pre-commit Hooks
```bash
#!/bin/sh
# .git/hooks/pre-commit

echo "🧪 اجرای بررسی‌های پیش از commit..."

# Flutter analysis
echo "📱 بررسی کد Dart/Flutter..."
flutter analyze
if [ $? -ne 0 ]; then
    echo "❌ خطا در تحلیل کد Flutter"
    exit 1
fi

# Flutter tests
echo "🧪 اجرای تست‌های Flutter..."
flutter test
if [ $? -ne 0 ]; then
    echo "❌ شکست در تست‌های Flutter"
    exit 1
fi

# PHP CodeSniffer
echo "🐘 بررسی کد PHP..."
./vendor/bin/phpcs --standard=PSR-12 backend/
if [ $? -ne 0 ]; then
    echo "❌ خطا در استاندارد کدنویسی PHP"
    exit 1
fi

# PHP Tests
echo "🧪 اجرای تست‌های PHP..."
./vendor/bin/phpunit
if [ $? -ne 0 ]; then
    echo "❌ شکست در تست‌های PHP"
    exit 1
fi

echo "✅ همه بررسی‌ها موفق!"
```

### VS Code Settings for Quality
```json
{
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true,
    "source.organizeImports": true
  },
  
  // Dart/Flutter
  "dart.lineLength": 100,
  "dart.insertArgumentPlaceholders": false,
  "dart.previewLsp": true,
  
  // PHP
  "php.validate.executablePath": "/usr/bin/php",
  "phpcs.executablePath": "./vendor/bin/phpcs",
  "phpcbf.executablePath": "./vendor/bin/phpcbf",
  
  // Persian support
  "editor.unicodeHighlight.ambiguousCharacters": false,
  
  // File associations
  "files.associations": {
    "*.md": "markdown",
    "*.php": "php"
  }
}
```

---

## 📊 Metrics & Quality Gates

### Code Quality Metrics
```yaml
Quality Gates:
  Code Coverage:
    Flutter: >= 80%
    PHP: >= 75%
    
  Complexity:
    Max Cyclomatic Complexity: 10
    Max Function Length: 50 lines
    Max Class Length: 500 lines
    
  Documentation:
    Public API Documentation: 100%
    Code Comments: >= 20%
    
  Performance:
    API Response Time: < 200ms
    App Launch Time: < 3s
    Memory Usage: < 100MB
```

### Automated Quality Checks
```yaml
# GitHub Actions workflow
name: Quality Assurance

on: [push, pull_request]

jobs:
  flutter-quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test --coverage
      - run: dart run coverage:coverage_check --coverage-threshold=80
      
  php-quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: shivammathur/setup-php@v2
        with:
          php-version: '8.1'
      - run: composer install
      - run: ./vendor/bin/phpcs --standard=PSR-12 backend/
      - run: ./vendor/bin/phpunit --coverage-text --coverage-clover=coverage.xml
```

---

## 🔄 Related Documentation
- [Development Environment](development-environment.md)
- [Testing Strategy](testing-strategy.md)
- [Project Structure](../01-Architecture/project-structure.md)
- [API Guidelines](../02-Backend-APIs/api-endpoints-reference.md)
- [Flutter Architecture](../04-Flutter-Frontend/flutter-architecture.md)

---
*Last updated: 2025-09-01*  
*File: docs/07-Development-Workflow/code-standards.md*