import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'app_config.dart';

Future<AppConfig> _fetchConfig(Uri uri) async {
  final response = await http.get(uri);
  if (response.statusCode != 200) {
    throw Exception('Failed to load config: ${response.statusCode} ${response.reasonPhrase}');
  }
  final json = jsonDecode(response.body) as Map<String, dynamic>;
  return AppConfig.fromJson(json);
}

Future<AppConfig> _loadConfigFromAssets() async {
  final data = await rootBundle.loadString('assets/config.json');
  final json = jsonDecode(data) as Map<String, dynamic>;
  return AppConfig.fromJson(json);
}

/// Provider: loads config once from /config.json (web) or assets/config.json (mobile).
final appConfigProvider = FutureProvider<AppConfig>((ref) async {
  if (kIsWeb) {
    final baseUrl = Uri.base;
    final path = baseUrl.path.endsWith('/') ? '${baseUrl.path}config.json' : '${baseUrl.path}/config.json';
    final configUrl = baseUrl.replace(path: path);
    return _fetchConfig(configUrl);
  }
  return _loadConfigFromAssets();
});
