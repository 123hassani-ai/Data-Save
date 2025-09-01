import 'dart:convert';

/// مدل فرم - Form Model
/// نمایانگر ساختار داده فرم در Flutter
class FormModel {
  final int? id;
  final int userId;
  final String persianTitle;
  final String? englishTitle;
  final String? persianDescription;
  final String? englishDescription;
  final Map<String, dynamic>? formSchema;
  final Map<String, dynamic>? formConfig;
  final Map<String, dynamic>? formSettings;
  final String status;
  final bool isPublic;
  final bool requiresLogin;
  final int? maxResponses;
  final int totalResponses;
  final int viewCount;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? publishedAt;
  final String version;

  FormModel({
    this.id,
    required this.userId,
    required this.persianTitle,
    this.englishTitle,
    this.persianDescription,
    this.englishDescription,
    this.formSchema,
    this.formConfig,
    this.formSettings,
    required this.status,
    this.isPublic = false,
    this.requiresLogin = false,
    this.maxResponses,
    this.totalResponses = 0,
    this.viewCount = 0,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
    this.publishedAt,
    this.version = '1.0',
  });

  /// ایجاد FormModel از JSON
  /// Create FormModel from JSON
  factory FormModel.fromJson(Map<String, dynamic> json) {
    return FormModel(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      userId: int.parse(json['user_id'].toString()),
      persianTitle: json['persian_title'] ?? '',
      englishTitle: json['english_title'],
      persianDescription: json['persian_description'],
      englishDescription: json['english_description'],
      formSchema: json['form_schema'] is String 
          ? _parseJsonString(json['form_schema'])
          : json['form_schema'],
      formConfig: json['form_config'] is String 
          ? _parseJsonString(json['form_config'])
          : json['form_config'],
      formSettings: json['form_settings'] is String 
          ? _parseJsonString(json['form_settings'])
          : json['form_settings'],
      status: json['status'] ?? 'draft',
      isPublic: json['is_public'] == true || json['is_public'] == 1,
      requiresLogin: json['requires_login'] == true || json['requires_login'] == 1,
      maxResponses: json['max_responses'] != null 
          ? int.tryParse(json['max_responses'].toString()) 
          : null,
      totalResponses: int.tryParse(json['total_responses']?.toString() ?? '0') ?? 0,
      viewCount: int.tryParse(json['view_count']?.toString() ?? '0') ?? 0,
      expiresAt: json['expires_at'] != null 
          ? DateTime.tryParse(json['expires_at'].toString()) 
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      publishedAt: json['published_at'] != null 
          ? DateTime.tryParse(json['published_at'].toString()) 
          : null,
      version: json['version'] ?? '1.0',
    );
  }

