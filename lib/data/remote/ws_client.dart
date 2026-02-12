import 'dart:async';

import 'package:web_socket_channel/web_socket_channel.dart';

/// Helper to connect to a WebSocket URL with optional auth.
/// Features that need live data can use this to open a channel and subscribe to messages.
/// Attach auth (e.g. query param or header) via [uriWithAuth].
class WsClient {
  WsClient({required this.baseUrl, Future<String?> Function()? getToken})
      : _getToken = getToken ?? (() async => null);

  final String baseUrl;
  final Future<String?> Function()> _getToken;

  /// Opens a WebSocket to [path] (relative to [baseUrl]). Optionally appends token as query param.
  Future<WebSocketChannel> connect(String path) async {
    final token = await _getToken();
    final uri = Uri.parse(baseUrl).replace(path: path);
    final uriWithAuth = token != null
        ? uri.replace(queryParameters: {...uri.queryParameters, 'token': token})
        : uri;
    return WebSocketChannel.connect(uriWithAuth);
  }

  /// Returns a stream of text messages from [path]. Call [cancel] to close.
  Stream<String> streamText(String path) async* {
    final token = await _getToken();
    final uri = Uri.parse(baseUrl).replace(path: path);
    final u = token != null
        ? uri.replace(queryParameters: {...uri.queryParameters, 'token': token})
        : uri;
    final channel = WebSocketChannel.connect(u);
    await for (final message in channel.stream) {
      if (message is String) yield message;
    }
  }
}
