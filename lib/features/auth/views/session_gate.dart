import 'package:flutter/material.dart';

import '../../admin/views/ssd_dashboard_view.dart';
import '../../broadcast/services/broadcast_service.dart';
import '../../dashboard/views/student_dashboard_view.dart';
import '../../profile/services/student_profile_service.dart';
import '../../sos/services/incident_service.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../viewmodels/session_view_model.dart';
import 'login_view.dart';
import 'reset_password_view.dart';

class SessionGate extends StatelessWidget {
  const SessionGate({
    required this.authService,
    required this.incidentService,
    required this.studentProfileService,
    required this.broadcastService,
    required this.viewModel,
    super.key,
  });

  final AuthService authService;
  final IncidentService incidentService;
  final StudentProfileService studentProfileService;
  final BroadcastService broadcastService;
  final SessionViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return switch (viewModel.status) {
          SessionStatus.loading => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          SessionStatus.signedOut => LoginView(authService: authService),
          SessionStatus.authenticated =>
            viewModel.user!.role == UserRole.student
                  ? StudentDashboardView(
                      user: viewModel.user!,
                      incidentService: incidentService,
                      studentProfileService: studentProfileService,
                      broadcastService: broadcastService,
                      onSignOut: viewModel.signOut,
                    )
                : SsdDashboardView(
                    user: viewModel.user!,
                    incidentService: incidentService,
                    broadcastService: broadcastService,
                    onSignOut: viewModel.signOut,
                  ),
          SessionStatus.passwordRecovery => ResetPasswordView(
            authService: authService,
            onCompleted: viewModel.completePasswordRecovery,
          ),
          SessionStatus.error => _SessionErrorView(
            message: viewModel.errorMessage,
            onRetry: viewModel.refresh,
            onSignOut: viewModel.signOut,
          ),
        };
      },
    );
  }
}

class _SessionErrorView extends StatelessWidget {
  const _SessionErrorView({
    required this.message,
    required this.onRetry,
    required this.onSignOut,
  });

  final String? message;
  final VoidCallback onRetry;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              Text(message ?? 'The session could not be loaded.'),
              const SizedBox(height: 16),
              FilledButton(onPressed: onRetry, child: const Text('Try again')),
              TextButton(onPressed: onSignOut, child: const Text('Sign out')),
            ],
          ),
        ),
      ),
    );
  }
}
