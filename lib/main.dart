import 'package:flutter/material.dart';
import 'pages/welcome_page.dart' hide AnimatedBuilder;
import 'pages/login_page.dart';
import 'pages/employee/main_shell.dart';
import 'pages/employee/assessment_history_page.dart';
import 'pages/employee/stress_page.dart';
import 'pages/employee/report_history_page.dart';
import 'pages/hr/hr_main_shell.dart';
import 'services/api_service.dart';
import 'services/notification_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RISKALA Lite',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF61D1DB)),
      ),
      home: const _AppBootstrap(),
      routes: {
        '/login': (context) => const LoginPage(),
        // Employee routes
        '/home': (context) => const MainShell(),
        '/profile': (context) => const MainShell(initialTab: 3),
        '/report': (context) => const MainShell(initialTab: 0),
        '/analytics': (context) => const MainShell(initialTab: 2),
        '/stress': (context) => const StressPage(),
        '/history': (context) => const AssessmentHistoryPage(),
        '/report-history': (context) => const ReportHistoryPage(),
        // HR routes
        '/hr/home': (context) => const HrMainShell(),
        '/hr/report': (context) => const HrMainShell(initialTab: 2),
        '/hr/profile': (context) => const HrMainShell(initialTab: 3),
      },
    );
  }
}

/// Splash screen yang menjalankan async init (restore session + notif),
/// lalu pindah ke welcome / home / hr-home tergantung sesi.
class _AppBootstrap extends StatefulWidget {
  const _AppBootstrap();

  @override
  State<_AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<_AppBootstrap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _logoAnim;

  @override
  void initState() {
    super.initState();
    _logoAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _bootstrap();
  }

  @override
  void dispose() {
    _logoAnim.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    // Pastikan minimal terlihat 600ms supaya tidak flicker
    final stopwatch = Stopwatch()..start();

    await ApiService.restoreSession();
    await NotificationService.init();

    final elapsed = stopwatch.elapsedMilliseconds;
    if (elapsed < 600) {
      await Future.delayed(Duration(milliseconds: 600 - elapsed));
    }

    if (!mounted) return;

    // Auto-route based on session
    final hasSession = ApiService.token != null;
    if (hasSession) {
      final route = ApiService.isHr ? '/hr/home' : '/home';
      Navigator.pushReplacementNamed(context, route);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFB3F3F4),
              Color(0xFF61D1DB),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _logoAnim,
                  builder: (_, _) {
                    final scale = 0.92 + (_logoAnim.value * 0.08);
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 30,
                              offset: const Offset(0, 12),
                              spreadRadius: -4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.spa,
                          color: Color(0xFF245A72),
                          size: 56,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 28),
                const Text(
                  'RISKALA Lite',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF245A72),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Your mental wellness companion',
                  style: TextStyle(
                    fontFamily: 'NimbusSans',
                    fontSize: 13,
                    color: const Color(0xFF245A72).withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(
                      Colors.white.withValues(alpha: 0.85),
                    ),
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
