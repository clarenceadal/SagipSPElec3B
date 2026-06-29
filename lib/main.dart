import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'core/config/supabase_config.dart';
import 'features/auth/services/supabase_auth_service.dart';
import 'features/broadcast/services/supabase_broadcast_service.dart';
import 'features/profile/services/supabase_student_profile_service.dart';
import 'features/sos/services/supabase_incident_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.publishableKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.implicit,
    ),
  );

  final supabaseClient = Supabase.instance.client;
  final startedFromPasswordRecovery = _startedFromPasswordRecoveryUrl();

  final authService = SupabaseAuthService(supabaseClient);
  final incidentService = SupabaseIncidentService(supabaseClient);
  final studentProfileService = SupabaseStudentProfileService(supabaseClient);
  final broadcastService = SupabaseBroadcastService(supabaseClient);
  runApp(
    SagipApp(
      authService: authService,
      incidentService: incidentService,
      studentProfileService: studentProfileService,
      broadcastService: broadcastService,
      startedFromPasswordRecovery: startedFromPasswordRecovery,
    ),
  );
}

bool _startedFromPasswordRecoveryUrl() {
  final uri = Uri.base;
  final fragmentParameters = Uri.splitQueryString(uri.fragment);

  bool hasAuthParameter(String key) {
    return uri.queryParameters.containsKey(key) ||
        fragmentParameters.containsKey(key);
  }

  final hasSupabaseAuthCallback =
      hasAuthParameter('access_token') ||
      hasAuthParameter('code') ||
      hasAuthParameter('error_description');

  if (!hasSupabaseAuthCallback) return false;

  return uri.queryParameters.containsKey('code') ||
      fragmentParameters['type'] == 'recovery';
}
