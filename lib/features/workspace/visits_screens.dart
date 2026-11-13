import 'dart:async';
import 'package:flutter/material.dart';
import 'crm_store.dart';
import 'crm_ui.dart';
import 'tasks_deals_screens.dart' show dateText;

class VisitsScreen extends StatefulWidget {
  const VisitsScreen({super.key, this.empty = false});
  final bool empty;
  @override
  State<VisitsScreen> createState() => _VisitsScreenState();
}

class _VisitsScreenState extends State<VisitsScreen> {
  DateTime selected = DateUtils.dateOnly(DateTime.now());
  String view = 'List View';
  @override
  Widget build(BuildContext c) => ListenableBuilder(
    listenable: CrmStore.instance,
    builder: (c, _) {
      final visits = widget.empty
          ? <Visit>[]
          : CrmStore.instance.visits
                .where((v) => DateUtils.isSameDay(v.date, selected))
                .toList();
      final monday = selected.subtract(Duration(days: selected.weekday - 1));
      return CrmPage(
        title: 'Visits',
        nav: 2,
        actions: [
          actionIcon(Icons.calendar_today_outlined, () async {
            final d = await showDatePicker(
              context: c,
              initialDate: selected,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (d != null) setState(() => selected = d);
          }, tooltip: 'Choose date'),
          actionIcon(
            Icons.add_circle,
            () => open(c, '/schedule-visit'),
            tooltip: 'Schedule visit',
          ),
        ],
        children: [
          Row(
            children: [
              for (int i = 0; i < 7; i++)
                Expanded(
                  child: InkWell(
                    onTap: () => setState(
                      () => selected = monday.add(Duration(days: i)),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selected.weekday == i + 1
                            ? AppColors.primary
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            [
                              'Mon',
                              'Tue',
                              'Wed',
                              'Thu',
                              'Fri',
                              'Sat',
                              'Sun',
                            ][i],
                            style: TextStyle(
                              fontSize: 10,
                              color: selected.weekday == i + 1
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                          gap(6),
                          Text(
                            '${monday.add(Duration(days: i)).day}',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: selected.weekday == i + 1
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          gap(12),
          chips(
            ['List View', 'Map View'],
            view,
            (v) => setState(() => view = v),
          ),
          Panel(
            color: const Color(0xFFCCFBF1),
            child: Text(
              '${visits.where((v) => v.status == 'Completed').length}/${visits.length} visits Completed · 2h 15m · 18 km',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (view == 'Map View') const MapPreview(),
          if (visits.isEmpty)
            emptyState(
              c,
              'No Visits Scheduled',
              'Plan your day by scheduling visits to your leads and customers.',
              Icons.location_on_outlined,
              'Schedule Visit',
              () => open(c, '/schedule-visit'),
            ),
          for (final v in visits)
            Panel(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${v.time} · ${v.status.toUpperCase()}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: v.status == 'Completed'
                                ? AppColors.success
                                : AppColors.primary,
                          ),
                        ),
                      ),
                      badge(v.type),
                    ],
                  ),
                  gap(10),
                  strong(v.company),
                  muted('${v.contact} · CTO'),
                  muted('Nariman Point, South Mumbai'),
                  gap(12),
                  button(
                    v.status == 'Completed'
                        ? 'View Summary'
                        : v.status == 'In Progress'
                        ? 'Continue Visit'
                        : 'View Details',
                    () => open(
                      c,
                      v.status == 'Completed'
                          ? '/visit-summary'
                          : v.status == 'In Progress'
                          ? '/active-visit'
                          : '/visit-details',
                      v,
                    ),
                    secondary: true,
                  ),
                ],
              ),
            ),
          if (visits.isNotEmpty)
            button('Plan Route', () => open(c, '/plan-route')),
        ],
      );
    },
  );
}

Widget visitForm(Visit? visit, [Account? account]) => CrmForm(
  title: visit == null ? 'Schedule Visit' : 'Reschedule Visit',
  submit: visit == null ? 'Schedule Visit' : 'Confirm Reschedule',
  fields: [
    FormFieldSpec(
      'Associated Lead / Customer',
      value: visit?.company ?? account?.company ?? 'Acme Corp',
      required: true,
      options: {
        'Acme Corp',
        ...CrmStore.instance.leads.map((a) => a.company),
        ...CrmStore.instance.customers.map((a) => a.company),
        if (visit != null) visit.company,
      }.toList(),
    ),
    FormFieldSpec(
      'Contact Person',
      value: visit?.contact ?? account?.contact ?? 'John Doe - CTO',
      required: true,
    ),
    FormFieldSpec(
      'Visit Date',
      value: visit == null
          ? ''
          : '${visit.date.year}-${visit.date.month.toString().padLeft(2, '0')}-${visit.date.day.toString().padLeft(2, '0')}',
      kind: 'date',
      required: true,
    ),
    FormFieldSpec(
      'Visit Time',
      value: visit?.time ?? '10:00 AM',
      options: [
        '09:00 AM',
        '10:00 AM',
        '11:30 AM',
        '02:00 PM',
        '03:30 PM',
        '05:00 PM',
      ],
    ),
    FormFieldSpec(
      'Visit Type',
      value: visit?.type ?? 'First Meeting',
      options: ['First Meeting', 'Follow-up', 'Demo', 'Contract Signing'],
    ),
    FormFieldSpec(
      'Purpose / Agenda',
      value: visit?.purpose ?? '',
      lines: 4,
      required: true,
    ),
    FormFieldSpec(
      'Estimated Duration',
      value: visit?.duration ?? '1 hr',
      options: ['30 min', '1 hr', '1.5 hr', '2 hr'],
    ),
    if (visit != null)
      const FormFieldSpec(
        'Reason for Reschedule',
        required: true,
        options: [
          'Client Request',
          'Schedule Conflict',
          'Travel Delay',
          'Other',
        ],
      ),
  ],
  onSave: (c, v) async {
    CrmStore.instance.update(() {
      final item =
          visit ??
          Visit(
            v['Associated Lead / Customer']!,
            v['Contact Person']!,
            v['Visit Time']!,
            v['Visit Type']!,
          );
      item.company = v['Associated Lead / Customer']!;
      item.contact = v['Contact Person']!;
      item.date = DateTime.parse(v['Visit Date']!);
      item.time = v['Visit Time']!;
      item.type = v['Visit Type']!;
      item.purpose = v['Purpose / Agenda']!;
      item.duration = v['Estimated Duration']!;
      if (visit == null) CrmStore.instance.visits.add(item);
    });
    Navigator.pop(c);
    message(c, visit == null ? 'Visit scheduled' : 'Visit rescheduled');
  },
);

class VisitDetailsScreen extends StatelessWidget {
  const VisitDetailsScreen({super.key, required this.visit});
  final Visit visit;
  @override
  Widget build(BuildContext c) => ListenableBuilder(
    listenable: CrmStore.instance,
    builder: (c, _) => CrmPage(
      title: 'Visit Details',
      actions: [
        actionIcon(
          Icons.edit_calendar_outlined,
          () => open(c, '/reschedule-visit', visit),
          tooltip: 'Reschedule visit',
        ),
      ],
      children: [
        badge('${visit.status} Visit'),
        gap(20),
        strong(visit.company, 23),
        muted(
          visit.purpose.isEmpty
              ? 'Product demo & setup verification'
              : visit.purpose,
        ),
        gap(15),
        Panel(
          child: Column(
            children: [
              detail(
                'Date',
                dateText(visit.date),
                icon: Icons.calendar_today_outlined,
              ),
              detail('Time', visit.time, icon: Icons.schedule),
              detail(
                'Visit Type',
                visit.type,
                icon: Icons.business_center_outlined,
              ),
              detail('Contact', visit.contact, icon: Icons.person_outline),
              detail(
                'Location',
                'Lower Parel, Mumbai',
                icon: Icons.location_on_outlined,
              ),
            ],
          ),
        ),
        const MapPreview(),
        gap(),
        button(
          visit.status == 'Completed' ? 'View Summary' : 'Check In',
          () => open(
            c,
            visit.status == 'Completed' ? '/visit-summary' : '/check-in',
            visit,
          ),
        ),
        button(
          'Reschedule Visit',
          () => open(c, '/reschedule-visit', visit),
          secondary: true,
        ),
        TextButton(
          onPressed: () async {
            if (await confirm(
              c,
              'Cancel Visit?',
              'Are you sure you want to cancel the visit to ${visit.company}? The customer will not be notified in this local demo.',
              action: 'Cancel Visit',
            )) {
              CrmStore.instance.update(() => visit.status = 'Cancelled');
              if (c.mounted) Navigator.pop(c);
            }
          },
          child: const Text(
            'Cancel Visit',
            style: TextStyle(color: AppColors.error),
          ),
        ),
      ],
    ),
  );
}

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key, required this.visit, this.mode = 'normal'});
  final Visit visit;
  final String mode;
  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  bool consent = false;
  final reason = TextEditingController();
  @override
  void dispose() {
    reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) => CrmPage(
    title: 'Check In',
    children: [
      const MapPreview(),
      gap(24),
      Center(
        child: strong(
          widget.mode == 'far'
              ? 'Far from Visit Location'
              : widget.mode == 'error'
              ? 'Unable to determine your location.'
              : 'Location Check',
          20,
        ),
      ),
      gap(10),
      Text(
        widget.mode == 'far'
            ? '2.4 km away · Expected range: within 200m'
            : 'Device GPS verification is not connected in this local preview.',
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      ),
      gap(24),
      Panel(
        child: detail(
          'Target Client',
          widget.visit.company,
          icon: Icons.location_on_outlined,
        ),
      ),
      TextField(
        controller: reason,
        decoration: const InputDecoration(
          labelText: 'Manual check-in reason',
          hintText: 'Explain why location could not be verified',
        ),
        maxLines: 3,
      ),
      gap(),
      CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        value: consent,
        onChanged: (v) => setState(() => consent = v!),
        title: const Text(
          'Record this as an unverified manual check-in',
          style: TextStyle(fontSize: 12),
        ),
      ),
      gap(20),
      button('Proceed with Check-In', () {
        if (!consent || reason.text.trim().isEmpty) {
          message(c, 'Add a reason and confirm manual check-in');
          return;
        }
        CrmStore.instance.update(() {
          widget.visit.status = 'In Progress';
          CrmStore.instance.accountNotes
              .putIfAbsent(widget.visit.company, () => [])
              .add('Manual check-in: ${reason.text}');
        });
        Navigator.pushReplacementNamed(
          c,
          '/active-visit',
          arguments: widget.visit,
        );
      }),
      button('Cancel', () => Navigator.pop(c), secondary: true),
    ],
  );
}

