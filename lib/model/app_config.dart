class AppConfig {
  final String title;
  final String subtitle;

  AppConfig({
    required this.title,
    required this.subtitle,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
    };
  }

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      title: json['title'] ?? 'INDIAN PEST CARE SERVICES',
      subtitle: json['subtitle'] ?? 'Pest Control Report',
    );
  }

  AppConfig copyWith({
    String? title,
    String? subtitle,
  }) {
    return AppConfig(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
    );
  }
}
