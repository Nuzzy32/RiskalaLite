import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/dummy_data.dart';
import 'hr_division_detail_page.dart';

class HrEmployeesPage extends StatelessWidget {
  final bool showNav;
  const HrEmployeesPage({super.key, this.showNav = true});

  @override
  Widget build(BuildContext context) {
    final counts = DummyStressData.divisionCounts;
    final maxCount = counts.values.reduce(max);
    final avgStress = DummyStressData.companyAvgStress;
    final stressPercent = avgStress / 100;
    final stressLabel = avgStress < 40 ? 'OPTIMAL' : avgStress < 70 ? 'MODERATE' : 'HIGH';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 140),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Employee Overview',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF245A72),
                        letterSpacing: -0.6,
                      ),
                    ),
                    ClipOval(
                      child: Container(
                        width: 40,
                        height: 40,
                        color: const Color(0xFFE0F2F4),
                        child: const Icon(Icons.person, color: Color(0xFF245A72), size: 20),
                      ),
                    ),
                  ],
                ),
              ),

              // Stress Score Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: const Color(0xFFEFF6FF).withValues(alpha: 0.5)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF245A72).withValues(alpha: 0.05),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                        spreadRadius: -5,
                      ),
                      BoxShadow(
                        color: const Color(0xFF245A72).withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 8),
                        spreadRadius: -6,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Cumulative Company Stress\nScore',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF245A72).withValues(alpha: 0.6),
                          height: 1.43,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 192,
                        height: 192,
                        child: CustomPaint(
                          painter: _DonutChartPainter(stressPercent),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${avgStress.round()}%',
                                  style: const TextStyle(
                                    fontFamily: 'Liberation Sans',
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF245A72),
                                  ),
                                ),
                                Text(
                                  stressLabel,
                                  style: const TextStyle(
                                    fontFamily: 'Liberation Sans',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF61D1DB),
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Division Statistics Section
              const Padding(
                padding: EdgeInsets.fromLTRB(28, 0, 24, 0),
                child: Text(
                  'Total Employees by Division',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF245A72),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Division rows
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: divisionInfoList.map((info) {
                    final count = counts[info.name] ?? 0;
                    return _buildDivisionRow(
                      context,
                      name: info.name,
                      icon: info.icon,
                      count: count,
                      barFraction: maxCount > 0 ? count / maxCount : 0,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivisionRow(
    BuildContext context, {
    required String name,
    required IconData icon,
    required int count,
    required double barFraction,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HrDivisionDetailPage(divisionName: name),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFB3F3F4).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: const Color(0xFF245A72).withValues(alpha: 0.6)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontFamily: 'NimbusSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF245A72),
                          ),
                        ),
                        Text(
                          '$count',
                          style: const TextStyle(
                            fontFamily: 'NimbusSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF245A72),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 12,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: barFraction,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(9999),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFB3F3F4), Color(0xFF61D1DB)],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final double percentage;
  _DonutChartPainter(this.percentage);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 16.0;
    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    final bgPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    final sweepAngle = 2 * pi * percentage;
    final gradientPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: -pi / 2,
        endAngle: -pi / 2 + sweepAngle,
        colors: const [Color(0xFFB3F3F4), Color(0xFF61D1DB)],
        stops: const [0.0, 1.0],
        transform: const GradientRotation(-pi / 2),
      ).createShader(rect);

    canvas.drawArc(rect, -pi / 2, sweepAngle, false, gradientPaint);
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter old) => old.percentage != percentage;
}
