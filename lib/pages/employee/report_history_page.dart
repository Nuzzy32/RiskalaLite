import 'package:flutter/material.dart';
import '../../data/dummy_data.dart';
import 'report_detail_page.dart';

class ReportHistoryPage extends StatelessWidget {
  const ReportHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final reports = DummyIncidentReports.reports;

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
                        child: const Icon(Icons.arrow_back_ios_new,
                            size: 18, color: Color(0xFF245A72)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Riwayat Laporan',
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
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReportDetailPage(report: report),
                    ),
                  ),
                  child: _buildCard(report),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(IncidentReport report) {
    final dateStr =
        '${report.date.day}/${report.date.month}/${report.date.year}';

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
          // Category icon
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
            child: Icon(
              _categoryIcon(report.category),
              size: 24,
              color: const Color(0xFF245A72).withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.category,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF245A72),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
          const SizedBox(width: 12),
          _buildStatusBadge(report.status),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final (Color bg, Color text, String label) = switch (status) {
      'pending' => (
        const Color(0xFFFEF9C3),
        const Color(0xFF854D0E),
        'MENUNGGU'
      ),
      'reviewed' => (
        const Color(0xFFDBEAFE),
        const Color(0xFF1E40AF),
        'DIPROSES'
      ),
      'resolved' => (
        const Color(0xFFDCFCE7),
        const Color(0xFF166534),
        'SELESAI'
      ),
      _ => (
        const Color(0xFFF1F5F9),
        const Color(0xFF64748B),
        status.toUpperCase()
      ),
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

  IconData _categoryIcon(String category) => switch (category) {
        'Beban Kerja Berlebihan' => Icons.trending_up_outlined,
        'Konflik dengan Rekan Kerja' => Icons.people_outline,
        'Masalah Manajemen' => Icons.supervisor_account_outlined,
        'Work-Life Balance' => Icons.balance_outlined,
        'Lingkungan Kerja' => Icons.apartment_outlined,
        _ => Icons.description_outlined,
      };
}
