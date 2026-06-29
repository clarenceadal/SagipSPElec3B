import 'package:flutter_test/flutter_test.dart';
import 'package:sagip/features/history/models/student_incident.dart';

void main() {
  group('StudentIncident', () {
    test('parses incident history JSON from Supabase', () {
      final incident = StudentIncident.fromJson({
        'id': 'incident-id',
        'status': 'responding',
        'description': 'Student needs assistance.',
        'created_at': '2026-06-29T09:15:00.000Z',
        'emergency_types': {'name': 'Medical Emergency'},
      });

      expect(incident.id, 'incident-id');
      expect(incident.emergencyType, 'Medical Emergency');
      expect(incident.status, 'responding');
      expect(incident.description, 'Student needs assistance.');
      expect(incident.createdAt.year, 2026);
    });

    test('uses default emergency label when relation is missing', () {
      final incident = StudentIncident.fromJson({
        'id': 'incident-id',
        'created_at': '2026-06-29T09:15:00.000Z',
      });

      expect(incident.emergencyType, 'Emergency Report');
      expect(incident.status, 'pending');
    });
  });
}
