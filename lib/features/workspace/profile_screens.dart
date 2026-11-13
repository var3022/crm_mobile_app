import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'crm_store.dart';
import 'crm_ui.dart';
import 'tasks_deals_screens.dart' show dateText;

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext c) => ListenableBuilder(
    listenable: CrmStore.instance,
    builder: (c, _) => CrmPage(
      title: 'Profile',
      nav: 4,
      actions: [
        TextButton(
          onPressed: () => open(c, '/edit-profile'),
          child: const Text('Edit Profile'),
        ),
      ],
      children: [
        gap(20),
        avatar('AM', radius: 42),
        gap(15),
        Center(child: strong(CrmStore.instance.name, 21)),
        gap(5),
        Center(child: badge('Field Sales Executive')),
        gap(5),
        Center(child: muted('Acme Industries · South Mumbai')),
        gap(20),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _stat('42', 'visits this month'),
            _stat('₹6.8L', 'revenue generated'),
            _stat('32%', 'conversion rate'),
          ],
        ),
        gap(15),
        const Divider(),
        for (final e in [
          ('My Reports', Icons.bar_chart, '/reports'),
          ('My Targets', Icons.flag_outlined, '/targets'),
          ('Visit History', Icons.history, '/visit-history'),
          ('Offline Data', Icons.cloud_download_outlined, '/offline-data'),
          ('Settings', Icons.settings_outlined, '/settings'),
          ('Help & Support', Icons.help_outline, '/help'),
          ('Customers', Icons.business_outlined, '/customers'),
          ('Sales Pipeline', Icons.trending_up, '/pipeline'),
          ('About', Icons.info_outline, '/about'),
        ])
          linkRow(e.$1, e.$2, () => open(c, e.$3)),
      ],
    ),
  );
  Widget _stat(String n, String label) => Column(
    children: [
      strong(n, 20),
      gap(4),
      Text(
        label,
        style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
      ),
    ],
  );
}

