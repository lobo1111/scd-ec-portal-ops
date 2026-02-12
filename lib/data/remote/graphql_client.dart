import 'package:graphql_flutter/graphql_flutter.dart';

/// Builds a [GraphQLClient] with HTTP link to [endpoint] and auth from [getToken].
/// [getToken] should return the current Cognito ID token (e.g. from Amplify.Auth.fetchAuthSession).
/// Use in features that need live data: create the client when setup and config are available,
/// then run queries/mutations/subscriptions.
GraphQLClient createGraphQLClient(
  String endpoint,
  Future<String?> Function() getToken,
) {
  final authLink = AuthLink(
    getToken: () async {
      final token = await getToken();
      return token != null ? 'Bearer $token' : null;
    },
  );
  final httpLink = HttpLink(endpoint);
  final link = authLink.concat(httpLink);
  return GraphQLClient(
    cache: GraphQLCache(store: InMemoryStore()),
    link: link,
  );
}
