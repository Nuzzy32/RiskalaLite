import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/self_help_content.dart';
import '../../data/crisis_resources.dart';
import '../../widgets/crisis_sheet.dart';
import '../../widgets/sos_button.dart';

class StressResultPage extends StatefulWidget {
  final int score;
  final bool riskFlagged;

  const StressResultPage({
    super.key,
    required this.score,
    this.riskFlagged = false,
  });

  @override
  State<StressResultPage> createState() => _StressResultPageState();
}

class _StressResultPageState extends State<StressResultPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter;
  late final StressGuidance _g;

  @override
  void initState() {
    super.initState();
    _g = guidanceForScore(widget.score);
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _enter.forward());
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  bool get _reduce => MediaQuery.of(context).disableAnimations;

  Widget _reveal(double start, double end, Widget child) {
    final anim = _reduce
        ? const AlwaysStoppedAnimation<double>(1.0)
        : CurvedAnimation(
            parent: _enter,
            curve: Interval(start, end, curve: Curves.easeOutCubic),
          );
    return AnimatedBuilder(
      animation: anim,
      builder: (_, c) => Opacity(
        opacity: anim.value,
        child: Transform.translate(
          offset: Offset(0, 16 * (1 - anim.value)),
          child: c,
        ),
      ),
      child: child,
    );
  }

  void _finish() {
    Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFC),
      body: Stack(
        children: [
          Positioned(
            top: -60,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _g.color.withValues(alpha: 0.10),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentLight.withValues(alpha: 0.25),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Align(
                          alignment: Alignment.centerRight,
                          child: SosIconButton(),
                        ),
                        const SizedBox(height: 12),
                        if (widget.riskFlagged) ...[
                          _reveal(0.0, 0.45, _buildCrisisCard()),
                          const SizedBox(height: 16),
                        ],
                        _reveal(0.0, 0.5, _buildScoreHero()),
                        if (!widget.riskFlagged && _g.category == 3) ...[
                          const SizedBox(height: 16),
                          _reveal(0.15, 0.6, _buildCrisisCard()),
                        ],
                        const SizedBox(height: 28),
                        _reveal(0.25, 0.7, _buildRecommendationsHeader()),
                        const SizedBox(height: 14),
                        ...List.generate(_g.tips.length, (i) {
                          final start = (0.35 + i * 0.10).clamp(0.0, 0.85);
                          final end = (start + 0.25).clamp(0.0, 1.0);
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: i == _g.tips.length - 1 ? 0 : 12,
                            ),
                            child: _reveal(
                              start,
                              end,
                              _TipCard(tip: _g.tips[i], accent: _g.color),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                _reveal(0.6, 1.0, _buildDoneButton()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: _g.color.withValues(alpha: 0.12),
            blurRadius: 28,
            offset: const Offset(0, 12),
            spreadRadius: -6,
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            width: 132,
            height: 132,
            child: Stack(
              alignment: Alignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: widget.score / 40),
                  duration: _reduce
                      ? Duration.zero
                      : const Duration(milliseconds: 1100),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, child) => SizedBox(
                    width: 132,
                    height: 132,
                    child: CircularProgressIndicator(
                      value: v,
                      strokeWidth: 11,
                      strokeCap: StrokeCap.round,
                      backgroundColor: _g.softColor,
                      valueColor: AlwaysStoppedAnimation(_g.color),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: widget.score.toDouble()),
                      duration: _reduce
                          ? Duration.zero
                          : const Duration(milliseconds: 1100),
                      curve: Curves.easeOutCubic,
                      builder: (_, v, child) => Text(
                        '${v.round()}',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          height: 1,
                          color: _g.color,
                        ),
                      ),
                    ),
                    Text(
                      'dari 40',
                      style: TextStyle(
                        fontFamily: 'NimbusSans',
                        fontSize: 12,
                        color: AppColors.brand.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: _g.softColor,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              _g.label,
              style: TextStyle(
                fontFamily: 'NimbusSans',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _g.color,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _g.headline,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.brand,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _g.message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'NimbusSans',
              fontSize: 13.5,
              height: 1.5,
              color: AppColors.brand.withValues(alpha: 0.62),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launch(Uri uri) async {
    final ok = await canLaunchUrl(uri);
    if (ok) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak dapat membuka tautan di perangkat ini'),
        ),
      );
    }
  }

  Future<void> _contactResource(CrisisResource r) async {
    if (r.phone != null) {
      await _launch(Uri(scheme: 'tel', path: r.phone));
    } else if (r.url != null) {
      await _launch(Uri.parse(r.url!));
    }
  }

  void _showAllCrisisContacts() => showCrisisSheet(context);

  Widget _buildCrisisCard() {
    final primary = kPrimaryCrisisContact;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2C6B82), AppColors.brand],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.brand.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 10),
            spreadRadius: -6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.volunteer_activism_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Kamu tidak harus menghadapinya sendiri',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Jika kamu merasa kewalahan, bantuan tersedia kapan pun kamu membutuhkannya. Berbicara dengan seseorang bisa sangat membantu.',
            style: TextStyle(
              fontFamily: 'NimbusSans',
              fontSize: 13,
              height: 1.5,
              color: Colors.white.withValues(alpha: 0.88),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => _contactResource(primary),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.brand,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.call_rounded, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Hubungi Hotline 119',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: _showAllCrisisContacts,
              child: Text(
                'Kontak bantuan lainnya',
                style: TextStyle(
                  fontFamily: 'NimbusSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsHeader() {
    return const Row(
      children: [
        Text(
          'Rekomendasi untukmu',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.brand,
          ),
        ),
      ],
    );
  }

  Widget _buildDoneButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: _finish,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.brand,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(27),
            ),
          ),
          child: const Text(
            'Selesai',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final SelfHelpTip tip;
  final Color accent;
  const _TipCard({required this.tip, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.brand.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(tip.icon, size: 22, color: accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip.title,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brand,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip.description,
                  style: TextStyle(
                    fontFamily: 'NimbusSans',
                    fontSize: 12.5,
                    height: 1.45,
                    color: AppColors.brand.withValues(alpha: 0.6),
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
