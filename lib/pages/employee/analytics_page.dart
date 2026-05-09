import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AnalyticsPage extends StatefulWidget {
  final bool showNav;
  const AnalyticsPage({super.key, this.showNav = true});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  bool _loading = true;

  // Mood 7 hari: index 0=Sen ... 6=Min, value 0=no data, 1-4=mood level
  final List<int> _moodData = List.filled(7, 0);

  // Stress 4 minggu
  final List<double> _stressScores = [0, 0, 0, 0];
  bool _hasStressData = false;
  bool _hasMoodData = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        ApiService.getMoodWeekly(),
        ApiService.getAssessmentHistory(),
      ]);

      final moods = results[0];
      final assessments = results[1];

      _buildMoodData(moods);
      _buildStressData(assessments);
    } catch (_) {}

    setState(() => _loading = false);
  }

  void _buildMoodData(List<Map<String, dynamic>> moods) {
    for (final m in moods) {
      final date = DateTime.tryParse(m['tgl_M']?.toString() ?? '');
      if (date == null) continue;
      // weekday: 1=Mon .. 7=Sun → index 0..6
      final idx = date.weekday - 1;
      _moodData[idx] = (m['level_mood'] as num?)?.toInt() ?? 0;
      _hasMoodData = true;
    }
  }

  void _buildStressData(List<Map<String, dynamic>> assessments) {
    if (assessments.isEmpty) return;
    _hasStressData = true;

    final now = DateTime.now();
    final weekScores = List<List<double>>.generate(4, (_) => []);

    for (final a in assessments) {
      final date = DateTime.tryParse(a['tgl_SA']?.toString() ?? '');
      if (date == null) continue;
      final daysAgo = now.difference(date).inDays;
      final weekIdx = (daysAgo / 7).floor();
      if (weekIdx >= 0 && weekIdx < 4) {
        final score = ((a['total_score'] as num?)?.toDouble() ?? 0) / 50 * 100;
        weekScores[weekIdx].add(score);
      }
    }

    for (int i = 0; i < 4; i++) {
      if (weekScores[i].isNotEmpty) {
        _stressScores[3 - i] = weekScores[i].reduce((a, b) => a + b) / weekScores[i].length;
      }
    }
  }

  static const _days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        bottom: false,
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF245A72)))
            : RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 140),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      _buildMoodTrendSection(),
                      const SizedBox(height: 24),
                      _buildStressSection(),
                      const SizedBox(height: 24),
                      _buildInsightsCard(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildMoodTrendSection() {
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
                const Text('Mood Trend',
                    style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF245A72))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB3F3F4).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text('7 Hari',
                      style: TextStyle(
                          fontFamily: 'NimbusSans',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF61D1DB))),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (!_hasMoodData)
              _buildEmptyChartState('Belum ada data mood minggu ini')
            else
              SizedBox(
                height: 140,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(7, (i) {
                    final score = _moodData[i];
                    final hasData = score > 0;
                    final fraction = hasData ? score / 4 : 0.1;
                    return Expanded(
                      child: GestureDetector(
                        onTap: hasData
                            ? () => _showMoodDetail(i, score)
                            : null,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(
                                hasData
                                    ? _moodIcon(score)
                                    : Icons.remove,
                                size: 16,
                                color: hasData
                                    ? _moodColor(score)
                                    : const Color(0xFF245A72).withValues(alpha: 0.15),
                              ),
                              const SizedBox(height: 6),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                height: 80 * fraction,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  gradient: hasData
                                      ? LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [
                                            _moodColor(score).withValues(alpha: 0.8),
                                            _moodColor(score).withValues(alpha: 0.4),
                                          ],
                                        )
                                      : LinearGradient(colors: [
                                          const Color(0xFF245A72).withValues(alpha: 0.08),
                                          const Color(0xFF245A72).withValues(alpha: 0.04),
                                        ]),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _days[i],
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
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showMoodDetail(int dayIdx, int score) {
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
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF245A72).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: _moodColor(score).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(_moodIcon(score), size: 36, color: _moodColor(score)),
            ),
            const SizedBox(height: 16),
            Text('Hari ${_days[dayIdx]}',
                style: TextStyle(
                    fontFamily: 'NimbusSans',
                    fontSize: 13,
                    color: const Color(0xFF245A72).withValues(alpha: 0.5))),
            const SizedBox(height: 4),
            Text('Suasana Hati: ${_moodLabel(score)}',
                style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF245A72))),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: _moodColor(score).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text('Skor: $score/4',
                  style: TextStyle(
                      fontFamily: 'NimbusSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _moodColor(score))),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStressSection() {
    final validScores = _stressScores.where((s) => s > 0).toList();

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
                const Text('Stress Level',
                    style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF245A72))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB3F3F4).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text('4 Minggu',
                      style: TextStyle(
                          fontFamily: 'NimbusSans',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF61D1DB))),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (!_hasStressData || validScores.isEmpty)
              _buildEmptyChartState('Belum ada data stress assessment')
            else
              SizedBox(
                height: 140,
                child: LayoutBuilder(
                  builder: (ctx, constraints) {
                    return Stack(
                      children: [
                        CustomPaint(
                          size: Size(constraints.maxWidth, 140),
                          painter: _StressChartPainter(_stressScores),
                        ),
                        ...List.generate(4, (i) {
                          final x = i == 0
                              ? 0.0
                              : (i / 3) * constraints.maxWidth;
                          final s = _stressScores[i];
                          final y = 140 - (s / 100) * 140;
                          return Positioned(
                            left: x - 20,
                            top: y - 20,
                            width: 40,
                            height: 40,
                            child: GestureDetector(
                              onTap: s > 0
                                  ? () => _showStressDetail(i, s)
                                  : null,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Text('Mg 1', style: TextStyle(fontFamily: 'NimbusSans', fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                Text('Mg 2', style: TextStyle(fontFamily: 'NimbusSans', fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                Text('Mg 3', style: TextStyle(fontFamily: 'NimbusSans', fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                Text('Mg 4', style: TextStyle(fontFamily: 'NimbusSans', fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showStressDetail(int weekIdx, double score) {
    final level = score >= 60 ? 'Tinggi' : score >= 40 ? 'Sedang' : 'Rendah';
    final levelColor = score >= 60
        ? const Color(0xFFFB923C)
        : score >= 40
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
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF245A72).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 80, height: 80,
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
              child: Text('${score.round()}',
                  style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: levelColor)),
            ),
            const SizedBox(height: 16),
            Text('Minggu ${weekIdx + 1}',
                style: TextStyle(
                    fontFamily: 'NimbusSans',
                    fontSize: 13,
                    color: const Color(0xFF245A72).withValues(alpha: 0.5))),
            const SizedBox(height: 4),
            Text('Skor Stress: ${score.round()}/100',
                style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF245A72))),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: levelColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text('Level: $level',
                  style: TextStyle(
                      fontFamily: 'NimbusSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: levelColor)),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsCard() {
    final avgMood = _hasMoodData
        ? _moodData.where((s) => s > 0).fold(0, (sum, s) => sum + s) /
            _moodData.where((s) => s > 0).length
        : 0.0;
    final lastStress = _stressScores.lastWhere((s) => s > 0, orElse: () => 0);

    String insight;
    if (!_hasMoodData && !_hasStressData) {
      insight = 'Mulai isi mood harian dan stress assessment untuk melihat ringkasan kondisi kesehatan mentalmu di sini.';
    } else if (lastStress < 45 && avgMood >= 3) {
      insight = 'Stress level kamu menurun dan mood kamu stabil minggu ini. Pertahankan kebiasaan wellness kamu!';
    } else if (lastStress >= 60) {
      insight = 'Stress level kamu cukup tinggi minggu ini. Coba luangkan waktu untuk meditasi dan istirahat yang cukup.';
    } else {
      insight = 'Mood dan stress kamu dalam level moderate. Terus pantau kondisi kamu dan jangan ragu untuk meminta bantuan.';
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
                  child: const Icon(Icons.auto_awesome_outlined,
                      size: 20, color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Text('Insights',
                    style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
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

  Widget _buildEmptyChartState(String message) {
    return SizedBox(
      height: 100,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart_outlined, size: 32,
                color: const Color(0xFF245A72).withValues(alpha: 0.15)),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontFamily: 'NimbusSans',
                fontSize: 13,
                color: const Color(0xFF245A72).withValues(alpha: 0.35),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StressChartPainter extends CustomPainter {
  final List<double> data;
  _StressChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final validPoints = data.where((s) => s > 0).toList();
    if (validPoints.length < 2) return;

    final points = <Offset>[];
    for (var i = 0; i < data.length; i++) {
      final x = i == 0 ? 0.0 : (i / (data.length - 1)) * size.width;
      final y = data[i] > 0
          ? size.height - (data[i] / 100) * size.height
          : size.height;
      points.add(Offset(x, y));
    }

    final activePoints = points.where((p) => p.dy < size.height).toList();
    if (activePoints.length < 2) return;

    final fillPath = Path()..moveTo(activePoints.first.dx, size.height);
    for (final p in activePoints) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(activePoints.last.dx, size.height);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF61D1DB).withValues(alpha: 0.3),
            const Color(0xFF61D1DB).withValues(alpha: 0.02),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    final linePath = Path()..moveTo(activePoints.first.dx, activePoints.first.dy);
    for (var i = 1; i < activePoints.length; i++) {
      final prev = activePoints[i - 1];
      final curr = activePoints[i];
      final cpX = (prev.dx + curr.dx) / 2;
      linePath.cubicTo(cpX, prev.dy, cpX, curr.dy, curr.dx, curr.dy);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = const Color(0xFF61D1DB)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    for (final p in activePoints) {
      canvas.drawCircle(p, 8, Paint()..color = const Color(0xFF61D1DB).withValues(alpha: 0.15));
      canvas.drawCircle(p, 5, Paint()..color = Colors.white);
      canvas.drawCircle(p, 3.5, Paint()..color = const Color(0xFF61D1DB));

      final score = 100 - ((p.dy / size.height) * 100);
      final tp = TextPainter(
        text: TextSpan(
          text: '${score.round()}',
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
