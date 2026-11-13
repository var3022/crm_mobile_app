import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'crm_store.dart';
import 'crm_ui.dart';
import '../leads/widgets/lead_card.dart';
import '../leads/models/lead_model.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key, this.customers = false, this.empty = false});
  final bool customers, empty;
  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  String filter = 'All', search = '', sort = 'AI Score';
  bool searching = false;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: CrmStore.instance,
    builder: (context, _) {
      final store = CrmStore.instance;
      final source = widget.empty
          ? <Account>[]
          : widget.customers
          ? store.customers
          : store.leads;
      final items = source
          .where(
            (a) =>
                (filter == 'All' ||
                    a.stage == filter ||
                    (filter == 'Hot' && a.score > 80) ||
                    (filter == 'Active' && a.stage == 'Healthy') ||
                    (filter == 'High Value' && a.score > 80)) &&
                '${a.company} ${a.contact} ${a.area}'.toLowerCase().contains(
                  search.toLowerCase(),
                ),
          )
          .toList();
      items.sort(
        (a, b) => sort == 'Name'
            ? a.company.compareTo(b.company)
            : sort == 'Distance'
            ? a.distance.compareTo(b.distance)
            : b.score.compareTo(a.score),
      );
      return CrmPage(
        title: widget.customers ? 'Customers' : 'Leads',
        nav: 1,
        actions: [
          actionIcon(
            Icons.search,
            () => setState(() => searching = !searching),
            tooltip: 'Search',
          ),
          actionIcon(
            widget.customers ? Icons.swap_horiz : Icons.add_circle,
            () => open(context, widget.customers ? '/pipeline' : '/new-lead'),
            tooltip: widget.customers ? 'Sales pipeline' : 'Add lead',
          ),
          PopupMenuButton<String>(
            onSelected: (s) => open(context, s),
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: '/customers',
                child: Text('Customers'),
              ),
              const PopupMenuItem(
                value: '/pipeline',
                child: Text('Sales Pipeline'),
              ),
              const PopupMenuItem(
                value: '/nearby-leads',
                child: Text('Nearby Leads'),
              ),
            ],
          ),
        ],
        children: [
          if (searching) ...[
            TextField(
              autofocus: true,
              onChanged: (s) => setState(() => search = s),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search company, contact or location',
              ),
            ),
            gap(8),
          ],
          chips(
            widget.customers
                ? ['All', 'Active', 'Inactive', 'High Value']
                : ['All', 'New', 'Contacted', 'Qualified', 'Hot'],
            filter,
            (s) => setState(() => filter = s),
          ),
          Row(
            children: [
              Expanded(
                child: muted(
                  '${items.length} ${widget.customers ? 'customers' : 'leads'}',
                ),
              ),
              DropdownButton<String>(
                value: sort,
                underline: const SizedBox(),
                style: const TextStyle(fontSize: 11, color: AppColors.primary),
                items: ['AI Score', 'Name', 'Distance']
                    .map(
                      (v) =>
                          DropdownMenuItem(value: v, child: Text('Sort: $v')),
                    )
                    .toList(),
                onChanged: (v) => setState(() => sort = v!),
              ),
              actionIcon(
                Icons.tune,
                () => open(context, '/filter-leads'),
                tooltip: 'Filter leads',
              ),
            ],
          ),
          if (items.isEmpty)
            emptyState(
              context,
              search.isNotEmpty
                  ? 'No Results Found'
                  : widget.customers
                  ? 'No Customers Yet'
                  : 'No Leads Yet',
              search.isNotEmpty
                  ? 'Try adjusting your search or filters.'
                  : widget.customers
                  ? 'Customers are created when you convert qualified leads. Start by adding your first lead.'
                  : 'Your assigned leads will appear here. You can also add leads manually or scan visiting cards.',
              Icons.people_outline,
              search.isNotEmpty
                  ? 'Clear Filters'
                  : widget.customers
                  ? 'View Leads'
                  : '+ Add New Lead',
              () {
                if (search.isNotEmpty) {
                  setState(() {
                    search = '';
                    filter = 'All';
                  });
                } else {
                  open(context, widget.customers ? '/leads' : '/new-lead');
                }
              },
            ),
          for (final a in items)
            if (!widget.customers)
              LeadCard(
                lead: LeadModel(
                  id: '${identityHashCode(a)}',
                  companyName: a.company,
                  contactName: a.contact,
                  contactRole: a.role,
                  distanceKm: a.distance,
                  locationArea: a.area,
                  lastActive: '2 hours ago',
                  aiScore: a.score,
                  stage: LeadStage.values.firstWhere(
                    (s) => s.name.toLowerCase() == a.stage.toLowerCase(),
                    orElse: () => LeadStage.newLead,
                  ),
                  temperature: a.score > 80
                      ? LeadTemperature.hot
                      : a.score >= 50
                      ? LeadTemperature.warm
                      : LeadTemperature.cold,
                  isFlagged: a.flagged,
                  phoneNumber: a.phone,
                  email: a.email,
                  hasSwipeActionTip: items.first == a,
                ),
                onTap: () => open(context, '/lead-details', a),
                onCall: () => open(context, '/log-call', a),
                onLogVisit: () => open(context, '/schedule-visit', a),
                onToggleFlag: () => store.update(() => a.flagged = !a.flagged),
              )
            else
              Panel(
                color: Colors.white,
                onTap: () => open(context, '/customer-details', a),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        avatar(a.initials),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              strong(a.company, 14),
                              muted('Technology'),
                              gap(10),
                              muted('Account Value'),
                            ],
                          ),
                        ),
                        badge(
                          a.stage,
                          color: a.stage == 'At Risk'
                              ? AppColors.warning
                              : a.stage == 'Critical'
                              ? AppColors.error
                              : AppColors.success,
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: strong('₹12,50,000', 13),
                    ),
                  ],
                ),
              ),
        ],
      );
    },
  );
}

