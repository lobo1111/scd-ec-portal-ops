import 'package:go_router/go_router.dart';

import '../auth/auth_service.dart';
import '../config/app_config.dart';
import '../features/admin_companies/admin_companies_screen.dart';
import '../features/callback/callback_screen.dart';
import '../features/home/home_screen.dart';
import 'portal_shell.dart';

GoRouter createAppRouter(AppConfig config, AuthService authService) {
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
      GoRoute(
        path: '/',
        builder: (context, state) {
          if (state.uri.queryParameters.containsKey('code')) {
            return CallbackScreen(config: config, authService: authService);
          }
          return PortalShell(
            authService: authService,
            currentPath: '/',
            child: const HomeScreen(),
          );
        },
      ),
      GoRoute(
        path: '/admin/companies',
        builder: (context, state) => PortalShell(
          authService: authService,
          currentPath: '/admin/companies',
          child: const AdminCompaniesScreen(),
        ),
      ),
    ],
  );
}
