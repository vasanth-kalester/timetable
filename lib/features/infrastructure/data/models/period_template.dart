class PeriodTemplate {
  final String id;
  final String name;
  final bool isActive;

  PeriodTemplate({
    required this.id,
    required this.name,
    required this.isActive,
  });

  factory PeriodTemplate.fromJson(Map<String, dynamic> json) {
    return PeriodTemplate(
      id: json['id'],
      name: json['name'],
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isActive': isActive,
    };
  }
}
