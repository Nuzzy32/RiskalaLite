import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/api_service.dart';
import '../../widgets/sos_button.dart';

class ReportHistoryPage extends StatefulWidget {
  const ReportHistoryPage({super.key});

  @override
  State<ReportHistoryPage> createState() => _ReportHistoryPageState();
}

class _ReportHistoryPageState extends State<ReportHistoryPage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _reports = [];

  static const _categories = {
    1: 'Beban Kerja Berlebihan',
    2: 'Konflik dengan Rekan Kerja',
    3: 'Masalah Manajemen',
    4: 'Work-Life Balance',
    5: 'Lingkungan Kerja',
    6: 'Lainnya',
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await ApiService.getReports();
      setState(() {
        _reports = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
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
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 18,
                          color: AppColors.brand,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Riwayat Laporan',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brand,
                      ),
                    ),
                    const Spacer(),
                    const SosIconButton(),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.brand),
                  )
                : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Color(0xFF9D174D),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'NimbusSans',
                            color: AppColors.brand,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _loadData,
                          child: const Text('Coba lagi'),
                        ),
                      ],
                    ),
                  )
                : _reports.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 64,
                          color: AppColors.brand.withValues(alpha: 0.2),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada riwayat laporan',
                          style: TextStyle(
                            fontFamily: 'NimbusSans',
                            fontSize: 15,
                            color: AppColors.brand.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadData,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                      itemCount: _reports.length,
                      itemBuilder: (context, index) =>
                          _buildCard(_reports[index]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> report) {
    final date =
        DateTime.tryParse(report['tgl_IR']?.toString() ?? '') ?? DateTime.now();
    final kategori = (report['kategori'] as num?)?.toInt() ?? 6;
    final category = _categories[kategori] ?? 'Lainnya';
    final status = report['status']?.toString() ?? 'pending';
    final hrResponse = report['hr_response']?.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.brand.withValues(alpha: 0.06),
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
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.accentLight.withValues(alpha: 0.5),
                      AppColors.accent.withValues(alpha: 0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _categoryIcon(category),
                  size: 24,
                  color: AppColors.brand.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brand,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${date.day}/${date.month}/${date.year}',
                      style: TextStyle(
                        fontFamily: 'NimbusSans',
                        fontSize: 12,
                        color: AppColors.brand.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _buildStatusBadge(status),
            ],
          ),
          if (hrResponse != null && hrResponse.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.reply, size: 14, color: Color(0xFF166634)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      hrResponse,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'NimbusSans',
                        fontSize: 12,
                        color: Color(0xFF166534),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final (Color bg, Color text, String label) = switch (status) {
      'pending' => (
        const Color(0xFFFEF9C3),
        const Color(0xFF854D0E),
        'MENUNGGU',
      ),
      'proses' => (
        const Color(0xFFDBEAFE),
        const Color(0xFF1E40AF),
        'DIPROSES',
      ),
      'selesai' => (
        const Color(0xFFDCFCE7),
        const Color(0xFF166534),
        'SELESAI',
      ),
      _ => (
        const Color(0xFFF1F5F9),
        const Color(0xFF64748B),
        status.toUpperCase(),
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
