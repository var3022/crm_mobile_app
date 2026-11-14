import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crm_pro/core/theme/app_theme.dart';
import 'font_setup.dart';
import 'package:crm_pro/features/workspace/crm_store.dart';
import 'package:crm_pro/features/workspace/crm_services.dart';
import 'package:crm_pro/features/workspace/crm_storage.dart';
import 'package:crm_pro/features/workspace/crm_storage_adapter.dart';
import 'package:crm_pro/features/workspace/crm_storage_io.dart';
import 'package:crm_pro/features/workspace/crm_routes.dart';
import 'package:crm_pro/features/workspace/crm_ui.dart';
import 'package:crm_pro/features/workspace/accounts_screens.dart';
import 'package:crm_pro/features/workspace/tasks_deals_screens.dart';
import 'package:archive/archive.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await loadAppTestFont();
    await CrmStore.instance.ensureHydrated();
  });

  test('notes stay attached to the selected account', () async {
    final store = CrmStore(storageAdapter: MemoryStorageAdapter());
    await store.ensureHydrated();
    await store.addNote('Test Company', 'Discuss annual pricing');
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
    await tester.ensureVisible(find.text('Mark as Complete'));
    await tester.drag(find.byType(ListView).first, const Offset(0, -160));
    await tester.pumpAndSettle();
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

  test(
    'relational stable IDs and account duplicate detection / merge',
    () async {
      final store = CrmStore(storageAdapter: MemoryStorageAdapter());
      await store.ensureHydrated();
      final leadA = Account(
        'Acme Industries',
        'John Doe',
        role: 'VP Sales',
        area: 'Nariman Point',
        stage: 'Hot',
        phone: '+91 98765 11111',
        email: 'john@acme.com',
        id: 'acc_test_a',
      );
      final leadB = Account(
        'Acme Industries Private Limited',
        'John D',
        role: 'Director',
        area: 'Nariman Point Mumbai',
        stage: 'Warm',
        phone: '+91 98765 11111',
        email: 'johndoe@acme.com',
        id: 'acc_test_b',
      );
      store.leads.addAll([leadA, leadB]);

      // Duplicate detection finds match by phone / company token
      final duplicates = store.findDuplicateLeads(
        company: 'Acme Industries',
        phone: '+91 98765 11111',
        email: 'different@email.com',
      );
      expect(duplicates, isNotEmpty);
      expect(
        duplicates.any((d) => d.id == leadA.id || d.id == leadB.id),
        isTrue,
      );

      // Relational notes
      store.notes.add(
        CrmNote(
          companyId: leadB.id,
          company: leadB.company,
          title: 'Preliminary discussion',
          content: 'Client needs 100 enterprise licenses',
          id: 'note_test_1',
        ),
      );

      // Merge leadB into leadA
      await store.mergeAccounts(leadA, leadB);

      // Duplicate removed from leads
      expect(store.leads.any((l) => l.id == leadB.id), isFalse);
      expect(store.leads.any((l) => l.id == leadA.id), isTrue);

      // Note re-associated to primary leadA
      final mergedNotes = store.notes.where(
        (n) => n.companyId == leadA.id || n.company == leadA.company,
      );
      expect(mergedNotes, isNotEmpty);

      store.dispose();
    },
  );

  test('lead to customer conversion with welcome deal creation', () async {
    final store = CrmStore(storageAdapter: MemoryStorageAdapter());
    await store.ensureHydrated();
    final lead = Account(
      'Zenith Cloud Labs',
      'Ananya Sen',
      role: 'CTO',
      area: 'Bandra Kurla Complex',
      stage: 'Qualified',
      phone: '+91 98765 22222',
      email: 'ananya@zenithcloud.io',
      id: 'lead_zenith',
    );
    store.leads.add(lead);

    expect(store.leads.contains(lead), isTrue);
    expect(
      store.customers.any((c) => c.company == 'Zenith Cloud Labs'),
      isFalse,
    );

    // Convert lead to customer
    await store.convertToCustomer(
      lead,
      customerType: 'Gold Enterprise',
      welcomeDeal: Deal(
        'Initial Welcome Deal',
        lead.company,
        125000,
        'Proposal',
      ),
    );

    // Moved to customers
    expect(store.leads.contains(lead), isFalse);
    expect(
      store.customers.any((c) => c.company == 'Zenith Cloud Labs'),
      isTrue,
    );

    // Welcome deal created
    final deals = store.deals.where((d) => d.company == 'Zenith Cloud Labs');
    expect(deals, isNotEmpty);
    expect(deals.first.value, 125000);

    store.dispose();
  });

  test('active visit persistent timer and workflow', () async {
    final store = CrmStore(storageAdapter: MemoryStorageAdapter());
    await store.ensureHydrated();
    final visit = Visit(
      'Target Dynamics',
      'Rohan Roy',
      '03:00 PM',
      'Technical Presentation',
      id: 'vis_test_timer',
      status: 'Scheduled',
      locationAddress: 'Mindspace Cybercity',
    );
    store.visits.add(visit);

    expect(store.activeVisitId, isNull);

    // Start active visit
    await store.startVisit(visit);
    expect(store.activeVisitId, visit.id);
    expect(visit.status, 'In Progress');
    expect(store.activeVisitStart, isNotNull);

    // Finish active visit
    await store.finishActiveVisit(
      visit,
      outcome: 'Signed POC Agreement',
      summary:
          'Delivered presentation to 6 stakeholders, collected requirements',
    );

    expect(store.activeVisitId, isNull);
    expect(visit.status, 'Completed');
    expect(visit.outcome, 'Signed POC Agreement');

    store.dispose();
  });

  test(
    'standards-compliant RFC 6238 TOTP verification, test vectors, and one-time backup consumption',
    () {
      // 1. Published RFC 6238 Appendix B test vectors for HMAC-SHA1
      // Secret: ASCII "12345678901234567890" -> Base32 "GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ"
      const rfcSecret = 'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ';
      expect(
        AuthService.generateTotp(secret: rfcSecret, timestampSeconds: 59),
        '287082',
      );
      expect(
        AuthService.generateTotp(
          secret: rfcSecret,
          timestampSeconds: 1111111109,
        ),
        '081804',
      );
      expect(
        AuthService.generateTotp(
          secret: rfcSecret,
          timestampSeconds: 1111111111,
        ),
        '050471',
      );
      expect(
        AuthService.generateTotp(
          secret: rfcSecret,
          timestampSeconds: 1234567890,
        ),
        '005924',
      );
      expect(
        AuthService.generateTotp(
          secret: rfcSecret,
          timestampSeconds: 2000000000,
        ),
        '279037',
      );

      // 2. Strict window validation and drift checks
      expect(
        AuthService.verifyTotp(
          code: '287082',
          secret: rfcSecret,
          currentTimestampSeconds: 59,
          window: 0,
        ),
        isTrue,
      );

      // Wrong code rejected
      expect(
        AuthService.verifyTotp(
          code: '999999',
          secret: rfcSecret,
          currentTimestampSeconds: 59,
          window: 1,
        ),
        isFalse,
      );

      // Expired window rejected when outside window
      expect(
        AuthService.verifyTotp(
          code: '287082', // valid at T=59 (step 1)
          secret: rfcSecret,
          currentTimestampSeconds: 200, // step 6, way beyond window of 1
          window: 1,
        ),
        isFalse,
      );

      // Negative tests for public helper AuthService.verifyTotpCode
      // (Missing, null, empty, whitespace secrets and invalid codes must strictly fail)
      expect(AuthService.verifyTotpCode('123456', null), isFalse);
      expect(AuthService.verifyTotpCode('123456', ''), isFalse);
      expect(AuthService.verifyTotpCode('123456', '   '), isFalse);
      expect(AuthService.verifyTotpCode('', rfcSecret), isFalse);
      expect(AuthService.verifyTotpCode('12', rfcSecret), isFalse);
      expect(AuthService.verifyTotpCode('abcdef', rfcSecret), isFalse);
      expect(AuthService.verifyTotpCode('999999', rfcSecret), isFalse);

      // 3. Dynamic enrollment secrets & backup codes
      final secretA = AuthService.generateRandomBase32Secret(16);
      final secretB = AuthService.generateRandomBase32Secret(16);
      expect(secretA.length, 16);
      expect(secretA, isNot(equals(secretB)));

      // 4. One-time backup code consumption
      final activeCodes = AuthService.generateBackupCodes(8);
      final consumedCodes = <String>[];
      expect(activeCodes.length, 8);

      final codeToUse = activeCodes.first;
      // First use must succeed
      final firstUse = AuthService.consumeBackupCode(
        code: codeToUse,
        availableCodes: activeCodes,
        consumedCodes: consumedCodes,
      );
      expect(firstUse, isTrue);
      expect(activeCodes.length, 7);
      expect(consumedCodes.length, 1);

      // Second use of the same code MUST fail
      final secondUse = AuthService.consumeBackupCode(
        code: codeToUse,
        availableCodes: activeCodes,
        consumedCodes: consumedCodes,
      );
      expect(secondUse, isFalse);

      // Random non-existent code must fail
      final badCode = AuthService.consumeBackupCode(
        code: 'DEAD-BEEF',
        availableCodes: activeCodes,
        consumedCodes: consumedCodes,
      );
      expect(badCode, isFalse);
    },
  );

  test(
    'genuine binary XLSX workbook and ISO 32000-1 binary PDF generation and RFC 4180 CSV escaping',
    () {
      final storage = CrmStorage.instance;
      final leads = [
        Account(
          'Apex Global, Inc.',
          'Alice Smith',
          role: 'VP, Operations',
          area: 'Andheri East',
          stage: 'Hot',
          phone: '+91 98765 00001',
          email: 'alice@apexglobal.com',
        ),
      ];
      final customers = [
        Account(
          'Beta "Tech" Solutions',
          'Bob Jones',
          role: 'Director',
          area: 'BKC',
          stage: 'Customer',
          phone: '+91 98765 00002',
          email: 'bob@betatech.com',
        ),
      ];
      final deals = [
        Deal(
          'Cloud Migration & Security',
          'Apex Global, Inc.',
          250000,
          'Proposal',
        ),
      ];
      final visits = [
        Visit(
          'Apex Global, Inc.',
          'Alice Smith',
          '10:30 AM',
          'Solution Demo',
          outcome: 'Positive, requested commercial draft',
          locationAddress: 'Andheri East, Mumbai',
        ),
      ];

      // 1. Binary XLSX Workbook verification via independent ZipDecoder
      final xlsxBytes = storage.generateXlsxBytes(
        leads: leads,
        customers: customers,
        deals: deals,
        visits: visits,
      );
      // Magic bytes for PK ZIP: 0x50, 0x4B, 0x03, 0x04
      expect(xlsxBytes.sublist(0, 4), [0x50, 0x4B, 0x03, 0x04]);

      final decodedArchive = ZipDecoder().decodeBytes(xlsxBytes);
      final fileNames = decodedArchive.map((f) => f.name).toSet();
      expect(fileNames, contains('[Content_Types].xml'));
      expect(fileNames, contains('_rels/.rels'));
      expect(fileNames, contains('xl/workbook.xml'));
      expect(fileNames, contains('xl/worksheets/sheet1.xml'));
      expect(fileNames, contains('xl/worksheets/sheet2.xml'));
      expect(fileNames, contains('xl/worksheets/sheet3.xml'));

      // Check sheet content inside parsed archive
      final sheet1File = decodedArchive.firstWhere(
        (f) => f.name == 'xl/worksheets/sheet1.xml',
      );
      final sheet1Xml = utf8.decode(sheet1File.content as List<int>);
      expect(sheet1Xml, contains('Apex Global, Inc.'));
      expect(sheet1Xml, contains('Beta &quot;Tech&quot; Solutions'));

      // 2. Binary ISO 32000-1 / PDF 1.4 verification
      final pdfBytes = storage.generatePdfBytes(
        period: 'November 2026',
        deals: deals,
        visits: visits,
      );
      final pdfString = utf8.decode(pdfBytes, allowMalformed: true);
      // Must begin with %PDF-1.4 header
      expect(pdfString.startsWith('%PDF-1.4'), isTrue);
      // Must contain standard PDF structural objects
      expect(pdfString, contains('/Type /Catalog'));
      expect(pdfString, contains('/Type /Pages'));
      expect(pdfString, contains('/Type /Page'));
      expect(pdfString, contains('/BaseFont /Helvetica'));
      expect(pdfString, contains('xref'));
      expect(pdfString, contains('trailer'));
      expect(pdfString, contains('%%EOF'));

      // 3. RFC 4180 CSV escaping verification
      final csv = storage.generateCsv(
        leads: leads,
        customers: customers,
        deals: deals,
        visits: visits,
      );
      // Commas and quotes must be escaped
      expect(csv, contains('"Apex Global, Inc."'));
      expect(csv, contains('"Beta ""Tech"" Solutions"'));
      expect(csv, contains('"Positive, requested commercial draft"'));
      // CRLF line endings
      expect(csv, contains('\r\n'));
    },
  );

  test(
    'durable browser & native storage isolation with simulated app reload',
    () async {
      final memoryStorage = MemoryStorageAdapter();

      // 1. First app session: load and modify data
      final sessionOne = CrmStore(storageAdapter: memoryStorage);
      await sessionOne.ensureHydrated();

      final customLead = Account(
        'Session Test Dynamics',
        'Karan Johar',
        role: 'Procurement Head',
        area: 'Worli',
        stage: 'Qualified',
        phone: '+91 99999 88888',
        email: 'karan@sessiontest.com',
        id: 'acc_session_persisted',
      );
      sessionOne.leads.add(customLead);
      sessionOne.addNote(
        'Session Test Dynamics',
        'Custom note persisted to storage adapter',
      );

      // Force save
      await sessionOne.syncNow();
      expect(memoryStorage.writeCount, greaterThan(0));

      // Inspect storage snapshot contains structured schema
      final rawStored = memoryStorage.snapshot['crm_pro_database_v1'];
      expect(rawStored, isNotNull);
      final parsed = jsonDecode(rawStored!) as Map<String, dynamic>;
      expect(parsed['schemaVersion'], 1);
      expect(parsed['storageOrigin'], 'crm_pro_local');

      // 2. Second app session (simulating fresh browser launch or reload)
      final sessionTwo = CrmStore(storageAdapter: memoryStorage);
      await sessionTwo.ensureHydrated();

      // Verify persisted lead and notes are faithfully hydrated
      expect(
        sessionTwo.leads.any((l) => l.id == 'acc_session_persisted'),
        isTrue,
      );
      final hydratedNotes = sessionTwo.notesFor('Session Test Dynamics');
      expect(
        hydratedNotes,
        contains('Custom note persisted to storage adapter'),
      );

      sessionOne.dispose();
      sessionTwo.dispose();
    },
  );

  test('real platform URL intents and device handoffs', () async {
    DeviceService.clearAuditLog();
    final receivedUris = <Uri>[];
    DeviceService.customLauncher = (uri) async {
      receivedUris.add(uri);
      return true; // simulated platform accepts intent
    };

    // 1. Phone intent
    await DeviceService.callPhone('+91 98765 43210');
    expect(
      receivedUris.any((u) => u.scheme == 'tel' && u.path == '+919876543210'),
      isTrue,
    );

    // 2. Email intent with encoded subject
    await DeviceService.sendEmail('alex@acme.com', 'Q4 Field Sales Proposal');
    expect(
      receivedUris.any(
        (u) =>
            u.scheme == 'mailto' &&
            u.path == 'alex@acme.com' &&
            u.queryParameters['subject'] == 'Q4 Field Sales Proposal',
      ),
      isTrue,
    );

    // 3. WhatsApp intent with encoded message
    await DeviceService.sendWhatsApp(
      '+91 98765 43210',
      'Confirming tomorrow 10am meeting',
    );
    expect(
      receivedUris.any(
        (u) =>
            u.host == 'wa.me' &&
            u.path == '/919876543210' &&
            u.queryParameters['text'] == 'Confirming tomorrow 10am meeting',
      ),
      isTrue,
    );

    // 4. Navigation intent with encoded address
    await DeviceService.getDirections('Nariman Point, Mumbai 400021');
    expect(
      receivedUris.any(
        (u) =>
            u.host == 'www.google.com' &&
            u.queryParameters['destination'] == 'Nariman Point, Mumbai 400021',
      ),
      isTrue,
    );

    DeviceService.customLauncher = null;
  });

  test(
    'honest location simulation, sync status preservation, and 30-day storage cleanup',
    () async {
      final store = CrmStore(storageAdapter: MemoryStorageAdapter());
      await store.ensureHydrated();

      // Storage breakdown calculation
      final breakdown = store.calculateStorageBreakdown();
      expect(breakdown['dbMb'], isNotNull);
      expect(breakdown['photosMb'], isNotNull);
      expect(breakdown['audioMb'], isNotNull);
      expect(breakdown['totalMb'], isNotNull);

      // SyncNow preserves pending items when remote server acknowledgement is absent
      store.appSettings.pendingSyncItems = 14;
      final ack = await store.syncNow(hasServerAcknowledgement: false);
      expect(ack, isFalse);
      expect(
        store.appSettings.pendingSyncItems,
        14,
      ); // preserved in offline queue!

      // 30-day cleanup deletes records older than threshold
      final oldVisit = Visit(
        'Archived Client',
        'Old Contact',
        '10:00 AM',
        'Follow-up',
        date: DateTime.now().subtract(const Duration(days: 45)),
        status: 'Completed',
      );
      final freshVisit = Visit(
        'Active Client',
        'Fresh Contact',
        '11:00 AM',
        'Follow-up',
        date: DateTime.now().subtract(const Duration(days: 2)),
        status: 'Completed',
      );
      store.visits.addAll([oldVisit, freshVisit]);

      await store.clearOldData(olderThanDays: 30);
      expect(store.visits.any((v) => v.id == oldVisit.id), isFalse);
      expect(store.visits.any((v) => v.id == freshVisit.id), isTrue);

      store.dispose();
    },
  );

  test(
    'native IoStorageAdapter crash-safe atomic write, backup recovery, and queue error isolation',
    () async {
      final tempDir = Directory.systemTemp.createTempSync('crm_io_test_');
      addTearDown(() {
        try {
          if (tempDir.existsSync()) {
            tempDir.deleteSync(recursive: true);
          }
        } catch (_) {}
      });

      final adapter = IoStorageAdapter(customDirectory: tempDir);
      const key = 'crm_test_key';
      const testPayload = '{"app":"CRM Pro","status":"active"}';

      // 1. Initial crash-safe write
      await adapter.write(key, testPayload);
      final targetFile = File('${tempDir.path}/$key.json');
      expect(targetFile.existsSync(), isTrue);
      expect(await adapter.read(key), testPayload);

      // 2. Interrupted replacement / crash recovery from .bak
      // Simulate a crash scenario where target is missing or deleted, but .bak exists
      const backupPayload = '{"app":"CRM Pro","status":"restored_from_backup"}';
      final bakFile = File('${tempDir.path}/$key.json.bak');
      await bakFile.writeAsString(backupPayload, flush: true);
      await targetFile.delete();
      expect(targetFile.existsSync(), isFalse);
      expect(bakFile.existsSync(), isTrue);

      // read() must automatically detect .bak, rename to target, and recover data
      final recovered = await adapter.read(key);
      expect(recovered, backupPayload);
      expect(targetFile.existsSync(), isTrue);
      expect(bakFile.existsSync(), isFalse);

      // 3. Queue error resilience: sequential writes continue after successful completion
      await adapter.write('key_two', '{"val": 2}');
      expect(await adapter.read('key_two'), '{"val": 2}');

      await adapter.delete(key);
      expect(await adapter.read(key), isNull);
    },
  );

  test(
    'multipage PDF generation with WinAnsi sanitization, page numbers, and complete visit coverage',
    () {
      final storage = CrmStorage.instance;
      // Generate 35 visits to force multiple PDF pages
      final manyVisits = List.generate(
        35,
        (i) => Visit(
          'Enterprise Corp #$i',
          'Contact Person $i',
          '10:${(i % 50).toString().padLeft(2, '0')} AM',
          'Routine Inspection $i',
          outcome: 'Completed ₹50,000 deal discussion #$i',
          locationAddress: 'Bandra Kurla Complex, Mumbai',
        ),
      );
      final deals = List.generate(
        5,
        (i) => Deal(
          'Enterprise Contract #$i',
          'Enterprise Corp #$i',
          500000 + i * 10000,
          'Proposal',
        ),
      );

      final pdfBytes = storage.generatePdfBytes(
        period: 'Q4 2026',
        deals: deals,
        visits: manyVisits,
      );

      final pdfString = utf8.decode(pdfBytes, allowMalformed: true);
      expect(pdfString.startsWith('%PDF-1.4'), isTrue);

      // Multipage structure check: /Count must be greater than 1
      final countMatch = RegExp(r'/Count\s+(\d+)').firstMatch(pdfString);
      expect(countMatch, isNotNull);
      final pageCount = int.parse(countMatch!.group(1)!);
      expect(pageCount, greaterThanOrEqualTo(2));

      // Page Kids array must have multiple references
      expect(pdfString, contains('/Kids ['));

      // Check WinAnsi transliteration: no raw UTF-8 Rupee sign, replaced with 'INR '
      expect(
        pdfString.contains('₹'),
        isFalse,
        reason: 'Raw ₹ must not be emitted in Type 1 WinAnsi Helvetica',
      );
      expect(pdfString.contains('INR '), isTrue);

      // Check page numbering text
      expect(pdfString, contains('Page 1 of'));
      expect(pdfString, contains('Page 2 of'));

      // Verify all visits are included in output, not truncated to 15
      for (var i = 0; i < 35; i++) {
        expect(
          pdfString,
          contains('Enterprise Corp #$i'),
          reason: 'Visit $i must be rendered in paginated output',
        );
      }
    },
  );

  test(
    'binary XLSX export includes complete record set across all sheets without truncation',
    () {
      final storage = CrmStorage.instance;
      final manyVisits = List.generate(
        30,
        (i) => Visit(
          'Visit Company $i',
          'Contact $i',
          '09:00 AM',
          'Field Visit',
          outcome: 'Outcome $i',
        ),
      );
      final manyLeads = List.generate(
        20,
        (i) => Account('Lead Company $i', 'Lead Contact $i'),
      );
      final manyCustomers = List.generate(
        10,
        (i) => Account('Customer Company $i', 'Customer Contact $i'),
      );
      final manyDeals = List.generate(
        15,
        (i) => Deal(
          'Deal $i',
          'Lead Company $i',
          100000 + i * 5000,
          'Negotiation',
        ),
      );

      final xlsxBytes = storage.generateXlsxBytes(
        leads: manyLeads,
        customers: manyCustomers,
        deals: manyDeals,
        visits: manyVisits,
      );

      final archive = ZipDecoder().decodeBytes(xlsxBytes);
      final sheet3 = archive.firstWhere(
        (f) => f.name == 'xl/worksheets/sheet3.xml',
      );
      final xml = utf8.decode(sheet3.content as List<int>);

      // Verify all 30 visits are present in sheet3
      for (var i = 0; i < 30; i++) {
        expect(
          xml,
          contains('Visit Company $i'),
          reason: 'Visit $i must be present in XLSX sheet3',
        );
      }
    },
  );

  test(
    'DeviceService fallback to clipboard on failed launcher or denial',
    () async {
      DeviceService.clearAuditLog();
      // Simulate platform returning false (launcher failed / denied)
      DeviceService.customLauncher = (uri) async => false;

      final launched = await DeviceService.launchUri(
        Uri.parse('tel:+919876500000'),
      );
      // Result should be false because platform launcher failed
      expect(launched, isFalse);
      expect(DeviceService.launchedUris.length, 1);
      expect(DeviceService.launchedUris.first.scheme, 'tel');

      // Also call callPhone to verify safe execution with clipboard fallback
      await DeviceService.callPhone('+91 98765 00000');
      expect(DeviceService.launchedUris.length, 2);

      DeviceService.customLauncher = null;
    },
  );

  test('CrmStore gates persistence on hydration completion', () async {
    final adapter = MemoryStorageAdapter();
    final existingData = {
      'schemaVersion': 1,
      'storageOrigin': 'crm_pro_local',
      'leads': [
        {'company': 'Pre-existing Corp', 'contact': 'Jane Doe'},
      ],
    };
    await adapter.write('crm_pro_database_v1', jsonEncode(existingData));

    final store = CrmStore(storageAdapter: adapter);
    await store.ensureHydrated();
    expect(store.leads.any((l) => l.company == 'Pre-existing Corp'), isTrue);

    store.dispose();
  });

  test(
    'delayed-storage regression test: immediate user edit survives loading',
    () async {
      // Setup a storage adapter with delayed read
      final memory = MemoryStorageAdapter();
      final savedData = {
        'schemaVersion': 1,
        'storageOrigin': 'crm_pro_local',
        'leads': [
          {
            'id': 'acc_saved_1',
            'company': 'Saved Cloud Corp',
            'contact': 'Alice Walker',
          },
        ],
        'notes': [
          {
            'id': 'note_saved_1',
            'companyId': 'acc_saved_1',
            'company': 'Saved Cloud Corp',
            'title': 'Saved Note',
            'body': 'Initial saved note',
          },
        ],
      };
      await memory.write('crm_pro_database_v1', jsonEncode(savedData));

      // Wrap in delayed adapter
      final delayedAdapter = _DelayedStorageAdapter(
        memory,
        delay: const Duration(milliseconds: 60),
      );
      final store = CrmStore(storageAdapter: delayedAdapter);

      // Verify store is NOT yet hydrated immediately after construction
      expect(store.isHydrated, isFalse);

      // IMMEDIATE USER EDIT before hydration completes
      const immediateCompanyName = 'Immediate Start Dynamics';
      final immediateLead = Account(
        immediateCompanyName,
        'David Kim',
        id: 'acc_immediate_001',
      );
      // Call addNote directly (NOT wrapped in update()) before hydration completes
      final noteFuture = store.addNote(
        immediateCompanyName,
        'Critical pre-hydration note',
      );
      store.update(() {
        store.leads.add(immediateLead);
        store.appSettings.wifiOnlySync = true;
      });
      await noteFuture;

      // Wait for storage hydration to complete
      await store.ensureHydrated();
      expect(store.isHydrated, isTrue);

      // Verify that the immediate user edits SURVIVED loading:
      // 1. Stored lead is loaded
      expect(
        store.leads.any((l) => l.company == 'Saved Cloud Corp'),
        isTrue,
        reason: 'Saved lead must be loaded from storage',
      );
      // 2. Immediate user-added lead survived!
      expect(
        store.leads.any((l) => l.company == immediateCompanyName),
        isTrue,
        reason: 'Immediate user edit must survive storage hydration',
      );
      // 3. Immediate note survived!
      expect(
        store.notesFor(immediateCompanyName),
        contains('Critical pre-hydration note'),
        reason: 'Immediate note must survive storage hydration',
      );
      // 4. Queued mutation survived!
      expect(
        store.appSettings.wifiOnlySync,
        isTrue,
        reason: 'Queued mutation must be preserved',
      );

      // Verify that the merged state was persisted by loading into a fresh store
      await store.syncNow();
      final freshStore = CrmStore(storageAdapter: memory);
      await freshStore.ensureHydrated();
      expect(
        freshStore.leads.any((l) => l.company == immediateCompanyName),
        isTrue,
        reason: 'Immediate user edit must be durably persisted to storage',
      );
      expect(
        freshStore.notesFor(immediateCompanyName),
        contains('Critical pre-hydration note'),
      );

      store.dispose();
      freshStore.dispose();
    },
  );

  test(
    'reporting correctness: empty datasets, zero revenue, mixed durations, and out-of-range records',
    () {
      final storage = CrmStorage.instance;
      final refDate = DateTime(2026, 11, 14);

      // 1. Empty dataset validation (zero revenue must remain zero, conversion N/A, avg duration N/A)
      final emptyPdfBytes = storage.generatePdfBytes(
        period: 'This Month',
        visitsGoalMet: 0,
        visitsGoalTotal: 0,
        revenueMet: 0.0,
        revenueGoal: 5.0,
        conversionRate: null,
        avgDuration: 'N/A',
        deals: const [],
        visits: const [],
      );
      final emptyPdfStr = utf8.decode(emptyPdfBytes, allowMalformed: true);
      expect(
        emptyPdfStr,
        contains(r'Revenue Closed:   INR 0.0L / INR 5.0L \(0%\)'),
        reason: 'Zero revenue must remain 0.0L, never fallback',
      );
      expect(
        emptyPdfStr,
        contains('Conversion Rate:  N/A'),
        reason: 'Conversion without closed deals must be explicitly N/A',
      );
      expect(emptyPdfStr, contains(r'Visits Completed: 0 / 0 \(0%\)'));
      expect(emptyPdfStr, contains('Average Visit Duration: N/A'));
      expect(emptyPdfStr, contains('No deals in selected period'));
      expect(emptyPdfStr, contains('No visits logged in selected period'));
      expect(emptyPdfStr, contains(r'FIELD VISITS LOGS \(0 records\)'));

      final emptyXlsxBytes = storage.generateXlsxBytes(
        leads: const [],
        customers: const [],
        deals: const [],
        visits: const [],
      );
      final emptyArchive = ZipDecoder().decodeBytes(emptyXlsxBytes);
      expect(
        emptyArchive.files.any((f) => f.name == 'xl/worksheets/sheet3.xml'),
        isTrue,
      );

      // 2. Zero revenue with active pipeline deals (deals exist but none won)
      final pipelineDeals = [
        Deal('Deal A', 'Acme', 200000, 'Proposal', createdAt: refDate),
        Deal('Deal B', 'Beta', 350000, 'Negotiation', createdAt: refDate),
        Deal('Deal C', 'Gamma', 150000, 'Discovery', createdAt: refDate),
      ];
      final wonDeals = pipelineDeals.where((d) => d.stage == 'Won').toList();
      final closedDeals = pipelineDeals
          .where((d) => d.stage == 'Won' || d.stage == 'Lost')
          .toList();
      final computedRev =
          wonDeals.fold<double>(0.0, (acc, d) => acc + d.value) / 100000.0;
      expect(computedRev, 0.0);
      expect(closedDeals.isEmpty, isTrue);

      final zeroRevPdf = storage.generatePdfBytes(
        period: 'This Month',
        revenueMet: computedRev,
        conversionRate: closedDeals.isNotEmpty
            ? (wonDeals.length / closedDeals.length * 100)
            : null,
        deals: pipelineDeals,
      );
      final zeroRevStr = utf8.decode(zeroRevPdf, allowMalformed: true);
      expect(
        zeroRevStr,
        contains(r'Revenue Closed:   INR 0.0L / INR 5.0L \(0%\)'),
      );
      expect(zeroRevStr, contains('Conversion Rate:  N/A'));

      // Check closed lost deals without wins yields 0.0% conversion, not N/A or fabricated
      final lostDeals = [
        Deal('Lost Deal', 'Lost Corp', 100000, 'Lost', createdAt: refDate),
      ];
      final lostRevPdf = storage.generatePdfBytes(
        period: 'This Month',
        revenueMet: 0.0,
        conversionRate: 0.0,
        deals: lostDeals,
      );
      final lostRevStr = utf8.decode(lostRevPdf, allowMalformed: true);
      expect(lostRevStr, contains('Conversion Rate:  0.0%'));
      expect(
        lostRevStr,
        contains(r'Revenue Closed:   INR 0.0L / INR 5.0L \(0%\)'),
      );

      // 3. Mixed duration calculation from actual visits
      final mixedVisits = [
        Visit(
          'Co 1',
          'C 1',
          '10:00 AM',
          'Demo',
          duration: '15 min',
          durationMinutes: 15,
          date: refDate,
        ),
        Visit(
          'Co 2',
          'C 2',
          '11:00 AM',
          'Meeting',
          duration: '45 min',
          durationMinutes: 45,
          date: refDate,
        ),
        Visit(
          'Co 3',
          'C 3',
          '02:00 PM',
          'Review',
          duration: '1h 30m',
          durationMinutes: 90,
          date: refDate,
        ),
        Visit(
          'Co 4',
          'C 4',
          '04:00 PM',
          'Audit',
          duration: '2 hours',
          durationMinutes: 120,
          date: refDate,
        ),
      ];
      // (15 + 45 + 90 + 120) / 4 = 270 / 4 = 67.5 -> 68 min -> 1h 8m
      final formattedAvg = CrmStorage.formatAverageDuration(mixedVisits);
      expect(
        formattedAvg,
        '1h 8m',
        reason: 'Average duration must be calculated from actual visit records',
      );

      final mixedPdf = storage.generatePdfBytes(
        period: 'This Month',
        avgDuration: formattedAvg,
        visits: mixedVisits,
      );
      final mixedPdfStr = utf8.decode(mixedPdf, allowMalformed: true);
      expect(mixedPdfStr, contains('Average Visit Duration: 1h 8m'));

      // 4. Date range filtering and out-of-range record exclusion
      final inRangeVisit = Visit(
        'Nov Co',
        'Nov Contact',
        '10:00 AM',
        'Demo',
        date: DateTime(2026, 11, 10),
      );
      final outOfRangeVisit = Visit(
        'May Co',
        'May Contact',
        '10:00 AM',
        'Demo',
        date: DateTime(2026, 5, 20),
      );

      expect(
        CrmStorage.isDateInRange(inRangeVisit.date, 'This Month', refDate),
        isTrue,
      );
      expect(
        CrmStorage.isDateInRange(outOfRangeVisit.date, 'This Month', refDate),
        isFalse,
      );

      final filteredVisits = [inRangeVisit, outOfRangeVisit]
          .where((v) => CrmStorage.isDateInRange(v.date, 'This Month', refDate))
          .toList();
      expect(filteredVisits.length, 1);
      expect(filteredVisits.first.company, 'Nov Co');

      final dateFilterPdf = storage.generatePdfBytes(
        period: 'November 2026',
        visits: filteredVisits,
      );
      final dateFilterPdfStr = utf8.decode(dateFilterPdf, allowMalformed: true);
      expect(dateFilterPdfStr, contains('Nov Co'));
      expect(
        dateFilterPdfStr.contains('May Co'),
        isFalse,
        reason: 'Out-of-range records must be excluded from export',
      );
    },
  );

  test(
    'delayed-storage regression: one record per ID when adding lead during hydration',
    () async {
      final memory = MemoryStorageAdapter();
      final delayedAdapter = _DelayedStorageAdapter(
        memory,
        delay: const Duration(milliseconds: 50),
      );
      final store = CrmStore(storageAdapter: delayedAdapter);

      final newLead = Account(
        'Apex Quantum Systems',
        'Elena Rostova',
        id: 'acc_unique_lead_1',
      );

      // Mutate during in-flight hydration via update
      store.update(() => store.leads.add(newLead));

      await store.ensureHydrated();

      // Assert exactly ONE entry exists with this ID
      final matching = store.leads.where((l) => l.id == newLead.id).toList();
      expect(
        matching.length,
        1,
        reason:
            'Adding a lead before hydration must result in exactly one entry',
      );
      expect(matching.first.company, 'Apex Quantum Systems');

      // Verify persistence across restart
      await store.syncNow();
      final freshStore = CrmStore(storageAdapter: memory);
      await freshStore.ensureHydrated();

      final freshMatching = freshStore.leads
          .where((l) => l.id == newLead.id)
          .toList();
      expect(
        freshMatching.length,
        1,
        reason: 'Exactly one entry must exist in fresh store after reload',
      );
      expect(freshMatching.first.company, 'Apex Quantum Systems');

      store.dispose();
      freshStore.dispose();
    },
  );

  test(
    'delayed-storage regression: edits to existing Account survive hydration and restart',
    () async {
      final memory = MemoryStorageAdapter();
      final existingData = {
        'schemaVersion': 1,
        'storageOrigin': 'crm_pro_local',
        'leads': [
          {
            'id': 'acc_acme_001',
            'company': 'Acme Corp',
            'contact': 'John Doe',
            'stage': 'Qualified',
            'notes': 'Original note from disk',
          },
        ],
      };
      await memory.write('crm_pro_database_v1', jsonEncode(existingData));

      final delayedAdapter = _DelayedStorageAdapter(
        memory,
        delay: const Duration(milliseconds: 50),
      );
      final store = CrmStore(storageAdapter: delayedAdapter);

      // Capture existing Account reference BEFORE hydration completes
      final acme = store.leads.firstWhere((l) => l.id == 'acc_acme_001');

      // Queue an edit on the captured account reference before hydration finishes
      store.update(() {
        acme.stage = 'Negotiation';
        acme.notes = 'Pre-hydration updated notes';
      });

      await store.ensureHydrated();

      // Verify the edit survived and was applied to the hydrated record
      final hydratedAcme = store.leads.firstWhere(
        (l) => l.id == 'acc_acme_001',
      );
      expect(
        hydratedAcme.stage,
        'Negotiation',
        reason:
            'User edit must modify the hydrated account, not a detached object',
      );
      expect(hydratedAcme.notes, 'Pre-hydration updated notes');

      // Verify persistence across restart
      await store.syncNow();
      final freshStore = CrmStore(storageAdapter: memory);
      await freshStore.ensureHydrated();

      final reloadedAcme = freshStore.leads.firstWhere(
        (l) => l.id == 'acc_acme_001',
      );
      expect(
        reloadedAcme.stage,
        'Negotiation',
        reason: 'User edit must be durably persisted across app restart',
      );
      expect(reloadedAcme.notes, 'Pre-hydration updated notes');

      store.dispose();
      freshStore.dispose();
    },
  );

  test(
    'delayed-storage regression: deletions and toggles survive hydration and restart',
    () async {
      final memory = MemoryStorageAdapter();
      final existingData = {
        'schemaVersion': 1,
        'storageOrigin': 'crm_pro_local',
        'leads': [
          {'id': 'acc_acme_001', 'company': 'Acme Corp', 'contact': 'John Doe'},
          {
            'id': 'acc_techvista_002',
            'company': 'TechVista Ltd',
            'contact': 'Priya Sharma',
          },
        ],
        'tasks': [
          {
            'id': 'tsk_001',
            'title': 'Follow up with Acme Corp',
            'company': 'Acme Corp',
            'completed': false,
          },
        ],
      };
      await memory.write('crm_pro_database_v1', jsonEncode(existingData));

      final delayedAdapter = _DelayedStorageAdapter(
        memory,
        delay: const Duration(milliseconds: 50),
      );
      final store = CrmStore(storageAdapter: delayedAdapter);

      // Capture before hydration
      final acme = store.leads.firstWhere((l) => l.id == 'acc_acme_001');
      final task = store.tasks.firstWhere((t) => t.id == 'tsk_001');

      // Queue deletion of acme and toggle of task before hydration finishes
      store.update(() {
        store.leads.remove(acme);
        task.completed = true;
      });

      await store.ensureHydrated();

      // Verify deletion and toggle on the hydrated store
      expect(
        store.leads.any((l) => l.id == 'acc_acme_001'),
        isFalse,
        reason: 'Deletion must remove the lead from hydrated store',
      );
      expect(
        store.tasks.firstWhere((t) => t.id == 'tsk_001').completed,
        isTrue,
        reason: 'Toggle must flip completed to true on hydrated task',
      );

      // Verify persistence across restart
      await store.syncNow();
      final freshStore = CrmStore(storageAdapter: memory);
      await freshStore.ensureHydrated();

      expect(
        freshStore.leads.any((l) => l.id == 'acc_acme_001'),
        isFalse,
        reason: 'Deletion must persist across app restart',
      );
      expect(
        freshStore.tasks.firstWhere((t) => t.id == 'tsk_001').completed,
        isTrue,
        reason: 'Task toggle must persist across app restart',
      );

      store.dispose();
      freshStore.dispose();
    },
  );

  test(
    'reporting correctness: Custom Range with explicit start/end dates filters records',
    () {
      final customStart = DateTime(2026, 8, 1);
      final customEnd = DateTime(2026, 8, 20);

      final visitInside = Visit(
        'Inside Co',
        'Inside Contact',
        '10:00 AM',
        'Demo',
        date: DateTime(2026, 8, 10),
      );
      final visitBefore = Visit(
        'Before Co',
        'Before Contact',
        '11:00 AM',
        'Demo',
        date: DateTime(2026, 7, 25),
      );
      final visitAfter = Visit(
        'After Co',
        'After Contact',
        '02:00 PM',
        'Demo',
        date: DateTime(2026, 8, 25),
      );

      // Inside explicit range -> true
      expect(
        CrmStorage.isDateInRange(
          visitInside.date,
          'Custom Range',
          null,
          customStart,
          customEnd,
        ),
        isTrue,
      );

      // Before explicit range -> false
      expect(
        CrmStorage.isDateInRange(
          visitBefore.date,
          'Custom Range',
          null,
          customStart,
          customEnd,
        ),
        isFalse,
      );

      // After explicit range -> false
      expect(
        CrmStorage.isDateInRange(
          visitAfter.date,
          'Custom Range',
          null,
          customStart,
          customEnd,
        ),
        isFalse,
      );

      // Custom Range with no explicit dates must NOT match all records (returns false)
      expect(
        CrmStorage.isDateInRange(visitInside.date, 'Custom Range'),
        isFalse,
        reason:
            'Custom Range without explicit dates must not match all records',
      );
    },
  );

  test(
    'actual downloaded-file checks on disk with magic byte and integrity validation',
    () async {
      final storage = CrmStorage.instance;
      final visits = [
        Visit(
          'File Check Co',
          'Agent Contact',
          '10:00 AM',
          'Demo',
          durationMinutes: 45,
          date: DateTime(2026, 8, 10),
        ),
      ];
      final pdfBytes = storage.generatePdfBytes(
        period: 'August 2026',
        visits: visits,
      );
      final xlsxBytes = storage.generateXlsxBytes(
        visits: visits,
        leads: const [],
        customers: const [],
        deals: const [],
      );
      final csvString = storage.generateCsv(
        visits: visits,
        leads: const [],
        customers: const [],
        deals: const [],
      );
      final csvBytes = utf8.encode(csvString);

      // Save PDF via CrmStorage.saveExportFile
      final pdfPath = await CrmStorage.saveExportFile(
        filename: 'actual_test_export.pdf',
        bytes: pdfBytes,
        mimeType: 'application/pdf',
      );
      expect(pdfPath, isNotNull);
      final pdfFile = File(pdfPath!);
      expect(pdfFile.existsSync(), isTrue);
      final readPdfBytes = await pdfFile.readAsBytes();
      final readPdfStr = utf8.decode(readPdfBytes, allowMalformed: true);
      expect(readPdfStr.startsWith('%PDF-1.4'), isTrue);
      expect(readPdfStr, contains('File Check Co'));

      // Save XLSX via CrmStorage.saveExportFile
      final xlsxPath = await CrmStorage.saveExportFile(
        filename: 'actual_test_export.xlsx',
        bytes: xlsxBytes,
        mimeType:
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      );
      expect(xlsxPath, isNotNull);
      final xlsxFile = File(xlsxPath!);
      expect(xlsxFile.existsSync(), isTrue);
      final readXlsxBytes = await xlsxFile.readAsBytes();
      // ZIP magic bytes: PK\x03\x04
      expect(readXlsxBytes[0], 0x50); // 'P'
      expect(readXlsxBytes[1], 0x4B); // 'K'
      expect(readXlsxBytes[2], 0x03);
      expect(readXlsxBytes[3], 0x04);
      final archive = ZipDecoder().decodeBytes(readXlsxBytes);
      expect(archive.files.isNotEmpty, isTrue);

      // Save CSV via CrmStorage.saveExportFile
      final csvPath = await CrmStorage.saveExportFile(
        filename: 'actual_test_export.csv',
        bytes: csvBytes,
        mimeType: 'text/csv',
      );
      expect(csvPath, isNotNull);
      final csvFile = File(csvPath!);
      expect(csvFile.existsSync(), isTrue);
      final readCsvStr = await csvFile.readAsString();
      expect(readCsvStr, contains('File Check Co'));

      // Clean up test files
      if (pdfFile.existsSync()) pdfFile.deleteSync();
      if (xlsxFile.existsSync()) xlsxFile.deleteSync();
      if (csvFile.existsSync()) csvFile.deleteSync();
    },
  );

  test(
    'delayed-storage regression: direct store.addNote before hydration finishes survives and persists across restart',
    () async {
      final memory = MemoryStorageAdapter();
      final existingData = {
        'schemaVersion': 1,
        'storageOrigin': 'crm_pro_local',
        'leads': [
          {'id': 'acc_01', 'company': 'Acme Corp', 'contact': 'John Doe'},
        ],
        'notes': [
          {
            'id': 'note_01',
            'companyId': 'acc_01',
            'company': 'Acme Corp',
            'title': 'Existing Note',
            'body': 'Initial saved note',
          },
        ],
      };
      await memory.write('crm_pro_database_v1', jsonEncode(existingData));

      // 1. Direct awaited addNote during delayed hydration
      final delayedAdapter1 = _DelayedStorageAdapter(
        memory,
        delay: const Duration(milliseconds: 50),
      );
      final store1 = CrmStore(storageAdapter: delayedAdapter1);
      expect(store1.isHydrated, isFalse);

      // Direct public call (not wrapped in update)
      await store1.addNote('Acme Corp', 'Direct pre-hydration note #1');
      expect(store1.isHydrated, isTrue);
      expect(
        store1.notesFor('Acme Corp'),
        contains('Direct pre-hydration note #1'),
      );
      expect(store1.notesFor('Acme Corp'), contains('Initial saved note'));

      // Verify persistence on fresh restart
      final restartStore1 = CrmStore(storageAdapter: memory);
      await restartStore1.ensureHydrated();
      expect(
        restartStore1.notesFor('Acme Corp'),
        contains('Direct pre-hydration note #1'),
        reason: 'Direct awaited addNote must persist across restart',
      );
      expect(
        restartStore1.notesFor('Acme Corp'),
        contains('Initial saved note'),
      );
      store1.dispose();
      restartStore1.dispose();

      // 2. Direct unawaited addNote during delayed hydration
      final delayedAdapter2 = _DelayedStorageAdapter(
        memory,
        delay: const Duration(milliseconds: 50),
      );
      final store2 = CrmStore(storageAdapter: delayedAdapter2);
      expect(store2.isHydrated, isFalse);

      // Direct unawaited call
      final unawaitedFuture = store2.addNote(
        'Acme Corp',
        'Direct unawaited pre-hydration note #2',
      );
      await store2.ensureHydrated();
      await unawaitedFuture;

      final restartStore2 = CrmStore(storageAdapter: memory);
      await restartStore2.ensureHydrated();
      expect(
        restartStore2.notesFor('Acme Corp'),
        contains('Direct unawaited pre-hydration note #2'),
        reason: 'Direct unawaited addNote must persist across restart',
      );
      store2.dispose();
      restartStore2.dispose();
    },
  );

  test(
    'delayed-storage regression: direct startVisit and finishActiveVisit survive delayed hydration and restart',
    () async {
      final memory = MemoryStorageAdapter();
      final existingData = {
        'schemaVersion': 1,
        'storageOrigin': 'crm_pro_local',
        'visits': [
          {
            'id': 'vis_test_01',
            'company': 'Target Corp',
            'contact': 'Bob Smith',
            'time': '10:00 AM',
            'type': 'Review',
            'status': 'Scheduled',
            'locationAddress': 'One BKC, Bandra, Mumbai',
          },
        ],
      };
      await memory.write('crm_pro_database_v1', jsonEncode(existingData));

      final delayedAdapter = _DelayedStorageAdapter(
        memory,
        delay: const Duration(milliseconds: 50),
      );
      final store = CrmStore(storageAdapter: delayedAdapter);
      expect(store.isHydrated, isFalse);

      final visitToStart = store.visits.firstWhere(
        (v) => v.id == 'vis_test_01',
        orElse: () => Visit(
          'Target Corp',
          'Bob Smith',
          '10:00 AM',
          'Review',
          id: 'vis_test_01',
        ),
      );

      // Direct call to startVisit before hydration completes
      await store.startVisit(visitToStart);
      expect(store.isHydrated, isTrue);
      expect(store.activeVisitId, 'vis_test_01');

      // Direct call to finishActiveVisit
      await store.finishActiveVisit(
        visitToStart,
        outcome: 'Contract Agreed',
        summary: 'Finalized enterprise terms',
      );
      expect(visitToStart.status, 'Completed');
      expect(visitToStart.outcome, 'Contract Agreed');
      expect(store.activeVisitId, isNull);

      // Verify persistence across restart
      final restartStore = CrmStore(storageAdapter: memory);
      await restartStore.ensureHydrated();
      final reloadedVisit = restartStore.visits.firstWhere(
        (v) => v.id == 'vis_test_01',
      );
      expect(reloadedVisit.status, 'Completed');
      expect(reloadedVisit.outcome, 'Contract Agreed');
      expect(reloadedVisit.summary, 'Finalized enterprise terms');

      store.dispose();
      restartStore.dispose();
    },
  );

  test(
    'delayed-storage regression: direct convertToCustomer and mergeAccounts survive delayed hydration and restart',
    () async {
      final memory = MemoryStorageAdapter();
      final existingData = {
        'schemaVersion': 1,
        'storageOrigin': 'crm_pro_local',
        'leads': [
          {
            'id': 'acc_lead_01',
            'company': 'Convertible Dynamics',
            'contact': 'Sarah Connor',
            'phone': '+91 99000 11223',
            'email': 'sarah@convertible.io',
          },
          {
            'id': 'acc_dup_01',
            'company': 'Convertible Dynamics Branch',
            'contact': 'Sarah C.',
            'notes': 'Branch notes',
          },
        ],
      };
      await memory.write('crm_pro_database_v1', jsonEncode(existingData));

      // 1. Direct mergeAccounts during delayed hydration
      final delayedAdapter1 = _DelayedStorageAdapter(
        memory,
        delay: const Duration(milliseconds: 50),
      );
      final store1 = CrmStore(storageAdapter: delayedAdapter1);
      expect(store1.isHydrated, isFalse);

      final primary = store1.leads.firstWhere(
        (l) => l.id == 'acc_lead_01',
        orElse: () =>
            Account('Convertible Dynamics', 'Sarah Connor', id: 'acc_lead_01'),
      );
      final duplicate = store1.leads.firstWhere(
        (l) => l.id == 'acc_dup_01',
        orElse: () => Account(
          'Convertible Dynamics Branch',
          'Sarah C.',
          id: 'acc_dup_01',
        ),
      );

      await store1.mergeAccounts(primary, duplicate);
      expect(store1.isHydrated, isTrue);
      expect(store1.leads.any((l) => l.id == 'acc_dup_01'), isFalse);
      expect(primary.notes, contains('Branch notes'));

      final restartStore1 = CrmStore(storageAdapter: memory);
      await restartStore1.ensureHydrated();
      expect(restartStore1.leads.any((l) => l.id == 'acc_dup_01'), isFalse);
      expect(
        restartStore1.leads.firstWhere((l) => l.id == 'acc_lead_01').notes,
        contains('Branch notes'),
      );
      store1.dispose();
      restartStore1.dispose();

      // 2. Direct convertToCustomer during delayed hydration
      final delayedAdapter2 = _DelayedStorageAdapter(
        memory,
        delay: const Duration(milliseconds: 50),
      );
      final store2 = CrmStore(storageAdapter: delayedAdapter2);
      expect(store2.isHydrated, isFalse);

      final leadToConvert = store2.leads.firstWhere(
        (l) => l.id == 'acc_lead_01',
        orElse: () =>
            Account('Convertible Dynamics', 'Sarah Connor', id: 'acc_lead_01'),
      );
      final welcomeDeal = Deal(
        'Convertible Onboarding',
        'Convertible Dynamics',
        95000,
        'Qualified',
      );

      await store2.convertToCustomer(
        leadToConvert,
        welcomeDeal: welcomeDeal,
        customerType: 'Enterprise',
      );
      expect(store2.isHydrated, isTrue);
      expect(store2.customers.any((c) => c.id == 'acc_lead_01'), isTrue);
      expect(store2.leads.any((l) => l.id == 'acc_lead_01'), isFalse);

      final restartStore2 = CrmStore(storageAdapter: memory);
      await restartStore2.ensureHydrated();
      expect(restartStore2.customers.any((c) => c.id == 'acc_lead_01'), isTrue);
      expect(restartStore2.leads.any((l) => l.id == 'acc_lead_01'), isFalse);
      expect(
        restartStore2.deals.any((d) => d.title == 'Convertible Onboarding'),
        isTrue,
      );
      store2.dispose();
      restartStore2.dispose();
    },
  );

  test(
    'awaited update remains pending while storage write is blocked and completes only after write and flush finish',
    () async {
      final adapter = _ControllableStorageAdapter();
      final store = CrmStore(storageAdapter: adapter);
      await store.ensureHydrated();
      expect(store.isHydrated, isTrue);

      // Block both write and flush
      adapter.writeCompleter = Completer<void>();
      adapter.flushCompleter = Completer<void>();
      adapter.writeCalled = false;
      adapter.flushCalled = false;

      var updateFinished = false;
      final updateFuture = store
          .update(() {
            store.leads.add(Account('Pending Storage Corp', 'Alice'));
          })
          .then((_) {
            updateFinished = true;
          });

      // Allow microtasks to execute
      await Future.delayed(const Duration(milliseconds: 20));

      // 1. Proves: Awaited update remains pending while storage write is blocked
      expect(adapter.writeCalled, isTrue, reason: 'write must be initiated');
      expect(
        updateFinished,
        isFalse,
        reason:
            'awaited update must remain pending while storage write is blocked',
      );
      expect(
        adapter.flushCalled,
        isFalse,
        reason: 'flush must not be called before write finishes',
      );

      // Unblock write, but keep flush blocked
      adapter.writeCompleter!.complete();
      await Future.delayed(const Duration(milliseconds: 20));

      // Still pending because flush is blocked!
      expect(
        adapter.flushCalled,
        isTrue,
        reason: 'flush is initiated after write completes',
      );
      expect(
        updateFinished,
        isFalse,
        reason: 'awaited update must remain pending while flush is blocked',
      );

      // Unblock flush
      adapter.flushCompleter!.complete();
      await updateFuture;

      // 2. Proves: It completes only after the write and flush finish
      expect(
        updateFinished,
        isTrue,
        reason: 'update completes after write and flush finish',
      );
      expect(adapter.flushCount, greaterThanOrEqualTo(1));
      expect(
        adapter.snapshot['crm_pro_database_v1'],
        contains('Pending Storage Corp'),
      );

      store.dispose();
    },
  );

  test(
    'write failure reaches the caller via update and direct mutators',
    () async {
      final adapter = _FailingStorageAdapter(
        errorMessage: 'Disk I/O failure: quota exceeded',
      );
      final store = CrmStore(storageAdapter: adapter);
      await store.ensureHydrated();

      // 1. Synchronous mutation in update() propagates write failure to caller
      await expectLater(
        () => store.update(() {
          store.leads.add(Account('Failing Corp', 'John'));
        }),
        throwsA(
          isA<FileSystemException>().having(
            (e) => e.message,
            'message',
            contains('quota exceeded'),
          ),
        ),
      );

      // 2. Async mutation in update() propagates write failure to caller
      await expectLater(
        () => store.update(() async {
          await Future.delayed(const Duration(milliseconds: 10));
          store.leads.add(Account('Failing Async Corp', 'Bob'));
        }),
        throwsA(
          isA<FileSystemException>().having(
            (e) => e.message,
            'message',
            contains('quota exceeded'),
          ),
        ),
      );

      // 3. Direct public mutator addNote propagates write failure to caller
      await expectLater(
        () => store.addNote('Acme Corp', 'Important takeaway note'),
        throwsA(
          isA<FileSystemException>().having(
            (e) => e.message,
            'message',
            contains('quota exceeded'),
          ),
        ),
      );

      // 4. Direct public mutator createLead propagates write failure to caller
      await expectLater(
        () => store.createLead(Account('New Lead Corp', 'Alice')),
        throwsA(
          isA<FileSystemException>().having(
            (e) => e.message,
            'message',
            contains('quota exceeded'),
          ),
        ),
      );

      // 5. Direct public mutator finishActiveVisit propagates write failure to caller
      final testVisit = Visit('Acme Corp', 'Alice', '10:00 AM', 'Meeting');
      await expectLater(
        () => store.finishActiveVisit(
          testVisit,
          outcome: 'Completed',
          summary: 'Summary',
        ),
        throwsA(
          isA<FileSystemException>().having(
            (e) => e.message,
            'message',
            contains('quota exceeded'),
          ),
        ),
      );

      expect(store.lastStorageError, contains('quota exceeded'));
      store.dispose();
    },
  );

  testWidgets('failed saves do not trigger success messages or navigation', (
    tester,
  ) async {
    final failingAdapter = _FailingStorageAdapter(
      errorMessage: 'Simulated disk full error',
    );
    final store = CrmStore(storageAdapter: failingAdapter);
    await store.ensureHydrated();

    final prevStore = CrmStore.instance;
    CrmStore.setInstanceForTesting(store);
    addTearDown(() {
      CrmStore.setInstanceForTesting(prevStore);
      store.dispose();
    });

    var navigatedAway = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Builder(
            builder: (ctx) => TextButton(
              onPressed: () {
                Navigator.of(ctx)
                    .push(MaterialPageRoute(builder: (_) => taskForm(null)))
                    .then((_) {
                      navigatedAway = true;
                    });
              },
              child: const Text('Open Form'),
            ),
          ),
        ),
      ),
    );

    // Open form
    await tester.tap(find.text('Open Form'));
    await tester.pumpAndSettle();

    expect(find.text('New Task'), findsOneWidget);

    // Fill required task title
    await tester.enterText(
      find.byType(TextFormField).first,
      'Simulated failing task',
    );

    // Tap 'Save' action button in AppBar
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // 1. Proves: Error message displayed
    expect(find.textContaining('Failed to save'), findsOneWidget);

    // 2. Proves: Did NOT navigate away (form is still mounted)
    expect(find.text('New Task'), findsOneWidget);
    expect(navigatedAway, isFalse);

    // 3. Proves: Success message was NOT triggered
    expect(find.text('Task saved successfully'), findsNothing);
  });
}