class AccountDetailsScreen extends StatelessWidget {
  const AccountDetailsScreen({
    super.key,
    required this.account,
    this.customer = false,
  });
  final Account account;
  final bool customer;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: CrmStore.instance,
    builder: (context, _) => CrmPage(
      title: customer ? account.company : 'Lead Details',
      nav: 1,
      actions: [
        actionIcon(
          Icons.edit_outlined,
          () => open(context, '/edit-lead', account),
          tooltip: 'Edit lead',
        ),
        PopupMenuButton<String>(
          onSelected: (v) async {
            if (v == 'delete') {
              if (await confirm(
                context,
                'Delete ${customer ? 'Customer' : 'Lead'}?',
                'This action cannot be undone. All associated notes and details will also be removed.',
              )) {
                CrmStore.instance.update(
                  () =>
                      (customer
                              ? CrmStore.instance.customers
                              : CrmStore.instance.leads)
                          .remove(account),
                );
                if (context.mounted) Navigator.pop(context);
              }
            } else {
              open(context, v, account);
            }
          },
          itemBuilder: (_) => [
            if (!customer)
              const PopupMenuItem(
                value: '/convert-customer',
                child: Text('Convert to Customer'),
              ),
            const PopupMenuItem(
              value: '/activity',
              child: Text('Activity Timeline'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete', style: TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      ],
      children: [
        Panel(
          child: Row(
            children: [
              avatar(account.initials),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    strong(account.company, 20),
                    muted('${account.contact} · ${account.role}'),
                    gap(5),
                    badge(customer ? 'Healthy' : account.stage),
                  ],
                ),
              ),
              if (!customer) avatar('${account.score}'),
            ],
          ),
        ),
        if (customer)
          Panel(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [muted('Account Value'), strong('₹12,50,000', 18)],
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (final e in [
              (Icons.call, 'Call'),
              (Icons.chat_bubble_outline, 'WhatsApp'),
              (Icons.mail_outline, 'Email'),
              (Icons.near_me_outlined, 'Navigate'),
            ])
              Column(
                children: [
                  IconButton.filledTonal(
                    onPressed: () {
                      if (e.$2 == 'Navigate') {
                        open(context, '/nearby-leads');
                      } else if (e.$2 == 'Call') {
                        open(context, '/log-call', account);
                      } else {
                        Clipboard.setData(
                          ClipboardData(
                            text: e.$2 == 'Email'
                                ? account.email
                                : account.phone,
                          ),
                        );
                        message(
                          context,
                          '${e.$2 == 'Email' ? 'Email address' : 'Phone number'} copied. Open your ${e.$2} app to contact ${account.contact}.',
                        );
                      }
                    },
                    icon: Icon(e.$1, size: 20),
                  ),
                  muted(e.$2),
                ],
              ),
          ],
        ),
        gap(),
        if (customer)
          Panel(
            color: AppColors.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '✦ AI Field Insights',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                gap(10),
                const Text(
                  'Contract renews in 45 days. High upsell potential.\n\nEngagement declined 12% this month. Call recommended.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        heading(customer ? 'Contacts' : 'Contact Details'),
        Panel(
          child: Column(
            children: [
              detail('Phone Number', account.phone, icon: Icons.call_outlined),
              detail('Email Address', account.email, icon: Icons.mail_outline),
              detail(
                'Office Address',
                '12th Floor, Maker Chambers, ${account.area}',
                icon: Icons.location_on_outlined,
              ),
            ],
          ),
        ),
        heading(
          customer ? 'Active Deals' : 'Deal Pipeline',
          TextButton(
            onPressed: () => open(context, '/new-deal', account),
            child: const Text('+ New'),
          ),
        ),
        ...CrmStore.instance.deals
            .where((d) => d.company == account.company)
            .map(
              (d) => Panel(
                onTap: () => open(context, '/deal-details', d),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: strong(d.title, 14)),
                        strong('₹${d.value.toStringAsFixed(0)}', 14),
                      ],
                    ),
                    gap(8),
                    muted('${d.stage} · Target Close: Aug 30'),
                  ],
                ),
              ),
            ),
        heading('Visit History'),
        ...CrmStore.instance.visits
            .where((v) => v.company == account.company)
            .map(
              (v) => Panel(
                onTap: () => open(context, '/visit-details', v),
                child: detail(
                  v.time,
                  '${v.type} · ${v.status}',
                  icon: Icons.location_on_outlined,
                ),
              ),
            ),
        if (account.notes.isNotEmpty) Panel(child: muted(account.notes)),
        heading(
          'Notes',
          TextButton(
            onPressed: () => open(context, '/add-note', account),
            child: const Text('+ Add'),
          ),
        ),
        for (final n in CrmStore.instance.notesFor(account.company))
          Panel(child: muted(n)),
        button(
          'Schedule Visit',
          () => open(context, '/schedule-visit', account),
        ),
        button(
          'Activity Timeline',
          () => open(context, '/activity', account),
          secondary: true,
        ),
      ],
    ),
  );
}

