import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'hr_psikolog_form_page.dart';

class HrPsikologListPage extends StatefulWidget {
  const HrPsikologListPage({super.key});

  @override
  State<HrPsikologListPage> createState() => _HrPsikologListPageState();
}

class _HrPsikologListPageState extends State<HrPsikologListPage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _psikologs = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await ApiService.getPsikologs();
      if (!mounted) return;
      setState(() { _psikologs = data; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> _addPsikolog() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const HrPsikologFormPage()),
    );
    if (result == true && mounted) {
      _load();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Psikolog berhasil ditambahkan'),
          backgroundColor: Color(0xFF166534),
        ),
      );
    }
  }

  Future<void> _editPsikolog(Map<String, dynamic> p) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => HrPsikologFormPage(psikolog: p)),
    );
    if (result == true && mounted) {
      _load();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data psikolog diperbarui'),
          backgroundColor: Color(0xFF166534),
        ),
      );
    }
  }

  Future<void> _deletePsikolog(Map<String, dynamic> p) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Psikolog?',
            style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700)),
        content: Text('Yakin ingin menghapus ${p['nama']}? Tindakan ini tidak dapat dibatalkan.',
            style: const TextStyle(fontFamily: 'NimbusSans')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF9D174D)),
              child: const Text('Hapus')),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await ApiService.deletePsikolog(p['id'] as int);
      if (!mounted) return;
      _load();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${p['nama']} dihapus'),
          backgroundColor: const Color(0xFF166534),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: const Color(0xFF9D174D),
        ),
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
            _buildHeader(),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF245A72)))
                  : _error != null
                      ? _buildError()
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: _psikologs.isEmpty ? _buildEmpty() : _buildList(),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addPsikolog,
        backgroundColor: const Color(0xFF245A72),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add, size: 20),
        label: const Text('Tambah Psikolog',
            style: TextStyle(
                fontFamily: 'NimbusSans', fontSize: 13, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-0.7, -1), end: Alignment(0.7, 1),
          colors: [Color(0xFFB3F3F4), Color(0xFF61D1DB)],
        ),
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(32),
            bottomRight: Radius.circular(32)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: Color(0xFF245A72), size: 16),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('RISKALA LITE',
                  style: TextStyle(
                      fontFamily: 'NimbusSans', fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF245A72).withValues(alpha: 0.6),
                      letterSpacing: 1.2)),
              const Text('Kelola Psikolog',
                  style: TextStyle(
                      fontFamily: 'Manrope', fontSize: 22,
                      fontWeight: FontWeight.w700, color: Color(0xFF245A72))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Color(0xFF9D174D), size: 48),
          const SizedBox(height: 12),
          Text(_error!,
              style: const TextStyle(fontFamily: 'NimbusSans', color: Color(0xFF245A72))),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _load, child: const Text('Coba lagi')),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 80),
        Icon(Icons.psychology_outlined, size: 64,
            color: const Color(0xFF245A72).withValues(alpha: 0.2)),
        const SizedBox(height: 12),
        Text('Belum ada psikolog terdaftar',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'NimbusSans', fontSize: 15,
                color: const Color(0xFF245A72).withValues(alpha: 0.5))),
        const SizedBox(height: 8),
        Text('Tap "Tambah Psikolog" untuk mulai',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'NimbusSans', fontSize: 13,
                color: const Color(0xFF245A72).withValues(alpha: 0.4))),
      ],
    );
  }

  Widget _buildList() {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 96),
      itemCount: _psikologs.length,
      itemBuilder: (_, i) => _buildCard(_psikologs[i]),
    );
  }

  Widget _buildCard(Map<String, dynamic> p) {
    final isAvailable = p['is_available'] == true;
    final caseload = (p['active_caseload'] as num?)?.toInt() ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF245A72).withValues(alpha: 0.04),
              blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                    color: const Color(0xFF245A72).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.psychology_outlined,
                    color: Color(0xFF245A72), size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p['nama']?.toString() ?? '-',
                        style: const TextStyle(
                            fontFamily: 'Manrope', fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF245A72))),
                    if ((p['spesialisasi']?.toString().isNotEmpty ?? false))
                      Text(p['spesialisasi'].toString(),
                          style: const TextStyle(
                              fontFamily: 'NimbusSans', fontSize: 12,
                              color: Color(0xFF94A3B8))),
                  ],
                ),
              ),
              _buildBadge(isAvailable),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.email_outlined, size: 14, color: Color(0xFF94A3B8)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(p['email']?.toString() ?? '-',
                    style: const TextStyle(
                        fontFamily: 'NimbusSans', fontSize: 12,
                        color: Color(0xFF568B8F)),
                    overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 12),
              Icon(Icons.folder_outlined, size: 14,
                  color: caseload >= 3
                      ? const Color(0xFF9D174D)
                      : const Color(0xFF94A3B8)),
              const SizedBox(width: 4),
              Text('$caseload kasus',
                  style: TextStyle(
                      fontFamily: 'NimbusSans', fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: caseload >= 3
                          ? const Color(0xFF9D174D)
                          : const Color(0xFF568B8F))),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: const Color(0xFF245A72).withValues(alpha: 0.06)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _editPsikolog(p),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF245A72),
                      textStyle: const TextStyle(
                          fontFamily: 'NimbusSans',
                          fontWeight: FontWeight.w700)),
                ),
              ),
              Container(width: 1, height: 20,
                  color: const Color(0xFF245A72).withValues(alpha: 0.08)),
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _deletePsikolog(p),
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Hapus'),
                  style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF9D174D),
                      textStyle: const TextStyle(
                          fontFamily: 'NimbusSans',
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(bool isAvailable) {
    final bg = isAvailable ? const Color(0xFFDCFCE7) : const Color(0xFFFCE7F3);
    final fg = isAvailable ? const Color(0xFF166534) : const Color(0xFF9D174D);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(9999)),
      child: Text(isAvailable ? 'Available' : 'Penuh',
          style: TextStyle(
              fontFamily: 'NimbusSans', fontSize: 10,
              fontWeight: FontWeight.w700, color: fg, letterSpacing: 0.3)),
    );
  }
}