class ActiveVisitScreen extends StatefulWidget {
  const ActiveVisitScreen({super.key, required this.visit});
  final Visit visit;
  @override
  State<ActiveVisitScreen> createState() => _ActiveVisitScreenState();
}

class _ActiveVisitScreenState extends State<ActiveVisitScreen> {
  Timer? timer;
  int seconds = 0;
  final quick = TextEditingController();
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => seconds++);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    quick.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) => CrmPage(
    title: 'Visit in Progress',
    actions: [
      TextButton(
        onPressed: () => open(c, '/visit-details', widget.visit),
        child: const Text('Details'),
      ),
    ],
    children: [
      Row(
        children: [
          badge('● VISIT IN PROGRESS', color: AppColors.error),
          const Spacer(),
          Text(
            '${(seconds ~/ 3600).toString().padLeft(2, '0')}:${(seconds ~/ 60 % 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      gap(),
      Panel(
        child: Row(
          children: [
            avatar('AC'),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  strong(widget.visit.company),
                  muted('${widget.visit.contact} · CTO'),
                  muted('Last visited: Aug 2, 2026'),
                ],
              ),
            ),
          ],
        ),
      ),
      heading('Visit Tasks'),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final item in [
            (Icons.edit_note, 'Notes', '/visit-notes'),
            (Icons.photo_camera_outlined, 'Photos', '/photos'),
            (Icons.mic_none, 'Voice Note', '/voice-note'),
            (Icons.trending_up, 'Update Deal', '/pipeline'),
            (Icons.checklist, 'Checklist', '/visit-checklist'),
            (Icons.draw_outlined, 'Signature', '/signature'),
          ])
            SizedBox(
              width: (MediaQuery.sizeOf(c).width - 50) / 2,
              child: OutlinedButton.icon(
                onPressed: () => open(c, item.$3, widget.visit),
                icon: Icon(item.$1, size: 17),
                label: Text(item.$2, style: const TextStyle(fontSize: 12)),
              ),
            ),
        ],
      ),
      heading('Quick Notes'),
      TextField(
        controller: quick,
        maxLines: 4,
        decoration: const InputDecoration(
          hintText: 'Type meeting takeaways or notes here...',
        ),
      ),
      TextButton(
        onPressed: () {
          if (quick.text.trim().isEmpty) return;
          CrmStore.instance.addNote(widget.visit.company, quick.text.trim());
          quick.clear();
          message(c, 'Note added');
        },
        child: const Text('Save Note'),
      ),
      gap(),
      Panel(
        color: AppColors.primary,
        child: const Text(
          '✦ AI Copilot Suggestion\n\nJohn mentioned wanting a pricing sheet. Open Update Deal to review the current proposal.',
          style: TextStyle(color: Colors.white, fontSize: 12, height: 1.5),
        ),
      ),
      button('Complete Visit', () => open(c, '/visit-summary', widget.visit)),
    ],
  );
}