Widget profileForm() => CrmForm(
  title: 'Edit Profile',
  submit: 'Update Profile',
  fields: [
    FormFieldSpec('Full Name', value: CrmStore.instance.name, required: true),
    FormFieldSpec(
      'Email Address',
      value: CrmStore.instance.email,
      required: true,
      kind: 'email',
    ),
    FormFieldSpec(
      'Phone Number',
      value: CrmStore.instance.phone,
      required: true,
    ),
    const FormFieldSpec('Designation', value: 'Field Sales Executive'),
    const FormFieldSpec(
      'Territory',
      value: 'South Mumbai',
      options: ['South Mumbai', 'North Mumbai', 'Lower Parel'],
    ),
    const FormFieldSpec('Reporting Manager', value: 'Priya Sharma'),
  ],
  onSave: (c, v) async {
    CrmStore.instance.update(() {
      CrmStore.instance.name = v['Full Name']!;
      CrmStore.instance.email = v['Email Address']!;
      CrmStore.instance.phone = v['Phone Number']!;
    });
    Navigator.pop(c);
    message(c, 'Profile updated');
  },
);

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    this.notifications = false,
    this.permissions = false,
  });
  final bool notifications, permissions;
  @override
  Widget build(BuildContext c) => ListenableBuilder(
    listenable: CrmStore.instance,
    builder: (c, _) => CrmPage(
      title: permissions
          ? 'Permissions'
          : notifications
          ? 'Notification Settings'
          : 'Settings',
      nav: 4,
      children: [
        if (!notifications && !permissions) ...[
          Panel(
            child: Row(
              children: [
                avatar('AM'),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    strong(CrmStore.instance.name, 14),
                    muted(CrmStore.instance.email),
                    muted('Field Sales Executive · South Mumbai'),
                  ],
                ),
              ],
            ),
          ),
          heading('ACCOUNT SETTINGS'),
          linkRow(
            'Edit Profile',
            Icons.person_outline,
            () => open(c, '/edit-profile'),
          ),
          linkRow(
            'Change Password',
            Icons.lock_outline,
            () => open(c, '/change-password'),
          ),
          pref(c, 'Biometric Login'),
          linkRow(
            'Two-Factor Authentication',
            Icons.security,
            () => open(c, '/security'),
          ),
          heading('NOTIFICATIONS'),
        ],
        if (permissions) ...[
          Panel(
            child: muted(
              'These are preview preferences. Device permissions must be requested by the production app.',
            ),
          ),
          for (final s in ['Location', 'Camera', 'Microphone', 'Notifications'])
            pref(c, s),
        ] else ...[
          for (final s in [
            'Push Notifications',
            'New Lead Assigned',
            'Visit Reminders',
            'Task Due Notifications',
            'Deal Updates',
            'Team Messages',
          ])
            pref(c, s),
          if (notifications) ...[
            heading('EMAIL NOTIFICATIONS'),
            for (final s in [
              'Daily Summary',
              'Weekly Report',
              'Lead Activity Alerts',
              'Deal Stage Changes',
            ])
              pref(c, s),
            heading('QUIET HOURS'),
            pref(c, 'Enable Quiet Hours'),
          ],
        ],
        if (!notifications && !permissions) ...[
          linkRow(
            'Notification Preferences',
            Icons.notifications_outlined,
            () => open(c, '/notification-settings'),
          ),
          heading('LOCATION & TRACKING'),
          pref(c, 'Location Tracking'),
          linkRow(
            'Permissions',
            Icons.verified_user_outlined,
            () => open(c, '/permissions'),
          ),
          heading('OFFLINE & DATA'),
          linkRow(
            'Offline Data',
            Icons.cloud_outlined,
            () => open(c, '/offline-data'),
          ),
          pref(c, 'WiFi-only Sync'),
          heading('AI SETTINGS'),
          pref(c, 'AI Assistant'),
          pref(c, 'Daily Briefing'),
          gap(),
          button(
            'Sign Out',
            () => open(c, '/logout-confirmation'),
            secondary: true,
          ),
          Center(
            child: muted('You will be asked to confirm before signing out'),
          ),
        ],
      ],
    ),
  );
  Widget pref(BuildContext c, String name) => SwitchListTile(
    contentPadding: EdgeInsets.zero,
    dense: true,
    title: Text(name, style: const TextStyle(fontSize: 13)),
    value: CrmStore.instance.preferences[name] ?? true,
    onChanged: (v) =>
        CrmStore.instance.update(() => CrmStore.instance.preferences[name] = v),
  );
}

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final key = GlobalKey<FormState>();
  final current = TextEditingController(),
      next = TextEditingController(),
      confirmPass = TextEditingController();
  bool obscure = true;
  @override
  void dispose() {
    current.dispose();
    next.dispose();
    confirmPass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: const Text('Change Password')),
    body: Form(
      key: key,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          for (final e in [
            ('Current Password', current),
            ('New Password', next),
            ('Confirm New Password', confirmPass),
          ]) ...[
            heading(e.$1),
            TextFormField(
              controller: e.$2,
              obscureText: obscure,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  onPressed: () => setState(() => obscure = !obscure),
                  icon: Icon(
                    obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return '${e.$1} is required';
                if (e.$2 == next &&
                    (v.length < 8 ||
                        !RegExp('[A-Z]').hasMatch(v) ||
                        !RegExp('[0-9]').hasMatch(v)))
                  return 'Use 8+ characters, an uppercase letter and a number';
                if (e.$2 == next && v == current.text)
                  return 'Use a different password';
                if (e.$2 == confirmPass && v != next.text)
                  return 'Passwords do not match';
                return null;
              },
            ),
            gap(12),
          ],
          muted(
            'Use at least 8 characters with uppercase letters and numbers.',
          ),
          gap(24),
          button('Update Password', () {
            if (key.currentState!.validate())
              message(
                c,
                'Password validation passed. Password updates require your authentication service.',
              );
          }),
          button(
            'Forgot your current password?',
            () => open(c, '/forgot-password'),
            secondary: true,
          ),
        ],
      ),
    ),
  );
}

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key, this.targets = false});
  final bool targets;
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String period = 'This Month';
  @override
  Widget build(BuildContext c) => CrmPage(
    title: widget.targets ? 'My Targets' : 'My Reports',
    nav: 4,
    actions: [
      actionIcon(
        Icons.date_range,
        () => showDateRange(c),
        tooltip: 'Date range',
      ),
      if (!widget.targets)
        actionIcon(
          Icons.ios_share,
          () => showExport(c),
          tooltip: 'Export report',
        ),
    ],
    children: [
      if (!widget.targets)
        chips(
          ['This Week', 'This Month', 'Last Month', 'Quarter'],
          period,
          (v) => setState(() => period = v),
        ),
      gap(),
      Panel(
        color: const Color(0xFFECFDF5),
        child: Row(
          children: [
            avatar('A'),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  strong('Great performance this month!', 13),
                  muted('+12% above team average'),
                ],
              ),
            ),
          ],
        ),
      ),
      if (widget.targets) ...[
        gap(20),
        Center(
          child: SizedBox(
            width: 150,
            height: 150,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: .68,
                    strokeWidth: 10,
                    backgroundColor: AppColors.primaryLight,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [strong('68%', 34), muted('Overall Achieved')],
                ),
              ],
            ),
          ),
        ),
        gap(30),
        for (final e in [
          ('Visits Target', 42.0, 50.0, 'visits'),
          ('Revenue Target', 6.8, 10.0, 'L'),
          ('New Leads', 15.0, 20.0, 'leads'),
          ('Conversion Rate', 32.0, 30.0, '%'),
        ])
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                strong(e.$1, 14),
                gap(8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    muted('${e.$2} / ${e.$3} ${e.$4}'),
                    badge('${(e.$2 / e.$3 * 100).round()}%'),
                  ],
                ),
                gap(10),
                LinearProgressIndicator(
                  value: (e.$2 / e.$3).clamp(0, 1).toDouble(),
                  backgroundColor: AppColors.primaryLight,
                ),
              ],
            ),
          ),
      ] else ...[
        Row(
          children: [
            Expanded(child: _metric('VISITS GOAL', '42 / 50', '84% complete')),
            const SizedBox(width: 12),
            Expanded(
              child: _metric('REVENUE', '₹6.8L / ₹10L', '68% target met'),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(child: _metric('CONVERSION', '32%', '↑ 5% this month')),
            const SizedBox(width: 12),
            Expanded(
              child: _metric(
                'AVG DURATION',
                '38 min',
                'Within standard limits',
              ),
            ),
          ],
        ),
        heading('Visit Activity (Last Week)'),
        Panel(
          child: SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (int i = 0; i < 7; i++)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${[5, 8, 6, 9, 4, 7, 3][i]}',
                        style: const TextStyle(fontSize: 10),
                      ),
                      gap(5),
                      Container(
                        width: 14,
                        height: [75.0, 110.0, 85.0, 130.0, 60.0, 95.0, 45.0][i],
                        color: AppColors.primary,
                      ),
                      gap(8),
                      muted(['M', 'T', 'W', 'T', 'F', 'S', 'S'][i]),
                    ],
                  ),
              ],
            ),
          ),
        ),
        heading('Deal Pipeline Stage'),
        for (final stage in [
          'Qualified',
          'Discovery',
          'Proposal',
          'Negotiation',
          'Won',
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                SizedBox(width: 85, child: muted(stage)),
                Expanded(
                  child: LinearProgressIndicator(
                    value:
                        CrmStore.instance.deals
                            .where((d) => d.stage == stage)
                            .length /
                        (CrmStore.instance.deals.isEmpty
                            ? 1
                            : CrmStore.instance.deals.length),
                    minHeight: 20,
                    backgroundColor: AppColors.primaryLight,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${CrmStore.instance.deals.where((d) => d.stage == stage).length}',
                ),
              ],
            ),
          ),
      ],
      gap(),
      button('Day Complete', () => open(c, '/day-complete'), secondary: true),
    ],
  );
  Widget _metric(String label, String value, String help) => Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [muted(label), gap(8), strong(value, 19), gap(5), muted(help)],
    ),
  );
  Future<void> showDateRange(BuildContext c) async {
    final d = await showDateRangePicker(
      context: c,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 14)),
        end: DateTime.now(),
      ),
    );
    if (d != null)
      setState(() => period = '${dateText(d.start)} – ${dateText(d.end)}');
  }

  Future<void> showExport(BuildContext c) => showModalBottomSheet(
    context: c,
    isScrollControlled: true,
    builder: (c) => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          strong('Export Report', 20),
          gap(8),
          muted(
            'This preview can copy report data. PDF and spreadsheet file generation are not connected.',
          ),
          gap(20),
          button('Copy Report Data', () {
            Clipboard.setData(
              ClipboardData(
                text:
                    'CRM Pro Field Sales\n$period\nVisits: 42/50\nRevenue: INR 680000\nConversion: 32%\nAverage duration: 38 min',
              ),
            );
            Navigator.pop(c);
            message(context, 'Report data copied');
          }),
        ],
      ),
    ),
  );
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});
  @override
  Widget build(BuildContext c) => CrmPage(
    title: 'Visit History',
    nav: 4,
    children: [
      Panel(
        child: muted(
          '${CrmStore.instance.visits.length} visits · Recent activity',
        ),
      ),
      for (final v in CrmStore.instance.visits)
        Panel(
          onTap: () => open(c, '/visit-details', v),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: muted('${dateText(v.date)} · ${v.time}')),
                  badge(v.status),
                ],
              ),
              gap(10),
              strong(v.company, 15),
              muted(v.type),
              gap(8),
              muted(
                v.summary.isEmpty ? 'Tap to view visit details' : v.summary,
              ),
            ],
          ),
        ),
    ],
  );
}

