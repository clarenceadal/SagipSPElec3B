import 'package:flutter/material.dart';

import '../../auth/models/app_user.dart';

class DashboardPlaceholderView extends StatelessWidget {
  const DashboardPlaceholderView({
    required this.user,
    required this.onSignOut,
    super.key,
  });

  final AppUser user;
  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context) {
    final roleName = user.role == UserRole.admin ? 'SSD Admin' : 'Student';

    return Scaffold(
      appBar: AppBar(
        title: const Text('SAGIP'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: onSignOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_user_outlined, size: 64),
              const SizedBox(height: 16),
              Text(
                'Welcome, ${user.fullName}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text('$roleName account authenticated'),
              const SizedBox(height: 8),
              const Text(
                'The dashboard module will be implemented separately.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
