import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riskala_lite2/pages/auth/employee_login_page.dart';
import 'package:riskala_lite2/pages/auth/welcome_page.dart';
import 'package:riskala_lite2/pages/employee/stress_page.dart';

void main() {
  void setPhoneViewport(WidgetTester tester) {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(390, 844);
  }

  void resetViewport(WidgetTester tester) {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  }

  testWidgets('welcome page navigates to login page', (
    WidgetTester tester,
  ) async {
    setPhoneViewport(tester);
    addTearDown(() => resetViewport(tester));

    await tester.pumpWidget(
      MaterialApp(
        home: const WelcomePage(),
        routes: {'/entry/employee': (_) => const EmployeeLoginPage()},
      ),
    );
    await tester.pump(const Duration(milliseconds: 1000));

    expect(find.text('Masuk sebagai Pegawai'), findsOneWidget);
    await tester.tap(find.text('Masuk sebagai Pegawai'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Kode Perusahaan'), findsWidgets);
    expect(
      find.text('Masukkan kode unik perusahaan Anda untuk melanjutkan.'),
      findsOneWidget,
    );
  });

  testWidgets('stress page does not overflow on a phone-sized screen', (
    WidgetTester tester,
  ) async {
    setPhoneViewport(tester);
    addTearDown(() => resetViewport(tester));

    await tester.pumpWidget(const MaterialApp(home: StressPage()));
    await tester.pump();

    expect(find.text('Sangat Setuju'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
