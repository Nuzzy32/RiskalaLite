import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';

const _kBrand = Color(0xFF245A72);
const _kAccent = Color(0xFF61D1DB);
const _kAccentLight = Color(0xFFB3F3F4);
const _kSubtle = Color(0xFF568B8F);
const _kBg = Color(0xFFF8F9FA);
const _kOtpLen = 6;

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({super.key});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage>
    with SingleTickerProviderStateMixin {
  late String _email;
  bool _argsLoaded = false;

  final _controllers = List.generate(_kOtpLen, (_) => TextEditingController());
  final _focuses = List.generate(_kOtpLen, (_) => FocusNode());
  int _focusedIdx = 0;

  bool _verifying = false;
  bool _resending = false;
  String? _error;
  bool _pendingAutoVerify = false;

  int _secondsLeft = 60;
  Timer? _timer;
  bool _canResend = false;

  late final AnimationController _enterCtrl;
  late final List<Animation<double>> _headerAnim;
  late final List<Animation<double>> _boxAnims;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _headerAnim = [
      CurvedAnimation(parent: _enterCtrl, curve: const Interval(0.00, 0.55, curve: Curves.easeOutCubic)),
      CurvedAnimation(parent: _enterCtrl, curve: const Interval(0.15, 0.65, curve: Curves.easeOutCubic)),
    ];
    // Each OTP box staggers in 50ms apart
    _boxAnims = List.generate(_kOtpLen, (i) {
      final s = 0.28 + i * 0.055;
      return CurvedAnimation(
        parent: _enterCtrl,
        curve: Interval(s, (s + 0.38).clamp(0.0, 1.0), curve: Curves.easeOutCubic),
      );
    });

    for (int i = 0; i < _kOtpLen; i++) {
      final idx = i;
      _focuses[idx].addListener(() {
        if (mounted) setState(() => _focusedIdx = idx);
      });
      // Backspace on empty → jump to previous box
      _focuses[idx].onKeyEvent = (_, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace &&
            _controllers[idx].text.isEmpty &&
            idx > 0) {
          _focuses[idx - 1].requestFocus();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      };
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _enterCtrl.forward();
      _startCountdown();
      _focuses[0].requestFocus();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_argsLoaded) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _email = args?['email'] as String? ?? '';
      _argsLoaded = true;
    }
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _timer?.cancel();
    for (final c in _controllers) { c.dispose(); }
    for (final f in _focuses) { f.dispose(); }
    super.dispose();
  }

  void _startCountdown() {
    _secondsLeft = 60;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          _canResend = true;
          t.cancel();
        }
      });
    });
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  void _onChanged(String value, int index) {
    // Paste: distribute across boxes
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < digits.length && i + index < _kOtpLen; i++) {
        _controllers[index + i].text = digits[i];
      }
      final next = (index + digits.length).clamp(0, _kOtpLen - 1);
      _focuses[next].requestFocus();
      setState(() {});
      _scheduleAutoVerify();
      return;
    }

    setState(() {});
    if (value.isNotEmpty && index < _kOtpLen - 1) {
      _focuses[index + 1].requestFocus();
    }
    _scheduleAutoVerify();
  }

  void _scheduleAutoVerify() {
    if (_otpCode.length == _kOtpLen && !_pendingAutoVerify && !_verifying) {
      _pendingAutoVerify = true;
      // Small delay so the last digit renders before we start the API call
      Future.delayed(const Duration(milliseconds: 280), () {
        if (mounted && _otpCode.length == _kOtpLen) _verify();
      });
    }
  }

  Future<void> _verify() async {
    if (_otpCode.length < _kOtpLen) {
      setState(() => _error = 'Masukkan semua $_kOtpLen digit kode OTP');
      return;
    }
    setState(() { _verifying = true; _error = null; });
    try {
      final result = await ApiService.verifyResetOtp(_email, _otpCode);
      if (!mounted) return;
      final token = result['token'] as String? ?? _otpCode;
      Navigator.pushNamed(context, '/reset-password',
          arguments: {'email': _email, 'token': token});
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _verifying = false;
        _pendingAutoVerify = false;
      });
    }
  }

  Future<void> _resend() async {
    if (!_canResend || _resending) return;
    setState(() { _resending = true; _error = null; });
    for (final c in _controllers) { c.clear(); }
    _pendingAutoVerify = false;
    setState(() {});
    _focuses[0].requestFocus();
    try {
      await ApiService.requestPasswordResetOtp(_email);
      if (!mounted) return;
      setState(() => _resending = false);
      _startCountdown();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _resending = false;
        _canResend = true;
      });
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  Widget _staggered(Animation<double> anim, Widget child) {
    final reduce = MediaQuery.of(context).disableAnimations;
    final a = reduce ? const AlwaysStoppedAnimation<double>(1.0) : anim;
    return AnimatedBuilder(
      animation: a,
      builder: (_, c) => Opacity(
        opacity: a.value,
        child: Transform.translate(offset: Offset(0, 14 * (1 - a.value)), child: c),
      ),
      child: child,
    );
  }

  Widget _buildBox(int index) {
    final reduce = MediaQuery.of(context).disableAnimations;
    final boxAnim = reduce
        ? const AlwaysStoppedAnimation<double>(1.0)
        : _boxAnims[index];

    return AnimatedBuilder(
      animation: boxAnim,
      builder: (_, unused) {
        final t = boxAnim.value;
        final isFocused = _focusedIdx == index && _focuses[index].hasFocus;
        final isFilled = _controllers[index].text.isNotEmpty;

        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - t)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              width: 46,
              height: 54,
              decoration: BoxDecoration(
                color: isFilled ? const Color(0xFFE8FBFC) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isFocused
                      ? _kAccent
                      : isFilled
                          ? _kAccent.withValues(alpha: 0.45)
                          : const Color(0xFFDAEEF1),
                  width: isFocused ? 2.0 : 1.5,
                ),
                boxShadow: [
                  isFocused
                      ? BoxShadow(
                          color: _kAccent.withValues(alpha: 0.20),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        )
                      : BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                ],
              ),
              child: TextField(
                controller: _controllers[index],
                focusNode: _focuses[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 1,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: _kBrand,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  counterText: '',
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (v) => _onChanged(v, index),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final maskedEmail = _maskEmail(_email);

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
          'Verifikasi OTP',
          style: TextStyle(color: _kBrand, fontSize: 17, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header ───────────────────────────────────────────────────
              _staggered(_headerAnim[0],
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
                    child: const Icon(Icons.mark_email_read_outlined, size: 36, color: _kBrand),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Masukkan Kode OTP',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _kBrand),
                  ),
                  const SizedBox(height: 10),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(fontSize: 14, color: _kSubtle, height: 1.55),
                      children: [
                        const TextSpan(text: 'Kode 6 digit telah dikirim ke\n'),
                        TextSpan(
                          text: maskedEmail,
                          style: const TextStyle(
                            color: _kBrand,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 40),

              // ── OTP boxes ────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_kOtpLen, _buildBox),
              ),

              // ── Error ────────────────────────────────────────────────────
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
              const SizedBox(height: 32),

              // ── Verifikasi button ─────────────────────────────────────────
              _staggered(_headerAnim[1],
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: (_verifying || _otpCode.length < _kOtpLen) ? null : _verify,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kBrand,
                      disabledBackgroundColor: _kBrand.withValues(alpha: 0.45),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
                      elevation: 0,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: _verifying
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
                              'Verifikasi',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Countdown / Resend ────────────────────────────────────────
              Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween(begin: const Offset(0, 0.25), end: Offset.zero).animate(anim),
                      child: child,
                    ),
                  ),
                  child: _canResend
                      ? _resending
                          ? const SizedBox(
                              key: ValueKey('resending'),
                              width: 18, height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(_kAccent),
                              ),
                            )
                          : TextButton(
                              key: const ValueKey('resend'),
                              onPressed: _resend,
                              child: const Text(
                                'Kirim ulang kode',
                                style: TextStyle(
                                  color: _kAccent,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                      : Text(
                          key: ValueKey(_secondsLeft),
                          'Kirim ulang kode dalam ${_secondsLeft}s',
                          style: const TextStyle(color: _kSubtle, fontSize: 14),
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

// ── Helpers ────────────────────────────────────────────────────────────────────

String _maskEmail(String email) {
  final parts = email.split('@');
  if (parts.length != 2) return email;
  final name = parts[0];
  final domain = parts[1];
  if (name.length <= 2) return '${name[0]}***@$domain';
  return '${name[0]}${'*' * (name.length - 2)}${name[name.length - 1]}@$domain';
}

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
