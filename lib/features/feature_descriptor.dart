import 'package:go_router/go_router.dart';

/// Descriptor for a feature that contributes routes (and optionally nav items).
/// Register in [_registry] so the shell builds the router from it.
class FeatureDescriptor {
  const FeatureDescriptor({
    required this.name,
    required this.routes,
    this.navLabel,
    this.navPath,
  });

  final String name;
  final List<RouteBase> routes;
  final String? navLabel;
  final String? navPath;
}