Widget accountForm(Account? account) => CrmForm(
  title: account == null ? 'New Lead' : 'Edit Lead',
  submit: account == null ? 'Save Lead' : 'Save Changes',
  fields: [
    FormFieldSpec(
      'First Name',
      value: account?.contact.split(' ').first ?? '',
      required: true,
    ),
    FormFieldSpec(
      'Last Name',
      value: account?.contact.split(' ').skip(1).join(' ') ?? '',
      required: true,
    ),
    FormFieldSpec('Phone Number', value: account?.phone ?? '', required: true),
    FormFieldSpec(
      'Email Address',
      value: account?.email ?? '',
      required: true,
      kind: 'email',
    ),
    FormFieldSpec(
      'Company Name',
      value: account?.company ?? '',
      required: true,
    ),
    FormFieldSpec('Designation', value: account?.role ?? ''),
    FormFieldSpec(
      'Lead Source',
      value: account?.source ?? 'Referral',
      options: [
        'Referral',
        'Website',
        'Cold Call',
        'Social Media',
        'Trade Show',
      ],
    ),
    FormFieldSpec('Address', value: account?.area ?? '', lines: 2),
    FormFieldSpec(
      'Lead Priority',
      value: account?.priority ?? 'High',
      options: ['Low', 'Medium', 'High'],
    ),
    FormFieldSpec(
      'Lead Status',
      value: account?.stage ?? 'New',
      options: ['New', 'Contacted', 'Qualified', 'Proposal', 'Negotiation'],
    ),
    FormFieldSpec('Notes', value: account?.notes ?? '', lines: 3),
  ],
  onSave: (context, v) async {
    final store = CrmStore.instance;
    if (account == null &&
        store.leads.any(
          (a) => a.company.toLowerCase() == v['Company Name']!.toLowerCase(),
        )) {
      final proceed = await confirm(
        context,
        'Possible Duplicate Found',
        'A lead with a similar company name already exists. Create this lead anyway?',
        action: 'Create Anyway',
      );
      if (!proceed) return;
    }
    final a =
        account ??
        Account(v['Company Name']!, '${v['First Name']} ${v['Last Name']}');
    store.update(() {
      a.company = v['Company Name']!;
      a.contact = '${v['First Name']} ${v['Last Name']}';
      a.phone = v['Phone Number']!;
      a.email = v['Email Address']!;
      a.role = v['Designation']!;
      a.area = v['Address']!;
      a.notes = v['Notes']!;
      a.source = v['Lead Source']!;
      a.priority = v['Lead Priority']!;
      a.stage = v['Lead Status']!;
      if (account == null) store.leads.add(a);
    });
    if (context.mounted) {
      Navigator.pop(context);
      message(context, 'Lead saved successfully!');
    }
  },
);
Widget logCallForm(Account a) => CrmForm(
  title: 'Log Call',
  submit: 'Save Call Log',
  fields: [
    FormFieldSpec('Contact', value: '${a.contact} · ${a.company}'),
    const FormFieldSpec(
      'Call Outcome',
      value: 'Connected',
      required: true,
      options: ['Connected', 'No Answer', 'Busy', 'Wrong Number'],
    ),
    const FormFieldSpec(
      'Call Type',
      value: 'Outbound',
      options: ['Inbound', 'Outbound'],
    ),
    const FormFieldSpec('Notes', required: true, lines: 4),
    const FormFieldSpec('Follow-up Date', kind: 'date'),
    const FormFieldSpec(
      'Next Action',
      value: 'Schedule Visit',
      options: ['Schedule Visit', 'Send Proposal', 'Follow-up Call'],
    ),
  ],
  onSave: (c, v) async {
    CrmStore.instance.addNote(
      a.company,
      'Call with ${a.contact}: ${v['Call Outcome']}. ${v['Notes']}',
    );
    Navigator.pop(c);
    message(c, 'Call log saved');
  },
);
Widget convertForm(Account a) => CrmForm(
  title: 'Convert to Customer',
  submit: 'Convert Lead',
  fields: [
    FormFieldSpec('Contact', value: '${a.contact} · ${a.company}'),
    const FormFieldSpec(
      'Customer Type',
      value: 'Enterprise',
      options: ['Enterprise', 'Small Business', 'Individual'],
    ),
    const FormFieldSpec(
      'Account Owner',
      value: 'Arjun Mehta',
      options: ['Arjun Mehta', 'Priya Sharma'],
    ),
    const FormFieldSpec(
      'Assign Territory',
      value: 'South Mumbai',
      options: ['South Mumbai', 'North Mumbai', 'Lower Parel'],
    ),
    const FormFieldSpec('Initial Deal Value', value: '50000', kind: 'number'),
  ],
  onSave: (c, v) async {
    CrmStore.instance.update(() {
      a.stage = 'Healthy';
      a.customerType = v['Customer Type']!;
      a.owner = v['Account Owner']!;
      a.territory = v['Assign Territory']!;
      CrmStore.instance.leads.remove(a);
      CrmStore.instance.customers.add(a);
    });
    Navigator.pop(c);
    Navigator.pushReplacementNamed(c, '/customer-details', arguments: a);
  },
);
Widget noteForm(Account a) => CrmForm(
  title: 'Add Note',
  submit: 'Save Note',
  fields: [
    FormFieldSpec('Account', value: a.company),
    const FormFieldSpec(
      'Category',
      value: 'General',
      options: ['General', 'Meeting', 'Call', 'Follow-up', 'Issue'],
    ),
    const FormFieldSpec('Note Title', required: true),
    const FormFieldSpec('Note', required: true, lines: 5),
  ],
  onSave: (c, v) async {
    CrmStore.instance.addNote(
      v['Account']!,
      '${v['Note Title']}\n${v['Note']}',
    );
    Navigator.pop(c);
    message(c, 'Note saved');
  },
);

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key, required this.account});
  final Account account;
  @override
  Widget build(BuildContext context) => CrmPage(
    title: 'Activity Timeline',
    children: [
      Panel(
        child: Row(
          children: [
            avatar(account.initials),
            const SizedBox(width: 12),
            strong(account.company),
          ],
        ),
      ),
      heading('Today'),
      for (final n in CrmStore.instance.notesFor(account.company))
        Panel(child: detail('Note added', n, icon: Icons.edit_note)),
      heading('Earlier'),
      for (final v in CrmStore.instance.visits.where(
        (v) => v.company == account.company,
      ))
        Panel(
          child: detail(
            'Visited ${v.company}',
            '${v.type} · ${v.status}',
            icon: Icons.location_on_outlined,
          ),
        ),
      for (final d in CrmStore.instance.deals.where(
        (d) => d.company == account.company,
      ))
        Panel(
          child: detail(
            'Deal moved to ${d.stage}',
            d.title,
            icon: Icons.trending_up,
          ),
        ),
    ],
  );
}

