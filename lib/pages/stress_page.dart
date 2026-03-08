import 'package:flutter/material.dart';

class StressPage extends StatefulWidget {
  const StressPage({super.key});

  @override
  State<StressPage> createState() => _StressPageState();
}

class _StressPageState extends State<StressPage> {
  int _currentQ = 0;
  final List<int?> _answers = List.filled(10, null);

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
      setState(() => _currentQ++);
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void _prevQuestion() {
    if (_currentQ > 0) {
      setState(() => _currentQ--);
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
          // Decorative blobs
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
                color: const Color(0xFFB3F3F4).withValues(alpha: 0.3),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _prevQuestion,
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.arrow_back_ios_new, color: Color(0xFF245A72), size: 16),
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Stress Check-in',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF245A72),
                            letterSpacing: -0.45,
                          ),
                        ),
                      ),
                      const SizedBox(width: 32),
                    ],
                  ),
                ),

                // Progress
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
                              color: const Color(0xFF245A72).withValues(alpha: 0.7),
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
                          valueColor: const AlwaysStoppedAnimation(Color(0xFF41C1DD)),
                        ),
                      ),
                    ],
                  ),
                ),

                // Question + options
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Column(
                      children: [
                        // Question text
                        Text(
                          _questions[_currentQ],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF245A72),
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
                            color: const Color(0xFF245A72).withValues(alpha: 0.6),
                            height: 1.43,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Options
                        ...List.generate(_options.length, (i) {
                          final isSelected = _answers[_currentQ] == i;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () => setState(() => _answers[_currentQ] = i),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFFB3F3F4) : Colors.white,
                                  borderRadius: BorderRadius.circular(9999),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFFB3F3F4) : Colors.transparent,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF41C1DD).withValues(alpha: 0.1),
                                      blurRadius: 20,
                                      offset: const Offset(0, 4),
                                      spreadRadius: -2,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _options[i],
                                      style: const TextStyle(
                                        fontFamily: 'Manrope',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF245A72),
                                      ),
                                    ),
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected ? const Color(0xFF245A72) : Colors.transparent,
                                        border: Border.all(
                                          color: isSelected ? const Color(0xFF245A72) : const Color(0xFFE2E8F0),
                                          width: 2,
                                        ),
                                      ),
                                      child: isSelected
                                          ? Center(
                                              child: Container(
                                                width: 8,
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                              ),
                                            )
                                          : null,
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

                // Bottom action
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _answers[_currentQ] != null ? _nextQuestion : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF41C1DD),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFF41C1DD).withValues(alpha: 0.6),
                        disabledForegroundColor: Colors.white.withValues(alpha: 0.6),
                        elevation: 4,
                        shadowColor: const Color(0xFF41C1DD).withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentQ < 9 ? 'Pertanyaan Selanjutnya' : 'Selesai',
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
