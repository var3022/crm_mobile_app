import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crm_pro/core/theme/app_theme.dart';
import 'font_setup.dart';
import 'package:crm_pro/features/workspace/crm_routes.dart';

/// Mount every new screen at the PDF's mobile viewport. This catches layout
/// exceptions, missing assets and incorrect route argument fallbacks.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAppTestFont);
  const screens = [
    '/leads',
    '/empty-leads',
    '/nearby-leads',
    '/new-lead',
    '/lead-details',
    '/edit-lead',
    '/filter-leads',
    '/log-call',
    '/convert-customer',
    '/customers',
    '/empty-customers',
    '/customer-details',
    '/add-note',
    '/activity',
    '/pipeline',
    '/empty-deals',
    '/new-deal',
    '/deal-details',
    '/update-deal',
    '/deal-won',
    '/deal-lost',
    '/visits',
    '/empty-visits',
    '/schedule-visit',
    '/reschedule-visit',
    '/visit-details',
    '/plan-route',
    '/todays-route',
    '/check-in',
    '/check-in-error',
    '/check-in-far',
    '/active-visit',
    '/visit-notes',
    '/visit-checklist',
    '/signature',
    '/visit-summary',
    '/tasks',
    '/empty-tasks',
    '/new-task',
    '/task-details',
    '/edit-task',
    '/task-completed',
    '/profile',
    '/edit-profile',
    '/settings',
    '/change-password',
    '/notification-settings',
    '/security',
    '/permissions',
    '/reports',
    '/targets',
    '/visit-history',
    '/offline-data',
    '/help',
    '/day-complete',
    '/photos',
    '/camera',
    '/voice-note',
    '/offline',
    '/syncing',
    '/server-error',
    '/session-expired',
    '/access-restricted',
    '/not-found',
    '/rate-limit',
    '/suspended',
    '/subscription-expired',
    '/maintenance',
    '/about',
  ];
  for (final screen in screens) {
    testWidgets('mounts $screen at 390 x 844', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          initialRoute: screen,
          onGenerateInitialRoutes: (_) => [
            crmRoute(RouteSettings(name: screen))!,
          ],
          onGenerateRoute: crmRoute,
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull, reason: screen);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });
  }
}
