import 'package:amplify_flutter/amplify_flutter.dart';

/// Thin wrapper around Amplify Auth for Hosted UI redirect flow.
class AuthService {
  AuthService();

  Future<AuthUser?> getCurrentUser() async {
    try {
      return await Amplify.Auth.getCurrentUser();
    } on SignedOutException {
      return null;
    }
  }

  /// Redirects to Cognito Hosted UI for sign-in. After redirect, app lands on /callback.
  Future<void> signInWithWebUI() async {
    await Amplify.Auth.signInWithWebUI();
  }

  /// Signs out and redirects to Cognito sign-out if using Hosted UI.
  Future<void> signOut() async {
    await Amplify.Auth.signOut();
  }

  /// Fetch current session (e.g. after returning from Hosted UI callback).
  Future<AuthSession> fetchAuthSession() async {
    return Amplify.Auth.fetchAuthSession();
  }
}
