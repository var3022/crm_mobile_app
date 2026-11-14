import 'dart:async';
import 'package:flutter/material.dart';
import 'crm_store.dart';
import 'crm_ui.dart';
import 'crm_services.dart';
import 'tasks_deals_screens.dart' show dateText;

/// Page 54: Visits list and weekly calendar view
class VisitsScreen extends StatefulWidget {
  const VisitsScreen({super.key, this.empty = false});
  final bool empty;
  @override
  State<VisitsScreen> createState() => _VisitsScreenState();
}

class _VisitsScreenState extends State<VisitsScreen> {
  DateTime selected = DateUtils.dateOnly(DateTime.now());
  String view = 'List View';
  String filterStatus = 'All';

  @override
  Widget build(BuildContext c) => ListenableBuilder(
    listenable: CrmStore.instance,
    builder: (c, _) {
      final allVisits = widget.empty ? <Visit>[] : CrmStore.instance.visits;

      final visitsForDate = widget.empty
          ? <Visit>[]
          : allVisits.where((v) {
              final matchDate = DateUtils.isSameDay(v.date, selected);
              final matchStatus =
                  filterStatus == 'All' || v.status == filterStatus;
              return matchDate && matchStatus;
            }).toList();

      final monday = selected.subtract(Duration(days: selected.weekday - 1));

      return CrmPage(
        title: 'Visits',
        nav: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.route_outlined),
            tooltip: 'Plan Route',
            onPressed: () => open(c, '/plan-route'),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            tooltip: 'Choose date',
            onPressed: () async {
              final d = await showDatePicker(
                context: c,
                initialDate: selected,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (d != null) setState(() => selected = d);
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_circle),
            tooltip: 'Schedule visit',
            onPressed: () => open(c, '/schedule-visit'),
          ),
        ],
        children: [
          // Weekly Calendar Bar
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
                        border: Border.all(
                          color: selected.weekday == i + 1
                              ? AppColors.primary
                              : Colors.grey.shade200,
                        ),
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
                              fontWeight: FontWeight.w600,
                              color: selected.weekday == i + 1
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
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

          // Status Filter Chips
          chips(
            ['All', 'Scheduled', 'In Progress', 'Completed', 'Cancelled'],
            filterStatus,
            (s) => setState(() => filterStatus = s),
          ),
          gap(10),

          // Header summary & Actions
          Row(
            children: [
              Expanded(
                child: muted(
                  '${visitsForDate.length} visits · ${dateText(selected)}',
                ),
              ),
              TextButton.icon(
                onPressed: () => open(c, '/todays-route'),
                icon: const Icon(Icons.map, size: 16),
                label: const Text(
                  "Today's Route",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          gap(8),

          if (visitsForDate.isEmpty)
            emptyState(
              c,
              'No Visits Scheduled',
              'You have no client visits on this date. Use the button below or Plan Route to add visits to your schedule.',
              Icons.calendar_today_outlined,
              '+ Schedule Visit',
              () => open(c, '/schedule-visit'),
            )
          else
            for (final v in visitsForDate) ...[
              Panel(
                onTap: () => open(c, '/visit-details', v),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        avatar(v.initials),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              strong(v.company, 15),
                              const SizedBox(height: 2),
                              muted('${v.contact} · ${v.type}'),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.schedule,
                                    size: 12,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    v.time,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Icon(
                                    Icons.location_on_outlined,
                                    size: 12,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 2),
                                  Expanded(
                                    child: Text(
                                      v.locationAddress,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        _statusBadge(v.status),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (v.status == 'In Progress')
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                            ),
                            icon: const Icon(Icons.play_arrow, size: 16),
                            label: const Text(
                              'Resume Visit',
                              style: TextStyle(fontSize: 12),
                            ),
                            onPressed: () => open(c, '/active-visit', v),
                          )
                        else if (v.status == 'Scheduled')
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                            ),
                            icon: const Icon(
                              Icons.check_circle_outline,
                              size: 16,
                            ),
                            label: const Text(
                              'Check In',
                              style: TextStyle(fontSize: 12),
                            ),
                            onPressed: () => open(c, '/check-in', v),
                          )
                        else
                          OutlinedButton(
                            onPressed: () => open(c, '/visit-summary', v),
                            child: const Text(
                              'View Summary',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              gap(10),
            ],
        ],
      );
    },
  );

  Widget _statusBadge(String status) {
    Color bg;
    Color fg;
    if (status == 'In Progress') {
      bg = Colors.amber.shade100;
      fg = Colors.amber.shade900;
    } else if (status == 'Completed') {
      bg = Colors.green.shade100;
      fg = Colors.green.shade900;
    } else if (status == 'Cancelled') {
      bg = Colors.red.shade100;
      fg = Colors.red.shade900;
    } else {
      bg = Colors.blue.shade100;
      fg = Colors.blue.shade900;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// Helper extension for avatar initials
extension on Visit {
  String get initials => company
      .split(' ')
      .take(2)
      .map((s) => s.isEmpty ? '' : s[0])
      .join()
      .toUpperCase();
}

/// Page 56: Schedule Visit Form
Widget scheduleVisitForm([BuildContext? context, Account? account]) => CrmForm(
  title: 'Schedule Visit',
  submit: 'Confirm Schedule',
  fields: [
    FormFieldSpec(
      'Associated Lead / Customer',
      required: true,
      initial: account?.company,
      options: [
        for (final a in [
          ...CrmStore.instance.leads,
          ...CrmStore.instance.customers,
        ])
          a.company,
      ],
    ),
    const FormFieldSpec(
      'Contact Person',
      required: true,
      initial: 'Priya Sharma',
    ),
    FormFieldSpec(
      'Visit Date',
      type: 'date',
      initial: DateTime.now().toIso8601String().split('T').first,
    ),
    FormFieldSpec(
      'Visit Time',
      type: 'select',
      initial: '11:30 AM',
      options: const [
        '09:30 AM',
        '11:30 AM',
        '02:00 PM',
        '04:15 PM',
        '05:30 PM',
      ],
    ),
    FormFieldSpec(
      'Visit Type',
      type: 'select',
      initial: 'Product Demo',
      options: const [
        'First Meeting',
        'Follow-up',
        'Product Demo',
        'Negotiation',
        'Contract Signing',
      ],
    ),
    const FormFieldSpec(
      'Estimated Duration',
      type: 'select',
      initial: '45 min',
      options: ['30 min', '45 min', '1 hr', '1.5 hr', '2 hr'],
    ),
    const FormFieldSpec(
      'Purpose / Agenda',
      lines: 3,
      initial: 'Review solution architecture and finalize licensing seats.',
    ),
  ],
  onSave: (c, v) async {
    try {
      await CrmStore.instance.update(() {
        final visit = Visit(
          v['Associated Lead / Customer']!,
          v['Contact Person']!,
          v['Visit Time']!,
          v['Visit Type']!,
          date: DateTime.parse(v['Visit Date']!),
          purpose: v['Purpose / Agenda']!,
          duration: v['Estimated Duration']!,
          locationAddress: '12th Floor, Maker Chambers, Nariman Point, Mumbai',
        );
        CrmStore.instance.visits.add(visit);
      });
      if (c.mounted) {
        Navigator.pop(c);
        message(c, 'Visit scheduled successfully');
      }
    } catch (e) {
      if (c.mounted) {
        ScaffoldMessenger.of(c).showSnackBar(
          SnackBar(
            content: Text('Failed to schedule visit: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  },
);

/// Page 57: Reschedule Visit Form
Widget rescheduleVisitForm([BuildContext? context, Visit? visit]) => CrmForm(
  title: 'Reschedule Visit',
  submit: 'Save Reschedule',
  fields: [
    FormFieldSpec(
      'Associated Lead / Customer',
      required: true,
      initial: visit?.company,
      options: [
        for (final a in [
          ...CrmStore.instance.leads,
          ...CrmStore.instance.customers,
        ])
          a.company,
      ],
    ),
    FormFieldSpec(
      'Contact Person',
      required: true,
      initial: visit?.contact ?? 'Priya Sharma',
    ),
    FormFieldSpec(
      'Visit Date',
      type: 'date',
      initial: (visit?.date ?? DateTime.now().add(const Duration(days: 1)))
          .toIso8601String()
          .split('T')
          .first,
    ),
    FormFieldSpec(
      'Visit Time',
      type: 'select',
      initial: visit?.time ?? '02:00 PM',
      options: const [
        '09:30 AM',
        '11:30 AM',
        '02:00 PM',
        '04:15 PM',
        '05:30 PM',
      ],
    ),
    FormFieldSpec(
      'Reason for Rescheduling',
      type: 'select',
      initial: 'Client Requested Different Time',
      options: const [
        'Client Requested Different Time',
        'Traffic / Logistics Delay',
        'Emergency Reassignment',
        'Double Booking',
        'Other',
      ],
    ),
    FormFieldSpec(
      'Estimated Duration',
      type: 'select',
      initial: visit?.duration ?? '45 min',
      options: const ['30 min', '45 min', '1 hr', '1.5 hr', '2 hr'],
    ),
    FormFieldSpec(
      'Purpose / Agenda',
      lines: 3,
      initial: visit?.purpose.isNotEmpty == true
          ? visit!.purpose
          : 'Rescheduled agenda discussion and contract terms review.',
    ),
  ],
  onSave: (c, v) async {
    try {
      await CrmStore.instance.update(() {
        final item =
            visit ??
            Visit(
              v['Associated Lead / Customer']!,
              v['Contact Person']!,
              v['Visit Time']!,
              v['Visit Type'] ?? 'Follow-up',
            );
        item.company = v['Associated Lead / Customer']!;
        item.contact = v['Contact Person']!;
        item.date = DateTime.parse(v['Visit Date']!);
        item.time = v['Visit Time']!;
        item.purpose = v['Purpose / Agenda']!;
        item.duration = v['Estimated Duration']!;
        item.status = 'Scheduled';
        if (visit == null) CrmStore.instance.visits.add(item);
      });
      if (c.mounted) {
        Navigator.pop(c);
        message(c, 'Visit rescheduled');
      }
    } catch (e) {
      if (c.mounted) {
        ScaffoldMessenger.of(c).showSnackBar(
          SnackBar(
            content: Text('Failed to reschedule visit: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  },
);

/// Backward-compatible visit form function
Widget visitForm([Visit? visit, Account? account]) => visit == null
    ? scheduleVisitForm(null, account)
    : rescheduleVisitForm(null, visit);

/// Page 55: Visit Details Screen with quick actions & location preview
class VisitDetailsScreen extends StatelessWidget {
  const VisitDetailsScreen({super.key, required this.visit});
  final Visit visit;

  @override
  Widget build(BuildContext c) => ListenableBuilder(
    listenable: CrmStore.instance,
    builder: (c, _) => CrmPage(
      title: 'Visit Details',
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_calendar_outlined),
          tooltip: 'Reschedule visit',
          onPressed: () => open(c, '/reschedule-visit', visit),
        ),
      ],
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            badge('${visit.status} Visit'),
            Text(
              visit.duration,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
        gap(16),
        strong(visit.company, 22),
        muted(
          visit.purpose.isEmpty
              ? 'Product demo & setup verification'
              : visit.purpose,
        ),
        gap(15),

        // Quick Communication Handoffs (Call, WhatsApp, Email, Directions)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _actionPill(
              Icons.phone,
              'Call',
              () => DeviceService.callPhone('+919876543210'),
            ),
            _actionPill(
              Icons.chat_bubble_outline,
              'WhatsApp',
              () => DeviceService.sendWhatsApp(
                '+919876543210',
                'Hello ${visit.contact}, looking forward to our meeting today.',
              ),
            ),
            _actionPill(
              Icons.email_outlined,
              'Email',
              () => DeviceService.sendEmail(
                'client@${visit.company.toLowerCase().replaceAll(" ", "")}.com',
                'Meeting Confirmation',
              ),
            ),
            _actionPill(
              Icons.directions_outlined,
              'Navigate',
              () => DeviceService.getDirections(visit.locationAddress),
            ),
          ],
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
                visit.locationAddress,
                icon: Icons.location_on_outlined,
              ),
            ],
          ),
        ),
        const MapPreview(),
        gap(),

        button(
          visit.status == 'Completed'
              ? 'View Summary'
              : visit.status == 'In Progress'
              ? 'Resume Visit'
              : 'Check In',
          () {
            if (visit.status == 'Completed') {
              open(c, '/visit-summary', visit);
            } else if (visit.status == 'In Progress') {
              open(c, '/active-visit', visit);
            } else {
              open(c, '/check-in', visit);
            }
          },
        ),
        button(
          'Reschedule Visit',
          () => open(c, '/reschedule-visit', visit),
          secondary: true,
        ),
        TextButton(
          onPressed: () => _confirmCancelVisit(c, visit),
          child: const Text(
            'Cancel Visit',
            style: TextStyle(color: AppColors.error),
          ),
        ),
      ],
    ),
  );

  Widget _actionPill(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmCancelVisit(BuildContext context, Visit v) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CancelVisitModal(visit: v),
    );
  }
}

/// Page 58: Cancel Visit Modal Bottom Sheet
class CancelVisitModal extends StatefulWidget {
  const CancelVisitModal({super.key, required this.visit});
  final Visit visit;

  @override
  State<CancelVisitModal> createState() => _CancelVisitModalState();
}

class _CancelVisitModalState extends State<CancelVisitModal> {
  String selectedReason = 'Client Requested Cancellation';
  final note = TextEditingController();

  final reasons = const [
    'Client Requested Cancellation',
    'Client Unreachable / No Show',
    'Internal Reassignment',
    'Inclement Weather / Emergency',
    'Other',
  ];

  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Cancel Visit',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 6),
          Text(
            'Please select the cancellation reason for ${widget.visit.company}:',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: selectedReason,
            decoration: const InputDecoration(
              labelText: 'Reason for Cancellation',
            ),
            items: reasons
                .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                .toList(),
            onChanged: (v) => setState(() => selectedReason = v!),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: note,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Additional Notes (Optional)',
              hintText: 'Add details for manager audit log...',
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    CrmStore.instance.update(() {
                      widget.visit.status = 'Cancelled';
                      if (note.text.isNotEmpty) {
                        widget.visit.summary =
                            'Cancelled: $selectedReason - ${note.text}';
                      }
                    });
                    Navigator.pop(context);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Visit marked as Cancelled'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Confirm Cancel'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Page 59: Dedicated Plan Route Screen with AI Route Optimization and Stop Ordering
class PlanRouteScreen extends StatefulWidget {
  const PlanRouteScreen({super.key});
  @override
  State<PlanRouteScreen> createState() => _PlanRouteScreenState();
}

class _PlanRouteScreenState extends State<PlanRouteScreen> {
  bool avoidTolls = false;
  bool avoidHighways = false;
  bool isAiOptimized = false;

  late List<Visit> stops;

  @override
  void initState() {
    super.initState();
    stops = List.from(CrmStore.instance.visits);
  }

  void _applyAiOptimization() {
    setState(() {
      isAiOptimized = true;
      // Optimize sequence by distance/urgency
      stops.sort((a, b) => a.company.length.compareTo(b.company.length));
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AI Route Applied: Saved ~42 min & 8.4 km')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Plan Route',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share Itinerary',
            onPressed: () {
              DeviceService.shareContent(
                title: 'Planned Route',
                text:
                    'Today\'s 6-Stop Route:\n1. Acme Corp\n2. TechVista\n3. DataFlow',
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Current Location Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.my_location, color: AppColors.primary, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'STARTING POINT',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Maker Chambers, Nariman Point, Mumbai',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // AI Route Optimization Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withOpacity(0.85),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.amber, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'AI Route Optimization',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Reorder your 6 scheduled stops based on live traffic to save ~42 min travel time & 8.4 km fuel.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: isAiOptimized ? null : _applyAiOptimization,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: Text(
                    isAiOptimized ? 'AI Route Applied ✓' : 'Apply AI Route',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Stops List Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ITINERARY (${stops.length} STOPS)',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              TextButton.icon(
                onPressed: () => open(context, '/schedule-visit'),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Stop', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Reorderable list of stops
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stops.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex--;
                final item = stops.removeAt(oldIndex);
                stops.insert(newIndex, item);
              });
            },
            itemBuilder: (context, index) {
              final stop = stops[index];
              return Container(
                key: ValueKey(stop.id),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stop.company,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '${stop.time} · ${stop.locationAddress}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.drag_handle, color: Colors.grey),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // Route Preferences Checkboxes
          CheckboxListTile(
            value: avoidTolls,
            onChanged: (v) => setState(() => avoidTolls = v ?? false),
            title: const Text('Avoid Tolls', style: TextStyle(fontSize: 13)),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          CheckboxListTile(
            value: avoidHighways,
            onChanged: (v) => setState(() => avoidHighways = v ?? false),
            title: const Text('Avoid Highways', style: TextStyle(fontSize: 13)),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 12),

          // Total Summary Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      'Total Distance',
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '33.4 km',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'Est. Drive Time',
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '~1h 45m',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'End of Day',
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '~5:30 PM',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => open(context, '/todays-route'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.navigation, size: 18),
              label: const Text(
                'Start Route · Open Turn-by-Turn',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Page 60: Dedicated Today's Route Screen with Map View and Next Stop Sheet
class TodaysRouteScreen extends StatefulWidget {
  const TodaysRouteScreen({super.key});
  @override
  State<TodaysRouteScreen> createState() => _TodaysRouteScreenState();
}

class _TodaysRouteScreenState extends State<TodaysRouteScreen> {
  int currentStopIndex = 1; // TechVista Solutions

  @override
  Widget build(BuildContext context) {
    final visits = CrmStore.instance.visits;
    final nextVisit = visits.length > 1 ? visits[1] : visits.first;

    return Scaffold(
      body: Stack(
        children: [
          // Full-screen Map Background
          Positioned.fill(
            child: Image.asset(
              'assets/images/south_mumbai_map.png',
              fit: BoxFit.cover,
            ),
          ),

          // Floating Top Route Header Card
          Positioned(
            top: 48,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Today's Route",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '6 stops · 33.4 km · ~1h 45m drive',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.tune),
                    onPressed: () => open(context, '/plan-route'),
                  ),
                ],
              ),
            ),
          ),

          // Map Zoom & Recenter Controls
          Positioned(
            right: 16,
            top: 140,
            child: Column(
              children: [
                _mapControl(Icons.add, () {}),
                const SizedBox(height: 6),
                _mapControl(Icons.remove, () {}),
                const SizedBox(height: 6),
                _mapControl(Icons.my_location, () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Centered on current GPS location'),
                    ),
                  );
                }),
              ],
            ),
          ),

          // Bottom Sheet: Next Stop Details
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'NEXT STOP #2',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        '3.2 km away · ~12 min',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    nextVisit.company,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${nextVisit.contact} · ${nextVisit.locationAddress}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => DeviceService.getDirections(
                            nextVisit.locationAddress,
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.directions, size: 18),
                          label: const Text('Navigate'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              open(context, '/check-in', nextVisit),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('Mark Arrived'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapControl(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: AppColors.textDark),
      ),
    );
  }
}

/// Pages 61, 62, 63: Check-in Screen with verified radar, error fallback, and far resolution
class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key, required this.visit, this.mode = 'normal'});
  final Visit visit;
  final String mode; // 'normal', 'error', 'far'
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

  void _proceedCheckIn(String modeType) async {
    final store = CrmStore.instance;
    try {
      await store.startVisit(widget.visit);
      widget.visit.checkInMode = modeType;
      if (reason.text.trim().isNotEmpty) {
        widget.visit.checkInReason = reason.text.trim();
      }
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/active-visit',
          arguments: widget.visit,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to check in: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext c) {
    if (widget.mode == 'error') {
      return _buildGpsErrorScreen(c);
    }
    if (widget.mode == 'far') {
      return _buildFarLocationScreen(c);
    }
    return _buildVerifiedScreen(c);
  }

  // Page 61: Verified In-Radius Check-in
  Widget _buildVerifiedScreen(BuildContext c) => CrmPage(
    title: 'Location Check-In',
    children: [
      // Honest Simulation Notice
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.amber.shade300),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.location_searching, color: Colors.amber, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'SIMULATED LOCATION (Development Mode)\n'
                'Simulated coordinates: Lat 37.7749, Lng -122.4194 (~45m from client). '
                'No native hardware GPS provider is connected. Check-in is audited as simulated radius.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.amber.shade900,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
      gap(16),
      const MapPreview(),
      gap(16),
      Center(
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.gps_fixed,
            size: 42,
            color: AppColors.primary,
          ),
        ),
      ),
      gap(12),
      const Center(
        child: Text(
          'Simulated In-Radius Check-In',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      gap(4),
      Center(
        child: Text(
          'Simulated location: ~45m from client office (expected: <200m)',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
      ),
      gap(20),
      Panel(
        child: Column(
          children: [
            detail('Client', widget.visit.company, icon: Icons.business),
            detail(
              'Contact Person',
              widget.visit.contact,
              icon: Icons.person_outline,
            ),
            detail('Scheduled Time', widget.visit.time, icon: Icons.schedule),
            detail(
              'Address',
              widget.visit.locationAddress,
              icon: Icons.location_on_outlined,
            ),
          ],
        ),
      ),
      gap(20),
      button(
        'Proceed with Simulated Check-In',
        () => _proceedCheckIn('simulated_radius'),
      ),
      button('Cancel', () => Navigator.pop(c), secondary: true),
    ],
  );

  // Page 62: GPS Error Fallback Screen
  Widget _buildGpsErrorScreen(BuildContext c) => CrmPage(
    title: 'Location Unavailable',
    children: [
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.amber.shade200),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.amber,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'GPS Signal Weak or Unavailable',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Unable to lock precise GPS coordinates. Select an alternative resolution:',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      gap(20),
      Panel(
        onTap: () => _proceedCheckIn('last_known'),
        child: const Row(
          children: [
            Icon(Icons.history, color: AppColors.primary),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Use Last Known Location',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Maker Chambers, Nariman Point (3 min ago)',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
      gap(10),
      Panel(
        onTap: () => _proceedCheckIn('manual'),
        child: const Row(
          children: [
            Icon(Icons.edit_location_alt_outlined, color: AppColors.primary),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter Location Manually',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Requires manager approval in audit trail',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
      gap(10),
      Panel(
        onTap: () => _proceedCheckIn('unverified'),
        child: const Row(
          children: [
            Icon(Icons.flag_outlined, color: AppColors.error),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Check In Unverified',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Logs audit flag for administrative review',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    ],
  );

  // Page 63: Far From Location Modal Screen
  Widget _buildFarLocationScreen(BuildContext c) => CrmPage(
    title: 'Far From Location',
    children: [
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.location_off_outlined,
              color: AppColors.error,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '2.4 km Away from Client Address',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Expected range: within 200m of scheduled location.',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      gap(16),
      TextField(
        controller: reason,
        decoration: const InputDecoration(
          labelText: 'Reason for remote check-in',
          hintText: 'e.g. Client changed meeting location to coffee shop...',
        ),
        maxLines: 3,
      ),
      gap(12),
      CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        value: consent,
        onChanged: (v) => setState(() => consent = v!),
        title: const Text(
          'I confirm that this visit is taking place remotely or at an agreed alternate location',
          style: TextStyle(fontSize: 12),
        ),
      ),
      gap(16),
      button('Check In Anyway (Flagged)', () {
        if (!consent || reason.text.trim().isEmpty) {
          message(c, 'Please provide an explanation and confirm the checkbox');
          return;
        }
        _proceedCheckIn('far_override');
      }),
      button('Get Directions to Scheduled Address', () {
        DeviceService.getDirections(widget.visit.locationAddress);
      }, secondary: true),
    ],
  );
}

/// Page 64: Active Visit Screen with persistent timer across navigation & 6 visit tasks
class ActiveVisitScreen extends StatefulWidget {
  const ActiveVisitScreen({super.key, required this.visit});
  final Visit visit;
  @override
  State<ActiveVisitScreen> createState() => _ActiveVisitScreenState();
}

class _ActiveVisitScreenState extends State<ActiveVisitScreen> {
  Timer? timer;
  late int seconds;
  final quick = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Retrieve persistent elapsed seconds from CrmStore so navigation never resets the timer!
    seconds = CrmStore.instance.activeVisitElapsedSeconds;
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          seconds = CrmStore.instance.activeVisitElapsedSeconds;
        });
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    quick.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) => ListenableBuilder(
    listenable: CrmStore.instance,
    builder: (c, _) {
      final store = CrmStore.instance;
      final notesCount = store.notesFor(widget.visit.company).length;
      final checklistDone = widget.visit.checklist.where((b) => b).length;
      final photoCount = store.photos
          .where((p) => p.company == widget.visit.company)
          .length;
      final voiceCount = store.voiceNotes
          .where((v) => v.company == widget.visit.company)
          .length;
      final hasSignature = widget.visit.signature.isNotEmpty;

      return CrmPage(
        title: 'Visit in Progress',
        actions: [
          TextButton(
            onPressed: () => open(c, '/visit-details', widget.visit),
            child: const Text('Details'),
          ),
        ],
        children: [
          // Persistent Live Timer Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.fiber_manual_record,
                  color: AppColors.error,
                  size: 14,
                ),
                const SizedBox(width: 8),
                const Text(
                  'VISIT IN PROGRESS',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(seconds ~/ 3600).toString().padLeft(2, '0')}:${(seconds ~/ 60 % 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
          gap(14),

          // Client Card with quick handoffs
          Panel(
            child: Column(
              children: [
                Row(
                  children: [
                    avatar(widget.visit.initials),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          strong(widget.visit.company, 16),
                          muted(
                            '${widget.visit.contact} · ${widget.visit.type}',
                          ),
                          Text(
                            widget.visit.locationAddress,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      onPressed: () => DeviceService.callPhone('+919876543210'),
                      icon: const Icon(Icons.phone, size: 16),
                      label: const Text('Call', style: TextStyle(fontSize: 12)),
                    ),
                    TextButton.icon(
                      onPressed: () => DeviceService.sendWhatsApp(
                        '+919876543210',
                        'In-meeting update',
                      ),
                      icon: const Icon(Icons.chat_bubble_outline, size: 16),
                      label: const Text(
                        'WhatsApp',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => DeviceService.getDirections(
                        widget.visit.locationAddress,
                      ),
                      icon: const Icon(Icons.directions, size: 16),
                      label: const Text(
                        'Directions',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          gap(14),

          heading('Visit Tasks'),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _visitTaskTile(
                c,
                Icons.edit_note,
                'Meeting Notes',
                '$notesCount notes',
                notesCount > 0,
                '/visit-notes',
              ),
              _visitTaskTile(
                c,
                Icons.checklist,
                'Checklist',
                '$checklistDone/8 done',
                checklistDone > 0,
                '/visit-checklist',
              ),
              _visitTaskTile(
                c,
                Icons.photo_camera_outlined,
                'Capture Photos',
                '$photoCount photos',
                photoCount > 0,
                '/photos',
              ),
              _visitTaskTile(
                c,
                Icons.mic_none,
                'Voice Memo',
                '$voiceCount memos',
                voiceCount > 0,
                '/voice-notes',
              ),
              _visitTaskTile(
                c,
                Icons.draw_outlined,
                'Client Signature',
                hasSignature ? 'Signed ✓' : 'Pending',
                hasSignature,
                '/signature',
              ),
              _visitTaskTile(
                c,
                Icons.assignment_turned_in_outlined,
                'Review Checkout',
                'Summary note',
                false,
                '/visit-summary',
              ),
            ],
          ),
          gap(16),

          heading('Quick Notes'),
          TextField(
            controller: quick,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Type meeting takeaways, SLA comments or next steps...',
            ),
          ),
          TextButton.icon(
            onPressed: () async {
              if (quick.text.trim().isEmpty) return;
              final text = quick.text.trim();
              quick.clear();
              try {
                await store.addNote(widget.visit.company, text);
                if (c.mounted) {
                  ScaffoldMessenger.of(
                    c,
                  ).showSnackBar(const SnackBar(content: Text('Note added')));
                }
              } catch (e) {
                if (c.mounted) {
                  ScaffoldMessenger.of(c).showSnackBar(
                    SnackBar(
                      content: Text('Failed to add note: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.send, size: 16),
            label: const Text('Save Note'),
          ),
          gap(10),

          // AI Copilot Suggestion Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.9)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.amber, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'AI Copilot Suggestion',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  'Client showed high interest in Enterprise SaaS SLA during the last call. Recommend highlighting our 99.99% uptime guarantee and dedicated customer success manager.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          gap(16),

          button(
            'End Visit & Check Out',
            () => open(c, '/visit-summary', widget.visit),
          ),
        ],
      );
    },
  );

  Widget _visitTaskTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    bool completed,
    String route,
  ) {
    return SizedBox(
      width: (MediaQuery.sizeOf(context).width - 50) / 2,
      child: InkWell(
        onTap: () => open(context, route, widget.visit),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: completed
                  ? AppColors.success.withOpacity(0.5)
                  : Colors.grey.shade200,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: completed ? AppColors.success : AppColors.primary,
                  ),
                  if (completed)
                    const Icon(
                      Icons.check_circle,
                      size: 14,
                      color: AppColors.success,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Page 65: Visit Notes Screen with rich formatting toolbar & voice memo player
class VisitNotesScreen extends StatefulWidget {
  const VisitNotesScreen({super.key, required this.visit});
  final Visit visit;
  @override
  State<VisitNotesScreen> createState() => _VisitNotesScreenState();
}

class _VisitNotesScreenState extends State<VisitNotesScreen> {
  final input = TextEditingController();
  bool isBold = false;
  bool isItalic = false;

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  void _saveNote() async {
    if (input.text.trim().isEmpty) return;
    String text = input.text.trim();
    if (isBold) text = '**$text**';
    if (isItalic) text = '*$text*';
    input.clear();
    try {
      await CrmStore.instance.addNote(widget.visit.company, text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note added to visit record')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add note: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext c) => ListenableBuilder(
    listenable: CrmStore.instance,
    builder: (c, _) {
      final notes = CrmStore.instance.notesFor(widget.visit.company);
      final voiceMemo = CrmStore.instance.voiceNotes
          .cast<VoiceNoteRecord?>()
          .firstWhere(
            (v) => v?.company == widget.visit.company,
            orElse: () => null,
          );

      return CrmPage(
        title: 'Visit Notes',
        actions: [
          IconButton(
            icon: const Icon(Icons.mic),
            tooltip: 'Record Voice Memo',
            onPressed: () => open(c, '/voice-note', widget.visit),
          ),
        ],
        children: [
          muted('Meeting Notes · ${widget.visit.company}'),
          gap(12),

          // Attached Voice Memo Card if present
          if (voiceMemo != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.mic, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          voiceMemo.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          'Duration: ${voiceMemo.duration} · Transcribed ✓',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => open(c, '/recording-player', voiceMemo),
                    child: const Text('Play'),
                  ),
                ],
              ),
            ),
          gap(12),

          // Timestamped Notes List
          if (notes.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No notes recorded yet for this visit.',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ),
            )
          else
            for (int i = 0; i < notes.length; i++)
              Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 12,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(child: muted('Note #${notes.length - i}')),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 16,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            CrmStore.instance.update(() {
                              if (CrmStore.instance.accountNotes[widget
                                          .visit
                                          .company] !=
                                      null &&
                                  i <
                                      CrmStore
                                          .instance
                                          .accountNotes[widget.visit.company]!
                                          .length) {
                                CrmStore
                                    .instance
                                    .accountNotes[widget.visit.company]!
                                    .removeAt(i);
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    Text(
                      notes[i],
                      style: const TextStyle(fontSize: 13, height: 1.5),
                    ),
                  ],
                ),
              ),
          gap(14),

          // Rich Formatting Bar & Input
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.format_bold,
                  color: isBold ? AppColors.primary : Colors.grey,
                ),
                onPressed: () => setState(() => isBold = !isBold),
              ),
              IconButton(
                icon: Icon(
                  Icons.format_italic,
                  color: isItalic ? AppColors.primary : Colors.grey,
                ),
                onPressed: () => setState(() => isItalic = !isItalic),
              ),
              IconButton(
                icon: const Icon(
                  Icons.format_list_bulleted,
                  color: Colors.grey,
                ),
                onPressed: () {
                  input.text = '• ${input.text}';
                },
              ),
            ],
          ),
          TextField(
            controller: input,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Add Meeting Takeaway / Action Item',
              hintText: 'Enter discussion notes...',
            ),
          ),
          gap(10),
          button('Save Note', _saveNote),
        ],
      );
    },
  );
}

/// Page 66: Visit Checklist Screen with Grouped Items and Custom Item Addition
class VisitChecklistScreen extends StatefulWidget {
  const VisitChecklistScreen({super.key, required this.visit});
  final Visit visit;

  @override
  State<VisitChecklistScreen> createState() => _VisitChecklistScreenState();
}

class _VisitChecklistScreenState extends State<VisitChecklistScreen> {
  void _addCustomItemDialog() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Custom Checklist Item'),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. Verify dual power socket',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (textController.text.trim().isNotEmpty) {
                CrmStore.instance.update(() {
                  widget.visit.customChecklist.add(textController.text.trim());
                  widget.visit.checklist.add(false);
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext c) => ListenableBuilder(
    listenable: CrmStore.instance,
    builder: (c, _) {
      final total = widget.visit.checklist.length;
      final completed = widget.visit.checklist.where((b) => b).length;
      final percent = total > 0 ? (completed / total) : 0.0;

      return CrmPage(
        title: 'Visit Checklist',
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Custom Item',
            onPressed: _addCustomItemDialog,
          ),
        ],
        children: [
          muted(widget.visit.company),
          gap(12),
          Row(
            children: [
              Expanded(child: strong('Overall Completion', 14)),
              muted('$completed of $total items (${(percent * 100).round()}%)'),
            ],
          ),
          gap(8),
          LinearProgressIndicator(
            value: percent,
            backgroundColor: AppColors.primaryLight,
            color: AppColors.primary,
          ),
          gap(20),

          // Pre-Meeting section
          heading('PRE-MEETING PREPARATION'),
          _checkTile(0, 'Review past meeting minutes & account SLA terms'),
          _checkTile(1, 'Prepare updated enterprise product catalog & deck'),
          _checkTile(2, 'Confirm decision-maker attendance with reception'),

          // During Meeting section
          heading('DURING MEETING DISCUSSION'),
          _checkTile(3, 'Present cloud storage & field attendance module'),
          _checkTile(4, 'Discuss volume pricing discounts & contract tenure'),
          _checkTile(5, 'Address security, SOC2 compliance & data residency'),

          // Post-Meeting section
          heading('POST-MEETING ACTIONS'),
          _checkTile(6, 'Collect digital signature on meeting verification'),
          _checkTile(7, 'Record audio debrief and sync with mobile CRM'),

          // Custom items section if any
          if (widget.visit.customChecklist.isNotEmpty) ...[
            heading('CUSTOM VISIT ITEMS'),
            for (int i = 0; i < widget.visit.customChecklist.length; i++)
              _checkTile(8 + i, widget.visit.customChecklist[i]),
          ],

          gap(20),
          button('Save Checklist', () {
            message(c, 'Checklist progress saved');
            Navigator.pop(c);
          }),
        ],
      );
    },
  );

  Widget _checkTile(int index, String label) {
    if (index >= widget.visit.checklist.length) {
      widget.visit.checklist.add(false);
    }
    final isDone = widget.visit.checklist[index];

    return CheckboxListTile(
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          decoration: isDone ? TextDecoration.lineThrough : null,
          color: isDone ? Colors.grey : AppColors.textDark,
        ),
      ),
      value: isDone,
      onChanged: (v) => CrmStore.instance.update(
        () => widget.visit.checklist[index] = v ?? false,
      ),
    );
  }
}

/// Page 67: Digital Signature Screen with pen thickness & designation metadata
class SignatureScreen extends StatefulWidget {
  const SignatureScreen({super.key, required this.visit});
  final Visit visit;
  @override
  State<SignatureScreen> createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  double strokeWidth = 2.4;
  String selectedPurpose = 'Meeting Attendance Confirmation';
  final nameController = TextEditingController();
  final designationController = TextEditingController();

  final purposes = const [
    'Meeting Attendance Confirmation',
    'NDA & Compliance Acceptance',
    'Contract Execution Kickoff',
    'Delivery & Demo Acknowledgment',
  ];

  @override
  void initState() {
    super.initState();
    nameController.text = widget.visit.signerName.isNotEmpty
        ? widget.visit.signerName
        : widget.visit.contact;
    designationController.text = widget.visit.signerDesignation;
  }

  @override
  void dispose() {
    nameController.dispose();
    designationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) => CrmPage(
    title: 'Collect Signature',
    children: [
      Panel(
        child: Column(
          children: [
            detail('Signer', nameController.text, icon: Icons.person_outline),
            detail(
              'Client Company',
              widget.visit.company,
              icon: Icons.business,
            ),
          ],
        ),
      ),
      gap(12),

      DropdownButtonFormField<String>(
        value: selectedPurpose,
        decoration: const InputDecoration(labelText: 'Signature Purpose'),
        items: purposes
            .map(
              (p) => DropdownMenuItem(
                value: p,
                child: Text(p, style: const TextStyle(fontSize: 12)),
              ),
            )
            .toList(),
        onChanged: (v) => setState(() => selectedPurpose = v!),
      ),
      gap(14),

      // Signature Canvas Header with Clear & Pen Width
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Digital Signature Canvas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.brush, size: 18),
                tooltip: 'Pen Thickness',
                onPressed: () {
                  setState(() {
                    strokeWidth = strokeWidth == 2.4
                        ? 4.0
                        : strokeWidth == 4.0
                        ? 1.5
                        : 2.4;
                  });
                },
              ),
              TextButton(
                onPressed: () => setState(() => widget.visit.signature.clear()),
                child: const Text('Clear Canvas'),
              ),
            ],
          ),
        ],
      ),

      // Signature Drawing Canvas
      Container(
        height: 220,
        decoration: BoxDecoration(
          color: Colors.white,
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
              painter: SignaturePainter(
                widget.visit.signature,
                strokeWidth: strokeWidth,
              ),
              child: Center(
                child: widget.visit.signature.isEmpty
                    ? Text(
                        'Touch or draw to sign here',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                      )
                    : const SizedBox(),
              ),
            ),
          ),
        ),
      ),
      gap(14),

      TextField(
        controller: nameController,
        decoration: const InputDecoration(labelText: 'Signer Full Name'),
      ),
      gap(10),
      TextField(
        controller: designationController,
        decoration: const InputDecoration(
          labelText: 'Signer Designation / Title',
        ),
      ),
      gap(10),
      Row(
        children: [
          const Icon(Icons.lock_outline, size: 14, color: Colors.grey),
          const SizedBox(width: 6),
          Text(
            'Timestamp: ${DateTime.now().toLocal().toString().split(".")[0]} · Tamper-proof',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
      gap(20),

      button('Confirm & Save Signature', () {
        if (widget.visit.signature.whereType<Offset>().length < 3) {
          message(c, 'Please provide a signature on the canvas');
          return;
        }
        CrmStore.instance.update(() {
          widget.visit.signerName = nameController.text.trim();
          widget.visit.signerDesignation = designationController.text.trim();
          widget.visit.signerTimestamp = DateTime.now();
        });
        message(c, 'Signature recorded');
        Navigator.pop(c);
      }),
      button('Skip Signature', () => Navigator.pop(c), secondary: true),
    ],
  );
}

class SignaturePainter extends CustomPainter {
  SignaturePainter(this.points, {this.strokeWidth = 2.4});
  final List<Offset?> points;
  final double strokeWidth;

  @override
  void paint(Canvas c, Size s) {
    final p = Paint()
      ..color = AppColors.primary
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    for (int i = 1; i < points.length; i++) {
      if (points[i - 1] != null && points[i] != null) {
        c.drawLine(points[i - 1]!, points[i]!, p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant SignaturePainter old) => true;
}

/// Page 68: Visit Checkout Summary Screen with AI auto-generate summary
class VisitSummaryScreen extends StatefulWidget {
  const VisitSummaryScreen({super.key, required this.visit});
  final Visit visit;
  @override
  State<VisitSummaryScreen> createState() => _VisitSummaryScreenState();
}

class _VisitSummaryScreenState extends State<VisitSummaryScreen> {
  late String outcome = widget.visit.outcome;
  String nextSteps = 'Send Formal Proposal';
  final note = TextEditingController();
  DateTime followUpDate = DateTime.now().add(const Duration(days: 5));

  final nextStepsOptions = const [
    'Send Formal Proposal',
    'Schedule Solutions Deep-Dive Demo',
    'Send Revised Quote with SLA',
    'Awaiting Client Budget Approval',
    'No Immediate Action',
  ];

  @override
  void initState() {
    super.initState();
    note.text = widget.visit.summary;
  }

  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  void _autoGenerateSummaryWithAi() {
    final duration = widget.visit.duration;
    final notes = CrmStore.instance.notesFor(widget.visit.company);
    final notesSnippet = notes.isNotEmpty
        ? notes.first
        : 'Discussed enterprise roadmap and security.';

    setState(() {
      note.text =
          'Conducted a $duration visit with ${widget.visit.contact} (${widget.visit.company}). $notesSnippet Agreement reached on key evaluation metrics. Scheduled next step: $nextSteps for ${dateText(followUpDate)}.';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AI Visit Summary Auto-Generated!')),
    );
  }

  @override
  Widget build(BuildContext c) => CrmPage(
    title: 'Visit Summary & Checkout',
    children: [
      // Header Artifacts Card
      Panel(
        child: Column(
          children: [
            detail('Client', widget.visit.company, icon: Icons.business),
            detail(
              'Calculated Duration',
              widget.visit.duration,
              icon: Icons.schedule,
            ),
            detail(
              'Check-In Mode',
              '${widget.visit.checkInMode.toUpperCase()} · Verified',
              icon: Icons.location_on_outlined,
            ),
            detail(
              'Artifacts',
              '${CrmStore.instance.notesFor(widget.visit.company).length} Notes · ${widget.visit.signature.isNotEmpty ? "Signature Collected ✓" : "No Signature"}',
              icon: Icons.attachment,
            ),
          ],
        ),
      ),
      gap(14),

      heading('Visit Outcome *'),
      for (final o in [
        'Positive — Deal progressing',
        'Neutral — Follow-up needed',
        'Negative — No interest',
        'Rescheduled',
      ])
        RadioListTile<String>(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text(
            o,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          value: o,
          groupValue: outcome,
          onChanged: (v) => setState(() => outcome = v!),
        ),
      gap(10),

      DropdownButtonFormField<String>(
        value: nextSteps,
        decoration: const InputDecoration(labelText: 'Next Action Step'),
        items: nextStepsOptions
            .map(
              (s) => DropdownMenuItem(
                value: s,
                child: Text(s, style: const TextStyle(fontSize: 12)),
              ),
            )
            .toList(),
        onChanged: (v) => setState(() => nextSteps = v!),
      ),
      gap(14),

      // Summary Note with AI Generation Sparkle Button
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Summary Note *',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          TextButton.icon(
            onPressed: _autoGenerateSummaryWithAi,
            icon: const Icon(
              Icons.auto_awesome,
              size: 14,
              color: AppColors.primary,
            ),
            label: const Text(
              'AI Auto-Generate',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      TextField(
        controller: note,
        maxLines: 4,
        decoration: const InputDecoration(
          hintText:
              'Record meeting highlights, discussed terms, client feedback...',
        ),
      ),
      gap(20),

      if (widget.visit.status != 'Completed')
        button('Complete & Check Out', () async {
          if (note.text.trim().isEmpty) {
            message(c, 'Please provide or generate a summary before checkout');
            return;
          }
          try {
            await CrmStore.instance.finishActiveVisit(
              widget.visit,
              outcome: outcome,
              summary: note.text.trim(),
              nextSteps: nextSteps,
              followUpDate: followUpDate,
            );
            if (c.mounted) {
              Navigator.pushNamedAndRemoveUntil(c, '/visits', (r) => false);
              message(c, 'Visit checked out & logged to activity history!');
            }
          } catch (e) {
            if (c.mounted) {
              ScaffoldMessenger.of(c).showSnackBar(
                SnackBar(
                  content: Text('Failed to check out visit: $e'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          }
        })
      else ...[
        Panel(child: detail('Logged Outcome', widget.visit.outcome)),
        gap(10),
      ],
      button(
        'Schedule Follow-up Visit',
        () => open(c, '/schedule-visit'),
        secondary: true,
      ),
    ],
  );
}

/// Nearby Leads & Map Screen
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
              '✦ AI Smart Route\n\nReview and reorder stops to plan your day. Live turn-by-turn routing uses native device maps.',
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
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () => open(c, '/lead-details', a),
                  tooltip: 'Lead details',
                ),
              ],
            ),
          ),
        if (widget.routeMode)
          button("View Today's Route", () => open(c, '/todays-route')),
      ],
    );
  }
}

/// Static map artwork representation
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
                    'South Mumbai Route Map · Static Reference View',
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
