import 'package:go_router/go_router.dart';

import 'feature_descriptor.dart';
import 'home_screen.dart';

final homeFeatureDescriptor = FeatureDescriptor(
  name: 'home',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
  ],
  navLabel: 'Dashboard',
  navPath: '/',
);
