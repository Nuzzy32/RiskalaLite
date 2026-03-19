import 'package:flutter/material.dart';
import '../../data/dummy_data.dart';
import 'hr_report_detail_page.dart';

class HrReportPage extends StatefulWidget {
  final bool showNav;
  const HrReportPage({super.key, this.showNav = true});

  @override
  State<HrReportPage> createState() => _HrReportPageState();
}

class _HrReportPageState extends State<HrReportPage> {
  String _selectedDivision = 'All';
  String _selectedRisk = 'All';

  // Dummy submission data
  static final List<_Submission> _allSubmissions = DummyStressData.allStressData.map((e) {
    // Generate a dummy date based on index
    final idx = DummyStressData.allStressData.indexOf(e);
    final day = 28 - (idx % 10);
    final month = day > 20 ? 'Oct' : 'Oct';
    return _Submission(
      name: e.name.split(' ').first.toUpperCase(),
      division: e.division,
      riskLevel: e.stressLevel,
      date: '$month $day',
    );
  }).toList();

  List<_Submission> get _filteredSubmissions {
    return _allSubmissions.where((s) {
      if (_selectedDivision != 'All' && s.division != _selectedDivision) return false;
      if (_selectedRisk != 'All' && s.riskLevel != _selectedRisk) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 140),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildFilters(),
              const SizedBox(height: 12),
              _buildDateRange(),
              const SizedBox(height: 32),
              _buildSubmissionsTable(),
            ],
          ),
        ),
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
    final divisions = ['All', ...DummyStressData.divisions];
    final risks = ['All', 'low', 'moderate', 'high'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Division filter
          Expanded(
            child: _buildDropdown(
              label: 'Filter by Divisi',
              value: _selectedDivision,
              items: divisions,
              onChanged: (v) => setState(() => _selectedDivision = v ?? 'All'),
            ),
          ),
          const SizedBox(width: 12),
          // Risk filter
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
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
            return DropdownMenuItem(value: item, child: Text(display));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDateRange() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined, size: 18, color: const Color(0xFF245A72).withValues(alpha: 0.5)),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Date Range: Oct 1 – Oct 31, 2023',
                style: TextStyle(
                  fontFamily: 'NimbusSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF245A72),
                ),
              ),
            ),
            Icon(Icons.keyboard_arrow_down, size: 20, color: const Color(0xFF245A72).withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmissionsTable() {
    final submissions = _filteredSubmissions;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Questionnaire\nSubmissions',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF245A72),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 20),
          // Table header
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                _tableHeader('EMPLOYEE', flex: 3),
                _tableHeader('DIVISION', flex: 3),
                _tableHeader('RISK', flex: 2),
                _tableHeader('DATE', flex: 2),
              ],
            ),
          ),
          // Table rows
          ...submissions.map((s) => _buildSubmissionRow(s)),
        ],
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
        // Find the matching stress data
        final stressData = DummyStressData.allStressData.firstWhere(
          (e) => e.name.split(' ').first.toUpperCase() == s.name && e.division == s.division,
          orElse: () => DummyStressData.allStressData.first,
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HrReportDetailPage(
              employee: stressData,
              reportDate: s.date,
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
            Expanded(
              flex: 2,
              child: _buildRiskBadge(s.riskLevel),
            ),
            Expanded(
              flex: 2,
              child: Text(
                s.date,
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
  final String name;
  final String division;
  final String riskLevel;
  final String date;
  const _Submission({
    required this.name,
    required this.division,
    required this.riskLevel,
    required this.date,
  });
}
