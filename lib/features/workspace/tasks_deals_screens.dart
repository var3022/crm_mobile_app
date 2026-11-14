import 'dart:async';
import 'package:flutter/material.dart';
import 'crm_store.dart';
import 'crm_ui.dart';
import 'crm_services.dart';

/// Page 70: Tasks list with filter tabs
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key, this.empty = false});
  final bool empty;
  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  String filter = 'All';

  @override
  Widget build(BuildContext c) => ListenableBuilder(
    listenable: CrmStore.instance,
    builder: (c, _) {
      final tasks = widget.empty
          ? <CrmTask>[]
          : CrmStore.instance.tasks
                .where(
                  (t) => filter == 'Completed'
                      ? t.completed
                      : !t.completed &&
                            (filter != 'Overdue' || t.overdue) &&
                            (filter != 'Today' ||
                                DateUtils.isSameDay(t.due, DateTime.now())) &&
                            (filter != 'This Week' ||
                                t.due.isBefore(
                                  DateTime.now().add(const Duration(days: 7)),
                                )),
                )
                .toList();

      return CrmPage(
        title: 'My Tasks',
        nav: 3,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle),
            tooltip: 'Create task',
            onPressed: () => open(c, '/new-task'),
          ),
        ],
        fab: FloatingActionButton.small(
          onPressed: () => open(c, '/new-task'),
          child: const Icon(Icons.add),
        ),
        children: [
          chips(
            ['All', 'Overdue', 'Today', 'This Week', 'Completed'],
            filter,
            (v) => setState(() => filter = v),
          ),
          gap(12),
          if (tasks.isEmpty)
            emptyState(
              c,
              'No Tasks Yet',
              'Tasks assigned to you will appear here. Start by creating your first task or check with your manager.',
              Icons.assignment_outlined,
              '+ Create New Task',
              () => open(c, '/new-task'),
            ),
          for (final t in tasks)
            Panel(
              color: Colors.white,
              onTap: () => open(c, '/task-details', t),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: t.completed,
                    onChanged: (v) => CrmStore.instance.update(() {
                      t.completed = v!;
                      if (v) {
                        t.status = 'Completed';
                      }
                    }),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        strong(t.title, 14),
                        gap(4),
                        Text(
                          t.overdue && !t.completed
                              ? 'Overdue · ${dateText(t.due)}'
                              : '${dateText(t.due)} · ${t.completed ? "Completed" : "2:30 PM"}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: t.overdue && !t.completed
                                ? AppColors.error
                                : AppColors.textSecondary,
                          ),
                        ),
                        gap(6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            badge(t.source),
                            muted(t.company),
                            if (t.priority == 'High')
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'HIGH PRIORITY',
                                  style: TextStyle(
                                    color: Colors.red.shade800,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 3,
                    height: 55,
                    color: t.overdue && !t.completed
                        ? AppColors.error
                        : AppColors.primary,
                  ),
                ],
              ),
            ),
        ],
      );
    },
  );
}

String dateText(DateTime date) =>
    '${['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][date.month - 1]} ${date.day}, ${date.year}';

