// lib/features/auth/presentation/pages/onboarding_page.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';

class _Slide {
  final String title;
  final String subtitle;
  final Color bgColor;
  final Color accentColor;
  final Widget Function(AnimationController) illustrationBuilder;
  const _Slide(
      {required this.title,
      required this.subtitle,
      required this.bgColor,
      required this.accentColor,
      required this.illustrationBuilder});
}

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});
  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage>
    with TickerProviderStateMixin {
  final _pageCtrl = PageController();
  int _current = 0;

  late AnimationController _autoSlideCtrl;
  late AnimationController _illustrationCtrl;
  late AnimationController _contentCtrl;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;
  late Animation<double> _progressAnim;
  late List<_Slide> _slides;

  static const _slideDuration = Duration(seconds: 4);
  static const _transitionDuration = Duration(milliseconds: 600);

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _illustrationCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..repeat();

    _contentCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _contentFade = CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut);
    _contentSlide = Tween<Offset>(
            begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut));

    _autoSlideCtrl = AnimationController(vsync: this, duration: _slideDuration);
    _progressAnim =
        CurvedAnimation(parent: _autoSlideCtrl, curve: Curves.linear);
    _autoSlideCtrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) _advanceSlide();
    });

    _slides = _buildSlides();
    _contentCtrl.forward();
    _startAutoSlide();
  }

  List<_Slide> _buildSlides() => [
        _Slide(
            title: 'Ride Green,\nRide Smart',
            subtitle:
                'Book eco-friendly rides with seamless navigation and secure bookings.',
            bgColor: const Color(0xFF0D1B2A),
            accentColor: AppColors.secondary,
            illustrationBuilder: (c) => _MapIllustration(controller: c)),
        _Slide(
            title: 'Track Your\nRide Live',
            subtitle:
                'Real-time GPS tracking so you always know exactly where your driver is.',
            bgColor: const Color(0xFF0A1628),
            accentColor: AppColors.accent,
            illustrationBuilder: (c) => _TrackingIllustration(controller: c)),
        _Slide(
            title: 'Safe &\nSecure Trips',
            subtitle:
                'Verified drivers, cashless payments, and 24/7 customer support.',
            bgColor: const Color(0xFF0D1B2A),
            accentColor: const Color(0xFF00B4D8),
            illustrationBuilder: (c) => _SafetyIllustration(controller: c)),
        _Slide(
            title: 'Earn as a\nDriver',
            subtitle:
                'Set your own hours, grow your income, and join thousands of drivers.',
            bgColor: const Color(0xFF0F1923),
            accentColor: AppColors.secondary,
            illustrationBuilder: (c) => _EarningsIllustration(controller: c)),
      ];

  void _startAutoSlide() {
    _autoSlideCtrl.reset();
    _autoSlideCtrl.forward();
  }

  void _advanceSlide() {
    if (!mounted) return;
    if (_current < _slides.length - 1) {
      _pageCtrl.nextPage(
          duration: _transitionDuration, curve: Curves.easeInOut);
    } else {
      _finish();
    }
  }

  void _onPageChanged(int i) {
    setState(() => _current = i);
    _contentCtrl.reset();
    _contentCtrl.forward();
    _startAutoSlide();
  }

  Future<void> _finish() async {
    _autoSlideCtrl.stop();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppRoutes.kOnboardingSeen, true);
    if (mounted) context.go(AppRoutes.login);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _autoSlideCtrl.dispose();
    _illustrationCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_current];
    final isLast = _current == _slides.length - 1;
    // Use LayoutBuilder so nothing overflows on small screens
    return Scaffold(
      backgroundColor: slide.bgColor,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        color: slide.bgColor,
        child: Stack(children: [
          Positioned.fill(
              child: CustomPaint(
                  painter: _DotGridPainter(color: slide.accentColor))),
          // Page view
          PageView.builder(
            controller: _pageCtrl,
            itemCount: _slides.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (_, i) => _SlideView(
              slide: _slides[i],
              contentFade: _contentFade,
              contentSlide: _contentSlide,
              illustrationCtrl: _illustrationCtrl,
            ),
          ),
          // Top bar
          SafeArea(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                            color: slide.accentColor,
                            borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.directions_car_rounded,
                            color: Colors.white, size: 18)),
                    const SizedBox(width: 8),
                    const Text('e-Drive',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800)),
                  ]),
                  if (!isLast)
                    TextButton(
                      onPressed: _finish,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        backgroundColor: Colors.white.withOpacity(0.1),
                        shape: const StadiumBorder(),
                      ),
                      child: Text('Skip',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 13,
                              fontWeight: FontWeight.w500)),
                    ),
                ]),
          )),
          // Bottom controls — fixed height, no overflow
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                  child: Container(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  // Segment bars
                  Row(
                      children: List.generate(
                          _slides.length,
                          (i) => Expanded(
                                  child: Padding(
                                padding: EdgeInsets.only(
                                    right: i < _slides.length - 1 ? 6 : 0),
                                child: _SegmentBar(
                                    isCompleted: i < _current,
                                    isActive: i == _current,
                                    accentColor: slide.accentColor,
                                    progressAnimation: _progressAnim),
                              )))),
                  const SizedBox(height: 20),
                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_slides.length, (i) {
                      final isActive = i == _current;
                      return GestureDetector(
                        onTap: () {
                          _pageCtrl.animateToPage(i,
                              duration: _transitionDuration,
                              curve: Curves.easeInOut);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isActive ? 22 : 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: isActive
                                ? slide.accentColor
                                : Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 18),
                  // CTA button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      decoration: BoxDecoration(
                        color: slide.accentColor,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                              color: slide.accentColor.withOpacity(0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 5))
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: isLast ? _finish : _advanceSlide,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(isLast ? 'Get Started' : 'Next',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.3)),
                              const SizedBox(width: 8),
                              Icon(
                                  isLast
                                      ? Icons.rocket_launch_rounded
                                      : Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 19),
                            ]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Login link
                  GestureDetector(
                    onTap: _finish,
                    child: RichText(
                        text: TextSpan(
                      text: 'Already have an account? ',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.45), fontSize: 13),
                      children: [
                        TextSpan(
                            text: 'Log In',
                            style: TextStyle(
                                color: slide.accentColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w700))
                      ],
                    )),
                  ),
                ]),
              ))),
        ]),
      ),
    );
  }
}

