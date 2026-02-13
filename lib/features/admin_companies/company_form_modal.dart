import 'dart:async';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../config/app_config.dart';
import '../../core/portal_theme.dart';
import '../../data/remote/graphql_client.dart';
import '../../data/remote/ops_api_queries.dart';
import '../../auth/auth_service.dart';
import 'models/admin_company.dart';

/// Modal to add or edit an admin company. Layout aligned with design/portal/admin-companies.html.
class CompanyFormModal extends StatefulWidget {
  const CompanyFormModal({
    super.key,
    required this.company,
    required this.config,
    required this.authService,
    required this.onSaved,
  });

  final AdminCompany? company;
  final AppConfig config;
  final AuthService authService;
  final VoidCallback onSaved;

  @override
  State<CompanyFormModal> createState() => _CompanyFormModalState();
}

class _CompanyFormModalState extends State<CompanyFormModal> {
  final _formKey = GlobalKey<FormState>();
  final _legalNameController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _addressController = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.company != null) {
      _legalNameController.text = widget.company!.legalName;
      _contactEmailController.text = widget.company!.contactEmail;
      _addressController.text = widget.company!.address ?? '';
    }
  }

  @override
  void dispose() {
    _legalNameController.dispose();
    _contactEmailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<String?> _getToken() async {
    try {
      final session = await widget.authService.fetchAuthSession();
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

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final endpoint = widget.config.graphqlEndpoint ?? widget.config.apiBaseUrl;
    if (endpoint == null || endpoint.isEmpty) {
      setState(() {
        _saving = false;
        _error = 'API URL not configured';
      });
      return;
    }
    try {
      final client = createGraphQLClient(endpoint, _getToken);
      if (widget.company == null) {
        final result = await client.mutate(MutationOptions(
          document: gql(createAdminCompanyMutation),
          variables: {
            'input': {
              'legalName': _legalNameController.text.trim(),
              'contactEmail': _contactEmailController.text.trim(),
              'address': _addressController.text.trim().isEmpty
                  ? null
                  : _addressController.text.trim(),
            },
          },
        ));
        if (result.hasException) {
          setState(() {
            _error = result.exception.toString();
            _saving = false;
          });
          return;
        }
      } else {
        final result = await client.mutate(MutationOptions(
          document: gql(updateAdminCompanyMutation),
          variables: {
            'id': widget.company!.id,
            'input': {
              'legalName': _legalNameController.text.trim(),
              'contactEmail': _contactEmailController.text.trim(),
              'address': _addressController.text.trim().isEmpty
                  ? null
                  : _addressController.text.trim(),
            },
          },
        ));
        if (result.hasException) {
          setState(() {
            _error = result.exception.toString();
            _saving = false;
          });
          return;
        }
      }
      if (mounted) {
        widget.onSaved();
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _saving = false;
        });
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.company != null;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(PortalTheme.spacing4),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 0.9 * 600),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(PortalTheme.radiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context, isEdit),
            Flexible(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(PortalTheme.spacing6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_error != null) ...[
                          Padding(
                            padding: const EdgeInsets.only(bottom: PortalTheme.spacing3),
                            child: Text(
                              _error!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: PortalTheme.fontSizeSm,
                              ),
                            ),
                          ),
                        ],
                        _formGroup(
                          label: 'Legal name *',
                          child: TextFormField(
                            controller: _legalNameController,
                            decoration: const InputDecoration(
                              hintText: 'e.g. Acme Estates Ltd',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: PortalTheme.spacing4,
                                vertical: PortalTheme.spacing3,
                              ),
                            ),
                            textCapitalization: TextCapitalization.words,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Required';
                              return null;
                            },
                          ),
                        ),
                        _formGroup(
                          label: 'Contact email *',
                          child: TextFormField(
                            controller: _contactEmailController,
                            decoration: const InputDecoration(
                              hintText: 'admin@company.example',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: PortalTheme.spacing4,
                                vertical: PortalTheme.spacing3,
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Required';
                              return null;
                            },
                          ),
                        ),
                        _formGroup(
                          label: 'Address (optional)',
                          child: TextFormField(
                            controller: _addressController,
                            decoration: const InputDecoration(
                              hintText: 'Street, city, post code',
                              border: OutlineInputBorder(),
                              alignLabelWithHint: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: PortalTheme.spacing4,
                                vertical: PortalTheme.spacing3,
                              ),
                            ),
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isEdit) {
    return Container(
      padding: const EdgeInsets.all(PortalTheme.spacing6),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: PortalTheme.gray200)),
      ),
      child: Row(
        children: [
          Text(
            isEdit ? 'Edit company' : 'Add company',
            style: const TextStyle(
              fontSize: PortalTheme.fontSizeXl,
              fontWeight: FontWeight.w600,
              color: PortalTheme.gray900,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Text('×', style: TextStyle(fontSize: 24, height: 1)),
            onPressed: () => Navigator.of(context).pop(),
            style: IconButton.styleFrom(
              foregroundColor: PortalTheme.gray500,
              padding: const EdgeInsets.all(PortalTheme.spacing2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _formGroup({required String label, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: PortalTheme.spacing6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: PortalTheme.fontSizeSm,
              fontWeight: FontWeight.w500,
              color: PortalTheme.gray700,
            ),
          ),
          const SizedBox(height: PortalTheme.spacing2),
          child,
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PortalTheme.spacing6),
      decoration: const BoxDecoration(
        color: PortalTheme.gray50,
        border: Border(top: BorderSide(color: PortalTheme.gray200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: _saving ? null : () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: PortalTheme.gray700,
            ),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: PortalTheme.spacing3),
          FilledButton(
            onPressed: _saving ? null : _save,
            style: FilledButton.styleFrom(
              backgroundColor: PortalTheme.primary500,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: PortalTheme.spacing6,
                vertical: PortalTheme.spacing3,
              ),
            ),
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Save company'),
          ),
        ],
      ),
    );
  }
}
