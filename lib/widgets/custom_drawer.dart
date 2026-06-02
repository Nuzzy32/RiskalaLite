import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import 'crisis_sheet.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  static const _primaryColor = AppColors.accentLight;
  static const _secondaryColor = AppColors.accent;
  static const _textColor = AppColors.brand;
  static const _bgColor = Color(0xFFF8F9FA);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: _bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(32)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 8),
            // Menu items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                children: [
                  _DrawerItem(
                    icon: Icons.home_outlined,
                    label: 'Home',
                    onTap: () => _navigateTo(context, '/home'),
                  ),
                  _DrawerItem(
                    icon: Icons.description_outlined,
                    label: 'Incident Report',
                    onTap: () => _navigateTo(context, '/report'),
                  ),
                  _DrawerItem(
                    icon: Icons.person_outline,
                    label: 'Account',
                    onTap: () => _navigateTo(context, '/profile'),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Divider(height: 1),
                  ),
                  _DrawerItem(
                    icon: Icons.psychology_outlined,
                    label: 'Konseling Rahasia',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/counseling');
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.assignment_outlined,
                    label: 'Assessment Log',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/history');
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.folder_outlined,
                    label: 'Riwayat Laporan',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/report-history');
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.support_agent_outlined,
                    label: 'Kontak Bantuan',
                    onTap: () {
                      Navigator.pop(context);
                      showCrisisSheet(context);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.shield_outlined,
                    label: 'Privasi & Keamanan Data',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/privacy');
                    },
                  ),
                ],
              ),
            ),
            // Footer
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment(-0.7, -1),
          end: Alignment(0.7, 1),
          colors: [_primaryColor, _secondaryColor],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _secondaryColor.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.6),
                width: 2,
              ),
            ),
            child: const CircleAvatar(
              radius: 32,
              backgroundColor: Colors.white,
              child: Icon(Icons.person_outline, color: _textColor, size: 32),
            ),
          ),
          const SizedBox(height: 12),
          // Name
          const Text(
            'Tony Wijaya',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Engineering',
            style: TextStyle(
              fontFamily: 'NimbusSans',
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.85),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 12),
          // Daily mood pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.sentiment_satisfied,
                  size: 16,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                const SizedBox(width: 6),
                Text(
                  'Mood: Baik',
                  style: TextStyle(
                    fontFamily: 'NimbusSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          // Log out button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await ApiService.logout();
                if (context.mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/entry/employee', (_) => false);
                }
              },
              icon: const Icon(Icons.logout_outlined, size: 20),
              label: const Text('Log Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _textColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                  side: BorderSide(color: _textColor.withValues(alpha: 0.12)),
                ),
                textStyle: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Version text
          Text(
            'RISKALA Lite v1.0.0',
            style: TextStyle(
              fontFamily: 'NimbusSans',
              fontSize: 11,
              color: _textColor.withValues(alpha: 0.35),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, String route) {
    Navigator.pop(context); // close drawer
    Navigator.pushReplacementNamed(context, route);
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          splashColor: AppColors.accentLight.withValues(alpha: 0.3),
          highlightColor: AppColors.accentLight.withValues(alpha: 0.15),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: AppColors.brand.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brand,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