class OfflineDataScreen extends StatelessWidget {
  const OfflineDataScreen({super.key});
  @override
  Widget build(BuildContext c) => CrmPage(
    title: 'Offline Data',
    nav: 4,
    children: [
      Panel(
        child: Row(
          children: [
            avatar('49%'),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  muted('Storage Used · Design reference'),
                  strong('245 MB / 500 MB', 17),
                  gap(8),
                  const LinearProgressIndicator(
                    value: .49,
                    backgroundColor: AppColors.primaryLight,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      Panel(
        child: muted(
          'Local preview: changes stay in memory for this session. Server sync and offline downloads are not connected.',
        ),
      ),
      heading('DATA BREAKDOWN'),
      for (final e in [
        ('Leads Data', '120 records · 45 MB'),
        ('Customer Profiles', '85 records · 38 MB'),
        ('Visit Logs', '7 days · 62 MB'),
        ('Photos & Media', '52 files · 78 MB'),
        ('Voice Notes', '12 files · 22 MB'),
      ])
        detail(e.$1, e.$2, icon: Icons.folder_outlined),
      gap(20),
      button(
        'Sync Now',
        () => message(c, 'Connect your CRM API to enable server sync.'),
      ),
      button(
        'Download All for Offline',
        () => message(
          c,
          'Offline downloads require a connected CRM data service.',
        ),
        secondary: true,
      ),
    ],
  );
}

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});
  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  String query = '';
  @override
  Widget build(BuildContext c) => CrmPage(
    title: 'Help & Support',
    children: [
      TextField(
        onChanged: (v) => setState(() => query = v),
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search),
          hintText: 'Search help articles...',
        ),
      ),
      heading('QUICK ACTIONS'),
      linkRow('Email Support', Icons.mail_outline, () {
        Clipboard.setData(
          const ClipboardData(
            text:
                'Contact your CRM administrator for your organization’s support address.',
          ),
        );
        message(
          c,
          'Ask your CRM administrator for the configured support contact.',
        );
      }, subtitle: 'Contact your organization’s CRM administrator'),
      heading('FREQUENTLY ASKED QUESTIONS'),
      for (final e in [
        (
          'How do I check in to a visit?',
          'Open Visits, choose your scheduled visit, and tap Check In. The preview supports manual, unverified check-in with a reason.',
        ),
        (
          'How does offline mode work?',
          'The current preview keeps data in memory. Persistent storage and server synchronization need to be connected before offline use.',
        ),
        (
          'How can I add a lead?',
          'Open Leads and tap +. Fill in the contact and company details, then save.',
        ),
        (
          'Where is my location tracked?',
          'This preview does not access your location. A production GPS service must request device permission.',
        ),
      ])
        if ('${e.$1} ${e.$2}'.toLowerCase().contains(query.toLowerCase()))
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text(e.$1, style: const TextStyle(fontSize: 13)),
            children: [
              Padding(padding: const EdgeInsets.all(12), child: muted(e.$2)),
            ],
          ),
      gap(20),
      Panel(
        child: Column(
          children: [
            strong('App Version', 13),
            muted('CRM Pro Field Sales v1.0.0'),
          ],
        ),
      ),
    ],
  );
}

