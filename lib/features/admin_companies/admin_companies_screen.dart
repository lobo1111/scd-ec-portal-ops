import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/portal_theme.dart';
import '../../core/setup_provider.dart';
import '../../data/sync/sync_provider.dart';
import 'company_form_modal.dart';
import 'data/admin_companies_providers.dart';
import 'models/admin_company.dart';

/// Admin companies list: toolbar (search + Add company), table or empty state.
/// Layout and styling aligned with design/portal/admin-companies.html.
class AdminCompaniesScreen extends ConsumerStatefulWidget {
  const AdminCompaniesScreen({super.key});

  @override
  ConsumerState<AdminCompaniesScreen> createState() =>
      _AdminCompaniesScreenState();
}

class _AdminCompaniesScreenState extends ConsumerState<AdminCompaniesScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(syncServiceProvider.future).then((s) => s?.syncEntity('admin_companies'));
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AdminCompany> _filter(List<AdminCompany> items) {
    if (_searchQuery.trim().isEmpty) return items;
    final q = _searchQuery.trim().toLowerCase();
    return items
        .where((c) =>
            c.legalName.toLowerCase().contains(q) ||
            c.contactEmail.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final setupAsync = ref.watch(setupProvider);
    final store = ref.watch(adminCompaniesStoreProvider);
    final items = _filter(store.items);

    return setupAsync.when(
      data: (setup) => _buildContent(context, ref, setup, items),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Error loading setup')),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    AppSetup setup,
    List<AdminCompany> items,
  ) {
    final syncAsync = ref.watch(syncServiceProvider);
    final canSync = syncAsync.valueOrNull != null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth.clamp(0.0, 672.0); // max-width-2xl
        return SingleChildScrollView(
          padding: const EdgeInsets.all(PortalTheme.spacing6),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildToolbar(context, ref, setup, canSync),
                const SizedBox(height: PortalTheme.spacing6),
                items.isEmpty
                    ? _buildEmptyState(context, ref, setup)
                    : _buildTableWrap(context, ref, items),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildToolbar(
    BuildContext context,
    WidgetRef ref,
    AppSetup setup,
    bool canSync,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 320,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by name or email…',
              hintStyle: TextStyle(color: PortalTheme.gray400, fontSize: PortalTheme.fontSizeBase),
              prefixIcon: Icon(Icons.search, size: 20, color: PortalTheme.gray400),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(PortalTheme.radiusMd),
                borderSide: const BorderSide(color: PortalTheme.gray200),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: PortalTheme.spacing4,
                vertical: PortalTheme.spacing3,
              ),
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
        ),
        const SizedBox(width: PortalTheme.spacing4),
        if (canSync)
          IconButton(
            icon: const Icon(Icons.refresh, size: 22),
            tooltip: 'Refresh',
            onPressed: () async {
              await ref.read(syncServiceProvider.future).then((s) => s?.syncEntity('admin_companies'));
            },
          ),
        const SizedBox(width: PortalTheme.spacing2),
        FilledButton.icon(
          onPressed: () => _openAddCompany(context, ref, setup),
          icon: const Icon(Icons.add, size: 20),
          label: const Text('Add company'),
          style: FilledButton.styleFrom(
            backgroundColor: PortalTheme.primary500,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: PortalTheme.spacing6,
              vertical: PortalTheme.spacing3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableWrap(
    BuildContext context,
    WidgetRef ref,
    List<AdminCompany> items,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: PortalTheme.gray200),
        borderRadius: BorderRadius.circular(PortalTheme.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(PortalTheme.radiusLg),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(PortalTheme.gray50),
              columns: [
                DataColumn(
                  label: Text(
                    'Legal name',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: PortalTheme.gray700,
                      fontSize: PortalTheme.fontSizeSm,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Contact email',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: PortalTheme.gray700,
                      fontSize: PortalTheme.fontSizeSm,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Communities',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: PortalTheme.gray700,
                      fontSize: PortalTheme.fontSizeSm,
                    ),
                  ),
                  numeric: true,
                ),
                DataColumn(
                  label: Text(
                    'Admin users',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: PortalTheme.gray700,
                      fontSize: PortalTheme.fontSizeSm,
                    ),
                  ),
                  numeric: true,
                ),
                const DataColumn(label: Text('Actions')),
              ],
              headingTextStyle: TextStyle(
                fontWeight: FontWeight.w600,
                color: PortalTheme.gray700,
                fontSize: PortalTheme.fontSizeSm,
              ),
              dataRowMinHeight: 48,
              dataRowMaxHeight: 56,
              columnSpacing: 24,
              horizontalMargin: 24,
              rows: items.map((c) => DataRow(
                cells: [
                  DataCell(Text(
                    c.legalName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: PortalTheme.gray900,
                      fontSize: PortalTheme.fontSizeSm,
                    ),
                  )),
                  DataCell(Text(
                    c.contactEmail,
                    style: const TextStyle(
                      color: PortalTheme.gray600,
                      fontSize: PortalTheme.fontSizeSm,
                    ),
                  )),
                  DataCell(Center(
                    child: Text(
                      '${c.communityCount}',
                      style: const TextStyle(
                        color: PortalTheme.gray500,
                        fontSize: PortalTheme.fontSizeSm,
                      ),
                    ),
                  )),
                  DataCell(Center(
                    child: Text(
                      '${c.adminUserCount}',
                      style: const TextStyle(
                        color: PortalTheme.gray500,
                        fontSize: PortalTheme.fontSizeSm,
                      ),
                    ),
                  )),
                  DataCell(TextButton(
                    onPressed: () => _openEditCompany(context, ref, c),
                    style: TextButton.styleFrom(
                      foregroundColor: PortalTheme.gray700,
                      padding: const EdgeInsets.symmetric(
                        horizontal: PortalTheme.spacing4,
                        vertical: PortalTheme.spacing2,
                      ),
                    ),
                    child: const Text('Show details', style: TextStyle(fontSize: PortalTheme.fontSizeSm)),
                  )),
                ],
              )).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref, AppSetup setup) {
    return Container(
      padding: const EdgeInsets.all(PortalTheme.spacing12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: PortalTheme.gray200),
        borderRadius: BorderRadius.circular(PortalTheme.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No admin companies yet',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: PortalTheme.gray700,
                fontSize: PortalTheme.fontSizeBase,
              ),
            ),
            const SizedBox(height: PortalTheme.spacing4),
            Text(
              'Add a company to get started. Operators can then assign communities and admin users to it.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: PortalTheme.gray500,
                fontSize: PortalTheme.fontSizeSm,
              ),
            ),
            const SizedBox(height: PortalTheme.spacing6),
            FilledButton.icon(
              onPressed: () => _openAddCompany(context, ref, setup),
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Add company'),
              style: FilledButton.styleFrom(
                backgroundColor: PortalTheme.primary500,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: PortalTheme.spacing6,
                  vertical: PortalTheme.spacing3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openAddCompany(BuildContext context, WidgetRef ref, AppSetup setup) {
    showDialog<void>(
      context: context,
      builder: (ctx) => CompanyFormModal(
        company: null,
        config: setup.config,
        authService: setup.authService,
        onSaved: () async {
          final sync = await ref.read(syncServiceProvider.future);
          sync?.syncEntity('admin_companies');
        },
      ),
    );
  }

  void _openEditCompany(BuildContext context, WidgetRef ref, AdminCompany c) {
    final setup = ref.read(setupProvider).valueOrNull;
    if (setup == null) return;
    showDialog<void>(
      context: context,
      builder: (ctx) => CompanyFormModal(
        company: c,
        config: setup.config,
        authService: setup.authService,
        onSaved: () async {
          final sync = await ref.read(syncServiceProvider.future);
          sync?.syncEntity('admin_companies');
        },
      ),
    );
  }
}
