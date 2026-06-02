import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/api_service.dart';
import 'psikolog_case_detail_page.dart';
import 'psikolog_bookings_page.dart';

const _kBrand = AppColors.brand;
const _kAccent = AppColors.accent;
const _kBg = Color(0xFFF6F8F8);

/// Psikolog portal home — the caseload of assigned incident reports.
class PsikologHomePage extends StatefulWidget {
  const PsikologHomePage({super.key});

  @override
  State<PsikologHomePage> createState() => _PsikologHomePageState();
}

class _PsikologHomePageState extends State<PsikologHomePage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _cases = [];
  String _filter = 'all'; // all | proses | selesai

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final cases = await ApiService.getPsikologCases(
        status: _filter == 'all' ? null : _filter,
      );
      // Refresh the cached profile so the caseload count stays accurate.
      await ApiService.refreshPsikolog();
      if (!mounted) return;
      setState(() { _cases = cases; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _setFilter(String f) {
    if (_filter == f) return;
    setState(() => _filter = f);
    _load();
  }

  Future<void> _logout() async {
    await ApiService.psikologLogout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/entry/employee', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PsikologBookingsPage()),
        ),
        backgroundColor: _kBrand,
        icon: const Icon(Icons.event_available_rounded, color: Colors.white),
        label: const Text('Booking',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: _kBrand,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildFilters()),
            if (_loading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator(color: _kBrand)),
              )
            else if (_error != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildError(),
              )
            else if (_cases.isEmpty)
              SliverFillRemaining(hasScrollBody: false, child: _buildEmpty())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                sliver: SliverList.builder(
                  itemCount: _cases.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _CaseCard(
                      data: _cases[i],
                      index: i,
                      onTap: () async {
                        final changed = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PsikologCaseDetailPage(caseData: _cases[i]),
                          ),
                        );
                        if (changed == true) _load();
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final caseload = ApiService.psikologCaseload;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-0.7, -1), end: Alignment(0.7, 1),
          colors: [AppColors.accentLight, AppColors.accent],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text('Portal Psikolog',
                      style: TextStyle(
                          fontFamily: 'NimbusSans', fontSize: 13,
                          fontWeight: FontWeight.w600, color: Colors.white)),
                ),
                GestureDetector(
                  onTap: _logout,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.logout_rounded, size: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Halo, ${ApiService.psikologName} 👋',
                style: const TextStyle(
                    fontFamily: 'Manrope', fontSize: 22,
                    fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 4),
            Text(
              ApiService.psikologSpesialisasi.isNotEmpty
                  ? ApiService.psikologSpesialisasi
                  : 'Psikolog',
              style: TextStyle(
                  fontFamily: 'NimbusSans', fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.9)),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.folder_shared_outlined, size: 20, color: Colors.white),
                  const SizedBox(width: 10),
                  Text('$caseload kasus aktif',
                      style: const TextStyle(
                          fontFamily: 'Manrope', fontSize: 15,
                          fontWeight: FontWeight.w700, color: Colors.white)),
                  const Spacer(),
                  if (caseload >= 3)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text('PENUH',
                          style: TextStyle(
                              fontFamily: 'NimbusSans', fontSize: 10,
                              fontWeight: FontWeight.w800, color: AppColors.danger)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    const filters = {'all': 'Semua', 'proses': 'Diproses', 'selesai': 'Selesai'};
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: filters.entries.map((e) {
          final active = _filter == e.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => _setFilter(e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  color: active ? _kBrand : Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                      color: active ? _kBrand : const Color(0xFFE2E8F0)),
                ),
                child: Text(e.value,
                    style: TextStyle(
                        fontFamily: 'NimbusSans', fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: active ? Colors.white : _kSubtleColor)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: _kAccent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.inbox_outlined, size: 30, color: _kAccent),
            ),
            const SizedBox(height: 16),
            const Text('Belum ada kasus',
                style: TextStyle(
                    fontFamily: 'Manrope', fontSize: 16,
                    fontWeight: FontWeight.w700, color: _kBrand)),
            const SizedBox(height: 6),
            Text(
              _filter == 'all'
                  ? 'Kasus yang ditugaskan HR akan muncul di sini.'
                  : 'Tidak ada kasus dengan status ini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'NimbusSans', fontSize: 13,
                  color: _kBrand.withValues(alpha: 0.55)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 40, color: _kSubtleColor),
            const SizedBox(height: 12),
            Text(_error ?? 'Gagal memuat',
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'NimbusSans', color: _kBrand)),
            const SizedBox(height: 12),
            TextButton(onPressed: _load, child: const Text('Coba lagi')),
          ],
        ),
      ),
    );
  }
}

const _kSubtleColor = AppColors.subtle;

class _CaseCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final int index;
  final VoidCallback onTap;
  const _CaseCard({required this.data, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final user = data['user'] as Map<String, dynamic>?;
    final name = user?['nama_user']?.toString() ?? 'Karyawan';
    final division = user?['department']?.toString() ?? '-';
    final status = data['status']?.toString() ?? 'proses';
    final category = data['nama_kategori']?.toString() ?? 'Laporan';
    final desc = data['deskripsi']?.toString() ?? '';
    final stress = (data['tingkat_stres'] as num?)?.toInt() ?? 0;

    final statusColor = switch (status) {
      'selesai' => AppColors.success,
      'pending' => const Color(0xFF94A3B8),
      _ => AppColors.warning,
    };
    final statusLabel = switch (status) {
      'selesai' => 'Selesai',
      'pending' => 'Menunggu',
      _ => 'Diproses',
    };

    return TweenAnimationBuilder<double>(
      key: ValueKey(data['id_report']),
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 360 + (index.clamp(0, 5)) * 50),
      curve: Curves.easeOutCubic,
      builder: (_, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, 12 * (1 - t)), child: child),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontFamily: 'Manrope', fontSize: 15,
                                fontWeight: FontWeight.w700, color: _kBrand)),
                        const SizedBox(height: 2),
                        Text('$division • $category',
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontFamily: 'NimbusSans', fontSize: 12,
                                color: _kSubtleColor)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(statusLabel,
                        style: TextStyle(
                            fontFamily: 'NimbusSans', fontSize: 11,
                            fontWeight: FontWeight.w700, color: statusColor)),
                  ),
                ],
              ),
              if (desc.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(desc,
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: 'NimbusSans', fontSize: 13, height: 1.4,
                        color: _kBrand.withValues(alpha: 0.7))),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.monitor_heart_outlined, size: 15,
                      color: _kBrand.withValues(alpha: 0.5)),
                  const SizedBox(width: 5),
                  Text('Tingkat stres $stress/5',
                      style: TextStyle(
                          fontFamily: 'NimbusSans', fontSize: 12,
                          color: _kBrand.withValues(alpha: 0.6))),
                  const Spacer(),
                  Text('Lihat detail',
                      style: TextStyle(
                          fontFamily: 'NimbusSans', fontSize: 12,
                          fontWeight: FontWeight.w700, color: _kAccent)),
                  const Icon(Icons.chevron_right_rounded, size: 18, color: _kAccent),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