class SystemStateScreen extends StatelessWidget {
  const SystemStateScreen({super.key, required this.kind});
  final String kind;
  @override
  Widget build(BuildContext c) {
    final data = <String, (String, String, IconData, String)>{
      'offline': (
        "You're Offline",
        'Your data is safe. Continue with the data already available in this session.',
        Icons.cloud_off_outlined,
        'Continue Offline',
      ),
      'syncing': (
        'Syncing Your Data',
        'Fetching your latest leads, visits, and deals requires a connected CRM API.',
        Icons.sync,
        'Go to Dashboard',
      ),
      'server-error': (
        'Something Went Wrong',
        "We couldn’t connect to the server. Please check your connection and try again.",
        Icons.cloud_off_outlined,
        'Try Again',
      ),
      'session-expired': (
        'Session Expired',
        'For your security, your session has timed out. Please sign in again to continue.',
        Icons.lock_outline,
        'Sign In Again',
      ),
      'access-restricted': (
        'Access Restricted',
        "You don’t have permission to view this content. Contact your admin to request access.",
        Icons.shield_outlined,
        'Contact Administrator',
      ),
      'not-found': (
        'Page Not Found',
        "The page you’re looking for doesn’t exist or has been moved.",
        Icons.description_outlined,
        'Go to Dashboard',
      ),
      'rate-limit': (
        'Too Many Requests',
        "You’ve exceeded the rate limit. Please wait a moment before trying again.",
        Icons.schedule,
        'Go to Dashboard',
      ),
      'suspended': (
        'Account Suspended',
        'Your account has been suspended. Please contact your administrator for assistance.',
        Icons.gpp_bad_outlined,
        'Contact Support',
      ),
      'subscription-expired': (
        'Subscription Expired',
        'Your subscription has expired. Contact your administrator to renew.',
        Icons.event_busy,
        'Contact Administrator',
      ),
      'maintenance': (
        'Under Maintenance',
        "We’re performing scheduled maintenance. We’ll be back shortly.",
        Icons.home_repair_service_outlined,
        'Go to Dashboard',
      ),
    };
    final d = data[kind] ?? data['not-found']!;
    return CrmPage(
      title: '',
      children: [
        gap(120),
        Center(
          child: CircleAvatar(
            radius: 48,
            backgroundColor: kind == 'offline'
                ? AppColors.surfaceTertiary
                : AppColors.primaryLight,
            child: Icon(d.$3, size: 38, color: AppColors.primary),
          ),
        ),
        gap(32),
        Center(child: strong(d.$1, 22)),
        gap(12),
        Text(
          d.$2,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            height: 1.6,
          ),
        ),
        gap(32),
        button(d.$4, () {
          if (kind == 'session-expired')
            Navigator.pushNamedAndRemoveUntil(c, '/sign-in', (r) => false);
          else if (d.$4.contains('Contact'))
            open(c, '/help');
          else
            tab(c, 0);
        }),
        button(
          'Back to Previous',
          () => Navigator.maybePop(c),
          secondary: true,
        ),
      ],
    );
  }
}

