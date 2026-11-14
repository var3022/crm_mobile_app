import 'dart:convert';
import 'dart:io' show Directory, File, Platform;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:archive/archive.dart';

import 'crm_models.dart';
import 'crm_storage_adapter.dart';
import 'crm_storage_web.dart'
    if (dart.library.io) 'crm_storage_io.dart'
    as impl;
import 'file_saver_stub.dart'
    if (dart.library.js_interop) 'file_saver_web.dart'
    if (dart.library.io) 'file_saver_io.dart'
    as saver;

/// Storage and export subsystem for CRM Pro.
class CrmStorage {
  CrmStorage({StorageAdapter? adapter})
    : _adapter = adapter ?? impl.createStorageAdapter();

  static final CrmStorage instance = CrmStorage();
  final StorageAdapter _adapter;

  static const _storageKey = 'crm_pro_database_v1';
  static const int currentSchemaVersion = 1;

  StorageAdapter get adapter => _adapter;

  /// Save the entire state as structured JSON with schema version and origin metadata.
  Future<void> saveDatabase({
    required List<Account> leads,
    required List<Account> customers,
    required List<Deal> deals,
    required List<Visit> visits,
    required List<CrmTask> tasks,
    required List<CrmNote> notes,
    required List<CrmActivity> activities,
    required List<PhotoRecord> photos,
    required List<VoiceNoteRecord> voiceNotes,
    required UserProfile profile,
    required AppSettings settings,
    required List<String> recentSearches,
    DateTime? activeVisitStart,
    String? activeVisitId,
  }) async {
    final data = {
      'schemaVersion': currentSchemaVersion,
      'storageOrigin': 'crm_pro_local',
      'savedAt': DateTime.now().toIso8601String(),
      'leads': leads.map((a) => a.toJson()).toList(),
      'customers': customers.map((a) => a.toJson()).toList(),
      'deals': deals.map((d) => d.toJson()).toList(),
      'visits': visits.map((v) => v.toJson()).toList(),
      'tasks': tasks.map((t) => t.toJson()).toList(),
      'notes': notes.map((n) => n.toJson()).toList(),
      'activities': activities.map((a) => a.toJson()).toList(),
      'photos': photos.map((p) => p.toJson()).toList(),
      'voiceNotes': voiceNotes.map((v) => v.toJson()).toList(),
      'profile': profile.toJson(),
      'settings': settings.toJson(),
      'recentSearches': recentSearches,
      'activeVisitStart': activeVisitStart?.toIso8601String(),
      'activeVisitId': activeVisitId,
    };
    await _adapter.write(_storageKey, jsonEncode(data));
    await _adapter.flush();
  }

  /// Load existing database or null if not yet persisted.
  Future<Map<String, dynamic>?> loadDatabase() async {
    try {
      final raw = await _adapter.read(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        return decoded;
      }
    } catch (_) {}
    return null;
  }

  /// Delete persisted data.
  Future<void> clearDatabase() async {
    await _adapter.delete(_storageKey);
  }

  // =========================================================================
  // RFC 4180 CSV GENERATOR
  // =========================================================================

  static String _escapeCsv(dynamic value) {
    if (value == null) return '';
    final s = value.toString();
    if (s.contains(',') ||
        s.contains('"') ||
        s.contains('\n') ||
        s.contains('\r')) {
      return '"${s.replaceAll('"', '""')}"';
    }
    return s;
  }

  /// Generates genuine RFC 4180 compliant CSV string with proper escaping and CRLF line breaks.
  String generateCsv({
    required List<Account> leads,
    required List<Account> customers,
    required List<Deal> deals,
    required List<Visit> visits,
  }) {
    final buffer = StringBuffer();
    const crlf = '\r\n';

    // Header 1: Accounts
    buffer.write('=== LEADS & CUSTOMERS ===$crlf');
    buffer.write(
      'ID,Company,Contact,Role,Stage,Type,Score,Phone,Email,Area,Value$crlf',
    );
    for (final a in [...leads, ...customers]) {
      buffer.write(
        [
              _escapeCsv(a.id),
              _escapeCsv(a.company),
              _escapeCsv(a.contact),
              _escapeCsv(a.role),
              _escapeCsv(a.stage),
              _escapeCsv(a.isCustomer ? 'Customer' : 'Lead'),
              _escapeCsv(a.score),
              _escapeCsv(a.phone),
              _escapeCsv(a.email),
              _escapeCsv(a.area),
              _escapeCsv(a.accountValue),
            ].join(',') +
            crlf,
      );
    }

    buffer.write(crlf);
    buffer.write('=== DEALS ===$crlf');
    buffer.write(
      'ID,Title,Company,Value,Stage,Probability,CloseDate,Owner$crlf',
    );
    for (final d in deals) {
      final closeStr = d.closeDate?.toIso8601String().split('T').first ?? '';
      buffer.write(
        [
              _escapeCsv(d.id),
              _escapeCsv(d.title),
              _escapeCsv(d.company),
              _escapeCsv(d.value),
              _escapeCsv(d.stage),
              _escapeCsv('${d.probability}%'),
              _escapeCsv(closeStr),
              _escapeCsv(d.owner),
            ].join(',') +
            crlf,
      );
    }

    buffer.write(crlf);
    buffer.write('=== VISITS ===$crlf');
    buffer.write(
      'ID,Company,Contact,Date,Time,Type,Status,Duration,Outcome$crlf',
    );
    for (final v in visits) {
      final dateStr = v.date.toIso8601String().split('T').first;
      buffer.write(
        [
              _escapeCsv(v.id),
              _escapeCsv(v.company),
              _escapeCsv(v.contact),
              _escapeCsv(dateStr),
              _escapeCsv(v.time),
              _escapeCsv(v.type),
              _escapeCsv(v.status),
              _escapeCsv(v.duration),
              _escapeCsv(v.outcome),
            ].join(',') +
            crlf,
      );
    }

    return buffer.toString();
  }

