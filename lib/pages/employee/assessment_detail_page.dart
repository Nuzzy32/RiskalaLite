import 'package:flutter/material.dart';
import '../../data/dummy_data.dart';

class AssessmentDetailPage extends StatelessWidget {
  final AssessmentRecord record;
  const AssessmentDetailPage({super.key, required this.record});

  // Dummy Likert questions + answers for detail view
  static const _questions = [
    'Saya merasa kewalahan dengan beban kerja saya.',
    'Saya sulit berkonsentrasi saat bekerja.',
    'Saya merasa cemas tentang deadline pekerjaan.',
    'Saya mengalami gangguan tidur karena pikiran tentang pekerjaan.',
    'Saya merasa tidak dihargai di tempat kerja.',
    'Saya merasa lelah secara fisik setelah bekerja.',
    'Saya sulit memisahkan waktu kerja dan waktu pribadi.',
    'Saya merasa hubungan dengan rekan kerja kurang baik.',
    'Saya merasa motivasi kerja saya menurun.',
    'Saya merasa tekanan dari atasan terlalu besar.',
  ];

  List<int> _generateAnswers() {
    // Deterministic answers based on score
    final base = record.score / record.maxScore;
    return List.generate(10, (i) {
      final v = ((base * 5) + (i % 3 - 1) * 0.5).clamp(1.0, 5.0);
      return v.round();
    });
  }

  @override
  Widget build(BuildContext context) {
    final answers = _generateAnswers();
    final dateStr =
        '${record.date.day} ${_monthName(record.date.month)} ${record.date.year}';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // Header bar
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
                        child: const Icon(Icons.arrow_back_ios_new,
                            size: 18, color: Color(0xFF245A72)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Detail Asesmen',
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

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
              child: Column(
                children: [
                  // Header card
                  _buildHeaderCard(dateStr),
                  const SizedBox(height: 24),
                  // Questions list
                  ...List.generate(_questions.length, (i) {
                    return _buildQuestionCard(i + 1, _questions[i], answers[i]);
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(String dateStr) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment(-0.7, -1),
          end: Alignment(0.7, 1),
          colors: [Color(0xFFB3F3F4), Color(0xFF61D1DB)],
        ),
        borderRadius: BorderRadius.circular(24),
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
        children: [
          Text(
            dateStr,
            style: TextStyle(
              fontFamily: 'NimbusSans',
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.85),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${record.score}/${record.maxScore}',
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Total Skor',
            style: TextStyle(
              fontFamily: 'NimbusSans',
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          _buildBadge(record.stressLevel),
        ],
      ),
    );
  }

  Widget _buildBadge(String level) {
    final (Color bg, Color text, String label) = switch (level) {
      'low' => (
        Colors.white.withValues(alpha: 0.3),
        Colors.white,
        'LOW STRESS'
      ),
      'moderate' => (
        Colors.white.withValues(alpha: 0.3),
        Colors.white,
        'MODERATE STRESS'
      ),
      'high' => (
        Colors.white.withValues(alpha: 0.3),
        Colors.white,
        'HIGH STRESS'
      ),
      _ => (Colors.white.withValues(alpha: 0.3), Colors.white, level.toUpperCase()),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'NimbusSans',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: text,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildQuestionCard(int number, String question, int answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pertanyaan $number',
            style: TextStyle(
              fontFamily: 'NimbusSans',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF61D1DB),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            question,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF245A72),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          // Likert scale display
          Row(
            children: List.generate(5, (i) {
              final score = i + 1;
              final isSelected = score == answer;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: i < 4 ? 8 : 0),
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF61D1DB)
                        : const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF61D1DB)
                          : const Color(0xFF245A72).withValues(alpha: 0.1),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$score',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF245A72).withValues(alpha: 0.5),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sangat Tidak Setuju',
                style: TextStyle(
                  fontFamily: 'NimbusSans',
                  fontSize: 9,
                  color: const Color(0xFF245A72).withValues(alpha: 0.4),
                ),
              ),
              Text(
                'Sangat Setuju',
                style: TextStyle(
                  fontFamily: 'NimbusSans',
                  fontSize: 9,
                  color: const Color(0xFF245A72).withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _monthName(int m) {
    const months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return months[m];
  }
}
