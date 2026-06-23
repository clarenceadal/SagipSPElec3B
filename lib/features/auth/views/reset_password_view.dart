import 'package:flutter/material.dart';

import '../../../core/utils/validators.dart';
import '../services/auth_service.dart';
import '../viewmodels/reset_password_view_model.dart';
import 'widgets/auth_error_banner.dart';
import 'widgets/auth_scaffold.dart';

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({
    required this.authService,
    required this.onCompleted,
    super.key,
  });

  final AuthService authService;
  final VoidCallback onCompleted;

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();
  late final ResetPasswordViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ResetPasswordViewModel(widget.authService);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmationController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await _viewModel.updatePassword(_passwordController.text);
    if (!mounted || !success) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password updated successfully.')),
    );
    widget.onCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Choose a new password',
      subtitle: 'Use at least eight characters for your new password.',
      showBackButton: true,
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
                  controller: _passwordController,
                  enabled: !_viewModel.isLoading,
                  obscureText: _viewModel.obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'New password',
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
                  validator: Validators.password,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmationController,
                  enabled: !_viewModel.isLoading,
                  obscureText: _viewModel.obscureConfirmation,
                  decoration: InputDecoration(
                    labelText: 'Confirm new password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: _viewModel.toggleConfirmationVisibility,
                      icon: Icon(
                        _viewModel.obscureConfirmation
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Passwords do not match.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _viewModel.isLoading ? null : _submit,
                  child: _viewModel.isLoading
                      ? const SizedBox.square(
                          dimension: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('UPDATE PASSWORD'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
