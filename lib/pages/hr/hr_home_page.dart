import 'package:flutter/material.dart';
import '../../data/division_info.dart';
import '../../services/api_service.dart';

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
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _loading = true; _error = null; });
    try {
      final employees = await ApiService.getEmployees();
      final divisions = await ApiService.getStressDivisions(
        startDate: _dateRange?.start,
        endDate: _dateRange?.end,
      );

      final stressMap = <String, double>{};
      for (final d in divisions) {
        final name = d['division']?.toString() ?? '';
        final avg = (d['avg_score'] as num?)?.toDouble() ?? 0;
        stressMap[name] = (avg / 50).clamp(0.0, 1.0);
      }

      setState(() {
        _totalEmployees = employees.length;
        _divisionStress = stressMap;
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
      initialDateRange: _dateRange ??
          DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 30)),
            end: DateTime.now(),
          ),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF245A72),
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
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
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
                      const Icon(Icons.error_outline, color: Color(0xFF9D174D), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_error!,
                            style: const TextStyle(
                                fontFamily: 'NimbusSans',
                                fontSize: 13,
                                color: Color(0xFF9D174D))),
                      ),
                      GestureDetector(
                        onTap: _loadData,
                        child: const Text('Retry',
                            style: TextStyle(
                                fontFamily: 'NimbusSans',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF9D174D))),
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
                  color: const Color(0xFF245A72).withValues(alpha: 0.5),
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
                  color: Color(0xFF245A72),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.search, size: 20,
                    color: const Color(0xFF245A72).withValues(alpha: 0.6)),
              ),
              const SizedBox(width: 8),
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2F4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person, size: 20, color: Color(0xFF245A72)),
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
          colors: [Color(0xFFB3F3F4), Color(0xFF61D1DB)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF61D1DB).withValues(alpha: 0.25),
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
                          child: Center(child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2)))
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
              color: hasRange
                  ? const Color(0xFF61D1DB)
                  : const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 16,
                color: const Color(0xFF245A72)
                    .withValues(alpha: hasRange ? 0.8 : 0.5)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'NimbusSans', fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF245A72)
                      .withValues(alpha: hasRange ? 1.0 : 0.55),
                ),
              ),
            ),
            if (hasRange)
              GestureDetector(
                onTap: _clearDateRange,
                child: Icon(Icons.close,
                    size: 16,
                    color: const Color(0xFF245A72).withValues(alpha: 0.5)),
              )
            else
              Icon(Icons.keyboard_arrow_down,
                  size: 18,
                  color: const Color(0xFF245A72).withValues(alpha: 0.5)),
          ],
        ),
      ),
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
                color: Color(0xFF245A72),
              ),
            ),
            Text(
              'LIVE UPDATES',
              style: TextStyle(
                fontFamily: 'NimbusSans',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF61D1DB),
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
                color: const Color(0xFF245A72).withValues(alpha: 0.1),
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
                  child: Center(child: CircularProgressIndicator(color: Color(0xFF245A72))),
                )
              else
                ...() {
                  final widgets = <Widget>[];
                  for (var i = 0; i < divisionInfoList.length; i++) {
                    if (i > 0) widgets.add(const SizedBox(height: 20));
                    final name = divisionInfoList[i].name;
                    final score = _divisionStress[name] ?? 0.0;
                    widgets.add(_buildBarRow(name, score));
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
          child: Text('DIVISION',
              style: TextStyle(
                  fontFamily: 'NimbusSans', fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF245A72).withValues(alpha: 0.4),
                  letterSpacing: -0.5)),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['LOW', 'MODERATE', 'HIGH'].map((l) => Text(l,
                  style: TextStyle(
                      fontFamily: 'NimbusSans', fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF245A72).withValues(alpha: 0.4),
                      letterSpacing: -0.5))).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBarRow(String division, double percentage) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(division,
                style: const TextStyle(
                    fontFamily: 'NimbusSans', fontSize: 12,
                    fontWeight: FontWeight.w700, color: Color(0xFF245A72))),
            Text('${(percentage * 100).round()}%',
                style: TextStyle(
                    fontFamily: 'NimbusSans', fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF245A72).withValues(alpha: 0.5))),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 12,
          width: double.infinity,
          decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(9999)),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9999),
                gradient: const LinearGradient(
                    colors: [Color(0xFFB3F3F4), Color(0xFF61D1DB)]),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
