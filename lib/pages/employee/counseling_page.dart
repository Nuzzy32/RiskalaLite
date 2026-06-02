import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/api_service.dart';
import '../../widgets/sos_button.dart';

class CounselingPage extends StatefulWidget {
  const CounselingPage({super.key});

  @override
  State<CounselingPage> createState() => _CounselingPageState();
}

class _CounselingPageState extends State<CounselingPage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _bookings = [];
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
      final results = await Future.wait([
        ApiService.getMyBookings(),
        ApiService.getAvailablePsikologs(),
      ]);
      if (!mounted) return;
      setState(() {
        _bookings = results[0];
        _psikologs = results[1];
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _cancel(Map<String, dynamic> b) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Batalkan sesi?'),
        content: const Text('Permintaan sesi ini akan dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, batalkan'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ApiService.cancelBooking(b['id'] as int);
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F8F8),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: AppColors.brand,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Konseling Rahasia',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.brand,
          ),
        ),
        actions: const [
          SosIconButton(size: 38, margin: EdgeInsets.only(right: 12)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                children: [
                  _confidentialityBanner(),
                  const SizedBox(height: 20),
                  if (_error != null) _errorState(),
                  const Text(
                    'Sesi Saya',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F191A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_bookings.isEmpty)
                    _emptyBookings()
                  else
                    ..._bookings.map(_bookingCard),
                ],
              ),
            ),
      floatingActionButton: _loading
          ? null
          : FloatingActionButton.extended(
              onPressed: _psikologs.isEmpty ? null : _openRequestSheet,
              backgroundColor: _psikologs.isEmpty
                  ? AppColors.subtle
                  : AppColors.brand,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text(
                'Ajukan Sesi',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
    );
  }

  Widget _confidentialityBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentLight.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lock_rounded, color: AppColors.brand, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sepenuhnya rahasia',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brand,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Hanya kamu dan psikolog yang bisa melihat sesi ini. HR maupun atasanmu tidak akan pernah diberi tahu.',
                  style: TextStyle(
                    fontFamily: 'NimbusSans',
                    fontSize: 12.5,
                    height: 1.45,
                    color: AppColors.brand.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorState() => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Text(_error!, style: const TextStyle(color: AppColors.danger)),
  );

  Widget _emptyBookings() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEAF0F1)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_note_rounded,
            size: 36,
            color: AppColors.subtle.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 12),
          const Text(
            'Belum ada sesi',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.brand,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ajukan sesi kapan pun kamu merasa perlu berbicara.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'NimbusSans',
              fontSize: 13,
              color: AppColors.subtle.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bookingCard(Map<String, dynamic> b) {
    final status = b['status']?.toString() ?? 'requested';
    final psikolog = b['psikolog'] as Map<String, dynamic>?;
    final (Color c, String label) = switch (status) {
      'requested' => (AppColors.warning, 'Menunggu konfirmasi'),
      'confirmed' => (AppColors.success, 'Terjadwal'),
      'completed' => (AppColors.subtle, 'Selesai'),
      _ => (AppColors.danger, 'Dibatalkan'),
    };
    final when = _fmt(b['scheduled_at'] ?? b['preferred_at']);
    final canCancel = status == 'requested' || status == 'confirmed';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEAF0F1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  psikolog?['nama']?.toString() ?? 'Psikolog',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brand,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: c.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'NimbusSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: c,
                  ),
                ),
              ),
            ],
          ),
          if (psikolog?['spesialisasi'] != null) ...[
            const SizedBox(height: 2),
            Text(
              psikolog!['spesialisasi'].toString(),
              style: const TextStyle(
                fontFamily: 'NimbusSans',
                fontSize: 12,
                color: AppColors.subtle,
              ),
            ),
          ],
          if (when != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: 15,
                  color: AppColors.subtle,
                ),
                const SizedBox(width: 6),
                Text(
                  when,
                  style: const TextStyle(
                    fontFamily: 'NimbusSans',
                    fontSize: 12.5,
                    color: AppColors.subtle,
                  ),
                ),
              ],
            ),
          ],
          if ((b['psikolog_note']?.toString() ?? '').isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F8F8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                b['psikolog_note'].toString(),
                style: TextStyle(
                  fontFamily: 'NimbusSans',
                  fontSize: 12.5,
                  height: 1.4,
                  color: AppColors.brand.withValues(alpha: 0.8),
                ),
              ),
            ),
          ],
          if (canCancel) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _cancel(b),
                child: const Text(
                  'Batalkan',
                  style: TextStyle(color: AppColors.danger, fontSize: 13),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _openRequestSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _RequestSheet(
        psikologs: _psikologs,
        onSubmitted: () {
          Navigator.pop(context);
          _load();
        },
      ),
    );
  }

  static String? _fmt(dynamic iso) {
    if (iso == null) return null;
    final dt = DateTime.tryParse(iso.toString())?.toLocal();
    if (dt == null) return null;
    const months = [
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
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $h:$m';
  }
}

