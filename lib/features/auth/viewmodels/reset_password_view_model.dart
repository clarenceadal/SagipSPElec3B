import '../services/auth_service.dart';
import 'auth_form_view_model.dart';

class ResetPasswordViewModel extends AuthFormViewModel {
  ResetPasswordViewModel(this._authService);

  final AuthService _authService;
  bool _obscurePassword = true;
  bool _obscureConfirmation = true;

  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmation => _obscureConfirmation;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleConfirmationVisibility() {
    _obscureConfirmation = !_obscureConfirmation;
    notifyListeners();
  }

  Future<bool> updatePassword(String password) {
    return run(() => _authService.updatePassword(password));
  }
}
