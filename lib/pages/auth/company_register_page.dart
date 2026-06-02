import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/api_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Constants
// ─────────────────────────────────────────────────────────────────────────────

const _kBrand = AppColors.brand;
const _kAccent = AppColors.accent;

const _kIndustries = [
  'Teknologi',
  'Manufaktur',
  'Kesehatan',
  'Pendidikan',
  'Keuangan',
  'Ritel',
  'Logistik',
  'Lainnya',
];

const _kEmployeeRanges = ['1–50', '51–200', '201–500', '500+'];

// ─────────────────────────────────────────────────────────────────────────────
// Page
// ─────────────────────────────────────────────────────────────────────────────

class CompanyRegisterPage extends StatefulWidget {
  const CompanyRegisterPage({super.key});

  @override
  State<CompanyRegisterPage> createState() => _CompanyRegisterPageState();
}

class _CompanyRegisterPageState extends State<CompanyRegisterPage>
    with SingleTickerProviderStateMixin {
  int _step = 0; // 0–3 = form steps, 4 = success
  bool _slideForward = true;

  // Step 0 — Company info
  final _companyNameCtrl = TextEditingController();
  final _companyEmailCtrl = TextEditingController();
  String? _industry;

  // Step 1 — Size
  String? _employeeRange;

  // Step 2 — HR account
  final _hrNameCtrl = TextEditingController();
  final _hrNipCtrl = TextEditingController();
  final _hrPassCtrl = TextEditingController();
  final _hrPassConfirmCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  // Step 3 — Review + submit
  bool _submitting = false;
  String? _submitError;

  // Step 4 — Success
  String? _generatedCode;

  // Field errors per step
  String? _step0Error;
  String? _step1Error;
  String? _step2Error;

  @override
  void dispose() {
    _companyNameCtrl.dispose();
    _companyEmailCtrl.dispose();
    _hrNameCtrl.dispose();
    _hrNipCtrl.dispose();
    _hrPassCtrl.dispose();
    _hrPassConfirmCtrl.dispose();
    super.dispose();
  }

  // ── Validation ──────────────────────────────────────────────────────────────

  bool _validateStep0() {
    if (_companyNameCtrl.text.trim().isEmpty) {
      setState(() => _step0Error = 'Nama perusahaan wajib diisi');
      return false;
    }
    if (_companyEmailCtrl.text.trim().isEmpty ||
        !_companyEmailCtrl.text.contains('@')) {
      setState(() => _step0Error = 'Email perusahaan tidak valid');
      return false;
    }
    if (_industry == null) {
      setState(() => _step0Error = 'Pilih industri perusahaan');
      return false;
    }
    setState(() => _step0Error = null);
    return true;
  }

  bool _validateStep1() {
    if (_employeeRange == null) {
      setState(() => _step1Error = 'Pilih jumlah karyawan');
      return false;
    }
    setState(() => _step1Error = null);
    return true;
  }

  bool _validateStep2() {
    if (_hrNameCtrl.text.trim().isEmpty) {
      setState(() => _step2Error = 'Nama HR wajib diisi');
      return false;
    }
    if (_hrNipCtrl.text.trim().isEmpty) {
      setState(() => _step2Error = 'NIP wajib diisi');
      return false;
    }
    if (_hrPassCtrl.text.length < 8) {
      setState(() => _step2Error = 'Kata sandi minimal 8 karakter');
      return false;
    }
    if (_hrPassCtrl.text != _hrPassConfirmCtrl.text) {
      setState(() => _step2Error = 'Konfirmasi kata sandi tidak cocok');
      return false;
    }
    setState(() => _step2Error = null);
    return true;
  }

  // ── Navigation ──────────────────────────────────────────────────────────────

  void _next() {
    switch (_step) {
      case 0:
        if (!_validateStep0()) return;
      case 1:
        if (!_validateStep1()) return;
      case 2:
        if (!_validateStep2()) return;
    }
    setState(() {
      _slideForward = true;
      _step++;
    });
  }

  void _back() {
    if (_step == 0 || _step == 4) {
      Navigator.maybePop(context);
    } else {
      setState(() {
        _slideForward = false;
        _step--;
      });
    }
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _submitError = null;
    });
    try {
      final result = await ApiService.registerCompany(
        companyName: _companyNameCtrl.text.trim(),
        companyEmail: _companyEmailCtrl.text.trim(),
        industry: _industry!,
        employeeRange: _employeeRange!,
        hrName: _hrNameCtrl.text.trim(),
        hrNip: _hrNipCtrl.text.trim(),
        hrPassword: _hrPassCtrl.text,
      );
      if (!mounted) return;
      if (result['success'] == true) {
        setState(() {
          _generatedCode = result['company_code'] as String?;
          _submitting = false;
          _slideForward = true;
          _step = 4;
        });
      } else {
        setState(() {
          _submitError =
              result['message'] as String? ?? 'Pendaftaran gagal. Coba lagi.';
          _submitting = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      setState(() {
        _submitError = msg.isNotEmpty ? msg : 'Tidak dapat terhubung ke server';
        _submitting = false;
      });
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _step == 0 || _step == 4,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4FAFB),
        body: SafeArea(
          child: Column(
            children: [
              if (_step < 4)
                _RegHeader(step: _step, totalSteps: 4, onBack: _back),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_step < 4) ...[
                        const SizedBox(height: 8),
                        _StepDots(step: _step, total: 4),
                        const SizedBox(height: 32),
                      ],
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 320),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, anim) {
                          final isIncoming =
                              child.key == ValueKey(_step);
                          final dir = _slideForward ? 1.0 : -1.0;
                          final begin = isIncoming
                              ? Offset(dir * 0.06, 0)
                              : Offset(-dir * 0.06, 0);
                          return FadeTransition(
                            opacity: anim,
                            child: SlideTransition(
                              position: Tween(
                                begin: begin,
                                end: Offset.zero,
                              ).animate(anim),
                              child: child,
                            ),
                          );
                        },
                        child: _buildStep(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _Step0CompanyInfo(
          key: const ValueKey(0),
          nameCtrl: _companyNameCtrl,
          emailCtrl: _companyEmailCtrl,
          industry: _industry,
          error: _step0Error,
          onIndustryChanged: (v) => setState(() => _industry = v),
          onNext: _next,
        );
      case 1:
        return _Step1Size(
          key: const ValueKey(1),
          selected: _employeeRange,
          error: _step1Error,
          onSelected: (v) => setState(() => _employeeRange = v),
          onNext: _next,
        );
      case 2:
        return _Step2HrAccount(
          key: const ValueKey(2),
          nameCtrl: _hrNameCtrl,
          nipCtrl: _hrNipCtrl,
          passCtrl: _hrPassCtrl,
          passConfirmCtrl: _hrPassConfirmCtrl,
          obscurePass: _obscurePass,
          obscureConfirm: _obscureConfirm,
          error: _step2Error,
          onTogglePass: () => setState(() => _obscurePass = !_obscurePass),
          onToggleConfirm: () =>
              setState(() => _obscureConfirm = !_obscureConfirm),
          onNext: _next,
        );
      case 3:
        return _Step3Review(
          key: const ValueKey(3),
          companyName: _companyNameCtrl.text.trim(),
          companyEmail: _companyEmailCtrl.text.trim(),
          industry: _industry ?? '—',
          employeeRange: _employeeRange ?? '—',
          hrName: _hrNameCtrl.text.trim(),
          hrNip: _hrNipCtrl.text.trim(),
          submitting: _submitting,
          error: _submitError,
          onSubmit: _submit,
        );
      case 4:
        return _Step4Success(
          key: const ValueKey(4),
          companyCode: _generatedCode ?? '—',
          companyName: _companyNameCtrl.text.trim(),
          onDone: () =>
              Navigator.pushNamedAndRemoveUntil(context, '/hr/home', (_) => false),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared widgets
// ─────────────────────────────────────────────────────────────────────────────

class _RegHeader extends StatelessWidget {
  const _RegHeader({
    required this.step,
    required this.totalSteps,
    required this.onBack,
  });
  final int step;
  final int totalSteps;
  final VoidCallback onBack;

  static const _titles = [
    'Info Perusahaan',
    'Ukuran Tim',
    'Akun HR',
    'Konfirmasi',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 24, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: _kBrand,
            onPressed: onBack,
          ),
          const SizedBox(width: 4),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(anim),
                child: child,
              ),
            ),
            child: Text(
              step < _titles.length ? _titles[step] : '',
              key: ValueKey(step),
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _kBrand,
                letterSpacing: -0.3,
              ),
            ),
          ),
          const Spacer(),
          Text(
            '${step + 1} / $totalSteps',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 13,
              color: _kBrand.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepDots extends StatelessWidget {
  const _StepDots({required this.step, required this.total});
  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final active = i == step;
        final done = i < step;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            width: active ? 28 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: done
                  ? _kAccent
                  : active
                      ? _kBrand
                      : _kBrand.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        );
      }),
    );
  }
}

