import '../services/auth_service.dart';
import 'auth_form_view_model.dart';

class LoginViewModel extends AuthFormViewModel {
  LoginViewModel(this._authService);

  final AuthService _authService;
  bool _obscurePassword = true;

  bool get obscurePassword => _obscurePassword;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  Future<bool> signIn({required String email, required String password}) {
    return run(() async {
      await _authService.signIn(email: email, password: password);
    });
  }
}
