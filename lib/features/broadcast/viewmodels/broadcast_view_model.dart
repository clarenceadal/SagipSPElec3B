import 'package:flutter/foundation.dart';

import '../models/broadcast_message.dart';
import '../services/broadcast_service.dart';

class BroadcastViewModel extends ChangeNotifier {
  BroadcastViewModel(this._broadcastService);

  final BroadcastService _broadcastService;

  bool _isLoading = false;
  bool _isSending = false;
  String? _errorMessage;
  String? _successMessage;
  List<BroadcastMessage> _recentBroadcasts = const [];

  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  List<BroadcastMessage> get recentBroadcasts => _recentBroadcasts;

  Future<void> loadRecentBroadcasts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _recentBroadcasts = await _broadcastService.getRecentBroadcasts();
    } catch (error) {
      _errorMessage = 'Unable to load broadcasts: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendBroadcast({
    required String title,
    required String message,
  }) async {
    _isSending = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _broadcastService.createBroadcast(
        title: title,
        message: message,
      );
      _successMessage = 'Broadcast sent successfully.';
      await loadRecentBroadcasts();
      return true;
    } catch (error) {
      _errorMessage = 'Unable to send broadcast: $error';
      return false;
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }
}
