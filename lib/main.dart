import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'core/config/supabase_config.dart';
import 'features/auth/services/supabase_auth_service.dart';
import 'features/sos/services/supabase_incident_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.publishableKey,
  );

  final authService = SupabaseAuthService(Supabase.instance.client);
  final incidentService = SupabaseIncidentService(Supabase.instance.client);
  runApp(
    SagipApp(
      authService: authService,
      incidentService: incidentService,
    ),
  );
}
