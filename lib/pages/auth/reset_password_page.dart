import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/api_service.dart';

const _kBrand = AppColors.brand;
const _kAccent = AppColors.accent;
const _kAccentLight = AppColors.accentLight;
const _kSubtle = AppColors.subtle;
const _kBg = Color(0xFFF8F9FA);

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _saving = false;
  String? _error;

  late String _email;
  late String _token;
  bool _argsLoaded = false;

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
      CurvedAnimation(parent: _enterCtrl, curve: const Interval(0.00, 0.58, curve: Curves.easeOutCubic)),
      CurvedAnimation(parent: _enterCtrl, curve: const Interval(0.18, 0.72, curve: Curves.easeOutCubic)),
      CurvedAnimation(parent: _enterCtrl, curve: const Interval(0.34, 0.85, curve: Curves.easeOutCubic)),
      CurvedAnimation(parent: _enterCtrl, curve: const Interval(0.48, 0.96, curve: Curves.easeOutCubic)),
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) => _enterCtrl.forward());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_argsLoaded) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _email = args?['email'] as String? ?? '';
      _token = args?['token'] as String? ?? '';
      _argsLoaded = true;
    }
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Widget _staggered(int i, Widget child) {
    final reduce = MediaQuery.of(context).disableAnimations;
    final anim = reduce ? const AlwaysStoppedAnimation<double>(1.0) : _anims[i];
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
    setState(() { _saving = true; _error = null; });
    try {
      await ApiService.resetPassword(_email, _token, _newCtrl.text);
      if (!mounted) return;
      _showSuccessSheet();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _saving = false;
      });
    }
  }

  void _showSuccessSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _SuccessSheet(
        onDone: () {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/entry/employee',
            (route) => false,
          );
        },
      ),
    );
  }

  InputDecoration _inputDecor({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) =>
      InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _kSubtle, fontSize: 14),
        prefixIcon: Icon(icon, color: _kAccent, size: 20),
        suffixIcon: suffix,
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
      );

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
          'Kata Sandi Baru',
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
                // ── Header ───────────────────────────────────────────────
                _staggered(0,
                  Column(children: [
                    Container(
                      width: 84, height: 84,
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
                      child: const Icon(Icons.lock_open_rounded, size: 36, color: _kBrand),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Buat Kata Sandi Baru',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _kBrand),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Kata sandi harus minimal 6 karakter dan mudah Anda ingat.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: _kSubtle, height: 1.55),
                    ),
                  ]),
                ),
                const SizedBox(height: 40),

                // ── Kata Sandi Baru ────────────────────────────────────────
                _staggered(1,
                  TextFormField(
                    controller: _newCtrl,
                    obscureText: _obscureNew,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(color: _kBrand, fontSize: 15),
                    decoration: _inputDecor(
                      label: 'Kata Sandi Baru',
                      icon: Icons.lock_outline_rounded,
                      suffix: IconButton(
                        icon: Icon(
                          _obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: _kSubtle, size: 20,
                        ),
                        onPressed: () => setState(() => _obscureNew = !_obscureNew),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Kata sandi wajib diisi';
                      if (v.length < 6) return 'Minimal 6 karakter';
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // ── Konfirmasi ────────────────────────────────────────────
                _staggered(2,
                  TextFormField(
                    controller: _confirmCtrl,
                    obscureText: _obscureConfirm,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    style: const TextStyle(color: _kBrand, fontSize: 15),
                    decoration: _inputDecor(
                      label: 'Konfirmasi Kata Sandi Baru',
                      icon: Icons.lock_outline_rounded,
                      suffix: IconButton(
                        icon: Icon(
                          _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: _kSubtle, size: 20,
                        ),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Konfirmasi kata sandi wajib diisi';
                      if (v != _newCtrl.text) return 'Kata sandi tidak cocok';
                      return null;
                    },
                  ),
                ),

                // ── Error banner ──────────────────────────────────────────
                AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  child: _error != null
                      ? Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: _ErrorBanner(message: _error!),
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 28),

                // ── Submit button ─────────────────────────────────────────
                _staggered(3,
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kBrand,
                        disabledBackgroundColor: _kBrand.withValues(alpha: 0.45),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
                        elevation: 0,
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: _saving
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
                                'Perbarui Kata Sandi',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Success Bottom Sheet ───────────────────────────────────────────────────────

class _SuccessSheet extends StatefulWidget {
  final VoidCallback onDone;
  const _SuccessSheet({required this.onDone});

  @override
  State<_SuccessSheet> createState() => _SuccessSheetState();
}

class _SuccessSheetState extends State<_SuccessSheet>
    with TickerProviderStateMixin {
  late final AnimationController _slideCtrl;
  late final AnimationController _iconCtrl;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));
    _iconCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 520));

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _slideCtrl.forward();
      await Future.delayed(const Duration(milliseconds: 180));
      if (mounted) _iconCtrl.forward();
    });
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    _iconCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.of(context).disableAnimations;

    return AnimatedBuilder(
      animation: _slideCtrl,
      builder: (_, child) {
        final t = reduce
            ? 1.0
            : CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic).value;
        return Opacity(
          opacity: t,
          child: Transform.translate(offset: Offset(0, 40 * (1 - t)), child: child),
        );
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(28, 20, 28,
            28 + MediaQuery.of(context).viewInsets.bottom),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 32,
              offset: Offset(0, -8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag pill
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDAEEF1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 32),

            // Spring checkmark icon — Jhey-style delighter for this one moment
            AnimatedBuilder(
              animation: _iconCtrl,
              builder: (_, unused) {
                final scale = reduce
                    ? 1.0
                    : CurvedAnimation(parent: _iconCtrl, curve: Curves.elasticOut).value;
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 76, height: 76,
                    decoration: BoxDecoration(
                      color: _kAccentLight,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _kAccent.withValues(alpha: 0.28),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.check_rounded, size: 38, color: _kBrand),
                  ),
                );
              },
            ),
            const SizedBox(height: 22),

            const Text(
              'Kata Sandi Berhasil Diperbarui',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _kBrand),
            ),
            const SizedBox(height: 10),
            const Text(
              'Silakan masuk kembali menggunakan kata sandi baru Anda.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: _kSubtle, height: 1.55),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: widget.onDone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kBrand,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
                  elevation: 0,
                ),
                child: const Text(
                  'Masuk Sekarang',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error banner ───────────────────────────────────────────────────────────────

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
            blurRadius: 8, offset: const Offset(0, 2),
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
