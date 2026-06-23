import 'package:flutter/material.dart';

import '../../../core/utils/validators.dart';
import '../services/auth_service.dart';
import '../viewmodels/forgot_password_view_model.dart';
import 'widgets/auth_error_banner.dart';
import 'widgets/auth_scaffold.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({required this.authService, super.key});

  final AuthService authService;

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  late final ForgotPasswordViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ForgotPasswordViewModel(widget.authService);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    await _viewModel.sendResetLink(_emailController.text);
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Reset your password',
      subtitle: 'We will email you a secure password-reset link.',
      showBackButton: true,
      child: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          if (_viewModel.emailSent) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.mark_email_read_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Check your email',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'If an account exists for ${_emailController.text.trim()}, '
                  'a reset link has been sent.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Back to sign in'),
                ),
              ],
            );
          }

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
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: Validators.email,
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _viewModel.isLoading ? null : _submit,
                  child: _viewModel.isLoading
                      ? const SizedBox.square(
                          dimension: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('SEND RESET LINK'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _viewModel.isLoading
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('Back to sign in'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
