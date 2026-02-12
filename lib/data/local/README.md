# Local data layer

- **SyncMetadataStore**: Tracks last-sync timestamp per entity for the sync service. Default implementation is in-memory; for persistence across restarts, plug in a Drift-backed store or `shared_preferences`.
- **Drift**: For significant offline data and queryable tables, add a Drift database:
  1. Define tables (e.g. in a `.drift` file or Dart `Table` classes).
  2. Create a database class with `part 'app_database.g.dart';` and `@DriftDatabase(tables: [...])`.
  3. Run `dart run build_runner build --delete-conflicting-outputs` to generate the `.g.dart` file.
  4. Use `drift_flutter`’s `driftDatabase()` for mobile (file) and web (null or Wasm setup per drift_flutter docs).

Features that need offline data define their own tables (via Drift migrations) and repositories that read/write the shared DB.
