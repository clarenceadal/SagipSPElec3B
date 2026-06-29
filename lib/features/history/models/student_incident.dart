class StudentIncident {
  const StudentIncident({
    required this.id,
    required this.emergencyType,
    required this.status,
    required this.createdAt,
    this.description,
    this.location,
  });

  final String id;
  final String emergencyType;
  final String status;
  final DateTime createdAt;
  final String? description;
  final String? location;

  factory StudentIncident.fromJson(Map<String, dynamic> json) {
    final emergencyType = json['emergency_types'] as Map<String, dynamic>? ?? {};
    return StudentIncident(
      id: json['id'] as String,
      emergencyType: emergencyType['name'] as String? ?? 'Emergency Report',
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      description: json['description'] as String?,
      location: json['location_address'] as String?,
    );
  }
}
