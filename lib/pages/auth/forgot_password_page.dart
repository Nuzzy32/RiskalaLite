import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/api_service.dart';

const _kBrand = AppColors.brand;
const _kAccent = AppColors.accent;
const _kAccentLight = AppColors.accentLight;
const _kSubtle = AppColors.subtle;
const _kBg = Color(0xFFF8F9FA);

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  bool _sending = false;
  String? _error;

  late final AnimationController _enterCtrl;
  late final List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    _anims = [
      CurvedAnimation(parent: _enterCtrl, curve: const Interval(0.00, 0.60, curve: Curves.easeOutCubic)),
      CurvedAnimation(parent: _enterCtrl, curve: const Interval(0.20, 0.75, curve: Curves.easeOutCubic)),
      CurvedAnimation(parent: _enterCtrl, curve: const Interval(0.40, 0.90, curve: Curves.easeOutCubic)),
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) => _enterCtrl.forward());
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Widget _staggered(int index, Widget child) {
    final reduce = MediaQuery.of(context).disableAnimations;
    final anim = reduce ? const AlwaysStoppedAnimation<double>(1.0) : _anims[index];
    return AnimatedBuilder(
      animation: anim,
      builder: (_, c) => Opacity(
        opacity: anim.value,
        child: Transform.translate(offset: Offset(0, 14 * (1 - anim.value)), child: c),
      ),
      child: child,
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() { _sending = true; _error = null; });
    try {
      await ApiService.requestPasswordResetOtp(_emailCtrl.text.trim());
      if (!mounted) return;
      Navigator.pushNamed(context, '/verify-otp',
          arguments: {'email': _emailCtrl.text.trim()});
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _sending = false;
      });
    }
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
        title: const Text(
          'Pemulihan Akun',
          style: TextStyle(color: _kBrand, fontSize: 17, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Ilustrasi + heading ──────────────────────────────────────
                _staggered(0,
                  Column(children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: _kAccentLight,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _kAccent.withValues(alpha: 0.22),
                            blurRadius: 28,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.lock_reset_rounded, size: 38, color: _kBrand),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Lupa Kata Sandi?',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _kBrand),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Masukkan email terdaftar perusahaan Anda untuk menerima kode verifikasi OTP.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: _kSubtle, height: 1.55),
                    ),
                  ]),
                ),
                const SizedBox(height: 40),

                // ── Email field ──────────────────────────────────────────────
                _staggered(1,
                  Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      style: const TextStyle(color: _kBrand, fontSize: 15),
                      decoration: InputDecoration(
                        labelText: 'Email Perusahaan',
                        labelStyle: const TextStyle(color: _kSubtle, fontSize: 14),
                        prefixIcon: const Icon(Icons.email_outlined, color: _kAccent, size: 20),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: Color(0xFFDAEEF1), width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: Color(0xFFDAEEF1), width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: _kAccent, width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: Color(0xFFE57373), width: 1.5),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: Color(0xFFE57373), width: 2),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
                        final ok = RegExp(r'^[\w.+\-]+@[\w\-]+\.\w{2,}$');
                        if (!ok.hasMatch(v.trim())) return 'Format email tidak valid';
                        return null;
                      },
                    ),

                    // Error banner — animated in/out
                    AnimatedSize(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      child: _error != null
                          ? Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: _ErrorBanner(message: _error!),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ]),
                ),
                const SizedBox(height: 28),

                // ── Kirim button ─────────────────────────────────────────────
                _staggered(2,
                  Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _sending ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kBrand,
                          disabledBackgroundColor: _kBrand.withValues(alpha: 0.45),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
                          elevation: 0,
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: _sending
                              ? const SizedBox(
                                  key: ValueKey('spin'),
                                  width: 22, height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation(Colors.white),
                                  ),
                                )
                              : const Text(
                                  key: ValueKey('lbl'),
                                  'Kirim Kode OTP',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Kembali ke Login',
                          style: TextStyle(color: _kSubtle, fontSize: 14),
                        ),
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Shared error banner ────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFCDD2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(children: [
        const Icon(Icons.error_outline_rounded, size: 16, color: Color(0xFFE57373)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(color: Color(0xFFC62828), fontSize: 13, height: 1.4),
          ),
        ),
      ]),
    );
  }
}
