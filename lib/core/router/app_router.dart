// lib/core/router/app_router.dart
// ADD this GoRoute inside the routes list (alongside login, register etc.):

// GoRoute(
//   path: AppRoutes.profileSetup,
//   builder: (_, s) {
//     final args = s.extra as Map<String, String>? ?? {};
//     return ProfileSetupPage(
//       role:  args['role']  ?? TokenStorage.instance.role ?? 'client',
//       email: args['email'] ?? TokenStorage.instance.email ?? '',
//     );
//   },
// ),

// Full updated router for reference:
import 'package:e_drive/features/auth/presentation/pages/verify_otp_page.dart';
import 'package:e_drive/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../main_shell.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';

import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/profile_setup_page.dart'; // ← NEW
import '../../features/ride/presentation/pages/home_page.dart';
import '../../features/ride/presentation/pages/book_ride_page.dart';

import '../../features/trips/presentation/pages/trips_page.dart';
import '../../features/trips/presentation/pages/trip_detail_page.dart';
import '../../features/driver/presentation/pages/driver_dashboard_page.dart';
import '../../features/driver/presentation/pages/driver_online_page.dart';
import '../../features/driver/presentation/pages/earnings_page.dart';
import '../../features/driver/presentation/pages/register_vehicle_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/payment/presentation/pages/payment_methods_page.dart';
import '../../features/payment/presentation/pages/add_payment_method_page.dart';
import '../widgets/in_app_webview_page.dart';
import '../services/token_storage.dart';
import '../services/auth_guard.dart';
import 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashPage()),
      GoRoute(
          path: AppRoutes.onboarding,
          builder: (_, __) => const OnboardingPage()),
      GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginPage()),
      GoRoute(
          path: AppRoutes.register, builder: (_, __) => const RegisterPage()),
      GoRoute(
          path: AppRoutes.verifyOtp,
          builder: (_, s) => VerifyOtpPage(email: s.extra as String? ?? '')),
      // GoRoute(
      //     path: AppRoutes.forgotPassword,
      //     builder: (_, __) => const ForgotPasswordPage()),
      // ── Profile setup ────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.profileSetup,
        builder: (_, s) {
          final args = s.extra as Map<String, String>? ?? {};
          return ProfileSetupPage(
            // pendingRole is what was saved during register()
            role: args['role'] ?? TokenStorage.instance.pendingRole ?? 'client',
            email: args['email'] ?? TokenStorage.instance.pendingEmail ?? '',
          );
        },
      ),

      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => MainShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
                path: AppRoutes.home,
                builder: (_, __) => const HomePage(),
                routes: [
                  GoRoute(
                    path: 'book',
                    builder: (_, s) => BookRidePage(origin: s.extra as LatLng?),
                  ),
                ]),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: AppRoutes.driverDash,
                builder: (_, __) => const DashboardPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: AppRoutes.profile,
                builder: (_, __) => const ProfilePage(),
                routes: [
                  GoRoute(
                      path: 'edit',
                      builder: (_, __) => const EditProfilePage()),
                  GoRoute(
                      path: 'payments',
                      builder: (_, __) => const PaymentMethodsPage(),
                      routes: [
                        GoRoute(
                            path: 'add',
                            builder: (_, __) => const AddPaymentMethodPage()),
                      ]),
                ]),
          ]),
        ],
      ),

      // GoRoute(path: AppRoutes.driverOnline,    builder: (_, __) => const DriverOnlinePage()),
      // GoRoute(path: AppRoutes.earnings,        builder: (_, __) => const EarningsPage()),
      // GoRoute(path: AppRoutes.registerVehicle, builder: (_, __) => const RegisterVehiclePage()),
      GoRoute(
          path: AppRoutes.webview,
          builder: (_, s) {
            final args = s.extra as Map<String, String>;
            return InAppWebViewPage(
                url: args['url']!, title: args['title'] ?? '');
          }),
    ],
  );
});
