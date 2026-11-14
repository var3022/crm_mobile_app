import 'package:flutter/material.dart';
import 'crm_store.dart';
import 'crm_ui.dart';

const monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];
String monthLabel(DateTime date) =>
    '${monthNames[date.month - 1]} ${date.year}';
String rupees(num value) => '₹${(value / 100000).toStringAsFixed(1)}L';
bool inMonth(DateTime date, DateTime month) =>
    date.year == month.year && date.month == month.month;

class MonthlyPerformance {
  MonthlyPerformance(CrmStore store, this.month)
    : visits = store.visits
          .where((v) => inMonth(v.date, month) && v.status == 'Completed')
          .toList(),
      deals = store.deals
          .where((d) => inMonth(d.closeDate ?? d.createdAt, month))
          .toList(),
      newLeads = store.leads.where((a) => inMonth(a.createdAt, month)).length;
  final DateTime month;
  final List<Visit> visits;
  final List<Deal> deals;
  final int newLeads;
  double get revenue =>
      deals.where((d) => d.stage == 'Won').fold(0.0, (s, d) => s + d.value);
  double get conversion {
    final closed = deals
        .where((d) => d.stage == 'Won' || d.stage == 'Lost')
        .length;
    return closed == 0
        ? 0
        : deals.where((d) => d.stage == 'Won').length / closed * 100;
  }

  double get averageDeal {
    final won = deals.where((d) => d.stage == 'Won').toList();
    return won.isEmpty ? 0 : revenue / won.length;
  }

  double get overall =>
      ((visits.length / 50).clamp(0.0, 1.0) +
          (revenue / 1000000).clamp(0.0, 1.0) +
          (newLeads / 20).clamp(0.0, 1.0)) /
      3;
}

class ReportRange {
  const ReportRange(this.label, this.start, this.end, {this.compare = false});
  final String label;
  final DateTime start, end;
  final bool compare;
}

ReportRange reportPreset(String label, [DateTime? reference]) {
  final now = reference ?? DateTime.now();
  final day = DateUtils.dateOnly(now);
  final week = day.subtract(Duration(days: day.weekday - 1));
  final quarter = ((now.month - 1) ~/ 3) * 3 + 1;
  return switch (label) {
    'Today' => ReportRange(label, day, day),
    'Yesterday' => ReportRange(
      label,
      day.subtract(const Duration(days: 1)),
      day.subtract(const Duration(days: 1)),
    ),
    'This Week' => ReportRange(label, week, week.add(const Duration(days: 6))),
    'Last Week' => ReportRange(
      label,
      week.subtract(const Duration(days: 7)),
      week.subtract(const Duration(days: 1)),
    ),
    'Last Month' => ReportRange(
      label,
      DateTime(now.year, now.month - 1),
      DateTime(now.year, now.month, 0),
    ),
    'Quarter' || 'This Quarter' => ReportRange(
      'Quarter',
      DateTime(now.year, quarter),
      DateTime(now.year, quarter + 3, 0),
    ),
    _ => ReportRange(
      'This Month',
      DateTime(now.year, now.month),
      DateTime(now.year, now.month + 1, 0),
    ),
  };
}

Future<ReportRange?> selectReportRange(
  BuildContext context,
  ReportRange initial,
) => showModalBottomSheet<ReportRange>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
  ),
  builder: (_) => _ReportRangeSheet(initial: initial),
);

class _ReportRangeSheet extends StatefulWidget {
  const _ReportRangeSheet({required this.initial});
  final ReportRange initial;
  @override
  State<_ReportRangeSheet> createState() => _ReportRangeSheetState();
}

class _ReportRangeSheetState extends State<_ReportRangeSheet> {
  late DateTime start = widget.initial.start, end = widget.initial.end;
  late String label = widget.initial.label;
  late bool compare = widget.initial.compare;
  bool choosingEnd = false;
  @override
  Widget build(BuildContext c) => SizedBox(
    height: MediaQuery.sizeOf(c).height * .88,
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: strong('Select Date Range', 19)),
              IconButton(
                onPressed: () => Navigator.pop(c),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 6,
                    children: [
                      for (final preset in [
                        'Today',
                        'Yesterday',
                        'This Week',
                        'Last Week',
                        'This Month',
                        'Last Month',
                        'This Quarter',
                        'Custom',
                      ])
                        ChoiceChip(
                          showCheckmark: false,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          labelPadding: EdgeInsets.zero,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          label: Text(
                            preset,
                            style: const TextStyle(fontSize: 11),
                          ),
                          selected: label == preset,
                          onSelected: (_) => setState(() {
                            label = preset;
                            if (preset != 'Custom') {
                              final r = reportPreset(preset);
                              start = r.start;
                              end = r.end;
                            }
                          }),
                        ),
                    ],
                  ),
                  gap(12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => choosingEnd = false),
                          child: Text('FROM\n${dateLabel(start)}'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => choosingEnd = true),
                          child: Text('TO\n${dateLabel(end)}'),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    choosingEnd ? 'Select end date' : 'Select start date',
                    style: const TextStyle(fontSize: 11),
                  ),
                  CalendarDatePicker(
                    key: ValueKey('$choosingEnd-$label'),
                    initialDate: choosingEnd ? end : start,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2036),
                    onDateChanged: (date) => setState(() {
                      label = 'Custom';
                      if (choosingEnd) {
                        end = date;
                        if (start.isAfter(end)) start = end;
                      } else {
                        start = date;
                        if (end.isBefore(start)) end = start;
                        choosingEnd = true;
                      }
                    }),
                  ),
                ],
              ),
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Compare with previous period',
              style: TextStyle(fontSize: 13),
            ),
            value: compare,
            onChanged: (v) => setState(() => compare = v),
          ),
          button(
            'Apply Filter',
            () => Navigator.pop(
              c,
              ReportRange(label, start, end, compare: compare),
            ),
          ),
        ],
      ),
    ),
  );
}

String dateLabel(DateTime date) =>
    '${monthNames[date.month - 1]} ${date.day}, ${date.year}';
