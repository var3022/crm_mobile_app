import 'reporting_ui.dart';
import 'dart:convert';
import 'crm_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'crm_store.dart';
import 'crm_ui.dart';
import 'crm_services.dart';
import '../leads/widgets/lead_card.dart';
import '../leads/models/lead_model.dart';
import 'tasks_deals_screens.dart' show dateText;

/// Pages 27, 28, 41, 42: Accounts Screen (Leads / Customers list)
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
                    (filter == 'Nearby' && a.distance <= 2) ||
                    (filter == 'Followup Due' &&
                        store.tasks.any(
                          (t) =>
                              t.company == a.company &&
                              t.due.isBefore(DateTime.now()) &&
                              !t.completed,
                        )) ||
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
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search Leads',
            onPressed: () => open(context, '/search'),
          ),
          IconButton(
            icon: Icon(widget.customers ? Icons.swap_horiz : Icons.add_circle),
            tooltip: widget.customers ? 'Sales pipeline' : 'Add lead',
            onPressed: () =>
                open(context, widget.customers ? '/pipeline' : '/new-lead'),
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
                : [
                    'All',
                    'New',
                    'Contacted',
                    'Qualified',
                    'Hot',
                    'Followup Due',
                    'Nearby',
                    'Cold',
                  ],
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
              IconButton(
                icon: const Icon(Icons.tune),
                tooltip: 'Filter leads',
                onPressed: () => open(context, '/filter-leads'),
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
                onCall: () => DeviceService.callPhone(a.phone),
                onLogVisit: () => open(context, '/schedule-visit'),
              )
            else
              Panel(
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
                              strong(a.company, 15),
                              muted(a.industry),
                              const SizedBox(height: 4),
                              Text(
                                a.area,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 11,
                                ),
                              ),
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
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Primary Contact: ${a.contact}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '₹${(a.accountValue / 100000).toStringAsFixed(1)}L',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
        ],
      );
    },
  );
}