class VisitNotesScreen extends StatelessWidget {
  const VisitNotesScreen({super.key, required this.visit});
  final Visit visit;
  @override
  Widget build(BuildContext c) => ListenableBuilder(
    listenable: CrmStore.instance,
    builder: (c, _) => CrmPage(
      title: 'Visit Notes',
      actions: [
        actionIcon(
          Icons.add_circle_outline,
          () => open(c, '/add-note', visit),
          tooltip: 'Add note',
        ),
      ],
      children: [
        for (
          int i = 0;
          i < CrmStore.instance.notesFor(visit.company).length;
          i++
        )
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: muted('11:${32 + i * 5} AM')),
                    actionIcon(
                      Icons.delete_outline,
                      () => CrmStore.instance.update(
                        () => CrmStore.instance.accountNotes[visit.company]!
                            .removeAt(i),
                      ),
                      tooltip: 'Delete note',
                    ),
                  ],
                ),
                Text(
                  CrmStore.instance.notesFor(visit.company)[i],
                  style: const TextStyle(fontSize: 13, height: 1.6),
                ),
              ],
            ),
          ),
        button('Add Note', () => open(c, '/add-note', visit)),
      ],
    ),
  );
}

class VisitChecklistScreen extends StatelessWidget {
  const VisitChecklistScreen({super.key, required this.visit});
  final Visit visit;
  @override
  Widget build(BuildContext c) => ListenableBuilder(
    listenable: CrmStore.instance,
    builder: (c, _) => CrmPage(
      title: 'Visit Checklist',
      children: [
        muted(visit.company),
        gap(12),
        Row(
          children: [
            Expanded(child: strong('Progress', 13)),
            muted(
              '${visit.checklist.where((b) => b).length}/8 items completed',
            ),
          ],
        ),
        gap(10),
        LinearProgressIndicator(
          value: visit.checklist.where((b) => b).length / 8,
          backgroundColor: AppColors.primaryLight,
        ),
        gap(20),
        for (int i = 0; i < 8; i++) ...[
          if (i == 0 || i == 3 || i == 6)
            heading(
              i == 0
                  ? 'PRE-MEETING'
                  : i == 3
                  ? 'DURING MEETING'
                  : 'POST-MEETING',
            ),
          CheckboxListTile(
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            title: Text(
              [
                'Review client history',
                'Prepare product catalog',
                'Check inventory availability',
                'Present new offerings',
                'Discuss pricing terms',
                'Address pending complaints',
                'Capture meeting notes',
                'Set follow-up actions',
              ][i],
              style: const TextStyle(fontSize: 13),
            ),
            value: visit.checklist[i],
            onChanged: (v) =>
                CrmStore.instance.update(() => visit.checklist[i] = v!),
          ),
        ],
        gap(20),
        button('Save Checklist', () {
          message(c, 'Checklist saved');
          Navigator.pop(c);
        }),
      ],
    ),
  );
}

