import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'package:flutter/services.dart';
import '../../services/api_service.dart';
import 'hr_add_employee_page.dart';
import 'hr_psikolog_list_page.dart';
import 'hr_department_page.dart';

class HrProfilePage extends StatefulWidget {
  final bool showNav;
  const HrProfilePage({super.key, this.showNav = true});

  @override
  State<HrProfilePage> createState() => _HrProfilePageState();
}

class _HrProfilePageState extends State<HrProfilePage> {
  // HR notification preferences (persisted to backend).
  bool _notifHighStress = ApiService.notifHighStress;
  bool _notifNewReport = ApiService.notifNewReport;
  bool _notifWeekly = ApiService.notifWeeklySummary;

  String _companyName = ApiService.userCompany;

  String get _hrName => ApiService.userName.isNotEmpty ? ApiService.userName : 'HR';

  Future<void> _toggleNotif(String key, bool v) async {
    setState(() {
      if (key == 'high') _notifHighStress = v;
      if (key == 'report') _notifNewReport = v;
      if (key == 'weekly') _notifWeekly = v;
    });
    try {
      await ApiService.updateHrNotifications(
        highStress: key == 'high' ? v : null,
        newReport: key == 'report' ? v : null,
        weeklySummary: key == 'weekly' ? v : null,
      );
    } catch (e) {
      if (!mounted) return;
      // Roll back on failure.
      setState(() {
        if (key == 'high') _notifHighStress = !v;
        if (key == 'report') _notifNewReport = !v;
        if (key == 'weekly') _notifWeekly = !v;
      });
      _snack(e.toString().replaceFirst('Exception: ', ''), ok: false);
    }
  }

  void _copyCode() {
    final code = ApiService.companyCode;
    if (code.isEmpty) return;
    Clipboard.setData(ClipboardData(text: code));
    _snack('Kode perusahaan "$code" disalin', ok: true);
  }

