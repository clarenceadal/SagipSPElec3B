import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../services/auth_exception_mapper.dart';
import '../services/auth_service.dart';

enum SessionStatus {
  loading,
  signedOut,
  authenticated,
  passwordRecovery,
  error,
}

class SessionViewModel extends ChangeNotifier {
  SessionViewModel(
    this._authService, {
    bool startsInPasswordRecovery = false,
  }) {
    _subscription = _authService.authEvents.listen(_handleAuthEvent);
    if (startsInPasswordRecovery) {
      _status = SessionStatus.passwordRecovery;
    } else {
      refresh();
    }
  }

  final AuthService _authService;
  late final StreamSubscription<AuthSessionEvent> _subscription;

  SessionStatus _status = SessionStatus.loading;
  AppUser? _user;
  String? _errorMessage;

  SessionStatus get status => _status;
  AppUser? get user => _user;
  String? get errorMessage => _errorMessage;

  Future<void> refresh() async {
    if (!_authService.hasSession) {
      _status = SessionStatus.signedOut;
      _user = null;
      notifyListeners();
      return;
    }

    _status = SessionStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _authService.getCurrentUser();
      _status = _user == null
          ? SessionStatus.signedOut
          : SessionStatus.authenticated;
    } catch (error) {
      _errorMessage = AuthExceptionMapper.message(error);
      _status = SessionStatus.error;
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  void completePasswordRecovery() {
    refresh();
  }

  void _handleAuthEvent(AuthSessionEvent event) {
    switch (event) {
      case AuthSessionEvent.passwordRecovery:
        _status = SessionStatus.passwordRecovery;
        notifyListeners();
      case AuthSessionEvent.signedOut:
        _user = null;
        _status = SessionStatus.signedOut;
        notifyListeners();
      case AuthSessionEvent.signedIn:
      case AuthSessionEvent.userUpdated:
      case AuthSessionEvent.initialSession:
        refresh();
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
