import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/api_service.dart';

/// Psikolog-side management of confidential counseling bookings.
class PsikologBookingsPage extends StatefulWidget {
  const PsikologBookingsPage({super.key});

  @override
  State<PsikologBookingsPage> createState() => _PsikologBookingsPageState();
}

class _PsikologBookingsPageState extends State<PsikologBookingsPage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _bookings = [];

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
      final data = await ApiService.getPsikologBookings();
      if (!mounted) return;
      setState(() {
        _bookings = data;
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

  Future<void> _confirm(Map<String, dynamic> b) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 10, minute: 0));
    if (time == null) return;
    final scheduled = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    await _update(b, status: 'confirmed', scheduledAt: scheduled.toIso8601String());
  }

  Future<void> _update(Map<String, dynamic> b,
      {String? status, String? scheduledAt}) async {
    try {
      await ApiService.updatePsikologBooking(b['id'] as int,
          status: status, scheduledAt: scheduledAt);
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.brand),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Permintaan Konseling',
            style: TextStyle(
                fontFamily: 'Manrope', fontSize: 18,
                fontWeight: FontWeight.w700, color: AppColors.brand)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: AppColors.danger)))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: _bookings.isEmpty
                      ? ListView(children: const [
                          SizedBox(height: 120),
                          Center(child: Text('Belum ada permintaan sesi',
                              style: TextStyle(color: AppColors.subtle))),
                        ])
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                          itemCount: _bookings.length,
                          itemBuilder: (_, i) => _card(_bookings[i]),
                        ),
                ),
    );
  }

  Widget _card(Map<String, dynamic> b) {
    final status = b['status']?.toString() ?? 'requested';
    final emp = b['employee'] as Map<String, dynamic>?;
    final (Color c, String label) = switch (status) {
      'requested' => (AppColors.warning, 'Permintaan baru'),
      'confirmed' => (AppColors.success, 'Terjadwal'),
      'completed' => (AppColors.subtle, 'Selesai'),
      _ => (AppColors.danger, 'Dibatalkan'),
    };
    final when = _fmt(b['scheduled_at'] ?? b['preferred_at']);

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
                child: Text(emp?['nama']?.toString() ?? 'Karyawan',
                    style: const TextStyle(
                        fontFamily: 'Manrope', fontSize: 15,
                        fontWeight: FontWeight.w700, color: AppColors.brand)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: c.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(label,
                    style: TextStyle(
                        fontFamily: 'NimbusSans', fontSize: 11,
                        fontWeight: FontWeight.w700, color: c)),
              ),
            ],
          ),
          if (emp?['department'] != null) ...[
            const SizedBox(height: 2),
            Text(emp!['department'].toString(),
                style: const TextStyle(
                    fontFamily: 'NimbusSans', fontSize: 12, color: AppColors.subtle)),
          ],
          if (when != null) ...[
            const SizedBox(height: 10),
            Row(children: [
              const Icon(Icons.schedule_rounded, size: 15, color: AppColors.subtle),
              const SizedBox(width: 6),
              Text(when,
                  style: const TextStyle(
                      fontFamily: 'NimbusSans', fontSize: 12.5, color: AppColors.subtle)),
            ]),
          ],
          if ((b['note']?.toString() ?? '').isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F8F8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(b['note'].toString(),
                  style: TextStyle(
                      fontFamily: 'NimbusSans', fontSize: 12.5, height: 1.4,
                      color: AppColors.brand.withValues(alpha: 0.8))),
            ),
          ],
          if (status == 'requested' || status == 'confirmed') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (status == 'requested')
                  Expanded(
                    child: _btn('Konfirmasi & jadwalkan', AppColors.brand, Colors.white,
                        () => _confirm(b)),
                  ),
                if (status == 'confirmed')
                  Expanded(
                    child: _btn('Tandai selesai', AppColors.success, Colors.white,
                        () => _update(b, status: 'completed')),
                  ),
                const SizedBox(width: 8),
                _btn('Batalkan', const Color(0xFFFDECEC), AppColors.danger,
                    () => _update(b, status: 'cancelled')),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _btn(String label, Color bg, Color fg, VoidCallback onTap) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Text(label,
              style: TextStyle(
                  fontFamily: 'Manrope', fontSize: 13,
                  fontWeight: FontWeight.w700, color: fg)),
        ),
      ),
    );
  }

  static String? _fmt(dynamic iso) {
    if (iso == null) return null;
    final dt = DateTime.tryParse(iso.toString())?.toLocal();
    if (dt == null) return null;
    const months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $h:$m';
  }
}