/// Pages 71 & 73: Task Form with Reminder Toggle and Type Dropdown
Widget taskForm(CrmTask? task) => CrmForm(
  title: task == null ? 'New Task' : 'Edit Task',
  submit: task == null ? 'Create Task' : 'Save Changes',
  fields: [
    FormFieldSpec('Task Title', value: task?.title ?? '', required: true),
    FormFieldSpec('Description', value: task?.description ?? '', lines: 3),
    FormFieldSpec(
      'Due Date',
      value: task == null
          ? DateTime.now()
                .add(const Duration(hours: 4))
                .toIso8601String()
                .split('T')
                .first
          : '${task.due.year}-${task.due.month.toString().padLeft(2, '0')}-${task.due.day.toString().padLeft(2, '0')}',
      kind: 'date',
      required: true,
    ),
    FormFieldSpec(
      'Priority',
      value: task?.priority ?? 'High',
      options: const ['Low', 'Medium', 'High'],
    ),
    FormFieldSpec(
      'Assign To',
      value: task?.assignee ?? 'Arjun Mehta',
      required: true,
      options: const [
        'Arjun Mehta',
        'John Smith',
        'Priya Sharma',
        'Rahul Patel',
      ],
    ),
    FormFieldSpec(
      'Related Lead',
      value: task?.company ?? 'Acme Corp',
      options: {
        'Acme Corp',
        ...CrmStore.instance.leads.map((a) => a.company),
        ...CrmStore.instance.customers.map((a) => a.company),
      }.toList(),
    ),
    FormFieldSpec(
      'Task Type',
      value: task?.type ?? 'Follow-up',
      options: const [
        'Follow-up',
        'Call',
        'Visit',
        'Email',
        'Proposal Review',
        'Contract NDA',
      ],
    ),
  ],
  onSave: (c, v) async {
    try {
      await CrmStore.instance.update(() {
        final t = task ?? CrmTask(v['Task Title']!, v['Related Lead']!);
        t.title = v['Task Title']!;
        t.description = v['Description']!;
        t.company = v['Related Lead']!;
        t.priority = v['Priority']!;
        t.assignee = v['Assign To']!;
        t.type = v['Task Type']!;
        t.due = DateTime.parse(v['Due Date']!);
        t.overdue = t.due.isBefore(DateUtils.dateOnly(DateTime.now()));
        if (task == null) CrmStore.instance.tasks.add(t);
      });
      if (c.mounted) {
        Navigator.pop(c);
        message(c, 'Task saved successfully');
      }
    } catch (e) {
      if (c.mounted) {
        ScaffoldMessenger.of(c).showSnackBar(
          SnackBar(
            content: Text('Failed to save task: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  },
);

/// Page 72: Task Details Screen with quick handoffs and completion state
class TaskDetailsScreen extends StatelessWidget {
  const TaskDetailsScreen({super.key, required this.task});
  final CrmTask task;

  @override
  Widget build(BuildContext c) => ListenableBuilder(
    listenable: CrmStore.instance,
    builder: (c, _) => CrmPage(
      title: 'Task Details',
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          tooltip: 'Edit task',
          onPressed: () => open(c, '/edit-task', task),
        ),
      ],
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: badge(
            task.completed
                ? 'COMPLETED'
                : task.overdue
                ? 'OVERDUE'
                : 'ACTIVE',
            color: task.overdue && !task.completed
                ? AppColors.error
                : AppColors.success,
          ),
        ),
        gap(14),
        strong(task.title, 22),
        gap(12),

        Panel(
          child: Column(
            children: [
              detail('Assigned To', task.assignee, icon: Icons.person_outline),
              detail(
                'Due Date',
                dateText(task.due),
                icon: Icons.calendar_today_outlined,
              ),
              detail('Related Client', task.company, icon: Icons.business),
              detail('Priority', task.priority, icon: Icons.flag_outlined),
              detail('Task Type', task.type, icon: Icons.category_outlined),
            ],
          ),
        ),
        gap(14),

        // Related Lead Quick Actions (Call, WhatsApp, Email, Directions)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _taskAction(
              Icons.call,
              'Call Client',
              () => DeviceService.callPhone('+919876543210'),
            ),
            _taskAction(
              Icons.chat_bubble_outline,
              'WhatsApp',
              () => DeviceService.sendWhatsApp(
                '+919876543210',
                'Task update: ${task.title}',
              ),
            ),
            _taskAction(
              Icons.email_outlined,
              'Email',
              () => DeviceService.sendEmail(
                'info@${task.company.toLowerCase().replaceAll(" ", "")}.com',
                task.title,
              ),
            ),
          ],
        ),
        gap(16),

        heading('Description'),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            task.description.isEmpty
                ? "Visit ${task.company}'s office to present the newly updated enterprise proposal. Carry physical brochures and collect signatures on standard NDA template."
                : task.description,
            style: const TextStyle(fontSize: 13, height: 1.5),
          ),
        ),
        gap(16),

        heading('Task Sub-Checklist'),
        Panel(
          child: Column(
            children: [
              for (int i = 0; i < task.checklist.length; i++)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(
                    task.checklistLabels.length > i
                        ? task.checklistLabels[i]
                        : 'Subtask #${i + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      decoration: task.checklist[i]
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  value: task.checklist[i],
                  onChanged: (v) => CrmStore.instance.update(
                    () => task.checklist[i] = v ?? false,
                  ),
                ),
            ],
          ),
        ),
        gap(20),

        if (!task.completed)
          button('Mark as Complete', () {
            CrmStore.instance.update(() {
              task.completed = true;
              task.status = 'Completed';
            });
            open(c, '/task-completed', task);
          }),
        if (!task.completed)
          button('Snooze Task', () async {
            final d = await showDatePicker(
              context: c,
              initialDate: DateTime.now().add(const Duration(days: 1)),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (d != null) {
              CrmStore.instance.update(() {
                task.due = d;
                task.overdue = false;
              });
              if (c.mounted) message(c, 'Task snoozed until ${dateText(d)}');
            }
          }, secondary: true),
        TextButton(
          onPressed: () async {
            if (await confirm(
              c,
              'Delete Task?',
              'This task will be removed from your task list.',
            )) {
              try {
                await CrmStore.instance.deleteTask(task.id);
                if (c.mounted) Navigator.pop(c);
              } catch (e) {
                if (c.mounted) {
                  ScaffoldMessenger.of(c).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete task: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            }
          },
          child: const Text(
            'Delete Task',
            style: TextStyle(color: AppColors.error),
          ),
        ),
      ],
    ),
  );

  Widget _taskAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
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
}

