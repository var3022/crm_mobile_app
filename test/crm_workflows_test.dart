import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crm_pro/core/theme/app_theme.dart';
import 'font_setup.dart';
import 'package:crm_pro/features/workspace/crm_store.dart';
import 'package:crm_pro/features/workspace/crm_routes.dart';
import 'package:crm_pro/features/workspace/crm_ui.dart';
import 'package:crm_pro/features/workspace/accounts_screens.dart';
import 'package:crm_pro/features/workspace/tasks_deals_screens.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAppTestFont);

  test('notes stay attached to the selected account', () {
    final store = CrmStore();
    store.addNote('Test Company', 'Discuss annual pricing');
    expect(store.notesFor('Test Company'), ['Discuss annual pricing']);
    expect(store.notesFor('Another Company'), isEmpty);
    store.dispose();
  });

  testWidgets('form validates required fields before saving', (tester) async {
    var saves = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: CrmForm(
          title: 'New Task',
          submit: 'Create Task',
          fields: const [FormFieldSpec('Task Title', required: true)],
          onSave: (_, __) async {
            saves++;
          },
        ),
      ),
    );
    await tester.tap(find.text('Create Task'));
    await tester.pump();
    expect(find.text('Task Title is required'), findsOneWidget);
    expect(saves, 0);
    await tester.enterText(find.byType(TextFormField), 'Send revised proposal');
    await tester.tap(find.text('Create Task'));
    await tester.pump();
    expect(saves, 1);
  });

  testWidgets('opening a lead retains the selected company', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const AccountsScreen(),
        onGenerateRoute: crmRoute,
      ),
    );
    await tester.tap(find.text('TechVista Ltd').first);
    await tester.pumpAndSettle();
    expect(find.text('Lead Details'), findsOneWidget);
    expect(find.text('TechVista Ltd').last, findsOneWidget);
    expect(find.text('Priya Sharma · HR Director'), findsWidgets);
  });

  testWidgets('completing a task updates shared task state', (tester) async {
    final store = CrmStore.instance;
    final task = CrmTask('Send test proposal', 'Test Company');
    store.tasks.add(task);
    addTearDown(() => store.tasks.remove(task));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const TasksScreen(),
        onGenerateRoute: crmRoute,
      ),
    );
    await tester.scrollUntilVisible(
      find.text('Send test proposal'),
      180,
      scrollable: find.byWidgetPredicate(
        (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
      ),
    );
    await tester.tap(find.text('Send test proposal'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Mark as Complete'),
      200,
      scrollable: find.byWidgetPredicate(
        (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
      ),
    );
    await tester.tap(find.text('Mark as Complete'));
    await tester.pumpAndSettle();
    expect(task.completed, isTrue);
    expect(find.text('Task Completed!'), findsOneWidget);
  });

  test('all primary navigation tabs resolve to routes', () {
    for (final name in ['/leads', '/visits', '/tasks', '/profile']) {
      expect(crmRoute(RouteSettings(name: name)), isNotNull, reason: name);
    }
  });
}
