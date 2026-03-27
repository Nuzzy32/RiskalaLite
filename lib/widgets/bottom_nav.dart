import 'package:flutter/material.dart';

class NavItem {
  final String id;
  final String label;
  final IconData icon;
  const NavItem({required this.id, required this.label, required this.icon});
}

class BottomNav extends StatefulWidget {
  final String active;
  final Function(String) onTap;
  final List<NavItem>? items;

  const BottomNav({
    super.key,
    required this.active,
    required this.onTap,
    this.items,
  });

  // Default items for employee
  static const defaultItems = [
    NavItem(id: 'report', label: 'REPORT', icon: Icons.description_outlined),
    NavItem(id: 'home', label: 'HOME', icon: Icons.home_outlined),
    NavItem(id: 'analytics', label: 'ANALYTICS', icon: Icons.bar_chart_outlined),
    NavItem(id: 'account', label: 'ACCOUNT', icon: Icons.person_outline),
  ];

  // HR items (4 tabs matching Figma design)
  static const hrItems = [
    NavItem(id: 'dashboard', label: 'DASHBOARD', icon: Icons.home_outlined),
    NavItem(id: 'employees', label: 'EMPLOYEES', icon: Icons.groups_outlined),
    NavItem(id: 'report', label: 'REPORTS', icon: Icons.description_outlined),
    NavItem(id: 'account', label: 'PROFILE', icon: Icons.person_outline),
  ];

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _positionAnimation;
  late Animation<double> _glowAnimation;

  List<NavItem> get _items => widget.items ?? BottomNav.defaultItems;

  int get _activeIndex => _items.indexWhere((e) => e.id == widget.active);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _positionAnimation = AlwaysStoppedAnimation(_activeIndex.toDouble());
    _glowAnimation = const AlwaysStoppedAnimation(1.0);
  }

  @override
  void didUpdateWidget(BottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active) {
      final oldItems = oldWidget.items ?? BottomNav.defaultItems;
      final oldIndex = oldItems.indexWhere((e) => e.id == oldWidget.active);
      final newIndex = _activeIndex;

      _positionAnimation =
          Tween<double>(
            begin: oldIndex.toDouble(),
            end: newIndex.toDouble(),
          ).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
          );

      _glowAnimation = TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 2.0), weight: 40),
        TweenSequenceItem(tween: Tween(begin: 2.0, end: 1.0), weight: 60),
      ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bottomSpacing = 0.0;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        final pos = _positionAnimation.value;
        final glow = _glowAnimation.value;

        return Padding(
          padding: EdgeInsets.only(bottom: bottomSpacing),
          child: LayoutBuilder(
          builder: (context, outerConstraints) {
            // We need the full available width to compute positions
            final barWidth = outerConstraints.maxWidth - 48; // minus horizontal margin
            const hPad = 10.0;
            final rowWidth = barWidth - hPad * 2;
            final itemWidth = rowWidth / _items.length;
            final centerX = hPad + pos * itemWidth + itemWidth / 2;
            const bubbleSize = 50.0;
            final bubbleLeft = (centerX - bubbleSize / 2).clamp(
              hPad + 4,
              barWidth - bubbleSize - hPad - 4,
            );

            return SizedBox(
              height: 82 + 40, // bar + glow area below
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Tubelight glow cone (below the bar)
                  Positioned(
                    bottom: 0,
                    left: 24 + centerX - 45,
                    child: Container(
                      width: 90,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.topCenter,
                          radius: 1.2,
                          colors: [
                            const Color(0xFF8EEDF5).withValues(alpha: 0.35 * glow),
                            const Color(0xFF61D1DB).withValues(alpha: 0.12 * glow),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.4, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // The main bar
                  Positioned(
                    top: 0,
                    left: 24,
                    right: 24,
                    height: 82,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF61C2D4),
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF61C2D4).withValues(alpha: 0.30),
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Subtle gradient overlay
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.white.withValues(alpha: 0.10),
                                    Colors.transparent,
                                    const Color(0xFF2F9EB3).withValues(alpha: 0.08),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Active bubble
                          Positioned(
                            top: (82 - bubbleSize) / 2,
                            left: bubbleLeft,
                            child: Container(
                              width: bubbleSize,
                              height: bubbleSize,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF2A8FA5).withValues(alpha: 0.15 * glow),
                                    blurRadius: 14 * glow,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Nav items
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: hPad),
                            child: Row(
                              children: List.generate(_items.length, (i) {
                                final item = _items[i];
                                final isActive = i == _activeIndex;
                                final distance = (pos - i).abs();
                                final proximity = (1.0 - distance).clamp(0.0, 1.0);

                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () => widget.onTap(item.id),
                                    behavior: HitTestBehavior.opaque,
                                    child: _buildNavItem(item, isActive, proximity),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Tubelight bar (bottom edge of the navbar)
                  Positioned(
                    top: 82 - 2.5,
                    left: 24 + centerX - 20,
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(3),
                          topRight: Radius.circular(3),
                        ),
                        color: Colors.white,
                        boxShadow: [
                          // Intense close glow
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.95),
                            blurRadius: 6 * glow,
                            spreadRadius: 1 * glow,
                          ),
                          // Wide soft glow
                          BoxShadow(
                            color: const Color(0xFF8EEDF5).withValues(alpha: 0.7),
                            blurRadius: 16 * glow,
                            spreadRadius: 2,
                          ),
                          // Extra wide ambient
                          BoxShadow(
                            color: const Color(0xFF61D1DB).withValues(alpha: 0.3),
                            blurRadius: 30 * glow,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        );
      },
    );
  }

  Widget _buildNavItem(NavItem item, bool isActive, double proximity) {
    const activeColor = Color(0xFF61C2D4);
    final inactiveColor = Colors.white;
    final iconColor = Color.lerp(inactiveColor, activeColor, proximity)!;

    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        width: 60,
        height: 56,
        alignment: Alignment.center,
        child: Icon(item.icon, color: iconColor, size: isActive ? 26 : 24),
      ),
    );
  }
}