class _RequestSheet extends StatefulWidget {
  final List<Map<String, dynamic>> psikologs;
  final VoidCallback onSubmitted;
  const _RequestSheet({required this.psikologs, required this.onSubmitted});

  @override
  State<_RequestSheet> createState() => _RequestSheetState();
}

class _RequestSheetState extends State<_RequestSheet> {
  int? _selectedId;
  DateTime? _preferred;
  final _noteCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );
    if (time == null) return;
    setState(
      () => _preferred = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      ),
    );
  }

  Future<void> _submit() async {
    if (_selectedId == null) return;
    setState(() => _submitting = true);
    try {
      await ApiService.createBooking(
        psikologId: _selectedId!,
        preferredAt: _preferred?.toIso8601String(),
        note: _noteCtrl.text.trim(),
      );
      if (!mounted) return;
      widget.onSubmitted();
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.brand.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Ajukan Sesi Konseling',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brand,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Pilih psikolog',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F191A),
                ),
              ),
              const SizedBox(height: 8),
              ...widget.psikologs.map((p) {
                final id = p['id'] as int;
                final available = p['is_available'] == true;
                final selected = _selectedId == id;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedId = id),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.accentLight.withValues(alpha: 0.4)
                            : const Color(0xFFFBFDFD),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected
                              ? AppColors.accent
                              : const Color(0xFFEAF0F1),
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p['nama']?.toString() ?? '—',
                                  style: const TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.brand,
                                  ),
                                ),
                                if (p['spesialisasi'] != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    p['spesialisasi'].toString(),
                                    style: const TextStyle(
                                      fontFamily: 'NimbusSans',
                                      fontSize: 12,
                                      color: AppColors.subtle,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (available
                                          ? AppColors.success
                                          : AppColors.warning)
                                      .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              available ? 'Tersedia' : 'Sibuk',
                              style: TextStyle(
                                fontFamily: 'NimbusSans',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: available
                                    ? AppColors.success
                                    : AppColors.warning,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickTime,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBFDFD),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEAF0F1)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 18,
                        color: AppColors.accentDeep,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _preferred == null
                              ? 'Waktu yang diinginkan (opsional)'
                              : _CounselingPageState._fmt(
                                  _preferred!.toIso8601String(),
                                )!,
                          style: TextStyle(
                            fontFamily: 'NimbusSans',
                            fontSize: 13,
                            color: _preferred == null
                                ? AppColors.subtle
                                : AppColors.brand,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _noteCtrl,
                maxLines: 3,
                maxLength: 1000,
                decoration: InputDecoration(
                  hintText:
                      'Ceritakan singkat apa yang ingin kamu bicarakan (opsional)',
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: AppColors.subtle,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFFBFDFD),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFEAF0F1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFEAF0F1)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: (_selectedId == null || _submitting)
                      ? null
                      : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brand,
                    disabledBackgroundColor: AppColors.brand.withValues(
                      alpha: 0.4,
                    ),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text(
                          'Kirim Permintaan',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
