import 'package:flutter/material.dart';

import '../features/auth/services/auth_service.dart';
import '../features/auth/viewmodels/session_view_model.dart';
import '../features/auth/views/session_gate.dart';
import '../features/broadcast/services/broadcast_service.dart';
import '../features/profile/services/student_profile_service.dart';
import '../features/sos/services/incident_service.dart';
import 'theme.dart';

class SagipApp extends StatefulWidget {
  const SagipApp({
    required this.authService,
    required this.incidentService,
    required this.studentProfileService,
    required this.broadcastService,
    this.startedFromPasswordRecovery = false,
    super.key,
  });

  final AuthService authService;
  final IncidentService incidentService;
  final StudentProfileService studentProfileService;
  final BroadcastService broadcastService;
  final bool startedFromPasswordRecovery;

  @override
  State<SagipApp> createState() => _SagipAppState();
}

class _SagipAppState extends State<SagipApp> {
  late final SessionViewModel _sessionViewModel;

  @override
  void initState() {
    super.initState();
    _sessionViewModel = SessionViewModel(
      widget.authService,
      startsInPasswordRecovery: widget.startedFromPasswordRecovery,
    );
  }

  @override
  void dispose() {
    _sessionViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SAGIP',
      theme: SagipTheme.light,
      home: SessionGate(
        authService: widget.authService,
        incidentService: widget.incidentService,
        studentProfileService: widget.studentProfileService,
        broadcastService: widget.broadcastService,
        viewModel: _sessionViewModel,
      ),
    );
  }
}
