import 'package:flutter/material.dart';
import '../../widgets/bottom_nav.dart';
import 'hr_home_page.dart';
import 'hr_employees_page.dart';
import '../employee/report_page.dart';
import '../employee/profile_page.dart';

class HrMainShell extends StatefulWidget {
  final int initialTab;

  const HrMainShell({super.key, this.initialTab = 0});

  @override
  State<HrMainShell> createState() => _HrMainShellState();
}

class _HrMainShellState extends State<HrMainShell> {
  late int _currentIndex;
  static const _tabIds = ['dashboard', 'employees', 'report', 'account'];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  void _onTabTap(String id) {
    final index = _tabIds.indexOf(id);
    if (index != -1 && index != _currentIndex) {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.05, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: _buildPage(),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomNav(
              active: _tabIds[_currentIndex],
              onTap: _onTabTap,
              items: BottomNav.hrItems,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage() {
    switch (_currentIndex) {
      case 1:
        return const HrEmployeesPage(key: ValueKey('employees'), showNav: false);
      case 2:
        return const ReportPage(key: ValueKey('report'), showNav: false);
      case 3:
        return const ProfilePage(key: ValueKey('profile'), showNav: false);
      default:
        return const HrHomePage(key: ValueKey('hr_home'), showNav: false);
    }
  }
}