  /// تبدیل FormModel به JSON
  /// Convert FormModel to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'persian_title': persianTitle,
      if (englishTitle != null) 'english_title': englishTitle,
      if (persianDescription != null) 'persian_description': persianDescription,
      if (englishDescription != null) 'english_description': englishDescription,
      if (formSchema != null) 'form_schema': formSchema,
      if (formConfig != null) 'form_config': formConfig,
      if (formSettings != null) 'form_settings': formSettings,
      'status': status,
      'is_public': isPublic,
      'requires_login': requiresLogin,
      if (maxResponses != null) 'max_responses': maxResponses,
      'total_responses': totalResponses,
      'view_count': viewCount,
      if (expiresAt != null) 'expires_at': expiresAt!.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (publishedAt != null) 'published_at': publishedAt!.toIso8601String(),
      'version': version,
    };
  }

  /// کپی FormModel با تغییرات
  /// Copy FormModel with changes
  FormModel copyWith({
    int? id,
    int? userId,
    String? persianTitle,
    String? englishTitle,
    String? persianDescription,
    String? englishDescription,
    Map<String, dynamic>? formSchema,
    Map<String, dynamic>? formConfig,
    Map<String, dynamic>? formSettings,
    String? status,
    bool? isPublic,
    bool? requiresLogin,
    int? maxResponses,
    int? totalResponses,
    int? viewCount,
    DateTime? expiresAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? publishedAt,
    String? version,
  }) {
    return FormModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      persianTitle: persianTitle ?? this.persianTitle,
      englishTitle: englishTitle ?? this.englishTitle,
      persianDescription: persianDescription ?? this.persianDescription,
      englishDescription: englishDescription ?? this.englishDescription,
      formSchema: formSchema ?? this.formSchema,
      formConfig: formConfig ?? this.formConfig,
      formSettings: formSettings ?? this.formSettings,
      status: status ?? this.status,
      isPublic: isPublic ?? this.isPublic,
      requiresLogin: requiresLogin ?? this.requiresLogin,
      maxResponses: maxResponses ?? this.maxResponses,
      totalResponses: totalResponses ?? this.totalResponses,
      viewCount: viewCount ?? this.viewCount,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      publishedAt: publishedAt ?? this.publishedAt,
      version: version ?? this.version,
    );
  }

  /// بررسی منقضی بودن فرم
  /// Check if form is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// بررسی منتشر بودن فرم
  /// Check if form is published
  bool get isPublished => status == 'published';

  /// بررسی draft بودن فرم
  /// Check if form is draft
  bool get isDraft => status == 'draft';

  /// بررسی archive بودن فرم
  /// Check if form is archived
  bool get isArchived => status == 'archived';

  /// دریافت تعداد ویجت‌های فرم
  /// Get form widgets count
  int get widgetCount {
    if (formSchema == null) return 0;
    final widgets = formSchema!['widgets'];
    if (widgets is List) return widgets.length;
    return 0;
  }

  /// بررسی خالی بودن فرم
  /// Check if form is empty
  bool get isEmpty => widgetCount == 0;

  /// دریافت زبان فرم
  /// Get form language
  String get language {
    return formConfig?['language'] ?? 'fa';
  }

  /// دریافت جهت فرم
  /// Get form direction
  String get direction {
    return formConfig?['direction'] ?? 'rtl';
  }

  /// دریافت تم فرم
  /// Get form theme
  String get theme {
    return formConfig?['theme'] ?? 'default';
  }

  /// بررسی قابلیت پاسخ‌های متعدد
  /// Check if multiple responses allowed
  bool get allowMultipleResponses {
    return formSettings?['allow_multiple_responses'] ?? true;
  }

  /// بررسی نیاز به ایمیل
  /// Check if email is required
  bool get requiresEmail {
    return formSettings?['require_email'] ?? false;
  }

  /// بررسی ذخیره خودکار
  /// Check if auto save is enabled
  bool get autoSave {
    return formSettings?['auto_save'] ?? true;
  }

  /// عنوان مناسب بر اساس زبان
  /// Appropriate title based on language
  String get displayTitle {
    if (language == 'en' && englishTitle?.isNotEmpty == true) {
      return englishTitle!;
    }
    return persianTitle;
  }

  /// توضیحات مناسب بر اساس زبان
  /// Appropriate description based on language
  String? get displayDescription {
    if (language == 'en' && englishDescription?.isNotEmpty == true) {
      return englishDescription;
    }
    return persianDescription;
  }

  /// متن وضعیت فارسی
  /// Persian status text
  String get statusText {
    switch (status) {
      case 'draft':
        return 'پیش‌نویس';
      case 'published':
        return 'منتشر شده';
      case 'archived':
        return 'آرشیو شده';
      default:
        return status;
    }
  }

  /// رنگ وضعیت
  /// Status color
  String get statusColor {
    switch (status) {
      case 'draft':
        return '#FFA726'; // نارنجی
      case 'published':
        return '#4CAF50'; // سبز
      case 'archived':
        return '#9E9E9E'; // خاکستری
      default:
        return '#2196F3'; // آبی
    }
  }

  /// فرمت‌بندی تاریخ فارسی
  /// Persian date formatting
  String get persianCreatedDate {
    // برای الان از format انگلیسی استفاده می‌کنیم
    // در آینده با پکیج persian_datetime بهبود می‌یابد
    return '${createdAt.year}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.day.toString().padLeft(2, '0')}';
  }

  /// فرمت‌بندی زمان فارسی
  /// Persian time formatting
  String get persianCreatedTime {
    return '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
  }

  /// متن کامل تاریخ و زمان فارسی
  /// Complete Persian date and time text
  String get persianCreatedDateTime {
    return '$persianCreatedDate در ساعت $persianCreatedTime';
  }

  /// Parse JSON string safely
  /// تجزیه امن رشته JSON
  static Map<String, dynamic>? _parseJsonString(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return null;
    try {
      return Map<String, dynamic>.from(
        const JsonDecoder().convert(jsonString)
      );
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() {
    return 'FormModel(id: $id, persianTitle: $persianTitle, status: $status, widgetCount: $widgetCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FormModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
