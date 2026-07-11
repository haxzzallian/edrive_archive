// lib/features/dashboard/presentation/pages/dashboard_page.dart
//
// Mirrors the web dashboard:
//   - Role badge
//   - Stat cards: Total Rides, Completed, Assigned, Pending, Amount Spent
//   - Status Distribution pie chart (custom painted)
//   - Completion Overview donut chart (custom painted)
//   - Ride Status Breakdown bar chart (custom painted)
//   - Ride Activity Trend line chart (custom painted)
//   - Completion Rate hero card

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/dashboard_entity.dart';
import '../providers/dashboard_notifier.dart';
import '../providers/dashboard_state.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : const Color(0xFFF5F6FA),
      body: SafeArea(
        child: state.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.secondary))
            : state.error != null
                ? _ErrorView(
                    error: state.error!,
                    onRetry: () =>
                        ref.read(dashboardProvider.notifier).refresh())
                : _DashboardContent(state: state, isDark: isDark),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CONTENT
// ══════════════════════════════════════════════════════════════════════════════
class _DashboardContent extends StatelessWidget {
  final DashboardState state;
  final bool isDark;
  const _DashboardContent({required this.state, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final stats = state.stats ?? const RideStatsEntity();
    final profile = state.profile!;

    return RefreshIndicator(
      color: AppColors.secondary,
      onRefresh: () async {},
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Header ─────────────────────────────────────────────────────────
          Row(children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('Your Ride Statistics',
                      style: TextStyle(
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text('Welcome back, ${profile.firstName}',
                      style:
                          TextStyle(color: AppColors.textHint, fontSize: 13)),
                ])),
            Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.divider)),
                child: Text(
                    'Role: ${profile.role[0].toUpperCase()}${profile.role.substring(1)}',
                    style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600))),
          ]),
          const SizedBox(height: 20),

          // ── Stat cards ──────────────────────────────────────────────────────
          _StatCardsRow(stats: stats, isDark: isDark),
          const SizedBox(height: 20),

          // ── Charts row: Status Distribution + Completion Overview ───────────
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
                child: _ChartCard(
                    title: 'Status Distribution',
                    isDark: isDark,
                    child: _StatusPieChart(stats: stats))),
            const SizedBox(width: 12),
            Expanded(
                child: _ChartCard(
                    title: 'Completion Overview',
                    isDark: isDark,
                    child: _CompletionDonut(stats: stats))),
          ]),
          const SizedBox(height: 16),

          // ── Ride Status Breakdown bar chart ─────────────────────────────────
          _ChartCard(
              title: 'Ride Status Breakdown',
              isDark: isDark,
              child: _StatusBarChart(stats: stats, isDark: isDark)),
          const SizedBox(height: 16),

          // ── Ride Activity Trend line chart ──────────────────────────────────
          _ChartCard(
              title: 'Ride Activity Trend',
              isDark: isDark,
              child: _ActivityTrendChart(stats: stats, isDark: isDark)),
          const SizedBox(height: 16),

          // ── Completion rate hero card ───────────────────────────────────────
          _CompletionRateCard(stats: stats, isDark: isDark),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Stat cards row ────────────────────────────────────────────────────────────
class _StatCardsRow extends StatelessWidget {
  final RideStatsEntity stats;
  final bool isDark;
  const _StatCardsRow({required this.stats, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Row 1: Total, Completed, Assigned
      Row(children: [
        Expanded(
            child: _StatCard(
                label: 'Total Rides',
                value: '${stats.totalRides}',
                color: const Color(0xFF3B82F6),
                isDark: isDark)),
        const SizedBox(width: 10),
        Expanded(
            child: _StatCard(
                label: 'Completed',
                value: '${stats.completed}',
                color: AppColors.secondary,
                isDark: isDark)),
        const SizedBox(width: 10),
        Expanded(
            child: _StatCard(
                label: 'Assigned',
                value: '${stats.assigned}',
                color: AppColors.textPrimary,
                isDark: isDark)),
      ]),
      const SizedBox(height: 10),
      // Row 2: Pending, Amount Spent
      Row(children: [
        Expanded(
            child: _StatCard(
                label: 'Pending',
                value: '${stats.pending}',
                color: const Color(0xFFF59E0B),
                isDark: isDark)),
        const SizedBox(width: 10),
        Expanded(
            child: _StatCard(
                label: 'Amount Spent',
                value: '₦${stats.totalSpent.toStringAsFixed(0)}',
                color: const Color(0xFF8B5CF6),
                isDark: isDark)),
        const SizedBox(width: 10),
        Expanded(
            child: _StatCard(
                label: 'Cancelled',
                value: '${stats.cancelled}',
                color: AppColors.error,
                isDark: isDark)),
      ]),
    ]);
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final Color color;
  final bool isDark;
  const _StatCard(
      {required this.label,
      required this.value,
      required this.color,
      required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: TextStyle(
                color: AppColors.textHint,
                fontSize: 10,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(value,
            style: TextStyle(
                color: color, fontSize: 20, fontWeight: FontWeight.w900)),
      ]));
}