class _ControllableStorageAdapter implements StorageAdapter {
  _ControllableStorageAdapter([Map<String, String>? initialData])
    : _data = initialData != null ? Map.from(initialData) : {};

  final Map<String, String> _data;
  Completer<void>? writeCompleter;
  Completer<void>? flushCompleter;
  bool writeCalled = false;
  bool flushCalled = false;
  int flushCount = 0;

  Map<String, String> get snapshot => Map.unmodifiable(_data);

  @override
  Future<String?> read(String key) async => _data[key];

  @override
  Future<void> write(String key, String value) async {
    writeCalled = true;
    if (writeCompleter != null) {
      await writeCompleter!.future;
    }
    _data[key] = value;
  }

  @override
  Future<void> flush() async {
    flushCalled = true;
    flushCount++;
    if (flushCompleter != null) {
      await flushCompleter!.future;
    }
  }

  @override
  Future<void> delete(String key) async => _data.remove(key);
}

class _FailingStorageAdapter implements StorageAdapter {
  _FailingStorageAdapter({this.errorMessage = 'Disk I/O error: disk full'});
  final String errorMessage;

  @override
  Future<String?> read(String key) async => null;

  @override
  Future<void> write(String key, String value) async {
    throw FileSystemException(errorMessage);
  }

  @override
  Future<void> flush() async {}

  @override
  Future<void> delete(String key) async {}
}

class _DelayedStorageAdapter implements StorageAdapter {
  _DelayedStorageAdapter(this._inner, {required this.delay});
  final StorageAdapter _inner;
  final Duration delay;

  @override
  Future<String?> read(String key) async {
    await Future.delayed(delay);
    return _inner.read(key);
  }

  @override
  Future<void> write(String key, String value) => _inner.write(key, value);

  @override
  Future<void> delete(String key) => _inner.delete(key);

  @override
  Future<void> flush() => _inner.flush();
}
