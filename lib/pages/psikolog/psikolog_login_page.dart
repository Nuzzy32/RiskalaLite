import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/api_service.dart';

const _kBrand = AppColors.brand;
const _kAccent = AppColors.accent;
const _kAccentLight = AppColors.accentLight;
const _kSubtle = AppColors.subtle;
const _kBg = Color(0xFFF8F9FA);

/// Email + password login for psikologs — a distinct actor from employees,
/// who sign in with company code + NIP.
class PsikologLoginPage extends StatefulWidget {
  const PsikologLoginPage({super.key});

  @override
  State<PsikologLoginPage> createState() => _PsikologLoginPageState();
}

class _PsikologLoginPageState extends State<PsikologLoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  late final AnimationController _enter;
  late final List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _anims = List.generate(4, (i) {
      final s = i * 0.14;
      return CurvedAnimation(
        parent: _enter,
        curve: Interval(s, (s + 0.5).clamp(0.0, 1.0), curve: Curves.easeOutCubic),
      );
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _enter.forward());
  }

  @override
  void dispose() {
    _enter.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Widget _reveal(int i, Widget child) {
    final a = MediaQuery.of(context).disableAnimations
        ? const AlwaysStoppedAnimation<double>(1.0)
        : _anims[i];
    return AnimatedBuilder(
      animation: a,
      builder: (_, c) => Opacity(
        opacity: a.value,
        child: Transform.translate(offset: Offset(0, 14 * (1 - a.value)), child: c),
      ),
      child: child,
    );
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() { _loading = true; _error = null; });
    try {
      await ApiService.psikologLogin(_emailCtrl.text.trim(), _passCtrl.text);
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/psikolog/home', (_) => false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  InputDecoration _decor(String label, IconData icon, {Widget? suffix}) =>
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _reveal(0,
                  Column(children: [
                    Container(
                      width: 84, height: 84,
                      decoration: BoxDecoration(
                        color: _kAccentLight,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _kAccent.withValues(alpha: 0.22),
                            blurRadius: 28, offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.psychology_rounded, size: 40, color: _kBrand),
                    ),
                    const SizedBox(height: 22),
                    const Text('Portal Psikolog',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: _kBrand)),
                    const SizedBox(height: 8),
                    const Text(
                      'Masuk untuk melihat kasus yang ditugaskan kepada Anda.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: _kSubtle, height: 1.5),
                    ),
                  ]),
                ),
                const SizedBox(height: 36),
                _reveal(1,
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    style: const TextStyle(color: _kBrand, fontSize: 15),
                    decoration: _decor('Email', Icons.email_outlined),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Email wajib diisi' : null,
                  ),
                ),
                const SizedBox(height: 16),
                _reveal(2,
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: _obscure,
                    onFieldSubmitted: (_) => _login(),
                    style: const TextStyle(color: _kBrand, fontSize: 15),
                    decoration: _decor('Password', Icons.lock_outline_rounded,
                        suffix: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: _kSubtle, size: 20),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        )),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Password wajib diisi' : null,
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  child: _error != null
                      ? Padding(
                          padding: const EdgeInsets.only(top: 14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF0F0),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFFFCDD2)),
                            ),
                            child: Row(children: [
                              const Icon(Icons.error_outline_rounded, size: 16, color: Color(0xFFE57373)),
                              const SizedBox(width: 8),
                              Expanded(child: Text(_error!,
                                  style: const TextStyle(color: Color(0xFFC62828), fontSize: 13))),
                            ]),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 28),
                _reveal(3,
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kBrand,
                        disabledBackgroundColor: _kBrand.withValues(alpha: 0.45),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
                        elevation: 0,
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: _loading
                            ? const SizedBox(
                                key: ValueKey('s'), width: 22, height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation(Colors.white)),
                              )
                            : const Text('Masuk',
                                key: ValueKey('l'),
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
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
