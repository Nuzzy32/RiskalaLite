import 'package:flutter/material.dart';
import '../services/api_service.dart';

class EmployeeLoginPage extends StatefulWidget {
  const EmployeeLoginPage({super.key});

  @override
  State<EmployeeLoginPage> createState() => _EmployeeLoginPageState();
}

class _EmployeeLoginPageState extends State<EmployeeLoginPage>
    with SingleTickerProviderStateMixin {
  int _step = 0; // 0 = company code, 1 = credentials
  bool _slideForward = true;

  final _codeCtrl = TextEditingController();
  final _nipCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _validating = false;
  bool _loggingIn = false;
  bool _obscurePass = true;

  String? _companyName;
  bool _showBadge = false;

  String? _codeError;
  String? _loginError;

  late final AnimationController _enterCtrl;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_enterCtrl.value == 0) {
      if (MediaQuery.of(context).disableAnimations) {
        _enterCtrl.value = 1.0;
      } else {
        _enterCtrl.forward();
      }
    }
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _codeCtrl.dispose();
    _nipCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _validateCode() async {
    final code = _codeCtrl.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _codeError = 'Masukkan kode perusahaan');
      return;
    }
    setState(() {
      _validating = true;
      _codeError = null;
    });
    try {
      final result = await ApiService.validateCompanyCode(code);
      if (!mounted) return;
      if (result['valid'] == true) {
        setState(() {
          _companyName = result['company_name'] as String?;
          _showBadge = true;
          _validating = false;
        });
        await Future.delayed(const Duration(milliseconds: 420));
        if (!mounted) return;
        setState(() {
          _slideForward = true;
          _step = 1;
        });
      } else {
        setState(() {
          _codeError = result['message'] as String? ?? 'Kode tidak ditemukan';
          _validating = false;
          _showBadge = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      setState(() {
        _codeError = msg.isNotEmpty ? msg : 'Tidak dapat terhubung ke server';
        _validating = false;
      });
    }
  }

  Future<void> _login() async {
    final nip = _nipCtrl.text.trim();
    final pass = _passCtrl.text;
    if (nip.isEmpty || pass.isEmpty) {
      setState(() => _loginError = 'Lengkapi NIP dan kata sandi');
      return;
    }
    setState(() {
      _loggingIn = true;
      _loginError = null;
    });
    try {
      final code = _codeCtrl.text.trim().toUpperCase();
      await ApiService.login(nip, pass, companyCode: code);
      if (!mounted) return;
      final route = ApiService.isHr ? '/hr/home' : '/home';
      Navigator.pushNamedAndRemoveUntil(context, route, (_) => false);
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      setState(() {
        _loginError = msg.isNotEmpty ? msg : 'Tidak dapat terhubung ke server';
        _loggingIn = false;
      });
    }
  }

  void _back() {
    if (_step == 1) {
      setState(() {
        _slideForward = false;
        _step = 0;
        _loginError = null;
        _showBadge = false;
      });
    } else {
      Navigator.maybePop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _step == 1) _back();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4FAFB),
        body: SafeArea(
          child: Column(
            children: [
              _Header(step: _step, onBack: _back),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      _StepPills(step: _step),
                      const SizedBox(height: 32),
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
                        child: _step == 0
                            ? _CodeStep(
                                key: const ValueKey(0),
                                controller: _codeCtrl,
                                error: _codeError,
                                validating: _validating,
                                companyName: _companyName,
                                showBadge: _showBadge,
                                onSubmit: _validateCode,
                              )
                            : _CredentialsStep(
                                key: const ValueKey(1),
                                nipController: _nipCtrl,
                                passController: _passCtrl,
                                companyName: _companyName,
                                error: _loginError,
                                loggingIn: _loggingIn,
                                obscurePass: _obscurePass,
                                onToggleObscure: () => setState(
                                    () => _obscurePass = !_obscurePass),
                                onSubmit: _login,
                              ),
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
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.step, required this.onBack});
  final int step;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 24, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: const Color(0xFF245A72),
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
              step == 0 ? 'Kode Perusahaan' : 'Masuk Akun',
              key: ValueKey(step),
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF245A72),
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Morphing step pills ───────────────────────────────────────────────────────

class _StepPills extends StatelessWidget {
  const _StepPills({required this.step});
  final int step;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(2, (i) {
        final active = i == step;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            width: active ? 28 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: active
                  ? const Color(0xFF245A72)
                  : const Color(0xFF245A72).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        );
      }),
    );
  }
}

