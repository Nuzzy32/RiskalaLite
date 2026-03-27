import 'package:flutter/material.dart';
import '../../data/dummy_data.dart';
import 'assessment_detail_page.dart';

class AssessmentHistoryPage extends StatelessWidget {
  const AssessmentHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final records = DummyAssessmentHistory.records;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // Header
          Container(
            color: const Color(0xFFF8F9FA),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF245A72)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Assessment History',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF245A72),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              itemCount: records.length,
              itemBuilder: (context, index) => GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AssessmentDetailPage(record: records[index]),
                  ),
                ),
                child: _buildCard(records[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(AssessmentRecord record) {
    final dateStr = '${record.date.day}/${record.date.month}/${record.date.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF245A72).withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Row(
        children: [
          // Date circle
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFB3F3F4).withValues(alpha: 0.5),
                  const Color(0xFF61D1DB).withValues(alpha: 0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${record.date.day}',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF245A72),
                    height: 1,
                  ),
                ),
                Text(
                  _monthAbbr(record.date.month),
                  style: TextStyle(
                    fontFamily: 'NimbusSans',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF245A72).withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stress Assessment',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF245A72),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontFamily: 'NimbusSans',
                    fontSize: 12,
                    color: const Color(0xFF245A72).withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          // Score + Badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${record.score}/${record.maxScore}',
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF245A72),
                ),
              ),
              const SizedBox(height: 4),
              _buildBadge(record.stressLevel),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String level) {
    final (Color bg, Color text, String label) = switch (level) {
      'low' => (const Color(0xFFDCFCE7), const Color(0xFF166534), 'LOW'),
      'moderate' => (const Color(0xFFFEF9C3), const Color(0xFF854D0E), 'MODERATE'),
      'high' => (const Color(0xFFFCE7F3), const Color(0xFF9D174D), 'HIGH'),
      _ => (const Color(0xFFF1F5F9), const Color(0xFF64748B), level.toUpperCase()),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'NimbusSans',
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: text,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  String _monthAbbr(int m) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return months[m];
  }
}
