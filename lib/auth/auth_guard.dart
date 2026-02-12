import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_service.dart';
import '../core/setup_provider.dart';

/// Wraps [child] and ensures the user is authenticated before showing it.
/// If not authenticated, triggers Hosted UI sign-in (redirect).
/// Use when a subtree should only render when signed in; the global router redirect already guards routes.
class AuthGuard extends ConsumerStatefulWidget {
  const AuthGuard({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends ConsumerState<AuthGuard> {
  bool _checked = false;

  @override
  Widget build(BuildContext context) {
    final setupAsync = ref.watch(setupProvider);
    return setupAsync.when(
      data: (setup) {
        if (_checked) return widget.child;
        return FutureBuilder<bool>(
          future: setup.authService.getCurrentUser().then((u) => u != null),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            if (snapshot.data == true) {
              _checked = true;
              return widget.child;
            }
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              await setup.authService.signInWithWebUI();
            });
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          },
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => widget.child,
    );
  }
}
