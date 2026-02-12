/// Simple store for last-sync timestamp per entity.
/// Used by [SyncService]. Can be replaced with a Drift-backed store
/// (run `dart run build_runner build` and add AppDatabase).
abstract class SyncMetadataStore {
  Future<DateTime?> getLastSync(String entityKey);
  Future<void> setLastSync(String entityKey, DateTime at, {String? cursor});
}

/// In-memory implementation. For persistence, use a Drift database or shared_preferences.
class InMemorySyncMetadataStore implements SyncMetadataStore {
  final Map<String, ({DateTime at, String? cursor})> _store = {};

  @override
  Future<DateTime?> getLastSync(String entityKey) async => _store[entityKey]?.at;

  @override
  Future<void> setLastSync(String entityKey, DateTime at, {String? cursor}) async {
    _store[entityKey] = (at: at, cursor: cursor);
  }
}
