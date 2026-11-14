import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crm_pro/main.dart';
import 'package:crm_pro/features/workspace/crm_store.dart';
import 'font_setup.dart';

void main() {
  setUpAll(() async {
    await loadAppTestFont();
    await CrmStore.instance.ensureHydrated();
  });
  testWidgets('reports retains PDF metric groups and a safe title inset', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const CrmProApp());
    await tester.pump(const Duration(seconds: 1));
    tester
        .state<NavigatorState>(find.byType(Navigator).first)
        .pushNamedAndRemoveUntil('/reports', (_) => false);
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.text('My Reports')).dy,
      greaterThanOrEqualTo(40),
    );
    for (final label in [
      'VISITS GOAL',
      'REVENUE',
      'CONVERSION',
      'AVG DURATION',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    await tester.scrollUntilVisible(
      find.text('Deal Pipeline Stage'),
      180,
      scrollable: find.byWidgetPredicate(
        (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
      ),
    );
    expect(find.text('Deal Pipeline Stage'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'settings restores account, reminders and daily briefing contents',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const CrmProApp());
      await tester.pump(const Duration(seconds: 1));
      tester
          .state<NavigatorState>(find.byType(Navigator).first)
          .pushNamedAndRemoveUntil('/settings', (_) => false);
      await tester.pumpAndSettle();
      expect(find.text('Account Settings'), findsOneWidget);
      expect(find.text('Biometric Login'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Visit Reminders'), 200);
      expect(find.text('Visit Reminders'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Daily Briefing'), 200);
      expect(find.text('Daily Briefing'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
