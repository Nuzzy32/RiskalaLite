import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/api_service.dart';
import '../../widgets/sos_button.dart';

class AssessmentHistoryPage extends StatefulWidget {
  const AssessmentHistoryPage({super.key});

  @override
  State<AssessmentHistoryPage> createState() => _AssessmentHistoryPageState();
}

class _AssessmentHistoryPageState extends State<AssessmentHistoryPage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _records = [];

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
      final data = await ApiService.getAssessmentHistory();
      setState(() {
        _records = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _loading = false;
      });
    }
  }

  String _levelFromKategori(int k) {
    if (k == 3) return 'high';
    if (k == 2) return 'moderate';
    return 'low';
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
                      'Assessment History',
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
                : _records.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assessment_outlined,
                          size: 64,
                          color: AppColors.brand.withValues(alpha: 0.2),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada riwayat assessment',
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
                      itemCount: _records.length,
                      itemBuilder: (context, index) =>
                          _buildCard(_records[index]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> record) {
    final date =
        DateTime.tryParse(record['tgl_SA']?.toString() ?? '') ?? DateTime.now();
    final score = (record['total_score'] as num?)?.toInt() ?? 0;
    final kategori = (record['kategori_stres'] as num?)?.toInt() ?? 1;
    final level = _levelFromKategori(kategori);

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
      child: Row(
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${date.day}',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.brand,
                    height: 1,
                  ),
                ),
                Text(
                  _monthAbbr(date.month),
                  style: TextStyle(
                    fontFamily: 'NimbusSans',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brand.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Work-Stress Check-in',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brand,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$score/40',
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.brand,
                ),
              ),
              const SizedBox(height: 4),
              _buildBadge(level),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String level) {
    final (Color bg, Color text, String label) = switch (level) {
      'low' => (const Color(0xFFDCFCE7), const Color(0xFF166534), 'LOW'),
      'moderate' => (
        const Color(0xFFFEF9C3),
        const Color(0xFF854D0E),
        'MODERATE',
      ),
      'high' => (const Color(0xFFFCE7F3), const Color(0xFF9D174D), 'HIGH'),
      _ => (
        const Color(0xFFF1F5F9),
        const Color(0xFF64748B),
        level.toUpperCase(),
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

  String _monthAbbr(int m) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return months[m];
  }
}
