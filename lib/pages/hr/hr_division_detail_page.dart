import 'package:flutter/material.dart';
import '../../data/dummy_data.dart';

class HrDivisionDetailPage extends StatefulWidget {
  final String divisionName;
  const HrDivisionDetailPage({super.key, required this.divisionName});

  @override
  State<HrDivisionDetailPage> createState() => _HrDivisionDetailPageState();
}

class _HrDivisionDetailPageState extends State<HrDivisionDetailPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<EmployeeStressData> get _filteredEmployees {
    final employees = DummyStressData.byDivision(widget.divisionName);
    if (_searchQuery.isEmpty) return employees;
    final q = _searchQuery.toLowerCase();
    return employees
        .where((e) =>
            e.name.toLowerCase().contains(q) ||
            e.jobTitle.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // Header
          Container(
            color: const Color(0xFFF8F9FA).withValues(alpha: 0.8),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Icon(Icons.arrow_back_ios, size: 24, color: Color(0xFF245A72)),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'DIVISI ${widget.divisionName.toUpperCase()}',
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF245A72),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                    ClipOval(
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: const CircleAvatar(
                          backgroundColor: Color(0xFFE0F2F4),
                          child: Icon(Icons.person, color: Color(0xFF245A72), size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(9999),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: const InputDecoration(
                  hintText: 'Search employees...',
                  hintStyle: TextStyle(
                    fontFamily: 'NimbusSans',
                    fontSize: 14,
                    color: Color(0xFF9CA3AF),
                  ),
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(left: 16, right: 8),
                    child: Icon(Icons.search, size: 20, color: Color(0xFF9CA3AF)),
                  ),
                  prefixIconConstraints: BoxConstraints(minWidth: 44),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                ),
                style: const TextStyle(
                  fontFamily: 'NimbusSans',
                  fontSize: 14,
                  color: Color(0xFF245A72),
                ),
              ),
            ),
          ),

          // Employee list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 140),
              itemCount: _filteredEmployees.length,
              separatorBuilder: (_, _) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final emp = _filteredEmployees[index];
                return _buildEmployeeCard(emp);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(EmployeeStressData emp) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xFFF3F4F6),
            child: Icon(Icons.person, color: Color(0xFF245A72), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  emp.name,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF245A72),
                  ),
                ),
                Text(
                  emp.jobTitle.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'NimbusSans',
                    fontSize: 10,
                    color: Color(0xFF6B7280),
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          _buildStressBadge(emp.stressLevel),
        ],
      ),
    );
  }

  Widget _buildStressBadge(String level) {
    Color bgColor;
    Color textColor;
    String label;

    switch (level) {
      case 'low':
        bgColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF166534);
        label = 'LOW';
      case 'moderate':
        bgColor = const Color(0xFFFEF9C3);
        textColor = const Color(0xFF854D0E);
        label = 'MODERATE';
      case 'high':
        bgColor = const Color(0xFFFCE7F3);
        textColor = const Color(0xFF9D174D);
        label = 'HIGH';
      default:
        bgColor = const Color(0xFFF1F5F9);
        textColor = const Color(0xFF64748B);
        label = level.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
    );
  }
}
