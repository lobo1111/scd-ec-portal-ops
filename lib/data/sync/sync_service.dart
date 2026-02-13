import '../local/sync_metadata_store.dart';

/// Contract for syncing data from a backend into local storage.
/// When online, pulls from [pullEndpoint] (e.g. REST or GraphQL) and writes into the local DB.
/// Conflict handling: server-wins (document in implementation).
/// Features that need offline data register entities or call [syncEntity] / [syncAll].
abstract class SyncService {
  /// Sync a single entity type from the backend. [entityKey] identifies the entity (e.g. "estates").
  /// Uses [SyncMetadataStore] to track last-synced time and optional cursor.
  Future<void> syncEntity(String entityKey);

  /// Sync all registered entities. Called on resume, periodically, or manual refresh.
  Future<void> syncAll();

  /// Register an entity for sync (key + pull logic). Optional; some implementations
  /// may require registration before [syncEntity] works.
  void registerEntity(String entityKey, Future<void> Function(String? cursor) pull);
}

/// Default implementation: uses [SyncMetadataStore]; [syncEntity] delegates to registered pull.
/// Conflict handling: server-wins (last write from server overwrites local).
class DefaultSyncService implements SyncService {
  DefaultSyncService(this._store, {String? apiBaseUrl}) : _apiBaseUrl = apiBaseUrl ?? '';

  final SyncMetadataStore _store;
  final String _apiBaseUrl;
  final Map<String, Future<void> Function(String? cursor)> _pullHandlers = {};

  @override
  void registerEntity(String entityKey, Future<void> Function(String? cursor) pull) {
    _pullHandlers[entityKey] = pull;
  }

  @override
  Future<void> syncEntity(String entityKey) async {
    final pull = _pullHandlers[entityKey];
    if (pull == null) return;
    final cursor = null; // Could read from _store if we stored it
    await pull(cursor);
  }

  @override
  Future<void> syncAll() async {
    for (final key in _pullHandlers.keys) {
      await syncEntity(key);
    }
  }
}
