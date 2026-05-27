import 'dart:async';
import 'package:flutter/material.dart';
import '../../widgets/bottom_nav.dart';
import '../../services/api_service.dart';

class HomePage extends StatefulWidget {
  final bool showNav;
  final VoidCallback? onMenuTap;
  const HomePage({super.key, this.showNav = true, this.onMenuTap});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int? _selectedMood;
  bool _submittingMood = false;
  final Set<int> _completedPlans = {};

  // 5 mood levels — index 0 (best) → level 5, index 4 (worst) → level 1
  final _moods = [
    _Mood('Sangat\nBaik', Icons.sentiment_very_satisfied, const Color(0xFF22C55E)),
    _Mood('Baik', Icons.sentiment_satisfied, const Color(0xFF61D1DB)),
    _Mood('Netral', Icons.sentiment_neutral, const Color(0xFF60A5FA)),
    _Mood('Kurang\nBaik', Icons.sentiment_dissatisfied, const Color(0xFFFBBF24)),
    _Mood('Stres', Icons.sentiment_very_dissatisfied, const Color(0xFFFB923C)),
  ];

  // Plans with duration in seconds
  final _plans = [
    _Plan('Meditasi Pagi', 'Mindfulness', Icons.self_improvement,
        Color(0xFFFB923C), Color(0xFFFFF4E5), 600),
    _Plan('Hydration Break', 'Water intake', Icons.water_drop,
        Color(0xFF60A5FA), Color(0xFFE3F2FD), 60),
    _Plan('Journaling', 'Reflection', Icons.edit_note,
        Color(0xFFC084FC), Color(0xFFF3E5F5), 900),
  ];

  late final List<AnimationController> _moodAnims;

  @override
  void initState() {
    super.initState();
    _moodAnims = List.generate(_moods.length, (_) =>
        AnimationController(vsync: this, duration: const Duration(milliseconds: 350)));
  }

  @override
  void dispose() {
    for (final c in _moodAnims) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _handleMoodTap(int idx) async {
    if (_submittingMood) return;
    _moodAnims[idx].forward(from: 0);
    setState(() {
      _selectedMood = idx;
      _submittingMood = true;
    });

    // Map index 0..4 → level 5..1 (best to worst)
    final level = 5 - idx;
    try {
      await ApiService.submitMood(level);
      if (!mounted) return;
      setState(() => _submittingMood = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mood "${_moods[idx].label.replaceAll('\n', ' ')}" tersimpan'),
          backgroundColor: _moods[idx].color,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _submittingMood = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: const Color(0xFF9D174D),
        ),
      );
    }
  }

  void _navigateTo(String id) {
    if (id == 'report') {
      Navigator.pushReplacementNamed(context, '/report');
    } else if (id == 'account') {
      Navigator.pushReplacementNamed(context, '/profile');
    }
  }

