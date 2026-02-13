import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'admin_companies_store.dart';

/// In-memory store for admin companies. Sync pull updates this; UI reads from here (offline-first).
final adminCompaniesStoreProvider =
    ChangeNotifierProvider<AdminCompaniesStore>((ref) => AdminCompaniesStore());
