import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/auth_service.dart';
import '../../core/setup_provider.dart';
import '../_registry.dart';
import '../feature_descriptor.dart';

/// Home/dashboard screen. Header with portal title and profile menu (logout).
/// Lists feature nav links so users can reach Admin companies etc.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static List<FeatureDescriptor> get _navFeatures =>
      featureDescriptors
          .where((f) => f.navLabel != null && f.navPath != null && f.navPath != '/')
          .toList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setupAsync = ref.watch(setupProvider);
    return setupAsync.when(
      data: (setup) => _buildContent(context, ref, setup.authService),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Error loading auth')),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, AuthService authService) {
    final navFeatures = _navFeatures;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Dashboard',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Choose a section below.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            if (navFeatures.isNotEmpty) ...[
              const SizedBox(height: 24),
              ...navFeatures.map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const Icon(Icons.arrow_forward_ios, size: 18),
                      title: Text(f.navLabel!),
                      onTap: () => context.go(f.navPath!),
                      tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}
