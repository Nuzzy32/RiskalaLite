import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class HrAddEmployeePage extends StatefulWidget {
  final Map<String, dynamic>? employee;
  const HrAddEmployeePage({super.key, this.employee});

  @override
  State<HrAddEmployeePage> createState() => _HrAddEmployeePageState();
}

class _HrAddEmployeePageState extends State<HrAddEmployeePage> {
  bool get _isEdit => widget.employee != null;

  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  bool _obscurePass = true;
  bool _loading = false;
  bool _loadingDepts = true;
  bool _deptError = false;

  int _roleUser = 0;
  int? _selectedDeptId;
  List<Map<String, dynamic>> _departments = [];

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final emp = widget.employee!;
      _idController.text = emp['id_user']?.toString() ?? '';
      _namaController.text = emp['nama_user']?.toString() ?? '';
      _emailController.text = emp['email_user']?.toString() ?? '';
      _roleUser = (emp['role_user'] as num?)?.toInt() ?? 0;
    }
    _loadDepartments();
  }

  @override
  void dispose() {
    _idController.dispose();
    _namaController.dispose();
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Future<void> _loadDepartments() async {
    setState(() { _loadingDepts = true; _deptError = false; });
    try {
      final depts = await ApiService.getDepartments();
      int? initialDeptId;
      if (_isEdit) {
        final deptName = widget.employee!['department']?.toString();
        if (deptName != null) {
          final match = depts.firstWhere(
            (d) => d['nama_department']?.toString() == deptName,
            orElse: () => {},
          );
          if (match.isNotEmpty) initialDeptId = match['id_department'] as int?;
        }
      }
      setState(() {
        _departments = depts;
        _loadingDepts = false;
        _deptError = depts.isEmpty;
        if (initialDeptId != null) _selectedDeptId = initialDeptId;
      });
    } catch (e) {
      debugPrint('[HrAddEmployeePage] Failed to load departments: $e');
      setState(() { _loadingDepts = false; _deptError = true; });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDeptId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih departemen terlebih dahulu')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      if (_isEdit) {
        await ApiService.updateEmployee(
          _idController.text,
          namaUser: _namaController.text.trim(),
          emailUser: _emailController.text.trim(),
          passwdUser: _passController.text.isNotEmpty ? _passController.text : null,
          idDepartment: _selectedDeptId!,
          roleUser: _roleUser,
        );
      } else {
        await ApiService.createEmployee(
          idUser: _idController.text.trim().toUpperCase(),
          namaUser: _namaController.text.trim(),
          emailUser: _emailController.text.trim(),
          passwdUser: _passController.text,
          idDepartment: _selectedDeptId!,
          roleUser: _roleUser,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEdit
                ? '${_namaController.text.trim()} berhasil diperbarui'
                : '${_namaController.text.trim()} berhasil ditambahkan',
          ),
          backgroundColor: const Color(0xFF166534),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
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
            _buildHeader(context),
            Expanded(
              child: _loadingDepts
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF245A72)))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionLabel('INFORMASI AKUN'),
                            const SizedBox(height: 12),
                            _buildCard(
                              children: [
                                _buildField(
                                  controller: _idController,
                                  label: 'ID User',
                                  hint: 'Contoh: ENG08',
                                  icon: Icons.badge_outlined,
                                  maxLength: 5,
                                  readOnly: _isEdit,
                                  textCapitalization: TextCapitalization.characters,
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) return 'ID User wajib diisi';
                                    if (v.trim().length != 5) return 'ID User harus tepat 5 karakter';
                                    return null;
                                  },
                                ),
                                _buildDivider(),
                                _buildField(
                                  controller: _namaController,
                                  label: 'Nama Lengkap',
                                  hint: 'Masukkan nama lengkap',
                                  icon: Icons.person_outline,
                                  validator: (v) =>
                                      v == null || v.trim().isEmpty ? 'Nama wajib diisi' : null,
                                ),
                                _buildDivider(),
                                _buildField(
                                  controller: _emailController,
                                  label: 'Email',
                                  hint: 'nama@perusahaan.com',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
                                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
                                      return 'Format email tidak valid';
                                    }
                                    return null;
                                  },
                                ),
                                _buildDivider(),
                                _buildPasswordField(),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _buildSectionLabel('PENEMPATAN'),
                            const SizedBox(height: 12),
                            _buildCard(
                              children: [
                                _buildDepartmentDropdown(),
                                _buildDivider(),
                                _buildRoleSelector(),
                              ],
                            ),
                            const SizedBox(height: 32),
                            _buildSubmitButton(),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-0.7, -1),
          end: Alignment(0.7, 1),
          colors: [Color(0xFFB3F3F4), Color(0xFF61D1DB)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF245A72), size: 16),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'RISKALA LITE',
                style: TextStyle(
                  fontFamily: 'NimbusSans',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF245A72).withValues(alpha: 0.6),
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                _isEdit ? 'Edit Employee' : 'Tambah Employee',
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF245A72),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'NimbusSans',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF245A72).withValues(alpha: 0.5),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF245A72).withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: const Color(0xFF245A72).withValues(alpha: 0.07),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.words,
    int? maxLength,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        maxLength: maxLength,
        readOnly: readOnly,
        validator: validator,
        style: TextStyle(
          fontFamily: 'NimbusSans',
          fontSize: 14,
          color: readOnly
              ? const Color(0xFF245A72).withValues(alpha: 0.4)
              : const Color(0xFF245A72),
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          counterText: '',
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, size: 18, color: const Color(0xFF61D1DB)),
          labelStyle: TextStyle(
            fontFamily: 'NimbusSans',
            fontSize: 13,
            color: const Color(0xFF245A72).withValues(alpha: 0.6),
          ),
          hintStyle: TextStyle(
            fontFamily: 'NimbusSans',
            fontSize: 13,
            color: const Color(0xFF245A72).withValues(alpha: 0.3),
          ),
          border: InputBorder.none,
          errorStyle: const TextStyle(fontFamily: 'NimbusSans', fontSize: 11),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: TextFormField(
        controller: _passController,
        obscureText: _obscurePass,
        validator: _isEdit
            ? (v) {
                if (v != null && v.isNotEmpty && v.length < 6) {
                  return 'Password minimal 6 karakter';
                }
                return null;
              }
            : (v) {
                if (v == null || v.isEmpty) return 'Password wajib diisi';
                if (v.length < 6) return 'Password minimal 6 karakter';
                return null;
              },
        style: const TextStyle(
          fontFamily: 'NimbusSans',
          fontSize: 14,
          color: Color(0xFF245A72),
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          labelText: 'Password',
          hintText: _isEdit ? 'Kosongkan jika tidak diubah' : 'Minimal 6 karakter',
          prefixIcon: const Icon(Icons.lock_outline, size: 18, color: Color(0xFF61D1DB)),
          suffixIcon: GestureDetector(
            onTap: () => setState(() => _obscurePass = !_obscurePass),
            child: Icon(
              _obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              size: 18,
              color: const Color(0xFF245A72).withValues(alpha: 0.4),
            ),
          ),
          labelStyle: TextStyle(
            fontFamily: 'NimbusSans',
            fontSize: 13,
            color: const Color(0xFF245A72).withValues(alpha: 0.6),
          ),
          hintStyle: TextStyle(
            fontFamily: 'NimbusSans',
            fontSize: 13,
            color: const Color(0xFF245A72).withValues(alpha: 0.3),
          ),
          border: InputBorder.none,
          errorStyle: const TextStyle(fontFamily: 'NimbusSans', fontSize: 11),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildDepartmentDropdown() {
    final selected = _selectedDeptId != null
        ? _departments.firstWhere(
            (d) => d['id_department'] == _selectedDeptId,
            orElse: () => {},
          )
        : null;
    final selectedName = selected?['nama_department']?.toString();

    return GestureDetector(
      onTap: _showDepartmentSheet,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          children: [
            const Icon(Icons.apartment_outlined, size: 18, color: Color(0xFF61D1DB)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedName ?? 'Pilih departemen',
                style: TextStyle(
                  fontFamily: 'NimbusSans',
                  fontSize: 14,
                  fontWeight: selectedName != null ? FontWeight.w600 : FontWeight.w400,
                  color: selectedName != null
                      ? const Color(0xFF245A72)
                      : const Color(0xFF245A72).withValues(alpha: 0.35),
                ),
              ),
            ),
            Icon(Icons.keyboard_arrow_down,
                size: 20, color: const Color(0xFF245A72).withValues(alpha: 0.4)),
          ],
        ),
      ),
    );
  }

  void _showDepartmentSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF245A72).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Pilih Departemen',
              style: TextStyle(
                fontFamily: 'Manrope', fontSize: 16,
                fontWeight: FontWeight.w700, color: Color(0xFF245A72),
              ),
            ),
            const SizedBox(height: 16),
            if (_loadingDepts)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator(color: Color(0xFF245A72))),
              )
            else if (_deptError || _departments.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Icon(Icons.wifi_off_outlined, size: 40,
                        color: const Color(0xFF245A72).withValues(alpha: 0.3)),
                    const SizedBox(height: 12),
                    Text(
                      'Gagal memuat departemen',
                      style: TextStyle(
                        fontFamily: 'NimbusSans',
                        fontSize: 14,
                        color: const Color(0xFF245A72).withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _loadDepartments().then((_) {
                          if (mounted && _departments.isNotEmpty) {
                            _showDepartmentSheet();
                          }
                        });
                      },
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Coba lagi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF245A72),
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(fontFamily: 'NimbusSans', fontWeight: FontWeight.w600),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              )
            else
              ..._departments.map((d) {
                final id = d['id_department'] as int;
                final name = d['nama_department']?.toString() ?? '-';
                final isSelected = _selectedDeptId == id;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedDeptId = id);
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF245A72).withValues(alpha: 0.08)
                          : const Color(0xFFF8FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF245A72).withValues(alpha: 0.3)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: TextStyle(
                              fontFamily: 'NimbusSans',
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: const Color(0xFF245A72),
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle, size: 18, color: Color(0xFF245A72)),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.manage_accounts_outlined, size: 18, color: Color(0xFF61D1DB)),
              const SizedBox(width: 12),
              Text(
                'Role',
                style: TextStyle(
                  fontFamily: 'NimbusSans',
                  fontSize: 13,
                  color: const Color(0xFF245A72).withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _roleChip(label: 'Employee', value: 0),
              const SizedBox(width: 12),
              _roleChip(label: 'HR', value: 1),
            ],
          ),
        ],
      ),
    );
  }

  Widget _roleChip({required String label, required int value}) {
    final selected = _roleUser == value;
    return GestureDetector(
      onTap: () => setState(() => _roleUser = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF245A72) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF245A72) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'NimbusSans',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : const Color(0xFF245A72).withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _loading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF245A72),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF245A72).withValues(alpha: 0.4),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Text(
                _isEdit ? 'Simpan Perubahan' : 'Tambah Employee',
                style: const TextStyle(
                  fontFamily: 'NimbusSans',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
      ),
    );
  }
}