// ── Step 0: Company Code ──────────────────────────────────────────────────────

class _CodeStep extends StatelessWidget {
  const _CodeStep({
    super.key,
    required this.controller,
    required this.error,
    required this.validating,
    required this.companyName,
    required this.showBadge,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final String? error;
  final bool validating;
  final String? companyName;
  final bool showBadge;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Masukkan kode unik perusahaan Anda untuk melanjutkan.',
          style: TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 15,
            color: Color(0xFF5A8A96),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 28),
        TextField(
          controller: controller,
          textCapitalization: TextCapitalization.characters,
          textInputAction: TextInputAction.go,
          onSubmitted: (_) => onSubmit(),
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: 4,
            color: Color(0xFF245A72),
          ),
          decoration: InputDecoration(
            labelText: 'Kode Perusahaan',
            labelStyle: const TextStyle(
              fontFamily: 'Public Sans',
              color: Color(0xFF5A8A96),
            ),
            errorText: error,
            prefixIcon: const Icon(
              Icons.apartment_rounded,
              color: Color(0xFF61D1DB),
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFFDAEEF1),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF61D1DB),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: validating ? null : onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF245A72),
              disabledBackgroundColor: const Color(0xFF245A72).withValues(alpha: 0.5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: validating
                  ? const SizedBox(
                      key: ValueKey('loading'),
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor:
                            AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Text(
                      key: ValueKey('label'),
                      'Lanjutkan',
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Step 1: Credentials ───────────────────────────────────────────────────────

class _CredentialsStep extends StatelessWidget {
  const _CredentialsStep({
    super.key,
    required this.nipController,
    required this.passController,
    required this.companyName,
    required this.error,
    required this.loggingIn,
    required this.obscurePass,
    required this.onToggleObscure,
    required this.onSubmit,
  });

  final TextEditingController nipController;
  final TextEditingController passController;
  final String? companyName;
  final String? error;
  final bool loggingIn;
  final bool obscurePass;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Company badge
        AnimatedScale(
          scale: companyName != null ? 1.0 : 0.85,
          duration: const Duration(milliseconds: 400),
          curve: Curves.elasticOut,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F8F9),
              borderRadius: BorderRadius.circular(12),
              border: const Border.fromBorderSide(
                BorderSide(color: Color(0xFFB3EBF0), width: 1.5),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.verified_rounded,
                  color: Color(0xFF245A72),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Perusahaan terverifikasi',
                        style: TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 11,
                          color: Color(0xFF5A8A96),
                        ),
                      ),
                      Text(
                        companyName ?? '—',
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF245A72),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: nipController,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          style: const TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 15,
            color: Color(0xFF245A72),
          ),
          decoration: _inputDecor(
            label: 'NIP',
            icon: Icons.badge_outlined,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: passController,
          obscureText: obscurePass,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => onSubmit(),
          style: const TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 15,
            color: Color(0xFF245A72),
          ),
          decoration: _inputDecor(
            label: 'Kata Sandi',
            icon: Icons.lock_outline_rounded,
          ).copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                obscurePass
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xFF5A8A96),
                size: 20,
              ),
              onPressed: onToggleObscure,
            ),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.fromBorderSide(
                BorderSide(color: Colors.red.shade200),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline_rounded,
                    color: Colors.red.shade700, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    error!,
                    style: TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 13,
                      color: Colors.red.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Navigator.pushNamed(
              context,
              '/forgot-password',
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Lupa Kata Sandi?',
              style: TextStyle(
                color: Color(0xFF61D1DB),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: loggingIn ? null : onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF245A72),
              disabledBackgroundColor:
                  const Color(0xFF245A72).withValues(alpha: 0.5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: loggingIn
                  ? const SizedBox(
                      key: ValueKey('loading'),
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Text(
                      key: ValueKey('label'),
                      'Masuk',
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecor({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        fontFamily: 'Public Sans',
        color: Color(0xFF5A8A96),
      ),
      prefixIcon: Icon(icon, color: const Color(0xFF61D1DB), size: 20),
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
        borderSide: const BorderSide(color: Color(0xFF61D1DB), width: 2),
      ),
    );
  }
}
