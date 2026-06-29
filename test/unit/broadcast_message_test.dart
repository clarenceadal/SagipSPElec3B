import 'package:flutter_test/flutter_test.dart';
import 'package:sagip/features/broadcast/models/broadcast_message.dart';

void main() {
  group('BroadcastMessage', () {
    test('parses broadcast JSON from Supabase', () {
      final broadcast = BroadcastMessage.fromJson({
        'id': 'broadcast-id',
        'title': 'No Classes',
        'message': 'Classes are cancelled today.',
        'created_at': '2026-06-29T08:30:00.000Z',
      });

      expect(broadcast.id, 'broadcast-id');
      expect(broadcast.title, 'No Classes');
      expect(broadcast.message, 'Classes are cancelled today.');
      expect(broadcast.createdAt.year, 2026);
    });
  });
}
