import '../models/emergency_type.dart';
import '../models/incident_submission.dart';

abstract interface class IncidentService {
  Future<List<EmergencyType>> getEmergencyTypes();

  Future<void> submitIncident(IncidentSubmission submission);
}
