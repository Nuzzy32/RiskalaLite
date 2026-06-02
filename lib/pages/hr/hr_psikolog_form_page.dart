import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/api_service.dart';

class HrPsikologFormPage extends StatefulWidget {
  final Map<String, dynamic>? psikolog;
  const HrPsikologFormPage({super.key, this.psikolog});

  @override
  State<HrPsikologFormPage> createState() => _HrPsikologFormPageState();
}

class _HrPsikologFormPageState extends State<HrPsikologFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _spesCtrl;
  late final TextEditingController _telpCtrl;
  bool _saving = false;

  bool get _isEdit => widget.psikolog != null;

  @override
  void initState() {
    super.initState();
    _namaCtrl = TextEditingController(text: widget.psikolog?['nama']?.toString() ?? '');
    _emailCtrl = TextEditingController(text: widget.psikolog?['email']?.toString() ?? '');
    _spesCtrl = TextEditingController(text: widget.psikolog?['spesialisasi']?.toString() ?? '');
    _telpCtrl = TextEditingController(text: widget.psikolog?['no_telp']?.toString() ?? '');
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _emailCtrl.dispose();
    _spesCtrl.dispose();
    _telpCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      if (_isEdit) {
        await ApiService.updatePsikolog(
          widget.psikolog!['id'] as int,
          nama: _namaCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          spesialisasi: _spesCtrl.text.trim().isEmpty ? null : _spesCtrl.text.trim(),
          noTelp: _telpCtrl.text.trim().isEmpty ? null : _telpCtrl.text.trim(),
        );
      } else {
        await ApiService.createPsikolog(
          nama: _namaCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          spesialisasi: _spesCtrl.text.trim().isEmpty ? null : _spesCtrl.text.trim(),
          noTelp: _telpCtrl.text.trim().isEmpty ? null : _telpCtrl.text.trim(),
        );
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('INFORMASI PSIKOLOG'),
                      const SizedBox(height: 12),
                      _buildCard([
                        _field(_namaCtrl, 'Nama Lengkap',
                            'Contoh: Dr. Budi Santoso', Icons.person_outline,
                            (v) => v == null || v.trim().isEmpty
                                ? 'Nama wajib diisi'
                                : null),
                        _divider(),
                        _field(_emailCtrl, 'Email', 'nama@contoh.com',
                            Icons.email_outlined, (v) {
                          if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
                            return 'Format email tidak valid';
                          }
                          return null;
                        }, keyboard: TextInputType.emailAddress),
                      ]),
                      const SizedBox(height: 24),
                      _label('DETAIL TAMBAHAN (OPSIONAL)'),
                      const SizedBox(height: 12),
                      _buildCard([
                        _field(_spesCtrl, 'Spesialisasi',
                            'Contoh: Psikologi Klinis',
                            Icons.psychology_outlined, null),
                        _divider(),
                        _field(_telpCtrl, 'No. Telepon', '08xxxxxxxxxx',
                            Icons.phone_outlined, null,
                            keyboard: TextInputType.phone),
                      ]),
                      const SizedBox(height: 32),
                      _buildSubmit(),
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

  Widget _buildHeader(BuildContext ctx) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-0.7, -1), end: Alignment(0.7, 1),
          colors: [AppColors.accentLight, AppColors.accent],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(ctx),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3), shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: AppColors.brand, size: 16),
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
                      color: AppColors.brand.withValues(alpha: 0.6),
                      letterSpacing: 1.2)),
              Text(_isEdit ? 'Edit Psikolog' : 'Tambah Psikolog',
                  style: const TextStyle(
                      fontFamily: 'Manrope', fontSize: 22,
                      fontWeight: FontWeight.w700, color: AppColors.brand)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(text,
            style: TextStyle(
                fontFamily: 'NimbusSans', fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.brand.withValues(alpha: 0.5),
                letterSpacing: 0.8)),
      );

  Widget _buildCard(List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
                color: AppColors.brand.withValues(alpha: 0.05),
                blurRadius: 16, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(children: children),
      );

  Widget _divider() => Divider(
      height: 1, indent: 16, endIndent: 16,
      color: AppColors.brand.withValues(alpha: 0.07));

  Widget _field(TextEditingController c, String label, String hint,
      IconData icon, String? Function(String?)? validator,
      {TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: TextFormField(
        controller: c,
        keyboardType: keyboard,
        validator: validator,
        style: const TextStyle(
            fontFamily: 'NimbusSans', fontSize: 14,
            color: AppColors.brand, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, size: 18, color: AppColors.accent),
          labelStyle: TextStyle(
              fontFamily: 'NimbusSans', fontSize: 13,
              color: AppColors.brand.withValues(alpha: 0.6)),
          hintStyle: TextStyle(
              fontFamily: 'NimbusSans', fontSize: 13,
              color: AppColors.brand.withValues(alpha: 0.3)),
          border: InputBorder.none,
          errorStyle: const TextStyle(fontFamily: 'NimbusSans', fontSize: 11),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildSubmit() {
    return SizedBox(
      width: double.infinity, height: 56,
      child: ElevatedButton(
        onPressed: _saving ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brand,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.brand.withValues(alpha: 0.4),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _saving
            ? const SizedBox(
                width: 22, height: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(_isEdit ? 'Simpan Perubahan' : 'Tambah Psikolog',
                style: const TextStyle(
                    fontFamily: 'NimbusSans', fontSize: 15,
                    fontWeight: FontWeight.w700, letterSpacing: 0.3)),
      ),
    );
  }
}