// ── Chart card wrapper ────────────────────────────────────────────────────────
class _ChartCard extends StatelessWidget {
  final String title;
  final Widget child;
  final bool isDark;
  const _ChartCard(
      {required this.title, required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3))
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: TextStyle(
                color:
                    isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 14),
        child,
      ]));
}

// ── Status Pie Chart ──────────────────────────────────────────────────────────
class _StatusPieChart extends StatelessWidget {
  final RideStatsEntity stats;
  const _StatusPieChart({required this.stats});

  @override
  Widget build(BuildContext context) {
    final segments = [
      _Seg('Pending', stats.pending, const Color(0xFFF59E0B)),
      _Seg('Negotiating', stats.negotiating, const Color(0xFF3B82F6)),
      _Seg('Assigned', stats.assigned, const Color(0xFFEA580C)),
      _Seg('Accepted', stats.accepted, const Color(0xFF10B981)),
      _Seg('In Progress', stats.inProgress, const Color(0xFF8B5CF6)),
      _Seg('Completed', stats.completed, AppColors.secondary),
      _Seg('Cancelled', stats.cancelled, AppColors.error),
      _Seg('Rejected', stats.rejected, const Color(0xFF6B7280)),
    ].where((s) => s.value > 0).toList();

    final total = segments.fold(0, (s, e) => s + e.value);

    return Column(children: [
      SizedBox(
          height: 140,
          child: CustomPaint(
              painter: _PiePainter(segments: segments, total: total),
              size: const Size(double.infinity, 140))),
      const SizedBox(height: 10),
      Wrap(
          spacing: 8,
          runSpacing: 4,
          children: segments.map((s) => _Legend(s.label, s.color)).toList()),
    ]);
  }
}

// ── Completion Donut ──────────────────────────────────────────────────────────
class _CompletionDonut extends StatelessWidget {
  final RideStatsEntity stats;
  const _CompletionDonut({required this.stats});

  @override
  Widget build(BuildContext context) {
    final active = stats.pending +
        stats.inProgress +
        stats.accepted +
        stats.negotiating +
        stats.assigned;
    final cancelled = stats.cancelled + stats.rejected;
    final segments = [
      _Seg('Completed', stats.completed, AppColors.secondary),
      _Seg('Active / Pending', active, const Color(0xFFF59E0B)),
      _Seg('Cancelled/Rejected', cancelled, AppColors.error),
    ].where((s) => s.value > 0).toList();
    final total = segments.fold(0, (s, e) => s + e.value);

    return Column(children: [
      SizedBox(
          height: 140,
          child: CustomPaint(
              painter:
                  _PiePainter(segments: segments, total: total, donut: true),
              size: const Size(double.infinity, 140))),
      const SizedBox(height: 10),
      Wrap(
          spacing: 8,
          runSpacing: 4,
          children: segments.map((s) => _Legend(s.label, s.color)).toList()),
    ]);
  }
}

