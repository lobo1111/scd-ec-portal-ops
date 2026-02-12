import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';

/// Configures Amplify Auth from [AppConfig]. Call once at startup after config is loaded.
/// Uses Hosted UI (OAuth) flow; no Identity Pool (User Pool only).
Future<void> configureAmplifyAuth(AppConfig config) async {
  final signInRedirectUri = _signInRedirectUri(config);
  final signOutRedirectUri = _signOutRedirectUri(config);

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
                'WebDomain': config.cognitoHostedUiDomain,
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

/// Web: use current origin + /callback. Mobile: use portalUrl + /callback or custom scheme from config.
String _signInRedirectUri(AppConfig config) {
  if (kIsWeb) {
    final base = Uri.base;
    return base.resolveUri(Uri(path: 'callback')).toString();
  }
  if (config.portalUrl != null && config.portalUrl!.isNotEmpty) {
    final uri = Uri.parse(config.portalUrl!);
    return '${uri.origin}/callback';
  }
  return 'fluttemplate://callback';
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
