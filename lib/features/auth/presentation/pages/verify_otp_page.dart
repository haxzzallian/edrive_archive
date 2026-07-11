// lib/features/auth/presentation/pages/verify_otp_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/token_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/auth_notifier.dart';

class VerifyOtpPage extends ConsumerStatefulWidget {
  final String email;
  const VerifyOtpPage({super.key, required this.email});
  @override
  ConsumerState<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends ConsumerState<VerifyOtpPage> {
  final List<TextEditingController> _ctrls =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(6, (_) => FocusNode());
  int _resendSeconds = 60;
  Timer? _timer;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _nodes[0].requestFocus());
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _resendSeconds = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendSeconds == 0) {
        t.cancel();
        return;
      }
      if (mounted) setState(() => _resendSeconds--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _ctrls) c.dispose();
    for (final n in _nodes) n.dispose();
    super.dispose();
  }

  String get _otp => _ctrls.map((c) => c.text).join();

  void _onDigitChanged(int i, String val) {
    if (val.length == 1 && i < 5) _nodes[i + 1].requestFocus();
    if (val.isEmpty && i > 0) _nodes[i - 1].requestFocus();
    if (_otp.length == 6) _verify();
  }

  Future<void> _verify() async {
    if (_isVerifying || _otp.length < 6) return;
    setState(() => _isVerifying = true);

    final ok = await ref.read(authProvider.notifier).verifyOtp(
          email: widget.email,
          code: _otp,
        );

    if (!mounted) return;
    setState(() => _isVerifying = false);

    if (ok) {
      // ── Read role BEFORE clearing — repository no longer clears it ────────
      final role = TokenStorage.instance.pendingRole ?? 'client';
      final email = TokenStorage.instance.pendingEmail ?? widget.email;

      // Clear pending state AFTER reading it
      await TokenStorage.instance.clearPendingVerification();

      if (!mounted) return;
      context.go(
        AppRoutes.profileSetup,
        extra: <String, String>{'role': role, 'email': email},
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Invalid OTP. Please try again.'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));
      for (final c in _ctrls) c.clear();
      _nodes[0].requestFocus();
    }
  }

  Future<void> _resend() async {
    if (_resendSeconds > 0) return;
    final ok = await ref.read(authProvider.notifier).resendOtp(
          email: widget.email,
        );
    if (!mounted) return;
    if (ok) {
      _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('OTP resent to ${widget.email}'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to resend OTP. Please try again.'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color:
                    isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                size: 20),
            onPressed: () => Navigator.of(context).pop()),
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 8),
          Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.mark_email_unread_rounded,
                  color: AppColors.secondary, size: 30)),
          const SizedBox(height: 22),
          Text('Verify Email',
              style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5)),
          const SizedBox(height: 8),
          RichText(
              text: TextSpan(
            text: 'Enter the 6-digit code sent to\n',
            style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
                fontSize: 14,
                height: 1.5),
            children: [
              TextSpan(
                  text: widget.email,
                  style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w600))
            ],
          )),
          const SizedBox(height: 36),
          LayoutBuilder(builder: (context, constraints) {
            final boxWidth = (constraints.maxWidth - 5 * 8) / 6;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                  6,
                  (i) => SizedBox(
                      width: boxWidth,
                      height: 54,
                      child: TextFormField(
                        controller: _ctrls[i],
                        focusNode: _nodes[i],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(1),
                        ],
                        style: TextStyle(
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w800),
                        onChanged: (v) => _onDigitChanged(i, v),
                        decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: isDark
                                ? AppColors.darkSurfaceVariant
                                : AppColors.surfaceVariant,
                            contentPadding: EdgeInsets.zero,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: AppColors.secondary, width: 2.5))),
                      ))),
            );
          }),
          const SizedBox(height: 32),
          SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: (_otp.length < 6 || _isVerifying) ? null : _verify,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    disabledBackgroundColor:
                        AppColors.secondary.withOpacity(0.4),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14))),
                child: _isVerifying
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : const Text('VERIFY',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1)),
              )),
          const SizedBox(height: 20),
          Center(
              child: GestureDetector(
            onTap: _resend,
            child: RichText(
                text: TextSpan(
              text: "Didn't receive the code? ",
              style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                  fontSize: 14),
              children: [
                TextSpan(
                    text: _resendSeconds > 0
                        ? 'Resend in ${_resendSeconds}s'
                        : 'Resend',
                    style: TextStyle(
                        color: _resendSeconds > 0
                            ? AppColors.textHint
                            : AppColors.secondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700))
              ],
            )),
          )),
          const SizedBox(height: 32),
        ]),
      ),
    );
  }
}
