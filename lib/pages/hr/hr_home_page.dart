import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../data/division_info.dart';
import '../../services/api_service.dart';
import 'hr_division_detail_page.dart';

class HrHomePage extends StatefulWidget {
  final bool showNav;
  const HrHomePage({super.key, this.showNav = true});

  @override
  State<HrHomePage> createState() => _HrHomePageState();
}

class _HrHomePageState extends State<HrHomePage> {
  bool _loading = true;
  String? _error;
  int _totalEmployees = 0;
  Map<String, double> _divisionStress = {};
  Map<String, bool> _divisionSuppressed = {};
  List<Map<String, dynamic>> _alerts = [];
  DateTimeRange? _dateRange;

  static const int _minGroupSize = 5;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final employees = await ApiService.getEmployees();
      final divisions = await ApiService.getStressDivisions(
        startDate: _dateRange?.start,
        endDate: _dateRange?.end,
      );
      final alerts = await ApiService.getStressAlerts();

      final stressMap = <String, double>{};
      final suppressedMap = <String, bool>{};
      for (final d in divisions) {
        final name = d['division']?.toString() ?? '';
        final suppressed = d['suppressed'] == true;
        suppressedMap[name] = suppressed;
        if (suppressed) {
          stressMap[name] = 0;
        } else {
          final avg = (d['avg_score'] as num?)?.toDouble() ?? 0;
          stressMap[name] = (avg / 40).clamp(0.0, 1.0);
        }
      }

