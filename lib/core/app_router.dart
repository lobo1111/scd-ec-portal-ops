import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_service.dart';
import '../config/app_config.dart';
import '../features/_registry.dart';
import '../features/callback/callback_screen.dart';

GoRouter createAppRouter(AppConfig config, AuthService authService) {
  final callbackRoute = GoRoute(
    path: '/callback',
    builder: (context, state) => CallbackScreen(config: config, authService: authService),
  );
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final isCallback = state.matchedLocation == '/callback';
      if (isCallback) return null;
      try {
        final user = await authService.getCurrentUser();
        if (user != null) return null;
      } catch (_) {}
      await authService.signInWithWebUI();
      return null;
    },
    routes: [
      ...featureDescriptors.expand((f) => f.routes),
      callbackRoute,
    ],
  );
}
