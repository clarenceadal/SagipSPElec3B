import 'package:flutter/material.dart';

import '../../../core/utils/validators.dart';
import '../services/auth_service.dart';
import '../viewmodels/login_view_model.dart';
import 'forgot_password_view.dart';
import 'registration_view.dart';
import 'widgets/auth_error_banner.dart';
import 'widgets/auth_scaffold.dart';

class LoginView extends StatefulWidget {
  const LoginView({required this.authService, super.key});

  final AuthService authService;

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final LoginViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = LoginViewModel(widget.authService);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    await _viewModel.signIn(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  void _openRegistration() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RegistrationView(authService: widget.authService),
      ),
    );
  }

  void _openForgotPassword() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ForgotPasswordView(authService: widget.authService),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Login',
      portalLabel: 'Emergency Response System',
      subtitle: 'Sign in to access SAGIP.',
      child: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          return Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthErrorBanner(message: _viewModel.errorMessage),
                TextFormField(
                  controller: _emailController,
                  enabled: !_viewModel.isLoading,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(
                    labelText: 'Email address',
                    hintText: 'Enter your email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  enabled: !_viewModel.isLoading,
                  obscureText: _viewModel.obscurePassword,
                  autofillHints: const [AutofillHints.password],
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: _viewModel.togglePasswordVisibility,
                      icon: Icon(
                        _viewModel.obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  validator: (value) => Validators.required(value, 'Password'),
                  onFieldSubmitted: (_) => _submit(),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _viewModel.isLoading
                        ? null
                        : _openForgotPassword,
                    child: const Text('Forgot password?'),
                  ),
                ),
                FilledButton(
                  onPressed: _viewModel.isLoading ? null : _submit,
                  child: _viewModel.isLoading
                      ? const SizedBox.square(
                          dimension: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('LOGIN'),
                ),
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: _viewModel.isLoading ? null : _openRegistration,
                      child: const Text('Register here'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