/// Page 74: Completion Celebration Screen
class CompletionScreen extends StatelessWidget {
  const CompletionScreen({
    super.key,
    required this.title,
    required this.subtitle,
    this.route = '/tasks',
    this.action = 'Back to Tasks',
  });
  final String title, subtitle, route, action;

  @override
  Widget build(BuildContext c) => CrmPage(
    title: '',
    nav: route == '/tasks' ? 3 : 0,
    children: [
      gap(60),
      const Center(
        child: CircleAvatar(
          radius: 54,
          backgroundColor: Color(0xFFD1FAE5),
          child: CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.success,
            child: Icon(Icons.check, size: 40, color: Colors.white),
          ),
        ),
      ),
      gap(24),
      Center(child: strong(title, 22)),
      gap(8),
      Center(child: muted(subtitle)),
      gap(24),
      Panel(
        child: Center(
          child: muted(
            '${CrmStore.instance.tasks.where((t) => t.completed).length} of ${CrmStore.instance.tasks.length} tasks completed',
          ),
        ),
      ),
      gap(20),
      button(
        action,
        () => Navigator.pushNamedAndRemoveUntil(c, route, (r) => false),
      ),
      button('Go to Dashboard', () => tab(c, 0), secondary: true),
    ],
  );
}

/// Page 47: Pipeline Screen with Kanban and List Views
class PipelineScreen extends StatefulWidget {
  const PipelineScreen({super.key, this.empty = false});
  final bool empty;
  @override
  State<PipelineScreen> createState() => _PipelineScreenState();
}

