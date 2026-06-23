class IncidentSubmission {
  const IncidentSubmission({
    required this.profileId,
    required this.emergencyTypeId,
    required this.details,
    required this.capturedAt,
  });

  final String profileId;
  final String emergencyTypeId;
  final String details;
  final DateTime capturedAt;
}