// ── Status Bar Chart ──────────────────────────────────────────────────────────
class _StatusBarChart extends StatelessWidget {
  final RideStatsEntity stats;
  final bool isDark;
  const _StatusBarChart({required this.stats, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bars = [
      _Bar('Pending', stats.pending, const Color(0xFFF59E0B)),
      _Bar('Negotiating', stats.negotiating, const Color(0xFF3B82F6)),
      _Bar('Assigned', stats.assigned, const Color(0xFFEA580C)),
      _Bar('Accepted', stats.accepted, const Color(0xFF10B981)),
      _Bar('In Progress', stats.inProgress, const Color(0xFF8B5CF6)),
      _Bar('Completed', stats.completed, AppColors.secondary),
      _Bar('Cancelled', stats.cancelled, AppColors.error),
      _Bar('Rejected', stats.rejected, const Color(0xFF6B7280)),
    ];
    final maxVal = bars.map((b) => b.value).reduce(max).clamp(1, 999999);
    const totalH = 200.0;
    const labelH = 32.0;
    const valH = 16.0;
    const barMaxH = totalH - labelH - valH - 8;

    return ClipRect(
      child: SizedBox(
        height: totalH,
        child: Column(children: [
          // Bar area
          Expanded(
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: bars.map((b) {
                    final barHeight = b.value == 0
                        ? 2.0
                        : (barMaxH * b.value / maxVal).clamp(2.0, barMaxH);
                    return Expanded(
                        child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Value above bar
                                SizedBox(
                                    height: valH,
                                    child: b.value > 0
                                        ? Text('${b.value}',
                                            style: TextStyle(
                                                color: b.color,
                                                fontSize: 9,
                                                fontWeight: FontWeight.w700),
                                            textAlign: TextAlign.center)
                                        : const SizedBox.shrink()),
                                // Bar
                                AnimatedContainer(
                                    duration: const Duration(milliseconds: 600),
                                    height: barHeight,
                                    decoration: BoxDecoration(
                                        color: b.value == 0
                                            ? AppColors.divider
                                            : b.color,
                                        borderRadius:
                                            const BorderRadius.vertical(
                                                top: Radius.circular(4)))),
                              ],
                            )));
                  }).toList())),
          // Labels row — completely separate, fixed height
          SizedBox(
              height: labelH,
              child: Row(
                  children: bars
                      .map((b) => Expanded(
                              child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Text(b.label,
                                style: TextStyle(
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textSecondary,
                                    fontSize: 7,
                                    height: 1.2),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                          )))
                      .toList())),
        ]),
      ),
    );
  }
}

// ── Ride Activity Trend (line chart) ─────────────────────────────────────────
class _ActivityTrendChart extends StatelessWidget {
  final RideStatsEntity stats;
  final bool isDark;
  const _ActivityTrendChart({required this.stats, required this.isDark});

  @override
  Widget build(BuildContext context) {
    // Real data would come from a monthly breakdown endpoint.
    // For now uses total to populate a 6-month simulated trend
    // identical to the web's placeholder pattern.
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
    final completed = <double>[0, 0, 0, 0, 0, stats.completed.toDouble()];
    final cancelled = <double>[0, 0, 0, 0, 0, stats.cancelled.toDouble()];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Legend
      Row(children: [
        _Legend('Completed Rides', AppColors.secondary),
        const SizedBox(width: 16),
        _Legend('Cancelled Rides', AppColors.error),
      ]),
      const SizedBox(height: 12),
      SizedBox(
          height: 140,
          child: CustomPaint(
              painter: _LinePainter(
                  months: months,
                  completedData: completed,
                  cancelledData: cancelled,
                  isDark: isDark),
              size: const Size(double.infinity, 140))),
    ]);
  }
}

// ── Completion Rate hero card ─────────────────────────────────────────────────
class _CompletionRateCard extends StatelessWidget {
  final RideStatsEntity stats;
  final bool isDark;
  const _CompletionRateCard({required this.stats, required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFFEEF2FF), Color(0xFFE0E7FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                blurRadius: 16,
                offset: const Offset(0, 4))
          ]),
      child: Column(children: [
        const Text('Your Completion Rate',
            style: TextStyle(
                color: Color(0xFF4338CA),
                fontSize: 16,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        Text('${stats.completionRate.toStringAsFixed(0)}%',
            style: const TextStyle(
                color: Color(0xFF3730A3),
                fontSize: 48,
                fontWeight: FontWeight.w900,
                letterSpacing: -2)),
        const SizedBox(height: 6),
        Text(
            '${stats.completed} completed rides out of ${stats.totalRides} total',
            style: const TextStyle(color: Color(0xFF6366F1), fontSize: 13)),
      ]));
}

