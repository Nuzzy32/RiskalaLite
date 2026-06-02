import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/bottom_nav.dart';
import '../../services/api_service.dart';

class ReportPage extends StatefulWidget {
  final bool showNav;
  const ReportPage({super.key, this.showNav = true});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  String _category = '';
  int _categoryId = 0;

  bool _showDropdown = false;
  final _descController = TextEditingController();
  double _stressLevel = 3;
  bool _submitted = false;
  bool _submitting = false;
  List<Map<String, dynamic>> _categories = [];
  bool _loadingCategories = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final data = await ApiService.getKategoriLaporan();
      if (!mounted) return;
      setState(() {
        _categories = data;
        _loadingCategories = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _categories = [
          {'id': 1, 'nama_kategori': 'Beban Kerja Berlebihan'},
          {'id': 2, 'nama_kategori': 'Konflik dengan Rekan Kerja'},
          {'id': 3, 'nama_kategori': 'Masalah Manajemen'},
          {'id': 4, 'nama_kategori': 'Work-Life Balance'},
          {'id': 5, 'nama_kategori': 'Lingkungan Kerja'},
          {'id': 6, 'nama_kategori': 'Lainnya'},
        ];
        _loadingCategories = false;
      });
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_category.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori masalah dulu')),
      );
      return;
    }
    if (_descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi deskripsi masalah dulu')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await ApiService.submitReport(
        kategori: _categoryId,
        deskripsi: _descController.text.trim(),
        tingkatStres: _stressLevel.round(),
      );
      if (!mounted) return;
      setState(() {
        _submitted = true;
        _submitting = false;
        _category = '';
        _categoryId = 0;
        _descController.clear();
        _stressLevel = 3;
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _submitted = false);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal: ${e.toString().replaceAll('Exception: ', '')}'),
        ),
      );
    }
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
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () =>
                            Navigator.pushReplacementNamed(context, '/home'),
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
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: AppColors.brand,
                            size: 16,
                          ),
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
                              color: AppColors.brand,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 160),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      const Text(
                        'Kategori Masalah',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.brand,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _loadingCategories
                            ? null
                            : () => setState(
                                () => _showDropdown = !_showDropdown,
                              ),
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
                                  _loadingCategories
                                      ? 'Memuat kategori...'
                                      : (_category.isEmpty
                                            ? 'Pilih kategori...'
                                            : _category),
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    color: _category.isEmpty
                                        ? const Color(0xFF475569)
                                        : const Color(0xFF1E293B),
                                  ),
                                ),
                              ),
                              Icon(
                                _showDropdown
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: const Color(0xFF6B7280),
                              ),
                            ],
                          ),
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOut,
                          ),
                          child: SizeTransition(
                            sizeFactor: CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            ),
                            axisAlignment: -1,
                            child: child,
                          ),
                        ),
                        child: _showDropdown
                            ? Container(
                                key: const ValueKey('dropdown'),
                                margin: const EdgeInsets.only(top: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.12,
                                      ),
                                      blurRadius: 40,
                                      offset: const Offset(0, 10),
                                      spreadRadius: -10,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: _categories.map((cat) {
                                    final nama = cat['nama_kategori'] as String;
                                    final id = cat['id'] as int;
                                    final isSelected = _categoryId == id;
                                    return GestureDetector(
                                      onTap: () => setState(() {
                                        _category = nama;
                                        _categoryId = id;
                                        _showDropdown = false;
                                      }),
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                        color: isSelected
                                            ? AppColors.accent.withValues(
                                                alpha: 0.05,
                                              )
                                            : Colors.transparent,
                                        child: Text(
                                          nama,
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 14,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                            color: isSelected
                                                ? AppColors.accent
                                                : const Color(0xFF475569),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              )
                            : const SizedBox.shrink(key: ValueKey('empty')),
                      ),

                      const SizedBox(height: 32),
                      const Text(
                        'Deskripsi Masalah',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.brand,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tingkat Stres',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.brand,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF60D0DC,
                              ).withValues(alpha: 0.1),
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
                          overlayColor: const Color(
                            0xFF60D0DC,
                          ).withValues(alpha: 0.2),
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
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _submitting ? null : _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF60D0DC),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(
                              0xFF60D0DC,
                            ).withValues(alpha: 0.5),
                            elevation: 4,
                            shadowColor: const Color(
                              0xFF60D0DC,
                            ).withValues(alpha: 0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9999),
                            ),
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: _submitting
                                ? const SizedBox(
                                    key: ValueKey('loading'),
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    key: ValueKey(_submitted ? 'sent' : 'send'),
                                    _submitted ? 'Terkirim! \u2714' : 'Kirim',
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
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
          if (widget.showNav)
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
