import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/auth_service.dart';
import '../../core/setup_provider.dart';

/// Home/dashboard screen. Header with portal title and profile menu (logout), aligned with design mocks.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setupAsync = ref.watch(setupProvider);
    return setupAsync.when(
      data: (setup) => _buildContent(context, ref, setup.authService),
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => Scaffold(
        appBar: AppBar(title: const Text('Portal')),
        body: const Center(child: Text('Error loading auth')),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, AuthService authService) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portal'),
        actions: [
          PopupMenuButton<String>(
            icon: const CircleAvatar(child: Text('U')),
            tooltip: 'Profile',
            onSelected: (value) async {
              if (value == 'logout') {
                await authService.signOut();
                if (context.mounted) context.go('/');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'logout', child: Text('Log out')),
            ],
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Dashboard placeholder', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Home content area. Header has logo, portal name, and profile with logout.'),
          ],
        ),
      ),
    );
  }
}