// ── Segment bar ───────────────────────────────────────────────────────────────
class _SegmentBar extends StatelessWidget {
  final bool isCompleted, isActive;
  final Color accentColor;
  final Animation<double> progressAnimation;
  const _SegmentBar(
      {required this.isCompleted,
      required this.isActive,
      required this.accentColor,
      required this.progressAnimation});
  @override
  Widget build(BuildContext context) => Container(
        height: 3,
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(2)),
        clipBehavior: Clip.hardEdge,
        child: isCompleted
            ? DecoratedBox(
                decoration: BoxDecoration(color: accentColor),
                child: const SizedBox.expand())
            : isActive
                ? AnimatedBuilder(
                    animation: progressAnimation,
                    builder: (_, __) => FractionallySizedBox(
                        widthFactor: progressAnimation.value,
                        alignment: Alignment.centerLeft,
                        child: DecoratedBox(
                            decoration: BoxDecoration(
                                color: accentColor,
                                borderRadius: BorderRadius.circular(2)),
                            child: const SizedBox.expand())))
                : const SizedBox.expand(),
      );
}

// ── Slide view — uses Flexible to prevent overflow ────────────────────────────
class _SlideView extends StatelessWidget {
  final _Slide slide;
  final Animation<double> contentFade;
  final Animation<Offset> contentSlide;
  final AnimationController illustrationCtrl;
  const _SlideView(
      {required this.slide,
      required this.contentFade,
      required this.contentSlide,
      required this.illustrationCtrl});

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).size.height * 0.23;
    return Column(children: [
      // Illustration takes flexible top portion
      Flexible(flex: 10, child: slide.illustrationBuilder(illustrationCtrl)),
      // Text content — uses Flexible so it never overflows
      Flexible(
        flex: 7,
        child: FadeTransition(
          opacity: contentFade,
          child: SlideTransition(
            position: contentSlide,
            child: Padding(
              padding: EdgeInsets.fromLTRB(26, 4, 26, bottomPad),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                            color: slide.accentColor,
                            borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 12),
                    Text(slide.title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            height: 1.15,
                            letterSpacing: -0.8)),
                    const SizedBox(height: 10),
                    Text(slide.subtitle,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 14,
                            height: 1.55,
                            fontWeight: FontWeight.w400)),
                  ]),
            ),
          ),
        ),
      ),
    ]);
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ILLUSTRATIONS
// ══════════════════════════════════════════════════════════════════════════════
class _MapIllustration extends StatelessWidget {
  final AnimationController controller;
  const _MapIllustration({required this.controller});
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Stack(children: [
      Positioned.fill(child: CustomPaint(painter: _MapPainter())),
      Positioned.fill(
          child: DecoratedBox(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
            Colors.transparent,
            const Color(0xFF0D1B2A).withOpacity(0.75)
          ])))),
      _FloatingCar(
          x: 0.05, y: 0.12, size: 42, delay: 0.0, ctrl: controller, sw: w),
      _FloatingCar(
          x: 0.60, y: 0.22, size: 34, delay: 0.3, ctrl: controller, sw: w),
      _FloatingCar(
          x: 0.12, y: 0.65, size: 38, delay: 0.6, ctrl: controller, sw: w),
      _FloatingCar(
          x: 0.66, y: 0.58, size: 30, delay: 0.9, ctrl: controller, sw: w),
      Center(
          child: Container(
        width: 130,
        height: 210,
        decoration: BoxDecoration(
            color: const Color(0xFF1A2840),
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 28,
                  offset: const Offset(0, 10))
            ]),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.location_on_rounded, color: AppColors.secondary, size: 28),
          const SizedBox(height: 8),
          Text('Finding\nyour ride',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 12,
                  height: 1.5)),
          const SizedBox(height: 12),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(20)),
              child: const Text('2 min away',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700))),
        ]),
      )),
    ]);
  }
}

