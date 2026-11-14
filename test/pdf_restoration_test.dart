import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crm_pro/core/theme/app_theme.dart';
import 'package:crm_pro/features/workspace/crm_store.dart';
import 'package:crm_pro/features/workspace/crm_storage_adapter.dart';
import 'package:crm_pro/features/workspace/accounts_screens.dart';
import 'package:crm_pro/features/workspace/profile_screens.dart';
import 'package:crm_pro/features/workspace/tasks_deals_screens.dart';
import 'package:crm_pro/features/workspace/reporting_ui.dart';
import 'package:crm_pro/features/workspace/report_export.dart';
import 'font_setup.dart';

void main() {
  setUpAll(loadAppTestFont);
  late CrmStore store, previous;
  late MemoryStorageAdapter storage;
  setUp(() async {
    storage = MemoryStorageAdapter();
    store = CrmStore(storageAdapter: storage);
    await store.ensureHydrated();
    previous = CrmStore.instance;
    CrmStore.setInstanceForTesting(store);
  });
  tearDown(() {
    CrmStore.setInstanceForTesting(previous);
    store.dispose();
  });

  test('monthly targets isolate records by month and use won revenue', () {
    store.visits.clear();
    store.deals.clear();
    store.leads.clear();
    store.visits.addAll([
      Visit(
        'Current',
        'A',
        '10 AM',
        'Demo',
        date: DateTime(2026, 8, 4),
        status: 'Completed',
      ),
      Visit(
        'Old',
        'B',
        '10 AM',
        'Demo',
        date: DateTime(2026, 7, 4),
        status: 'Completed',
      ),
    ]);
    store.deals.addAll([
      Deal('Won A', 'Current', 300000, 'Won', closeDate: DateTime(2026, 8, 5)),
      Deal('Lost A', 'Other', 100000, 'Lost', closeDate: DateTime(2026, 8, 5)),
      Deal('Old won', 'Old', 900000, 'Won', closeDate: DateTime(2026, 7, 5)),
    ]);
    final metrics = MonthlyPerformance(store, DateTime(2026, 8));
    expect(metrics.visits.length, 1);
    expect(metrics.revenue, 300000);
    expect(metrics.conversion, 50);
    expect(metrics.averageDeal, 300000);
    expect(metrics.overall, closeTo((1 / 50 + .3) / 3, .0001));
  });

  test('preset dates cover previous week and year rollover', () {
    final week = reportPreset('Last Week', DateTime(2026, 11, 14));
    expect(week.start, DateTime(2026, 11, 2));
    expect(week.end, DateTime(2026, 11, 8));
    final month = reportPreset('Last Month', DateTime(2026, 1, 3));
    expect(month.start, DateTime(2025, 12));
    expect(month.end, DateTime(2025, 12, 31));
  });

  test(
    'CSV includes selected team summary but excludes unselected raw data',
    () {
      store.deals.clear();
      store.leads.clear();
      store.visits.clear();
      store.leads.add(Account('SECRET_RAW_ACCOUNT', 'A'));
      store.deals.add(
        Deal(
          'Contract',
          'Private Customer',
          200000,
          'Won',
          owner: 'Team Owner',
          closeDate: DateTime(2026, 8, 5),
        ),
      );
      final file = buildReportFile(
        store,
        'csv',
        DateTime(2026, 8),
        DateTime(2026, 8, 31),
        const ReportContents(
          charts: false,
          rawData: false,
          summary: true,
          team: true,
        ),
      );
      final csv = utf8.decode(file.bytes);
      expect(csv, contains('Team Owner'));
      expect(csv, contains('200000'));
      expect(csv, contains('Summary'));
      expect(csv, isNot(contains('SECRET_RAW_ACCOUNT')));
      expect(csv, isNot(contains('Pipeline Chart Data')));
    },
  );

  test('XLSX selected sections exist as properly related workbook sheets', () {
    final file = buildReportFile(
      store,
      'xlsx',
      DateTime(2020),
      DateTime(2035),
      const ReportContents(team: true),
    );
    final zip = ZipDecoder().decodeBytes(file.bytes);
    String read(String name) => utf8.decode(
      zip.files.firstWhere((f) => f.name == name).content as List<int>,
    );
    expect(read('xl/workbook.xml'), contains('Team Breakdown'));
    expect(read('xl/workbook.xml'), contains('Pipeline Chart Data'));
    expect(
      read('xl/_rels/workbook.xml.rels'),
      contains('worksheets/sheet6.xml'),
    );
    expect(read('[Content_Types].xml'), contains('/xl/worksheets/sheet6.xml'));
    expect(read('xl/worksheets/sheet4.xml'), contains('Revenue target INR'));
  });

  test('PDF team option adds owner rows without forcing summary/raw data', () {
    store.deals.clear();
    store.deals.add(
      Deal(
        'Contract',
        'Acme',
        200000,
        'Won',
        owner: 'OWNER_EXPORT',
        closeDate: DateTime(2026, 8, 5),
      ),
    );
    final file = buildReportFile(
      store,
      'pdf',
      DateTime(2026, 8),
      DateTime(2026, 8, 31),
      const ReportContents(
        charts: false,
        rawData: false,
        summary: false,
        team: true,
      ),
    );
    final pdf = latin1.decode(file.bytes);
    expect(pdf, startsWith('%PDF-1.4'));
    expect(pdf, contains('OWNER_EXPORT'));
    expect(pdf, isNot(contains('EXECUTIVE SUMMARY')));
    expect(pdf, isNot(contains('FIELD VISITS LOGS')));
  });

  test(
    'note attachments and pin flags survive storage reload in pinned order',
    () async {
      store.notes.clear();
      store.accountNotes.clear();
      final payload = jsonEncode({
        'name': 'proposal.txt',
        'bytes': base64Encode(utf8.encode('proposal bytes')),
        'mime': 'text/plain',
      });
      await store.update(() {
        store.notes.addAll([
          CrmNote(
            companyId: 'A',
            company: 'Pinned Test',
            title: 'Older pinned',
            body: 'Pinned body',
            timestamp: DateTime(2026, 1),
            isPinned: true,
            notifyTeam: true,
            attachments: [payload],
          ),
          CrmNote(
            companyId: 'A',
            company: 'Pinned Test',
            title: 'New',
            body: 'New body',
          ),
        ]);
      });
      final reloaded = CrmStore(storageAdapter: storage);
      await reloaded.ensureHydrated();
      expect(reloaded.notesFor('Pinned Test').first, 'Pinned body');
      final note = reloaded.notes.firstWhere((n) => n.title == 'Older pinned');
      expect(note.notifyTeam, isTrue);
      expect(
        base64Decode(
          (jsonDecode(note.attachments.single) as Map)['bytes'] as String,
        ),
        utf8.encode('proposal bytes'),
      );
      reloaded.dispose();
    },
  );

  test('empty local store sizes do not invent megabytes of media', () {
    store.leads.clear();
    store.customers.clear();
    store.visits.clear();
    store.photos.clear();
    store.voiceNotes.clear();
    final size = store.calculateStorageBreakdown();
    expect(size['photosMb'], lessThan(.001));
    expect(size['audioMb'], lessThan(.001));
    expect(size['storageLimitMb'], 500);
    final snapshot = store.offlineSnapshot();
    expect(snapshot['schemaVersion'], 1);
    expect(snapshot['leads'], isEmpty);
  });

  Future<void> mount(WidgetTester tester, Widget page) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.lightTheme, home: page),
    );
    await tester.pumpAndSettle();
  }

  Finder vertical() => find
      .byWidgetPredicate(
        (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
      )
      .first;

  testWidgets('editing task retains time and persists reminder preference', (
    tester,
  ) async {
    final task = store.tasks.first;
    task.due = DateTime(2026, 12, 20, 14, 35);
    task.reminderEnabled = true;
    await mount(tester, taskForm(task));
    await tester.scrollUntilVisible(
      find.text('Set Reminder'),
      200,
      scrollable: vertical(),
    );
    await tester.drag(find.byType(ListView).first, const Offset(0, -180));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Set Reminder'));
    await tester.pump();
    await tester.tap(find.text('Save').first);
    await tester.pumpAndSettle();
    expect(task.due, DateTime(2026, 12, 20, 14, 35));
    expect(task.reminderEnabled, isFalse);
    final reloaded = CrmStore(storageAdapter: storage);
    await reloaded.ensureHydrated();
    expect(
      reloaded.tasks.firstWhere((t) => t.id == task.id).reminderEnabled,
      isFalse,
    );
    reloaded.dispose();
  });

  testWidgets('history changes actual records when month chip changes', (
    tester,
  ) async {
    final now = DateTime.now();
    final previousMonth = DateTime(now.year, now.month - 1, 10);
    store.visits.clear();
    store.visits.addAll([
      Visit(
        'CURRENT_MONTH_CLIENT',
        'A',
        '10 AM',
        'Demo',
        date: now,
        status: 'Completed',
      ),
      Visit(
        'PREVIOUS_MONTH_CLIENT',
        'B',
        '10 AM',
        'Demo',
        date: previousMonth,
        status: 'Completed',
      ),
    ]);
    await mount(tester, const HistoryScreen());
    expect(find.text('CURRENT_MONTH_CLIENT'), findsOneWidget);
    expect(find.text('PREVIOUS_MONTH_CLIENT'), findsNothing);
    await tester.tap(find.text(monthLabel(previousMonth)));
    await tester.pumpAndSettle();
    expect(find.text('CURRENT_MONTH_CLIENT'), findsNothing);
    expect(find.text('PREVIOUS_MONTH_CLIENT'), findsOneWidget);
  });

  testWidgets('lead filter applies assigned owner and added-date together', (
    tester,
  ) async {
    final now = DateTime.now();
    store.leads.clear();
    store.leads.addAll([
      Account(
        'MATCH_OWNER_DATE',
        'A',
        owner: 'Owner A',
        accountValue: 50000,
        createdAt: now,
      ),
      Account(
        'WRONG_OWNER',
        'B',
        owner: 'Owner B',
        accountValue: 50000,
        createdAt: now,
      ),
      Account(
        'OLD_DATE',
        'C',
        owner: 'Owner A',
        accountValue: 50000,
        createdAt: now.subtract(const Duration(days: 40)),
      ),
    ]);
    await mount(tester, const LeadFiltersScreen());
    await tester.scrollUntilVisible(
      find.text('Today'),
      180,
      scrollable: vertical(),
    );
    await tester.tap(find.text('Today'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Owner A'),
      180,
      scrollable: vertical(),
    );
    await tester.tap(find.text('Owner A'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Show 1 Leads'),
      180,
      scrollable: vertical(),
    );
    await tester.tap(find.text('Show 1 Leads'));
    await tester.pumpAndSettle();
    expect(find.text('MATCH_OWNER_DATE'), findsOneWidget);
    expect(find.text('WRONG_OWNER'), findsNothing);
    expect(find.text('OLD_DATE'), findsNothing);
  });
}
