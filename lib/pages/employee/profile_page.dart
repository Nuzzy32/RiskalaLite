import 'package:flutter/material.dart';
import '../../widgets/bottom_nav.dart';

class ProfilePage extends StatefulWidget {
  final bool showNav;
  const ProfilePage({super.key, this.showNav = true});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _dailyReminder = true;

  void _navigateTo(String id) {
    if (id == 'home') {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (id == 'report') {
      Navigator.pushReplacementNamed(context, '/report');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F8),
      body: Stack(
        children: [
          Column(
            children: [
              // Header
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pushReplacementNamed(context, '/home'),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF245A72), size: 16),
                        ),
                      ),
                      const Text(
                        'Profile & Settings',
                        style: TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF245A72),
                          letterSpacing: -0.45,
                        ),
                      ),
                      const Text(
                        'Edit',
                        style: TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF61D1DB),
                          letterSpacing: 0.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 120),
                  child: Column(
                    children: [
                      // Profile section
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Column(
                          children: [
                            // Avatar
                            Container(
                              width: 128,
                              height: 128,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                                color: const Color(0xFFE0F2F4),
                              ),
                              child: const Icon(Icons.person, size: 56, color: Color(0xFF245A72)),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Tony',
                              style: TextStyle(
                                fontFamily: 'Public Sans',
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF245A72),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Product Manager @ Contoh Corp',
                              style: TextStyle(
                                fontFamily: 'Public Sans',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF245A72).withValues(alpha: 0.7),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF61D1DB).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(9999),
                              ),
                              child: const Text(
                                'MEMBER SINCE 2021',
                                style: TextStyle(
                                  fontFamily: 'Public Sans',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF61D1DB),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Account Settings
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 8, bottom: 16),
                              child: Text(
                                'ACCOUNT SETTINGS',
                                style: TextStyle(
                                  fontFamily: 'Public Sans',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF245A72).withValues(alpha: 0.5),
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),

                            // Pengingat Harian
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFE0F2F4),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.notifications_outlined, color: Color(0xFF61D1DB), size: 18),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Pengingat Harian',
                                          style: TextStyle(
                                            fontFamily: 'Public Sans',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF245A72),
                                          ),
                                        ),
                                        Text(
                                          'Manage your daily focus time',
                                          style: TextStyle(
                                            fontFamily: 'Public Sans',
                                            fontSize: 12,
                                            color: const Color(0xFF245A72).withValues(alpha: 0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: _dailyReminder,
                                    onChanged: (v) => setState(() => _dailyReminder = v),
                                    activeThumbColor: Colors.white,
                                    activeTrackColor: const Color(0xFF61D1DB),
                                    inactiveThumbColor: Colors.white,
                                    inactiveTrackColor: const Color(0xFFE2E8F0),
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              height: 1,
                              margin: const EdgeInsets.only(left: 16, right: 8),
                              color: const Color(0xFF61D1DB).withValues(alpha: 0.1),
                            ),

                            // Privacy & Security
                            _settingsItem(
                              icon: Icons.lock_outline,
                              title: 'Privacy & Security',
                              subtitle: 'Password, FaceID & Data',
                            ),

                            Container(
                              height: 1,
                              margin: const EdgeInsets.only(left: 16, right: 8),
                              color: const Color(0xFF61D1DB).withValues(alpha: 0.1),
                            ),

                            // Info Perusahaan
                            _settingsItem(
                              icon: Icons.business_outlined,
                              title: 'Info Perusahaan',
                              subtitle: 'PT Contoh',
                            ),

                            const SizedBox(height: 24),

                            // Log Out
                            GestureDetector(
                              onTap: () => Navigator.pushReplacementNamed(context, '/'),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(17),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFF61D1DB).withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.logout, color: Color(0xFF245A72), size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      'Log Out',
                                      style: TextStyle(
                                        fontFamily: 'Public Sans',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF245A72),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom Nav
          if (widget.showNav)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BottomNav(active: 'account', onTap: _navigateTo),
            ),
        ],
      ),
    );
  }

  Widget _settingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFE0F2F4),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF61D1DB), size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF245A72),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 12,
                    color: const Color(0xFF245A72).withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: const Color(0xFF245A72).withValues(alpha: 0.3), size: 20),
        ],
      ),
    );
  }
}