/// Pages 29 & 30: Dedicated Search Screen with recent searches and live filtering
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final queryController = TextEditingController();
  String query = '';

  @override
  void dispose() {
    queryController.dispose();
    super.dispose();
  }

  void _executeSearch(String term) {
    setState(() {
      query = term;
      queryController.text = term;
    });
    final store = CrmStore.instance;
    if (term.isNotEmpty && !store.recentSearches.contains(term)) {
      store.update(() {
        store.recentSearches.insert(0, term);
        if (store.recentSearches.length > 8) store.recentSearches.removeLast();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CrmStore.instance,
      builder: (context, _) {
        final store = CrmStore.instance;
        final matches = query.isEmpty
            ? <Account>[]
            : [...store.leads, ...store.customers].where((a) {
                final text = '${a.company} ${a.contact} ${a.area} ${a.industry}'
                    .toLowerCase();
                return text.contains(query.toLowerCase());
              }).toList();

        return Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            title: TextField(
              controller: queryController,
              autofocus: true,
              onChanged: (v) => setState(() => query = v),
              decoration: InputDecoration(
                hintText: 'Search companies, contacts, areas...',
                border: InputBorder.none,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          queryController.clear();
                          setState(() => query = '');
                        },
                      )
                    : null,
              ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (query.isEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Searches',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    if (store.recentSearches.isNotEmpty)
                      TextButton(
                        onPressed: () =>
                            store.update(() => store.recentSearches.clear()),
                        child: const Text(
                          'Clear All',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (store.recentSearches.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        'No recent search history',
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                    ),
                  )
                else
                  for (final item in store.recentSearches)
                    ListTile(
                      leading: const Icon(
                        Icons.history,
                        size: 20,
                        color: Colors.grey,
                      ),
                      title: Text(item, style: const TextStyle(fontSize: 13)),
                      trailing: IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () => store.update(
                          () => store.recentSearches.remove(item),
                        ),
                      ),
                      onTap: () => _executeSearch(item),
                      contentPadding: EdgeInsets.zero,
                    ),
              ] else if (matches.isEmpty) ...[
                // Page 30: Empty search results state
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 50,
                    horizontal: 20,
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No Results Found',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'We couldn\'t find any matches for "$query". Try searching for another term or check your spelling.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            OutlinedButton(
                              onPressed: () {
                                queryController.clear();
                                setState(() => query = '');
                              },
                              child: const Text('Clear Search'),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                open(context, '/leads');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Browse All Leads'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                Text(
                  '${matches.length} results for "$query"',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                const SizedBox(height: 12),
                for (final a in matches)
                  Panel(
                    onTap: () {
                      open(
                        context,
                        a.isCustomer ? '/customer-details' : '/lead-details',
                        a,
                      );
                    },
                    child: Row(
                      children: [
                        avatar(a.initials),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                a.company,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '${a.contact} · ${a.role}',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                a.area,
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        badge(a.isCustomer ? 'Customer' : a.stage),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Pages 35, 43: Account Details Screen
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
    builder: (context, _) {
      final store = CrmStore.instance;
      final notes = store.notesFor(account.company);
      final deals = store.deals
          .where(
            (d) => d.company == account.company || d.companyId == account.id,
          )
          .toList();
      // ignore: unused_local_variable
      final visits = store.visits
          .where(
            (v) => v.company == account.company || v.companyId == account.id,
          )
          .toList();

      return CrmPage(
        title: customer ? account.company : 'Lead Details',
        nav: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit lead',
            onPressed: () => open(context, '/edit-lead', account),
          ),
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'delete') {
                if (await confirm(
                  context,
                  'Delete ${customer ? 'Customer' : 'Lead'}?',
                  'This action cannot be undone. All associated notes and details will also be removed.',
                )) {
                  try {
                    await store.update(
                      () => (customer ? store.customers : store.leads).remove(
                        account,
                      ),
                    );
                    if (context.mounted) Navigator.pop(context);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to delete: $e'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  }
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
                children: [
                  muted('Account Value'),
                  strong(
                    '₹${(account.accountValue / 100000).toStringAsFixed(1)} Lakhs',
                    18,
                  ),
                ],
              ),
            ),

          // Quick Action Handoffs
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _actionButton(
                Icons.call,
                'Call',
                () => open(context, '/log-call', account),
              ),
              _actionButton(
                Icons.chat_bubble_outline,
                'WhatsApp',
                () => DeviceService.sendWhatsApp(
                  account.phone,
                  'Hello ${account.contact}',
                ),
              ),
              _actionButton(
                Icons.mail_outline,
                'Email',
                () => DeviceService.sendEmail(
                  account.email,
                  'Following up from CRM',
                ),
              ),
              _actionButton(
                Icons.near_me_outlined,
                'Navigate',
                () => DeviceService.getDirections(account.area),
              ),
            ],
          ),
          gap(14),

          // AI Field Insights Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.9)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.amber, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'AI Field Insights',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${account.company} has an AI engagement score of ${account.score}/100. High probability of contract conversion if SLA terms are submitted within 48 hours.',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          gap(14),

          // Property Details
          Panel(
            child: Column(
              children: [
                detail('Phone', account.phone, icon: Icons.phone_outlined),
                detail('Email', account.email, icon: Icons.email_outlined),
                detail('Industry', account.industry, icon: Icons.business),
                detail(
                  'Company Size',
                  account.companySize,
                  icon: Icons.people_outline,
                ),
                detail(
                  'Territory',
                  account.territory,
                  icon: Icons.map_outlined,
                ),
                detail(
                  'Location',
                  account.area,
                  icon: Icons.location_on_outlined,
                ),
              ],
            ),
          ),
          gap(14),

          // Active Deals
          heading(
            'Active Deals (${deals.length})',
            TextButton(
              onPressed: () => open(context, '/new-deal'),
              child: const Text('+ New Deal', style: TextStyle(fontSize: 12)),
            ),
          ),
          for (final d in deals)
            Panel(
              onTap: () => open(context, '/deal-details', d),
              child: Row(
                children: [
                  const Icon(
                    Icons.monetization_on_outlined,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          'Stage: ${d.stage} · Prob: ${d.probability}%',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '\$${d.value.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          gap(14),

          // Recent Notes with Pinned Badges
          heading(
            'Account Notes (${notes.length})',
            TextButton(
              onPressed: () => open(context, '/add-note', account),
              child: const Text('+ Add Note', style: TextStyle(fontSize: 12)),
            ),
          ),
          for (final n in notes)
            AccountNotePanel(
              note: store.notes
                  .where(
                    (record) =>
                        record.company == account.company && record.body == n,
                  )
                  .firstOrNull,
              body: n,
            ),

          gap(20),

          if (!customer)
            button(
              'Convert to Customer',
              () => open(context, '/convert-customer', account),
            ),
          button(
            'Activity Timeline',
            () => open(context, '/activity', account),
            secondary: true,
          ),
        ],
      );
    },
  );

  Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        IconButton.filledTonal(onPressed: onTap, icon: Icon(icon, size: 20)),
        muted(label),
      ],
    );
  }
}

class AccountNotePanel extends StatelessWidget {
  const AccountNotePanel({super.key, required this.note, required this.body});
  final CrmNote? note;
  final String body;
  @override
  Widget build(BuildContext c) => Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: strong(note?.title ?? 'Note', 13)),
            if (note?.isPinned == true)
              const Icon(Icons.push_pin, size: 15, color: AppColors.primary),
          ],
        ),
        if (note != null) ...[gap(4), muted(note!.category)],
        gap(8),
        Text(body, style: const TextStyle(fontSize: 13, height: 1.5)),
        for (final attachment in note?.attachments ?? <String>[])
          Builder(
            builder: (c) {
              Map<String, dynamic>? file;
              try {
                file = jsonDecode(attachment) as Map<String, dynamic>;
              } catch (_) {}
              if (file == null)
                return Text(attachment, style: const TextStyle(fontSize: 11));
              final data = file;
              return TextButton.icon(
                icon: const Icon(Icons.download, size: 16),
                label: Text(
                  data['name'] as String,
                  overflow: TextOverflow.ellipsis,
                ),
                onPressed: () async {
                  try {
                    final result = await CrmStorage.saveExportFile(
                      filename: data['name'] as String,
                      bytes: base64Decode(data['bytes'] as String),
                      mimeType:
                          data['mime'] as String? ?? 'application/octet-stream',
                    );
                    if (c.mounted)
                      message(
                        c,
                        result == null
                            ? 'Attachment download failed'
                            : 'Attachment downloaded',
                      );
                  } catch (e) {
                    if (c.mounted)
                      message(c, 'Unable to download attachment: $e');
                  }
                },
              );
            },
          ),
        if (note?.notifyTeam == true) ...[
          gap(6),
          muted('Team notification requested; awaiting server integration'),
        ],
      ],
    ),
  );
}

