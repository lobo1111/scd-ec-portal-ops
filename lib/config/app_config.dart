/// Runtime app configuration (Cognito, API, etc.).
/// Loaded from config.json (web) or asset/URL (mobile).
class AppConfig {
  const AppConfig({
    required this.userPoolId,
    required this.userPoolClientId,
    required this.cognitoHostedUiDomain,
    required this.region,
    this.portalUrl,
    this.apiBaseUrl,
    this.graphqlEndpoint,
    this.wsUrl,
  });

  final String userPoolId;
  final String userPoolClientId;
  final String cognitoHostedUiDomain;
  final String region;
  final String? portalUrl;
  final String? apiBaseUrl;
  final String? graphqlEndpoint;
  final String? wsUrl;

  /// Builds from JSON map. Throws if required keys are missing or invalid.
  factory AppConfig.fromJson(Map<String, dynamic> json) {
    final userPoolId = json['userPoolId'] as String?;
    final userPoolClientId = json['userPoolClientId'] as String?;
    final cognitoHostedUiDomain = json['cognitoHostedUiDomain'] as String?;
    final region = json['region'] as String?;

    if (userPoolId == null || userPoolId.isEmpty) {
      throw ArgumentError('config.json: userPoolId is required');
    }
    if (userPoolClientId == null || userPoolClientId.isEmpty) {
      throw ArgumentError('config.json: userPoolClientId is required');
    }
    if (cognitoHostedUiDomain == null || cognitoHostedUiDomain.isEmpty) {
      throw ArgumentError('config.json: cognitoHostedUiDomain is required');
    }
    if (region == null || region.isEmpty) {
      throw ArgumentError('config.json: region is required');
    }

    return AppConfig(
      userPoolId: userPoolId,
      userPoolClientId: userPoolClientId,
      cognitoHostedUiDomain: cognitoHostedUiDomain,
      region: region,
      portalUrl: json['portalUrl'] as String?,
      apiBaseUrl: json['apiBaseUrl'] as String?,
      graphqlEndpoint: json['graphqlEndpoint'] as String?,
      wsUrl: json['wsUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userPoolId': userPoolId,
      'userPoolClientId': userPoolClientId,
      'cognitoHostedUiDomain': cognitoHostedUiDomain,
      'region': region,
      if (portalUrl != null) 'portalUrl': portalUrl,
      if (apiBaseUrl != null) 'apiBaseUrl': apiBaseUrl,
      if (graphqlEndpoint != null) 'graphqlEndpoint': graphqlEndpoint,
      if (wsUrl != null) 'wsUrl': wsUrl,
    };
  }
}
