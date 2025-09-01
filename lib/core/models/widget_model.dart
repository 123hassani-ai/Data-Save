import 'dart:convert';

/// مدل ویجت فرم - Form Widget Model
/// نمایانگر ساختار ویجت‌های قابل استفاده در فرم‌ساز
class FormWidgetModel {
  final int? id;
  final String widgetType;
  final String widgetCode;
  final String widgetCategory;
  final String persianLabel;
  final String? englishLabel;
  final String? persianDescription;
  final String? englishDescription;
  final Map<String, dynamic> widgetConfig;
  final Map<String, dynamic>? validationRules;
  final Map<String, dynamic>? defaultProps;
  final String? iconName;
  final String iconColor;
  final String? previewImage;
  final int displayOrder;
  final bool isPro;
  final bool isActive;
  final String minVersion;
  final int usageCount;
  final DateTime? lastUsedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  FormWidgetModel({
    this.id,
    required this.widgetType,
    required this.widgetCode,
    this.widgetCategory = 'basic',
    required this.persianLabel,
    this.englishLabel,
    this.persianDescription,
    this.englishDescription,
    required this.widgetConfig,
    this.validationRules,
    this.defaultProps,
    this.iconName,
    this.iconColor = '#2196F3',
    this.previewImage,
    this.displayOrder = 999,
    this.isPro = false,
    this.isActive = true,
    this.minVersion = '1.0',
    this.usageCount = 0,
    this.lastUsedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// ایجاد FormWidgetModel از JSON
  /// Create FormWidgetModel from JSON
  factory FormWidgetModel.fromJson(Map<String, dynamic> json) {
    return FormWidgetModel(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      widgetType: json['widget_type'] ?? '',
      widgetCode: json['widget_code'] ?? '',
      widgetCategory: json['widget_category'] ?? 'basic',
      persianLabel: json['persian_label'] ?? '',
      englishLabel: json['english_label'],
      persianDescription: json['persian_description'],
      englishDescription: json['english_description'],
      widgetConfig: json['widget_config'] is String
          ? _parseJsonString(json['widget_config']) ?? {}
          : Map<String, dynamic>.from(json['widget_config'] ?? {}),
      validationRules: json['validation_rules'] is String
          ? _parseJsonString(json['validation_rules'])
          : json['validation_rules'] != null
              ? Map<String, dynamic>.from(json['validation_rules'])
              : null,
      defaultProps: json['default_props'] is String
          ? _parseJsonString(json['default_props'])
          : json['default_props'] != null
              ? Map<String, dynamic>.from(json['default_props'])
              : null,
      iconName: json['icon_name'],
      iconColor: json['icon_color'] ?? '#2196F3',
      previewImage: json['preview_image'],
      displayOrder: int.tryParse(json['display_order']?.toString() ?? '999') ?? 999,
      isPro: json['is_pro'] == true || json['is_pro'] == 1,
      isActive: json['is_active'] == true || json['is_active'] == 1,
      minVersion: json['min_version'] ?? '1.0',
      usageCount: int.tryParse(json['usage_count']?.toString() ?? '0') ?? 0,
      lastUsedAt: json['last_used_at'] != null
          ? DateTime.tryParse(json['last_used_at'].toString())
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  /// تبدیل FormWidgetModel به JSON
  /// Convert FormWidgetModel to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'widget_type': widgetType,
      'widget_code': widgetCode,
      'widget_category': widgetCategory,
      'persian_label': persianLabel,
      if (englishLabel != null) 'english_label': englishLabel,
      if (persianDescription != null) 'persian_description': persianDescription,
      if (englishDescription != null) 'english_description': englishDescription,
      'widget_config': widgetConfig,
      if (validationRules != null) 'validation_rules': validationRules,
      if (defaultProps != null) 'default_props': defaultProps,
      if (iconName != null) 'icon_name': iconName,
      'icon_color': iconColor,
      if (previewImage != null) 'preview_image': previewImage,
      'display_order': displayOrder,
      'is_pro': isPro,
      'is_active': isActive,
      'min_version': minVersion,
      'usage_count': usageCount,
      if (lastUsedAt != null) 'last_used_at': lastUsedAt!.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// کپی FormWidgetModel با تغییرات
  /// Copy FormWidgetModel with changes
  FormWidgetModel copyWith({
    int? id,
    String? widgetType,
    String? widgetCode,
    String? widgetCategory,
    String? persianLabel,
    String? englishLabel,
    String? persianDescription,
    String? englishDescription,
    Map<String, dynamic>? widgetConfig,
    Map<String, dynamic>? validationRules,
    Map<String, dynamic>? defaultProps,
    String? iconName,
    String? iconColor,
    String? previewImage,
    int? displayOrder,
    bool? isPro,
    bool? isActive,
    String? minVersion,
    int? usageCount,
    DateTime? lastUsedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FormWidgetModel(
      id: id ?? this.id,
      widgetType: widgetType ?? this.widgetType,
      widgetCode: widgetCode ?? this.widgetCode,
      widgetCategory: widgetCategory ?? this.widgetCategory,
      persianLabel: persianLabel ?? this.persianLabel,
      englishLabel: englishLabel ?? this.englishLabel,
      persianDescription: persianDescription ?? this.persianDescription,
      englishDescription: englishDescription ?? this.englishDescription,
      widgetConfig: widgetConfig ?? this.widgetConfig,
      validationRules: validationRules ?? this.validationRules,
      defaultProps: defaultProps ?? this.defaultProps,
      iconName: iconName ?? this.iconName,
      iconColor: iconColor ?? this.iconColor,
      previewImage: previewImage ?? this.previewImage,
      displayOrder: displayOrder ?? this.displayOrder,
      isPro: isPro ?? this.isPro,
      isActive: isActive ?? this.isActive,
      minVersion: minVersion ?? this.minVersion,
      usageCount: usageCount ?? this.usageCount,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// عنوان مناسب بر اساس زبان
  /// Appropriate label based on language
  String get displayLabel => persianLabel; // فعلاً همیشه فارسی

  /// توضیحات مناسب بر اساس زبان
  /// Appropriate description based on language
  String? get displayDescription => persianDescription; // فعلاً همیشه فارسی

  /// نام دسته‌بندی فارسی
  /// Persian category name
  String get persianCategoryName {
    switch (widgetCategory) {
      case 'basic':
        return 'پایه';
      case 'advanced':
        return 'پیشرفته';
      case 'input':
        return 'ورودی';
      case 'selection':
        return 'انتخاب';
      case 'date':
        return 'تاریخ و زمان';
      case 'media':
        return 'رسانه';
      case 'layout':
        return 'چیدمان';
      case 'custom':
        return 'سفارشی';
      default:
        return widgetCategory;
    }
  }

  /// نوع ورودی فارسی
  /// Persian input type
  String get persianWidgetType {
    switch (widgetType) {
      case 'text':
        return 'متن ساده';
      case 'textarea':
        return 'متن چندخط';
      case 'number':
        return 'عدد';
      case 'email':
        return 'ایمیل';
      case 'password':
        return 'رمز عبور';
      case 'tel':
        return 'شماره تلفن';
      case 'url':
        return 'آدرس وب';
      case 'select':
        return 'لیست کشویی';
      case 'multiselect':
        return 'انتخاب چندتایی';
      case 'radio':
        return 'دکمه رادیویی';
      case 'checkbox':
        return 'چک‌باکس';
      case 'toggle':
        return 'کلید تغییر';
      case 'date':
        return 'تاریخ';
      case 'datetime':
        return 'تاریخ و زمان';
      case 'time':
        return 'زمان';
      case 'range':
        return 'محدوده';
      case 'color':
        return 'رنگ';
      case 'file':
        return 'فایل';
      case 'image':
        return 'تصویر';
      case 'signature':
        return 'امضا';
      case 'rating':
        return 'امتیازدهی';
      case 'matrix':
        return 'ماتریس';
      case 'submit':
        return 'دکمه ارسال';
      default:
        return widgetType;
    }
  }

  /// آیکون پیش‌فرض بر اساس نوع
  /// Default icon based on type
  String get defaultIcon {
    if (iconName != null && iconName!.isNotEmpty) return iconName!;
    
    switch (widgetType) {
      case 'text':
        return 'text_fields';
      case 'textarea':
        return 'notes';
      case 'number':
        return 'tag';
      case 'email':
        return 'alternate_email';
      case 'password':
        return 'lock';
      case 'tel':
        return 'phone';
      case 'url':
        return 'link';
      case 'select':
      case 'multiselect':
        return 'arrow_drop_down_circle';
      case 'radio':
        return 'radio_button_checked';
      case 'checkbox':
        return 'check_box';
      case 'toggle':
        return 'toggle_on';
      case 'date':
        return 'calendar_today';
      case 'datetime':
        return 'schedule';
      case 'time':
        return 'access_time';
      case 'range':
        return 'linear_scale';
      case 'color':
        return 'palette';
      case 'file':
        return 'attach_file';
      case 'image':
        return 'image';
      case 'signature':
        return 'gesture';
      case 'rating':
        return 'star';
      case 'matrix':
        return 'grid_on';
      case 'submit':
        return 'send';
      default:
        return 'widgets';
    }
  }

  /// بررسی نیاز به ویژگی‌های خاص
  /// Check if requires special features
  bool get requiresOptions {
    return ['select', 'multiselect', 'radio', 'checkbox'].contains(widgetType);
  }

  bool get requiresValidation {
    return ['text', 'textarea', 'number', 'email', 'tel', 'url'].contains(widgetType);
  }

  bool get requiresDateConfig {
    return ['date', 'datetime', 'time'].contains(widgetType);
  }

  bool get requiresFileConfig {
    return ['file', 'image'].contains(widgetType);
  }

  /// دریافت placeholder پیش‌فرض
  /// Get default placeholder
  String get defaultPlaceholder {
    final placeholder = widgetConfig['placeholder'];
    if (placeholder != null && placeholder.toString().isNotEmpty) {
      return placeholder.toString();
    }

    switch (widgetType) {
      case 'text':
        return 'متن خود را وارد کنید';
      case 'textarea':
        return 'متن خود را وارد کنید...';
      case 'number':
        return 'عدد مورد نظر را وارد کنید';
      case 'email':
        return 'ایمیل خود را وارد کنید';
      case 'password':
        return 'رمز عبور خود را وارد کنید';
      case 'tel':
        return 'شماره تلفن خود را وارد کنید';
      case 'url':
        return 'آدرس وب را وارد کنید';
      default:
        return 'مقدار خود را وارد کنید';
    }
  }

  /// تنظیمات اعتبارسنجی پیش‌فرض
  /// Default validation settings
  Map<String, dynamic> get defaultValidation {
    return validationRules ?? {
      'required': false,
      'type': widgetType,
    };
  }

  /// Parse JSON string safely
  /// تجزیه امن رشته JSON
  static Map<String, dynamic>? _parseJsonString(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return null;
    try {
      return Map<String, dynamic>.from(
        const JsonDecoder().convert(jsonString),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() {
    return 'FormWidgetModel(id: $id, widgetType: $widgetType, persianLabel: $persianLabel, category: $widgetCategory)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FormWidgetModel && 
           other.id == id && 
           other.widgetCode == widgetCode;
  }

  @override
  int get hashCode => id.hashCode ^ widgetCode.hashCode;
}

/// مدل ویجت روی بوم - Canvas Widget Model
/// نمایانگر ویجت اضافه شده به بوم فرم‌ساز
class CanvasWidgetModel {
  final String id; // شناسه یکتا در بوم
  final FormWidgetModel template; // قالب ویجت اصلی
  final Map<String, dynamic> position;
  final Map<String, dynamic> size;
  final Map<String, dynamic> properties;
  final Map<String, dynamic>? customValidation;
  final bool isSelected;
  final bool isLocked;
  final int zIndex;

  CanvasWidgetModel({
    required this.id,
    required this.template,
    required this.position,
    required this.size,
    required this.properties,
    this.customValidation,
    this.isSelected = false,
    this.isLocked = false,
    this.zIndex = 0,
  });

  /// ایجاد از FormWidgetModel
  /// Create from FormWidgetModel
  factory CanvasWidgetModel.fromTemplate(
    FormWidgetModel template, {
    double x = 0,
    double y = 0,
    double width = 300,
    double height = 60,
  }) {
    final widgetId = 'widget_${DateTime.now().millisecondsSinceEpoch}';
    
    return CanvasWidgetModel(
      id: widgetId,
      template: template,
      position: {'x': x, 'y': y},
      size: {'width': width, 'height': height},
      properties: {
        'label': template.persianLabel,
        'required': false,
        'placeholder': template.defaultPlaceholder,
        ...template.widgetConfig,
      },
    );
  }

  /// کپی با تغییرات
  /// Copy with changes
  CanvasWidgetModel copyWith({
    String? id,
    FormWidgetModel? template,
    Map<String, dynamic>? position,
    Map<String, dynamic>? size,
    Map<String, dynamic>? properties,
    Map<String, dynamic>? customValidation,
    bool? isSelected,
    bool? isLocked,
    int? zIndex,
  }) {
    return CanvasWidgetModel(
      id: id ?? this.id,
      template: template ?? this.template,
      position: position ?? this.position,
      size: size ?? this.size,
      properties: properties ?? this.properties,
      customValidation: customValidation ?? this.customValidation,
      isSelected: isSelected ?? this.isSelected,
      isLocked: isLocked ?? this.isLocked,
      zIndex: zIndex ?? this.zIndex,
    );
  }

  /// موقعیت X
  double get x => (position['x'] ?? 0.0).toDouble();

  /// موقعیت Y
  double get y => (position['y'] ?? 0.0).toDouble();

  /// عرض
  double get width => (size['width'] ?? 300.0).toDouble();

  /// ارتفاع
  double get height => (size['height'] ?? 60.0).toDouble();

  /// برچسب فعلی
  String get currentLabel => properties['label']?.toString() ?? template.persianLabel;

  /// وضعیت الزامی
  bool get isRequired => properties['required'] == true;

  /// placeholder فعلی
  String get currentPlaceholder => 
      properties['placeholder']?.toString() ?? template.defaultPlaceholder;

  /// تبدیل به JSON برای ذخیره در فرم
  Map<String, dynamic> toFormSchema() {
    return {
      'id': id,
      'type': template.widgetType,
      'label': currentLabel,
      'position': position,
      'size': size,
      'properties': properties,
      'validation': customValidation ?? template.defaultValidation,
    };
  }

  @override
  String toString() {
    return 'CanvasWidgetModel(id: $id, type: ${template.widgetType}, label: $currentLabel)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CanvasWidgetModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
