import '../models/broadcast_message.dart';

abstract interface class BroadcastService {
  Future<List<BroadcastMessage>> getRecentBroadcasts();

  Future<BroadcastMessage?> getLatestBroadcast();

  Future<void> createBroadcast({
    required String title,
    required String message,
  });
}
