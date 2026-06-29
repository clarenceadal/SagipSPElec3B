import '../models/emergency_type.dart';
import '../models/incident_submission.dart';
import '../../admin/models/admin_incident.dart';
import '../../history/models/student_incident.dart';

abstract interface class IncidentService {
  Future<List<EmergencyType>> getEmergencyTypes();

  Future<void> submitIncident(IncidentSubmission submission);

  Future<List<AdminIncident>> getAdminIncidents();

  Future<void> updateIncidentStatus(String incidentId, String status);

  Future<List<StudentIncident>> getStudentIncidents(String profileId);
}