  Future<void> _startActivity(int planIdx) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (_) => _TimerSheet(plan: _plans[planIdx]),
    );
    if (result == true && mounted) {
      setState(() => _completedPlans.add(planIdx));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_plans[planIdx].title} selesai! 🎉'),
          backgroundColor: const Color(0xFF22C55E),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F8),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildGreeting(),
                _buildMoodSelector(),
                _buildStressCard(),
                _buildPlansSection(),
              ],
            ),
          ),
          if (widget.showNav)
            Positioned(
              left: 0, right: 0, bottom: 0,
              child: BottomNav(active: 'home', onTap: _navigateTo),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
        child: Row(
          children: [
            GestureDetector(
                onTap: widget.onMenuTap ?? () {},
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 2, offset: const Offset(0, 1)),
                    ],
                  ),
                  child: const Icon(Icons.menu_rounded,
                      color: Color(0xFF245A72), size: 20),
                ),
            ),
            const SizedBox(width: 12),
            const CircleAvatar(
              radius: 24,
              backgroundColor: Color(0xFFE0F2F4),
              child: Icon(Icons.person, color: Color(0xFF245A72)),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Welcome back,',
                    style: TextStyle(
                        fontFamily: 'Manrope', fontSize: 14,
                        fontWeight: FontWeight.w500, color: Color(0xFF568B8F))),
                Text(
                  ApiService.userName.isNotEmpty
                      ? ApiService.userName.split(' ').first
                      : 'User',
                  style: const TextStyle(
                      fontFamily: 'Manrope', fontSize: 20,
                      fontWeight: FontWeight.w700, color: Color(0xFF0F191A)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    final hour = DateTime.now().hour;
    final greeting = hour < 11
        ? 'Selamat Pagi'
        : hour < 15
            ? 'Selamat Siang'
            : hour < 18
                ? 'Selamat Sore'
                : 'Selamat Malam';
    final firstName = ApiService.userName.isNotEmpty
        ? ApiService.userName.split(' ').first
        : 'User';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$greeting,',
              style: const TextStyle(
                  fontFamily: 'Manrope', fontSize: 30,
                  fontWeight: FontWeight.w700, color: Color(0xFF0F191A),
                  letterSpacing: -0.75, height: 1.2)),
          Text(firstName,
              style: const TextStyle(
                  fontFamily: 'Manrope', fontSize: 30,
                  fontWeight: FontWeight.w700, color: Color(0xFF0F191A),
                  letterSpacing: -0.75, height: 1.2)),
          const SizedBox(height: 8),
          const Text('Bagaimana kabarmu hari ini?',
              style: TextStyle(
                  fontFamily: 'Manrope', fontSize: 16, color: Color(0xFF568B8F))),
        ],
      ),
    );
  }

  Widget _buildMoodSelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 48),
      child: Row(
        children: List.generate(_moods.length, (i) {
          final mood = _moods[i];
          final isSelected = _selectedMood == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => _handleMoodTap(i),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _moodAnims[i],
                      builder: (ctx, child) {
                        // Bounce: scale up to 1.25 at mid, back to 1.0 at end
                        final t = _moodAnims[i].value;
                        final scale = 1.0 + (0.25 * (1 - (2 * t - 1).abs()));
                        return Transform.scale(scale: scale, child: child);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutBack,
                        width: 56, height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? mood.color.withValues(alpha: 0.15)
                              : Colors.white,
                          border: isSelected
                              ? Border.all(color: mood.color, width: 2)
                              : null,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                      color: mood.color.withValues(alpha: 0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4)),
                                ]
                              : [
                                  BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 2,
                                      offset: const Offset(0, 1)),
                                ],
                        ),
                        child: Icon(mood.icon, size: 28,
                            color: isSelected
                                ? mood.color
                                : const Color(0xFF94A3B8)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      mood.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Manrope', fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? mood.color : const Color(0xFF568B8F),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStressCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment(-1, -1), end: Alignment(1, 1),
            colors: [Color(0xFFE4F6F8), Color(0xFFF4FAFB), Colors.white],
            stops: [0.0, 0.5, 1.0],
          ),
          border: Border.all(color: const Color(0xFF61D1DB).withValues(alpha: 0.08)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Stack(
            children: [
              Positioned(
                  top: 0, right: 0,
                  child: Icon(Icons.cloud_outlined, size: 40,
                      color: const Color(0xFF61D1DB).withValues(alpha: 0.35))),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Stress Check-in',
                      style: TextStyle(
                          fontFamily: 'Manrope', fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F191A))),
                  const SizedBox(height: 4),
                  const Text(
                    'Saatnya melakukan check in rutin untuk memantau tingkat stres Anda.',
                    style: TextStyle(
                        fontFamily: 'Manrope', fontSize: 14,
                        color: Color(0xFF568B8F), height: 1.625),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/stress'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF61D1DB),
                      foregroundColor: Colors.white, elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9999)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Mulai Stress Assessment',
                            style: TextStyle(
                                fontFamily: 'Manrope', fontSize: 14,
                                fontWeight: FontWeight.w700)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlansSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Your Plan',
                  style: TextStyle(
                      fontFamily: 'Manrope', fontSize: 20,
                      fontWeight: FontWeight.w700, color: Color(0xFF0F191A))),
              Text('Manage Plan',
                  style: TextStyle(
                      fontFamily: 'Manrope', fontSize: 14,
                      fontWeight: FontWeight.w700, color: Color(0xFF61D1DB))),
            ],
          ),
          const SizedBox(height: 20),
          ...List.generate(_plans.length, (i) => _buildPlanCard(i)),
        ],
      ),
    );
  }

  Widget _buildPlanCard(int idx) {
    final plan = _plans[idx];
    final isCompleted = _completedPlans.contains(idx);
    final mins = plan.durationSeconds ~/ 60;
    final durationLabel = mins > 0 ? '$mins min' : '${plan.durationSeconds} sec';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
                color: plan.bgColor, shape: BoxShape.circle),
            child: Icon(plan.icon, color: plan.iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.title,
                  style: TextStyle(
                    fontFamily: 'Manrope', fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isCompleted
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF0F191A),
                    decoration:
                        isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text('$durationLabel • ${plan.desc}',
                    style: const TextStyle(
                        fontFamily: 'Manrope', fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF568B8F))),
              ],
            ),
          ),
          const SizedBox(width: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: CurvedAnimation(parent: animation, curve: Curves.elasticOut),
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: isCompleted
                ? Container(
                    key: const ValueKey('done'),
                    width: 36, height: 36,
                    decoration: const BoxDecoration(
                        color: Color(0xFF22C55E), shape: BoxShape.circle),
                    child: const Icon(Icons.check, color: Colors.white, size: 18),
                  )
                : ElevatedButton(
                    key: const ValueKey('start'),
                    onPressed: () => _startActivity(idx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: plan.iconColor,
                      foregroundColor: Colors.white, elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9999)),
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.play_arrow_rounded, size: 16),
                        SizedBox(width: 4),
                        Text('Start',
                            style: TextStyle(
                                fontFamily: 'Manrope', fontSize: 12,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _Mood {
  final String label;
  final IconData icon;
  final Color color;
  _Mood(this.label, this.icon, this.color);
}

class _Plan {
  final String title;
  final String desc;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final int durationSeconds;
  _Plan(this.title, this.desc, this.icon, this.iconColor, this.bgColor,
      this.durationSeconds);
}

// ──────────────────────────────────────────────────────────────────────────
// Timer Sheet
// ──────────────────────────────────────────────────────────────────────────

class _TimerSheet extends StatefulWidget {
  final _Plan plan;
  const _TimerSheet({required this.plan});

  @override
  State<_TimerSheet> createState() => _TimerSheetState();
}

class _TimerSheetState extends State<_TimerSheet>
    with SingleTickerProviderStateMixin {
  late int _remaining;
  Timer? _timer;
  bool _running = true;
  late final AnimationController _pulseAnim;

  @override
  void initState() {
    super.initState();
    _remaining = widget.plan.durationSeconds;
    _pulseAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseAnim.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remaining <= 1) {
        t.cancel();
        if (mounted) Navigator.pop(context, true);
      } else {
        setState(() => _remaining--);
      }
    });
  }

  void _toggle() {
    setState(() {
      _running = !_running;
      if (_running) {
        _startTimer();
        _pulseAnim.repeat(reverse: true);
      } else {
        _timer?.cancel();
        _pulseAnim.stop();
      }
    });
  }

  String _format(int s) {
    final m = s ~/ 60;
    final r = s % 60;
    return '${m.toString().padLeft(2, '0')}:${r.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress =
        1 - (_remaining / widget.plan.durationSeconds).clamp(0.0, 1.0);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF245A72).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 24),
          Text(widget.plan.title,
              style: const TextStyle(
                  fontFamily: 'Manrope', fontSize: 22,
                  fontWeight: FontWeight.w800, color: Color(0xFF0F191A))),
          const SizedBox(height: 4),
          Text(widget.plan.desc,
              style: const TextStyle(
                  fontFamily: 'Manrope', fontSize: 14,
                  color: Color(0xFF568B8F))),
          const SizedBox(height: 36),

          // Circular timer
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (_, _) {
              final pulse = 1.0 + (_running ? _pulseAnim.value * 0.04 : 0);
              return Transform.scale(
                scale: pulse,
                child: SizedBox(
                  width: 220, height: 220,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 220, height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.plan.bgColor,
                          boxShadow: [
                            BoxShadow(
                                color: widget.plan.iconColor
                                    .withValues(alpha: 0.2),
                                blurRadius: 32,
                                spreadRadius: -8),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 200, height: 200,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 8,
                          backgroundColor:
                              widget.plan.iconColor.withValues(alpha: 0.15),
                          valueColor:
                              AlwaysStoppedAnimation(widget.plan.iconColor),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(widget.plan.icon,
                              color: widget.plan.iconColor, size: 32),
                          const SizedBox(height: 8),
                          Text(_format(_remaining),
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 38,
                                fontWeight: FontWeight.w800,
                                color: widget.plan.iconColor,
                                letterSpacing: -1,
                                fontFeatures: const [
                                  FontFeature.tabularFigures()
                                ],
                              )),
                          Text(_running ? 'Sedang berjalan…' : 'Dijeda',
                              style: const TextStyle(
                                  fontFamily: 'Manrope', fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF94A3B8))),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 36),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _timer?.cancel();
                    Navigator.pop(context, false);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF94A3B8),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Batal',
                      style: TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _toggle,
                  icon: Icon(_running ? Icons.pause : Icons.play_arrow,
                      size: 18),
                  label: Text(_running ? 'Jeda' : 'Lanjut',
                      style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.plan.iconColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