      setState(() {
        _totalEmployees = employees.length;
        _divisionStress = stressMap;
        _divisionSuppressed = suppressedMap;
        _alerts = alerts;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> _pickDateRange() async {
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2027, 12, 31),
      initialDateRange:
          _dateRange ??
          DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 30)),
            end: DateTime.now(),
          ),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.brand,
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (result != null) {
      setState(() => _dateRange = result);
      _loadData();
    }
  }

  void _clearDateRange() {
    setState(() => _dateRange = null);
    _loadData();
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              if (_error != null)
                Container(
                  margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCE7F3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Color(0xFF9D174D),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(
                            fontFamily: 'NimbusSans',
                            fontSize: 13,
                            color: Color(0xFF9D174D),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _loadData,
                        child: const Text(
                          'Retry',
                          style: TextStyle(
                            fontFamily: 'NimbusSans',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF9D174D),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroMetricCard(),
                    if (!_loading && _alerts.isNotEmpty) ...[
                      const SizedBox(height: 32),
                      _buildEarlyWarningSection(),
                    ],
                    const SizedBox(height: 32),
                    _buildStressLevelsSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 56, 24, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'RISKALA LITE',
                style: TextStyle(
                  fontFamily: 'NimbusSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brand.withValues(alpha: 0.5),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'HR DASHBOARD',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.brand,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.search,
                  size: 20,
                  color: AppColors.brand.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2F4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person,
                  size: 20,
                  color: AppColors.brand,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroMetricCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment(-0.7, -1),
          end: Alignment(0.7, 1),
          colors: [AppColors.accentLight, AppColors.accent],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.25),
            blurRadius: 25,
            offset: const Offset(0, 10),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Opacity(
                    opacity: 0.9,
                    child: const Text(
                      'TOTAL EMPLOYEES',
                      style: TextStyle(
                        fontFamily: 'NimbusSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        letterSpacing: 0.35,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  _loading
                      ? const SizedBox(
                          height: 48,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      : Text(
                          '$_totalEmployees',
                          style: const TextStyle(
                            fontFamily: 'NimbusSans',
                            fontSize: 48,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.groups, size: 32, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilter() {
    final hasRange = _dateRange != null;
    final label = hasRange
        ? '${_formatDate(_dateRange!.start)} – ${_formatDate(_dateRange!.end)}'
        : 'Filter Rentang Tanggal';

    return GestureDetector(
      onTap: _pickDateRange,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: hasRange ? const Color(0xFFE0F2F4) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hasRange ? AppColors.accent : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: AppColors.brand.withValues(alpha: hasRange ? 0.8 : 0.5),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'NimbusSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.brand.withValues(
                    alpha: hasRange ? 1.0 : 0.55,
                  ),
                ),
              ),
            ),
            if (hasRange)
              GestureDetector(
                onTap: _clearDateRange,
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: AppColors.brand.withValues(alpha: 0.5),
                ),
              )
            else
              Icon(
                Icons.keyboard_arrow_down,
                size: 18,
                color: AppColors.brand.withValues(alpha: 0.5),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarlyWarningSection() {
    final criticalCount = _alerts
        .where((a) => a['severity'] == 'critical')
        .length;
    final anonymousCount = _alerts.where((a) => a['anonymous'] == true).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Flexible(
              child: Text(
                'Perlu Perhatian',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brand,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${_alerts.length} karyawan',
                    style: const TextStyle(
                      fontFamily: 'NimbusSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFC4292E),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          criticalCount > 0
              ? '$criticalCount karyawan dengan stres tinggi berturut-turut — disarankan tindak lanjut segera.'
              : 'Karyawan dengan tren stres tinggi yang sebaiknya dipantau.',
          style: TextStyle(
            fontFamily: 'NimbusSans',
            fontSize: 13,
            height: 1.45,
            color: AppColors.brand.withValues(alpha: 0.6),
          ),
        ),
        if (anonymousCount > 0) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.brand.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: 15,
                  color: AppColors.brand.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$anonymousCount disembunyikan demi privasi — hanya terlihat sebagai sinyal divisi sampai mereka mengizinkan.',
                    style: TextStyle(
                      fontFamily: 'NimbusSans',
                      fontSize: 11.5,
                      height: 1.4,
                      color: AppColors.brand.withValues(alpha: 0.65),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        ...List.generate(_alerts.length, (i) {
          return Padding(
            padding: EdgeInsets.only(bottom: i == _alerts.length - 1 ? 0 : 12),
            child: _AlertCard(
              alert: _alerts[i],
              index: i,
              onTap: () {
                final division = _alerts[i]['division']?.toString() ?? '';
                if (division.isEmpty) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        HrDivisionDetailPage(divisionName: division),
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStressLevelsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Stress Levels Per Divisi',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.brand,
              ),
            ),
            Text(
              'LIVE UPDATES',
              style: TextStyle(
                fontFamily: 'NimbusSans',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildDateFilter(),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: AppColors.brand.withValues(alpha: 0.1),
                blurRadius: 25,
                offset: const Offset(0, 10),
                spreadRadius: -5,
              ),
            ],
          ),
          child: Column(
            children: [
              _buildChartLabels(),
              const SizedBox(height: 24),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.brand),
                  ),
                )
              else
                ...() {
                  final widgets = <Widget>[];
                  final orderedNames = [
                    ...divisionInfoList.map((d) => d.name),
                    ..._divisionStress.keys.where(
                      (name) => !divisionInfoList.any((d) => d.name == name),
                    ),
                  ];
                  for (var i = 0; i < orderedNames.length; i++) {
                    if (i > 0) widgets.add(const SizedBox(height: 20));
                    final name = orderedNames[i];
                    final score = _divisionStress[name] ?? 0.0;
                    widgets.add(
                      _buildBarRow(
                        name,
                        score,
                        suppressed: _divisionSuppressed[name] == true,
                      ),
                    );
                  }
                  return widgets;
                }(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChartLabels() {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            'DIVISION',
            style: TextStyle(
              fontFamily: 'NimbusSans',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.brand.withValues(alpha: 0.4),
              letterSpacing: -0.5,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['LOW', 'MODERATE', 'HIGH']
                  .map(
                    (l) => Text(
                      l,
                      style: TextStyle(
                        fontFamily: 'NimbusSans',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brand.withValues(alpha: 0.4),
                        letterSpacing: -0.5,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBarRow(
    String division,
    double percentage, {
    bool suppressed = false,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              division,
              style: const TextStyle(
                fontFamily: 'NimbusSans',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.brand,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (suppressed) ...[
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 13,
                    color: AppColors.brand.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  suppressed ? 'Privat' : '${(percentage * 100).round()}%',
                  style: TextStyle(
                    fontFamily: 'NimbusSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brand.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (suppressed)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: 15,
                  color: AppColors.brand.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Belum cukup data untuk menjaga anonimitas (min. $_minGroupSize).',
                    style: TextStyle(
                      fontFamily: 'NimbusSans',
                      fontSize: 11.5,
                      height: 1.35,
                      color: AppColors.brand.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            height: 12,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(9999),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9999),
                  gradient: const LinearGradient(
                    colors: [AppColors.accentLight, AppColors.accent],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _AlertCard extends StatefulWidget {
  const _AlertCard({
    required this.alert,
    required this.index,
    required this.onTap,
  });

  final Map<String, dynamic> alert;
  final int index;
  final VoidCallback onTap;

  @override
  State<_AlertCard> createState() => _AlertCardState();
}

class _AlertCardState extends State<_AlertCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    final delay = (widget.index * 70).clamp(0, 350);
    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted) _enter.forward();
    });
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  String _formatDate(String? iso) {
    if (iso == null) return '';
    final d = DateTime.tryParse(iso);
    if (d == null) return '';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${d.day} ${months[d.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final isCritical = widget.alert['severity'] == 'critical';
    final isAnonymous = widget.alert['anonymous'] == true;
    final name = isAnonymous
        ? 'Karyawan dirahasiakan'
        : (widget.alert['nama_user']?.toString() ?? '—');
    final division = widget.alert['division_suppressed'] == true
        ? 'Divisi dirahasiakan'
        : (widget.alert['division']?.toString() ?? '—');
    final score = widget.alert['latest_score']?.toString() ?? '–';
    final consecutive =
        (widget.alert['consecutive_high'] as num?)?.toInt() ?? 0;
    final date = _formatDate(widget.alert['latest_date']?.toString());

    final accent = isCritical ? AppColors.danger : AppColors.warning;
    final accentDeep = isCritical
        ? const Color(0xFFC4292E)
        : const Color(0xFFB7791F);
    final tintTop = isCritical
        ? const Color(0xFFFFF6F6)
        : const Color(0xFFFFFBF1);
    final tintBottom = isCritical
        ? const Color(0xFFFFEDED)
        : const Color(0xFFFFF4E2);
    final badgeLabel = isCritical ? 'KRITIS' : 'PANTAU';

    final curved = CurvedAnimation(parent: _enter, curve: Curves.easeOutCubic);

    return AnimatedBuilder(
      animation: curved,
      builder: (_, child) {
        final t = curved.value;
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 14 * (1 - t)),
            child: Transform.scale(scale: 0.98 + 0.02 * t, child: child),
          ),
        );
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.975 : 1.0,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [tintTop, tintBottom],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accent.withValues(alpha: 0.18)),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.10),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: isAnonymous
                      ? Icon(
                          Icons.lock_outline_rounded,
                          size: 20,
                          color: accentDeep,
                        )
                      : Text(
                          _initials(name),
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: accentDeep,
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          fontStyle: isAnonymous
                              ? FontStyle.italic
                              : FontStyle.normal,
                          color: isAnonymous
                              ? AppColors.brand.withValues(alpha: 0.55)
                              : AppColors.brand,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        division,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'NimbusSans',
                          fontSize: 12.5,
                          color: AppColors.brand.withValues(alpha: 0.55),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          Icon(
                            Icons.trending_up_rounded,
                            size: 13,
                            color: accentDeep,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$consecutive× tinggi berturut',
                            style: TextStyle(
                              fontFamily: 'NimbusSans',
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: accentDeep,
                            ),
                          ),
                          if (date.isNotEmpty) ...[
                            Text(
                              '  ·  $date',
                              style: TextStyle(
                                fontFamily: 'NimbusSans',
                                fontSize: 11.5,
                                color: AppColors.brand.withValues(alpha: 0.45),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        badgeLabel,
                        style: const TextStyle(
                          fontFamily: 'NimbusSans',
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: score,
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: accentDeep,
                            ),
                          ),
                          TextSpan(
                            text: '/40',
                            style: TextStyle(
                              fontFamily: 'NimbusSans',
                              fontSize: 11,
                              color: AppColors.brand.withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