InputDecoration _fieldDecor({
  required String label,
  required IconData icon,
  String? errorText,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(fontFamily: 'Public Sans', color: Color(0xFF5A8A96)),
    errorText: errorText,
    prefixIcon: Icon(icon, color: _kAccent, size: 20),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFDAEEF1), width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: _kAccent, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Colors.red, width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Colors.red, width: 2),
    ),
  );
}

Widget _nextBtn({
  required String label,
  required VoidCallback onPressed,
  bool loading = false,
}) {
  return SizedBox(
    height: 54,
    child: ElevatedButton(
      onPressed: loading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: _kBrand,
        disabledBackgroundColor: _kBrand.withValues(alpha: 0.5),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: loading
            ? const SizedBox(
                key: ValueKey('loading'),
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : Text(
                key: const ValueKey('label'),
                label,
                style: const TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
      ),
    ),
  );
}

Widget _errorBanner(String msg) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.red.shade50,
      borderRadius: BorderRadius.circular(10),
      border: Border.fromBorderSide(BorderSide(color: Colors.red.shade200)),
    ),
    child: Row(
      children: [
        Icon(Icons.error_outline_rounded, color: Colors.red.shade700, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            msg,
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 13,
              color: Colors.red.shade700,
            ),
          ),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 0 — Company Info
// ─────────────────────────────────────────────────────────────────────────────

class _Step0CompanyInfo extends StatelessWidget {
  const _Step0CompanyInfo({
    super.key,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.industry,
    required this.error,
    required this.onIndustryChanged,
    required this.onNext,
  });

  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final String? industry;
  final String? error;
  final ValueChanged<String?> onIndustryChanged;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (error != null) _errorBanner(error!),
        TextField(
          controller: nameCtrl,
          textInputAction: TextInputAction.next,
          style: const TextStyle(fontFamily: 'Public Sans', fontSize: 15, color: _kBrand),
          decoration: _fieldDecor(label: 'Nama Perusahaan', icon: Icons.business_rounded),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: emailCtrl,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          style: const TextStyle(fontFamily: 'Public Sans', fontSize: 15, color: _kBrand),
          decoration: _fieldDecor(label: 'Email Perusahaan', icon: Icons.email_outlined),
        ),
        const SizedBox(height: 20),
        const Text(
          'Industri',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _kBrand,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _kIndustries.map((ind) {
            final selected = industry == ind;
            return GestureDetector(
              onTap: () => onIndustryChanged(ind),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  color: selected ? _kBrand : Colors.white,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.fromBorderSide(BorderSide(
                    color: selected ? _kBrand : const Color(0xFFDAEEF1),
                    width: 1.5,
                  )),
                ),
                child: Text(
                  ind,
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : _kBrand,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 28),
        _nextBtn(label: 'Lanjutkan', onPressed: onNext),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 1 — Team Size
// ─────────────────────────────────────────────────────────────────────────────

class _Step1Size extends StatelessWidget {
  const _Step1Size({
    super.key,
    required this.selected,
    required this.error,
    required this.onSelected,
    required this.onNext,
  });

  final String? selected;
  final String? error;
  final ValueChanged<String?> onSelected;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Berapa jumlah karyawan di perusahaan Anda?',
          style: TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 15,
            color: Color(0xFF5A8A96),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        if (error != null) _errorBanner(error!),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.8,
          children: _kEmployeeRanges.map((range) {
            final sel = selected == range;
            return GestureDetector(
              onTap: () => onSelected(range),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutBack,
                decoration: BoxDecoration(
                  color: sel ? _kBrand : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.fromBorderSide(BorderSide(
                    color: sel ? _kBrand : const Color(0xFFDAEEF1),
                    width: 1.5,
                  )),
                  boxShadow: sel
                      ? [
                          BoxShadow(
                            color: _kBrand.withValues(alpha: 0.18),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      range,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: sel ? Colors.white : _kBrand,
                      ),
                    ),
                    Text(
                      'karyawan',
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 12,
                        color: sel
                            ? Colors.white.withValues(alpha: 0.8)
                            : const Color(0xFF5A8A96),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 28),
        _nextBtn(label: 'Lanjutkan', onPressed: onNext),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 2 — HR Account
// ─────────────────────────────────────────────────────────────────────────────

class _Step2HrAccount extends StatelessWidget {
  const _Step2HrAccount({
    super.key,
    required this.nameCtrl,
    required this.nipCtrl,
    required this.passCtrl,
    required this.passConfirmCtrl,
    required this.obscurePass,
    required this.obscureConfirm,
    required this.error,
    required this.onTogglePass,
    required this.onToggleConfirm,
    required this.onNext,
  });

  final TextEditingController nameCtrl;
  final TextEditingController nipCtrl;
  final TextEditingController passCtrl;
  final TextEditingController passConfirmCtrl;
  final bool obscurePass;
  final bool obscureConfirm;
  final String? error;
  final VoidCallback onTogglePass;
  final VoidCallback onToggleConfirm;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Buat akun HR pertama untuk mengelola data karyawan.',
          style: TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 15,
            color: Color(0xFF5A8A96),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        if (error != null) _errorBanner(error!),
        TextField(
          controller: nameCtrl,
          textInputAction: TextInputAction.next,
          style: const TextStyle(fontFamily: 'Public Sans', fontSize: 15, color: _kBrand),
          decoration: _fieldDecor(label: 'Nama Lengkap HR', icon: Icons.person_outline_rounded),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: nipCtrl,
          textInputAction: TextInputAction.next,
          style: const TextStyle(fontFamily: 'Public Sans', fontSize: 15, color: _kBrand),
          decoration: _fieldDecor(label: 'NIP', icon: Icons.badge_outlined),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: passCtrl,
          obscureText: obscurePass,
          textInputAction: TextInputAction.next,
          style: const TextStyle(fontFamily: 'Public Sans', fontSize: 15, color: _kBrand),
          decoration: _fieldDecor(
            label: 'Kata Sandi',
            icon: Icons.lock_outline_rounded,
            suffixIcon: IconButton(
              icon: Icon(
                obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: const Color(0xFF5A8A96),
                size: 20,
              ),
              onPressed: onTogglePass,
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: passConfirmCtrl,
          obscureText: obscureConfirm,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => onNext(),
          style: const TextStyle(fontFamily: 'Public Sans', fontSize: 15, color: _kBrand),
          decoration: _fieldDecor(
            label: 'Konfirmasi Kata Sandi',
            icon: Icons.lock_outline_rounded,
            suffixIcon: IconButton(
              icon: Icon(
                obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: const Color(0xFF5A8A96),
                size: 20,
              ),
              onPressed: onToggleConfirm,
            ),
          ),
        ),
        const SizedBox(height: 28),
        _nextBtn(label: 'Lanjutkan', onPressed: onNext),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 3 — Review
// ─────────────────────────────────────────────────────────────────────────────

class _Step3Review extends StatelessWidget {
  const _Step3Review({
    super.key,
    required this.companyName,
    required this.companyEmail,
    required this.industry,
    required this.employeeRange,
    required this.hrName,
    required this.hrNip,
    required this.submitting,
    required this.error,
    required this.onSubmit,
  });

  final String companyName;
  final String companyEmail;
  final String industry;
  final String employeeRange;
  final String hrName;
  final String hrNip;
  final bool submitting;
  final String? error;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Periksa kembali data Anda sebelum mendaftar.',
          style: TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 15,
            color: Color(0xFF5A8A96),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        if (error != null) _errorBanner(error!),
        _ReviewCard(
          title: 'Perusahaan',
          icon: Icons.business_rounded,
          rows: [
            ('Nama', companyName),
            ('Email', companyEmail),
            ('Industri', industry),
            ('Karyawan', '$employeeRange orang'),
          ],
        ),
        const SizedBox(height: 12),
        _ReviewCard(
          title: 'Akun HR',
          icon: Icons.manage_accounts_outlined,
          rows: [
            ('Nama', hrName),
            ('NIP', hrNip),
          ],
        ),
        const SizedBox(height: 28),
        _nextBtn(
          label: 'Daftarkan Perusahaan',
          onPressed: onSubmit,
          loading: submitting,
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.title,
    required this.icon,
    required this.rows,
  });
  final String title;
  final IconData icon;
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: const Border.fromBorderSide(
          BorderSide(color: Color(0xFFDAEEF1), width: 1.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _kAccent, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _kBrand,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...rows.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    SizedBox(
                      width: 90,
                      child: Text(
                        r.$1,
                        style: const TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 13,
                          color: Color(0xFF5A8A96),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        r.$2,
                        style: const TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _kBrand,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 4 — Success + Company Code Reveal
// ─────────────────────────────────────────────────────────────────────────────

class _Step4Success extends StatelessWidget {
  const _Step4Success({
    super.key,
    required this.companyCode,
    required this.companyName,
    required this.onDone,
  });

  final String companyCode;
  final String companyName;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnimatedScale(
            scale: 1.0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            child: Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F8F9),
                  shape: BoxShape.circle,
                  border: Border.fromBorderSide(
                    BorderSide(color: _kAccent.withValues(alpha: 0.5), width: 2),
                  ),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: _kBrand,
                  size: 40,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '$companyName\nberhasil didaftarkan!',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _kBrand,
              height: 1.3,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Simpan kode perusahaan di bawah. Karyawan membutuhkannya untuk login.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              color: Color(0xFF5A8A96),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          _CompanyCodeReveal(code: companyCode),
          const SizedBox(height: 32),
          _nextBtn(label: 'Mulai sebagai HR', onPressed: onDone),
        ],
      ),
    );
  }
}

// ── Company Code Reveal ───────────────────────────────────────────────────────

class _CompanyCodeReveal extends StatefulWidget {
  const _CompanyCodeReveal({required this.code});
  final String code;

  @override
  State<_CompanyCodeReveal> createState() => _CompanyCodeRevealState();
}

class _CompanyCodeRevealState extends State<_CompanyCodeReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<Animation<double>> _charAnims;

  @override
  void initState() {
    super.initState();
    final len = widget.code.length;
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400 + len * 80),
    );
    _charAnims = List.generate(len, (i) {
      final start = i / len * 0.6;
      final end = start + 0.4;
      return CurvedAnimation(
        parent: _ctrl,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ctrl.value == 0) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          if (MediaQuery.of(context).disableAnimations) {
            _ctrl.value = 1.0;
          } else {
            _ctrl.forward();
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: _kBrand,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _kBrand.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'KODE PERUSAHAAN',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.code.length, (i) {
              final char = widget.code[i];
              return AnimatedBuilder(
                animation: _charAnims[i],
                builder: (_, c) {
                  final v = _charAnims[i].value;
                  return Opacity(
                    opacity: v,
                    child: Transform.translate(
                      offset: Offset(0, 12 * (1 - v)),
                      child: Container(
                        width: 36,
                        height: 44,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.fromBorderSide(
                            BorderSide(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            char,
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 14,
                color: Colors.white.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 6),
              Text(
                'Bagikan ke karyawan untuk login',
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
