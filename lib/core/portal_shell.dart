import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_service.dart';
import '../features/_registry.dart';
import '../features/feature_descriptor.dart';
import 'portal_theme.dart';

/// Shell layout matching design/portal: topbar, sidebar, content with breadcrumbs.
class PortalShell extends StatefulWidget {
  const PortalShell({
    super.key,
    required this.authService,
    required this.currentPath,
    required this.child,
  });

  final AuthService authService;
  final String currentPath;
  final Widget child;

  @override
  State<PortalShell> createState() => _PortalShellState();
}

class _PortalShellState extends State<PortalShell> {
  List<FeatureDescriptor> get _navFeatures => featureDescriptors
      .where((f) => f.navLabel != null && f.navPath != null)
      .toList();

  String get _breadcrumbLabel {
    if (widget.currentPath == '/' || widget.currentPath.isEmpty) return 'Dashboard';
    for (final f in _navFeatures) {
      if (f.navPath == widget.currentPath) return f.navLabel!;
    }
    if (widget.currentPath.contains('admin/companies')) return 'Admin companies';
    return 'Page';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PortalTheme.gray50,
      body: Column(
        children: [
          _buildTopbar(context),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSidebar(context),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildBreadcrumbs(context),
                      Expanded(child: widget.child),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopbar(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: PortalTheme.spacing6),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: PortalTheme.gray200)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.go('/'),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.account_balance_outlined, size: 28, color: PortalTheme.gray900),
                SizedBox(width: PortalTheme.spacing4),
                Text(
                  'Operators Portal',
                  style: TextStyle(
                    fontSize: PortalTheme.fontSizeXl,
                    fontWeight: FontWeight.w600,
                    color: PortalTheme.gray900,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          _buildProfileTrigger(context),
        ],
      ),
    );
  }

  Widget _buildProfileTrigger(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 44),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PortalTheme.radiusMd)),
      onSelected: (value) async {
        if (value == 'logout') {
          await widget.authService.signOut();
          if (context.mounted) context.go('/');
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'logout', child: Text('Log out')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: PortalTheme.spacing3, vertical: PortalTheme.spacing2),
        decoration: BoxDecoration(
          border: Border.all(color: PortalTheme.gray200),
          borderRadius: BorderRadius.circular(PortalTheme.radiusLg),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: PortalTheme.primary100,
              child: Text(
                'O',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: PortalTheme.fontSizeSm,
                  color: PortalTheme.primary700,
                ),
              ),
            ),
            const SizedBox(width: PortalTheme.spacing2),
            Text(
              'Profile',
              style: TextStyle(fontSize: PortalTheme.fontSizeSm, color: PortalTheme.gray700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 224, // 14rem
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: PortalTheme.gray200)),
      ),
      child: ListView(
        padding: const EdgeInsets.all(PortalTheme.spacing2),
        children: _navFeatures.map((f) {
          final isActive = f.navPath == widget.currentPath;
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Material(
              color: isActive ? PortalTheme.primary100 : Colors.transparent,
              borderRadius: BorderRadius.circular(PortalTheme.radiusMd),
              child: InkWell(
                onTap: () => context.go(f.navPath!),
                borderRadius: BorderRadius.circular(PortalTheme.radiusMd),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: PortalTheme.spacing3, vertical: PortalTheme.spacing3),
                  child: Row(
                    children: [
                      Icon(
                        f.navPath == '/' ? Icons.dashboard_outlined : Icons.business_outlined,
                        size: 20,
                        color: isActive ? PortalTheme.primary700 : PortalTheme.gray700,
                      ),
                      const SizedBox(width: PortalTheme.spacing3),
                      Text(
                        f.navLabel!,
                        style: TextStyle(
                          fontSize: PortalTheme.fontSizeSm,
                          fontWeight: FontWeight.w500,
                          color: isActive ? PortalTheme.primary700 : PortalTheme.gray700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBreadcrumbs(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: PortalTheme.spacing6, vertical: PortalTheme.spacing2),
      decoration: const BoxDecoration(
        color: PortalTheme.gray50,
        border: Border(bottom: BorderSide(color: PortalTheme.gray200)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.go('/'),
            child: Text(
              'Home',
              style: TextStyle(fontSize: PortalTheme.fontSizeSm, color: PortalTheme.gray600),
            ),
          ),
          Text(
            ' / ',
            style: TextStyle(fontSize: PortalTheme.fontSizeSm, color: PortalTheme.gray400),
          ),
          Text(
            _breadcrumbLabel,
            style: TextStyle(
              fontSize: PortalTheme.fontSizeSm,
              fontWeight: FontWeight.w500,
              color: PortalTheme.gray900,
            ),
          ),
        ],
      ),
    );
  }
}
