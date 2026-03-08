import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final String active;
  final Function(String) onTap;

  const BottomNav({
    super.key,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(id: 'report', label: 'REPORT', icon: Icons.description_outlined),
      _NavItem(id: 'home', label: 'HOME', icon: Icons.home_outlined),
      _NavItem(id: 'account', label: 'ACCOUNT', icon: Icons.person_outline),
    ];

    return Container(
      height: 112,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.map((item) {
          final isActive = active == item.id;
          return GestureDetector(
            onTap: () => onTap(item.id),
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isActive)
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5DC),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFC7F9CC).withValues(alpha: 0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(item.icon, color: const Color(0xFF245A72), size: 22),
                  )
                else
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: Icon(item.icon, color: const Color(0xFF94A3B8), size: 22),
                  ),
                const SizedBox(height: 4),
                Text(
                  item.label,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: isActive ? const Color(0xFF245A72) : const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _NavItem {
  final String id;
  final String label;
  final IconData icon;
  _NavItem({required this.id, required this.label, required this.icon});
}