// ══════════════════════════════════════════════════════════════════════════════
// CUSTOM PAINTERS
// ══════════════════════════════════════════════════════════════════════════════

class _Seg {
  final String label;
  final int value;
  final Color color;
  const _Seg(this.label, this.value, this.color);
}

class _Bar {
  final String label;
  final int value;
  final Color color;
  const _Bar(this.label, this.value, this.color);
}

class _PiePainter extends CustomPainter {
  final List<_Seg> segments;
  final int total;
  final bool donut;
  const _PiePainter(
      {required this.segments, required this.total, this.donut = false});

  @override
  void paint(Canvas canvas, Size size) {
    if (total == 0) {
      // Draw empty circle
      final paint = Paint()
        ..color = Colors.grey.withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = donut ? 30 : 1;
      canvas.drawCircle(Offset(size.width / 2, size.height / 2),
          min(size.width, size.height) / 2 - 10, paint);
      return;
    }
    final centre = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 4;
    double startAngle = -pi / 2;

    for (final seg in segments) {
      final sweep = 2 * pi * seg.value / total;
      final paint = Paint()
        ..color = seg.color
        ..style = donut ? PaintingStyle.stroke : PaintingStyle.fill
        ..strokeWidth = donut ? 32 : 1
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(Rect.fromCircle(center: centre, radius: radius),
          startAngle, sweep - 0.02, !donut, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(_PiePainter old) => old.total != total;
}

class _LinePainter extends CustomPainter {
  final List<String> months;
  final List<double> completedData, cancelledData;
  final bool isDark;
  const _LinePainter(
      {required this.months,
      required this.completedData,
      required this.cancelledData,
      required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final allVals = [...completedData, ...cancelledData];
    final maxVal = allVals.reduce(max).clamp(1.0, double.infinity);
    final padL = 24.0;
    final padB = 20.0;
    final w = size.width - padL;
    final h = size.height - padB;
    final n = months.length;

    // Grid lines
    final gridPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withOpacity(0.06)
      ..strokeWidth = 1;
    for (int i = 0; i <= 4; i++) {
      final y = h - h * i / 4;
      canvas.drawLine(Offset(padL, y), Offset(size.width, y), gridPaint);
    }

    // Month labels
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < n; i++) {
      final x = padL + w * i / (n - 1);
      tp.text = TextSpan(
          text: months[i],
          style: TextStyle(
              color: isDark ? Colors.white54 : Colors.black38, fontSize: 9));
      tp.layout();
      tp.paint(canvas, Offset(x - tp.width / 2, h + 5));
    }

    // Draw line
    void drawLine(List<double> data, Color color) {
      final path = Path();
      for (int i = 0; i < n; i++) {
        final x = padL + w * i / (n - 1);
        final y = h - h * data[i] / maxVal;
        i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
      }
      canvas.drawPath(
          path,
          Paint()
            ..color = color
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round);
      // Dots
      for (int i = 0; i < n; i++) {
        final x = padL + w * i / (n - 1);
        final y = h - h * data[i] / maxVal;
        canvas.drawCircle(
            Offset(x, y),
            3,
            Paint()
              ..color = color
              ..style = PaintingStyle.fill);
      }
    }

    drawLine(completedData, AppColors.secondary);
    drawLine(cancelledData, AppColors.error);
  }

  @override
  bool shouldRepaint(_LinePainter old) => false;
}

// ── Legend chip ───────────────────────────────────────────────────────────────
class _Legend extends StatelessWidget {
  final String label;
  final Color color;
  const _Legend(this.label, this.color);
  @override
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(color: AppColors.textHint, fontSize: 10)),
      ]);
}

// ── Error view ────────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.textHint),
        const SizedBox(height: 12),
        Text(error,
            style: const TextStyle(color: AppColors.textHint),
            textAlign: TextAlign.center),
        const SizedBox(height: 16),
        ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary, elevation: 0),
            child: const Text('Retry', style: TextStyle(color: Colors.white))),
      ]));
}
