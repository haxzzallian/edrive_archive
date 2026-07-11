// lib/core/network/endpoints.dart  — updated base URL
class Endpoints {
  Endpoints._();
  static const String baseUrl = 'https://api.edrive.ng/api';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String verifyEmail = '/auth/verify-email';
  static const String sendOtp = '/auth/send-otp';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // Profile
  static const String createProfile = '/profile/createprofile';
  static const String getProfile = '/profile';
  static const String updateProfile = '/profile/update';

  // Cloudinary image upload
  static const String cloudinaryUrl =
      'https://api.cloudinary.com/v1_1/digzrkdoe/image/upload';
  static const String cloudinaryPreset = 'oosh_preset';
}
