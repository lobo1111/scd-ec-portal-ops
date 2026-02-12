import 'package:go_router/go_router.dart';

import '../auth/auth_service.dart';
import '../config/app_config.dart';
import '../features/_registry.dart';
import '../features/callback/callback_screen.dart';
import '../features/home/home_screen.dart';

GoRouter createAppRouter(AppConfig config, AuthService authService) {
  // Root route: when OAuth returns to /?code=...&state=..., handle exchange then go(/) to strip query.
  final rootRoute = GoRoute(
    path: '/',
    builder: (context, state) {
      if (state.uri.queryParameters.containsKey('code')) {
        return CallbackScreen(config: config, authService: authService);
      }
      return const HomeScreen();
    },
  );
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      if (state.matchedLocation == '/' && state.uri.queryParameters.containsKey('code')) {
        return null;
      }
      try {
        final user = await authService.getCurrentUser();
        if (user != null) return null;
      } catch (_) {}
      await authService.signInWithWebUI();
      return null;
    },
    routes: [
      rootRoute,
      ...featureDescriptors.expand((f) => f.routes),
    ],
  );
}
