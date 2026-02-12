import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_service.dart';
import '../auth/amplify_config.dart';
import '../config/app_config.dart';
import '../config/load_config.dart';

/// Holds config and AuthService after Amplify is configured.
class AppSetup {
  const AppSetup({required this.config, required this.authService});
  final AppConfig config;
  final AuthService authService;
}

/// Loads config, configures Amplify Auth, then returns [AppSetup].
/// Watch this before building the router so auth is ready.
final setupProvider = FutureProvider<AppSetup>((ref) async {
  final config = await ref.watch(appConfigProvider.future);
  await configureAmplifyAuth(config);
  return AppSetup(config: config, authService: AuthService());
});
