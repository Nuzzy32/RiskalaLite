import 'package:flutter/material.dart';
import '../../data/dummy_data.dart';

class ReportDetailPage extends StatelessWidget {
  final IncidentReport report;
  const ReportDetailPage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${report.date.day} ${_monthName(report.date.month)} ${report.date.year}';

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
                      'Detail Laporan',
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header card
                  _buildHeaderCard(dateStr),
                  const SizedBox(height: 20),

                  // Description
                  _buildSection(
                    title: 'Deskripsi Keluhan',
                    icon: Icons.description_outlined,
                    child: Text(
                      report.description,
                      style: const TextStyle(
                        fontFamily: 'NimbusSans',
                        fontSize: 14,
                        color: Color(0xFF245A72),
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stress level
                  _buildSection(
                    title: 'Tingkat Stres',
                    icon: Icons.speed_outlined,
                    child: _buildStressIndicator(),
                  ),
                  const SizedBox(height: 16),

                  // HR Response
                  _buildHrResponseSection(),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  report.category,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              _buildStatusBadge(report.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            dateStr,
            style: TextStyle(
              fontFamily: 'NimbusSans',
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.85),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'ID: ${report.id}',
            style: TextStyle(
              fontFamily: 'NimbusSans',
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.6),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final (String label) = switch (status) {
      'pending' => 'MENUNGGU',
      'reviewed' => 'DIPROSES',
      'resolved' => 'SELESAI',
      _ => status.toUpperCase(),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'NimbusSans',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF61D1DB)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF245A72),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildStressIndicator() {
    return Column(
      children: [
        Row(
          children: List.generate(5, (i) {
            final level = i + 1;
            final isActive = level <= report.stressLevel;
            final isCurrent = level == report.stressLevel;
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: i < 4 ? 8 : 0),
                height: 40,
                decoration: BoxDecoration(
                  color: isActive
                      ? _stressColor(report.stressLevel)
                          .withValues(alpha: isCurrent ? 1.0 : 0.4)
                      : const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isActive
                        ? _stressColor(report.stressLevel)
                            .withValues(alpha: 0.5)
                        : const Color(0xFF245A72).withValues(alpha: 0.08),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$level',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isActive
                        ? (isCurrent ? Colors.white : _stressColor(report.stressLevel))
                        : const Color(0xFF245A72).withValues(alpha: 0.3),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Rendah',
              style: TextStyle(
                fontFamily: 'NimbusSans',
                fontSize: 10,
                color: const Color(0xFF245A72).withValues(alpha: 0.4),
              ),
            ),
            Text(
              'Tinggi',
              style: TextStyle(
                fontFamily: 'NimbusSans',
                fontSize: 10,
                color: const Color(0xFF245A72).withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _stressColor(int level) => switch (level) {
        1 => const Color(0xFF61D1DB),
        2 => const Color(0xFF60A5FA),
        3 => const Color(0xFFFBBF24),
        4 => const Color(0xFFFB923C),
        _ => const Color(0xFFEF4444),
      };

  Widget _buildHrResponseSection() {
    final hasResponse =
        report.hrResponse != null && report.status != 'pending';

    if (!hasResponse) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
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
          children: [
            Icon(
              Icons.hourglass_empty_outlined,
              size: 32,
              color: const Color(0xFF245A72).withValues(alpha: 0.2),
            ),
            const SizedBox(height: 12),
            Text(
              'Menunggu Tanggapan HR',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF245A72).withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Laporan Anda sedang ditinjau oleh tim HR',
              style: TextStyle(
                fontFamily: 'NimbusSans',
                fontSize: 12,
                color: const Color(0xFF245A72).withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF166534).withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF166534).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.support_agent_outlined,
                  size: 18,
                  color: const Color(0xFF166534).withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Tanggapan HR',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF166534),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            report.hrResponse!,
            style: TextStyle(
              fontFamily: 'NimbusSans',
              fontSize: 14,
              color: const Color(0xFF166534).withValues(alpha: 0.8),
              height: 1.6,
            ),
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
