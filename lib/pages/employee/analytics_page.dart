import 'package:flutter/material.dart';
import '../../data/dummy_data.dart';

class AnalyticsPage extends StatelessWidget {
  final bool showNav;
  const AnalyticsPage({super.key, this.showNav = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 140),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Text(
                  'Analytics',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF245A72),
                    letterSpacing: -0.6,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Ringkasan mood & stress kamu minggu ini',
                  style: TextStyle(
                    fontFamily: 'NimbusSans',
                    fontSize: 14,
                    color: const Color(0xFF245A72).withValues(alpha: 0.5),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Mood Trend
              _buildMoodTrendSection(context),
              const SizedBox(height: 24),

              // Stress Level
              _buildStressSection(context),
              const SizedBox(height: 24),

              // Insights
              _buildInsightsCard(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Mood Trend (7-day bar chart) ──────────────────────────────────────────

  Widget _buildMoodTrendSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF245A72).withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mood Trend',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF245A72),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB3F3F4).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    '7 Hari',
                    style: TextStyle(
                      fontFamily: 'NimbusSans',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF61D1DB),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Bar chart
            SizedBox(
              height: 140,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: DummyMoodHistory.last7Days.map((entry) {
                  final fraction = entry.moodScore / 4;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _showMoodDetail(context, entry),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              _moodIcon(entry.moodScore),
                              size: 16,
                              color: _moodColor(entry.moodScore),
                            ),
                            const SizedBox(height: 6),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              height: 80 * fraction,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    _moodColor(entry.moodScore).withValues(alpha: 0.8),
                                    _moodColor(entry.moodScore).withValues(alpha: 0.4),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              entry.day,
                              style: TextStyle(
                                fontFamily: 'NimbusSans',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF245A72).withValues(alpha: 0.45),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _moodIcon(int score) => switch (score) {
        4 => Icons.sentiment_very_satisfied,
        3 => Icons.sentiment_satisfied,
        2 => Icons.sentiment_neutral,
        _ => Icons.sentiment_dissatisfied,
      };

  Color _moodColor(int score) => switch (score) {
        4 => const Color(0xFF61D1DB),
        3 => const Color(0xFF60A5FA),
        2 => const Color(0xFFFBBF24),
        _ => const Color(0xFFFB923C),
      };

  String _moodLabel(int score) => switch (score) {
        4 => 'Sangat Baik',
        3 => 'Baik',
        2 => 'Netral',
        _ => 'Kurang Baik',
      };

  // ── Mood Detail Modal ───────────────────────────────────────────────────

  void _showMoodDetail(BuildContext context, MoodEntry entry) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF245A72).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 20),
            // Mood icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _moodColor(entry.moodScore).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _moodIcon(entry.moodScore),
                size: 36,
                color: _moodColor(entry.moodScore),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Hari ${entry.day}',
              style: TextStyle(
                fontFamily: 'NimbusSans',
                fontSize: 13,
                color: const Color(0xFF245A72).withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Suasana Hati: ${_moodLabel(entry.moodScore)}',
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF245A72),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: _moodColor(entry.moodScore).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Skor: ${entry.moodScore}/4',
                style: TextStyle(
                  fontFamily: 'NimbusSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _moodColor(entry.moodScore),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ── Stress Level (4-week interactive chart) ─────────────────────────────

  Widget _buildStressSection(BuildContext context) {
    final weeks = DummyWeeklyStress.last4Weeks;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF245A72).withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Stress Level',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF245A72),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB3F3F4).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    '4 Minggu',
                    style: TextStyle(
                      fontFamily: 'NimbusSans',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF61D1DB),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Line chart with tap overlay
            SizedBox(
              height: 140,
              child: LayoutBuilder(
                builder: (ctx, constraints) {
                  final chartW = constraints.maxWidth;
                  const chartH = 140.0;
                  return Stack(
                    children: [
                      CustomPaint(
                        size: Size(chartW, chartH),
                        painter: _StressChartPainter(weeks),
                      ),
                      // Invisible tap targets on each data point
                      ...List.generate(weeks.length, (i) {
                        final x = (i / (weeks.length - 1)) * chartW;
                        final y = chartH - (weeks[i].avgScore / 100) * chartH;
                        return Positioned(
                          left: x - 20,
                          top: y - 20,
                          width: 40,
                          height: 40,
                          child: GestureDetector(
                            onTap: () => _showStressDetail(context, weeks[i]),
                            behavior: HitTestBehavior.opaque,
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            // Labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: weeks
                  .map((w) => Text(
                        w.label,
                        style: TextStyle(
                          fontFamily: 'NimbusSans',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF245A72).withValues(alpha: 0.45),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Stress Detail Modal ─────────────────────────────────────────────────

  void _showStressDetail(BuildContext context, WeeklyStressEntry entry) {
    final level = entry.avgScore >= 60
        ? 'Tinggi'
        : entry.avgScore >= 40
            ? 'Sedang'
            : 'Rendah';
    final levelColor = entry.avgScore >= 60
        ? const Color(0xFFFB923C)
        : entry.avgScore >= 40
            ? const Color(0xFFFBBF24)
            : const Color(0xFF61D1DB);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF245A72).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 20),
            // Score circle
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    levelColor.withValues(alpha: 0.2),
                    levelColor.withValues(alpha: 0.08),
                  ],
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                '${entry.avgScore.round()}',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: levelColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              entry.label,
              style: TextStyle(
                fontFamily: 'NimbusSans',
                fontSize: 13,
                color: const Color(0xFF245A72).withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Skor Stress: ${entry.avgScore.round()}/100',
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF245A72),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: levelColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Level: $level',
                style: TextStyle(
                  fontFamily: 'NimbusSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: levelColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ── Insights Card ─────────────────────────────────────────────────────────

  Widget _buildInsightsCard() {
    final avgMood = DummyMoodHistory.last7Days
            .fold(0, (sum, e) => sum + e.moodScore) /
        DummyMoodHistory.last7Days.length;
    final lastStress = DummyWeeklyStress.last4Weeks.last.avgScore;

    String insight;
    if (lastStress < 45 && avgMood >= 3) {
      insight =
          'Stress level kamu menurun dan mood kamu stabil minggu ini. Pertahankan kebiasaan wellness kamu!';
    } else if (lastStress >= 60) {
      insight =
          'Stress level kamu cukup tinggi minggu ini. Coba luangkan waktu untuk meditasi dan istirahat yang cukup.';
    } else {
      insight =
          'Mood dan stress kamu dalam level moderate. Terus pantau kondisi kamu dan jangan ragu untuk meminta bantuan.';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment(-0.7, -1),
            end: Alignment(0.7, 1),
            colors: [Color(0xFFB3F3F4), Color(0xFF61D1DB)],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF61D1DB).withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.auto_awesome_outlined, size: 20, color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Insights',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              insight,
              style: TextStyle(
                fontFamily: 'NimbusSans',
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stress Line Chart Painter ────────────────────────────────────────────────

class _StressChartPainter extends CustomPainter {
  final List<WeeklyStressEntry> data;
  _StressChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final points = <Offset>[];
    final count = data.length;
    for (var i = 0; i < count; i++) {
      final x = (i / (count - 1)) * size.width;
      final y = size.height - (data[i].avgScore / 100) * size.height;
      points.add(Offset(x, y));
    }

    // Fill gradient
    final fillPath = Path()..moveTo(points.first.dx, size.height);
    for (final p in points) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF61D1DB).withValues(alpha: 0.3),
          const Color(0xFF61D1DB).withValues(alpha: 0.02),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    // Line
    final linePaint = Paint()
      ..color = const Color(0xFF61D1DB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final cpX = (prev.dx + curr.dx) / 2;
      linePath.cubicTo(cpX, prev.dy, cpX, curr.dy, curr.dx, curr.dy);
    }
    canvas.drawPath(linePath, linePaint);

    // Dots + score labels
    for (var i = 0; i < points.length; i++) {
      final p = points[i];
      canvas.drawCircle(
        p,
        8,
        Paint()..color = const Color(0xFF61D1DB).withValues(alpha: 0.15),
      );
      canvas.drawCircle(p, 5, Paint()..color = Colors.white);
      canvas.drawCircle(p, 3.5, Paint()..color = const Color(0xFF61D1DB));

      final tp = TextPainter(
        text: TextSpan(
          text: '${data[i].avgScore.round()}',
          style: TextStyle(
            fontFamily: 'NimbusSans',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF245A72).withValues(alpha: 0.7),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(p.dx - tp.width / 2, p.dy - 20));
    }
  }

  @override
  bool shouldRepaint(covariant _StressChartPainter old) => true;
}