/// Page 34: Duplicate Lead Modal Sheet
class DuplicateLeadSheet extends StatelessWidget {
  const DuplicateLeadSheet({
    super.key,
    required this.existing,
    required this.newCompany,
    required this.onViewExisting,
    required this.onMerge,
    required this.onCreateAnyway,
  });

  final Account existing;
  final String newCompany;
  final VoidCallback onViewExisting;
  final VoidCallback onMerge;
  final VoidCallback onCreateAnyway;

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
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 28),
              SizedBox(width: 10),
              Text(
                'Possible Duplicate Detected',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'An account with matching company or contact details already exists in your workspace.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 16),

          // Existing Lead Card Preview
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                avatar(existing.initials),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        existing.company,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${existing.contact} · ${existing.role}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Stage: ${existing.stage} · Owner: ${existing.owner}',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Actions
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onViewExisting,
              icon: const Icon(Icons.visibility_outlined, size: 18),
              label: const Text('View Existing Account'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onMerge,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.merge_type, size: 18),
              label: const Text('Merge Into Existing Account'),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: onCreateAnyway,
              child: const Text(
                'Create As New Record Anyway',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pages 33 & 37: New Lead / Edit Lead Form with Duplicate Check and GPS Radar
Widget accountForm(Account? account) => CrmForm(
  title: account == null ? 'New Lead' : 'Edit Lead',
  submit: account == null ? 'Save Lead' : 'Save Changes',
  alternateSubmit: account == null ? 'Save & Schedule Visit' : null,
  onDelete: account == null
      ? null
      : (c) async {
          await CrmStore.instance.deleteLead(account.id);
          if (c.mounted) Navigator.pop(c);
        },
  fields: [
    FormFieldSpec(
      'First Name',
      section: 'Contact Person',
      pair: 'name',
      value: account?.contact.split(' ').first ?? '',
      required: true,
    ),
    FormFieldSpec(
      'Last Name',
      pair: 'name',
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
      section: 'Company Details',
      value: account?.company ?? '',
      required: true,
    ),
    FormFieldSpec('Designation', value: account?.role ?? 'CTO'),
    FormFieldSpec(
      'Industry',
      pair: 'company',
      value: account?.industry ?? 'Technology',
      options: const [
        'Technology',
        'Healthcare',
        'Logistics',
        'Retail',
        'Finance',
        'Manufacturing',
      ],
    ),
    FormFieldSpec(
      'Company Size',
      pair: 'company',
      value: account?.companySize ?? '100-500',
      options: const [
        '1-10',
        '10-50',
        '50-100',
        '100-500',
        '500-1000',
        '1000+',
      ],
    ),
    FormFieldSpec(
      'Use Current GPS',
      section: 'Location Details',
      kind: 'action',
      onAction: (c) async {
        try {
          if (!await Geolocator.isLocationServiceEnabled()) {
            if (c.mounted) message(c, 'Enable location services first.');
            return null;
          }
          var permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied)
            permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied ||
              permission == LocationPermission.deniedForever) {
            if (c.mounted)
              message(
                c,
                'Location permission is required. You can enter an address manually.',
              );
            return null;
          }
          final position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: Duration(seconds: 20),
            ),
          );
          return '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
        } catch (e) {
          if (c.mounted) message(c, 'Unable to get GPS location: $e');
          return null;
        }
      },
    ),
    FormFieldSpec(
      'Verified Address',
      value: account?.verifiedAddress ?? '',
      lines: 2,
    ),
    FormFieldSpec(
      'Lead Source',
      section: 'Lead Logistics',
      value: account?.source ?? 'Referral',
      options: const [
        'Walk-in',
        'Referral',
        'Website',
        'Cold Call',
        'Social Media',
        'Trade Show',
      ],
    ),
    FormFieldSpec(
      'Lead Priority',
      caption: 'Set Priority',
      kind: 'chips',
      value: account?.priority ?? 'High',
      options: const ['Low', 'Medium', 'High'],
    ),
    FormFieldSpec(
      'Lead Status',
      value: account?.stage ?? 'New',
      options: const [
        'New',
        'Contacted',
        'Qualified',
        'Proposal',
        'Negotiation',
      ],
    ),
    FormFieldSpec('Notes', value: account?.notes ?? '', lines: 3),
    const FormFieldSpec(
      'Scan / Add Visiting Card',
      section: 'Attachments',
      kind: 'attachments',
      helper:
          'Attach a visiting card. Enter contact details manually; OCR is not connected.',
    ),
  ],
  onSave: (context, v) async {
    final store = CrmStore.instance;
    final companyName = v['Company Name']!;
    final email = v['Email Address']!;
    final phone = v['Phone Number']!;

    if (account == null) {
      final duplicates = store.findDuplicateLeads(
        company: companyName,
        email: email,
        phone: phone,
      );
      if (duplicates.isNotEmpty) {
        final existing = duplicates.first;
        bool proceed = false;

        await showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (ctx) => DuplicateLeadSheet(
            existing: existing,
            newCompany: companyName,
            onViewExisting: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              open(context, '/lead-details', existing);
            },
            onMerge: () async {
              final newAcc = Account(
                companyName,
                '${v['First Name']} ${v['Last Name']}',
                phone: phone,
                email: email,
                role: v['Designation'] ?? 'CTO',
                area: v['Verified Address'] ?? '',
                notes: v['Notes'] ?? '',
              );
              try {
                await store.mergeAccounts(existing, newAcc);
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Records merged successfully!'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to merge records: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            onCreateAnyway: () {
              proceed = true;
              Navigator.pop(ctx);
            },
          ),
        );

        if (!proceed) return;
      }
    }

    final a =
        account ?? Account(companyName, '${v['First Name']} ${v['Last Name']}');
    try {
      await store.update(() {
        a.company = companyName;
        a.contact = '${v['First Name']} ${v['Last Name']}';
        a.phone = phone;
        a.email = email;
        a.role = v['Designation'] ?? 'CTO';
        a.area = v['Verified Address'] ?? '';
        a.verifiedAddress = v['Use Current GPS']?.isNotEmpty == true
            ? '${v['Verified Address']} (${v['Use Current GPS']})'
            : (v['Verified Address'] ?? '');
        a.notes = v['Notes'] ?? '';
        a.source = v['Lead Source'] ?? 'Referral';
        a.priority = v['Lead Priority'] ?? 'High';
        a.stage = v['Lead Status'] ?? 'New';
        if (v['Industry'] != null) a.industry = v['Industry']!;
        if (v['Company Size'] != null) a.companySize = v['Company Size']!;
        if (account == null) store.leads.add(a);
        final cardFiles = v['Scan / Add Visiting Card'] ?? '';
        if (cardFiles.isNotEmpty && cardFiles != '[]')
          store.notes.add(
            CrmNote(
              companyId: a.id,
              company: a.company,
              title: 'Visiting Card',
              content: 'Attached visiting card',
              attachments: (jsonDecode(cardFiles) as List)
                  .map((f) => jsonEncode(f))
                  .toList(),
            ),
          );
      });

      if (context.mounted) {
        Navigator.pop(context);
        if (v['_scheduleVisit'] == 'true') {
          open(context, '/schedule-visit', a);
        } else {
          message(context, 'Lead saved successfully!');
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save lead: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  },
);

/// Page 38: Log Call Form
Widget logCallForm(Account a) => CrmForm(
  title: 'Log Call',
  submit: 'Save Call Log',
  fields: [
    FormFieldSpec('Contact', value: '${a.contact} · ${a.company}'),
    const FormFieldSpec(
      'Call Outcome',
      value: 'Connected — Decision Maker',
      required: true,
      options: [
        'Connected — Decision Maker',
        'Connected — Gatekeeper',
        'Left Voicemail',
        'No Answer',
        'Wrong Number',
      ],
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
      options: [
        'Schedule Visit',
        'Send Proposal',
        'Follow-up Call',
        'Awaiting Callback',
      ],
    ),
  ],
  onSave: (c, v) async {
    try {
      await CrmStore.instance.addNote(
        a.company,
        'Call with ${a.contact}: ${v['Call Outcome']}. ${v['Notes']}',
      );
      if (c.mounted) {
        Navigator.pop(c);
        message(c, 'Call log saved');
      }
    } catch (e) {
      if (c.mounted) {
        ScaffoldMessenger.of(c).showSnackBar(
          SnackBar(
            content: Text('Failed to save call log: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  },
);

/// Page 39: Convert to Customer Form with Welcome Deal & Tier
Widget convertForm(Account a) => CrmForm(
  title: 'Convert to Customer',
  submit: 'Convert Lead',
  fields: [
    FormFieldSpec('Contact', value: '${a.contact} · ${a.company}'),
    const FormFieldSpec(
      'Customer Type',
      value: 'Enterprise',
      options: ['Enterprise', 'Mid-Market', 'Growth', 'Small Business'],
    ),
    const FormFieldSpec(
      'Account Owner',
      value: 'Arjun Mehta',
      options: ['Arjun Mehta', 'Priya Sharma', 'Rahul Patel'],
    ),
    const FormFieldSpec(
      'Assign Territory',
      value: 'South Mumbai',
      options: ['South Mumbai', 'North Mumbai', 'Lower Parel', 'BKC Complex'],
    ),
    const FormFieldSpec(
      'Initial Welcome Deal Value',
      value: '75000',
      kind: 'number',
    ),
  ],
  onSave: (c, v) async {
    final dealValue =
        double.tryParse(v['Initial Welcome Deal Value'] ?? '75000') ?? 75000;
    final welcomeDeal = Deal(
      '${a.company} Welcome Onboarding',
      a.company,
      dealValue,
      'Qualified',
      owner: v['Account Owner'] ?? 'Arjun Mehta',
    );

    try {
      await CrmStore.instance.convertToCustomer(
        a,
        welcomeDeal: welcomeDeal,
        customerType: v['Customer Type'] ?? 'Enterprise',
      );

      if (c.mounted) {
        Navigator.pop(c);
        Navigator.pushReplacementNamed(c, '/customer-details', arguments: a);
      }
    } catch (e) {
      if (c.mounted) {
        ScaffoldMessenger.of(c).showSnackBar(
          SnackBar(
            content: Text('Failed to convert lead: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  },
);

/// Page 44: Add Note Form with Category & Pinning
Widget noteForm(Account a) => CrmForm(
  title: 'Add Note',
  submit: 'Save',
  fields: [
    FormFieldSpec('Account', value: a.company, kind: 'readonly'),
    const FormFieldSpec(
      'Category',
      kind: 'chips',
      value: 'General',
      options: ['General', 'Meeting', 'Call', 'Follow-up', 'Issue'],
    ),
    const FormFieldSpec('Note Title', required: true),
    const FormFieldSpec('Note', required: true, lines: 7),
    const FormFieldSpec('Attachments', kind: 'attachments'),
    const FormFieldSpec('Pin this note to top', kind: 'toggle', value: 'false'),
    const FormFieldSpec(
      'Notify team members',
      kind: 'toggle',
      value: 'false',
      helper:
          'Saves the notification request. Team delivery requires server sync.',
    ),
  ],
  onSave: (c, v) async {
    final store = CrmStore.instance;
    await store.update(() {
      store.notes.insert(
        0,
        CrmNote(
          companyId: a.id,
          company: a.company,
          title: v['Note Title']!,
          content: v['Note']!,
          category: v['Category']!,
          isPinned: v['Pin this note to top'] == 'true',
          notifyTeam: v['Notify team members'] == 'true',
          attachments: v['Attachments']!.isEmpty
              ? []
              : (jsonDecode(v['Attachments']!) as List)
                    .map((f) => jsonEncode(f))
                    .toList(),
        ),
      );
      store.activities.insert(
        0,
        CrmActivity(
          companyId: a.id,
          company: a.company,
          type: 'Note',
          title: 'Note Added',
          description: v['Note Title']!,
        ),
      );
    });
    if (c.mounted) {
      Navigator.pop(c);
      message(c, 'Note saved');
    }
  },
);

/// Page 45: Activity Timeline Screen with Type Filters
class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key, required this.account});
  final Account account;
  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  String selectedFilter = 'All';
  final filterOptions = const [
    'All',
    'Visits',
    'Calls',
    'Emails',
    'Notes',
    'Deals',
  ];

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: CrmStore.instance,
    builder: (context, _) {
      final store = CrmStore.instance;
      final activities = store.activities.where((act) {
        final matchAccount =
            act.company == widget.account.company ||
            act.companyId == widget.account.id;
        final matchType =
            selectedFilter == 'All' ||
            act.type.toLowerCase() == selectedFilter.toLowerCase();
        return matchAccount && matchType;
      }).toList();

      return CrmPage(
        title: 'Activity Timeline',
        children: [
          Panel(
            child: Row(
              children: [
                avatar(widget.account.initials),
                const SizedBox(width: 12),
                strong(widget.account.company),
              ],
            ),
          ),
          gap(10),

          // Activity filter chips
          chips(
            filterOptions,
            selectedFilter,
            (s) => setState(() => selectedFilter = s),
          ),
          gap(12),

          heading('Chronological History'),
          if (activities.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Center(
                child: Text(
                  'No recorded activity matching "$selectedFilter"',
                  style: TextStyle(color: Colors.grey.shade400),
                ),
              ),
            )
          else
            for (final act in activities)
              Panel(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _activityIcon(act.type),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                act.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                dateText(act.timestamp),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            act.description,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        ],
      );
    },
  );

  Widget _activityIcon(String type) {
    IconData icon;
    Color color;
    switch (type.toLowerCase()) {
      case 'call':
        icon = Icons.phone;
        color = Colors.green;
        break;
      case 'visit':
        icon = Icons.location_on;
        color = AppColors.primary;
        break;
      case 'deal':
        icon = Icons.trending_up;
        color = Colors.blue;
        break;
      case 'email':
        icon = Icons.email;
        color = Colors.orange;
        break;
      default:
        icon = Icons.edit_note;
        color = Colors.purple;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }
}

/// Page 31: Full Lead Filters Sheet with Stage, Priority, Source, Value Slider
class LeadFiltersScreen extends StatefulWidget {
  const LeadFiltersScreen({super.key});
  @override
  State<LeadFiltersScreen> createState() => _LeadFiltersScreenState();
}

class _LeadFiltersScreenState extends State<LeadFiltersScreen> {
  String stage = 'All';
  String priority = 'All';
  String source = 'All';
  String assignedTo = 'All', dateAdded = 'All';
  DateTime? addedStart, addedEnd;
  RangeValues valueRange = const RangeValues(10, 250); // $10k to $250k

  @override
  Widget build(BuildContext c) {
    final leads = CrmStore.instance.leads.where((a) {
      final matchStage = stage == 'All' || a.stage == stage;
      final matchPriority =
          priority == 'All' ||
          a.priority ==
              {'Hot': 'High', 'Warm': 'Medium', 'Cold': 'Low'}[priority];
      final matchSource = source == 'All' || a.source == source;
      final matchValue =
          (a.accountValue / 1000) >= valueRange.start &&
          (a.accountValue / 1000) <= valueRange.end;
      return matchStage &&
          matchPriority &&
          matchSource &&
          matchValue &&
          (assignedTo == 'All' || a.owner == assignedTo) &&
          (addedStart == null ||
              (!a.createdAt.isBefore(addedStart!) &&
                  a.createdAt.isBefore(
                    addedEnd!.add(const Duration(days: 1)),
                  )));
    }).toList();

    return CrmPage(
      title: 'Filter Leads',
      actions: [
        TextButton(
          onPressed: () => setState(() {
            stage = 'All';
            priority = 'All';
            source = 'All';
            assignedTo = 'All';
            dateAdded = 'All';
            addedStart = null;
            addedEnd = null;
            valueRange = const RangeValues(10, 250);
          }),
          child: const Text('Reset All'),
        ),
      ],
      children: [
        heading('Lead Stage'),
        chips(
          const [
            'All',
            'New',
            'Contacted',
            'Qualified',
            'Proposal',
            'Negotiation',
          ],
          stage,
          (v) => setState(() => stage = v),
        ),
        gap(10),

        heading('Priority'),
        chips(
          const ['All', 'Hot', 'Warm', 'Cold'],
          priority,
          (v) => setState(() => priority = v),
        ),
        gap(10),

        heading('Lead Source'),
        chips(
          const [
            'All',
            'Referral',
            'Website',
            'Cold Call',
            'Social Media',
            'Trade Show',
          ],
          source,
          (v) => setState(() => source = v),
        ),
        gap(10),

        heading('Date Added'),
        chips(
          const ['All', 'Today', 'This Week', 'This Month', 'Custom Range'],
          dateAdded,
          (v) async {
            if (v == 'Custom Range') {
              final range = await showDateRangePicker(
                context: c,
                firstDate: DateTime(2020),
                lastDate: DateTime(2036),
              );
              if (range != null)
                setState(() {
                  dateAdded = v;
                  addedStart = range.start;
                  addedEnd = range.end;
                });
            } else {
              setState(() {
                dateAdded = v;
                if (v == 'All') {
                  addedStart = null;
                  addedEnd = null;
                } else {
                  final r = reportPreset(v);
                  addedStart = r.start;
                  addedEnd = r.end;
                }
              });
            }
          },
        ),
        gap(14),
        heading('Assigned To'),
        chips(
          ['All', ...CrmStore.instance.leads.map((a) => a.owner).toSet()],
          assignedTo,
          (v) => setState(() => assignedTo = v),
        ),
        gap(14),
        heading('Estimated Value (\$K)'),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '\$${valueRange.start.round()}K',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '\$${valueRange.end.round()}K',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        RangeSlider(
          values: valueRange,
          min: 10,
          max: 250,
          divisions: 24,
          labels: RangeLabels(
            '\$${valueRange.start.round()}K',
            '\$${valueRange.end.round()}K',
          ),
          onChanged: (v) => setState(() => valueRange = v),
        ),
        gap(24),

        button(
          'Show ${leads.length} Leads',
          () => Navigator.pushReplacement(
            c,
            MaterialPageRoute(
              builder: (_) => FilteredLeadsScreen(
                assignedTo: assignedTo,
                addedStart: addedStart,
                addedEnd: addedEnd,
                stage: stage,
                priority: priority,
                source: source,
                range: RangeValues(
                  valueRange.start * 1000,
                  valueRange.end * 1000,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class FilteredLeadsScreen extends StatelessWidget {
  const FilteredLeadsScreen({
    super.key,
    required this.stage,
    required this.priority,
    required this.source,
    required this.range,
    this.assignedTo = 'All',
    this.addedStart,
    this.addedEnd,
  });
  final String stage, priority, source;
  final RangeValues range;
  final String assignedTo;
  final DateTime? addedStart, addedEnd;

  @override
  Widget build(BuildContext c) {
    final items = CrmStore.instance.leads.where((a) {
      final matchStage = stage == 'All' || a.stage == stage;
      final matchPriority =
          priority == 'All' ||
          a.priority ==
              {'Hot': 'High', 'Warm': 'Medium', 'Cold': 'Low'}[priority];
      final matchSource = source == 'All' || a.source == source;
      final matchValue =
          a.accountValue >= range.start && a.accountValue <= range.end;
      return matchStage &&
          matchPriority &&
          matchSource &&
          matchValue &&
          (assignedTo == 'All' || a.owner == assignedTo) &&
          (addedStart == null ||
              (!a.createdAt.isBefore(addedStart!) &&
                  a.createdAt.isBefore(
                    addedEnd!.add(const Duration(days: 1)),
                  )));
    }).toList();

    return CrmPage(
      title: 'Filtered Leads',
      children: [
        muted('${items.length} leads matching filters'),
        gap(),
        if (items.isEmpty)
          emptyState(
            c,
            'No Results Found',
            'Try widening your stage, priority, or value ranges.',
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
              subtitle: muted('${a.contact} · ${a.role}'),
              trailing: badge(a.stage),
            ),
          ),
      ],
    );
  }
}
