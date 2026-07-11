// lib/features/auth/presentation/pages/register_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/auth_notifier.dart';
import '../widgets/map_animation_background.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});
  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String _role = 'client';
  bool _obscurePass = true;
  bool _obscureConf = true;
  bool _agreed = false;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    for (final c in [
      _firstCtrl,
      _lastCtrl,
      _emailCtrl,
      _passCtrl,
      _confirmCtrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final email = await ref.read(authProvider.notifier).register(
          firstName: _firstCtrl.text.trim(),
          lastName: _lastCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
          role: _role,
        );
    if (!mounted) return;
    if (email != null) context.push(AppRoutes.verifyOtp, extra: email);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authProvider);

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

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: Stack(children: [
        // ── Animated map header (shorter than login — register has more content) ──
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: MapAnimationBackground(
            height: 200,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
            overlayColors: const [
              Color(0x660D1B2A),
              Color(0xEE0D1B2A),
            ],
          ),
        ),

        // ── Back button + title (sits on top of the map) ────────────────────
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SizedBox(
            height: 200,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.white, size: 20),
                          onPressed: () => Navigator.of(context).pop()),
                      const SizedBox(width: 4),
                      const Text('Create Account',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800)),
                    ]),
                    const SizedBox(height: 4),
                    Padding(
                        padding: const EdgeInsets.only(left: 44),
                        child: Text('Join e-Drive today',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.65),
                                fontSize: 14))),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Scrollable form ─────────────────────────────────────────────────
        Positioned.fill(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 172),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Role selector ─────────────────────────────────────
                      const SizedBox(height: 8),
                      _Card(
                          isDark: isDark,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Title('I am registering as', isDark),
                              const SizedBox(height: 12),
                              Row(children: [
                                _RoleChip(
                                    label: 'Passenger',
                                    icon: Icons.person_rounded,
                                    selected: _role == 'client',
                                    color: AppColors.secondary,
                                    onTap: () =>
                                        setState(() => _role = 'client')),
                                const SizedBox(width: 12),
                                _RoleChip(
                                    label: 'Driver',
                                    icon: Icons.drive_eta_rounded,
                                    selected: _role == 'driver',
                                    color: AppColors.accent,
                                    onTap: () =>
                                        setState(() => _role = 'driver')),
                              ]),
                            ],
                          )),
                      const SizedBox(height: 16),

                      // ── Personal info ─────────────────────────────────────
                      _Card(
                          isDark: isDark,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Title('Personal Information', isDark),
                              const SizedBox(height: 14),
                              Row(children: [
                                Expanded(
                                    child: _Field(
                                        ctrl: _firstCtrl,
                                        hint: 'First name',
                                        icon: Icons.person_outline_rounded,
                                        isDark: isDark,
                                        validator: (v) =>
                                            v == null || v.trim().isEmpty
                                                ? 'Required'
                                                : null)),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: _Field(
                                        ctrl: _lastCtrl,
                                        hint: 'Last name',
                                        icon: Icons.person_outline_rounded,
                                        isDark: isDark,
                                        validator: (v) =>
                                            v == null || v.trim().isEmpty
                                                ? 'Required'
                                                : null)),
                              ]),
                              const SizedBox(height: 14),
                              _Field(
                                  ctrl: _emailCtrl,
                                  hint: 'Email address',
                                  icon: Icons.email_outlined,
                                  isDark: isDark,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) =>
                                      v == null || !v.contains('@')
                                          ? 'Enter a valid email'
                                          : null),
                            ],
                          )),
                      const SizedBox(height: 16),

                      // ── Password ──────────────────────────────────────────
                      _Card(
                          isDark: isDark,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Title('Set Password', isDark),
                              const SizedBox(height: 14),
                              _Field(
                                  ctrl: _passCtrl,
                                  hint: 'Password',
                                  icon: Icons.lock_outline_rounded,
                                  isDark: isDark,
                                  obscure: _obscurePass,
                                  suffix: IconButton(
                                      icon: Icon(
                                          _obscurePass
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color: AppColors.textHint,
                                          size: 19),
                                      onPressed: () => setState(
                                          () => _obscurePass = !_obscurePass)),
                                  validator: (v) => v == null || v.length < 6
                                      ? 'Min 6 characters'
                                      : null),
                              const SizedBox(height: 14),
                              _Field(
                                  ctrl: _confirmCtrl,
                                  hint: 'Confirm password',
                                  icon: Icons.lock_outline_rounded,
                                  isDark: isDark,
                                  obscure: _obscureConf,
                                  suffix: IconButton(
                                      icon: Icon(
                                          _obscureConf
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color: AppColors.textHint,
                                          size: 19),
                                      onPressed: () => setState(
                                          () => _obscureConf = !_obscureConf)),
                                  validator: (v) => v != _passCtrl.text
                                      ? 'Passwords do not match'
                                      : null),
                              const SizedBox(height: 8),
                              ValueListenableBuilder(
                                  valueListenable: _passCtrl,
                                  builder: (_, __, ___) =>
                                      _StrengthBar(password: _passCtrl.text)),
                            ],
                          )),
                      const SizedBox(height: 16),

                      // ── Terms ─────────────────────────────────────────────
                      GestureDetector(
                        onTap: () => setState(() => _agreed = !_agreed),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                    color: _agreed
                                        ? AppColors.secondary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color: _agreed
                                            ? AppColors.secondary
                                            : AppColors.textHint,
                                        width: 1.5)),
                                child: _agreed
                                    ? const Icon(Icons.check_rounded,
                                        color: Colors.white, size: 14)
                                    : null),
                            const SizedBox(width: 10),
                            Expanded(
                                child: RichText(
                                    text: TextSpan(
                              text: 'I agree to the ',
                              style: TextStyle(
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary,
                                  fontSize: 13,
                                  height: 1.5),
                              children: [
                                TextSpan(
                                    text: 'Terms of Service',
                                    style: TextStyle(
                                        color: AppColors.secondary,
                                        fontWeight: FontWeight.w600)),
                                const TextSpan(text: ' and '),
                                TextSpan(
                                    text: 'Privacy Policy',
                                    style: TextStyle(
                                        color: AppColors.secondary,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Submit ────────────────────────────────────────────
                      SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: authState.isLoading || !_agreed
                                ? null
                                : _submit,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                disabledBackgroundColor:
                                    AppColors.secondary.withOpacity(0.4),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14))),
                            child: authState.isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2.5))
                                : const Text('CREATE ACCOUNT',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1)),
                          )),
                      const SizedBox(height: 20),

                      Center(
                          child: GestureDetector(
                        onTap: () => context.pop(),
                        child: RichText(
                            text: TextSpan(
                          text: 'Already have an account? ',
                          style: TextStyle(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                              fontSize: 14),
                          children: [
                            TextSpan(
                                text: 'Sign In',
                                style: TextStyle(
                                    color: AppColors.secondary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700))
                          ],
                        )),
                      )),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  final bool isDark;
  const _Card({required this.child, required this.isDark});
  @override
  Widget build(BuildContext context) => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                blurRadius: 16,
                offset: const Offset(0, 4))
          ]),
      child: child);
}

