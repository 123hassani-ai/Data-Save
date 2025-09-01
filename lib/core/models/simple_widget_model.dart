/// مدل ویجت ساده برای ساخت فرم - Simple Widget Model for Form Building
class WidgetModel {
  final String id;
  final String type;
  final String persianLabel;
  final String englishLabel;
  final bool isRequired;
  final int order;
  final Map<String, dynamic> validationRules;
  final Map<String, dynamic> config;
  final Map<String, dynamic>? defaultValue;
  final List<Map<String, dynamic>>? options;
  final bool isVisible;
  final bool isReadOnly;
  final String? helpText;
  final String? persianHelpText;

  const WidgetModel({
    required this.id,
    required this.type,
    required this.persianLabel,
    required this.englishLabel,
    this.isRequired = false,
    this.order = 0,
    this.validationRules = const {},
    this.config = const {},
    this.defaultValue,
    this.options,
    this.isVisible = true,
    this.isReadOnly = false,
    this.helpText,
    this.persianHelpText,
  });

  /// تبدیل به JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'persian_label': persianLabel,
      'english_label': englishLabel,
      'is_required': isRequired,
      'order': order,
      'validation_rules': validationRules,
      'config': config,
      'default_value': defaultValue,
      'options': options,
      'is_visible': isVisible,
      'is_read_only': isReadOnly,
      'help_text': helpText,
      'persian_help_text': persianHelpText,
    };
  }

  /// ایجاد از JSON
  factory WidgetModel.fromJson(Map<String, dynamic> json) {
    return WidgetModel(
      id: json['id'] ?? '',
      type: json['type'] ?? 'text_field',
      persianLabel: json['persian_label'] ?? '',
      englishLabel: json['english_label'] ?? '',
      isRequired: json['is_required'] ?? false,
      order: json['order'] ?? 0,
      validationRules: Map<String, dynamic>.from(json['validation_rules'] ?? {}),
      config: Map<String, dynamic>.from(json['config'] ?? {}),
      defaultValue: json['default_value'],
      options: json['options'] != null 
        ? List<Map<String, dynamic>>.from(json['options'])
        : null,
      isVisible: json['is_visible'] ?? true,
      isReadOnly: json['is_read_only'] ?? false,
      helpText: json['help_text'],
      persianHelpText: json['persian_help_text'],
    );
  }

  /// کپی با تغییرات
  WidgetModel copyWith({
    String? id,
    String? type,
    String? persianLabel,
    String? englishLabel,
    bool? isRequired,
    int? order,
    Map<String, dynamic>? validationRules,
    Map<String, dynamic>? config,
    Map<String, dynamic>? defaultValue,
    List<Map<String, dynamic>>? options,
    bool? isVisible,
    bool? isReadOnly,
    String? helpText,
    String? persianHelpText,
  }) {
    return WidgetModel(
      id: id ?? this.id,
      type: type ?? this.type,
      persianLabel: persianLabel ?? this.persianLabel,
      englishLabel: englishLabel ?? this.englishLabel,
      isRequired: isRequired ?? this.isRequired,
      order: order ?? this.order,
      validationRules: validationRules ?? this.validationRules,
      config: config ?? this.config,
      defaultValue: defaultValue ?? this.defaultValue,
      options: options ?? this.options,
      isVisible: isVisible ?? this.isVisible,
      isReadOnly: isReadOnly ?? this.isReadOnly,
      helpText: helpText ?? this.helpText,
      persianHelpText: persianHelpText ?? this.persianHelpText,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WidgetModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'WidgetModel(id: $id, type: $type, label: $persianLabel)';
  }
}