class _PipelineScreenState extends State<PipelineScreen> {
  bool board = true;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: CrmStore.instance,
    builder: (context, _) {
      final deals = widget.empty ? <Deal>[] : CrmStore.instance.deals;
      final totalValue = deals.fold<double>(0, (sum, d) => sum + d.value);

      return CrmPage(
        title: 'Sales Pipeline',
        nav: 1,
        actions: [
          IconButton(
            icon: Icon(
              board ? Icons.view_list_outlined : Icons.view_kanban_outlined,
            ),
            tooltip: 'Toggle layout',
            onPressed: () => setState(() => board = !board),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New deal',
            onPressed: () => open(context, '/new-deal'),
          ),
        ],
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Pipeline Value',
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '\$${totalValue.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${deals.length} Active Deals',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          gap(14),

          if (deals.isEmpty)
            emptyState(
              context,
              'No Deals Yet',
              'Create your first deal from a lead to start tracking your sales pipeline.',
              Icons.handshake_outlined,
              'Go to Leads',
              () => tab(context, 1),
            ),

          if (board && deals.isNotEmpty)
            SizedBox(
              height: 520,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final stage in [
                    'Qualified',
                    'Discovery',
                    'Proposal',
                    'Negotiation',
                    'Won',
                    'Lost',
                  ])
                    SizedBox(
                      width: 250,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: DragTarget<Deal>(
                          onAcceptWithDetails: (details) => CrmStore.instance
                              .update(() => details.data.stage = stage),
                          builder: (context, candidates, rejected) => Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: candidates.isEmpty
                                  ? AppColors.surfaceSecondary
                                  : AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(child: strong(stage, 13)),
                                    badge(
                                      '${deals.where((d) => d.stage == stage).length}',
                                    ),
                                  ],
                                ),
                                gap(12),
                                Expanded(
                                  child: ListView(
                                    children: [
                                      for (final deal in deals.where(
                                        (d) => d.stage == stage,
                                      ))
                                        LongPressDraggable<Deal>(
                                          data: deal,
                                          feedback: Material(
                                            child: SizedBox(
                                              width: 230,
                                              child: dealCard(context, deal),
                                            ),
                                          ),
                                          childWhenDragging: Opacity(
                                            opacity: 0.4,
                                            child: dealCard(context, deal),
                                          ),
                                          child: dealCard(context, deal),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          if (!board) ...deals.map((d) => dealCard(context, d)),
        ],
      );
    },
  );

  Widget dealCard(BuildContext context, Deal deal) => Panel(
    color: Colors.white,
    onTap: () => open(context, '/deal-details', deal),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        strong(deal.title, 13),
        gap(4),
        muted(deal.company),
        gap(10),
        Row(
          children: [
            Expanded(child: strong('\$${deal.value.toStringAsFixed(0)}', 15)),
            Text(
              '${deal.probability}% win',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        gap(6),
        badge(deal.stage),
      ],
    ),
  );
}

/// Pages 48 & 50: Deal Form with Stage Stepper & AI Probability
Widget dealForm(Deal? deal, [Account? account]) => CrmForm(
  title: deal == null ? 'New Deal' : 'Update Deal',
  submit: deal == null ? 'Create Deal' : 'Save Changes',
  fields: [
    FormFieldSpec('Deal Name', value: deal?.title ?? '', required: true),
    FormFieldSpec(
      'Associated Lead / Customer',
      value: deal?.company ?? account?.company ?? 'Acme Corp',
      required: true,
      options: {
        'Acme Corp',
        ...CrmStore.instance.leads.map((a) => a.company),
        ...CrmStore.instance.customers.map((a) => a.company),
        if (deal != null) deal.company,
      }.toList(),
    ),
    FormFieldSpec('Contact Person', value: account?.contact ?? 'John Doe'),
    FormFieldSpec(
      'Deal Value (\$)',
      value: deal?.value.toStringAsFixed(0) ?? '75000',
      required: true,
      kind: 'number',
    ),
    FormFieldSpec(
      'Expected Close Date',
      value:
          deal?.closeDate?.toIso8601String().split('T').first ??
          DateTime.now()
              .add(const Duration(days: 30))
              .toIso8601String()
              .split('T')
              .first,
      required: true,
      kind: 'date',
    ),
    FormFieldSpec(
      'Deal Stage',
      value: deal?.stage ?? 'Qualified',
      options: const [
        'Qualified',
        'Discovery',
        'Proposal',
        'Negotiation',
        'Won',
        'Lost',
      ],
    ),
    FormFieldSpec(
      'Win Probability (%)',
      value: deal?.probability ?? '75',
      kind: 'number',
    ),
    FormFieldSpec('Products / Services', value: deal?.products ?? '', lines: 2),
    FormFieldSpec(
      'Next Action',
      value: deal?.nextAction ?? 'Send Proposal',
      options: const [
        'Send Proposal',
        'Schedule Follow-up Visit',
        'Technical Review',
        'Contract Sign',
      ],
    ),
    FormFieldSpec('Notes', value: deal?.notes ?? '', lines: 3),
  ],
  onSave: (c, v) async {
    final d =
        deal ??
        Deal(v['Deal Name']!, v['Associated Lead / Customer']!, 0, 'Qualified');
    try {
      await CrmStore.instance.update(() {
        d.title = v['Deal Name']!;
        d.company = v['Associated Lead / Customer']!;
        d.value = double.parse(
          v['Deal Value (\$)']!.replaceAll(RegExp(r'[^0-9.]'), ''),
        );
        d.stage = v['Deal Stage']!;
        d.closeDate = DateTime.parse(v['Expected Close Date']!);
        d.probability = v['Win Probability (%)']!;
        d.products = v['Products / Services']!;
        d.nextAction = v['Next Action'] ?? 'Send Proposal';
        d.notes = v['Notes']!;
        if (deal == null) CrmStore.instance.deals.add(d);
      });
      if (c.mounted) {
        Navigator.pop(c);
        if (d.stage == 'Won' || d.stage == 'Lost') {
          open(c, d.stage == 'Won' ? '/deal-won' : '/deal-lost', d);
        } else {
          message(c, 'Deal saved');
        }
      }
    } catch (e) {
      if (c.mounted) {
        ScaffoldMessenger.of(c).showSnackBar(
          SnackBar(
            content: Text('Failed to save deal: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  },
);

/// Page 49: Deal Details Screen with Stepper and Properties
class DealDetailsScreen extends StatefulWidget {
  const DealDetailsScreen({super.key, required this.deal});
  final Deal deal;
  @override
  State<DealDetailsScreen> createState() => _DealDetailsScreenState();
}

class _DealDetailsScreenState extends State<DealDetailsScreen> {
  String selected = 'Details';

  @override
  Widget build(BuildContext c) => ListenableBuilder(
    listenable: CrmStore.instance,
    builder: (c, _) => CrmPage(
      title: 'Deal Details',
      nav: 1,
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          tooltip: 'Update deal',
          onPressed: () => open(c, '/update-deal', widget.deal),
        ),
      ],
      children: [
        muted(widget.deal.company),
        strong(widget.deal.title, 22),
        gap(10),
        Row(
          children: [
            Expanded(
              child: strong('\$${widget.deal.value.toStringAsFixed(0)}', 26),
            ),
            badge(widget.deal.stage),
          ],
        ),
        gap(16),

        Panel(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  muted('PROBABILITY'),
                  strong('${widget.deal.probability}%', 14),
                ],
              ),
              Column(
                children: [
                  muted('EXPECTED CLOSE'),
                  strong(
                    widget.deal.closeDate == null
                        ? 'Not set'
                        : dateText(widget.deal.closeDate!),
                    12,
                  ),
                ],
              ),
              Column(children: [muted('OWNER'), strong(widget.deal.owner, 14)]),
            ],
          ),
        ),
        chips(
          ['Details', 'Activity', 'Notes'],
          selected,
          (s) => setState(() => selected = s),
        ),
        gap(12),

        if (selected == 'Details') ...[
          Panel(
            child: Column(
              children: [
                detail(
                  'Primary Contact',
                  widget.deal.decisionMakers.isNotEmpty
                      ? widget.deal.decisionMakers
                      : 'Sarah Johnson (VP)',
                ),
                detail('Company', widget.deal.company),
                detail('Next Action', widget.deal.nextAction),
                detail(
                  'Products / Services',
                  widget.deal.products.isNotEmpty
                      ? widget.deal.products
                      : 'Enterprise SaaS Suite, Cloud Storage',
                ),
                detail(
                  'Competitors',
                  widget.deal.competitors.isNotEmpty
                      ? widget.deal.competitors
                      : 'SalesSphere, LeadPulse',
                ),
              ],
            ),
          ),
          button('Update Deal', () => open(c, '/update-deal', widget.deal)),
          button(
            'Schedule Follow-up Visit',
            () => open(c, '/schedule-visit'),
            secondary: true,
          ),
        ] else if (selected == 'Activity') ...[
          Panel(
            child: detail(
              'Deal Stage: ${widget.deal.stage}',
              '${widget.deal.company} · \$${widget.deal.value.toStringAsFixed(0)}',
              icon: Icons.trending_up,
            ),
          ),
        ] else ...[
          for (final n in CrmStore.instance.notesFor(widget.deal.company))
            Panel(child: muted(n)),
          button('Add Note', () => open(c, '/add-note', widget.deal)),
        ],
        TextButton(
          onPressed: () async {
            if (await confirm(
              c,
              'Delete Deal?',
              'This deal will be permanently removed.',
            )) {
              try {
                await CrmStore.instance.deleteDeal(widget.deal.id);
                if (c.mounted) Navigator.pop(c);
              } catch (e) {
                if (c.mounted) {
                  ScaffoldMessenger.of(c).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete deal: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            }
          },
          child: const Text(
            'Delete Deal',
            style: TextStyle(color: AppColors.error),
          ),
        ),
      ],
    ),
  );
}

/// Pages 51 & 52: Deal Won and Deal Lost Celebration/Resolution Screens
class DealResultScreen extends StatelessWidget {
  const DealResultScreen({super.key, required this.deal, required this.won});
  final Deal deal;
  final bool won;

  @override
  Widget build(BuildContext c) => CrmPage(
    title: won ? 'Deal Won' : 'Deal Closed',
    children: [
      gap(35),
      Center(
        child: CircleAvatar(
          radius: 48,
          backgroundColor: won ? AppColors.primaryLight : Colors.red.shade50,
          child: Icon(
            won ? Icons.emoji_events_outlined : Icons.trending_down,
            size: 44,
            color: won ? AppColors.primary : AppColors.error,
          ),
        ),
      ),
      gap(18),
      Center(
        child: strong(
          won ? 'Deal Closed as Won! 🎉' : 'Deal Closed as Lost',
          22,
        ),
      ),
      gap(8),
      Center(
        child: muted(
          won
              ? 'Congratulations! Another milestone deal unlocked.'
              : 'Let\'s analyze the lost deal context to improve conversion on future deals.',
        ),
      ),
      gap(24),

      Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            muted(deal.title.toUpperCase()),
            strong('\$${deal.value.toStringAsFixed(0)}', 28),
            detail('Client', deal.company),
            detail('Outcome Status', won ? 'Closed Won ✓' : 'Closed Lost ✕'),
          ],
        ),
      ),
      gap(14),

      if (!won)
        CrmFormInlineNote(
          onSaved: (v) async {
            try {
              await CrmStore.instance.addNote(
                deal.company,
                'Lost deal reason (${deal.title}): $v',
              );
              if (c.mounted) message(c, 'Reason for loss saved');
            } catch (e) {
              if (c.mounted) {
                ScaffoldMessenger.of(c).showSnackBar(
                  SnackBar(
                    content: Text('Failed to save reason: $e'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            }
          },
        ),
      button(
        won ? 'Schedule Kickoff Meeting' : 'Log Follow-up Reminder',
        () => open(c, won ? '/schedule-visit' : '/new-task', won ? deal : null),
      ),
      button('Back to Pipeline', () => open(c, '/pipeline'), secondary: true),
    ],
  );
}

class CrmFormInlineNote extends StatefulWidget {
  const CrmFormInlineNote({super.key, required this.onSaved});
  final FutureOr<void> Function(String) onSaved;
  @override
  State<CrmFormInlineNote> createState() => _CrmFormInlineNoteState();
}

class _CrmFormInlineNoteState extends State<CrmFormInlineNote> {
  final controller = TextEditingController();
  String selectedReason = 'Price too high';
  final lossReasons = const [
    'Price too high',
    'Competitor chosen',
    'Budget cut / deferred',
    'Missing required feature',
    'Other',
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Reason for Loss',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
      gap(6),
      DropdownButtonFormField<String>(
        value: selectedReason,
        decoration: const InputDecoration(labelText: 'Primary Factor'),
        items: lossReasons
            .map((r) => DropdownMenuItem(value: r, child: Text(r)))
            .toList(),
        onChanged: (v) => setState(() => selectedReason = v!),
      ),
      gap(10),
      TextField(
        controller: controller,
        maxLines: 3,
        decoration: const InputDecoration(
          labelText: 'Debrief Notes',
          hintText: 'What could we have done differently?',
        ),
      ),
      TextButton.icon(
        onPressed: () async =>
            await widget.onSaved('$selectedReason - ${controller.text}'),
        icon: const Icon(Icons.save, size: 16),
        label: const Text('Save Reason'),
      ),
    ],
  );
}
