import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'token_storage.dart';
import '../router/app_routes.dart';

class AuthGuard {
  static void protect(
    BuildContext context, {
    required VoidCallback onAuthenticated,
  }) {
    if (TokenStorage.instance.hasToken) {
      onAuthenticated();
    } else {
      context.go(AppRoutes.login);
    }
  }

  static String? redirect(BuildContext context, GoRouterState state) {
    final isLoggedIn = TokenStorage.instance.hasToken;
    final goingToAuth = state.matchedLocation.startsWith('/auth');
    if (!isLoggedIn && !goingToAuth) return AppRoutes.login;
    if (isLoggedIn && goingToAuth) return AppRoutes.home;
    return null;
  }
}
