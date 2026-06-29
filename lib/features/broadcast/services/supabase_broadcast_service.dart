import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/broadcast_message.dart';
import 'broadcast_service.dart';

class SupabaseBroadcastService implements BroadcastService {
  SupabaseBroadcastService(this._client);

  final SupabaseClient _client;

  @override
  Future<List<BroadcastMessage>> getRecentBroadcasts() async {
    final rows = await _client
        .from('broadcasts')
        .select('id, title, message, created_at')
        .order('created_at', ascending: false)
        .limit(10);

    return rows.map(BroadcastMessage.fromJson).toList();
  }

  @override
  Future<BroadcastMessage?> getLatestBroadcast() async {
    final row = await _client
        .from('broadcasts')
        .select('id, title, message, created_at')
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (row == null) return null;
    return BroadcastMessage.fromJson(row);
  }

  @override
  Future<void> createBroadcast({
    required String title,
    required String message,
  }) async {
    await _client.from('broadcasts').insert({
      'title': title.trim(),
      'message': message.trim(),
      'created_by': _client.auth.currentUser?.id,
    });
  }
}
