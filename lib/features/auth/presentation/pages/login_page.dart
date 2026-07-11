// lib/features/auth/presentation/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/auth_notifier.dart';
import '../widgets/map_animation_background.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ref.read(authProvider.notifier).login(
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authProvider);
    final size = MediaQuery.of(context).size;

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    ref.listen(authProvider.select((s) => s.error), (_, error) {
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
        ref.read(authProvider.notifier).clearError();
      }
    });

    ref.listen(authProvider.select((s) => s.isAuthenticated), (_, isAuth) {
      if (isAuth) context.go(AppRoutes.home);
    });

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: Stack(children: [
        // ── Animated map header ─────────────────────────────────────────────
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: MapAnimationBackground(
            height: size.height * 0.42,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(36),
              bottomRight: Radius.circular(36),
            ),
            // Dark navy gradient matches the header design
            overlayColors: const [
              Color(0x880D1B2A),
              Color(0xDD0D1B2A),
            ],
          ),
        ),

        // ── Logo + welcome text (sits on top of the map) ────────────────────
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SizedBox(
            height: size.height * 0.42,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo
                    Row(children: [
                      Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.directions_car_rounded,
                              color: Colors.white, size: 22)),
                      const SizedBox(width: 10),
                      const Text('e-Drive',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800)),
                    ]),
                    const Spacer(),
                    const Text('Welcome\nBack! 👋',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            height: 1.15,
                            letterSpacing: -1)),
                    const SizedBox(height: 8),
                    Text('Sign in to continue your journey',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14)),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Scrollable form card ────────────────────────────────────────────
        Positioned.fill(
          child: SingleChildScrollView(
            child: Column(children: [
              SizedBox(height: size.height * 0.35),
              FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                            color:
                                Colors.black.withOpacity(isDark ? 0.4 : 0.10),
                            blurRadius: 32,
                            offset: const Offset(0, 8))
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Label('Email Address', isDark),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary,
                                fontSize: 15),
                            decoration: _deco(isDark,
                                hint: 'you@example.com',
                                icon: Icons.email_outlined),
                            validator: (v) => v == null || !v.contains('@')
                                ? 'Enter a valid email'
                                : null,
                          ),
                          const SizedBox(height: 18),
                          _Label('Password', isDark),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passCtrl,
                            obscureText: _obscure,
                            style: TextStyle(
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary,
                                fontSize: 15),
                            decoration: _deco(isDark,
                                hint: '••••••••',
                                icon: Icons.lock_outline_rounded,
                                suffix: IconButton(
                                    icon: Icon(
                                        _obscure
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: AppColors.textHint,
                                        size: 20),
                                    onPressed: () =>
                                        setState(() => _obscure = !_obscure))),
                            validator: (v) => v == null || v.length < 6
                                ? 'Min 6 characters'
                                : null,
                          ),
                          const SizedBox(height: 6),
                          Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                  onPressed: () =>
                                      context.push(AppRoutes.forgotPassword),
                                  style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap),
                                  child: Text('Forgot password?',
                                      style: TextStyle(
                                          color: AppColors.secondary,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600)))),
                          const SizedBox(height: 24),
                          SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: authState.isLoading ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.secondary,
                                    disabledBackgroundColor:
                                        AppColors.secondary.withOpacity(0.5),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14))),
                                child: authState.isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5))
                                    : const Text('SIGN IN',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 1.2)),
                              )),
                          // const SizedBox(height: 20),
                          // Row(children: [
                          //   Expanded(
                          //       child: Divider(
                          //           color: isDark
                          //               ? AppColors.darkDivider
                          //               : AppColors.divider)),
                          //   Padding(
                          //       padding:
                          //           const EdgeInsets.symmetric(horizontal: 12),
                          //       child: Text('or continue with',
                          //           style: TextStyle(
                          //               color: AppColors.textHint,
                          //               fontSize: 12))),
                          //   Expanded(
                          //       child: Divider(
                          //           color: isDark
                          //               ? AppColors.darkDivider
                          //               : AppColors.divider)),
                          // ]),
                          // const SizedBox(height: 14),
                          // Row(children: [
                          //   Expanded(
                          //       child: _SocialBtn(
                          //           label: 'Google',
                          //           icon: Icons.g_mobiledata_rounded,
                          //           isDark: isDark,
                          //           onTap: () {})),
                          //   const SizedBox(width: 12),
                          //   Expanded(
                          //       child: _SocialBtn(
                          //           label: 'Apple',
                          //           icon: Icons.apple,
                          //           isDark: isDark,
                          //           onTap: () {})),
                          // ]),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              GestureDetector(
                  onTap: () => context.push(AppRoutes.register),
                  child: RichText(
                      text: TextSpan(
                    text: "Don't have an account? ",
                    style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                        fontSize: 14),
                    children: [
                      TextSpan(
                          text: 'Sign Up',
                          style: TextStyle(
                              color: AppColors.secondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700))
                    ],
                  ))),
              const SizedBox(height: 32),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _Label(String text, bool isDark) => Text(text,
      style: TextStyle(
          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w600));

  InputDecoration _deco(
    bool isDark, {
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) =>
      InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
        prefixIcon: Icon(icon, color: AppColors.textHint, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor:
            isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.secondary, width: 2)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error, width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error, width: 2)),
      );
}

class _SocialBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;
  const _SocialBtn(
      {required this.label,
      required this.icon,
      required this.isDark,
      required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceVariant : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: isDark ? AppColors.darkDivider : AppColors.divider,
                width: 1.5)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon,
              size: 22,
              color:
                  isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ]),
      ));
}