class SignatureScreen extends StatefulWidget {
  const SignatureScreen({super.key, required this.visit});
  final Visit visit;
  @override
  State<SignatureScreen> createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  @override
  Widget build(BuildContext c) => CrmPage(
    title: 'Collect Signature',
    children: [
      Panel(
        child: detail(widget.visit.contact, 'CTO, ${widget.visit.company}'),
      ),
      heading('Purpose'),
      muted('Meeting Attendance Confirmation'),
      heading(
        'Digital Signature',
        TextButton(
          onPressed: () => setState(() => widget.visit.signature.clear()),
          child: const Text('Clear'),
        ),
      ),
      Container(
        height: 250,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: LayoutBuilder(
          builder: (c, b) => GestureDetector(
            onPanStart: (d) =>
                setState(() => widget.visit.signature.add(d.localPosition)),
            onPanUpdate: (d) => setState(
              () => widget.visit.signature.add(
                Offset(
                  d.localPosition.dx.clamp(0, b.maxWidth).toDouble(),
                  d.localPosition.dy.clamp(0, b.maxHeight).toDouble(),
                ),
              ),
            ),
            onPanEnd: (_) => setState(() => widget.visit.signature.add(null)),
            child: CustomPaint(
              painter: SignaturePainter(widget.visit.signature),
              child: Center(
                child: widget.visit.signature.isEmpty
                    ? muted('Sign here')
                    : const SizedBox(),
              ),
            ),
          ),
        ),
      ),
      gap(),
      detail('Signed Name', widget.visit.contact),
      detail('Timestamp', dateText(DateTime.now())),
      gap(),
      button('Confirm & Save', () {
        if (widget.visit.signature.whereType<Offset>().length < 3) {
          message(c, 'Please add a signature');
          return;
        }
        CrmStore.instance.update(() {});
        message(c, 'Signature saved for this visit');
        Navigator.pop(c);
      }),
      button('Skip Signature', () => Navigator.pop(c), secondary: true),
    ],
  );
}