  // =========================================================================
  // GENUINE BINARY XLSX WORKBOOK GENERATOR
  // =========================================================================

  static String _xmlEscape(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  /// Generates genuine Open Packaging Convention (OPC) ZIP XLSX bytes.
  Uint8List generateXlsxBytes({
    required List<Account> leads,
    required List<Account> customers,
    required List<Deal> deals,
    required List<Visit> visits,
  }) {
    final archive = Archive();

    // 1. [Content_Types].xml
    const contentTypesXml =
        '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>
  <Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>
  <Override PartName="/xl/worksheets/sheet2.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>
  <Override PartName="/xl/worksheets/sheet3.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>
  <Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>
</Types>''';
    archive.addFile(
      ArchiveFile(
        '[Content_Types].xml',
        contentTypesXml.length,
        utf8.encode(contentTypesXml),
      ),
    );

    // 2. _rels/.rels
    const rootRelsXml =
        '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>
</Relationships>''';
    archive.addFile(
      ArchiveFile('_rels/.rels', rootRelsXml.length, utf8.encode(rootRelsXml)),
    );

    // 3. xl/_rels/workbook.xml.rels
    const workbookRelsXml =
        '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet2.xml"/>
  <Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet3.xml"/>
  <Relationship Id="rId4" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
</Relationships>''';
    archive.addFile(
      ArchiveFile(
        'xl/_rels/workbook.xml.rels',
        workbookRelsXml.length,
        utf8.encode(workbookRelsXml),
      ),
    );

    // 4. xl/workbook.xml
    const workbookXml =
        '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
  <sheets>
    <sheet name="Leads &amp; Customers" sheetId="1" r:id="rId1"/>
    <sheet name="Deals Pipeline" sheetId="2" r:id="rId2"/>
    <sheet name="Field Visits" sheetId="3" r:id="rId3"/>
  </sheets>
</workbook>''';
    archive.addFile(
      ArchiveFile(
        'xl/workbook.xml',
        workbookXml.length,
        utf8.encode(workbookXml),
      ),
    );

    // 5. xl/styles.xml
    const stylesXml = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
  <fonts count="1"><font><sz val="11"/><name val="Calibri"/></font></fonts>
  <fills count="2"><fill><patternFill patternType="none"/></fill><fill><patternFill patternType="gray125"/></fill></fills>
  <borders count="1"><border><left/><right/><top/><bottom/></border></borders>
  <cellStyleXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/></cellStyleXfs>
  <cellXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/></cellXfs>
</styleSheet>''';
    archive.addFile(
      ArchiveFile('xl/styles.xml', stylesXml.length, utf8.encode(stylesXml)),
    );

    // 6. Sheet 1: Leads & Customers
    final sheet1Sb = StringBuffer();
    sheet1Sb.writeln('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>');
    sheet1Sb.writeln(
      '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">',
    );
    sheet1Sb.writeln('<sheetData>');
    sheet1Sb.writeln('<row r="1">');
    sheet1Sb.writeln('<c r="A1" t="inlineStr"><is><t>ID</t></is></c>');
    sheet1Sb.writeln('<c r="B1" t="inlineStr"><is><t>Company</t></is></c>');
    sheet1Sb.writeln('<c r="C1" t="inlineStr"><is><t>Contact</t></is></c>');
    sheet1Sb.writeln('<c r="D1" t="inlineStr"><is><t>Role</t></is></c>');
    sheet1Sb.writeln('<c r="E1" t="inlineStr"><is><t>Stage</t></is></c>');
    sheet1Sb.writeln('<c r="F1" t="inlineStr"><is><t>Type</t></is></c>');
    sheet1Sb.writeln('<c r="G1" t="inlineStr"><is><t>Phone</t></is></c>');
    sheet1Sb.writeln('<c r="H1" t="inlineStr"><is><t>Email</t></is></c>');
    sheet1Sb.writeln(
      '<c r="I1" t="inlineStr"><is><t>Account Value</t></is></c>',
    );
    sheet1Sb.writeln('</row>');

    var rowIdx = 2;
    for (final a in [...leads, ...customers]) {
      sheet1Sb.writeln('<row r="$rowIdx">');
      sheet1Sb.writeln(
        '<c r="A$rowIdx" t="inlineStr"><is><t>${_xmlEscape(a.id)}</t></is></c>',
      );
      sheet1Sb.writeln(
        '<c r="B$rowIdx" t="inlineStr"><is><t>${_xmlEscape(a.company)}</t></is></c>',
      );
      sheet1Sb.writeln(
        '<c r="C$rowIdx" t="inlineStr"><is><t>${_xmlEscape(a.contact)}</t></is></c>',
      );
      sheet1Sb.writeln(
        '<c r="D$rowIdx" t="inlineStr"><is><t>${_xmlEscape(a.role)}</t></is></c>',
      );
      sheet1Sb.writeln(
        '<c r="E$rowIdx" t="inlineStr"><is><t>${_xmlEscape(a.stage)}</t></is></c>',
      );
      sheet1Sb.writeln(
        '<c r="F$rowIdx" t="inlineStr"><is><t>${a.isCustomer ? "Customer" : "Lead"}</t></is></c>',
      );
      sheet1Sb.writeln(
        '<c r="G$rowIdx" t="inlineStr"><is><t>${_xmlEscape(a.phone)}</t></is></c>',
      );
      sheet1Sb.writeln(
        '<c r="H$rowIdx" t="inlineStr"><is><t>${_xmlEscape(a.email)}</t></is></c>',
      );
      sheet1Sb.writeln('<c r="I$rowIdx"><v>${a.accountValue}</v></c>');
      sheet1Sb.writeln('</row>');
      rowIdx++;
    }
    sheet1Sb.writeln('</sheetData></worksheet>');
    final sheet1Xml = sheet1Sb.toString();
    archive.addFile(
      ArchiveFile(
        'xl/worksheets/sheet1.xml',
        sheet1Xml.length,
        utf8.encode(sheet1Xml),
      ),
    );

    // 7. Sheet 2: Deals Pipeline
    final sheet2Sb = StringBuffer();
    sheet2Sb.writeln('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>');
    sheet2Sb.writeln(
      '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">',
    );
    sheet2Sb.writeln('<sheetData>');
    sheet2Sb.writeln('<row r="1">');
    sheet2Sb.writeln('<c r="A1" t="inlineStr"><is><t>Deal ID</t></is></c>');
    sheet2Sb.writeln('<c r="B1" t="inlineStr"><is><t>Title</t></is></c>');
    sheet2Sb.writeln('<c r="C1" t="inlineStr"><is><t>Company</t></is></c>');
    sheet2Sb.writeln('<c r="D1" t="inlineStr"><is><t>Value</t></is></c>');
    sheet2Sb.writeln('<c r="E1" t="inlineStr"><is><t>Stage</t></is></c>');
    sheet2Sb.writeln('<c r="F1" t="inlineStr"><is><t>Probability</t></is></c>');
    sheet2Sb.writeln('</row>');

    rowIdx = 2;
    for (final d in deals) {
      sheet2Sb.writeln('<row r="$rowIdx">');
      sheet2Sb.writeln(
        '<c r="A$rowIdx" t="inlineStr"><is><t>${_xmlEscape(d.id)}</t></is></c>',
      );
      sheet2Sb.writeln(
        '<c r="B$rowIdx" t="inlineStr"><is><t>${_xmlEscape(d.title)}</t></is></c>',
      );
      sheet2Sb.writeln(
        '<c r="C$rowIdx" t="inlineStr"><is><t>${_xmlEscape(d.company)}</t></is></c>',
      );
      sheet2Sb.writeln('<c r="D$rowIdx"><v>${d.value}</v></c>');
      sheet2Sb.writeln(
        '<c r="E$rowIdx" t="inlineStr"><is><t>${_xmlEscape(d.stage)}</t></is></c>',
      );
      sheet2Sb.writeln('<c r="F$rowIdx"><v>${d.probability}</v></c>');
      sheet2Sb.writeln('</row>');
      rowIdx++;
    }
    sheet2Sb.writeln('</sheetData></worksheet>');
    final sheet2Xml = sheet2Sb.toString();
    archive.addFile(
      ArchiveFile(
        'xl/worksheets/sheet2.xml',
        sheet2Xml.length,
        utf8.encode(sheet2Xml),
      ),
    );

    // 8. Sheet 3: Visits
    final sheet3Sb = StringBuffer();
    sheet3Sb.writeln('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>');
    sheet3Sb.writeln(
      '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">',
    );
    sheet3Sb.writeln('<sheetData>');
    sheet3Sb.writeln('<row r="1">');
    sheet3Sb.writeln('<c r="A1" t="inlineStr"><is><t>Visit ID</t></is></c>');
    sheet3Sb.writeln('<c r="B1" t="inlineStr"><is><t>Company</t></is></c>');
    sheet3Sb.writeln('<c r="C1" t="inlineStr"><is><t>Contact</t></is></c>');
    sheet3Sb.writeln('<c r="D1" t="inlineStr"><is><t>Date</t></is></c>');
    sheet3Sb.writeln('<c r="E1" t="inlineStr"><is><t>Status</t></is></c>');
    sheet3Sb.writeln('<c r="F1" t="inlineStr"><is><t>Duration</t></is></c>');
    sheet3Sb.writeln('<c r="G1" t="inlineStr"><is><t>Outcome</t></is></c>');
    sheet3Sb.writeln('</row>');

    rowIdx = 2;
    for (final v in visits) {
      final dateStr = v.date.toIso8601String().split('T').first;
      sheet3Sb.writeln('<row r="$rowIdx">');
      sheet3Sb.writeln(
        '<c r="A$rowIdx" t="inlineStr"><is><t>${_xmlEscape(v.id)}</t></is></c>',
      );
      sheet3Sb.writeln(
        '<c r="B$rowIdx" t="inlineStr"><is><t>${_xmlEscape(v.company)}</t></is></c>',
      );
      sheet3Sb.writeln(
        '<c r="C$rowIdx" t="inlineStr"><is><t>${_xmlEscape(v.contact)}</t></is></c>',
      );
      sheet3Sb.writeln(
        '<c r="D$rowIdx" t="inlineStr"><is><t>$dateStr</t></is></c>',
      );
      sheet3Sb.writeln(
        '<c r="E$rowIdx" t="inlineStr"><is><t>${_xmlEscape(v.status)}</t></is></c>',
      );
      sheet3Sb.writeln(
        '<c r="F$rowIdx" t="inlineStr"><is><t>${_xmlEscape(v.duration)}</t></is></c>',
      );
      sheet3Sb.writeln(
        '<c r="G$rowIdx" t="inlineStr"><is><t>${_xmlEscape(v.outcome)}</t></is></c>',
      );
      sheet3Sb.writeln('</row>');
      rowIdx++;
    }
    sheet3Sb.writeln('</sheetData></worksheet>');
    final sheet3Xml = sheet3Sb.toString();
    archive.addFile(
      ArchiveFile(
        'xl/worksheets/sheet3.xml',
        sheet3Xml.length,
        utf8.encode(sheet3Xml),
      ),
    );

    final zipBytes = ZipEncoder().encode(archive);
    return Uint8List.fromList(zipBytes!);
  }

  /// Backward-compatible alias returning XML SpreadsheetML string.
  String generateXlsxSpreadsheet({
    required List<Account> leads,
    required List<Account> customers,
    required List<Deal> deals,
    required List<Visit> visits,
  }) {
    final sb = StringBuffer();
    sb.writeln('<?xml version="1.0"?>');
    sb.writeln('<?mso-application progid="Excel.Sheet"?>');
    sb.writeln(
      '<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"',
    );
    sb.writeln(' xmlns:o="urn:schemas-microsoft-com:office:office"');
    sb.writeln(' xmlns:x="urn:schemas-microsoft-com:office:excel"');
    sb.writeln(' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet">');

    // Leads Sheet
    sb.writeln('<Worksheet ss:Name="Leads">');
    sb.writeln('<Table>');
    sb.writeln(
      '<Row><Cell><Data ss:Type="String">Company</Data></Cell><Cell><Data ss:Type="String">Contact</Data></Cell><Cell><Data ss:Type="String">Stage</Data></Cell><Cell><Data ss:Type="Number">AI Score</Data></Cell><Cell><Data ss:Type="String">Phone</Data></Cell><Cell><Data ss:Type="String">Email</Data></Cell></Row>',
    );
    for (final a in leads) {
      sb.writeln(
        '<Row><Cell><Data ss:Type="String">${_xmlEscape(a.company)}</Data></Cell><Cell><Data ss:Type="String">${_xmlEscape(a.contact)}</Data></Cell><Cell><Data ss:Type="String">${_xmlEscape(a.stage)}</Data></Cell><Cell><Data ss:Type="Number">${a.score}</Data></Cell><Cell><Data ss:Type="String">${_xmlEscape(a.phone)}</Data></Cell><Cell><Data ss:Type="String">${_xmlEscape(a.email)}</Data></Cell></Row>',
      );
    }
    sb.writeln('</Table></Worksheet>');

    // Deals Sheet
    sb.writeln('<Worksheet ss:Name="Deals">');
    sb.writeln('<Table>');
    sb.writeln(
      '<Row><Cell><Data ss:Type="String">Deal Title</Data></Cell><Cell><Data ss:Type="String">Company</Data></Cell><Cell><Data ss:Type="Number">Value</Data></Cell><Cell><Data ss:Type="String">Stage</Data></Cell><Cell><Data ss:Type="String">Probability</Data></Cell></Row>',
    );
    for (final d in deals) {
      sb.writeln(
        '<Row><Cell><Data ss:Type="String">${_xmlEscape(d.title)}</Data></Cell><Cell><Data ss:Type="String">${_xmlEscape(d.company)}</Data></Cell><Cell><Data ss:Type="Number">${d.value}</Data></Cell><Cell><Data ss:Type="String">${_xmlEscape(d.stage)}</Data></Cell><Cell><Data ss:Type="String">${d.probability}%</Data></Cell></Row>',
      );
    }
    sb.writeln('</Table></Worksheet>');

    sb.writeln('</Workbook>');
    return sb.toString();
  }

  String generateSpreadsheetXml({
    required List<Account> leads,
    required List<Account> customers,
    required List<Deal> deals,
    required List<Visit> visits,
  }) => generateXlsxSpreadsheet(
    leads: leads,
    customers: customers,
    deals: deals,
    visits: visits,
  );

  // =========================================================================
  // REPORTING METRICS & DATE FILTERING HELPERS
  // =========================================================================

  /// Evaluates whether a date falls within the selected period window.
  /// Supports 'This Week', 'This Month', 'Quarter 3' / 'This Quarter', 'All Time',
  /// and explicit 'Custom Range' with optional startDate and endDate parameters.
  static bool isDateInRange(
    DateTime date,
    String period, [
    DateTime? referenceDate,
    DateTime? startDate,
    DateTime? endDate,
  ]) {
    final now = referenceDate ?? DateTime.now();
    final p = period.toLowerCase().trim();

    if (p.contains('custom')) {
      if (startDate != null || endDate != null) {
        final start = startDate != null
            ? DateTime(startDate.year, startDate.month, startDate.day)
            : DateTime(1970);
        final end = endDate != null
            ? DateTime(
                endDate.year,
                endDate.month,
                endDate.day,
                23,
                59,
                59,
                999,
              )
            : DateTime(2099);
        return !date.isBefore(start) && !date.isAfter(end);
      }
      return false; // Does not match all records when explicit dates are absent or unselected
    }

    if (p.contains('all')) return true;

    if (p.contains('week')) {
      final startOfWeek = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 7));
      return !date.isBefore(startOfWeek) && date.isBefore(endOfWeek);
    }

    if (p.contains('month')) {
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 1);
      return !date.isBefore(startOfMonth) && date.isBefore(endOfMonth);
    }

    if (p.contains('quarter') || p.contains('q')) {
      if (p.contains('quarter 3') || p.contains('q3')) {
        final startOfQ3 = DateTime(now.year, 7, 1);
        final endOfQ3 = DateTime(now.year, 10, 1);
        return !date.isBefore(startOfQ3) && date.isBefore(endOfQ3);
      }
      final qMonth = ((now.month - 1) ~/ 3) * 3 + 1;
      final startOfQuarter = DateTime(now.year, qMonth, 1);
      final endOfQuarter = DateTime(now.year, qMonth + 3, 1);
      return !date.isBefore(startOfQuarter) && date.isBefore(endOfQuarter);
    }

    return true;
  }

  /// Extracts or parses duration in minutes from a Visit record.
  static int parseDurationMinutes(Visit v) {
    if (v.durationMinutes > 0) return v.durationMinutes;
    final text = v.duration.toLowerCase().trim();
    if (text.isEmpty) return 0;
    var total = 0;
    final hourMatch = RegExp(r'(\d+)\s*(?:h|hour|hr)').firstMatch(text);
    if (hourMatch != null) {
      total += int.parse(hourMatch.group(1)!) * 60;
    }
    final minMatch = RegExp(r'(\d+)\s*(?:m|min|minute)').firstMatch(text);
    if (minMatch != null) {
      total += int.parse(minMatch.group(1)!);
    }
    if (total == 0) {
      final numOnly = int.tryParse(text.replaceAll(RegExp(r'\D'), ''));
      if (numOnly != null) total = numOnly;
    }
    return total;
  }

  /// Calculates and formats the average duration from actual visits.
  static String formatAverageDuration(List<Visit> visits) {
    if (visits.isEmpty) return 'N/A';
    final validVisits = visits
        .where((v) => parseDurationMinutes(v) > 0)
        .toList();
    if (validVisits.isEmpty) return '0 min';
    final totalMins = validVisits.fold<int>(
      0,
      (sum, v) => sum + parseDurationMinutes(v),
    );
    final avgMins = (totalMins / validVisits.length).round();
    if (avgMins == 0) return '0 min';
    if (avgMins < 60) return '$avgMins min';
    final hours = avgMins ~/ 60;
    final mins = avgMins % 60;
    return mins == 0 ? '${hours}h' : '${hours}h ${mins}m';
  }

  // =========================================================================
  // MULTI-PAGE BINARY PDF 1.4 GENERATOR (WINANSI COMPATIBLE)
  // =========================================================================

  static String _pdfEscape(String text) {
    // Transliterate non-ASCII characters to standard WinAnsi equivalents
    final clean = text
        .replaceAll('₹', 'INR ')
        .replaceAll('–', '-')
        .replaceAll('—', '-')
        .replaceAll('“', '"')
        .replaceAll('”', '"')
        .replaceAll('’', "'")
        .replaceAll('‘', "'");
    return clean
        .replaceAll('\\', '\\\\')
        .replaceAll('(', '\\(')
        .replaceAll(')', '\\)');
  }

  /// Generates genuine ISO 32000-1 / PDF 1.4 binary file bytes with complete multi-page pagination.
  Uint8List generatePdfBytes({
    String period = 'Current Month',
    int visitsGoalMet = 0,
    int visitsGoalTotal = 0,
    double revenueMet = 0.0,
    double revenueGoal = 5.0,
    double? conversionRate,
    String avgDuration = 'N/A',
    List<Account>? leads,
    List<Account>? customers,
    List<Deal> deals = const [],
    List<Visit> visits = const [],
    UserProfile? profile,
    bool includeCharts = true,
    bool includeRawData = true,
    bool includeSummary = true,
  }) {
    final pageStreams = <String>[];
    var cs = StringBuffer();

    // Page 1 Header Banner
    cs.writeln('q 0.0588 0.298 0.298 rg 40 730 532 45 re f Q');
    cs.writeln(
      'BT /F2 16 Tf 1 1 1 rg 52 750 Td (${_pdfEscape("CRM PRO FIELD SALES REPORT")}) Tj ET',
    );
    cs.writeln(
      'BT /F1 9 Tf 0.85 0.95 0.95 rg 52 738 Td (${_pdfEscape("Period: $period  |  Generated: ${DateTime.now().toLocal().toString().split(".")[0]}")}) Tj ET',
    );

    var y = 705;

    if (includeSummary) {
      cs.writeln(
        'BT /F2 12 Tf 0.1 0.1 0.1 rg 40 $y Td (${_pdfEscape("EXECUTIVE SUMMARY")}) Tj ET',
      );
      y -= 16;
      final visitsPct = visitsGoalTotal > 0
          ? (visitsGoalMet / visitsGoalTotal * 100).round()
          : 0;
      final revPct = revenueGoal > 0
          ? (revenueMet / revenueGoal * 100).round()
          : 0;
      final convText = conversionRate != null
          ? '${conversionRate.toStringAsFixed(1)}%'
          : 'N/A';

      cs.writeln(
        'BT /F1 9.5 Tf 0.2 0.2 0.2 rg 50 $y Td (${_pdfEscape("Visits Completed: $visitsGoalMet / $visitsGoalTotal ($visitsPct%)")}) Tj ET',
      );
      y -= 13;
      cs.writeln(
        'BT /F1 9.5 Tf 0.2 0.2 0.2 rg 50 $y Td (${_pdfEscape("Revenue Closed:   INR ${revenueMet.toStringAsFixed(1)}L / INR ${revenueGoal.toStringAsFixed(1)}L ($revPct%)")}) Tj ET',
      );
      y -= 13;
      cs.writeln(
        'BT /F1 9.5 Tf 0.2 0.2 0.2 rg 50 $y Td (${_pdfEscape("Conversion Rate:  $convText   |   Average Visit Duration: $avgDuration")}) Tj ET',
      );
      y -= 20;
    }

    if (includeCharts) {
      cs.writeln(
        'BT /F2 12 Tf 0.1 0.1 0.1 rg 40 $y Td (${_pdfEscape("PIPELINE STAGE BREAKDOWN")}) Tj ET',
      );
      y -= 16;
      if (deals.isEmpty) {
        cs.writeln(
          'BT /F1 9 Tf 0.4 0.4 0.4 rg 50 $y Td (${_pdfEscape("No deals in selected period")}) Tj ET',
        );
        y -= 20;
      } else {
        for (final stage in [
          'Qualified',
          'Discovery',
          'Proposal',
          'Negotiation',
          'Won',
          'Lost',
        ]) {
          final count = deals.where((d) => d.stage == stage).length;
          final barWidth = count > 0 ? (count * 25).clamp(4, 200) : 0;
          cs.writeln(
            'BT /F1 9 Tf 0.2 0.2 0.2 rg 50 $y Td (${_pdfEscape(stage.padRight(12))}) Tj ET',
          );
          if (barWidth > 0) {
            cs.writeln(
              'q 0.063 0.725 0.506 rg 120 ${y - 2} $barWidth 9 re f Q',
            );
          }
          cs.writeln(
            'BT /F1 9 Tf 0.4 0.4 0.4 rg ${125 + barWidth} $y Td (${_pdfEscape("$count deals")}) Tj ET',
          );
          y -= 13;
        }
        y -= 14;
      }
    }

    void drawTableHeader(StringBuffer buffer, int currentY, String title) {
      buffer.writeln(
        'BT /F2 12 Tf 0.1 0.1 0.1 rg 40 $currentY Td (${_pdfEscape(title)}) Tj ET',
      );
      final headerY = currentY - 16;
      buffer.writeln('q 0.9 0.9 0.9 rg 40 ${headerY - 4} 532 14 re f Q');
      buffer.writeln(
        'BT /F2 9 Tf 0 0 0 rg 45 $headerY Td (${_pdfEscape("Date")}) Tj ET',
      );
      buffer.writeln(
        'BT /F2 9 Tf 0 0 0 rg 115 $headerY Td (${_pdfEscape("Time")}) Tj ET',
      );
      buffer.writeln(
        'BT /F2 9 Tf 0 0 0 rg 170 $headerY Td (${_pdfEscape("Company")}) Tj ET',
      );
      buffer.writeln(
        'BT /F2 9 Tf 0 0 0 rg 330 $headerY Td (${_pdfEscape("Status")}) Tj ET',
      );
      buffer.writeln(
        'BT /F2 9 Tf 0 0 0 rg 420 $headerY Td (${_pdfEscape("Outcome")}) Tj ET',
      );
    }

    if (includeRawData) {
      if (visits.isEmpty) {
        cs.writeln(
          'BT /F2 12 Tf 0.1 0.1 0.1 rg 40 $y Td (${_pdfEscape("FIELD VISITS LOGS (0 records)")}) Tj ET',
        );
        y -= 16;
        cs.writeln(
          'BT /F1 9 Tf 0.4 0.4 0.4 rg 50 $y Td (${_pdfEscape("No visits logged in selected period")}) Tj ET',
        );
        y -= 20;
      } else {
        drawTableHeader(cs, y, "FIELD VISITS LOGS (${visits.length} records)");
        y -= 30;

        for (final v in visits) {
          if (y < 80) {
            // Close page 1 (or current page) and start next page
            pageStreams.add(cs.toString());
            cs = StringBuffer();
            y = 740;
            drawTableHeader(cs, y, "FIELD VISITS LOGS (Continued)");
            y -= 30;
          }

          final dateStr = v.date.toIso8601String().split('T').first;
          cs.writeln(
            'BT /F1 8.5 Tf 0.2 0.2 0.2 rg 45 $y Td (${_pdfEscape(dateStr)}) Tj ET',
          );
          cs.writeln(
            'BT /F1 8.5 Tf 0.2 0.2 0.2 rg 115 $y Td (${_pdfEscape(v.time)}) Tj ET',
          );
          cs.writeln(
            'BT /F1 8.5 Tf 0.2 0.2 0.2 rg 170 $y Td (${_pdfEscape(v.company.length > 25 ? v.company.substring(0, 23) + ".." : v.company)}) Tj ET',
          );
          cs.writeln(
            'BT /F1 8.5 Tf 0.2 0.2 0.2 rg 330 $y Td (${_pdfEscape(v.status)}) Tj ET',
          );
          cs.writeln(
            'BT /F1 8.5 Tf 0.2 0.2 0.2 rg 420 $y Td (${_pdfEscape(v.outcome.length > 20 ? v.outcome.substring(0, 18) + ".." : v.outcome)}) Tj ET',
          );
          y -= 13;
        }
      }
    }

    pageStreams.add(cs.toString());

    // Build PDF objects with byte offsets
    final buffer = BytesBuilder();
    buffer.add(utf8.encode('%PDF-1.4\n%\xE2\xE3\xCF\xD3\n'));

    final offsets = <int>[];
    void addObject(int objNum, String content) {
      offsets.add(buffer.length);
      buffer.add(utf8.encode('$objNum 0 obj\n$content\nendobj\n'));
    }

    final totalPages = pageStreams.length;

    // 1: Catalog
    addObject(1, '<< /Type /Catalog /Pages 2 0 R >>');

    // 2: Pages Collection
    final kids = List.generate(totalPages, (i) => '${5 + i * 2} 0 R').join(' ');
    addObject(2, '<< /Type /Pages /Kids [$kids] /Count $totalPages >>');

    // 3: Font Helvetica
    addObject(
      3,
      '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica /Encoding /WinAnsiEncoding >>',
    );

    // 4: Font Helvetica-Bold
    addObject(
      4,
      '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold /Encoding /WinAnsiEncoding >>',
    );

    for (var i = 0; i < totalPages; i++) {
      final pageObjId = 5 + i * 2;
      final streamObjId = 6 + i * 2;

      // Page Object
      addObject(
        pageObjId,
        '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] '
        '/Resources << /Font << /F1 3 0 R /F2 4 0 R >> >> '
        '/Contents $streamObjId 0 R >>',
      );

      // Stream with footer
      final streamContent =
          pageStreams[i] +
          'BT /F1 8 Tf 0.5 0.5 0.5 rg 40 35 Td (${_pdfEscape("CRM Pro Mobile  |  Page ${i + 1} of $totalPages")}) Tj ET\n';
      final streamBytes = utf8.encode(streamContent);

      offsets.add(buffer.length);
      buffer.add(
        utf8.encode(
          '$streamObjId 0 obj\n<< /Length ${streamBytes.length} >>\nstream\n',
        ),
      );
      buffer.add(streamBytes);
      buffer.add(utf8.encode('\nendstream\nendobj\n'));
    }

    // XREF Table
    final xrefOffset = buffer.length;
    final totalObjects = offsets.length + 1;
    final xrefSb = StringBuffer();
    xrefSb.writeln('xref');
    xrefSb.writeln('0 $totalObjects');
    xrefSb.writeln('0000000000 65535 f ');
    for (final off in offsets) {
      xrefSb.writeln('${off.toString().padLeft(10, "0")} 00000 n ');
    }
    xrefSb.writeln('trailer');
    xrefSb.writeln('<< /Size $totalObjects /Root 1 0 R >>');
    xrefSb.writeln('startxref');
    xrefSb.writeln('$xrefOffset');
    xrefSb.writeln('%%EOF');

    buffer.add(utf8.encode(xrefSb.toString()));
    return buffer.toBytes();
  }

  /// Backward-compatible alias returning human-readable formatted PDF text structure.
  String generatePdfReportText({
    String period = 'Current Month',
    int visitsGoalMet = 18,
    int visitsGoalTotal = 24,
    double revenueMet = 3.2,
    double revenueGoal = 5.0,
    double conversionRate = 24.5,
    String avgDuration = '45 min',
    List<Account>? leads,
    List<Account>? customers,
    List<Deal> deals = const [],
    List<Visit> visits = const [],
    UserProfile? profile,
    bool includeCharts = true,
    bool includeRawData = true,
    bool includeSummary = true,
  }) {
    final sb = StringBuffer();
    sb.writeln('=====================================================');
    sb.writeln('          CRM PRO FIELD SALES REPORT               ');
    sb.writeln('          Period: $period                          ');
    sb.writeln('          Generated: ${DateTime.now().toLocal()}   ');
    sb.writeln('=====================================================');
    sb.writeln();
    if (includeSummary) {
      sb.writeln('EXECUTIVE SUMMARY');
      sb.writeln('-----------------------------------------------------');
      sb.writeln(
        'Visits Completed: $visitsGoalMet / $visitsGoalTotal (${(visitsGoalMet / (visitsGoalTotal == 0 ? 1 : visitsGoalTotal) * 100).round()}%)',
      );
      sb.writeln(
        'Revenue Target:   INR ${revenueMet}L / INR ${revenueGoal}L (${(revenueMet / (revenueGoal == 0 ? 1 : revenueGoal) * 100).round()}%)',
      );
      sb.writeln('Conversion Rate:  ${conversionRate.toStringAsFixed(1)}%');
      sb.writeln('Average Duration: $avgDuration');
      sb.writeln();
    }
    if (includeCharts) {
      sb.writeln('PIPELINE BREAKDOWN BY STAGE');
      sb.writeln('-----------------------------------------------------');
      for (final s in [
        'Qualified',
        'Discovery',
        'Proposal',
        'Negotiation',
        'Won',
        'Lost',
      ]) {
        final count = deals.where((d) => d.stage == s).length;
        final bar = '█' * (count * 3);
        sb.writeln('${s.padRight(12)}: $bar ($count)');
      }
      sb.writeln();
    }
    if (includeRawData) {
      sb.writeln('VISIT LOGS IN PERIOD (${visits.length} records)');
      sb.writeln('-----------------------------------------------------');
      for (final v in visits) {
        sb.writeln(
          '${v.date.toIso8601String().split("T").first} ${v.time.padRight(10)} ${v.company.padRight(20)} [${v.status}] ${v.outcome}',
        );
      }
    }
    sb.writeln();
    sb.writeln('End of Report.');
    return sb.toString();
  }

  // =========================================================================
  // FILE SAVING & DOWNLOADING
  // =========================================================================

  /// Saves binary bytes to device storage or triggers browser download.
  static Future<String?> saveExportFile({
    required String filename,
    required List<int> bytes,
    required String mimeType,
    BuildContext? context,
  }) async {
    try {
      final savedPathOrName = await saver.saveFileBytes(
        filename: filename,
        bytes: bytes,
        mimeType: mimeType,
      );
      if (context != null && context.mounted && savedPathOrName != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File exported: $filename (${bytes.length} bytes)'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return savedPathOrName;
    } catch (e) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Save error: $e')));
      }
      return null;
    }
  }
}
