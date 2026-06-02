import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/api_service.dart';
import '../../widgets/sos_button.dart';
import 'stress_result_page.dart';

class StressPage extends StatefulWidget {
  const StressPage({super.key});

  @override
  State<StressPage> createState() => _StressPageState();
}

class _StressPageState extends State<StressPage> {
  int _currentQ = 0;
  bool _slideForward = true;
  final List<int?> _answers = List.filled(10, null);
  bool _submitting = false;

  final _questions = [
    'Saya merasa kewalahan dengan beban kerja saya',
    'Saya merasa cemas tentang tenggat waktu',
    'Saya kesulitan berkonsentrasi pada pekerjaan',
    'Saya merasa kurang didukung oleh tim',
    'Saya mengalami gangguan tidur karena stres kerja',
    'Saya merasa sulit menyeimbangkan kerja dan kehidupan pribadi',
    'Saya merasa tidak dihargai atas usaha saya',
    'Saya mengalami gejala fisik akibat stres',
    'Saya merasa tidak puas dengan lingkungan kerja',
    'Saya merasa produktivitas saya menurun',
  ];

  final _options = [
    'Sangat tidak setuju',
    'Tidak setuju',
    'Netral',
    'Setuju',
    'Sangat Setuju',
  ];

  void _nextQuestion() {
    if (_currentQ < 9) {
      setState(() {
        _slideForward = true;
        _currentQ++;
      });
    } else {
      _submitAndFinish();
    }
  }

  Future<void> _submitAndFinish() async {
    final riskScore = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => const _RiskScreenSheet(),
    );
    if (riskScore == null || !mounted) return;

    setState(() => _submitting = true);
    final totalScore = _answers.fold<int>(0, (sum, a) => sum + (a ?? 0));
    try {
      await ApiService.submitAssessment(
        totalScore: totalScore,
        riskScore: riskScore,
      );
    } catch (_) {}
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            StressResultPage(score: totalScore, riskFlagged: riskScore >= 1),
      ),
    );
  }

  void _prevQuestion() {
    if (_currentQ > 0) {
      setState(() {
        _slideForward = false;
        _currentQ--;
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentQ + 1) / 10;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFC),
      body: Stack(
        children: [
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF41C1DD).withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentLight.withValues(alpha: 0.3),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _prevQuestion,
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            color: AppColors.brand,
                            size: 16,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Work-Stress Check-in',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.brand,
                            letterSpacing: -0.45,
                          ),
                        ),
                      ),
                      const SosIconButton(size: 36),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Question ${_currentQ + 1} of 10',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(
                                0xFF245A72,
                              ).withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(9999),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: const Color(0xFFE2E8F0),
                          valueColor: const AlwaysStoppedAnimation(
                            Color(0xFF41C1DD),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 320),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) {
                        final direction = _slideForward ? 0.04 : -0.04;
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position:
                                Tween<Offset>(
                                  begin: Offset(direction, 0),
                                  end: Offset.zero,
                                ).animate(
                                  CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOutCubic,
                                  ),
                                ),
                            child: child,
                          ),
                        );
                      },
                      child: Column(
                        key: ValueKey(_currentQ),
                        children: [
                          Text(
                            _questions[_currentQ],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              color: AppColors.brand,
                              letterSpacing: -0.75,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Pilih opsi yang paling menggambarkan 2 minggu terakhir Anda.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(
                                0xFF245A72,
                              ).withValues(alpha: 0.6),
                              height: 1.43,
                            ),
                          ),
                          const SizedBox(height: 32),

                          ...List.generate(_options.length, (i) {
                            final isSelected = _answers[_currentQ] == i;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _answers[_currentQ] = i),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeOutBack,
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 17,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.accentLight
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(9999),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.accentLight
                                          : Colors.transparent,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF41C1DD,
                                        ).withValues(alpha: 0.1),
                                        blurRadius: 20,
                                        offset: const Offset(0, 4),
                                        spreadRadius: -2,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _options[i],
                                          style: const TextStyle(
                                            fontFamily: 'Manrope',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.brand,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        curve: Curves.easeOutBack,
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isSelected
                                              ? AppColors.brand
                                              : Colors.transparent,
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors.brand
                                                : const Color(0xFFE2E8F0),
                                            width: 2,
                                          ),
                                        ),
                                        child: Center(
                                          child: AnimatedScale(
                                            scale: isSelected ? 1.0 : 0.0,
                                            duration: const Duration(
                                              milliseconds: 250,
                                            ),
                                            curve: Curves.elasticOut,
                                            child: Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: (_answers[_currentQ] != null && !_submitting)
                          ? _nextQuestion
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF41C1DD),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(
                          0xFF41C1DD,
                        ).withValues(alpha: 0.6),
                        disabledForegroundColor: Colors.white.withValues(
                          alpha: 0.6,
                        ),
                        elevation: 4,
                        shadowColor: const Color(
                          0xFF41C1DD,
                        ).withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9999),
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: _submitting
                              ? const SizedBox(
                                  key: ValueKey('loading'),
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Row(
                                  key: ValueKey(
                                    _currentQ < 9 ? 'next' : 'done',
                                  ),
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _currentQ < 9
                                          ? 'Pertanyaan Selanjutnya'
                                          : 'Selesai',
                                      style: const TextStyle(
                                        fontFamily: 'Manrope',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.45,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.arrow_forward, size: 16),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RiskScreenSheet extends StatefulWidget {
  const _RiskScreenSheet();

  @override
  State<_RiskScreenSheet> createState() => _RiskScreenSheetState();
}

class _RiskScreenSheetState extends State<_RiskScreenSheet> {
  int? _selected;

  static const _options = [
    'Tidak pernah',
    'Beberapa hari',
    'Lebih dari separuh hari',
    'Hampir setiap hari',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.brand.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Satu pertanyaan terakhir',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.brand,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Dalam 2 minggu terakhir, seberapa sering kamu terganggu oleh pikiran bahwa kamu lebih baik tiada, atau ingin menyakiti diri sendiri?',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 14.5,
              height: 1.5,
              color: const Color(0xFF0F191A).withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Jawabanmu hanya dilihat oleh psikolog, tidak oleh HR.',
            style: TextStyle(
              fontFamily: 'NimbusSans',
              fontSize: 12,
              color: AppColors.subtle.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 18),
          ...List.generate(_options.length, (i) {
            final selected = _selected == i;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => setState(() => _selected = i),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.accentLight.withValues(alpha: 0.4)
                        : const Color(0xFFFBFDFD),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected
                          ? AppColors.accent
                          : const Color(0xFFEAF0F1),
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        selected
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        size: 20,
                        color: selected
                            ? AppColors.accentDeep
                            : AppColors.subtle,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _options[i],
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: AppColors.brand,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _selected == null
                  ? null
                  : () => Navigator.pop(context, _selected),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brand,
                disabledBackgroundColor: AppColors.brand.withValues(alpha: 0.4),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              child: const Text(
                'Selesai',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
