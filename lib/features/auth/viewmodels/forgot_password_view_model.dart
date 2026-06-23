import '../services/auth_service.dart';
import 'auth_form_view_model.dart';

class ForgotPasswordViewModel extends AuthFormViewModel {
  ForgotPasswordViewModel(this._authService);

  final AuthService _authService;
  bool _emailSent = false;

  bool get emailSent => _emailSent;

  Future<bool> sendResetLink(String email) {
    return run(() async {
      await _authService.sendPasswordReset(email);
      _emailSent = true;
    });
  }
}
