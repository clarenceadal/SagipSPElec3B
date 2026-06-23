import 'package:flutter/material.dart';

import '../features/auth/services/auth_service.dart';
import '../features/auth/viewmodels/session_view_model.dart';
import '../features/auth/views/session_gate.dart';
import '../features/sos/services/incident_service.dart';
import 'theme.dart';

class SagipApp extends StatefulWidget {
  const SagipApp({
    required this.authService,
    required this.incidentService,
    super.key,
  });

  final AuthService authService;
  final IncidentService incidentService;

  @override
  State<SagipApp> createState() => _SagipAppState();
}

class _SagipAppState extends State<SagipApp> {
  late final SessionViewModel _sessionViewModel;

  @override
  void initState() {
    super.initState();
    _sessionViewModel = SessionViewModel(widget.authService);
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
        viewModel: _sessionViewModel,
      ),
    );
  }
}
