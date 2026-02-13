import 'package:go_router/go_router.dart';

import '../feature_descriptor.dart';
import 'admin_companies_screen.dart';

final adminCompaniesFeatureDescriptor = FeatureDescriptor(
  name: 'admin_companies',
  routes: [
    GoRoute(
      path: '/admin/companies',
      builder: (context, state) => const AdminCompaniesScreen(),
    ),
  ],
  navLabel: 'Admin companies',
  navPath: '/admin/companies',
);