class SignaturePainter extends CustomPainter {
  SignaturePainter(this.points);
  final List<Offset?> points;
  @override
  void paint(Canvas c, Size s) {
    final p = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    for (int i = 1; i < points.length; i++) {
      if (points[i - 1] != null && points[i] != null)
        c.drawLine(points[i - 1]!, points[i]!, p);
    }
  }

  @override
  bool shouldRepaint(covariant SignaturePainter old) => true;
}

class VisitSummaryScreen extends StatefulWidget {
  const VisitSummaryScreen({super.key, required this.visit});
  final Visit visit;
  @override
  State<VisitSummaryScreen> createState() => _VisitSummaryScreenState();
}

class _VisitSummaryScreenState extends State<VisitSummaryScreen> {
  late String outcome = widget.visit.outcome;
  final note = TextEditingController();
  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) => CrmPage(
    title: 'Visit Summary',
    children: [
      Panel(
        child: Column(
          children: [
            detail('Duration', '45 minutes', icon: Icons.schedule),
            detail(
              'Location',
              'Manual check-in · Unverified',
              icon: Icons.location_on_outlined,
            ),
            detail(
              'Notes',
              '${CrmStore.instance.notesFor(widget.visit.company).length} entries',
              icon: Icons.edit_note,
            ),
            detail(
              'Checklist',
              '${widget.visit.checklist.where((b) => b).length}/8 completed',
              icon: Icons.checklist,
            ),
            detail(
              'Signature',
              widget.visit.signature.isEmpty ? 'Not collected' : 'Collected',
              icon: Icons.draw_outlined,
            ),
          ],
        ),
      ),
      heading('Visit Outcome *'),
      for (final o in [
        'Positive — Deal progressing',
        'Neutral — Follow-up needed',
        'Negative — No interest',
        'Rescheduled',
        'No Show',
      ])
        RadioListTile<String>(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text(o, style: const TextStyle(fontSize: 12)),
          value: o,
          groupValue: outcome,
          onChanged: (v) => setState(() => outcome = v!),
        ),
      heading('Summary Note'),
      TextField(
        controller: note,
        maxLines: 4,
        decoration: InputDecoration(
          hintText: widget.visit.summary.isEmpty
              ? 'Record the outcome and next steps...'
              : widget.visit.summary,
        ),
      ),
      gap(20),
      if (widget.visit.status != 'Completed')
        button('Complete & Check Out', () {
          if (note.text.trim().isEmpty) {
            message(c, 'Add a summary before checking out');
            return;
          }
          CrmStore.instance.update(() {
            widget.visit.status = 'Completed';
            widget.visit.outcome = outcome;
            widget.visit.summary = note.text.trim();
          });
          Navigator.pushNamedAndRemoveUntil(c, '/visits', (r) => false);
          message(c, 'Visit completed');
        })
      else
        Panel(child: detail('Outcome', widget.visit.outcome)),
      button(
        'Schedule Follow-up',
        () => open(c, '/schedule-visit'),
        secondary: true,
      ),
    ],
  );
}

