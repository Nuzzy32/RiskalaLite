import 'package:flutter/material.dart';
import '../../data/dummy_data.dart';
import '../../widgets/bottom_nav.dart';

class HrHomePage extends StatefulWidget {
  final bool showNav;
  const HrHomePage({super.key, this.showNav = true});

  @override
  State<HrHomePage> createState() => _HrHomePageState();
}

class _HrHomePageState extends State<HrHomePage> {
  void _navigateTo(String id) {
    if (id == 'report') {
      Navigator.pushReplacementNamed(context, '/hr/report');
    } else if (id == 'account') {
      Navigator.pushReplacementNamed(context, '/hr/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: Stack(
        children: [
          // Scrollable content
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(),
                // Main content
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
          // Bottom Nav
          if (widget.showNav)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BottomNav(active: 'dashboard', onTap: _navigateTo, items: BottomNav.hrItems),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Row(
            children: [
              // Title section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'RISKALA LITE',
                      style: TextStyle(
                        fontFamily: 'NimbusSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF61D1DB),
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      'HR DASHBOARD',
                      style: TextStyle(
                        fontFamily: 'NimbusSans',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF245A72),
                      ),
                    ),
                  ],
                ),
              ),
              // Search button
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.search,
                  size: 24,
                  color: const Color(0xFF245A72),
                ),
              ),
              const SizedBox(width: 16),
              // Avatar
              ClipOval(
                child: Container(
                  width: 36,
                  height: 36,
                  color: const Color(0xFFE0F2F4),
                  child: const Icon(Icons.person, color: Color(0xFF245A72), size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroMetricCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment(-0.7, -1),
          end: Alignment(0.7, 1),
          colors: [Color(0xFFB3F3F4), Color(0xFF61D1DB)],
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
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Decorative circle
          Positioned(
            top: -64,
            right: -64,
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text content
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Opacity(
                        opacity: 0.9,
                        child: Text(
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
                      Text(
                        '${DummyStressData.totalEmployees}',
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
                  // Icon container
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.groups,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStressLevelsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: const [
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
        const SizedBox(height: 16),
        // Chart card
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
              // Chart labels
              _buildChartLabels(),
              const SizedBox(height: 24),
              // Bars — driven by dummy data
              ...() {
                final avgStress = DummyStressData.divisionAvgStress;
                final divisions = divisionInfoList.map((d) => d.name).toList();
                final widgets = <Widget>[];
                for (var i = 0; i < divisions.length; i++) {
                  if (i > 0) widgets.add(const SizedBox(height: 20));
                  final name = divisions[i];
                  final score = (avgStress[name] ?? 0) / 100;
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
          child: Text(
            'DIVISION',
            style: TextStyle(
              fontFamily: 'NimbusSans',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF245A72).withValues(alpha: 0.4),
              letterSpacing: -0.5,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'LOW',
                  style: TextStyle(
                    fontFamily: 'NimbusSans',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF245A72).withValues(alpha: 0.4),
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'MODERATE',
                  style: TextStyle(
                    fontFamily: 'NimbusSans',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF245A72).withValues(alpha: 0.4),
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'HIGH',
                  style: TextStyle(
                    fontFamily: 'NimbusSans',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF245A72).withValues(alpha: 0.4),
                    letterSpacing: -0.5,
                  ),
                ),
              ],
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
            Text(
              division,
              style: const TextStyle(
                fontFamily: 'NimbusSans',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF245A72),
              ),
            ),
            Text(
              '${(percentage * 100).round()}%',
              style: TextStyle(
                fontFamily: 'NimbusSans',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF245A72).withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
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
                  colors: [Color(0xFFB3F3F4), Color(0xFF61D1DB)],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
