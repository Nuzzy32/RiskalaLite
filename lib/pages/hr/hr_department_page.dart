import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/api_service.dart';

const _kBrand = AppColors.brand;
const _kAccent = AppColors.accent;
const _kSubtle = AppColors.subtle;
const _kBg = Color(0xFFF6F8F8);

/// HR manages their company's departments/divisions (add / rename / delete).
class HrDepartmentPage extends StatefulWidget {
  const HrDepartmentPage({super.key});

  @override
  State<HrDepartmentPage> createState() => _HrDepartmentPageState();
}

class _HrDepartmentPageState extends State<HrDepartmentPage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _departments = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final d = await ApiService.getDepartments();
      if (!mounted) return;
      setState(() { _departments = d; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _showForm({Map<String, dynamic>? existing}) async {
    final isEdit = existing != null;
    final ctrl = TextEditingController(
        text: existing?['nama_department']?.toString() ?? '');
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: _kBrand.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(isEdit ? 'Ubah Nama Departemen' : 'Tambah Departemen',
                  style: const TextStyle(
                      fontFamily: 'Manrope', fontSize: 18,
                      fontWeight: FontWeight.w700, color: _kBrand)),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(color: _kBrand, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Nama departemen',
                  filled: true,
                  fillColor: const Color(0xFFF6F8F8),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kBrand,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                  ),
                  child: Text(isEdit ? 'Simpan' : 'Tambah',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (result == null || result.isEmpty) return;
    try {
      if (isEdit) {
        await ApiService.updateDepartment(existing['id_department'], result);
      } else {
        await ApiService.createDepartment(result);
      }
      await _load();
      _toast(isEdit ? 'Departemen diperbarui' : 'Departemen ditambahkan', ok: true);
    } catch (e) {
      _toast(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _confirmDelete(Map<String, dynamic> dept) async {
    final count = (dept['employee_count'] as num?)?.toInt() ?? 0;
    if (count > 0) {
      _toast('Tidak bisa dihapus — masih ada $count karyawan di departemen ini.');
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Hapus departemen?',
            style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700)),
        content: Text('"${dept['nama_department']}" akan dihapus permanen.',
            style: const TextStyle(fontFamily: 'NimbusSans')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal', style: TextStyle(color: _kSubtle))),
          TextButton(onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Hapus', style: TextStyle(color: AppColors.danger))),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ApiService.deleteDepartment(dept['id_department']);
      await _load();
      _toast('Departemen dihapus', ok: true);
    } catch (e) {
      _toast(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _toast(String msg, {bool ok = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: ok ? AppColors.success : const Color(0xFF9D174D),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: _kBrand),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Kelola Departemen',
            style: TextStyle(color: _kBrand, fontSize: 17, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(),
        backgroundColor: _kBrand,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Tambah',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: _kBrand,
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: _kBrand))
            : _error != null
                ? _errorView()
                : _departments.isEmpty
                    ? _emptyView()
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                        itemCount: _departments.length,
                        separatorBuilder: (_, i) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => _deptCard(_departments[i]),
                      ),
      ),
    );
  }

  Widget _deptCard(Map<String, dynamic> dept) {
    final count = (dept['employee_count'] as num?)?.toInt() ?? 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _kBrand.withValues(alpha: 0.05),
            blurRadius: 12, offset: const Offset(0, 4), spreadRadius: -3,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: _kAccent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.apartment_rounded, color: _kAccent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dept['nama_department']?.toString() ?? '-',
                    style: const TextStyle(
                        fontFamily: 'Manrope', fontSize: 15,
                        fontWeight: FontWeight.w700, color: _kBrand)),
                const SizedBox(height: 2),
                Text('$count karyawan',
                    style: const TextStyle(
                        fontFamily: 'NimbusSans', fontSize: 12.5, color: _kSubtle)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20, color: _kSubtle),
            onPressed: () => _showForm(existing: dept),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, size: 20,
                color: count > 0 ? const Color(0xFFCBD5E1) : AppColors.danger),
            onPressed: () => _confirmDelete(dept),
          ),
        ],
      ),
    );
  }

  Widget _emptyView() => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          const Icon(Icons.apartment_outlined, size: 48, color: _kAccent),
          const SizedBox(height: 12),
          const Center(
            child: Text('Belum ada departemen',
                style: TextStyle(
                    fontFamily: 'Manrope', fontSize: 16,
                    fontWeight: FontWeight.w700, color: _kBrand)),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text('Tekan "Tambah" untuk membuat departemen pertama.',
                style: TextStyle(
                    fontFamily: 'NimbusSans', fontSize: 13,
                    color: _kBrand.withValues(alpha: 0.55))),
          ),
        ],
      );

  Widget _errorView() => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          const Icon(Icons.cloud_off_rounded, size: 44, color: _kSubtle),
          const SizedBox(height: 12),
          Center(child: Text(_error ?? 'Gagal memuat',
              style: const TextStyle(fontFamily: 'NimbusSans', color: _kBrand))),
          const SizedBox(height: 12),
          Center(child: TextButton(onPressed: _load, child: const Text('Coba lagi'))),
        ],
      );
}
