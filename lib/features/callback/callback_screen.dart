import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../auth/auth_service.dart';
import '../../config/app_config.dart';

/// Handles OAuth redirect from Cognito Hosted UI. Completes code exchange then redirects to /.
class CallbackScreen extends StatelessWidget {
  const CallbackScreen({super.key, required this.config, required this.authService});

  final AppConfig config;
  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!context.mounted) return;
      try {
        await authService.fetchAuthSession();
      } catch (_) {}
      if (context.mounted) context.go('/');
    });
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
