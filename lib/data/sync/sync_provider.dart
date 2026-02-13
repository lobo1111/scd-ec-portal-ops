import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../config/app_config.dart';
import '../../core/setup_provider.dart';
import '../local/sync_metadata_store.dart';
import '../remote/graphql_client.dart';
import '../remote/ops_api_queries.dart';
import '../../features/admin_companies/data/admin_companies_providers.dart';
import '../../features/admin_companies/models/admin_company.dart';
import 'sync_service.dart';

/// Builds the global [SyncService] and registers entities (e.g. admin_companies).
/// Depends on [setupProvider] and feature stores. Returns null if API URL is not configured.
final syncServiceProvider = FutureProvider<SyncService?>((ref) async {
  final setup = await ref.watch(setupProvider.future);
  final AppConfig config = setup.config;
  final endpoint = config.graphqlEndpoint ?? config.apiBaseUrl ?? '';
  if (endpoint.isEmpty) return null;

  Future<String?> getToken() async {
    try {
      final session = await setup.authService.fetchAuthSession();
      final tokensResult = (session as dynamic).userPoolTokensResult;
      final tokens = tokensResult?.valueOrNull ?? tokensResult?.value;
      if (tokens != null && tokens.idToken != null) {
        return tokens.idToken.raw;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  final metadataStore = InMemorySyncMetadataStore();
  final sync = DefaultSyncService(metadataStore, apiBaseUrl: endpoint);
  final client = createGraphQLClient(endpoint, getToken);
  final adminCompaniesStore = ref.read(adminCompaniesStoreProvider.notifier);

  sync.registerEntity('admin_companies', (String? cursor) async {
    try {
      final result = await client.query(QueryOptions(
        document: gql(listAdminCompaniesQuery),
        variables: {
          'limit': 100,
          if (cursor != null && cursor.isNotEmpty) 'nextToken': cursor,
        },
      ));
      if (result.hasException) return;
      final data = result.data?['listAdminCompanies'];
      if (data == null) return;
      final list = data['items'] as List<dynamic>?;
      final items = list
              ?.map((e) =>
                  AdminCompany.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [];
      adminCompaniesStore.setItems(items);
      await metadataStore.setLastSync(
        'admin_companies',
        DateTime.now(),
        cursor: data['nextToken'] as String?,
      );
    } catch (_) {
      // Keep existing cache on error
    }
  });

  return sync;
});
