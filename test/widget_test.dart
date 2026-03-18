import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riskala_lite2/pages/stress_page.dart';
import 'package:riskala_lite2/main.dart';

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

    await tester.pumpWidget(const MyApp());

    expect(find.text('Get Started'), findsOneWidget);
    await tester.tap(find.text('Get Started'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
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