class LeadFiltersScreen extends StatefulWidget {
  const LeadFiltersScreen({super.key});
  @override
  State<LeadFiltersScreen> createState() => _LeadFiltersScreenState();
}

class _LeadFiltersScreenState extends State<LeadFiltersScreen> {
  String stage = 'Qualified', priority = 'Hot', source = 'Referral';
  RangeValues range = const RangeValues(0, 100);
  @override
  Widget build(BuildContext c) => CrmPage(
    title: 'Filter Leads',
    actions: [
      TextButton(
        onPressed: () => setState(() {
          stage = 'All';
          priority = 'All';
          source = 'All';
          range = const RangeValues(0, 100);
        }),
        child: const Text('Reset All'),
      ),
    ],
    children: [
      heading('Lead Stage'),
      chips(
        ['All', 'New', 'Contacted', 'Qualified', 'Proposal', 'Negotiation'],
        stage,
        (v) => setState(() => stage = v),
      ),
      heading('Priority'),
      chips(
        ['All', 'Hot', 'Warm', 'Cold'],
        priority,
        (v) => setState(() => priority = v),
      ),
      heading('Source'),
      chips(
        ['All', 'Referral', 'Website', 'Cold Call', 'Social Media'],
        source,
        (v) => setState(() => source = v),
      ),
      heading('AI Score'),
      RangeSlider(
        values: range,
        min: 0,
        max: 100,
        divisions: 20,
        labels: RangeLabels('${range.start.round()}', '${range.end.round()}'),
        onChanged: (v) => setState(() => range = v),
      ),
      gap(24),
      button(
        'Show Results',
        () => Navigator.pushReplacement(
          c,
          MaterialPageRoute(
            builder: (_) => FilteredLeadsScreen(
              stage: stage,
              priority: priority,
              source: source,
              range: range,
            ),
          ),
        ),
      ),
    ],
  );
}

