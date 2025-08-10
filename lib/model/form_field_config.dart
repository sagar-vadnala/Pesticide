class FormFieldConfig {
  final String id;
  final String label;
  final bool isRequired;

  FormFieldConfig({
    required this.id,
    required this.label,
    this.isRequired = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'isRequired': isRequired,
    };
  }

  factory FormFieldConfig.fromJson(Map<String, dynamic> json) {
    return FormFieldConfig(
      id: json['id'],
      label: json['label'],
      isRequired: json['isRequired'] ?? true,
    );
  }

  FormFieldConfig copyWith({
    String? id,
    String? label,
    bool? isRequired,
  }) {
    return FormFieldConfig(
      id: id ?? this.id,
      label: label ?? this.label,
      isRequired: isRequired ?? this.isRequired,
    );
  }
}
