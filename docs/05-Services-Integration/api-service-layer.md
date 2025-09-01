# لایه سرویس API - API Service Layer

## 📊 Document Information
- **Created:** 2025-09-01
- **Last Updated:** 2025-09-01
- **Version:** 1.0
- **Maintainer:** DataSave Development Team
- **Related Files:** `lib/core/services/`, `lib/core/network/`, `backend/api/`

## 🎯 Overview
معماری کامل لایه سرویس API در Flutter برای ارتباط با backend PHP، شامل مدیریت HTTP requests، error handling، caching، و پشتیبانی از متن فارسی.

## 📋 Table of Contents
- [معماری لایه API](#معماری-لایه-api)
- [HTTP Client Configuration](#http-client-configuration)
- [API Service Classes](#api-service-classes)
- [Request/Response Models](#requestresponse-models)
- [Error Handling](#error-handling)
- [Caching Strategy](#caching-strategy)
- [Authentication](#authentication)
- [Persian Text Support](#persian-text-support)
- [Testing API Services](#testing-api-services)

---

## 🏗️ معماری لایه API - API Architecture

### Layer Structure
```yaml
lib/core/
├── network/
│   ├── api_client.dart          # HTTP client base
│   ├── api_endpoints.dart       # API endpoints constants
│   ├── api_response.dart        # Response wrapper
│   ├── network_info.dart        # Network connectivity
│   └── interceptors/           # HTTP interceptors
│       ├── auth_interceptor.dart
│       ├── logging_interceptor.dart
│       └── persian_interceptor.dart
├── services/
│   ├── api_service.dart         # Base API service
│   ├── forms_api_service.dart   # Forms API
│   ├── settings_api_service.dart # Settings API
│   └── system_api_service.dart  # System API
└── models/
    ├── api_models.dart         # API request/response models
    ├── error_models.dart       # Error models
    └── persian_models.dart     # Persian-specific models
```

### Service Dependencies
```dart
// Dependency injection setup
class ServiceLocator {
  static final GetIt _getIt = GetIt.instance;
  
  static void setup() {
    // Network layer
    _getIt.registerLazySingleton<Dio>(() => _createDioClient());
    _getIt.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
    
    // API services
    _getIt.registerLazySingleton<ApiService>(
      () => ApiService(_getIt<Dio>(), _getIt<NetworkInfo>())
    );
    
    _getIt.registerLazySingleton<FormsApiService>(
      () => FormsApiService(_getIt<ApiService>())
    );
    
    _getIt.registerLazySingleton<SettingsApiService>(
      () => SettingsApiService(_getIt<ApiService>())
    );
  }
  
  static T get<T extends Object>() => _getIt<T>();
  
  static Dio _createDioClient() {
    final dio = Dio(BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json',
        'Accept-Charset': 'utf-8',
      },
    ));
    
    // Add interceptors
    dio.interceptors.addAll([
      AuthInterceptor(),
      PersianInterceptor(),
      LoggingInterceptor(),
    ]);
    
    return dio;
  }
}
```

---

## 🌐 HTTP Client Configuration

### Base API Client
```dart
// lib/core/network/api_client.dart

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

/// فارسی: کلاینت پایه برای ارتباط با API
/// English: Base client for API communication
@singleton
class ApiClient {
  final Dio _dio;
  final NetworkInfo _networkInfo;
  
  ApiClient(this._dio, this._networkInfo);
  
  /// فارسی: درخواست GET با پشتیبانی فارسی
  /// English: GET request with Persian support
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      await _ensureConnectivity();
      
      final response = await _dio.get<Map<String, dynamic>>(
        endpoint,
        queryParameters: queryParameters,
        options: options ?? _defaultOptions(),
      );
      
      return ApiResponse.fromResponse<T>(response);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  /// فارسی: درخواست POST با پشتیبانی فارسی
  /// English: POST request with Persian support
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      await _ensureConnectivity();
      
      final response = await _dio.post<Map<String, dynamic>>(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options ?? _defaultOptions(),
      );
      
      return ApiResponse.fromResponse<T>(response);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  /// فارسی: درخواست PUT
  /// English: PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    dynamic data,
    Options? options,
  }) async {
    try {
      await _ensureConnectivity();
      
      final response = await _dio.put<Map<String, dynamic>>(
        endpoint,
        data: data,
        options: options ?? _defaultOptions(),
      );
      
      return ApiResponse.fromResponse<T>(response);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  /// فارسی: درخواست DELETE
  /// English: DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Options? options,
  }) async {
    try {
      await _ensureConnectivity();
      
      final response = await _dio.delete<Map<String, dynamic>>(
        endpoint,
        options: options ?? _defaultOptions(),
      );
      
      return ApiResponse.fromResponse<T>(response);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  /// فارسی: بررسی اتصال اینترنت
  /// English: Check internet connectivity
  Future<void> _ensureConnectivity() async {
    if (!await _networkInfo.isConnected) {
      throw NetworkException('اتصال اینترنت برقرار نیست');
    }
  }
  
  /// فارسی: تنظیمات پیش‌فرض درخواست
  /// English: Default request options
  Options _defaultOptions() {
    return Options(
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json',
        'Accept-Charset': 'utf-8',
      },
      responseType: ResponseType.json,
    );
  }
  
  /// فارسی: مدیریت خطاها
  /// English: Handle errors
  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return NetworkException('درخواست منقضی شد');
          
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode ?? 0;
          final message = _getErrorMessage(error.response?.data);
          return ApiException(message, statusCode: statusCode);
          
        case DioExceptionType.cancel:
          return NetworkException('درخواست لغو شد');
          
        case DioExceptionType.unknown:
        default:
          return NetworkException('خطا در اتصال به سرور');
      }
    }
    
    return UnknownException('خطای نامشخص: ${error.toString()}');
  }
  
  /// فارسی: استخراج پیام خطا از پاسخ
  /// English: Extract error message from response
  String _getErrorMessage(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      return responseData['message'] ?? 'خطای سرور';
    }
    return 'خطای نامشخص';
  }
}
```

### API Endpoints Constants
```dart
// lib/core/network/api_endpoints.dart

/// فارسی: نقاط انتهایی API
/// English: API endpoints
class ApiEndpoints {
  // Base URL
  static const String baseUrl = 'http://localhost/datasave/backend';
  
  // Forms endpoints
  static const String forms = '/api/forms';
  static const String getAllForms = '$forms/get.php';
  static const String createForm = '$forms/create.php';
  static const String updateForm = '$forms/update.php';
  static const String deleteForm = '$forms/delete.php';
  static const String getFormById = '$forms/get_by_id.php';
  
  // Settings endpoints
  static const String settings = '/api/settings';
  static const String getAllSettings = '$settings/get.php';
  static const String updateSetting = '$settings/update.php';
  static const String getSetting = '$settings/get_by_key.php';
  
  // System endpoints
  static const String system = '/api/system';
  static const String getSystemInfo = '$system/info.php';
  static const String healthCheck = '$system/health.php';
  
  // Authentication endpoints (future implementation)
  static const String auth = '/api/auth';
  static const String login = '$auth/login.php';
  static const String register = '$auth/register.php';
  static const String logout = '$auth/logout.php';
  static const String refreshToken = '$auth/refresh.php';
  
  /// فارسی: ساخت URL کامل
  /// English: Build full URL
  static String buildUrl(String endpoint) {
    return baseUrl + endpoint;
  }
}
```

---

## 🔧 API Service Classes

### Base API Service
```dart
// lib/core/services/api_service.dart

/// فارسی: سرویس پایه API
/// English: Base API service
abstract class BaseApiService {
  final ApiClient _apiClient;
  
  BaseApiService(this._apiClient);
  
  /// فارسی: دریافت کلاینت API
  /// English: Get API client
  ApiClient get client => _apiClient;
  
  /// فارسی: مدیریت خطاهای مشترک
  /// English: Handle common errors
  T handleResponse<T>(ApiResponse<T> response) {
    if (response.success) {
      return response.data!;
    } else {
      throw ApiException(response.message ?? 'خطای ناشناخته');
    }
  }
}

/// فارسی: سرویس اصلی API
/// English: Main API service
@singleton
class ApiService extends BaseApiService {
  ApiService(super.apiClient);
  
  /// فارسی: درخواست عمومی GET
  /// English: Generic GET request
  Future<T> get<T>(String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await client.get<T>(
      endpoint,
      queryParameters: queryParameters,
    );
    return handleResponse(response);
  }
  
  /// فارسی: درخواست عمومی POST
  /// English: Generic POST request
  Future<T> post<T>(String endpoint, {
    dynamic data,
  }) async {
    final response = await client.post<T>(
      endpoint,
      data: data,
    );
    return handleResponse(response);
  }
  
  /// فارسی: درخواست عمومی PUT
  /// English: Generic PUT request
  Future<T> put<T>(String endpoint, {
    dynamic data,
  }) async {
    final response = await client.put<T>(
      endpoint,
      data: data,
    );
    return handleResponse(response);
  }
  
  /// فارسی: درخواست عمومی DELETE
  /// English: Generic DELETE request
  Future<T> delete<T>(String endpoint) async {
    final response = await client.delete<T>(endpoint);
    return handleResponse(response);
  }
}
```

### Forms API Service
```dart
// lib/core/services/forms_api_service.dart

/// فارسی: سرویس API فرم‌ها
/// English: Forms API service
@singleton
class FormsApiService extends BaseApiService {
  FormsApiService(ApiClient apiClient) : super(apiClient);
  
  /// فارسی: دریافت تمام فرم‌ها
  /// English: Get all forms
  Future<List<FormModel>> getAllForms() async {
    try {
      final response = await client.get<List<dynamic>>(
        ApiEndpoints.getAllForms,
      );
      
      if (response.success && response.data != null) {
        return response.data!
            .map((json) => FormModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      
      return [];
    } catch (e) {
      throw ApiException('خطا در دریافت لیست فرم‌ها: ${e.toString()}');
    }
  }
  
  /// فارسی: دریافت فرم بر اساس ID
  /// English: Get form by ID
  Future<FormModel?> getFormById(int formId) async {
    try {
      final response = await client.get<Map<String, dynamic>>(
        ApiEndpoints.getFormById,
        queryParameters: {'id': formId},
      );
      
      if (response.success && response.data != null) {
        return FormModel.fromJson(response.data!);
      }
      
      return null;
    } catch (e) {
      throw ApiException('خطا در دریافت فرم: ${e.toString()}');
    }
  }
  
  /// فارسی: ایجاد فرم جدید
  /// English: Create new form
  Future<FormModel> createForm(CreateFormRequest request) async {
    try {
      final response = await client.post<Map<String, dynamic>>(
        ApiEndpoints.createForm,
        data: request.toJson(),
      );
      
      if (response.success && response.data != null) {
        return FormModel.fromJson(response.data!);
      }
      
      throw ApiException(response.message ?? 'خطا در ایجاد فرم');
    } catch (e) {
      throw ApiException('خطا در ایجاد فرم: ${e.toString()}');
    }
  }
  
  /// فارسی: بروزرسانی فرم
  /// English: Update form
  Future<FormModel> updateForm(int formId, UpdateFormRequest request) async {
    try {
      final response = await client.put<Map<String, dynamic>>(
        ApiEndpoints.updateForm,
        data: {
          'id': formId,
          ...request.toJson(),
        },
      );
      
      if (response.success && response.data != null) {
        return FormModel.fromJson(response.data!);
      }
      
      throw ApiException(response.message ?? 'خطا در بروزرسانی فرم');
    } catch (e) {
      throw ApiException('خطا در بروزرسانی فرم: ${e.toString()}');
    }
  }
  
  /// فارسی: حذف فرم
  /// English: Delete form
  Future<bool> deleteForm(int formId) async {
    try {
      final response = await client.delete<Map<String, dynamic>>(
        '${ApiEndpoints.deleteForm}?id=$formId',
      );
      
      return response.success;
    } catch (e) {
      throw ApiException('خطا در حذف فرم: ${e.toString()}');
    }
  }
  
  /// فارسی: جستجوی فرم‌ها
  /// English: Search forms
  Future<List<FormModel>> searchForms(String query) async {
    try {
      final response = await client.get<List<dynamic>>(
        ApiEndpoints.getAllForms,
        queryParameters: {'search': query},
      );
      
      if (response.success && response.data != null) {
        return response.data!
            .map((json) => FormModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      
      return [];
    } catch (e) {
      throw ApiException('خطا در جستجوی فرم‌ها: ${e.toString()}');
    }
  }
}
```

### Settings API Service
```dart
// lib/core/services/settings_api_service.dart

/// فارسی: سرویس API تنظیمات
/// English: Settings API service
@singleton
class SettingsApiService extends BaseApiService {
  SettingsApiService(ApiClient apiClient) : super(apiClient);
  
  /// فارسی: دریافت تمام تنظیمات
  /// English: Get all settings
  Future<List<SettingModel>> getAllSettings() async {
    try {
      final response = await client.get<List<dynamic>>(
        ApiEndpoints.getAllSettings,
      );
      
      if (response.success && response.data != null) {
        return response.data!
            .map((json) => SettingModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      
      return [];
    } catch (e) {
      throw ApiException('خطا در دریافت تنظیمات: ${e.toString()}');
    }
  }
  
  /// فارسی: دریافت تنظیم بر اساس کلید
  /// English: Get setting by key
  Future<SettingModel?> getSettingByKey(String key) async {
    try {
      final response = await client.get<Map<String, dynamic>>(
        ApiEndpoints.getSetting,
        queryParameters: {'key': key},
      );
      
      if (response.success && response.data != null) {
        return SettingModel.fromJson(response.data!);
      }
      
      return null;
    } catch (e) {
      throw ApiException('خطا در دریافت تنظیم: ${e.toString()}');
    }
  }
  
  /// فارسی: بروزرسانی تنظیم
  /// English: Update setting
  Future<bool> updateSetting(String key, String value) async {
    try {
      final response = await client.put<Map<String, dynamic>>(
        ApiEndpoints.updateSetting,
        data: {
          'key': key,
          'value': value,
        },
      );
      
      return response.success;
    } catch (e) {
      throw ApiException('خطا در بروزرسانی تنظیم: ${e.toString()}');
    }
  }
  
  /// فارسی: بروزرسانی چندگانه تنظیمات
  /// English: Batch update settings
  Future<bool> updateMultipleSettings(Map<String, String> settings) async {
    try {
      final response = await client.post<Map<String, dynamic>>(
        '${ApiEndpoints.settings}/batch_update.php',
        data: {'settings': settings},
      );
      
      return response.success;
    } catch (e) {
      throw ApiException('خطا در بروزرسانی تنظیمات: ${e.toString()}');
    }
  }
}
```

---

## 📦 Request/Response Models

### API Response Model
```dart
// lib/core/models/api_models.dart

/// فارسی: مدل پاسخ API
/// English: API response model
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final Map<String, dynamic>? errors;
  final int? statusCode;
  final DateTime timestamp;
  
  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.errors,
    this.statusCode,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
  
  /// فارسی: ایجاد از پاسخ HTTP
  /// English: Create from HTTP response
  factory ApiResponse.fromResponse<T>(Response<Map<String, dynamic>> response) {
    final responseData = response.data ?? {};
    
    return ApiResponse<T>(
      success: responseData['success'] ?? false,
      data: responseData['data'],
      message: responseData['message'],
      errors: responseData['errors'],
      statusCode: response.statusCode,
      timestamp: _parseTimestamp(responseData['timestamp']),
    );
  }
  
  /// فارسی: پاسخ موفق
  /// English: Success response
  factory ApiResponse.success(T data, {String? message}) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message,
    );
  }
  
  /// فارسی: پاسخ خطا
  /// English: Error response
  factory ApiResponse.error(
    String message, {
    Map<String, dynamic>? errors,
    int? statusCode,
  }) {
    return ApiResponse<T>(
      success: false,
      message: message,
      errors: errors,
      statusCode: statusCode,
    );
  }
  
  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp is String) {
      return DateTime.tryParse(timestamp) ?? DateTime.now();
    }
    return DateTime.now();
  }
  
  @override
  String toString() {
    return 'ApiResponse(success: $success, message: $message, data: $data)';
  }
}

/// فارسی: مدل درخواست ایجاد فرم
/// English: Create form request model
class CreateFormRequest {
  final String title;
  final String? description;
  final FormSettings? settings;
  
  CreateFormRequest({
    required this.title,
    this.description,
    this.settings,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'settings': settings?.toJson(),
    };
  }
}

/// فارسی: مدل درخواست بروزرسانی فرم
/// English: Update form request model
class UpdateFormRequest {
  final String? title;
  final String? description;
  final FormSettings? settings;
  final bool? isActive;
  
  UpdateFormRequest({
    this.title,
    this.description,
    this.settings,
    this.isActive,
  });
  
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    
    if (title != null) json['title'] = title;
    if (description != null) json['description'] = description;
    if (settings != null) json['settings'] = settings!.toJson();
    if (isActive != null) json['is_active'] = isActive;
    
    return json;
  }
}

/// فارسی: مدل تنظیمات فرم
/// English: Form settings model
class FormSettings {
  final String textDirection;
  final String fontFamily;
  final bool allowDuplicates;
  final bool requireAuthentication;
  
  FormSettings({
    this.textDirection = 'rtl',
    this.fontFamily = 'Vazirmatn',
    this.allowDuplicates = false,
    this.requireAuthentication = false,
  });
  
  factory FormSettings.fromJson(Map<String, dynamic> json) {
    return FormSettings(
      textDirection: json['text_direction'] ?? 'rtl',
      fontFamily: json['font_family'] ?? 'Vazirmatn',
      allowDuplicates: json['allow_duplicates'] ?? false,
      requireAuthentication: json['require_authentication'] ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'text_direction': textDirection,
      'font_family': fontFamily,
      'allow_duplicates': allowDuplicates,
      'require_authentication': requireAuthentication,
    };
  }
}
```

---

## 🚫 Error Handling

### Exception Classes
```dart
// lib/core/models/error_models.dart

/// فارسی: کلاس پایه خطاهای DataSave
/// English: Base DataSave exception class
abstract class DataSaveException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  
  const DataSaveException(
    this.message, {
    this.code,
    this.originalError,
  });
  
  @override
  String toString() => '$runtimeType: $message';
}

/// فارسی: خطای شبکه
/// English: Network exception
class NetworkException extends DataSaveException {
  const NetworkException(
    String message, {
    String? code,
    dynamic originalError,
  }) : super(message, code: code, originalError: originalError);
}

/// فارسی: خطای API
/// English: API exception
class ApiException extends DataSaveException {
  final int? statusCode;
  final Map<String, dynamic>? errors;
  
  const ApiException(
    String message, {
    this.statusCode,
    this.errors,
    String? code,
    dynamic originalError,
  }) : super(message, code: code, originalError: originalError);
  
  /// فارسی: آیا خطای سرور است؟
  /// English: Is server error?
  bool get isServerError => statusCode != null && statusCode! >= 500;
  
  /// فارسی: آیا خطای کلاینت است؟
  /// English: Is client error?
  bool get isClientError => statusCode != null && statusCode! >= 400 && statusCode! < 500;
}

/// فارسی: خطای اعتبارسنجی
/// English: Validation exception
class ValidationException extends DataSaveException {
  final Map<String, List<String>>? fieldErrors;
  
  const ValidationException(
    String message, {
    this.fieldErrors,
    String? code,
  }) : super(message, code: code);
  
  /// فارسی: دریافت خطاهای فیلد خاص
  /// English: Get errors for specific field
  List<String> getFieldErrors(String fieldName) {
    return fieldErrors?[fieldName] ?? [];
  }
}

/// فارسی: خطای احراز هویت
/// English: Authentication exception
class AuthenticationException extends DataSaveException {
  const AuthenticationException(
    String message, {
    String? code,
  }) : super(message, code: code);
}

/// فارسی: خطای نامشخص
/// English: Unknown exception
class UnknownException extends DataSaveException {
  const UnknownException(
    String message, {
    dynamic originalError,
  }) : super(message, originalError: originalError);
}
```

### Error Handler Service
```dart
// lib/core/services/error_handler_service.dart

/// فارسی: سرویس مدیریت خطاها
/// English: Error handler service
@singleton
class ErrorHandlerService {
  final Logger _logger;
  
  ErrorHandlerService(this._logger);
  
  /// فارسی: مدیریت خطا و بازگرداندن پیام مناسب
  /// English: Handle error and return appropriate message
  String handleError(Exception error, {String? context}) {
    final errorMessage = _getLocalizedMessage(error);
    
    // Log the error
    _logError(error, context: context);
    
    // Send to crash reporting service (if available)
    _reportError(error, context: context);
    
    return errorMessage;
  }
  
  /// فارسی: دریافت پیام محلی‌سازی شده
  /// English: Get localized error message
  String _getLocalizedMessage(Exception error) {
    switch (error.runtimeType) {
      case NetworkException:
        return _getNetworkErrorMessage(error as NetworkException);
      case ApiException:
        return _getApiErrorMessage(error as ApiException);
      case ValidationException:
        return _getValidationErrorMessage(error as ValidationException);
      case AuthenticationException:
        return 'لطفاً دوباره وارد شوید';
      default:
        return 'خطای غیرمنتظره‌ای رخ داده است';
    }
  }
  
  /// فارسی: پیام خطای شبکه
  /// English: Network error message
  String _getNetworkErrorMessage(NetworkException error) {
    if (error.message.contains('timeout') || error.message.contains('منقضی')) {
      return 'اتصال منقضی شد. لطفاً دوباره تلاش کنید';
    } else if (error.message.contains('connection') || error.message.contains('اتصال')) {
      return 'خطا در اتصال به سرور. لطفاً اتصال اینترنت خود را بررسی کنید';
    }
    return 'مشکلی در ارتباط با سرور رخ داده است';
  }
  
  /// فارسی: پیام خطای API
  /// English: API error message
  String _getApiErrorMessage(ApiException error) {
    if (error.isClientError) {
      return error.message.isNotEmpty ? error.message : 'درخواست نامعتبر است';
    } else if (error.isServerError) {
      return 'خطای سرور رخ داده است. لطفاً بعداً تلاش کنید';
    }
    return error.message.isNotEmpty ? error.message : 'خطای نامشخص';
  }
  
  /// فارسی: پیام خطای اعتبارسنجی
  /// English: Validation error message
  String _getValidationErrorMessage(ValidationException error) {
    if (error.fieldErrors?.isNotEmpty == true) {
      final firstError = error.fieldErrors!.values.first.first;
      return firstError;
    }
    return error.message.isNotEmpty ? error.message : 'داده‌های ورودی نامعتبر است';
  }
  
  /// فارسی: ثبت خطا در لاگ
  /// English: Log error
  void _logError(Exception error, {String? context}) {
    final contextInfo = context != null ? '[$context] ' : '';
    _logger.severe('${contextInfo}Error: $error');
    
    if (error is DataSaveException && error.originalError != null) {
      _logger.severe('Original error: ${error.originalError}');
    }
  }
  
  /// فارسی: گزارش خطا به سرویس monitoring
  /// English: Report error to monitoring service
  void _reportError(Exception error, {String? context}) {
    // TODO: Implement crash reporting (Firebase Crashlytics, Sentry, etc.)
    if (kReleaseMode) {
      // Send to crash reporting service
    }
  }
}
```

---

## 💾 Caching Strategy

### API Cache Service
```dart
// lib/core/services/api_cache_service.dart

/// فارسی: سرویس کش API
/// English: API cache service
@singleton
class ApiCacheService {
  final Map<String, CacheEntry> _cache = {};
  final Duration _defaultTtl = const Duration(minutes: 5);
  
  /// فارسی: دریافت داده از کش
  /// English: Get data from cache
  T? get<T>(String key) {
    final entry = _cache[key];
    
    if (entry == null) return null;
    
    if (entry.isExpired) {
      _cache.remove(key);
      return null;
    }
    
    return entry.data as T?;
  }
  
  /// فارسی: ذخیره داده در کش
  /// English: Store data in cache
  void set<T>(String key, T data, {Duration? ttl}) {
    _cache[key] = CacheEntry(
      data: data,
      expiresAt: DateTime.now().add(ttl ?? _defaultTtl),
    );
  }
  
  /// فارسی: حذف از کش
  /// English: Remove from cache
  void remove(String key) {
    _cache.remove(key);
  }
  
  /// فارسی: پاک کردن کامل کش
  /// English: Clear all cache
  void clear() {
    _cache.clear();
  }
  
  /// فارسی: ایجاد کلید کش
  /// English: Generate cache key
  String generateKey(String endpoint, [Map<String, dynamic>? params]) {
    final paramString = params?.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&') ?? '';
    return '$endpoint${paramString.isNotEmpty ? '?$paramString' : ''}';
  }
}

/// فارسی: ورودی کش
/// English: Cache entry
class CacheEntry {
  final dynamic data;
  final DateTime expiresAt;
  
  CacheEntry({
    required this.data,
    required this.expiresAt,
  });
  
  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// فارسی: مکس‌این wrapper برای کش
/// English: Mixin wrapper for caching
mixin ApiCacheMixin {
  ApiCacheService get cacheService => ServiceLocator.get<ApiCacheService>();
  
  /// فارسی: دریافت یا fetch کردن
  /// English: Get or fetch
  Future<T> getOrFetch<T>(
    String cacheKey,
    Future<T> Function() fetchFunction, {
    Duration? cacheTtl,
  }) async {
    // Try cache first
    final cached = cacheService.get<T>(cacheKey);
    if (cached != null) {
      return cached;
    }
    
    // Fetch from API
    final data = await fetchFunction();
    
    // Cache the result
    cacheService.set(cacheKey, data, ttl: cacheTtl);
    
    return data;
  }
}
```

---

## 🔐 Authentication

### Auth Interceptor
```dart
// lib/core/network/interceptors/auth_interceptor.dart

/// فارسی: اینترسپتور احراز هویت
/// English: Authentication interceptor
class AuthInterceptor extends Interceptor {
  final AuthService _authService = ServiceLocator.get<AuthService>();
  
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add auth token if available
    final token = _authService.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    handler.next(options);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle auth errors
    if (err.response?.statusCode == 401) {
      _handleUnauthorized(err, handler);
    } else {
      handler.next(err);
    }
  }
  
  /// فارسی: مدیریت خطای عدم احراز هویت
  /// English: Handle unauthorized error
  void _handleUnauthorized(DioException err, ErrorInterceptorHandler handler) async {
    try {
      // Try to refresh token
      final newToken = await _authService.refreshToken();
      
      if (newToken != null) {
        // Retry the original request
        final clonedRequest = await _retryRequest(err.requestOptions);
        handler.resolve(clonedRequest);
      } else {
        // Logout user
        await _authService.logout();
        handler.next(err);
      }
    } catch (e) {
      // Failed to refresh, logout
      await _authService.logout();
      handler.next(err);
    }
  }
  
  /// فارسی: تلاش مجدد درخواست
  /// English: Retry request
  Future<Response<dynamic>> _retryRequest(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    
    final dio = Dio();
    return dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
}
```

---

## 🌍 Persian Text Support

### Persian Interceptor
```dart
// lib/core/network/interceptors/persian_interceptor.dart

/// فارسی: اینترسپتور پشتیبانی فارسی
/// English: Persian support interceptor
class PersianInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Ensure UTF-8 encoding for Persian text
    options.headers['Accept-Charset'] = 'utf-8';
    options.headers['Content-Type'] = 'application/json; charset=utf-8';
    
    // Process Persian data
    if (options.data != null) {
      options.data = _processPersianData(options.data);
    }
    
    handler.next(options);
  }
  
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Process Persian response data
    if (response.data != null) {
      response.data = _processPersianResponse(response.data);
    }
    
    handler.next(response);
  }
  
  /// فارسی: پردازش داده‌های فارسی در درخواست
  /// English: Process Persian data in request
  dynamic _processPersianData(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data.map((key, value) => MapEntry(key, _processPersianValue(value)));
    } else if (data is List) {
      return data.map(_processPersianValue).toList();
    }
    return data;
  }
  
  /// فارسی: پردازش پاسخ فارسی
  /// English: Process Persian response
  dynamic _processPersianResponse(dynamic data) {
    // Same processing as request data
    return _processPersianData(data);
  }
  
  /// فارسی: پردازش مقدار فارسی
  /// English: Process Persian value
  dynamic _processPersianValue(dynamic value) {
    if (value is String) {
      // Normalize Persian/Arabic characters
      return _normalizePersianText(value);
    } else if (value is Map<String, dynamic>) {
      return value.map((k, v) => MapEntry(k, _processPersianValue(v)));
    } else if (value is List) {
      return value.map(_processPersianValue).toList();
    }
    return value;
  }
  
  /// فارسی: نرمال‌سازی متن فارسی
  /// English: Normalize Persian text
  String _normalizePersianText(String text) {
    // Replace Arabic characters with Persian equivalents
    return text
        .replaceAll('ي', 'ی')  // Arabic ya to Persian ya
        .replaceAll('ك', 'ک')  // Arabic kaf to Persian kaf
        .replaceAll('٠', '۰')  // Arabic digits to Persian
        .replaceAll('١', '۱')
        .replaceAll('٢', '۲')
        .replaceAll('٣', '۳')
        .replaceAll('٤', '۴')
        .replaceAll('٥', '۵')
        .replaceAll('٦', '۶')
        .replaceAll('٧', '۷')
        .replaceAll('٨', '۸')
        .replaceAll('٩', '۹');
  }
}
```

---

## 🧪 Testing API Services

### API Service Tests
```dart
// test/services/forms_api_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:datasave/core/services/forms_api_service.dart';
import 'package:datasave/core/network/api_client.dart';
import 'package:datasave/core/models/api_models.dart';

// Mock classes
class MockApiClient extends Mock implements ApiClient {}

void main() {
  group('FormsApiService', () {
    late FormsApiService formsApiService;
    late MockApiClient mockApiClient;
    
    setUp(() {
      mockApiClient = MockApiClient();
      formsApiService = FormsApiService(mockApiClient);
    });
    
    group('getAllForms', () {
      test('فارسی: باید لیست فرم‌ها را با موفقیت برگرداند - should return forms list successfully', () async {
        // Arrange
        final mockResponse = ApiResponse.success([
          {'id': 1, 'title': 'فرم تماس', 'description': 'توضیحات فرم'},
          {'id': 2, 'title': 'فرم ثبت‌نام', 'description': 'فرم ثبت‌نام کاربران'},
        ]);
        
        when(mockApiClient.get<List<dynamic>>(
          ApiEndpoints.getAllForms,
        )).thenAnswer((_) async => mockResponse);
        
        // Act
        final result = await formsApiService.getAllForms();
        
        // Assert
        expect(result, isA<List<FormModel>>());
        expect(result.length, equals(2));
        expect(result[0].title, equals('فرم تماس'));
        expect(result[1].title, equals('فرم ثبت‌نام'));
        
        verify(mockApiClient.get<List<dynamic>>(ApiEndpoints.getAllForms)).called(1);
      });
      
      test('فارسی: باید خطای API را مدیریت کند - should handle API error', () async {
        // Arrange
        when(mockApiClient.get<List<dynamic>>(
          ApiEndpoints.getAllForms,
        )).thenThrow(const ApiException('خطای سرور'));
        
        // Act & Assert
        expect(
          () => formsApiService.getAllForms(),
          throwsA(isA<ApiException>()),
        );
      });
    });
    
    group('createForm', () {
      test('فارسی: باید فرم جدید ایجاد کند - should create new form', () async {
        // Arrange
        final request = CreateFormRequest(
          title: 'فرم تست',
          description: 'توضیحات تست',
        );
        
        final mockResponse = ApiResponse.success({
          'id': 1,
          'title': 'فرم تست',
          'description': 'توضیحات تست',
          'created_at': '2025-09-01 12:00:00',
        });
        
        when(mockApiClient.post<Map<String, dynamic>>(
          ApiEndpoints.createForm,
          data: request.toJson(),
        )).thenAnswer((_) async => mockResponse);
        
        // Act
        final result = await formsApiService.createForm(request);
        
        // Assert
        expect(result, isA<FormModel>());
        expect(result.title, equals('فرم تست'));
        expect(result.description, equals('توضیحات تست'));
        
        verify(mockApiClient.post<Map<String, dynamic>>(
          ApiEndpoints.createForm,
          data: request.toJson(),
        )).called(1);
      });
    });
  });
}
```

### Integration Tests
```dart
// test/integration/api_integration_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:datasave/core/services/forms_api_service.dart';
import 'package:datasave/core/network/api_client.dart';
import 'package:datasave/core/models/api_models.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('API Integration Tests', () {
    late FormsApiService formsApiService;
    
    setUpAll(() {
      // Setup real API client for integration testing
      final apiClient = ApiClient(
        Dio(BaseOptions(baseUrl: 'http://localhost/datasave/backend')),
        NetworkInfoImpl(),
      );
      formsApiService = FormsApiService(apiClient);
    });
    
    test('فارسی: تست کامل CRUD عملیات فرم - Full form CRUD integration test', () async {
      // Create form
      final createRequest = CreateFormRequest(
        title: 'فرم تست تکامل',
        description: 'این فرمی برای تست تکامل سیستم است',
      );
      
      final createdForm = await formsApiService.createForm(createRequest);
      expect(createdForm.title, equals('فرم تست تکامل'));
      
      // Get form by ID
      final retrievedForm = await formsApiService.getFormById(createdForm.id);
      expect(retrievedForm, isNotNull);
      expect(retrievedForm!.title, equals(createdForm.title));
      
      // Update form
      final updateRequest = UpdateFormRequest(
        title: 'فرم تست بروزرسانی شده',
        description: 'توضیحات بروزرسانی شده',
      );
      
      final updatedForm = await formsApiService.updateForm(createdForm.id, updateRequest);
      expect(updatedForm.title, equals('فرم تست بروزرسانی شده'));
      
      // Delete form
      final deleteResult = await formsApiService.deleteForm(createdForm.id);
      expect(deleteResult, isTrue);
      
      // Verify deletion
      final deletedForm = await formsApiService.getFormById(createdForm.id);
      expect(deletedForm, isNull);
    });
  });
}
```

---

## 📊 Performance Monitoring

### API Metrics Service
```dart
// lib/core/services/api_metrics_service.dart

/// فارسی: سرویس متریک‌های API
/// English: API metrics service
@singleton
class ApiMetricsService {
  final Map<String, List<ApiCallMetric>> _metrics = {};
  
  /// فارسی: ثبت متریک درخواست
  /// English: Record request metric
  void recordApiCall(String endpoint, Duration duration, bool success) {
    final metric = ApiCallMetric(
      endpoint: endpoint,
      duration: duration,
      success: success,
      timestamp: DateTime.now(),
    );
    
    _metrics.putIfAbsent(endpoint, () => []).add(metric);
    
    // Keep only last 100 records per endpoint
    if (_metrics[endpoint]!.length > 100) {
      _metrics[endpoint]!.removeAt(0);
    }
  }
  
  /// فارسی: دریافت آمار عملکرد
  /// English: Get performance stats
  Map<String, ApiPerformanceStats> getPerformanceStats() {
    return _metrics.map((endpoint, metrics) {
      return MapEntry(endpoint, _calculateStats(metrics));
    });
  }
  
  ApiPerformanceStats _calculateStats(List<ApiCallMetric> metrics) {
    final durations = metrics.map((m) => m.duration.inMilliseconds).toList();
    final successCount = metrics.where((m) => m.success).length;
    
    return ApiPerformanceStats(
      totalCalls: metrics.length,
      successRate: successCount / metrics.length,
      averageResponseTime: durations.fold(0, (a, b) => a + b) / durations.length,
      maxResponseTime: durations.fold(0, (a, b) => a > b ? a : b),
      minResponseTime: durations.fold(durations.first, (a, b) => a < b ? a : b),
    );
  }
}

class ApiCallMetric {
  final String endpoint;
  final Duration duration;
  final bool success;
  final DateTime timestamp;
  
  ApiCallMetric({
    required this.endpoint,
    required this.duration,
    required this.success,
    required this.timestamp,
  });
}

class ApiPerformanceStats {
  final int totalCalls;
  final double successRate;
  final double averageResponseTime;
  final int maxResponseTime;
  final int minResponseTime;
  
  ApiPerformanceStats({
    required this.totalCalls,
    required this.successRate,
    required this.averageResponseTime,
    required this.maxResponseTime,
    required this.minResponseTime,
  });
}
```

---

## 🔄 Related Documentation
- [API Endpoints Reference](../02-Backend-APIs/api-endpoints-reference.md)
- [Flutter Architecture](../04-Flutter-Frontend/flutter-architecture.md)
- [Error Handling](../02-Backend-APIs/error-handling.md)
- [Testing Strategy](../07-Development-Workflow/testing-strategy.md)
- [OpenAI Integration](openai-integration.md)

---
*Last updated: 2025-09-01*  
*File: docs/05-Services-Integration/api-service-layer.md*