class _FloatingCar extends StatelessWidget {
  final double x, y, size, delay, sw;
  final AnimationController ctrl;
  const _FloatingCar(
      {required this.x,
      required this.y,
      required this.size,
      required this.delay,
      required this.ctrl,
      required this.sw});
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: ctrl,
        builder: (_, __) {
          final t = (ctrl.value + delay) % 1.0;
          return Positioned(
              left: x * sw,
              top: y * 280 + sin(t * 2 * pi) * 7,
              child: Icon(Icons.directions_car_rounded,
                  color: AppColors.accent, size: size));
        },
      );
}

class _TrackingIllustration extends StatelessWidget {
  final AnimationController controller;
  const _TrackingIllustration({required this.controller});
  @override
  Widget build(BuildContext context) => Stack(children: [
        Positioned.fill(
            child: CustomPaint(
                painter: _MapPainter(tint: const Color(0xFF0A1628)))),
        Positioned.fill(
            child: DecoratedBox(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
              Colors.transparent,
              const Color(0xFF0A1628).withOpacity(0.8)
            ])))),
        Center(
            child: CustomPaint(
                size: const Size(280, 260), painter: _RoutePainter())),
        Positioned(
            left: 65,
            top: 120,
            child: AnimatedBuilder(
                animation: controller,
                builder: (_, __) {
                  final p = sin(controller.value * 2 * pi) * 0.3 + 0.7;
                  return Stack(alignment: Alignment.center, children: [
                    Container(
                        width: 56 * p,
                        height: 56 * p,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.accent.withOpacity(0.15 * p))),
                    Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.accent,
                            boxShadow: [
                              BoxShadow(
                                  color: AppColors.accent.withOpacity(0.5),
                                  blurRadius: 14)
                            ]),
                        child: const Icon(Icons.directions_car_rounded,
                            color: Colors.white, size: 19)),
                  ]);
                })),
        Positioned(
            right: 65,
            top: 85,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.secondary,
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.secondary.withOpacity(0.5),
                            blurRadius: 14)
                      ]),
                  child: const Icon(Icons.location_on_rounded,
                      color: Colors.white, size: 22)),
              const SizedBox(height: 5),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(6)),
                  child: const Text('Destination',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700))),
            ])),
        Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
                child: AnimatedBuilder(
              animation: controller,
              builder: (_, __) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white.withOpacity(0.2))),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.access_time_rounded,
                      color: Colors.white, size: 15),
                  const SizedBox(width: 5),
                  Text('ETA: ${4 - (controller.value * 0.5).round()} mins',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ]),
              ),
            ))),
      ]);
}

