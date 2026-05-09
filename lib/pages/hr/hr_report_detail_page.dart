import 'package:flutter/material.dart';
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
  });

  @override
  State<HrReportDetailPage> createState() => _HrReportDetailPageState();
}

class _HrReportDetailPageState extends State<HrReportDetailPage> {
  late final TextEditingController _responseController;
  late String _currentStatus;
  late String? _currentResponse;
  bool _saving = false;

  bool get _isIncident => widget.reportId != null;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.status ?? 'pending';
    _currentResponse = widget.hrResponse;
    _responseController = TextEditingController(text: widget.hrResponse ?? '');
  }

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  Future<void> _handleFollowUp() async {
    final text = _responseController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tulis respon HR dulu sebelum tindak lanjut')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await ApiService.updateReport(
        widget.reportId!,
        status: 'selesai',
        hrResponse: text,
      );
      if (!mounted) return;
      setState(() {
        _saving = false;
        _currentStatus = 'selesai';
        _currentResponse = text;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Laporan berhasil ditindaklanjuti')),
      );
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) Navigator.pop(context, true);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: ${e.toString().replaceAll('Exception: ', '')}')),
      );
    }
  }

  Future<void> _markAsProcessing() async {
    if (widget.reportId == null) return;
    setState(() => _saving = true);
    try {
      await ApiService.updateReport(widget.reportId!, status: 'proses');
      if (!mounted) return;
      setState(() {
        _saving = false;
        _currentStatus = 'proses';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status diubah menjadi diproses')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: ${e.toString().replaceAll('Exception: ', '')}')),
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
                    _isIncident ? _buildStressSlider() : _buildWeeklyAssessment(),
                    if (_isIncident) ...[
                      const SizedBox(height: 24),
                      _buildIncidentSection(),
                      const SizedBox(height: 24),
                      _buildFollowUpForm(),
                    ],
                    const SizedBox(height: 28),
                    _buildActionButton(context),
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
            const CircleAvatar(
              radius: 28,
              backgroundColor: Color(0xFFF3F4F6),
              child: Icon(Icons.person, color: Color(0xFF245A72), size: 28),
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
                            color: Color(0xFF245A72),
                          ),
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
                    '${widget.division} Division',
                    style: TextStyle(
                      fontFamily: 'NimbusSans',
                      fontSize: 13,
                      color: const Color(0xFF245A72).withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    'REPORTED: ${widget.reportDate.toUpperCase()}',
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
    final base = widget.stressScore;
    final workload = (base * 1.05).clamp(0, 100).round();
    final emotional = (base * 0.85).clamp(0, 100).round();

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

  Widget _buildStressSlider() {
    final level = (widget.tingkatStres ?? 1).toDouble();

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tingkat Stres',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF245A72),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                  Text('RENDAH',
                      style: TextStyle(fontFamily: 'NimbusSans', fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF7A8B94), letterSpacing: 0.5)),
                  Text('TINGGI',
                      style: TextStyle(fontFamily: 'NimbusSans', fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF7A8B94), letterSpacing: 0.5)),
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
                color: Color(0xFF245A72),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFB3F3F4).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '"${widget.deskripsi ?? ''}"',
              style: TextStyle(
                fontFamily: 'NimbusSans',
                fontSize: 13,
                height: 1.6,
                color: const Color(0xFF245A72).withValues(alpha: 0.7),
              ),
            ),
          ),
          if (_currentResponse != null && _currentResponse!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.reply, size: 14, color: Color(0xFF166534)),
                      SizedBox(width: 6),
                      Text(
                        'Respon HR',
                        style: TextStyle(
                          fontFamily: 'NimbusSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF166534),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentResponse!,
                    style: const TextStyle(
                      fontFamily: 'NimbusSans',
                      fontSize: 13,
                      height: 1.5,
                      color: Color(0xFF166534),
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

  Widget _buildFollowUpForm() {
    final isDone = _currentStatus == 'selesai';
    if (isDone) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tulis Respon HR',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF245A72),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: _responseController,
              maxLines: 4,
              maxLength: 1000,
              decoration: const InputDecoration(
                hintText: 'Tulis tanggapan untuk karyawan...',
                hintStyle: TextStyle(
                  fontFamily: 'NimbusSans',
                  fontSize: 13,
                  color: Color(0xFF94A3B8),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
              style: const TextStyle(
                fontFamily: 'NimbusSans',
                fontSize: 13,
                color: Color(0xFF245A72),
              ),
            ),
          ),
          if (_currentStatus == 'pending') ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _saving ? null : _markAsProcessing,
              icon: const Icon(Icons.timer_outlined, size: 16),
              label: const Text('Tandai Sedang Diproses'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF854D0E),
                side: const BorderSide(color: Color(0xFFFEF9C3)),
                backgroundColor: const Color(0xFFFEF9C3).withValues(alpha: 0.3),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(fontFamily: 'NimbusSans', fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    final isDone = _currentStatus == 'selesai';
    final canFollowUp = _isIncident;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: !canFollowUp || isDone || _saving ? null : _handleFollowUp,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDone ? const Color(0xFFCBD5E1) : const Color(0xFF61D1DB),
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(0xFFCBD5E1),
            disabledForegroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 0,
          ),
          child: _saving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(
                  isDone
                      ? 'Sudah Ditindaklanjuti'
                      : !canFollowUp
                          ? 'Tindak Lanjut Tidak Tersedia'
                          : 'Tindak Lanjut Selesai',
                  style: const TextStyle(
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
