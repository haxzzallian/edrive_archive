// lib/core/router/app_routes.dart  — ADD these two routes
class AppRoutes {
  AppRoutes._();

  // Auth
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String verifyOtp = '/auth/verify-otp';
  static const String forgotPassword = '/auth/forgot-password';
  static const String roleSelect = '/auth/role-select';
  static const String profileSetup = '/auth/profile-setup'; // ← NEW

  // Main shell
  static const String home = '/home';
  static const String trips = '/trips';
  static const String driverDash = '/driver/dashboard';
  static const String profile = '/profile';

  // Ride
  static const String bookRide = '/home/book';
  static const String rideTracking = '/home/tracking';
  static const String rideComplete = '/home/complete';
  static String tripDetail(String id) => '/trips/$id';

  // Driver
  static const String driverOnline = '/driver/online';
  static const String earnings = '/driver/earnings';
  static const String registerVehicle = '/driver/vehicle/register';

  // Profile
  static const String editProfile = '/profile/edit';
  static const String paymentMethods = '/profile/payments';
  static const String addPayment = '/profile/payments/add';

  // Shared
  static const String webview = '/webview';

  // SharedPreferences keys
  static const String kOnboardingSeen = 'onboarding_seen';
}
