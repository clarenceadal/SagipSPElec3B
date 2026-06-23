class EmergencyType {
  const EmergencyType({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  factory EmergencyType.fromJson(Map<String, dynamic> json) {
    return EmergencyType(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}