class NearbyScreen extends StatefulWidget {
  const NearbyScreen({super.key, this.routeMode = false});
  final bool routeMode;
  @override
  State<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends State<NearbyScreen> {
  String radius = '2 km', view = 'Map';
  @override
  Widget build(BuildContext c) {
    final leads =
        CrmStore.instance.leads
            .where((a) => a.distance <= double.parse(radius.split(' ').first))
            .toList()
          ..sort((a, b) => a.distance.compareTo(b.distance));
    return CrmPage(
      title: widget.routeMode ? 'Plan Route' : 'Nearby Leads',
      nav: widget.routeMode ? 2 : 1,
      actions: [
        TextButton(
          onPressed: () =>
              setState(() => view = view == 'Map' ? 'List' : 'Map'),
          child: Text(view == 'Map' ? 'List' : 'Map'),
        ),
      ],
      children: [
        if (!widget.routeMode)
          chips(
            ['1 km', '2 km', '5 km', '10 km'],
            radius,
            (v) => setState(() => radius = v),
          ),
        if (view == 'Map') const MapPreview(),
        if (widget.routeMode) ...[
          gap(),
          Panel(
            color: AppColors.primary,
            child: const Text(
              '✦ AI Smart Route\n\nReview and reorder stops to plan your day. Live routing requires a map service.',
              style: TextStyle(color: Colors.white, fontSize: 12, height: 1.6),
            ),
          ),
        ],
        heading(
          widget.routeMode
              ? 'ITINERARY (${leads.length} STOPS)'
              : 'NEARBY LEADS (SORTED BY DISTANCE)',
        ),
        for (final a in leads)
          Panel(
            color: Colors.white,
            onTap: () => open(c, '/lead-details', a),
            child: Row(
              children: [
                badge('${a.distance} km'),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [strong(a.company, 13), muted(a.area)],
                  ),
                ),
                actionIcon(
                  Icons.arrow_forward,
                  () => open(c, '/lead-details', a),
                  tooltip: 'Lead details',
                ),
              ],
            ),
          ),
        if (widget.routeMode)
          button('View Today’s Route', () => open(c, '/todays-route')),
      ],
    );
  }
}

/// Static map artwork extracted from the supplied design, not live GPS data.
class MapPreview extends StatelessWidget {
  const MapPreview({super.key});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
    child: AspectRatio(
      aspectRatio: 1184 / 864,
      child: LayoutBuilder(
        builder: (context, bounds) => Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/south_mumbai_map.png',
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              left: bounds.maxWidth * .23,
              top: bounds.maxHeight * .27,
              child: InkWell(
                onTap: () => open(context, '/lead-details'),
                child: badge('Acme Corp', color: AppColors.error),
              ),
            ),
            Positioned(
              left: bounds.maxWidth * .55,
              top: bounds.maxHeight * .55,
              child: InkWell(
                onTap: () => open(
                  context,
                  '/lead-details',
                  CrmStore.instance.leads.length > 1
                      ? CrmStore.instance.leads[1]
                      : null,
                ),
                child: badge('TechVista', color: AppColors.warning),
              ),
            ),
            Positioned(
              left: bounds.maxWidth * .41,
              top: bounds.maxHeight * .65,
              child: const CircleAvatar(
                radius: 9,
                backgroundColor: Colors.white,
                child: Icon(Icons.circle, color: AppColors.info, size: 12),
              ),
            ),
            const Positioned(
              left: 6,
              bottom: 6,
              child: ColoredBox(
                color: Color(0xDDFFFFFF),
                child: Padding(
                  padding: EdgeInsets.all(3),
                  child: Text(
                    'Design reference · Not a live map',
                    style: TextStyle(
                      fontSize: 9,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