Widget _Title(String t, bool isDark) => Text(t,
    style: TextStyle(
        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2));

class _RoleChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _RoleChip(
      {required this.label,
      required this.icon,
      required this.selected,
      required this.color,
      required this.onTap});
  @override
  Widget build(BuildContext context) => Expanded(
      child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
                color: selected ? color.withOpacity(0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: selected ? color : AppColors.divider,
                    width: selected ? 2 : 1.5)),
            child: Column(children: [
              Icon(icon,
                  color: selected ? color : AppColors.textHint, size: 26),
              const SizedBox(height: 6),
              Text(label,
                  style: TextStyle(
                      color: selected ? color : AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w500)),
            ]),
          )));
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final IconData icon;
  final bool isDark;
  final bool obscure;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  const _Field(
      {required this.ctrl,
      required this.hint,
      required this.icon,
      required this.isDark,
      this.obscure = false,
      this.suffix,
      this.keyboardType,
      this.validator});
  @override
  Widget build(BuildContext context) => TextFormField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
        prefixIcon: Icon(icon, color: AppColors.textHint, size: 19),
        suffixIcon: suffix,
        filled: true,
        fillColor:
            isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
      ));
}

class _StrengthBar extends StatelessWidget {
  final String password;
  const _StrengthBar({required this.password});
  int get _s {
    int s = 0;
    if (password.length >= 8) s++;
    if (password.contains(RegExp(r'[A-Z]'))) s++;
    if (password.contains(RegExp(r'[0-9]'))) s++;
    if (password.contains(RegExp(r'[!@#\$%^&*]'))) s++;
    return s;
  }

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();
    final s = _s;
    final color = s <= 1
        ? AppColors.error
        : s == 2
            ? AppColors.warning
            : s == 3
                ? AppColors.info
                : AppColors.success;
    final label = s <= 1
        ? 'Weak'
        : s == 2
            ? 'Fair'
            : s == 3
                ? 'Good'
                : 'Strong';
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 8),
      Row(
          children: List.generate(
              4,
              (i) => Expanded(
                  child: Container(
                      height: 4,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                          color: i < s ? color : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(2)))))),
      const SizedBox(height: 4),
      Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    ]);
  }
}