class DayCompleteScreen extends StatelessWidget {
  const DayCompleteScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final store = CrmStore.instance;
    final completed = store.visits.where((v) => v.status == 'Completed').length;
    final completedTasks = store.tasks.where((t) => t.completed).length;
    return CrmPage(
      title: 'Day Complete 🎉',
      children: [
        Center(child: muted(dateText(DateTime.now()))),
        gap(20),
        Panel(
          color: const Color(0xFFD1FAE5),
          child: Center(
            child: strong(
              'Great work today, ${store.name.split(' ').first}!',
              15,
            ),
          ),
        ),
        heading('TODAY’S METRICS'),
        Panel(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: detail(
                      'Visits Completed',
                      '$completed / ${store.visits.length}',
                    ),
                  ),
                  Expanded(
                    child: detail(
                      'Tasks Completed',
                      '$completedTasks / ${store.tasks.length}',
                    ),
                  ),
                ],
              ),
              const Divider(),
              detail('New Leads', '${store.leads.length} in your pipeline'),
              detail(
                'Active Deals',
                '${store.deals.where((d) => d.stage != 'Won' && d.stage != 'Lost').length} opportunities',
              ),
            ],
          ),
        ),
        heading('HIGHLIGHTS'),
        for (final visit in store.visits.where((v) => v.status == 'Completed'))
          Panel(
            child: Row(
              children: [
                const Icon(Icons.check, size: 17, color: AppColors.success),
                const SizedBox(width: 10),
                Expanded(child: muted('Completed visit to ${visit.company}')),
              ],
            ),
          ),
        Panel(
          color: AppColors.primary,
          child: const Text(
            '✦ AI INSIGHT\n\nReview your follow-up tasks and scheduled visits to prepare for your next day.',
            style: TextStyle(color: Colors.white, fontSize: 13, height: 1.6),
          ),
        ),
        button('Go to Dashboard', () => tab(context, 0)),
        button(
          'View Full Report',
          () => open(context, '/reports'),
          secondary: true,
        ),
      ],
    );
  }
}

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});
  @override
  Widget build(BuildContext c) => CrmPage(
    title: 'Security Settings',
    children: [
      gap(20),
      avatar('LP', radius: 35),
      gap(25),
      strong('Set Up Two-Factor Authentication', 24),
      gap(),
      muted('Add an extra layer of security to your account.'),
      gap(24),
      Panel(
        child: detail(
          'Authenticator App',
          'Generate one-time codes for secure sign-in.',
          icon: Icons.security,
        ),
      ),
      Panel(
        child: detail(
          'SMS Verification',
          'Receive a verification code by text message.',
          icon: Icons.sms_outlined,
        ),
      ),
      gap(20),
      muted(
        'Two-factor setup must be provided by your authentication service. No security setting is changed in this preview.',
      ),
    ],
  );
}
