import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedMood = 2;
  final List<int> _completedPlans = [];

  final _moods = [
    _Mood('Sangat\nBaik', Icons.sentiment_very_satisfied, 1.0),
    _Mood('Baik', Icons.sentiment_satisfied, 0.7),
    _Mood('Netral', Icons.sentiment_neutral, 1.0),
    _Mood('Kurang\nBaik', Icons.sentiment_dissatisfied, 1.0),
  ];

  final _plans = [
    _Plan('Meditasi Pagi', '10 mins • Mindfulness', Icons.self_improvement, Color(0xFFFB923C), Color(0xFFFFF4E5)),
    _Plan('Hydration Break', '500ml • Water intake', Icons.water_drop, Color(0xFF60A5FA), Color(0xFFE3F2FD)),
    _Plan('Journaling', '15 mins • Reflection', Icons.edit_note, Color(0xFFC084FC), Color(0xFFF3E5F5)),
  ];

  void _navigateTo(String id) {
    if (id == 'report') {
      Navigator.pushReplacementNamed(context, '/report');
    } else if (id == 'account') {
      Navigator.pushReplacementNamed(context, '/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F8),
      body: Stack(
        children: [
          // Scrollable content
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                    child: Row(
                      children: [
                        // Avatar
                        Stack(
                          children: [
                            const CircleAvatar(
                              radius: 24,
                              backgroundColor: Color(0xFFE0F2F4),
                              child: Icon(Icons.person, color: Color(0xFF245A72)),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF61D1DB),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Welcome back,',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF568B8F),
                              ),
                            ),
                            Text(
                              'Tony',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F191A),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFF8FAFC)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.notifications_outlined, color: Color(0xFF0F191A), size: 20),
                        ),
                      ],
                    ),
                  ),
                ),

                // Greeting
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Selamat Pagi,',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F191A),
                          letterSpacing: -0.75,
                          height: 1.2,
                        ),
                      ),
                      Text(
                        'Tony',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F191A),
                          letterSpacing: -0.75,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Bagaimana kabarmu hari ini?',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 16,
                          color: Color(0xFF568B8F),
                        ),
                      ),
                    ],
                  ),
                ),

                // Mood buttons
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
                  child: Row(
                    children: List.generate(_moods.length, (i) {
                      final mood = _moods[i];
                      final isSelected = _selectedMood == i;
                      return Padding(
                        padding: EdgeInsets.only(right: i < _moods.length - 1 ? 12 : 0),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedMood = i),
                          child: Column(
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected ? const Color(0xFF61D1DB).withValues(alpha: 0.1) : Colors.white,
                                  border: isSelected
                                      ? Border.all(color: const Color(0xFF61D1DB), width: 2)
                                      : null,
                                  boxShadow: isSelected
                                      ? null
                                      : [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.05),
                                            blurRadius: 2,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                ),
                                child: Icon(
                                  mood.icon,
                                  size: 30,
                                  color: Color(0xFF61D1DB).withValues(alpha: mood.opacity),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                mood.label,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? const Color(0xFF61D1DB) : const Color(0xFF568B8F),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                // Stress Check-in Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(48),
                      gradient: const LinearGradient(
                        begin: Alignment(-0.5, -1),
                        end: Alignment(1, 1),
                        colors: [Color(0xFFE0F7F9), Colors.white],
                      ),
                      border: Border.all(color: const Color(0xFF61D1DB).withValues(alpha: 0.1)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Stress Check-in',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F191A),
                              height: 1.56,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Saatnya melakukan check in rutin untuk memantau tingkat stres Anda.',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 14,
                              color: Color(0xFF568B8F),
                              height: 1.625,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => Navigator.pushNamed(context, '/stress'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF61D1DB),
                              foregroundColor: Colors.white,
                              elevation: 4,
                              shadowColor: const Color(0xFF61D1DB).withValues(alpha: 0.2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  'Mulai Stress Assessment',
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.35,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, size: 16),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Your Plan Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'Your Plan',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F191A),
                            ),
                          ),
                          Text(
                            'Manage Plan',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF61D1DB),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ...List.generate(_plans.length, (i) {
                        final plan = _plans[i];
                        final isCompleted = _completedPlans.contains(i);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isCompleted) {
                                _completedPlans.remove(i);
                              } else {
                                _completedPlans.add(i);
                              }
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: plan.bgColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(plan.icon, color: plan.iconColor, size: 24),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        plan.title,
                                        style: TextStyle(
                                          fontFamily: 'Manrope',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: isCompleted ? const Color(0xFF94A3B8) : const Color(0xFF0F191A),
                                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                                          height: 1.5,
                                        ),
                                      ),
                                      Text(
                                        plan.desc,
                                        style: const TextStyle(
                                          fontFamily: 'Manrope',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF568B8F),
                                          height: 1.33,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isCompleted ? const Color(0xFF61D1DB) : Colors.transparent,
                                    border: Border.all(
                                      color: isCompleted ? const Color(0xFF61D1DB) : const Color(0xFFE2E8F0),
                                      width: 2,
                                    ),
                                  ),
                                  child: isCompleted
                                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Bottom Nav
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomNav(active: 'home', onTap: _navigateTo),
          ),
        ],
      ),
    );
  }
}

class _Mood {
  final String label;
  final IconData icon;
  final double opacity;
  _Mood(this.label, this.icon, this.opacity);
}

class _Plan {
  final String title;
  final String desc;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  _Plan(this.title, this.desc, this.icon, this.iconColor, this.bgColor);
}
