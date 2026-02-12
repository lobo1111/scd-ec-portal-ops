#!/usr/bin/env dart
// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

/// Prints BUCKET_NAME and DISTRIBUTION_ID for the given env/variant so a shell can eval the output.
/// Usage: eval $(dart run tools/get_hosting_outputs.dart --env dev --variant ops)
const _usage = '''
Usage: dart run tools/get_hosting_outputs.dart --env <env> --variant <variant> [--scd-repo <path>]

Prints export statements for BUCKET_NAME and DISTRIBUTION_ID from scd-echocorner
.deployer/.deploy-state.json for the portal hosting product. Use in deploy scripts:

  eval \$(dart run tools/get_hosting_outputs.dart --env dev --variant ops)
  aws s3 sync build/web/ s3://\$BUCKET_NAME/ --delete
  aws cloudfront create-invalidation --distribution-id \$DISTRIBUTION_ID --paths "/*"
''';

const _hostingProduct = <String, String>{
  'ops': 'ec_web_spa_ops_portal_hosting',
  'admins': 'ec_web_spa_admins_portal_hosting',
  'users': 'ec_web_spa_users_portal_hosting',
};

void main(List<String> args) {
  String? env;
  String? variant;
  String scdRepo = '../scd-echocorner';

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
      case '--help':
      case '-h':
        print(_usage);
        exit(0);
    }
  }

  if (env == null || env.isEmpty) exitUsage('--env is required');
  if (variant == null || variant.isEmpty) exitUsage('--variant is required');

  final productKey = _hostingProduct[variant];
  if (productKey == null) {
    print('Error: Unknown variant "$variant". Use ops, admins, or users.');
    exit(1);
  }

  final scriptDir = path.dirname(Platform.script.toFilePath());
  final projectRoot = path.normalize(path.join(scriptDir, '..'));
  final resolvedScdRepo = path.isAbsolute(scdRepo) ? scdRepo : path.join(projectRoot, scdRepo);
  final stateFile = File(path.join(resolvedScdRepo, '.deployer', '.deploy-state.json'));

  if (!stateFile.existsSync()) {
    print('Error: Deploy state not found: ${stateFile.path}', stderr);
    exit(1);
  }

  final stateJson = jsonDecode(stateFile.readAsStringSync()) as Map<String, dynamic>;
  final products = stateJson['environments']?[env]?['products'] as Map<String, dynamic>?;
  if (products == null) {
    print('Error: Environment "$env" or products not found.', stderr);
    exit(1);
  }

  final outputs = products[productKey]?['outputs'] as Map<String, dynamic>?;
  if (outputs == null) {
    print('Error: Hosting product "$productKey" not found for env "$env".', stderr);
    exit(1);
  }

  final bucket = outputs['BucketName'] as String?;
  final distributionId = outputs['DistributionId'] as String?;
  if (bucket == null || bucket.isEmpty) {
    print('Error: BucketName not found for $productKey.', stderr);
    exit(1);
  }

  print('export BUCKET_NAME="$bucket"');
  if (distributionId != null && distributionId.isNotEmpty) {
    print('export DISTRIBUTION_ID="$distributionId"');
  } else {
    print('export DISTRIBUTION_ID=""');
  }
}

void exitUsage(String message) {
  print('Error: $message', stderr);
  print(_usage);
  exit(1);
}
