import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/api_service.dart';
import 'hr_add_employee_page.dart';

class HrDivisionDetailPage extends StatefulWidget {
  final String divisionName;
  const HrDivisionDetailPage({super.key, required this.divisionName});

  @override
  State<HrDivisionDetailPage> createState() => _HrDivisionDetailPageState();
}

class _HrDivisionDetailPageState extends State<HrDivisionDetailPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _employees = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final all = await ApiService.getEmployees();
      final filtered = all
          .where((e) => (e['department']?.toString() ?? '') == widget.divisionName)
          .toList();
      if (!mounted) return;
      setState(() { _employees = filtered; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  List<Map<String, dynamic>> get _filteredEmployees {
    if (_searchQuery.isEmpty) return _employees;
    final q = _searchQuery.toLowerCase();
    return _employees
        .where((e) => (e['nama_user']?.toString().toLowerCase() ?? '').contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          Container(
            color: const Color(0xFFF8F9FA).withValues(alpha: 0.8),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Icon(Icons.arrow_back_ios, size: 24, color: AppColors.brand),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'DIVISI ${widget.divisionName.toUpperCase()}',
                          style: const TextStyle(
                            fontFamily: 'Manrope', fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.brand, letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: Color(0xFFE0F2F4),
                      child: Icon(Icons.person, color: AppColors.brand, size: 18),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(9999),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: const InputDecoration(
                  hintText: 'Search employees...',
                  hintStyle: TextStyle(
                      fontFamily: 'NimbusSans',
                      fontSize: 14, color: Color(0xFF9CA3AF)),
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(left: 16, right: 8),
                    child: Icon(Icons.search, size: 20, color: Color(0xFF9CA3AF)),
                  ),
                  prefixIconConstraints: BoxConstraints(minWidth: 44),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                ),
                style: const TextStyle(
                    fontFamily: 'NimbusSans', fontSize: 14, color: AppColors.brand),
              ),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
                child: child,
              ),
              child: _loading
                  ? const Center(key: ValueKey('loading'), child: CircularProgressIndicator(color: AppColors.brand))
                  : _error != null
                      ? _buildErrorState()
                      : _filteredEmployees.isEmpty
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              key: const ValueKey('content'),
                              onRefresh: _load,
                              child: ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(24, 0, 24, 140),
                                itemCount: _filteredEmployees.length,
                                separatorBuilder: (_, _) => const SizedBox(height: 16),
                                itemBuilder: (_, i) =>
                                    _buildEmployeeCard(_filteredEmployees[i]),
                              ),
                            ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFF9D174D), size: 48),
            const SizedBox(height: 12),
            Text(_error!,
                style: const TextStyle(fontFamily: 'NimbusSans', color: AppColors.brand)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _load, child: const Text('Coba lagi')),
          ],
        ),
      );

  Widget _buildEmptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 56,
                color: AppColors.brand.withValues(alpha: 0.2)),
            const SizedBox(height: 12),
            Text(
              _searchQuery.isEmpty
                  ? 'Belum ada karyawan di divisi ini'
                  : 'Tidak ditemukan',
              style: TextStyle(
                  fontFamily: 'NimbusSans', fontSize: 14,
                  color: AppColors.brand.withValues(alpha: 0.5)),
            ),
          ],
        ),
      );

  Widget _buildEmployeeCard(Map<String, dynamic> emp) {
    return GestureDetector(
      onTap: () async {
        final updated = await Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (_) => HrAddEmployeePage(employee: emp)),
        );
        if (updated == true) _load();
      },
      onLongPress: () => _confirmDelete(emp),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9999),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 24,
              backgroundColor: Color(0xFFF3F4F6),
              child: Icon(Icons.person, color: AppColors.brand, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(emp['nama_user']?.toString() ?? '-',
                      style: const TextStyle(
                          fontFamily: 'Manrope', fontSize: 16,
                          fontWeight: FontWeight.w700, color: AppColors.brand)),
                  Text((emp['email_user']?.toString() ?? '-').toLowerCase(),
                      style: const TextStyle(
                          fontFamily: 'NimbusSans', fontSize: 11, color: Color(0xFF6B7280))),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2F4),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Text((emp['nip'] ?? emp['id_user'])?.toString() ?? '-',
                  style: const TextStyle(
                      fontFamily: 'NimbusSans', fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brand, letterSpacing: 0.25)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(Map<String, dynamic> emp) async {
    final name = emp['nama_user']?.toString() ?? 'Employee ini';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Hapus Employee',
          style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700, color: AppColors.brand),
        ),
        content: Text(
          'Yakin ingin menghapus $name? Tindakan ini tidak bisa dibatalkan.',
          style: const TextStyle(fontFamily: 'NimbusSans', fontSize: 14, color: AppColors.brand),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(fontFamily: 'NimbusSans', color: AppColors.brand)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9D174D),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Hapus', style: TextStyle(fontFamily: 'NimbusSans', fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await ApiService.deleteEmployee(emp['id_user']?.toString() ?? '');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$name berhasil dihapus'),
          backgroundColor: const Color(0xFF166534),
        ),
      );
      _load();
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
}