  Future<void> _editCompany() async {
    final updated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _EditCompanySheet(),
    );
    if (updated == true && mounted) {
      setState(() => _companyName = ApiService.userCompany);
      _snack('Profil perusahaan diperbarui', ok: true);
    }
  }

  void _snack(String msg, {required bool ok}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: ok ? const Color(0xFF166534) : const Color(0xFF9D174D),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F8),
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  const Text(
                    'Profile & Settings',
                    style: TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brand,
                      letterSpacing: -0.45,
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                children: [
                  // Avatar & info
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        Container(
                          width: 128,
                          height: 128,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            color: const Color(0xFFE0F2F4),
                          ),
                          child: const Icon(Icons.person, size: 56, color: AppColors.brand),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _hrName,
                          style: const TextStyle(
                            fontFamily: 'Public Sans',
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.brand,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'HR Manager @ Riskala',
                          style: TextStyle(
                            fontFamily: 'Public Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.brand.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: const Text(
                            'HR ADMIN',
                            style: TextStyle(
                              fontFamily: 'Public Sans',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.accent,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // HR Management section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 16),
                          child: Text(
                            'MANAJEMEN KARYAWAN',
                            style: TextStyle(
                              fontFamily: 'Public Sans',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.brand.withValues(alpha: 0.5),
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),

                        // Tambah Employee card
                        GestureDetector(
                          onTap: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            final result = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const HrAddEmployeePage(),
                              ),
                            );
                            if (result == true) {
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Data employee berhasil ditambahkan'),
                                  backgroundColor: Color(0xFF166534),
                                ),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.brand.withValues(alpha: 0.04),
                                  blurRadius: 12,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.brand.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.person_add_outlined,
                                    color: AppColors.brand,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Tambah Employee',
                                        style: TextStyle(
                                          fontFamily: 'Public Sans',
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.brand,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Daftarkan karyawan atau HR baru',
                                        style: TextStyle(
                                          fontFamily: 'Public Sans',
                                          fontSize: 12,
                                          color: AppColors.brand.withValues(alpha: 0.55),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: AppColors.brand.withValues(alpha: 0.3),
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Kelola Psikolog card
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HrPsikologListPage(),
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.brand.withValues(alpha: 0.04),
                                  blurRadius: 12,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.accent.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.psychology_outlined,
                                    color: AppColors.brand,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Kelola Psikolog',
                                        style: TextStyle(
                                          fontFamily: 'Public Sans',
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.brand,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Tambah, edit, atau hapus data psikolog',
                                        style: TextStyle(
                                          fontFamily: 'Public Sans',
                                          fontSize: 12,
                                          color: AppColors.brand.withValues(alpha: 0.55),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: AppColors.brand.withValues(alpha: 0.3),
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Kelola Departemen card
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const HrDepartmentPage()),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.brand.withValues(alpha: 0.04),
                                  blurRadius: 12, offset: const Offset(0, 2)),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44, height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.accent.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.apartment_rounded,
                                      color: AppColors.brand, size: 20),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Kelola Departemen',
                                          style: TextStyle(
                                              fontFamily: 'Public Sans', fontSize: 15,
                                              fontWeight: FontWeight.w600, color: AppColors.brand)),
                                      const SizedBox(height: 2),
                                      Text('Tambah, ubah nama, atau hapus divisi',
                                          style: TextStyle(
                                              fontFamily: 'Public Sans', fontSize: 12,
                                              color: AppColors.brand.withValues(alpha: 0.55))),
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_right,
                                    color: AppColors.brand.withValues(alpha: 0.3), size: 20),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Kode Perusahaan — share with employees to onboard
                        _buildCompanyCodeCard(),

                        const SizedBox(height: 28),

                        Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 16),
                          child: Text(
                            'ACCOUNT SETTINGS',
                            style: TextStyle(
                              fontFamily: 'Public Sans',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.brand.withValues(alpha: 0.5),
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            children: [
                              // Notifikasi HR
                              _notifTile(
                                icon: Icons.warning_amber_rounded,
                                title: 'Alert Stres Tinggi',
                                subtitle: 'Saat karyawan terdeteksi stres tinggi',
                                value: _notifHighStress,
                                onChanged: (v) => _toggleNotif('high', v),
                              ),
                              Divider(height: 1, indent: 16, endIndent: 16,
                                  color: AppColors.brand.withValues(alpha: 0.07)),
                              _notifTile(
                                icon: Icons.assignment_outlined,
                                title: 'Laporan Insiden Baru',
                                subtitle: 'Saat ada laporan masuk',
                                value: _notifNewReport,
                                onChanged: (v) => _toggleNotif('report', v),
                              ),
                              Divider(height: 1, indent: 16, endIndent: 16,
                                  color: AppColors.brand.withValues(alpha: 0.07)),
                              _notifTile(
                                icon: Icons.summarize_outlined,
                                title: 'Ringkasan Mingguan',
                                subtitle: 'Rangkuman tren tim via email',
                                value: _notifWeekly,
                                onChanged: (v) => _toggleNotif('weekly', v),
                              ),

                              Divider(height: 1, indent: 16, endIndent: 16,
                                  color: AppColors.brand.withValues(alpha: 0.07)),

                              // Info Perusahaan — tap to edit
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: _editCompany,
                                child: _settingsItem(
                                  icon: Icons.business_outlined,
                                  title: 'Profil Perusahaan',
                                  subtitle: _companyName.isNotEmpty ? _companyName : 'Atur profil perusahaan',
                                  trailing: const Icon(Icons.chevron_right_rounded,
                                      color: Color(0xFF94A3B8)),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Log Out
                        GestureDetector(
                          onTap: () async {
                            final nav = Navigator.of(context);
                            await ApiService.logout();
                            if (!mounted) return;
                            nav.pushReplacementNamed('/');
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(17),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.accent.withValues(alpha: 0.2),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.logout, color: AppColors.brand, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Log Out',
                                  style: TextStyle(
                                    fontFamily: 'Public Sans',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.brand,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFE0F2F4),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.accent, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.brand,
                    )),
                Text(subtitle,
                    style: const TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                    )),
              ],
            ),
          ),
          trailing ??
              Icon(Icons.chevron_right,
                  color: AppColors.brand.withValues(alpha: 0.3), size: 20),
        ],
      ),
    );
  }

  Widget _buildCompanyCodeCard() {
    final code = ApiService.companyCode;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment(-0.7, -1), end: Alignment(0.7, 1),
          colors: [Color(0xFF2C6B82), AppColors.brand],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.brand.withValues(alpha: 0.25),
            blurRadius: 20, offset: const Offset(0, 8), spreadRadius: -6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.qr_code_2_rounded, color: AppColors.accentLight, size: 18),
              const SizedBox(width: 8),
              Text('KODE PERUSAHAAN',
                  style: TextStyle(
                      fontFamily: 'NimbusSans', fontSize: 12,
                      fontWeight: FontWeight.w700, letterSpacing: 0.8,
                      color: Colors.white.withValues(alpha: 0.85))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  code.isEmpty ? '—' : code,
                  style: const TextStyle(
                      fontFamily: 'Manrope', fontSize: 30,
                      fontWeight: FontWeight.w800, letterSpacing: 4, color: Colors.white),
                ),
              ),
              GestureDetector(
                onTap: _copyCode,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.copy_rounded, size: 16, color: Colors.white),
                      SizedBox(width: 6),
                      Text('Salin',
                          style: TextStyle(
                              fontFamily: 'Manrope', fontSize: 13,
                              fontWeight: FontWeight.w700, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('Bagikan kode ini ke karyawan agar mereka bisa masuk ke aplikasi.',
              style: TextStyle(
                  fontFamily: 'NimbusSans', fontSize: 12, height: 1.4,
                  color: Colors.white.withValues(alpha: 0.8))),
        ],
      ),
    );
  }

  Widget _notifTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFE0F2F4), shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.accent, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontFamily: 'Public Sans', fontSize: 15,
                        fontWeight: FontWeight.w500, color: AppColors.brand)),
                Text(subtitle,
                    style: const TextStyle(
                        fontFamily: 'Public Sans', fontSize: 12, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.accent,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFE2E8F0),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
// Edit company profile bottom sheet
// ──────────────────────────────────────────────────────────────────────────

class _EditCompanySheet extends StatefulWidget {
  const _EditCompanySheet();

  @override
  State<_EditCompanySheet> createState() => _EditCompanySheetState();
}

class _EditCompanySheetState extends State<_EditCompanySheet> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _industry = TextEditingController();
  String? _range;
  bool _loading = true;
  bool _saving = false;

  static const _ranges = ['1-10', '11-50', '51-200', '201-500', '500+'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final c = await ApiService.getCompany();
      if (!mounted) return;
      setState(() {
        _name.text = c['name']?.toString() ?? '';
        _industry.text = c['industry']?.toString() ?? '';
        final r = c['employee_range']?.toString();
        _range = _ranges.contains(r) ? r : null;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _industry.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      await ApiService.updateCompany(
        name: _name.text.trim(),
        industry: _industry.text.trim(),
        employeeRange: _range,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString().replaceFirst('Exception: ', '')),
        backgroundColor: const Color(0xFF9D174D),
      ));
    }
  }

  InputDecoration _decor(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.subtle, fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF6F8F8),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
        child: _loading
            ? const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator(color: AppColors.brand)))
            : Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40, height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.brand.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(999)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Profil Perusahaan',
                        style: TextStyle(
                            fontFamily: 'Manrope', fontSize: 18,
                            fontWeight: FontWeight.w700, color: AppColors.brand)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _name,
                      style: const TextStyle(color: AppColors.brand, fontSize: 15),
                      decoration: _decor('Nama Perusahaan'),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _industry,
                      style: const TextStyle(color: AppColors.brand, fontSize: 15),
                      decoration: _decor('Industri'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _range,
                      decoration: _decor('Jumlah Karyawan'),
                      items: _ranges
                          .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                          .toList(),
                      onChanged: (v) => setState(() => _range = v),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brand,
                          disabledBackgroundColor: AppColors.brand.withValues(alpha: 0.45),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 22, height: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation(Colors.white)))
                            : const Text('Simpan',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
