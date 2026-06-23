import 'package:supabase_flutter/supabase_flutter.dart';

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
}
