import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/app_router.dart';
import 'core/setup_provider.dart';

/// Root app widget. Builds router once config is loaded and Amplify is configured.
class FlutTemplateApp extends ConsumerWidget {
  const FlutTemplateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setupAsync = ref.watch(setupProvider);
    return setupAsync.when(
      data: (setup) {
        return MaterialApp.router(
          title: 'Portal',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF236042)),
            useMaterial3: true,
          ),
          routerConfig: createAppRouter(setup.config, setup.authService),
        );
      },
      loading: () => const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (err, stack) => MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load config or auth',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(err.toString(), textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
