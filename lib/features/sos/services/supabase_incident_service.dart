import 'package:supabase_flutter/supabase_flutter.dart';

import '../../admin/models/admin_incident.dart';
import '../../history/models/student_incident.dart';
import '../models/emergency_type.dart';
import '../models/incident_submission.dart';
import 'incident_service.dart';

class SupabaseIncidentService implements IncidentService {
  SupabaseIncidentService(this._client);

  final SupabaseClient _client;

  @override
  Future<List<EmergencyType>> getEmergencyTypes() async {
    final rows = await _client
        .from('emergency_types')
        .select('id, name')
        .eq('is_active', true)
        .order('name');

    return rows.map(EmergencyType.fromJson).toList();
  }

  @override
  Future<void> submitIncident(IncidentSubmission submission) async {
    final student = await _client
        .from('students')
        .select('id')
        .eq('profile_id', submission.profileId)
        .single();

    await _client.from('incidents').insert({
      'student_id': student['id'],
      'emergency_type_id': submission.emergencyTypeId,
      'description': submission.details.trim().isEmpty
          ? null
          : submission.details.trim(),
      'status': 'pending',
      'priority': 'high',
      'created_at': submission.capturedAt.toUtc().toIso8601String(),
    });
  }

  @override
  Future<List<AdminIncident>> getAdminIncidents() async {
    final rows = await _client
        .from('incidents')
        .select('''
          id,
          status,
          priority,
          description,
          created_at,
          emergency_types(name),
          students(
            student_id,
            course,
            year_level,
            last_name,
            first_name,
            middle_initial
          )
        ''')
        .order('created_at', ascending: false);

    return rows.map(AdminIncident.fromJson).toList();
  }

  @override
  Future<void> updateIncidentStatus(String incidentId, String status) async {
    await _client
        .from('incidents')
        .update({'status': status})
        .eq('id', incidentId);
  }

  @override
  Future<List<StudentIncident>> getStudentIncidents(String profileId) async {
    final student = await _client
        .from('students')
        .select('id')
        .eq('profile_id', profileId)
        .single();

    final rows = await _client
        .from('incidents')
        .select('''
          id,
          status,
          description,
          created_at,
          emergency_types(name)
        ''')
        .eq('student_id', student['id'])
        .order('created_at', ascending: false);

    return rows.map(StudentIncident.fromJson).toList();
  }
}
