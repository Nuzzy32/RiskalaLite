import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  String _category = '';
  bool _showDropdown = false;
  final _descController = TextEditingController();
  double _stressLevel = 3;
  bool _submitted = false;

  final _categories = [
    'Beban Kerja Berlebihan',
    'Konflik dengan Rekan Kerja',
    'Masalah Manajemen',
    'Work-Life Balance',
    'Lingkungan Kerja',
    'Lainnya',
  ];

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    setState(() => _submitted = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _submitted = false);
    });
  }

  void _navigateTo(String id) {
    if (id == 'home') {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (id == 'account') {
      Navigator.pushReplacementNamed(context, '/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F7),
      body: Stack(
        children: [
          Column(
            children: [
              // Header
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pushReplacementNamed(context, '/home'),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF245A72), size: 16),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 40),
                          child: const Text(
                            'Laporan Keluhan',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF245A72),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 160),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subtext
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 40),
                          child: const Text(
                            'Laporan ini bersifat rahasia dan hanya akan\ndibaca oleh tim HR untuk membantu Anda.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              color: Color(0xFF7A8B94),
                              height: 1.625,
                            ),
                          ),
                        ),
                      ),

                      // Category
                      const Text(
                        'Kategori Masalah',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF245A72),
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => setState(() => _showDropdown = !_showDropdown),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(24, 16, 16, 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(9999),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _category.isEmpty ? 'Pilih kategori...' : _category,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    color: _category.isEmpty ? const Color(0xFF475569) : const Color(0xFF1E293B),
                                  ),
                                ),
                              ),
                              Icon(
                                _showDropdown ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                color: const Color(0xFF6B7280),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_showDropdown)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 40,
                                offset: const Offset(0, 10),
                                spreadRadius: -10,
                              ),
                            ],
                          ),
                          child: Column(
                            children: _categories.map((cat) {
                              final isSelected = _category == cat;
                              return GestureDetector(
                                onTap: () => setState(() {
                                  _category = cat;
                                  _showDropdown = false;
                                }),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  color: isSelected ? const Color(0xFF61D1DB).withValues(alpha: 0.05) : Colors.transparent,
                                  child: Text(
                                    cat,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 14,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                      color: isSelected ? const Color(0xFF61D1DB) : const Color(0xFF475569),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                      const SizedBox(height: 32),

                      // Description
                      const Text(
                        'Deskripsi Masalah',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF245A72),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _descController,
                          maxLines: 6,
                          decoration: const InputDecoration(
                            hintText: 'Ceritakan masalah yang Anda alami...',
                            hintStyle: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(24),
                          ),
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Stress Level
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tingkat Stres',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF245A72),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF60D0DC).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: Text(
                              '${_stressLevel.round()}/5',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF60D0DC),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: const Color(0xFF60D0DC),
                          inactiveTrackColor: const Color(0xFFE2E8F0),
                          thumbColor: const Color(0xFF60D0DC),
                          overlayColor: const Color(0xFF60D0DC).withValues(alpha: 0.2),
                        ),
                        child: Slider(
                          value: _stressLevel,
                          min: 1,
                          max: 5,
                          divisions: 4,
                          onChanged: (v) => setState(() => _stressLevel = v),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'RENDAH',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF7A8B94),
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              'TINGGI',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF7A8B94),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Submit
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF60D0DC),
                            foregroundColor: Colors.white,
                            elevation: 4,
                            shadowColor: const Color(0xFF60D0DC).withValues(alpha: 0.3),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                          ),
                          child: Text(
                            _submitted ? 'Terkirim! \u2714' : 'Kirim',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom Nav
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomNav(active: 'report', onTap: _navigateTo),
          ),
        ],
      ),
    );
  }
}
