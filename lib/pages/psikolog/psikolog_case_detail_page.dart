import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/api_service.dart';

const _kBrand = AppColors.brand;
const _kAccent = AppColors.accent;
const _kSubtle = AppColors.subtle;
const _kBg = Color(0xFFF6F8F8);

/// Detail of one assigned case — psikolog records the session outcome here.
class PsikologCaseDetailPage extends StatefulWidget {
  final Map<String, dynamic> caseData;
  const PsikologCaseDetailPage({super.key, required this.caseData});

  @override
  State<PsikologCaseDetailPage> createState() => _PsikologCaseDetailPageState();
}

class _PsikologCaseDetailPageState extends State<PsikologCaseDetailPage> {
  late final TextEditingController _noteCtrl;
  late String _status;
  DateTime? _sessionAt;
  bool _saving = false;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _noteCtrl = TextEditingController(
        text: widget.caseData['psikolog_note']?.toString() ?? '');
    _status = widget.caseData['status']?.toString() ?? 'proses';
    final s = widget.caseData['session_at']?.toString();
    if (s != null && s.isNotEmpty) _sessionAt = DateTime.tryParse(s);
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickSessionDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _sessionAt ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _kBrand, onPrimary: Colors.white, surface: Colors.white),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _sessionAt = picked);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ApiService.updatePsikologCase(
        widget.caseData['id_report'].toString(),
        status: _status,
        psikologNote: _noteCtrl.text.trim(),
        sessionAt: _sessionAt != null
            ? '${_sessionAt!.toIso8601String().split('T').first} 00:00:00'
            : null,
      );
      _changed = true;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kasus diperbarui'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal: ${e.toString().replaceFirst('Exception: ', '')}'),
          backgroundColor: const Color(0xFF9D174D),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.caseData['user'] as Map<String, dynamic>?;
    final name = user?['nama_user']?.toString() ?? 'Karyawan';
    final division = user?['department']?.toString() ?? '-';
    final category = widget.caseData['nama_kategori']?.toString() ?? 'Laporan';
    final desc = widget.caseData['deskripsi']?.toString() ?? '';
    final stress = (widget.caseData['tingkat_stres'] as num?)?.toInt() ?? 0;

    return PopScope(
      canPop: !_saving,
      onPopInvokedWithResult: (didPop, _) {},
      child: Scaffold(
        backgroundColor: _kBg,
        appBar: AppBar(
          backgroundColor: _kBg,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: _kBrand),
            onPressed: () => Navigator.pop(context, _changed),
          ),
          title: const Text('Detail Kasus',
              style: TextStyle(color: _kBrand, fontSize: 17, fontWeight: FontWeight.w600)),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Employee + case info
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48, height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _kAccent.withValues(alpha: 0.14),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: const TextStyle(
                                fontFamily: 'Manrope', fontSize: 18,
                                fontWeight: FontWeight.w700, color: _kBrand),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name,
                                  style: const TextStyle(
                                      fontFamily: 'Manrope', fontSize: 17,
                                      fontWeight: FontWeight.w700, color: _kBrand)),
                              Text(division,
                                  style: const TextStyle(
                                      fontFamily: 'NimbusSans', fontSize: 13,
                                      color: _kSubtle)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _infoRow(Icons.label_outline_rounded, 'Kategori', category),
                    const SizedBox(height: 10),
                    _infoRow(Icons.monitor_heart_outlined, 'Tingkat stres', '$stress / 5'),
                    if (desc.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      const Text('Deskripsi',
                          style: TextStyle(
                              fontFamily: 'NimbusSans', fontSize: 12,
                              fontWeight: FontWeight.w700, color: _kSubtle)),
                      const SizedBox(height: 4),
                      Text(desc,
                          style: TextStyle(
                              fontFamily: 'NimbusSans', fontSize: 14, height: 1.5,
                              color: _kBrand.withValues(alpha: 0.85))),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Status selector
              const Text('Status Penanganan',
                  style: TextStyle(
                      fontFamily: 'Manrope', fontSize: 15,
                      fontWeight: FontWeight.w700, color: _kBrand)),
              const SizedBox(height: 10),
              Row(
                children: [
                  _statusOption('proses', 'Diproses', AppColors.warning),
                  const SizedBox(width: 10),
                  _statusOption('selesai', 'Selesai', AppColors.success),
                ],
              ),
              const SizedBox(height: 20),

              // Session date
              const Text('Tanggal Sesi',
                  style: TextStyle(
                      fontFamily: 'Manrope', fontSize: 15,
                      fontWeight: FontWeight.w700, color: _kBrand)),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickSessionDate,
                child: _card(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      const Icon(Icons.event_outlined, size: 20, color: _kAccent),
                      const SizedBox(width: 12),
                      Text(
                        _sessionAt != null
                            ? _fmt(_sessionAt!)
                            : 'Pilih tanggal sesi konsultasi',
                        style: TextStyle(
                          fontFamily: 'NimbusSans', fontSize: 14,
                          color: _sessionAt != null
                              ? _kBrand
                              : _kBrand.withValues(alpha: 0.45),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right_rounded, color: _kSubtle),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Session note
              const Text('Catatan Sesi',
                  style: TextStyle(
                      fontFamily: 'Manrope', fontSize: 15,
                      fontWeight: FontWeight.w700, color: _kBrand)),
              const SizedBox(height: 10),
              _card(
                padding: const EdgeInsets.all(6),
                child: TextField(
                  controller: _noteCtrl,
                  maxLines: 5,
                  maxLength: 1000,
                  style: const TextStyle(
                      fontFamily: 'NimbusSans', fontSize: 14, height: 1.5, color: _kBrand),
                  decoration: const InputDecoration(
                    hintText: 'Tuliskan hasil sesi, rencana tindak lanjut, dll.',
                    hintStyle: TextStyle(color: _kSubtle, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kBrand,
                    disabledBackgroundColor: _kBrand.withValues(alpha: 0.45),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: _saving
                        ? const SizedBox(
                            key: ValueKey('s'), width: 22, height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation(Colors.white)))
                        : const Text('Simpan Perubahan',
                            key: ValueKey('l'),
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusOption(String value, String label, Color color) {
    final active = _status == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _status = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: active ? color.withValues(alpha: 0.12) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: active ? color : const Color(0xFFE2E8F0),
                width: active ? 2 : 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(active ? Icons.check_circle_rounded : Icons.circle_outlined,
                  size: 18, color: active ? color : _kSubtle),
              const SizedBox(width: 8),
              Text(label,
                  style: TextStyle(
                      fontFamily: 'Manrope', fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: active ? color : _kSubtle)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: _kSubtle),
        const SizedBox(width: 8),
        Text('$label: ',
            style: const TextStyle(
                fontFamily: 'NimbusSans', fontSize: 13, color: _kSubtle)),
        Text(value,
            style: const TextStyle(
                fontFamily: 'NimbusSans', fontSize: 13,
                fontWeight: FontWeight.w700, color: _kBrand)),
      ],
    );
  }

  Widget _card({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.brand.withValues(alpha: 0.06),
            blurRadius: 14, offset: const Offset(0, 6), spreadRadius: -4,
          ),
        ],
      ),
      child: child,
    );
  }

  String _fmt(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}
