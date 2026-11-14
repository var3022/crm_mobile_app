import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'crm_store.dart';
import 'crm_storage.dart';

class ReportContents {
  const ReportContents({
    this.charts = true,
    this.rawData = true,
    this.summary = true,
    this.team = false,
  });
  final bool charts, rawData, summary, team;
}

class ReportFile {
  const ReportFile(this.bytes, this.mimeType);
  final Uint8List bytes;
  final String mimeType;
}

ReportFile buildReportFile(
  CrmStore store,
  String format,
  DateTime start,
  DateTime end,
  ReportContents contents,
) {
  bool contains(DateTime date) =>
      !date.isBefore(start) && date.isBefore(end.add(const Duration(days: 1)));
  final visits = store.visits.where((v) => contains(v.date)).toList();
  final deals = store.deals
      .where((d) => contains(d.closeDate ?? d.createdAt))
      .toList();
  final won = deals.where((d) => d.stage == 'Won').toList();
  final closed = deals
      .where((d) => d.stage == 'Won' || d.stage == 'Lost')
      .length;
  final completed = visits.where((v) => v.status == 'Completed').toList();
  final revenue = won.fold<double>(0, (s, d) => s + d.value);
  final extra = <String, List<List<String>>>{};
  if (contents.summary)
    extra['Summary'] = [
      ['Metric', 'Value'],
      [
        'Period',
        '${start.toIso8601String().split('T').first} to ${end.toIso8601String().split('T').first}',
      ],
      ['Visits completed', '${completed.length}'],
      ['Visits target', '50'],
      ['Revenue INR', '$revenue'],
      ['Revenue target INR', '1000000'],
      [
        'Conversion',
        closed == 0
            ? 'N/A'
            : '${(won.length / closed * 100).toStringAsFixed(1)}%',
      ],
      ['Average duration', CrmStorage.formatAverageDuration(completed)],
    ];
  if (contents.charts)
    extra['Pipeline Chart Data'] = [
      ['Stage', 'Count', 'Value'],
      for (final stage in [
        'Qualified',
        'Discovery',
        'Proposal',
        'Negotiation',
        'Won',
        'Lost',
      ])
        [
          stage,
          '${deals.where((d) => d.stage == stage).length}',
          '${deals.where((d) => d.stage == stage).fold<double>(0, (s, d) => s + d.value)}',
        ],
    ];
  if (contents.team)
    extra['Team Breakdown'] = [
      ['Owner', 'Deals', 'Won Revenue INR'],
      for (final owner in deals.map((d) => d.owner).toSet())
        [
          owner,
          '${deals.where((d) => d.owner == owner).length}',
          '${won.where((d) => d.owner == owner).fold<double>(0, (s, d) => s + d.value)}',
        ],
      if (deals.isEmpty) ['No owner data in selected period', '0', '0'],
    ];
  final rawLeads = contents.rawData ? store.leads : <Account>[];
  final rawCustomers = contents.rawData ? store.customers : <Account>[];
  final rawDeals = contents.rawData ? deals : <Deal>[];
  final rawVisits = contents.rawData ? visits : <Visit>[];
  if (format == 'pdf') {
    return ReportFile(
      CrmStorage.instance.generatePdfBytes(
        period:
            '${start.toIso8601String().split('T').first} - ${end.toIso8601String().split('T').first}',
        visitsGoalMet: completed.length,
        visitsGoalTotal: 50,
        revenueMet: revenue / 100000,
        revenueGoal: 10,
        conversionRate: closed == 0 ? null : won.length / closed * 100,
        avgDuration: CrmStorage.formatAverageDuration(completed),
        leads: rawLeads,
        customers: rawCustomers,
        deals: deals,
        visits: visits,
        profile: store.userProfile,
        includeCharts: contents.charts,
        includeRawData: contents.rawData,
        includeSummary: contents.summary,
        additionalLines: contents.team
            ? extra['Team Breakdown']!.map((row) => row.join(' | ')).toList()
            : const [],
      ),
      'application/pdf',
    );
  }
  if (format == 'csv') {
    String cell(String value) => '"${value.replaceAll('"', '""')}"';
    final extraCsv = extra.entries
        .map(
          (e) =>
              '\r\n${cell(e.key)}\r\n${e.value.map((row) => row.map(cell).join(',')).join('\r\n')}',
        )
        .join();
    final raw = contents.rawData
        ? CrmStorage.instance.generateCsv(
            leads: rawLeads,
            customers: rawCustomers,
            deals: rawDeals,
            visits: rawVisits,
          )
        : '';
    return ReportFile(
      Uint8List.fromList(utf8.encode('$raw$extraCsv')),
      'text/csv;charset=utf-8',
    );
  }
  final bytes = CrmStorage.instance.generateXlsxBytes(
    leads: rawLeads,
    customers: rawCustomers,
    deals: rawDeals,
    visits: rawVisits,
  );
  final archive = ZipDecoder().decodeBytes(bytes);
  String read(String path) => utf8.decode(
    archive.files.firstWhere((f) => f.name == path).content as List<int>,
  );
  var workbook = read('xl/workbook.xml'),
      rels = read('xl/_rels/workbook.xml.rels'),
      types = read('[Content_Types].xml');
  void replace(String path, String value) {
    final encoded = utf8.encode(value);
    archive.addFile(ArchiveFile(path, encoded.length, encoded));
  }

  String xml(String value) => value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');
  var sheetId = 4;
  for (final entry in extra.entries) {
    final id = 'report$sheetId';
    workbook = workbook.replaceFirst(
      '</sheets>',
      '<sheet name="${xml(entry.key)}" sheetId="$sheetId" r:id="$id"/></sheets>',
    );
    rels = rels.replaceFirst(
      '</Relationships>',
      '<Relationship Id="$id" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet$sheetId.xml"/></Relationships>',
    );
    types = types.replaceFirst(
      '</Types>',
      '<Override PartName="/xl/worksheets/sheet$sheetId.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/></Types>',
    );
    final rows = entry.value
        .map(
          (row) =>
              '<row>${row.map((cell) => '<c t="inlineStr"><is><t>${xml(cell)}</t></is></c>').join()}</row>',
        )
        .join();
    replace(
      'xl/worksheets/sheet$sheetId.xml',
      '<?xml version="1.0" encoding="UTF-8"?><worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><sheetData>$rows</sheetData></worksheet>',
    );
    sheetId++;
  }
  replace('xl/workbook.xml', workbook);
  replace('xl/_rels/workbook.xml.rels', rels);
  replace('[Content_Types].xml', types);
  return ReportFile(
    Uint8List.fromList(ZipEncoder().encode(archive)!),
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  );
}
