import 'dart:async';
import 'dart:math' as math;
import '../../theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../../widgets/bottom_nav.dart';
import '../../services/api_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/crisis_sheet.dart';
import '../../widgets/sos_button.dart';
import '../../data/activity_library.dart';
import '../../data/daily_content.dart';

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
  Map<String, dynamic>? _streak;
  Map<String, dynamic>? _recap;

  bool _activitiesLoaded = false;
  List<Map<String, dynamic>> _routine = [];
  final Set<String> _completedToday = {};
  Map<String, dynamic> _activityStreak = {};
  int? _stressCategory;
  int? _moodLevel;
  final Set<String> _dismissedRecs = {};
  final _moods = [
    _Mood('Sangat\nBaik', Icons.sentiment_very_satisfied, AppColors.success),
    _Mood('Baik', Icons.sentiment_satisfied, AppColors.accent),
    _Mood('Netral', Icons.sentiment_neutral, const Color(0xFF60A5FA)),
    _Mood(
      'Kurang\nBaik',
      Icons.sentiment_dissatisfied,
      const Color(0xFFFBBF24),
    ),
    _Mood('Stres', Icons.sentiment_very_dissatisfied, const Color(0xFFFB923C)),
  ];

  late final List<AnimationController> _moodAnims;

  @override
  void initState() {
    super.initState();
    _moodAnims = List.generate(
      _moods.length,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 350),
      ),
    );
    _loadStreak();
    _loadActivities();
    _loadRecap();
  }

  Future<void> _loadStreak() async {
    try {
      final s = await ApiService.getMoodStreak();
      if (mounted) setState(() => _streak = s);
      NotificationService.sync(checkedInToday: s['checked_in_today'] == true);
    } catch (_) {}
  }

  Future<void> _loadRecap() async {
    try {
      final r = await ApiService.getWeeklyRecap();
      if (mounted) setState(() => _recap = r);
    } catch (_) {}
  }

  Future<void> _loadActivities() async {
    try {
      final data = await ApiService.getActivities();
      if (!mounted) return;
      setState(() {
        _routine = List<Map<String, dynamic>>.from(data['routine'] ?? []);
        _completedToday
          ..clear()
          ..addAll(
            ((data['completed_today'] ?? []) as List).map((e) => e.toString()),
          );
        _activityStreak = Map<String, dynamic>.from(data['streak'] ?? {});
        final ctx = Map<String, dynamic>.from(data['context'] ?? {});
        _stressCategory = (ctx['stress_category'] as num?)?.toInt();
        _moodLevel = (ctx['mood_level'] as num?)?.toInt();
        _activitiesLoaded = true;
      });
    } catch (_) {}
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

    final level = 5 - idx;
    try {
      await ApiService.submitMood(level);
      if (!mounted) return;
      setState(() => _submittingMood = false);
      _loadStreak();
      _loadActivities();
      _loadRecap();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Mood "${_moods[idx].label.replaceAll('\n', ' ')}" tersimpan',
          ),
          backgroundColor: _moods[idx].color,
          duration: const Duration(seconds: 2),
        ),
      );
      if (idx == 4) _showAcuteMoodSupport();
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

  void _showAcuteMoodSupport() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
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
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.accentLight.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_rounded,
                color: AppColors.accentDeep,
                size: 26,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Terdengar berat hari ini',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F191A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kamu tidak harus melewatinya sendirian. Mau coba satu hal kecil yang bisa membantu sekarang?',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14,
                height: 1.5,
                color: const Color(0xFF0F191A).withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 22),
            _acuteAction(
              icon: Icons.air_rounded,
              color: AppColors.accentDeep,
              title: 'Latihan napas 4-7-8',
              subtitle: 'Dua menit untuk menenangkan diri',
              onTap: () {
                Navigator.pop(sheetCtx);
                final breathing = kActivityCatalog['breathing_478'];
                if (breathing != null) _doActivity(breathing);
              },
            ),
            const SizedBox(height: 10),
            _acuteAction(
              icon: Icons.volunteer_activism_rounded,
              color: AppColors.brand,
              title: 'Bicara dengan seseorang',
              subtitle: 'Lihat kontak bantuan yang tersedia',
              onTap: () {
                Navigator.pop(sheetCtx);
                showCrisisSheet(context);
              },
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(sheetCtx),
                child: Text(
                  'Nanti saja',
                  style: TextStyle(
                    fontFamily: 'NimbusSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.subtle.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _acuteAction({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFFFBFDFD),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEAF0F1)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brand,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: 'NimbusSans',
                        fontSize: 12,
                        height: 1.35,
                        color: AppColors.subtle,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.subtle,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateTo(String id) {
    if (id == 'report') {
      Navigator.pushReplacementNamed(context, '/report');
    } else if (id == 'account') {
      Navigator.pushReplacementNamed(context, '/profile');
    }
  }

  _Plan _planFromActivity(Activity a) =>
      _Plan(a.title, a.desc, a.icon, a.color, a.bgColor, a.durationSeconds);

  Future<void> _doActivity(Activity a) async {
    if (_completedToday.contains(a.key)) return;

    if (a.isTimed) {
      final result = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        isDismissible: false,
        enableDrag: false,
        builder: (_) => _TimerSheet(plan: _planFromActivity(a)),
      );
      if (result == true) await _completeActivity(a);
    } else {
      await _completeActivity(a);
    }
  }

  Future<void> _completeActivity(Activity a) async {
    setState(() => _completedToday.add(a.key));
    try {
      final res = await ApiService.completeActivity(a.key);
      if (!mounted) return;
      setState(
        () => _activityStreak = Map<String, dynamic>.from(
          res['streak'] ?? _activityStreak,
        ),
      );
      _loadRecap();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${a.title} selesai! 🎉'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _completedToday.remove(a.key));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menyimpan: ${e.toString().replaceAll('Exception: ', '')}',
          ),
          backgroundColor: const Color(0xFF9D174D),
        ),
      );
    }
  }

  Future<void> _addToRoutine(Activity a) async {
    try {
      await ApiService.addRoutineActivity(a.key);
      await _loadActivities();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menambah: ${e.toString().replaceAll('Exception: ', '')}',
          ),
          backgroundColor: const Color(0xFF9D174D),
        ),
      );
    }
  }

  Future<void> _removeFromRoutine(Map<String, dynamic> item) async {
    final id = (item['id'] as num).toInt();
    final activity = activityByKey(item['activity_key']?.toString() ?? '');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Hapus dari rutinitas?',
          style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700),
        ),
        content: Text(
          '"${activity?.title ?? 'Aktivitas ini'}" akan dihapus dari Rutinitas Saya.',
          style: const TextStyle(fontFamily: 'NimbusSans'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.subtle),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Hapus',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ApiService.removeRoutineActivity(id);
      await _loadActivities();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menghapus: ${e.toString().replaceAll('Exception: ', '')}',
          ),
          backgroundColor: const Color(0xFF9D174D),
        ),
      );
    }
  }

  Future<void> _showLibrarySheet() async {
    final inRoutine = _routine.map((e) => e['activity_key'].toString()).toSet();
    final available = allActivities
        .where((a) => !inRoutine.contains(a.key))
        .toList();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _LibrarySheet(
        activities: available,
        onPick: (a) async {
          Navigator.pop(ctx);
          await _addToRoutine(a);
        },
      ),
    );
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
                _buildDailyCard(),
                _buildStressCard(),
                _buildPlansSection(),
                _buildRecapCard(),
              ],
            ),
          ),
          if (widget.showNav)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
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
                  Icons.menu_rounded,
                  color: AppColors.brand,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const CircleAvatar(
              radius: 24,
              backgroundColor: Color(0xFFE0F2F4),
              child: Icon(Icons.person, color: AppColors.brand),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back,',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.subtle,
                  ),
                ),
                Text(
                  ApiService.userName.isNotEmpty
                      ? ApiService.userName.split(' ').first
                      : 'User',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F191A),
                  ),
                ),
              ],
            ),
            const Spacer(),
            const SosIconButton(margin: EdgeInsets.only(right: 10)),
            if (_streak != null)
              _StreakFlame(
                streak: (_streak!['current_streak'] as num?)?.toInt() ?? 0,
                checkedInToday: _streak!['checked_in_today'] == true,
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
          Text(
            '$greeting,',
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F191A),
              letterSpacing: -0.75,
              height: 1.2,
            ),
          ),
          Text(
            firstName,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F191A),
              letterSpacing: -0.75,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Bagaimana kabarmu hari ini?',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 16,
              color: AppColors.subtle,
            ),
          ),
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
                        final t = _moodAnims[i].value;
                        final scale = 1.0 + (0.25 * (1 - (2 * t - 1).abs()));
                        return Transform.scale(scale: scale, child: child);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutBack,
                        width: 56,
                        height: 56,
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
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                        ),
                        child: Icon(
                          mood.icon,
                          size: 28,
                          color: isSelected
                              ? mood.color
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      mood.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? mood.color : AppColors.subtle,
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

  Widget _buildDailyCard() {
    final item = dailyItemFor(DateTime.now());

    final (
      Color fg,
      Color bg,
      IconData icon,
      String label,
    ) = switch (item.kind) {
      DailyKind.tip => (
        AppColors.accentDeep,
        const Color(0xFFE8FBFC),
        Icons.lightbulb_outline_rounded,
        'Tips Hari Ini',
      ),
      DailyKind.quote => (
        AppColors.brand,
        const Color(0xFFEFF5F7),
        Icons.format_quote_rounded,
        'Renungan',
      ),
      DailyKind.practice => (
        AppColors.success,
        const Color(0xFFEAF7EF),
        Icons.self_improvement_rounded,
        'Latihan Cepat',
      ),
    };

    final Activity? linked = item.activityKey != null
        ? kActivityCatalog[item.activityKey!]
        : null;
    final done = linked != null && _completedToday.contains(linked.key);

    return _FadeInOnce(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: fg.withValues(alpha: 0.12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: fg),
                  const SizedBox(width: 8),
                  Text(
                    label.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'NimbusSans',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: fg,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                item.title,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F191A),
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item.kind == DailyKind.quote ? '“${item.body}”' : item.body,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  color: const Color(0xFF0F191A).withValues(alpha: 0.7),
                  height: 1.5,
                  fontStyle: item.kind == DailyKind.quote
                      ? FontStyle.italic
                      : FontStyle.normal,
                ),
              ),
              if (item.kind == DailyKind.quote && item.author != null) ...[
                const SizedBox(height: 8),
                Text(
                  '— ${item.author}',
                  style: TextStyle(
                    fontFamily: 'NimbusSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: fg,
                  ),
                ),
              ],
              if (linked != null) ...[
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Material(
                    color: done ? Colors.transparent : fg,
                    borderRadius: BorderRadius.circular(999),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: done ? null : () => _doActivity(linked),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              done
                                  ? Icons.check_circle_rounded
                                  : Icons.play_arrow_rounded,
                              size: 18,
                              color: done ? fg : Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              done ? 'Selesai hari ini' : 'Coba sekarang',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: done ? fg : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Week-to-date recap — a glanceable closing card that makes the daily
  /// check-ins and activities feel like they accumulate into something.
  /// Hidden until there's at least one entry this week (no empty/sad state).
  Widget _buildRecapCard() {
    final recap = _recap;
    if (recap == null) return const SizedBox.shrink();

    final mood = Map<String, dynamic>.from(recap['mood'] ?? {});
    final acts = Map<String, dynamic>.from(recap['activities'] ?? {});
    final moodCount = (mood['count'] as num?)?.toInt() ?? 0;
    final actCount = (acts['count'] as num?)?.toInt() ?? 0;
    if (moodCount == 0 && actCount == 0) return const SizedBox.shrink();

    final avg = (mood['average'] as num?)?.toDouble();
    final moodActiveDays = (mood['active_days'] as num?)?.toInt() ?? 0;
    final topKey = acts['top_key'] as String?;
    final topActivity = topKey != null ? kActivityCatalog[topKey] : null;

    String moodLabel() {
      if (avg == null) return '—';
      if (avg >= 4.5) return 'Sangat Baik';
      if (avg >= 3.5) return 'Baik';
      if (avg >= 2.5) return 'Netral';
      if (avg >= 1.5) return 'Kurang Baik';
      return 'Berat';
    }

    String encouragement() {
      if (avg != null && avg >= 3.5 && actCount >= 3) {
        return 'Minggu yang stabil dan konsisten. Pertahankan ya 👏';
      }
      if (avg != null && avg < 2.5) {
        return 'Minggu ini terasa berat. Kamu tidak harus melewatinya sendirian 💙';
      }
      if (moodActiveDays <= 1) {
        return 'Yuk lebih sering check-in minggu ini — sedikit demi sedikit.';
      }
      if (actCount == 0) {
        return 'Coba satu aktivitas kecil minggu ini, lihat bedanya.';
      }
      return 'Langkah-langkah kecilmu minggu ini berarti. Terus jalan 🌱';
    }

    return _FadeInOnce(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFEFF7F8), Color(0xFFF6FBFB)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.brand.withValues(alpha: 0.10)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 16,
                    color: AppColors.brand,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'RINGKASAN MINGGU INI',
                    style: TextStyle(
                      fontFamily: 'NimbusSans',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: AppColors.brand.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _recapStat(moodLabel(), 'Mood rata-rata', Icons.mood_rounded),
                  _recapDivider(),
                  _recapStat(
                    '$moodActiveDays hari',
                    'Check-in',
                    Icons.event_available_rounded,
                  ),
                  _recapDivider(),
                  _recapStat('$actCount', 'Aktivitas', Icons.spa_rounded),
                ],
              ),
              if (topActivity != null) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(topActivity.icon, size: 16, color: AppColors.subtle),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Paling sering: ${topActivity.title}',
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.subtle,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              Text(
                encouragement(),
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  height: 1.45,
                  color: const Color(0xFF0F191A).withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _recapStat(String value, String label, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.accentDeep),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F191A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'NimbusSans',
              fontSize: 11,
              color: AppColors.subtle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _recapDivider() => Container(
    width: 1,
    height: 40,
    color: AppColors.brand.withValues(alpha: 0.08),
  );

  Widget _buildStressCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment(-1, -1),
            end: Alignment(1, 1),
            colors: [Color(0xFFE4F6F8), Color(0xFFF4FAFB), Colors.white],
            stops: [0.0, 0.5, 1.0],
          ),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.08)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                right: 0,
                child: Icon(
                  Icons.cloud_outlined,
                  size: 40,
                  color: AppColors.accent.withValues(alpha: 0.35),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Work-Stress Check-in',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F191A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Saatnya melakukan check in rutin untuk memantau tingkat stres Anda.',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 14,
                      color: AppColors.subtle,
                      height: 1.625,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/stress'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Mulai Check-in Stres',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
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
    final recs = _currentRecommendations();
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (recs.isNotEmpty) ...[
            _buildRecommendationsZone(recs),
            const SizedBox(height: 32),
          ],
          _buildRoutineZone(),
        ],
      ),
    );
  }

  List<Activity> _currentRecommendations() {
    if (!_activitiesLoaded) return [];
    final inRoutine = _routine.map((e) => e['activity_key'].toString()).toSet();
    final keys = recommendedActivityKeys(
      stressCategory: _stressCategory,
      moodLevel: _moodLevel,
    );
    final result = <Activity>[];
    for (final k in keys) {
      if (inRoutine.contains(k)) continue;
      if (_dismissedRecs.contains(k)) continue;
      if (_completedToday.contains(k)) continue;
      final a = activityByKey(k);
      if (a != null) result.add(a);
      if (result.length == 3) break;
    }
    return result;
  }

  String _recSubtitle() {
    if (_stressCategory == 3) {
      return 'Disesuaikan untuk meredakan stres tinggimu';
    }
    if (_stressCategory == 1) return 'Untuk menjaga kondisi baikmu';
    if (_moodLevel != null && _moodLevel! <= 2) {
      return 'Dipilih untuk menemani harimu yang berat';
    }
    if (_stressCategory == null && _moodLevel == null) {
      return 'Beberapa aktivitas untuk memulai harimu';
    }
    return 'Disesuaikan dengan kondisimu hari ini';
  }

  Widget _buildRecommendationsZone(List<Activity> recs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.auto_awesome_rounded,
              size: 18,
              color: AppColors.accentDeep,
            ),
            const SizedBox(width: 7),
            const Text(
              'Rekomendasi Hari Ini',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F191A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          _recSubtitle(),
          style: TextStyle(
            fontFamily: 'NimbusSans',
            fontSize: 12.5,
            color: AppColors.brand.withValues(alpha: 0.55),
          ),
        ),
        const SizedBox(height: 14),
        ...recs.asMap().entries.map(
          (e) => _FadeInOnce(
            key: ValueKey('rec_${e.value.key}'),
            delay: Duration(milliseconds: e.key * 70),
            child: _buildRecCard(e.value),
          ),
        ),
      ],
    );
  }

  Widget _buildRecCard(Activity a) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [a.bgColor, a.bgColor.withValues(alpha: 0.35)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: a.color.withValues(alpha: 0.20)),
          boxShadow: [
            BoxShadow(
              color: a.color.withValues(alpha: 0.10),
              blurRadius: 16,
              offset: const Offset(0, 6),
              spreadRadius: -4,
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
                    color: Colors.white.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(a.icon, color: a.color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a.title,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F191A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${a.durationLabel} • ${a.desc}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'NimbusSans',
                          fontSize: 12,
                          color: AppColors.subtle,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _dismissedRecs.add(a.key)),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: AppColors.brand.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _doActivity(a),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: a.color,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          a.isTimed
                              ? Icons.play_arrow_rounded
                              : Icons.check_rounded,
                          size: 17,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          a.isTimed ? 'Kerjakan' : 'Tandai Selesai',
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _addToRoutine(a),
                  child: Container(
                    height: 41,
                    width: 41,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      shape: BoxShape.circle,
                      border: Border.all(color: a.color.withValues(alpha: 0.3)),
                    ),
                    child: Icon(
                      Icons.push_pin_outlined,
                      size: 18,
                      color: a.color,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Zona: Rutinitas Saya ──────────────────────────────────────────────────

  Widget _buildRoutineZone() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                children: [
                  const Flexible(
                    child: Text(
                      'Rutinitas Saya',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F191A),
                      ),
                    ),
                  ),
                  if (((_activityStreak['current'] as num?)?.toInt() ?? 0) >
                      0) ...[
                    const SizedBox(width: 10),
                    _buildActivityStreakChip(),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _showLibrarySheet,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_rounded,
                      size: 16,
                      color: AppColors.accentDeep,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Tambah',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accentDeep,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_activitiesLoaded && _routine.isEmpty)
          _buildRoutineEmptyState()
        else
          ..._routine.asMap().entries.map(
            (e) => _FadeInOnce(
              key: ValueKey('routine_${e.value['activity_key']}'),
              delay: Duration(milliseconds: e.key * 70),
              child: _buildRoutineCard(e.value),
            ),
          ),
      ],
    );
  }

  Widget _buildActivityStreakChip() {
    final current = (_activityStreak['current'] as num?)?.toInt() ?? 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFF9A4D).withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department_rounded,
            size: 14,
            color: Color(0xFFF97316),
          ),
          const SizedBox(width: 3),
          Text(
            '$current',
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFFEA6A12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineEmptyState() {
    return GestureDetector(
      onTap: _showLibrarySheet,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F8F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.accent.withValues(alpha: 0.25),
            width: 1.2,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.spa_outlined,
                color: AppColors.accentDeep,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Belum ada rutinitas',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.brand,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tambahkan aktivitas dari pustaka untuk membangun kebiasaan harianmu.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'NimbusSans',
                fontSize: 12.5,
                height: 1.45,
                color: AppColors.brand.withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutineCard(Map<String, dynamic> item) {
    final activity = activityByKey(item['activity_key']?.toString() ?? '');
    if (activity == null) return const SizedBox.shrink();
    final isCompleted = _completedToday.contains(activity.key);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onLongPress: () => _removeFromRoutine(item),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: activity.bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(activity.icon, color: activity.color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isCompleted
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF0F191A),
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${activity.durationLabel} • ${activity.desc}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.subtle,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildDoButton(activity, isCompleted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoButton(Activity activity, bool isCompleted) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: CurvedAnimation(parent: animation, curve: Curves.elasticOut),
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: isCompleted
          ? Container(
              key: const ValueKey('done'),
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 18),
            )
          : ElevatedButton(
              key: const ValueKey('start'),
              onPressed: () => _doActivity(activity),
              style: ElevatedButton.styleFrom(
                backgroundColor: activity.color,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999),
                ),
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    activity.isTimed
                        ? Icons.play_arrow_rounded
                        : Icons.check_rounded,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    activity.isTimed ? 'Mulai' : 'Selesai',
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
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
  _Plan(
    this.title,
    this.desc,
    this.icon,
    this.iconColor,
    this.bgColor,
    this.durationSeconds,
  );
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
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.brand.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            widget.plan.title,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F191A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.plan.desc,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 14,
              color: AppColors.subtle,
            ),
          ),
          const SizedBox(height: 36),
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (_, _) {
              final pulse = 1.0 + (_running ? _pulseAnim.value * 0.04 : 0);
              return Transform.scale(
                scale: pulse,
                child: SizedBox(
                  width: 220,
                  height: 220,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.plan.bgColor,
                          boxShadow: [
                            BoxShadow(
                              color: widget.plan.iconColor.withValues(
                                alpha: 0.2,
                              ),
                              blurRadius: 32,
                              spreadRadius: -8,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 8,
                          backgroundColor: widget.plan.iconColor.withValues(
                            alpha: 0.15,
                          ),
                          valueColor: AlwaysStoppedAnimation(
                            widget.plan.iconColor,
                          ),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.plan.icon,
                            color: widget.plan.iconColor,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _format(_remaining),
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 38,
                              fontWeight: FontWeight.w800,
                              color: widget.plan.iconColor,
                              letterSpacing: -1,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                          Text(
                            _running ? 'Sedang berjalan…' : 'Dijeda',
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
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
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Batal',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _toggle,
                  icon: Icon(
                    _running ? Icons.pause : Icons.play_arrow,
                    size: 18,
                  ),
                  label: Text(
                    _running ? 'Jeda' : 'Lanjut',
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.plan.iconColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
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

// ──────────────────────────────────────────────────────────────────────────
// One-shot staggered entrance. Keyed by content so it animates on first mount
// only — rebuilds (complete/dismiss/reload) preserve State and don't re-fire.
// ──────────────────────────────────────────────────────────────────────────

class _FadeInOnce extends StatefulWidget {
  final Widget child;
  final Duration delay;
  const _FadeInOnce({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  @override
  State<_FadeInOnce> createState() => _FadeInOnceState();
}

class _FadeInOnceState extends State<_FadeInOnce>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _a;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _a = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    // Note: do NOT read MediaQuery here — inherited widgets aren't available
    // during initState. Reduced-motion is handled in build().
    Future.delayed(widget.delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Respect reduced-motion: show the child fully, no animation.
    if (MediaQuery.of(context).disableAnimations) return widget.child;
    return AnimatedBuilder(
      animation: _a,
      builder: (_, child) => Opacity(
        opacity: _a.value,
        child: Transform.translate(
          offset: Offset(0, 12 * (1 - _a.value)),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
// Library picker — choose an activity to add to "Rutinitas Saya"
// ──────────────────────────────────────────────────────────────────────────

class _LibrarySheet extends StatelessWidget {
  final List<Activity> activities;
  final ValueChanged<Activity> onPick;
  const _LibrarySheet({required this.activities, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.7;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.brand.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 18),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Tambah Aktivitas',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.brand,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Pilih dari pustaka untuk dimasukkan ke rutinitasmu.',
              style: TextStyle(
                fontFamily: 'NimbusSans',
                fontSize: 13,
                color: AppColors.brand.withValues(alpha: 0.55),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (activities.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 40,
                    color: AppColors.accent,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Semua aktivitas sudah ada di rutinitasmu 🎉',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'NimbusSans',
                      fontSize: 13.5,
                      color: AppColors.brand.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: activities.length,
                separatorBuilder: (_, i) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final a = activities[i];
                  return GestureDetector(
                    onTap: () => onPick(a),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBFDFD),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEAF0F1)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: a.bgColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(a.icon, color: a.color, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  a.title,
                                  style: const TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.brand,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${a.durationLabel} • ${a.desc}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'NimbusSans',
                                    fontSize: 12,
                                    color: AppColors.subtle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: a.color.withValues(alpha: 0.14),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.add_rounded,
                              size: 18,
                              color: a.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
// alive, dimmed/static when broken or not checked in today.
// ──────────────────────────────────────────────────────────────────────────

class _StreakFlame extends StatefulWidget {
  final int streak;
  final bool checkedInToday;
  const _StreakFlame({required this.streak, required this.checkedInToday});

  @override
  State<_StreakFlame> createState() => _StreakFlameState();
}

class _StreakFlameState extends State<_StreakFlame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  bool get _alive => widget.streak > 0;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Flicker only when the streak is alive and motion is allowed.
    final reduce = MediaQuery.of(context).disableAnimations;
    if (_alive && !reduce) {
      if (!_c.isAnimating) _c.repeat();
    } else {
      _c.stop();
      _c.value = 0;
    }
  }

  @override
  void didUpdateWidget(covariant _StreakFlame old) {
    super.didUpdateWidget(old);
    if (widget.streak != old.streak) {
      final reduce = MediaQuery.of(context).disableAnimations;
      if (_alive && !reduce) {
        if (!_c.isAnimating) _c.repeat();
      } else {
        _c.stop();
        _c.value = 0;
      }
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flameColor = _alive
        ? const Color(0xFFFF7A1A)
        : const Color(0xFFB8C2CC);
    final numberColor = _alive
        ? const Color(0xFFEA6A12)
        : const Color(0xFF94A3B8);
    final pillColor = _alive
        ? const Color(0xFFFFE7CC)
        : const Color(0xFFEDF1F4);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: pillColor,
        borderRadius: BorderRadius.circular(999),
        boxShadow: _alive
            ? [
                BoxShadow(
                  color: const Color(0xFFFF7A1A).withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: -2,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _c,
            builder: (_, child) {
              if (!_alive) return child!;
              // Two out-of-phase sine waves → organic flicker: vertical
              // stretch + gentle sway + a glow pulse behind the icon.
              final t = _c.value * 2 * math.pi;
              final stretchY = 1.0 + 0.12 * math.sin(t);
              final stretchX = 1.0 - 0.05 * math.sin(t);
              final sway = 0.06 * math.sin(t * 1.7);
              final glow = 0.45 + 0.35 * (0.5 + 0.5 * math.sin(t * 2.3));
              return Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFFFFB020,
                          ).withValues(alpha: glow * 0.5),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  Transform.rotate(
                    angle: sway,
                    child: Transform.scale(
                      scaleX: stretchX,
                      scaleY: stretchY,
                      alignment: Alignment.bottomCenter,
                      child: child,
                    ),
                  ),
                ],
              );
            },
            child: Icon(
              Icons.local_fire_department_rounded,
              size: 20,
              color: flameColor,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            '${widget.streak}',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: numberColor,
            ),
          ),
        ],
      ),
    );
  }
}
