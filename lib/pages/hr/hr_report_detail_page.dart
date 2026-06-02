import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/api_service.dart';

class HrReportDetailPage extends StatefulWidget {
  final String employeeName;
  final String division;
  final String riskLevel;
  final int stressScore;
  final String reportDate;

  final String? reportId;
  final String? kategori;
  final String? deskripsi;
  final String? status;
  final String? hrResponse;
  final int? tingkatStres;
  final Map<String, dynamic>? psikolog;

  const HrReportDetailPage({
    super.key,
    required this.employeeName,
    required this.division,
    required this.riskLevel,
    required this.stressScore,
    required this.reportDate,
    this.reportId,
    this.kategori,
    this.deskripsi,
    this.status,
    this.hrResponse,
    this.tingkatStres,
    this.psikolog,
  });

  @override
  State<HrReportDetailPage> createState() => _HrReportDetailPageState();
}

class _HrReportDetailPageState extends State<HrReportDetailPage> {
  late String _currentStatus;
  Map<String, dynamic>? _currentPsikolog;
  bool _saving = false;

  bool get _isIncident => widget.reportId != null;
  bool get _hasPsikolog => _currentPsikolog != null;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.status ?? 'pending';
    _currentPsikolog = widget.psikolog;
  }

  Future<void> _showPsikologSheet() async {
    final selectedId = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _PsikologPickerSheet(),
    );

    if (selectedId == null || !mounted) return;
    await _assignPsikolog(selectedId);
  }

  Future<void> _assignPsikolog(int psikologId) async {
    setState(() => _saving = true);
    try {
      final res = await ApiService.assignPsikolog(widget.reportId!, psikologId);
      final data = res['data'] as Map<String, dynamic>?;
      final psikolog = data?['psikolog'] as Map<String, dynamic>?;
      final status = data?['status']?.toString() ?? 'proses';

      if (!mounted) return;
      setState(() {
        _saving = false;
        _currentPsikolog = psikolog;
        _currentStatus = status;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Penugasan ke ${psikolog?['nama'] ?? 'psikolog'} berhasil. Email terkirim.',
          ),
          backgroundColor: const Color(0xFF166534),
          duration: const Duration(seconds: 3),
        ),
      );
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) Navigator.pop(context, true);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: const Color(0xFF9D174D),
        ),
      );
    }
  }

  Future<void> _markComplete() async {
    setState(() => _saving = true);
    try {
      await ApiService.updateReport(widget.reportId!, status: 'selesai');
      if (!mounted) return;
      setState(() {
        _saving = false;
        _currentStatus = 'selesai';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Laporan ditandai selesai'),
          backgroundColor: Color(0xFF166534),
        ),
      );
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) Navigator.pop(context, true);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

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
                padding: const EdgeInsets.only(bottom: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildEmployeeCard(),
                    const SizedBox(height: 20),
                    _isIncident
                        ? _buildStressSlider()
                        : _buildWeeklyAssessment(),
                    if (_isIncident) ...[
                      const SizedBox(height: 24),
                      _buildIncidentSection(),
                      const SizedBox(height: 24),
                      if (_hasPsikolog) _buildPsikologCard(),
                    ],
                    const SizedBox(height: 28),
                    _buildActionButton(),
                    const SizedBox(height: 28),
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
            child: const Icon(
              Icons.arrow_back_ios,
              size: 22,
              color: AppColors.brand,
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Report Details',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brand,
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
            child: const Icon(
              Icons.description_outlined,
              color: AppColors.brand,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard() {
    final level = widget.riskLevel;
    final riskLabel = level == 'high'
        ? 'HIGH RISK'
        : level == 'moderate'
        ? 'MODERATE RISK'
        : 'LOW RISK';

    Color badgeBg;
    Color badgeText;
    switch (level) {
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
          border: Border.all(
            color: const Color(0xFFE2E8F0).withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.brand.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 28,
              backgroundColor: Color(0xFFF3F4F6),
              child: Icon(Icons.person, color: AppColors.brand, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          widget.employeeName.split(' ').first,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.brand,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
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
                    '${widget.division} Division',
                    style: TextStyle(
                      fontFamily: 'NimbusSans',
                      fontSize: 13,
                      color: AppColors.brand.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    'REPORTED: ${widget.reportDate.toUpperCase()}',
                    style: TextStyle(
                      fontFamily: 'NimbusSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brand.withValues(alpha: 0.4),
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
    final base = widget.stressScore;
    final workload = (base * 1.05).clamp(0, 100).round();
    final emotional = (base * 0.85).clamp(0, 100).round();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Work-Stress Check-in',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.brand,
              ),
            ),
            const SizedBox(height: 20),
            _buildAssessmentBar('Tekanan Beban Kerja', workload),
            const SizedBox(height: 16),
            _buildAssessmentBar('Kelelahan Emosional', emotional),
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
                color: AppColors.brand.withValues(alpha: 0.7),
              ),
            ),
            Text(
              '$percent%',
              style: const TextStyle(
                fontFamily: 'NimbusSans',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.brand,
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
                  colors: [AppColors.accent, AppColors.brand],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStressSlider() {
    final level = (widget.tingkatStres ?? 1).toDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tingkat Stres',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brand,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF60D0DC).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text(
                    '${level.round()}/5',
                    style: const TextStyle(
                      fontFamily: 'NimbusSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF60D0DC),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SliderTheme(
              data: const SliderThemeData(
                activeTrackColor: Color(0xFF60D0DC),
                inactiveTrackColor: Color(0xFFE2E8F0),
                thumbColor: Color(0xFF60D0DC),
                overlayColor: Colors.transparent,
                disabledActiveTrackColor: Color(0xFF60D0DC),
                disabledInactiveTrackColor: Color(0xFFE2E8F0),
                disabledThumbColor: Color(0xFF60D0DC),
              ),
              child: Slider(
                value: level,
                min: 1,
                max: 5,
                divisions: 4,
                onChanged: null,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'RENDAH',
                    style: TextStyle(
                      fontFamily: 'NimbusSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF7A8B94),
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    'TINGGI',
                    style: TextStyle(
                      fontFamily: 'NimbusSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF7A8B94),
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

  Widget _buildIncidentSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Komentar Karyawan & Laporan Insiden',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.brand,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2F4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.kategori ?? '-',
              style: const TextStyle(
                fontFamily: 'NimbusSans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.brand,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.accentLight.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '"${widget.deskripsi ?? ''}"',
              style: TextStyle(
                fontFamily: 'NimbusSans',
                fontSize: 13,
                height: 1.6,
                color: AppColors.brand.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPsikologCard() {
    final p = _currentPsikolog!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFBBF7D0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 18,
                  color: Color(0xFF166534),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Sudah Ditugaskan ke Psikolog',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF166534),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF166534).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.psychology_outlined,
                    color: Color(0xFF166534),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p['nama']?.toString() ?? '-',
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F191A),
                        ),
                      ),
                      if ((p['spesialisasi']?.toString().isNotEmpty ?? false))
                        Text(
                          p['spesialisasi'].toString(),
                          style: const TextStyle(
                            fontFamily: 'NimbusSans',
                            fontSize: 12,
                            color: Color(0xFF166534),
                          ),
                        ),
                      const SizedBox(height: 2),
                      Text(
                        p['email']?.toString() ?? '',
                        style: TextStyle(
                          fontFamily: 'NimbusSans',
                          fontSize: 11,
                          color: const Color(0xFF166534).withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.mark_email_read_outlined,
                    size: 14,
                    color: Color(0xFF166534),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Email penugasan otomatis terkirim ke psikolog.',
                      style: TextStyle(
                        fontFamily: 'NimbusSans',
                        fontSize: 11,
                        color: const Color(0xFF166534).withValues(alpha: 0.85),
                      ),
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

  Widget _buildActionButton() {
    if (!_isIncident) {
      return const SizedBox.shrink();
    }

    final isDone = _currentStatus == 'selesai';

    if (isDone) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: const Color(0xFFCBD5E1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Sudah Ditindaklanjuti',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'NimbusSans',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ),
      );
    }

    if (_hasPsikolog) {
      // Sudah assigned, tampilkan tombol mark complete + ganti psikolog
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _markComplete,
                icon: const Icon(Icons.check, size: 18),
                label: const Text(
                  'Tandai Selesai',
                  style: TextStyle(
                    fontFamily: 'NimbusSans',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF166534),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _saving ? null : _showPsikologSheet,
              icon: const Icon(Icons.swap_horiz, size: 16),
              label: const Text(
                'Ganti Psikolog',
                style: TextStyle(
                  fontFamily: 'NimbusSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextButton.styleFrom(foregroundColor: AppColors.brand),
            ),
          ],
        ),
      );
    }

    // Belum assigned: tombol pilih psikolog
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _saving ? null : _showPsikologSheet,
          icon: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.psychology_outlined, size: 20),
          label: Text(
            _saving ? 'Memproses…' : 'Tindak Lanjut → Pilih Psikolog',
            style: const TextStyle(
              fontFamily: 'NimbusSans',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(0xFFCBD5E1),
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
          ),
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0xFFE2E8F0).withValues(alpha: 0.5)),
      boxShadow: [
        BoxShadow(
          color: AppColors.brand.withValues(alpha: 0.06),
          blurRadius: 20,
          offset: const Offset(0, 8),
          spreadRadius: -4,
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
// Psikolog Picker Sheet
// ──────────────────────────────────────────────────────────────────────────

class _PsikologPickerSheet extends StatefulWidget {
  const _PsikologPickerSheet();

  @override
  State<_PsikologPickerSheet> createState() => _PsikologPickerSheetState();
}

class _PsikologPickerSheetState extends State<_PsikologPickerSheet> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _psikologs = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await ApiService.getPsikologs();
      if (!mounted) return;
      setState(() {
        _psikologs = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final available = _psikologs
        .where((p) => p['is_available'] == true)
        .toList();
    final unavailable = _psikologs
        .where((p) => p['is_available'] != true)
        .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.brand.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Icon(
                    Icons.psychology_outlined,
                    color: AppColors.brand,
                    size: 22,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Pilih Psikolog',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brand,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Psikolog dengan beban kasus < 3 dapat menerima penugasan baru.',
                style: TextStyle(
                  fontFamily: 'NimbusSans',
                  fontSize: 12,
                  color: AppColors.brand.withValues(alpha: 0.55),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.brand),
                    )
                  : _error != null
                  ? _buildError()
                  : _psikologs.isEmpty
                  ? _buildEmpty()
                  : ListView(
                      controller: scrollCtrl,
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                      children: [
                        if (available.isNotEmpty) ...[
                          _sectionLabel('TERSEDIA (${available.length})'),
                          ...available.map((p) => _buildItem(p, true)),
                          const SizedBox(height: 16),
                        ],
                        if (unavailable.isNotEmpty) ...[
                          _sectionLabel('PENUH (${unavailable.length})'),
                          ...unavailable.map((p) => _buildItem(p, false)),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 8, 0, 10),
    child: Text(
      text,
      style: TextStyle(
        fontFamily: 'NimbusSans',
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.brand.withValues(alpha: 0.5),
        letterSpacing: 0.8,
      ),
    ),
  );

  Widget _buildError() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, color: Color(0xFF9D174D), size: 40),
        const SizedBox(height: 12),
        Text(
          _error!,
          style: const TextStyle(
            fontFamily: 'NimbusSans',
            color: AppColors.brand,
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: _load, child: const Text('Coba lagi')),
      ],
    ),
  );

  Widget _buildEmpty() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.psychology_outlined,
          size: 48,
          color: AppColors.brand.withValues(alpha: 0.2),
        ),
        const SizedBox(height: 12),
        Text(
          'Belum ada psikolog terdaftar',
          style: TextStyle(
            fontFamily: 'NimbusSans',
            fontSize: 14,
            color: AppColors.brand.withValues(alpha: 0.5),
          ),
        ),
      ],
    ),
  );

  Widget _buildItem(Map<String, dynamic> p, bool available) {
    final caseload = (p['active_caseload'] as num?)?.toInt() ?? 0;
    final id = p['id'] as int;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: available ? () => Navigator.pop(context, id) : null,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: available ? Colors.white : const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: available
                    ? const Color(0xFFE2E8F0)
                    : const Color(0xFFE2E8F0).withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: available
                        ? AppColors.brand.withValues(alpha: 0.08)
                        : const Color(0xFF94A3B8).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.psychology_outlined,
                    color: available
                        ? AppColors.brand
                        : const Color(0xFF94A3B8),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p['nama']?.toString() ?? '-',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: available
                              ? AppColors.brand
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                      if ((p['spesialisasi']?.toString().isNotEmpty ?? false))
                        Text(
                          p['spesialisasi'].toString(),
                          style: TextStyle(
                            fontFamily: 'NimbusSans',
                            fontSize: 11,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      const SizedBox(height: 2),
                      Text(
                        '$caseload kasus aktif',
                        style: TextStyle(
                          fontFamily: 'NimbusSans',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: caseload >= 3
                              ? const Color(0xFF9D174D)
                              : const Color(0xFF166534),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: available
                        ? const Color(0xFFDCFCE7)
                        : const Color(0xFFFCE7F3),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text(
                    available ? 'Available' : 'Penuh',
                    style: TextStyle(
                      fontFamily: 'NimbusSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: available
                          ? const Color(0xFF166534)
                          : const Color(0xFF9D174D),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
