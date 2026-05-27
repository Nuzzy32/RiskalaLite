import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'hr_report_detail_page.dart';

class HrReportPage extends StatefulWidget {
  final bool showNav;
  const HrReportPage({super.key, this.showNav = true});

  @override
  State<HrReportPage> createState() => _HrReportPageState();
}

class _HrReportPageState extends State<HrReportPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String _selectedDivision = 'All';
  String _selectedRisk = 'All';
  DateTimeRange? _dateRange;

  bool _loading = true;
  String? _error;

  List<_Submission> _allSubmissions = [];
  List<_EmployeeReport> _allEmployeeReports = [];
  List<String> _divisions = ['All'];

  static const _categories = {
    1: 'Beban Kerja Berlebihan',
    2: 'Konflik dengan Rekan Kerja',
    3: 'Masalah Manajemen',
    4: 'Work-Life Balance',
    5: 'Lingkungan Kerja',
    6: 'Lainnya',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final assessments = await ApiService.getAssessmentHistory();
      final reports = await ApiService.getReports();

      final divisionsSet = <String>{};

      _allSubmissions = assessments.map((a) {
        final user = a['user'] as Map<String, dynamic>?;
        final division = user?['department']?.toString() ?? '-';
        divisionsSet.add(division);
        return _Submission(
          idUser: a['id_user']?.toString() ?? '',
          name: (user?['nama_user']?.toString().split(' ').first ?? '-').toUpperCase(),
          fullName: user?['nama_user']?.toString() ?? '-',
          division: division,
          totalScore: (a['total_score'] as num?)?.toInt() ?? 0,
          kategoriStres: (a['kategori_stres'] as num?)?.toInt() ?? 1,
          date: DateTime.tryParse(a['tgl_SA']?.toString() ?? '') ?? DateTime.now(),
        );
      }).toList();

      _allEmployeeReports = reports.map((r) {
        final user = r['user'] as Map<String, dynamic>?;
        final division = user?['department']?.toString() ?? '-';
        divisionsSet.add(division);
        return _EmployeeReport(
          idReport: r['id_report']?.toString() ?? '',
          idUser: r['id_user']?.toString() ?? '',
          employeeName: user?['nama_user']?.toString() ?? '-',
          division: division,
          kategori: (r['kategori'] as num?)?.toInt() ?? 6,
          deskripsi: r['deskripsi']?.toString() ?? '',
          tingkatStres: (r['tingkat_stres'] as num?)?.toInt() ?? 1,
          status: r['status']?.toString() ?? 'pending',
          hrResponse: r['hr_response']?.toString(),
          psikolog: r['psikolog'] is Map<String, dynamic>
              ? r['psikolog'] as Map<String, dynamic>
              : null,
          date: DateTime.tryParse(r['tgl_IR']?.toString() ?? '') ?? DateTime.now(),
        );
      }).toList();

      _divisions = ['All', ...divisionsSet.toList()..sort()];

      setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  String _riskFromKategori(int k) {
    if (k >= 3) return 'high';
    if (k == 2) return 'moderate';
    return 'low';
  }

  String _riskFromStress(int s) {
    if (s >= 4) return 'high';
    if (s == 3) return 'moderate';
    return 'low';
  }

  List<_Submission> get _filteredSubmissions {
    return _allSubmissions.where((s) {
      if (_selectedDivision != 'All' && s.division != _selectedDivision) return false;
      if (_selectedRisk != 'All' && _riskFromKategori(s.kategoriStres) != _selectedRisk) return false;
      if (_dateRange != null) {
        if (s.date.isBefore(_dateRange!.start) || s.date.isAfter(_dateRange!.end.add(const Duration(days: 1)))) return false;
      }
      return true;
    }).toList();
  }

  List<_EmployeeReport> get _filteredEmployeeReports {
    return _allEmployeeReports.where((r) {
      if (_selectedDivision != 'All' && r.division != _selectedDivision) return false;
      if (_selectedRisk != 'All' && _riskFromStress(r.tingkatStres) != _selectedRisk) return false;
      if (_dateRange != null) {
        if (r.date.isBefore(_dateRange!.start) || r.date.isAfter(_dateRange!.end.add(const Duration(days: 1)))) return false;
      }
      return true;
    }).toList();
  }

  String _formatDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[d.month - 1]} ${d.day}';
  }

  Future<void> _pickDateRange() async {
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2027, 12, 31),
      initialDateRange: _dateRange ?? DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 30)),
        end: DateTime.now(),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF245A72),
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (result != null) setState(() => _dateRange = result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildFilters(),
            const SizedBox(height: 12),
            _buildDateRange(),
            const SizedBox(height: 16),
            _buildTabs(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
                  child: child,
                ),
                child: _loading
                    ? const Center(key: ValueKey('loading'), child: CircularProgressIndicator(color: Color(0xFF245A72)))
                    : _error != null
                        ? _buildErrorState()
                        : RefreshIndicator(
                            key: const ValueKey('content'),
                            onRefresh: _loadData,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _buildQuestionnaireTab(),
                                _buildLaporanEmployeeTab(),
                              ],
                            ),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Color(0xFF9D174D)),
          const SizedBox(height: 12),
          Text(_error ?? 'Terjadi kesalahan',
              style: const TextStyle(fontFamily: 'NimbusSans', color: Color(0xFF245A72))),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _loadData, child: const Text('Coba lagi')),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment(-0.7, -1),
          end: Alignment(0.7, 1),
          colors: [Color(0xFFB3F3F4), Color(0xFF61D1DB)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF245A72).withValues(alpha: 0.1),
            blurRadius: 25,
            offset: const Offset(0, 10),
            spreadRadius: -5,
          ),
        ],
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
                  color: const Color(0xFF245A72).withValues(alpha: 0.6),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'LAPORAN\nEMPLOYEE',
                style: TextStyle(
                  fontFamily: 'NimbusSans',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF245A72),
                  height: 1.2,
                ),
              ),
            ],
          ),
          ClipOval(
            child: Container(
              width: 44,
              height: 44,
              color: const Color(0xFFE0F2F4),
              child: const Icon(Icons.person, color: Color(0xFF245A72), size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final risks = ['All', 'low', 'moderate', 'high'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _buildDropdown(
              label: 'Filter by Divisi',
              value: _selectedDivision,
              items: _divisions,
              onChanged: (v) => setState(() => _selectedDivision = v ?? 'All'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildDropdown(
              label: 'Filter by Risk Level',
              value: _selectedRisk,
              items: risks,
              displayMap: {'low': 'Low', 'moderate': 'Moderate', 'high': 'High', 'All': 'All'},
              onChanged: (v) => setState(() => _selectedRisk = v ?? 'All'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    Map<String, String>? displayMap,
    required ValueChanged<String?> onChanged,
  }) {
    final safeValue = items.contains(value) ? value : items.first;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: safeValue,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: const Color(0xFF245A72).withValues(alpha: 0.5), size: 20),
          style: const TextStyle(
            fontFamily: 'NimbusSans',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF245A72),
          ),
          items: items.map((item) {
            final display = displayMap?[item] ?? item;
            return DropdownMenuItem(value: item, child: Text(display, overflow: TextOverflow.ellipsis));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDateRange() {
    final hasRange = _dateRange != null;
    final label = hasRange
        ? '${_formatDate(_dateRange!.start)} – ${_formatDate(_dateRange!.end)}'
        : 'Pilih Rentang Tanggal';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: _pickDateRange,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: hasRange ? const Color(0xFFE0F2F4) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasRange ? const Color(0xFF61D1DB) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: 18,
                  color: const Color(0xFF245A72).withValues(alpha: hasRange ? 0.8 : 0.5)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'NimbusSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF245A72).withValues(alpha: hasRange ? 1.0 : 0.5),
                  ),
                ),
              ),
              if (hasRange)
                GestureDetector(
                  onTap: () => setState(() => _dateRange = null),
                  child: Icon(Icons.close, size: 16,
                      color: const Color(0xFF245A72).withValues(alpha: 0.5)),
                )
              else
                Icon(Icons.keyboard_arrow_down, size: 20,
                    color: const Color(0xFF245A72).withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE8F4F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: const Color(0xFF245A72),
            borderRadius: BorderRadius.circular(10),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFF245A72),
          labelStyle: const TextStyle(
            fontFamily: 'NimbusSans',
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'NimbusSans',
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: 'Questionnaire'),
            Tab(text: 'Laporan Employee'),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionnaireTab() {
    final submissions = _filteredSubmissions;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 140),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${submissions.length} Submission',
            style: TextStyle(
              fontFamily: 'NimbusSans',
              fontSize: 13,
              color: const Color(0xFF245A72).withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                _tableHeader('EMPLOYEE', flex: 3),
                _tableHeader('DIVISION', flex: 3),
                _tableHeader('RISK', flex: 2),
                _tableHeader('DATE', flex: 2),
              ],
            ),
          ),
          if (submissions.isEmpty)
            _buildEmptyState('Tidak ada data questionnaire\nsesuai filter yang dipilih')
          else
            ...submissions.map((s) => _buildSubmissionRow(s)),
        ],
      ),
    );
  }

  Widget _buildLaporanEmployeeTab() {
    final reports = _filteredEmployeeReports;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 140),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${reports.length} Laporan',
            style: TextStyle(
              fontFamily: 'NimbusSans',
              fontSize: 13,
              color: const Color(0xFF245A72).withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 16),
          if (reports.isEmpty)
            _buildEmptyState('Tidak ada laporan\nsesuai filter yang dipilih')
          else
            ...reports.map((r) => _buildEmployeeReportCard(r)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 48,
                color: const Color(0xFF245A72).withValues(alpha: 0.2)),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'NimbusSans',
                fontSize: 14,
                color: const Color(0xFF245A72).withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tableHeader(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'NimbusSans',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF245A72).withValues(alpha: 0.4),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSubmissionRow(_Submission s) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HrReportDetailPage(
              employeeName: s.fullName,
              division: s.division,
              riskLevel: _riskFromKategori(s.kategoriStres),
              stressScore: ((s.totalScore / 50) * 100).clamp(0, 100).round(),
              reportDate: _formatDate(s.date),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: const Color(0xFF245A72).withValues(alpha: 0.06)),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                s.name,
                style: const TextStyle(
                  fontFamily: 'NimbusSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF245A72),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                s.division,
                style: TextStyle(
                  fontFamily: 'NimbusSans',
                  fontSize: 13,
                  color: const Color(0xFF245A72).withValues(alpha: 0.7),
                ),
              ),
            ),
            Expanded(flex: 2, child: _buildRiskBadge(_riskFromKategori(s.kategoriStres))),
            Expanded(
              flex: 2,
              child: Text(
                _formatDate(s.date),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'NimbusSans',
                  fontSize: 12,
                  color: const Color(0xFF245A72).withValues(alpha: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeReportCard(_EmployeeReport r) {
    Color statusBg;
    Color statusColor;
    String statusLabel;
    switch (r.status) {
      case 'selesai':
        statusBg = const Color(0xFFDCFCE7);
        statusColor = const Color(0xFF166534);
        statusLabel = 'Selesai';
      case 'proses':
        statusBg = const Color(0xFFFEF9C3);
        statusColor = const Color(0xFF854D0E);
        statusLabel = 'Diproses';
      default:
        statusBg = const Color(0xFFFCE7F3);
        statusColor = const Color(0xFF9D174D);
        statusLabel = 'Pending';
    }

    return GestureDetector(
      onTap: () async {
        final updated = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => HrReportDetailPage(
              employeeName: r.employeeName,
              division: r.division,
              riskLevel: _riskFromStress(r.tingkatStres),
              stressScore: (r.tingkatStres * 20).clamp(0, 100),
              reportDate: _formatDate(r.date),
              reportId: r.idReport,
              kategori: _categories[r.kategori] ?? 'Lainnya',
              deskripsi: r.deskripsi,
              status: r.status,
              hrResponse: r.hrResponse,
              tingkatStres: r.tingkatStres,
              psikolog: r.psikolog,
            ),
          ),
        );
        if (updated == true) _loadData();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF245A72).withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.employeeName,
                        style: const TextStyle(
                          fontFamily: 'NimbusSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF245A72),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        r.division,
                        style: TextStyle(
                          fontFamily: 'NimbusSans',
                          fontSize: 12,
                          color: const Color(0xFF245A72).withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontFamily: 'NimbusSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2F4),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _categories[r.kategori] ?? 'Lainnya',
                    style: const TextStyle(
                      fontFamily: 'NimbusSans',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF245A72),
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(r.date),
                  style: TextStyle(
                    fontFamily: 'NimbusSans',
                    fontSize: 12,
                    color: const Color(0xFF245A72).withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              r.deskripsi,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'NimbusSans',
                fontSize: 13,
                height: 1.5,
                color: const Color(0xFF245A72).withValues(alpha: 0.7),
              ),
            ),
            if (r.psikolog != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.psychology_outlined,
                        size: 14, color: Color(0xFF166534)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ditangani: ${r.psikolog!['nama'] ?? '-'}',
                            style: const TextStyle(
                              fontFamily: 'NimbusSans',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF166534),
                            ),
                          ),
                          if ((r.psikolog!['spesialisasi']?.toString().isNotEmpty ?? false))
                            Text(
                              r.psikolog!['spesialisasi'].toString(),
                              style: TextStyle(
                                fontFamily: 'NimbusSans',
                                fontSize: 11,
                                color: const Color(0xFF166534).withValues(alpha: 0.75),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRiskBadge(String level) {
    Color bgColor;
    Color textColor;
    String label;

    switch (level) {
      case 'low':
        bgColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF166534);
        label = 'Low';
      case 'moderate':
        bgColor = const Color(0xFFFEF9C3);
        textColor = const Color(0xFF854D0E);
        label = 'Mod';
      case 'high':
        bgColor = const Color(0xFFFCE7F3);
        textColor = const Color(0xFF9D174D);
        label = 'High';
      default:
        bgColor = const Color(0xFFF1F5F9);
        textColor = const Color(0xFF64748B);
        label = level;
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'NimbusSans',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: textColor,
            letterSpacing: 0.25,
          ),
        ),
      ),
    );
  }
}

class _Submission {
  final String idUser;
  final String name;
  final String fullName;
  final String division;
  final int totalScore;
  final int kategoriStres;
  final DateTime date;
  const _Submission({
    required this.idUser,
    required this.name,
    required this.fullName,
    required this.division,
    required this.totalScore,
    required this.kategoriStres,
    required this.date,
  });
}

class _EmployeeReport {
  final String idReport;
  final String idUser;
  final String employeeName;
  final String division;
  final int kategori;
  final String deskripsi;
  final int tingkatStres;
  final String status;
  final String? hrResponse;
  final Map<String, dynamic>? psikolog;
  final DateTime date;
  const _EmployeeReport({
    required this.idReport,
    required this.idUser,
    required this.employeeName,
    required this.division,
    required this.kategori,
    required this.deskripsi,
    required this.tingkatStres,
    required this.status,
    required this.hrResponse,
    required this.psikolog,
    required this.date,
  });
}
