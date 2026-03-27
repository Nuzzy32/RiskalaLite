import 'package:flutter/material.dart';
import 'pages/welcome_page.dart';
import 'pages/login_page.dart';
import 'pages/employee/main_shell.dart';
import 'pages/employee/assessment_history_page.dart';
import 'pages/employee/stress_page.dart';
import 'pages/employee/report_history_page.dart';
import 'pages/hr/hr_main_shell.dart';

void main() {
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
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomePage(),
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