class _SafetyIllustration extends StatelessWidget {
  final AnimationController controller;
  const _SafetyIllustration({required this.controller});
  @override
  Widget build(BuildContext context) => Stack(children: [
        const Positioned.fill(
            child: DecoratedBox(
                decoration: BoxDecoration(
                    gradient: RadialGradient(
                        center: Alignment(0, -0.3),
                        radius: 1.0,
                        colors: [Color(0xFF0D2540), Color(0xFF0A1628)])))),
        Positioned.fill(
            child: CustomPaint(
                painter: _DotGridPainter(
                    color: const Color(0xFF00B4D8), opacity: 0.04))),
        Center(
            child: AnimatedBuilder(
                animation: controller,
                builder: (_, __) {
                  final g = sin(controller.value * 2 * pi) * 0.2 + 0.8;
                  return Column(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF00B4D8).withOpacity(0.1 * g),
                            border: Border.all(
                                color: const Color(0xFF00B4D8)
                                    .withOpacity(0.35 * g),
                                width: 2),
                            boxShadow: [
                              BoxShadow(
                                  color: const Color(0xFF00B4D8)
                                      .withOpacity(0.15 * g),
                                  blurRadius: 28)
                            ]),
                        child: const Icon(Icons.verified_user_rounded,
                            color: Color(0xFF00B4D8), size: 62)),
                    const SizedBox(height: 20),
                    ...[
                      ('Verified Drivers', Icons.badge_rounded),
                      ('Secure Payments', Icons.lock_rounded),
                      ('24/7 Support', Icons.headset_mic_rounded)
                    ].map((item) => Container(
                        margin: const EdgeInsets.only(bottom: 9),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.1))),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(item.$2,
                              color: const Color(0xFF00B4D8), size: 17),
                          const SizedBox(width: 10),
                          Text(item.$1,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                        ]))),
                  ]);
                })),
      ]);
}

class _EarningsIllustration extends StatelessWidget {
  final AnimationController controller;
  const _EarningsIllustration({required this.controller});
  @override
  Widget build(BuildContext context) => Stack(children: [
        const Positioned.fill(
            child: DecoratedBox(
                decoration: BoxDecoration(
                    gradient: RadialGradient(
                        center: Alignment(0.2, -0.4),
                        radius: 1.1,
                        colors: [Color(0xFF1A3020), Color(0xFF0F1923)])))),
        Positioned.fill(
            child: CustomPaint(
                painter: _DotGridPainter(
                    color: AppColors.secondary, opacity: 0.04))),
        Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 270,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.secondary.withOpacity(0.3), width: 1.5)),
              child: Column(children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('This Week',
                          style:
                              TextStyle(color: Colors.white54, fontSize: 12)),
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 3),
                          decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20)),
                          child: Text('+12%',
                              style: TextStyle(
                                  color: AppColors.secondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700))),
                    ]),
                const SizedBox(height: 6),
                AnimatedBuilder(
                    animation: controller,
                    builder: (_, __) {
                      final n = 24500 +
                          (sin(controller.value * 2 * pi) * 500).round();
                      final f = n.toString().replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (m) => '${m[1]},');
                      return Text('₦$f',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1));
                    }),
                const SizedBox(height: 14),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [0.4, 0.7, 0.5, 0.9, 0.6, 0.8, 1.0]
                        .asMap()
                        .entries
                        .map((e) {
                      final isToday = e.key == 6;
                      return AnimatedBuilder(
                          animation: controller,
                          builder: (_, __) {
                            final b = isToday
                                ? sin(controller.value * 2 * pi) * 0.06 + 1.0
                                : 1.0;
                            return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                      width: 22,
                                      height: 54 * e.value * b,
                                      decoration: BoxDecoration(
                                          color: isToday
                                              ? AppColors.secondary
                                              : AppColors.secondary
                                                  .withOpacity(0.3),
                                          borderRadius:
                                              BorderRadius.circular(4))),
                                  const SizedBox(height: 4),
                                  Text(
                                      [
                                        'M',
                                        'T',
                                        'W',
                                        'T',
                                        'F',
                                        'S',
                                        'S'
                                      ][e.key],
                                      style: TextStyle(
                                          color: Colors.white.withOpacity(0.4),
                                          fontSize: 9)),
                                ]);
                          });
                    }).toList()),
              ])),
          const SizedBox(height: 14),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _SChip('42', 'Trips', AppColors.secondary),
            const SizedBox(width: 9),
            _SChip('4.9★', 'Rating', AppColors.accent),
            const SizedBox(width: 9),
            _SChip('8h', 'Online', const Color(0xFF00B4D8)),
          ]),
        ])),
      ]);
}

