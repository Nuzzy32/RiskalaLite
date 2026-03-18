import 'package:flutter/material.dart';
import '../../widgets/bottom_nav.dart';
import 'home_page.dart';
import 'report_page.dart';
import 'profile_page.dart';

class MainShell extends StatefulWidget {
  final int initialTab;

  const MainShell({super.key, this.initialTab = 1});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _currentIndex;
  static const _tabIds = ['report', 'home', 'account'];

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
          // Page content with iOS-like slide transition
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
          // Persistent bottom nav
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomNav(
              active: _tabIds[_currentIndex],
              onTap: _onTabTap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage() {
    switch (_currentIndex) {
      case 0:
        return const ReportPage(key: ValueKey('report'), showNav: false);
      case 2:
        return const ProfilePage(key: ValueKey('profile'), showNav: false);
      default:
        return const HomePage(key: ValueKey('home'), showNav: false);
    }
  }
}
