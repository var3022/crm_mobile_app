import 'package:flutter/material.dart';
import 'crm_store.dart';
import 'crm_ui.dart';

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
          actionIcon(
            Icons.add_circle,
            () => open(c, '/new-task'),
            tooltip: 'Create task',
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
                    onChanged: (v) =>
                        CrmStore.instance.update(() => t.completed = v!),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        strong(t.title, 14),
                        gap(5),
                        Text(
                          t.overdue && !t.completed
                              ? 'Overdue · ${dateText(t.due)}'
                              : '${dateText(t.due)} · ${t.completed ? 'Completed' : '2:30 PM'}',
                          style: TextStyle(
                            fontSize: 11,
                            color: t.overdue && !t.completed
                                ? AppColors.error
                                : AppColors.textSecondary,
                          ),
                        ),
                        gap(8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [badge(t.source), muted(t.company)],
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
Widget taskForm(CrmTask? task) => CrmForm(
  title: task == null ? 'New Task' : 'Edit Task',
  submit: task == null ? 'Create Task' : 'Save Changes',
  fields: [
    FormFieldSpec('Task Title', value: task?.title ?? '', required: true),
    FormFieldSpec('Description', value: task?.description ?? '', lines: 4),
    FormFieldSpec(
      'Due Date',
      value: task == null
          ? ''
          : '${task.due.year}-${task.due.month.toString().padLeft(2, '0')}-${task.due.day.toString().padLeft(2, '0')}',
      kind: 'date',
      required: true,
    ),
    FormFieldSpec(
      'Priority',
      value: task?.priority ?? 'High',
      options: ['Low', 'Medium', 'High'],
    ),
    FormFieldSpec(
      'Assign To',
      value: task?.assignee ?? 'Arjun Mehta',
      required: true,
      options: ['Arjun Mehta', 'John Smith', 'Priya Sharma'],
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
      options: ['Follow-up', 'Call', 'Visit', 'Email', 'Proposal'],
    ),
  ],
  onSave: (c, v) async {
    CrmStore.instance.update(() {
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
    Navigator.pop(c);
    message(c, 'Task saved');
  },
);

class TaskDetailsScreen extends StatelessWidget {
  const TaskDetailsScreen({super.key, required this.task});
  final CrmTask task;
  @override
  Widget build(BuildContext c) => ListenableBuilder(
    listenable: CrmStore.instance,
    builder: (c, _) => CrmPage(
      title: 'Task Details',
      actions: [
        actionIcon(
          Icons.edit_outlined,
          () => open(c, '/edit-task', task),
          tooltip: 'Edit task',
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
        gap(15),
        strong(task.title, 22),
        gap(),
        Panel(
          child: Column(
            children: [
              detail('Assigned By', 'Rohan Sharma (Manager)'),
              detail('Due Date', dateText(task.due)),
              detail('Related Lead', task.company),
              detail('Source', task.source),
            ],
          ),
        ),
        heading('Description'),
        muted(
          task.description.isEmpty
              ? "Visit ${task.company}'s headquarters to present the newly launched Q3 enterprise product stack. Hand over physical brochures and collect signatures on the standard mutual non-disclosure agreement."
              : task.description,
        ),
        gap(),
        heading('Checklist Items'),
        Panel(
          child: Column(
            children: [
              for (int i = 0; i < 3; i++)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(
                    [
                      'Print physical enterprise catalogs',
                      'Carry physical copy of NDA template',
                      'Obtain client signature on document',
                    ][i],
                    style: const TextStyle(fontSize: 12),
                  ),
                  value: task.checklist[i],
                  onChanged: (v) =>
                      CrmStore.instance.update(() => task.checklist[i] = v!),
                ),
            ],
          ),
        ),
        heading('Activity History'),
        Panel(
          child: Column(
            children: [
              detail(
                'Task Assigned',
                'By Rohan Sharma',
                icon: Icons.assignment_outlined,
              ),
              detail('Due', dateText(task.due), icon: Icons.schedule),
            ],
          ),
        ),
        if (!task.completed)
          button('Mark as Complete', () {
            CrmStore.instance.update(() => task.completed = true);
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
              CrmStore.instance.update(
                () => CrmStore.instance.tasks.remove(task),
              );
              if (c.mounted) Navigator.pop(c);
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
}

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
      gap(75),
      const Center(
        child: CircleAvatar(
          radius: 65,
          backgroundColor: Color(0xFFD1FAE5),
          child: CircleAvatar(
            radius: 44,
            backgroundColor: AppColors.success,
            child: Icon(Icons.check, size: 46, color: Colors.white),
          ),
        ),
      ),
      gap(32),
      Center(child: strong(title, 23)),
      gap(10),
      Center(child: muted(subtitle)),
      gap(28),
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
      return CrmPage(
        title: 'Sales Pipeline',
        nav: 1,
        actions: [
          actionIcon(
            board ? Icons.view_list_outlined : Icons.view_kanban_outlined,
            () => setState(() => board = !board),
            tooltip: 'Toggle layout',
          ),
          actionIcon(
            Icons.add,
            () => open(context, '/new-deal'),
            tooltip: 'New deal',
          ),
        ],
        children: [
          strong(
            'Total Pipeline: ₹${deals.fold<double>(0, (sum, d) => sum + d.value).toStringAsFixed(0)}',
            14,
          ),
          muted('${deals.length} Active Deals'),
          gap(20),
          if (deals.isEmpty)
            emptyState(
              context,
              'No Deals Yet',
              'Create your first deal from a lead to start tracking your pipeline.',
              Icons.handshake_outlined,
              'Go to Leads',
              () => tab(context, 1),
            ),
          if (board && deals.isNotEmpty)
            SizedBox(
              height: 560,
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
                                gap(16),
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
                                            opacity: .4,
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
        gap(12),
        Row(
          children: [
            Expanded(child: strong('₹${deal.value.toStringAsFixed(0)}', 15)),
            avatar('AM', radius: 12),
          ],
        ),
        gap(8),
        badge(deal.stage),
      ],
    ),
  );
}

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
      'Deal Value',
      value: deal?.value.toStringAsFixed(0) ?? '',
      required: true,
      kind: 'number',
    ),
    FormFieldSpec(
      'Expected Close Date',
      value: deal?.closeDate?.toIso8601String().split('T').first ?? '',
      required: true,
      kind: 'date',
    ),
    FormFieldSpec(
      'Deal Stage',
      value: deal?.stage ?? 'Qualified',
      options: [
        'Qualified',
        'Discovery',
        'Proposal',
        'Negotiation',
        'Won',
        'Lost',
      ],
    ),
    FormFieldSpec(
      'Win Probability',
      value: deal?.probability ?? '75',
      kind: 'number',
    ),
    FormFieldSpec('Products / Services', value: deal?.products ?? '', lines: 2),
    FormFieldSpec('Notes', value: deal?.notes ?? '', lines: 4),
  ],
  onSave: (c, v) async {
    final d =
        deal ??
        Deal(v['Deal Name']!, v['Associated Lead / Customer']!, 0, 'Qualified');
    CrmStore.instance.update(() {
      d.title = v['Deal Name']!;
      d.company = v['Associated Lead / Customer']!;
      d.value = double.parse(v['Deal Value']!.replaceAll(',', ''));
      d.stage = v['Deal Stage']!;
      d.closeDate = DateTime.parse(v['Expected Close Date']!);
      d.probability = v['Win Probability']!;
      d.products = v['Products / Services']!;
      d.notes = v['Notes']!;
      if (deal == null) CrmStore.instance.deals.add(d);
    });
    Navigator.pop(c);
    if (d.stage == 'Won' || d.stage == 'Lost')
      open(c, d.stage == 'Won' ? '/deal-won' : '/deal-lost', d);
    else
      message(c, 'Deal saved');
  },
);

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
        actionIcon(
          Icons.edit_outlined,
          () => open(c, '/update-deal', widget.deal),
          tooltip: 'Update deal',
        ),
      ],
      children: [
        muted(widget.deal.company),
        strong(widget.deal.title, 22),
        gap(10),
        Row(
          children: [
            Expanded(
              child: strong('₹${widget.deal.value.toStringAsFixed(0)}', 28),
            ),
            badge(widget.deal.stage),
          ],
        ),
        gap(20),
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
              Column(children: [muted('OWNER'), strong('Alex M.', 14)]),
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
                detail('Primary Contact', 'Sarah Johnson\nVP of Sales'),
                detail('Company', widget.deal.company),
                detail(
                  'Products / Services',
                  widget.deal.products.isEmpty
                      ? 'Enterprise SaaS Suite, Cloud Storage Add-on, Premium Support SLA'
                      : widget.deal.products,
                ),
                detail('Competitors', 'SalesSphere Corp, LeadPulse Systems'),
                detail(
                  'Decision Makers',
                  'Sarah Johnson (VP), Marcus Vance (CIO)',
                ),
              ],
            ),
          ),
          button('Update Deal', () => open(c, '/update-deal', widget.deal)),
          button(
            'Schedule Visit',
            () => open(c, '/schedule-visit'),
            secondary: true,
          ),
        ] else if (selected == 'Activity')
          Panel(
            child: detail(
              'Deal created',
              '${widget.deal.company} · ${widget.deal.stage}',
              icon: Icons.trending_up,
            ),
          )
        else ...[
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
              CrmStore.instance.update(
                () => CrmStore.instance.deals.remove(widget.deal),
              );
              if (c.mounted) Navigator.pop(c);
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
          radius: 45,
          backgroundColor: won
              ? AppColors.primaryLight
              : AppColors.surfaceTertiary,
          child: Icon(
            won ? Icons.emoji_events_outlined : Icons.close,
            size: 40,
            color: AppColors.primary,
          ),
        ),
      ),
      gap(20),
      Center(child: strong(won ? 'Deal Won!' : 'Deal Lost', 24)),
      gap(8),
      Center(
        child: muted(
          won
              ? 'Amazing work! Another milestone unlocked.'
              : "Let's study the context to improve next time.",
        ),
      ),
      gap(25),
      Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            muted(deal.title.toUpperCase()),
            strong('₹${deal.value.toStringAsFixed(0)}', 30),
            detail('Client', deal.company),
            detail('Status', won ? 'Closed Won' : 'Closed Lost'),
          ],
        ),
      ),
      if (!won)
        CrmFormInlineNote(
          onSaved: (v) {
            CrmStore.instance.addNote(
              deal.company,
              'Lost deal ${deal.title}: $v',
            );
            message(c, 'Reason saved');
          },
        ),
      button(
        won ? 'View Deal Summary' : 'Log Follow-up Reminder',
        () => open(c, won ? '/deal-details' : '/new-task', won ? deal : null),
      ),
      button('Back to Dashboard', () => tab(c, 0), secondary: true),
    ],
  );
}

class CrmFormInlineNote extends StatefulWidget {
  const CrmFormInlineNote({super.key, required this.onSaved});
  final ValueChanged<String> onSaved;
  @override
  State<CrmFormInlineNote> createState() => _CrmFormInlineNoteState();
}

class _CrmFormInlineNoteState extends State<CrmFormInlineNote> {
  final controller = TextEditingController();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) => Column(
    children: [
      TextField(
        controller: controller,
        maxLines: 3,
        decoration: const InputDecoration(labelText: 'Reason for loss'),
      ),
      TextButton(
        onPressed: () => widget.onSaved(controller.text),
        child: const Text('Save Reason'),
      ),
    ],
  );
}
