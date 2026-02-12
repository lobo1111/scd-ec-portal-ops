import 'dart:convert';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';

/// Configures Amplify Auth from [AppConfig]. Call once at startup after config is loaded.
/// Uses Hosted UI (OAuth) flow; no Identity Pool (User Pool only).
Future<void> configureAmplifyAuth(AppConfig config) async {
  final signInRedirectUri = _signInRedirectUri(config);
  final signOutRedirectUri = _signOutRedirectUri(config);
  // WebDomain must be a full URL (https://host) so the SDK builds the correct authorize URL.
  final webDomain = _normalizeWebDomain(config.cognitoHostedUiDomain);

  final configMap = {
    'UserAgent': 'aws-amplify-cli/2.0',
    'Version': '1.0',
    'auth': {
      'plugins': {
        'awsCognitoAuthPlugin': {
          'IdentityManager': {'Default': {}},
          'CognitoUserPool': {
            'Default': {
              'PoolId': config.userPoolId,
              'AppClientId': config.userPoolClientId,
              'Region': config.region,
            },
          },
          'Auth': {
            'Default': {
              'authenticationFlowType': 'USER_SRP_AUTH',
              'OAuth': {
                'WebDomain': webDomain,
                'AppClientId': config.userPoolClientId,
                'SignInRedirectURI': signInRedirectUri,
                'SignOutRedirectURI': signOutRedirectUri,
                'Scopes': [
                  'openid',
                  'email',
                  'profile',
                ],
              },
            },
          },
        },
      },
    },
  };

  final configString = jsonEncode(configMap);
  await Amplify.addPlugin(AmplifyAuthCognito());
  await Amplify.configure(configString);
}

/// Ensures WebDomain is a full URL. Amplify/Cognito expect e.g. https://host.
String _normalizeWebDomain(String cognitoHostedUiDomain) {
  final s = cognitoHostedUiDomain.trim();
  if (s.isEmpty) return s;
  if (s.startsWith('https://') || s.startsWith('http://')) return s;
  return 'https://$s';
}

/// Web: use current origin + / (root as callback; query params stripped after exchange). Mobile: use portalUrl + / or custom scheme.
String _signInRedirectUri(AppConfig config) {
  if (kIsWeb) {
    final origin = Uri.base.origin;
    return origin.endsWith('/') ? origin : '$origin/';
  }
  if (config.portalUrl != null && config.portalUrl!.isNotEmpty) {
    final uri = Uri.parse(config.portalUrl!);
    return '${uri.origin}/';
  }
  return 'fluttemplate://';
}

String _signOutRedirectUri(AppConfig config) {
  if (kIsWeb) {
    final base = Uri.base;
    return base.origin + (base.path.isEmpty ? '/' : base.path);
  }
  if (config.portalUrl != null && config.portalUrl!.isNotEmpty) {
    final uri = Uri.parse(config.portalUrl!);
    return uri.origin;
  }
  return 'fluttemplate://';
}