class _SChip extends StatelessWidget {
  final String v, l;
  final Color c;
  const _SChip(this.v, this.l, this.c);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
            color: c.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: c.withOpacity(0.3))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(v,
              style: TextStyle(
                  color: c, fontSize: 14, fontWeight: FontWeight.w800)),
          Text(l,
              style:
                  TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 9)),
        ]),
      );
}

// PAINTERS
class _MapPainter extends CustomPainter {
  final Color? tint;
  const _MapPainter({this.tint});
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h),
        Paint()..color = tint ?? const Color(0xFFD4E6C3));
    final water = Paint()..color = const Color(0xFF9DC3D4);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(w * .35, h * .28, w * .28, h * .12),
            const Radius.circular(8)),
        water);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(-w * .05, h * .60, w * .22, h * .18),
            const Radius.circular(6)),
        water);
    final park = Paint()..color = const Color(0xFF8BBD6B);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(w * .05, h * .15, w * .18, h * .10),
            const Radius.circular(6)),
        park);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(w * .65, h * .48, w * .20, h * .09),
            const Radius.circular(6)),
        park);
    final block = Paint()
      ..color = const Color(0xFFBFCFBF).withOpacity(tint != null ? 0.3 : 1.0);
    for (int r = 0; r < 6; r++)
      for (int c = 0; c < 4; c++) {
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTWH(w * .08 + c * w * .23, h * .05 + r * h * .16,
                    w * .14, h * .09),
                const Radius.circular(3)),
            block);
      }
    final road = Paint()
      ..color = const Color(0xFFE8E0D0).withOpacity(tint != null ? 0.5 : 1.0)
      ..strokeWidth = 12;
    //final road = Paint()..color = const Color(0xFFE8E0D0).withOpacity(tint != null ? 0.5 : 1.0)..strokeWidth = 12;
    for (int i = 0; i < 7; i++)
      canvas.drawLine(Offset(0, h * (0.10 + i * 0.14)),
          Offset(w, h * (0.10 + i * 0.14)), road);
    for (int i = 0; i < 5; i++)
      canvas.drawLine(Offset(w * (0.12 + i * 0.22), 0),
          Offset(w * (0.12 + i * 0.22), h), road);
    final dash = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 1.5;
    for (int i = 0; i < 7; i++) {
      final y = h * (0.10 + i * 0.14);
      for (double x = 0; x < w; x += 22)
        canvas.drawLine(Offset(x, y), Offset(x + 10, y), dash);
    }
    final pin = Paint()..color = const Color(0xFFCC2222);
    final px = w * 0.72;
    final py = h * 0.42;
    canvas.drawCircle(Offset(px, py), 22, pin);
    canvas.drawPath(
        Path()
          ..moveTo(px, py + 22)
          ..lineTo(px - 12, py + 42)
          ..lineTo(px + 12, py + 42)
          ..close(),
        pin);
    canvas.drawCircle(Offset(px, py), 9, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
        Path()
          ..moveTo(size.width * .2, size.height * .65)
          ..cubicTo(size.width * .25, size.height * .3, size.width * .6,
              size.height * .7, size.width * .75, size.height * .35),
        Paint()
          ..color = AppColors.accent.withOpacity(0.7)
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

class _DotGridPainter extends CustomPainter {
  final Color color;
  final double opacity;
  const _DotGridPainter({required this.color, this.opacity = 0.08});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withOpacity(opacity);
    const s = 28.0;
    for (double x = 0; x < size.width; x += s)
      for (double y = 0; y < size.height; y += s)
        canvas.drawCircle(Offset(x, y), 1.5, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}
