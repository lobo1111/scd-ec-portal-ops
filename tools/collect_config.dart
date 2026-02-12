#!/usr/bin/env dart
// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

const _usage = '''
Usage: dart run tools/collect_config.dart --env <env> --variant <variant> [options]

Required:
  --env <name>       Environment (e.g. dev, prod). Must exist in deploy state.
  --variant <name>   Portal variant: ops | admins | users.

Options:
  --scd-repo <path>  Path to scd-echocorner repo (default: ../scd-echocorner).
  --out <path>       Output JSON file (default: web/config.json).
  --all-variants     Emit one file per variant: web/config.<variant>.<env>.json.

Sources (read from scd-repo):
  .deployer/.deploy-state.json  -> environments.<env>.products.<product>.outputs
  .deployer/profiles.yaml       -> profiles.<env>.aws_region

Example:
  dart run tools/collect_config.dart --env dev --variant ops
  dart run tools/collect_config.dart --env dev --all-variants --out web/
''';

const _variantProducts = <String, Map<String, String>>{
  'ops': {
    'cognito': 'ec_security_cognito_operators_portal_auth',
    'hosting': 'ec_web_spa_ops_portal_hosting',
    'api': 'ec_api_ops_portal',
  },
  'admins': {
    'cognito': 'ec_security_cognito_admins_portal_auth',
    'hosting': 'ec_web_spa_admins_portal_hosting',
    'api': 'ec_api_admins_portal',
  },
  'users': {
    'cognito': 'ec_security_cognito_users_portal_auth',
    'hosting': 'ec_web_spa_users_portal_hosting',
    'api': 'ec_api_users_portal',
  },
};

void main(List<String> args) {
  String? env;
  String? variant;
  String scdRepo = '../scd-echocorner';
  String outPath = 'web/config.json';
  bool allVariants = false;

  for (var i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--env':
        if (i + 1 >= args.length) exitUsage('Missing value for --env');
        env = args[++i];
        break;
      case '--variant':
        if (i + 1 >= args.length) exitUsage('Missing value for --variant');
        variant = args[++i];
        break;
      case '--scd-repo':
        if (i + 1 >= args.length) exitUsage('Missing value for --scd-repo');
        scdRepo = args[++i];
        break;
      case '--out':
        if (i + 1 >= args.length) exitUsage('Missing value for --out');
        outPath = args[++i];
        break;
      case '--all-variants':
        allVariants = true;
        break;
      case '--help':
      case '-h':
        print(_usage);
        exit(0);
    }
  }

  if (env == null || env.isEmpty) exitUsage('--env is required');
  if (!allVariants && (variant == null || variant.isEmpty)) {
    exitUsage('--variant is required (or use --all-variants)');
  }
  if (allVariants && variant != null) {
    exitUsage('Do not pass --variant when using --all-variants');
  }

  final scriptDir = path.dirname(Platform.script.toFilePath());
  final projectRoot = path.normalize(path.join(scriptDir, '..'));
  final resolvedScdRepo = path.isAbsolute(scdRepo) ? scdRepo : path.join(projectRoot, scdRepo);
  final stateFile = File(path.join(resolvedScdRepo, '.deployer', '.deploy-state.json'));
  final profilesFile = File(path.join(resolvedScdRepo, '.deployer', 'profiles.yaml'));

  if (!stateFile.existsSync()) {
    print('Error: Deploy state not found: ${stateFile.path}');
    print('Run "scd deploy apply" in scd-echocorner first, or set --scd-repo.');
    exit(1);
  }

  final stateJson = jsonDecode(stateFile.readAsStringSync()) as Map<String, dynamic>;
  final environments = stateJson['environments'] as Map<String, dynamic>?;
  if (environments == null || !environments.containsKey(env)) {
    print('Error: Environment "$env" not found in deploy state.');
    exit(1);
  }

  final products = environments[env]!['products'] as Map<String, dynamic>?;
  if (products == null) {
    print('Error: No products for environment "$env".');
    exit(1);
  }

  String region = 'eu-central-1';
  if (profilesFile.existsSync()) {
    final yaml = loadYaml(profilesFile.readAsStringSync()) as Map?;
    final profiles = yaml?['profiles'] as Map?;
    final envProfile = profiles?[env] as Map?;
    if (envProfile != null && envProfile['aws_region'] != null) {
      region = envProfile['aws_region'].toString();
    }
  }

  final variantsToEmit = allVariants ? _variantProducts.keys.toList() : [variant!];
  for (final v in variantsToEmit) {
    final config = buildConfig(v, products, region);
    if (config == null) {
      print('Error: Missing product outputs for variant "$v".');
      exit(1);
    }
    final outFile = allVariants
        ? path.join(path.dirname(outPath), 'config.$v.$env.json')
        : outPath;
    final resolvedOut = path.isAbsolute(outFile) ? outFile : path.join(projectRoot, outFile);
    File(resolvedOut).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(config));
    print('Wrote ${path.relative(resolvedOut, from: projectRoot)}');
  }
}

Map<String, dynamic>? buildConfig(String variant, Map<String, dynamic> products, String region) {
  final keys = _variantProducts[variant];
  if (keys == null) return null;
  final cognitoOut = products[keys['cognito']!]?['outputs'] as Map<String, dynamic>?;
  if (cognitoOut == null) return null;
  final userPoolId = cognitoOut['UserPoolId'] as String?;
  final userPoolClientId = cognitoOut['UserPoolClientId'] as String?;
  final hostedUiDomain = cognitoOut['HostedUiDomain'] as String?;
  if (userPoolId == null || userPoolClientId == null || hostedUiDomain == null) {
    return null;
  }
  final hostingOut = products[keys['hosting']!]?['outputs'] as Map<String, dynamic>?;
  final apiOut = products[keys['api']!]?['outputs'] as Map<String, dynamic>?;
  return {
    'userPoolId': userPoolId,
    'userPoolClientId': userPoolClientId,
    'cognitoHostedUiDomain': hostedUiDomain,
    'region': region,
    'portalUrl': hostingOut?['PortalUrl'] as String? ?? '',
    'apiBaseUrl': apiOut?['ApiUrl'] as String? ?? '',
    'graphqlEndpoint': apiOut?['GraphQLEndpoint'] as String? ?? '',
  };
}

void exitUsage(String message) {
  print('Error: $message');
  print(_usage);
  exit(1);
}
