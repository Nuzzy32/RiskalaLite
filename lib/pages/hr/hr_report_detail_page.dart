import 'package:flutter/material.dart';
import '../../data/dummy_data.dart';

class HrReportDetailPage extends StatelessWidget {
  final EmployeeStressData employee;
  final String reportDate;

  const HrReportDetailPage({
    super.key,
    required this.employee,
    required this.reportDate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 140),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildEmployeeCard(),
                    const SizedBox(height: 20),
                    _buildWeeklyAssessment(),
                    const SizedBox(height: 24),
                    _buildCommentSection(),
                    const SizedBox(height: 28),
                    _buildActionButton(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios, size: 22, color: Color(0xFF245A72)),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Report Details',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF245A72),
                ),
              ),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2F4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.description_outlined, color: Color(0xFF245A72), size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard() {
    final riskLabel = employee.stressLevel == 'high'
        ? 'HIGH RISK'
        : employee.stressLevel == 'moderate'
            ? 'MODERATE RISK'
            : 'LOW RISK';

    Color badgeBg;
    Color badgeText;
    switch (employee.stressLevel) {
      case 'high':
        badgeBg = const Color(0xFFFCE7F3);
        badgeText = const Color(0xFF9D174D);
      case 'moderate':
        badgeBg = const Color(0xFFFEF9C3);
        badgeText = const Color(0xFF854D0E);
      default:
        badgeBg = const Color(0xFFDCFCE7);
        badgeText = const Color(0xFF166534);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE2E8F0).withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF245A72).withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFFF3F4F6),
              child: const Icon(Icons.person, color: Color(0xFF245A72), size: 28),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        employee.name.split(' ').first,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF245A72),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text(
                          riskLabel,
                          style: TextStyle(
                            fontFamily: 'NimbusSans',
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: badgeText,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${employee.division} Division',
                    style: TextStyle(
                      fontFamily: 'NimbusSans',
                      fontSize: 13,
                      color: const Color(0xFF245A72).withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    'REPORTED: ${reportDate.toUpperCase()}, 2023',
                    style: TextStyle(
                      fontFamily: 'NimbusSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF245A72).withValues(alpha: 0.4),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyAssessment() {
    // Dummy assessment data based on stress score
    final workloadScore = (employee.stressScore * 1.05).clamp(0, 100).round();
    final emotionalScore = (employee.stressScore * 0.85).clamp(0, 100).round();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE2E8F0).withValues(alpha: 0.5)),
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
            const Text(
              'Weekly Stress Assessment',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF245A72),
              ),
            ),
            const SizedBox(height: 20),
            _buildAssessmentBar('Tekanan Beban Kerja', workloadScore),
            const SizedBox(height: 16),
            _buildAssessmentBar('Kelelahan Emosional', emotionalScore),
          ],
        ),
      ),
    );
  }

  Widget _buildAssessmentBar(String label, int percent) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'NimbusSans',
                fontSize: 13,
                color: const Color(0xFF245A72).withValues(alpha: 0.7),
              ),
            ),
            Text(
              '$percent%',
              style: const TextStyle(
                fontFamily: 'NimbusSans',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF245A72),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 10,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(9999),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percent / 100,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9999),
                gradient: const LinearGradient(
                  colors: [Color(0xFF61D1DB), Color(0xFF245A72)],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentSection() {
    // Dummy comment based on stress level
    final comments = {
      'high': '"Batas waktu Q4 saat ini tumpang tindih secara signifikan dengan proyek restrukturisasi. Saya kesulitan mempertahankan kualitas hasil kerja sambil mengelola peningkatan volume laporan. Membutuhkan dukungan dalam memprioritaskan tugas."',
      'moderate': '"Beban kerja meningkat belakangan ini, tetapi masih bisa dikelola. Beberapa deadline yang berdekatan membuat saya perlu mengatur ulang prioritas. Akan lebih baik jika ada sedikit fleksibilitas waktu."',
      'low': '"Kondisi kerja saat ini cukup baik dan sesuai kapasitas. Tim bekerja dengan baik dan komunikasi lancar. Tidak ada kendala berarti yang mempengaruhi produktivitas."',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Komentar karyawan & Laporan insiden',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF245A72),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFB3F3F4).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              comments[employee.stressLevel] ?? comments['low']!,
              style: TextStyle(
                fontFamily: 'NimbusSans',
                fontSize: 13,
                height: 1.6,
                color: const Color(0xFF245A72).withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tindak lanjut akan dihubungi segera'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF61D1DB),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Tindak lanjut dengan karyawan',
            style: TextStyle(
              fontFamily: 'NimbusSans',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}