class FilteredLeadsScreen extends StatelessWidget {
  const FilteredLeadsScreen({
    super.key,
    required this.stage,
    required this.priority,
    required this.source,
    required this.range,
  });
  final String stage, priority, source;
  final RangeValues range;
  @override
  Widget build(BuildContext c) {
    final items = CrmStore.instance.leads
        .where(
          (a) =>
              (stage == 'All' || stage == a.stage) &&
              (priority == 'All' ||
                  (priority == 'Hot'
                      ? a.score > 80
                      : priority == 'Warm'
                      ? a.score >= 50 && a.score <= 80
                      : a.score < 50)) &&
              (source == 'All' || a.source == source) &&
              a.score >= range.start &&
              a.score <= range.end,
        )
        .toList();
    return CrmPage(
      title: 'Filtered Leads',
      children: [
        muted('${items.length} results'),
        gap(),
        if (items.isEmpty)
          emptyState(
            c,
            'No Results Found',
            'Try a broader range of filters.',
            Icons.search_off,
            'Edit Filters',
            () => Navigator.pop(c),
          ),
        for (final a in items)
          Panel(
            onTap: () => open(c, '/lead-details', a),
            child: ListTile(
              leading: avatar('${a.score}'),
              title: strong(a.company),
              subtitle: muted(a.contact),
              trailing: badge(a.stage),
            ),
          ),
      ],
    );
  }
}
