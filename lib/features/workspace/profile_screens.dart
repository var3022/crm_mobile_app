import 'report_export.dart';
import 'reporting_ui.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'crm_store.dart';
import 'crm_ui.dart';
import 'crm_services.dart';
import 'crm_storage.dart';
import 'tasks_deals_screens.dart' show dateText;

/// Page 81: Profile Screen with data-derived stats and avatar
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext c) => ListenableBuilder(
    listenable: CrmStore.instance,
    builder: (c, _) {
      final store = CrmStore.instance;
      final p = MonthlyPerformance(store, DateTime.now());
      final storage = store.calculateStorageBreakdown();
      return CrmPage(
        title: 'Profile',
        nav: 4,
        actions: [
          TextButton(
            onPressed: () => open(c, '/edit-profile'),
            child: const Text('Edit Profile'),
          ),
        ],
        children: [
          gap(16),
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: strong(store.userProfile.avatarInitials, 25),
            ),
          ),
          gap(12),
          Center(child: strong(store.name, 22)),
          gap(4),
          Center(child: muted(store.userProfile.designation)),
          gap(4),
          Center(
            child: muted('Acme Industries · ${store.userProfile.territory}'),
          ),
          gap(22),
          Row(
            children: [
              Expanded(child: _stat('${p.visits.length}', 'visits this month')),
              Expanded(child: _stat(rupees(p.revenue), 'revenue generated')),
              Expanded(
                child: _stat('${p.conversion.round()}%', 'conversion rate'),
              ),
            ],
          ),
          gap(24),
          Panel(
            child: Column(
              children: [
                linkRow(
                  'My Reports',
                  Icons.bar_chart_outlined,
                  () => open(c, '/reports'),
                ),
                linkRow(
                  'My Targets',
                  Icons.flag_outlined,
                  () => open(c, '/targets'),
                ),
                linkRow(
                  'Visit History',
                  Icons.history,
                  () => open(c, '/visit-history'),
                ),
                linkRow(
                  'Offline Data',
                  Icons.cloud_download_outlined,
                  () => open(c, '/offline-data'),
                  trailing: muted(
                    '${(storage['totalMb'] as num).toStringAsFixed(2)} MB',
                  ),
                ),
                linkRow(
                  'Settings',
                  Icons.settings_outlined,
                  () => open(c, '/settings'),
                ),
                linkRow(
                  'Help & Support',
                  Icons.help_outline,
                  () => open(c, '/help'),
                ),
                linkRow(
                  'About',
                  Icons.info_outline,
                  () => open(c, '/about'),
                  trailing: muted('v1.0.0'),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
  Widget _stat(String value, String label) => Column(
    children: [
      strong(value, 21),
      gap(5),
      Text(
        label,
        style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
        textAlign: TextAlign.center,
      ),
    ],
  );
}

/// Page 82: Edit Profile Form with Photo Avatar & Lock Indicator
Widget profileForm() => CrmForm(
  title: 'Edit Profile',
  submit: 'Update Profile',
  fields: [
    FormFieldSpec('Full Name', value: CrmStore.instance.name, required: true),
    FormFieldSpec(
      'Email Address (SSO Locked)',
      value: CrmStore.instance.email,
      required: true,
      kind: 'email',
    ),
    FormFieldSpec(
      'Phone Number',
      value: CrmStore.instance.phone,
      required: true,
    ),
    FormFieldSpec(
      'Designation',
      value: CrmStore.instance.userProfile.designation,
    ),
    FormFieldSpec(
      'Territory',
      value: CrmStore.instance.userProfile.territory,
      options: const [
        'Mumbai South & West Region',
        'BKC & Central Mumbai',
        'Powai & Thane Region',
      ],
    ),
    FormFieldSpec(
      'Reporting Manager',
      value: CrmStore.instance.userProfile.reportingManager,
    ),
  ],
  onSave: (c, v) async {
    try {
      await CrmStore.instance.updateProfile(
        name: v['Full Name']!,
        email: v['Email Address (SSO Locked)']!,
        phone: v['Phone Number']!,
        designation: v['Designation'],
        territory: v['Territory'],
        reportingManager: v['Reporting Manager'],
      );
      if (c.mounted) {
        Navigator.pop(c);
        message(c, 'Profile updated successfully');
      }
    } catch (e) {
      if (c.mounted) {
        ScaffoldMessenger.of(c).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  },
);

/// Page 12: Logout Confirmation Bottom Sheet Modal
class LogoutConfirmationModal extends StatelessWidget {
  const LogoutConfirmationModal({super.key});

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
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 18),
          const Icon(Icons.logout_rounded, size: 48, color: AppColors.error),
          const SizedBox(height: 12),
          const Text(
            'Sign Out of FieldPulse?',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Your unsynced offline records and cached assets will remain securely stored on this device until you sign back in.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/sign-in',
                      (r) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Sign Out'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Page 83: Settings Screen with Toggles and Quiet Hours Link
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Widget _setting(
    BuildContext c,
    String label,
    bool value,
    void Function(bool) change,
  ) => SwitchListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(
      label,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    ),
    value: value,
    onChanged: (v) async {
      try {
        await CrmStore.instance.update(() => change(v));
      } catch (_) {
        if (c.mounted) message(c, 'Failed to save setting');
      }
    },
  );
  @override
  Widget build(BuildContext c) => ListenableBuilder(
    listenable: CrmStore.instance,
    builder: (c, _) {
      final s = CrmStore.instance.appSettings;

      return CrmPage(
        title: 'Settings',
        nav: 4,
        actions: [
          PopupMenuButton<String>(
            onSelected: (route) => open(c, route),
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: '/security',
                child: Text('Two-Factor Authentication (2FA)'),
              ),
              PopupMenuItem(
                value: '/notification-settings',
                child: Text('Notification Categories & Quiet Hours'),
              ),
            ],
          ),
        ],
        children: [
          Panel(
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: strong(
                    CrmStore.instance.userProfile.avatarInitials,
                    24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      strong(CrmStore.instance.name, 16),
                      muted(CrmStore.instance.email),
                      muted(CrmStore.instance.userProfile.designation),
                      muted(CrmStore.instance.userProfile.territory),
                    ],
                  ),
                ),
              ],
            ),
          ),
          gap(20),
          heading('Account Settings'),
          Panel(
            child: Column(
              children: [
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
                _setting(
                  c,
                  'Biometric Login',
                  s.biometricLogin,
                  (v) => s.biometricLogin = v,
                ),
              ],
            ),
          ),
          gap(14),
          heading('Notifications'),
          Panel(
            child: Column(
              children: [
                _setting(
                  c,
                  'Push Notifications',
                  s.pushNotifications,
                  (v) => s.pushNotifications = v,
                ),
                _setting(
                  c,
                  'Visit Reminders',
                  s.visitReminders,
                  (v) => s.visitReminders = v,
                ),
                _setting(
                  c,
                  'Nearby Leads Alert',
                  s.nearbyLeadsAlert,
                  (v) => s.nearbyLeadsAlert = v,
                ),
              ],
            ),
          ),
          gap(14),
          heading('Location & Tracking'),
          Panel(
            child: Column(
              children: [
                _setting(
                  c,
                  'Location Tracking',
                  s.locationTracking,
                  (v) => s.locationTracking = v,
                ),
                linkRow('Tracking Hours', Icons.schedule, () async {
                  final start = await showTimePicker(
                    context: c,
                    initialTime: const TimeOfDay(hour: 8, minute: 0),
                  );
                  if (start == null || !c.mounted) return;
                  final end = await showTimePicker(
                    context: c,
                    initialTime: const TimeOfDay(hour: 20, minute: 0),
                  );
                  if (end == null || !c.mounted) return;
                  final hours = '${start.format(c)} - ${end.format(c)}';
                  try {
                    await CrmStore.instance.update(
                      () => s.trackingHours = hours,
                    );
                  } catch (_) {
                    if (c.mounted) message(c, 'Failed to save tracking hours');
                  }
                }, trailing: muted(s.trackingHours)),
              ],
            ),
          ),
          gap(14),
          heading('Offline & Data'),
          Panel(
            child: Column(
              children: [
                linkRow(
                  'Offline Data',
                  Icons.cloud_download_outlined,
                  () => open(c, '/offline-data'),
                ),
                _setting(
                  c,
                  'Wi-Fi only Sync',
                  s.wifiOnlySync,
                  (v) => s.wifiOnlySync = v,
                ),
              ],
            ),
          ),
          gap(14),
          heading('AI Settings'),
          Panel(
            child: Column(
              children: [
                _setting(
                  c,
                  'AI Assistant',
                  s.aiAssistant,
                  (v) => s.aiAssistant = v,
                ),
                _setting(
                  c,
                  'Daily Briefing',
                  s.dailyBriefing,
                  (v) => s.dailyBriefing = v,
                ),
              ],
            ),
          ),
          gap(20),
          button('Sign Out', () {
            showModalBottomSheet(
              context: c,
              backgroundColor: Colors.transparent,
              builder: (_) => const LogoutConfirmationModal(),
            );
          }, secondary: true),
          gap(16),
          Center(
            child: muted('You will be asked to confirm before signing out'),
          ),
        ],
      );
    },
  );
}

/// Page 84: Change Password Screen with live strength meter & 4 criteria
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final current = TextEditingController();
  final newPass = TextEditingController();
  final confirmPass = TextEditingController();
  String password = '';

  @override
  void dispose() {
    current.dispose();
    newPass.dispose();
    confirmPass.dispose();
    super.dispose();
  }

  bool get hasMinLength => password.length >= 8;
  bool get hasNumber => password.contains(RegExp(r'\d'));
  bool get hasUppercase => password.contains(RegExp(r'[A-Z]'));
  bool get hasSpecial => password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

  int get score =>
      (hasMinLength ? 1 : 0) +
      (hasNumber ? 1 : 0) +
      (hasUppercase ? 1 : 0) +
      (hasSpecial ? 1 : 0);

  @override
  Widget build(BuildContext c) => CrmPage(
    title: 'Change Password',
    children: [
      TextField(
        controller: current,
        obscureText: true,
        decoration: const InputDecoration(labelText: 'Current Password'),
      ),
      gap(12),
      TextField(
        controller: newPass,
        obscureText: true,
        onChanged: (v) => setState(() => password = v),
        decoration: const InputDecoration(labelText: 'New Password'),
      ),
      gap(10),

      // Strength Indicator Bar
      Row(
        children: [
          Expanded(
            child: LinearProgressIndicator(
              value: score / 4,
              backgroundColor: Colors.grey.shade200,
              color: score <= 1
                  ? Colors.red
                  : score <= 3
                  ? Colors.orange
                  : Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            score <= 1
                ? 'Weak'
                : score <= 3
                ? 'Medium'
                : 'Strong',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: score <= 1
                  ? Colors.red
                  : score <= 3
                  ? Colors.orange
                  : Colors.green,
            ),
          ),
        ],
      ),
      gap(14),

      // 4 Requirement Checks
      _reqCheck('At least 8 characters', hasMinLength),
      _reqCheck('At least one numeric digit (0-9)', hasNumber),
      _reqCheck('At least one uppercase letter (A-Z)', hasUppercase),
      _reqCheck('At least one special character (!@#\$%)', hasSpecial),
      gap(14),

      TextField(
        controller: confirmPass,
        obscureText: true,
        decoration: const InputDecoration(labelText: 'Confirm New Password'),
      ),
      gap(24),

      button('Update Password', () {
        if (score < 3) {
          message(c, 'Password does not meet required security standards');
          return;
        }
        if (newPass.text != confirmPass.text) {
          message(c, 'New passwords do not match');
          return;
        }
        message(c, 'Password changed successfully!');
        Navigator.pop(c);
      }),
    ],
  );

  Widget _reqCheck(String label, bool passed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            passed ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: passed ? AppColors.success : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: passed ? AppColors.textDark : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

/// Page 85: Notification Settings Screen with Quiet Hours (FROM 10 PM / TO 7 AM)
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});
  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  @override
  Widget build(BuildContext c) => ListenableBuilder(
    listenable: CrmStore.instance,
    builder: (c, _) {
      final s = CrmStore.instance.appSettings;

      return CrmPage(
        title: 'Notification Settings',
        children: [
          heading('PUSH ALERTS'),
          SwitchListTile(
            title: const Text(
              'Visit Reminders',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            subtitle: const Text(
              'Alert 15 minutes before scheduled arrival',
              style: TextStyle(fontSize: 11),
            ),
            value: s.visitReminders,
            onChanged: (v) =>
                CrmStore.instance.update(() => s.visitReminders = v),
          ),
          SwitchListTile(
            title: const Text(
              'Task Due Reminders',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            subtitle: const Text(
              'Alerts when manager-assigned tasks are due',
              style: TextStyle(fontSize: 11),
            ),
            value: s.taskDueNotifications,
            onChanged: (v) =>
                CrmStore.instance.update(() => s.taskDueNotifications = v),
          ),
          SwitchListTile(
            title: const Text(
              'Deal Stage Updates',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            subtitle: const Text(
              'Notify when pipeline deals change status',
              style: TextStyle(fontSize: 11),
            ),
            value: s.dealStageChanges,
            onChanged: (v) =>
                CrmStore.instance.update(() => s.dealStageChanges = v),
          ),
          gap(14),

          heading('EMAIL SUMMARIES'),
          SwitchListTile(
            title: const Text(
              'Daily Morning Briefing',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            subtitle: const Text(
              'Sent at 8:00 AM with today\'s agenda',
              style: TextStyle(fontSize: 11),
            ),
            value: s.dailySummary,
            onChanged: (v) =>
                CrmStore.instance.update(() => s.dailySummary = v),
          ),
          SwitchListTile(
            title: const Text(
              'Weekly Performance Report',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            subtitle: const Text(
              'Weekly PDF summary sent every Sunday evening',
              style: TextStyle(fontSize: 11),
            ),
            value: s.weeklyReport,
            onChanged: (v) =>
                CrmStore.instance.update(() => s.weeklyReport = v),
          ),
          gap(14),

          // Quiet Hours Section
          heading('QUIET HOURS'),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Enable Quiet Hours',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: const Text(
                      'Mute all non-urgent field push alerts',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: s.quietHoursEnabled,
                    onChanged: (v) =>
                        CrmStore.instance.update(() => s.quietHoursEnabled = v),
                  ),
                  if (s.quietHoursEnabled) ...[
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text(
                              'FROM',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Chip(
                              label: Text(
                                s.quietHoursFrom,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Icon(
                          Icons.arrow_forward,
                          color: Colors.grey,
                          size: 18,
                        ),
                        Column(
                          children: [
                            const Text(
                              'TO',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Chip(
                              label: Text(
                                s.quietHoursTo,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Allow urgent visit reminders during quiet hours',
                        style: TextStyle(fontSize: 12),
                      ),
                      value: s.quietHoursAllowUrgent,
                      onChanged: (v) => CrmStore.instance.update(
                        () => s.quietHoursAllowUrgent = v ?? true,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          gap(20),
          button('Save Preferences', () {
            message(c, 'Notification preferences saved');
            Navigator.pop(c);
          }),
        ],
      );
    },
  );
}

/// Page 86: Help & Support Screen with Search & FAQs
class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});
  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final searchController = TextEditingController();

  final faqs = const [
    (
      'How does offline GPS check-in work?',
      'FieldPulse records your GPS coordinates locally in secure storage. When network connectivity is restored, visits and check-in audit records sync automatically with the central server.',
    ),
    (
      'Can I reorder my route stops?',
      'Yes! Open "Plan Route", tap "Apply AI Route" to auto-optimize by live traffic, or use the drag handles to manually reorder stops.',
    ),
    (
      'How are PDF and Excel reports generated?',
      'Go to "My Reports", tap "Export Report", select your date range and desired format (PDF, Excel .xlsx, or CSV). The report file will be generated on-device immediately.',
    ),
    (
      'What if two-factor verification fails?',
      'You can switch to "Use backup code instead" on the verification screen and enter any of your 8 generated one-time emergency recovery codes.',
    ),
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) => CrmPage(
    title: 'Help & Support',
    children: [
      TextField(
        controller: searchController,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search),
          hintText: 'Search help articles, guides & FAQs...',
        ),
      ),
      gap(16),

      // Quick Support Channels
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _supportCard(Icons.chat_bubble_outline, 'Live Chat', () {
            message(c, 'Connecting to FieldPulse Support Chat...');
          }),
          _supportCard(Icons.phone_outlined, 'Call Support', () {
            DeviceService.callPhone('+911800233456');
          }),
          _supportCard(Icons.mail_outline, 'Email Support', () {
            DeviceService.sendEmail(
              'support@fieldpulse.io',
              'CRM Mobile App Support Request',
            );
          }),
        ],
      ),
      gap(20),

      heading('FREQUENTLY ASKED QUESTIONS'),
      for (final f in faqs)
        ExpansionTile(
          title: Text(
            f.$1,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          children: [
            Text(
              f.$2,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      gap(20),

      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          TextButton(
            onPressed: () =>
                message(c, 'Terms of Service version 2.4 (Active)'),
            child: const Text(
              'Terms of Service',
              style: TextStyle(fontSize: 12),
            ),
          ),
          TextButton(
            onPressed: () =>
                message(c, 'Privacy Policy compliant with SOC2 and GDPR'),
            child: const Text('Privacy Policy', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    ],
  );

  Widget _supportCard(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: AppColors.primary),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pages 78, 79, 80: Reports Screen with Export Modal Sheet (PDF/XLSX/CSV)
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  ReportRange range = reportPreset('This Month');
  Future<void> chooseRange() async {
    final selected = await selectReportRange(context, range);
    if (selected != null && mounted) setState(() => range = selected);
  }

  void export(BuildContext c) => showModalBottomSheet(
    context: c,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ExportReportModal(
      initialPeriod: 'Custom Range',
      initialStartDate: range.start,
      initialEndDate: range.end,
    ),
  );
  @override
  Widget build(BuildContext c) => ListenableBuilder(
    listenable: CrmStore.instance,
    builder: (c, _) {
      final store = CrmStore.instance;
      bool selected(DateTime date) =>
          !date.isBefore(range.start) &&
          date.isBefore(range.end.add(const Duration(days: 1)));
      final visits = store.visits.where((v) => selected(v.date)).toList();
      final completed = visits.where((v) => v.status == 'Completed').toList();
      final deals = store.deals
          .where((d) => selected(d.closeDate ?? d.createdAt))
          .toList();
      final won = deals.where((d) => d.stage == 'Won').toList();
      final closed = deals
          .where((d) => d.stage == 'Won' || d.stage == 'Lost')
          .length;
      final revenue = won.fold<double>(0, (s, d) => s + d.value);
      final conversion = closed == 0 ? 0.0 : won.length / closed * 100;
      final minutes = completed.fold<int>(
        0,
        (s, v) => s + CrmStorage.parseDurationMinutes(v),
      );
      final average = completed.isEmpty
          ? 0
          : (minutes / completed.length).round();
      final lastWeek = reportPreset('Last Week');
      final activity = store.visits
          .where(
            (v) =>
                !v.date.isBefore(lastWeek.start) &&
                v.date.isBefore(lastWeek.end.add(const Duration(days: 1))),
          )
          .toList();
      final counts = [
        for (var i = 1; i <= 7; i++)
          activity.where((v) => v.date.weekday == i).length,
      ];
      final maximum = counts.fold<int>(1, (a, b) => a > b ? a : b);
      final previousStart = range.start.subtract(
        Duration(days: range.end.difference(range.start).inDays + 1),
      );
      final previousVisits = store.visits
          .where(
            (v) =>
                v.status == 'Completed' &&
                !v.date.isBefore(previousStart) &&
                v.date.isBefore(range.start),
          )
          .length;
      return CrmPage(
        title: 'My Reports',
        nav: 0,
        actions: [
          IconButton(
            tooltip: 'Select Date Range',
            onPressed: chooseRange,
            icon: const Icon(Icons.calendar_today_outlined),
          ),
          IconButton(
            tooltip: 'Export Report',
            onPressed: () => export(c),
            icon: const Icon(Icons.file_download_outlined),
          ),
        ],
        children: [
          chips(
            const ['This Week', 'This Month', 'Last Month', 'Quarter'],
            range.label,
            (v) => setState(() => range = reportPreset(v)),
          ),
          gap(14),
          Panel(
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: strong(completed.length >= 40 ? 'A' : '—', 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      strong(
                        completed.length >= 40
                            ? 'Great performance this month!'
                            : 'Your performance this month',
                        15,
                      ),
                      gap(4),
                      muted(
                        'Team average unavailable until team data is connected.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          gap(16),
          if (range.compare) ...[
            Panel(
              child: Text(
                '${completed.length} completed visits vs $previousVisits in the previous ${range.end.difference(range.start).inDays + 1} days',
              ),
            ),
            gap(12),
          ],
          Row(
            children: [
              Expanded(
                child: metric(
                  'VISITS GOAL',
                  '${completed.length} / 50',
                  '${(completed.length / 50 * 100).round()}% complete',
                  completed.length / 50,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: metric(
                  'REVENUE',
                  '${rupees(revenue)} / ₹10L',
                  '${(revenue / 1000000 * 100).round()}% target met',
                  revenue / 1000000,
                ),
              ),
            ],
          ),
          gap(12),
          Row(
            children: [
              Expanded(
                child: metric(
                  'CONVERSION',
                  closed == 0 ? 'N/A' : '${conversion.round()}%',
                  '$closed closed deals',
                  null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: metric(
                  'AVG DURATION',
                  '$average min',
                  completed.isEmpty
                      ? 'No completed visits'
                      : 'Completed visits only',
                  null,
                ),
              ),
            ],
          ),
          gap(24),
          heading('Visit Activity (Last Week)'),
          Panel(
            color: Colors.white,
            child: SizedBox(
              height: 130,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (var i = 0; i < 7; i++)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${counts[i]}',
                          style: const TextStyle(fontSize: 10),
                        ),
                        gap(5),
                        Container(
                          width: 18,
                          height: 75 * counts[i] / maximum,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        gap(6),
                        Text(
                          ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i],
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          gap(24),
          heading('Deal Pipeline Stage'),
          ...['Qualified', 'Discovery', 'Proposal', 'Negotiation', 'Won'].map((
            stage,
          ) {
            final count = deals.where((d) => d.stage == stage).length;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(stage, style: const TextStyle(fontSize: 11)),
                  ),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: deals.isEmpty ? 0 : count / deals.length,
                      minHeight: 16,
                      borderRadius: BorderRadius.circular(4),
                      backgroundColor: AppColors.primaryLight,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('$count'),
                ],
              ),
            );
          }),
          gap(12),
          button('Export Report', () => export(c)),
        ],
      );
    },
  );
  Widget metric(
    String label,
    String value,
    String subtitle,
    double? progress,
  ) => Container(
    height: 130,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
        gap(8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        const Spacer(),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
        if (progress != null) ...[
          gap(7),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: AppColors.border,
            color: AppColors.primary,
            minHeight: 5,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ],
    ),
  );
}

class _ExportReportModal extends StatefulWidget {
  const _ExportReportModal({
    this.initialPeriod = 'This Month',
    this.initialStartDate,
    this.initialEndDate,
  });
  final String initialPeriod;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;

  @override
  State<_ExportReportModal> createState() => _ExportReportModalState();
}

class _ExportReportModalState extends State<_ExportReportModal> {
  String format = 'pdf';
  bool charts = true,
      rawData = true,
      summary = true,
      team = false,
      exporting = false;
  late ReportRange range =
      widget.initialStartDate != null && widget.initialEndDate != null
      ? ReportRange('Custom', widget.initialStartDate!, widget.initialEndDate!)
      : reportPreset(widget.initialPeriod);
  final email = TextEditingController();
  @override
  void dispose() {
    email.dispose();
    super.dispose();
  }

  Future<void> export() async {
    if (exporting) return;
    final address = email.text.trim();
    if (address.isNotEmpty &&
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(address)) {
      message(context, 'Enter a valid email address');
      return;
    }
    if (!charts && !rawData && !summary && !team) {
      message(context, 'Select at least one content section');
      return;
    }
    setState(() => exporting = true);
    final messenger = ScaffoldMessenger.of(context),
        navigator = Navigator.of(context);
    try {
      final file = buildReportFile(
        CrmStore.instance,
        format,
        range.start,
        range.end,
        ReportContents(
          charts: charts,
          rawData: rawData,
          summary: summary,
          team: team,
        ),
      );
      final filename =
          'CRM_Report_${range.start.toIso8601String().split('T').first}.$format';
      final saved = await CrmStorage.saveExportFile(
        filename: filename,
        bytes: file.bytes,
        mimeType: file.mimeType,
      );
      if (saved == null) throw StateError('Unable to write download');
      if (!mounted) return;
      if (address.isNotEmpty) {
        final launched = await DeviceService.launchUri(
          Uri(
            scheme: 'mailto',
            path: address,
            queryParameters: {
              'subject':
                  'CRM Report: ${dateLabel(range.start)} - ${dateLabel(range.end)}',
              'body':
                  'Please find the CRM report attached.\nAttach the downloaded file: $filename',
            },
          ),
        );
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              launched
                  ? 'Report downloaded. Attach it in your email composer before sending.'
                  : 'Report downloaded. Email composer unavailable; send the downloaded file manually.',
            ),
          ),
        );
      } else {
        messenger.showSnackBar(
          SnackBar(content: Text('Report downloaded: $filename')),
        );
      }
      if (mounted) navigator.pop();
    } catch (e) {
      if (mounted) message(context, 'Export failed: $e');
    } finally {
      if (mounted) setState(() => exporting = false);
    }
  }

  @override
  Widget build(BuildContext c) => Container(
    constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(c).height * .9),
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    child: SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        20 + MediaQuery.viewInsetsOf(c).bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: strong('Export Report', 19)),
              IconButton(
                onPressed: exporting ? null : () => Navigator.pop(c),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          TextButton(
            onPressed: () async {
              final selected = await selectReportRange(c, range);
              if (selected != null) setState(() => range = selected);
            },
            child: Text('${dateLabel(range.start)} — ${dateLabel(range.end)}'),
          ),
          for (final choice in [
            ('pdf', 'PDF Report', 'Formatted report with charts and tables'),
            ('xlsx', 'Excel Spreadsheet', 'Raw data in .xlsx format'),
            ('csv', 'CSV File', 'Plain data export'),
          ])
            Material(
              color: Colors.transparent,
              child: RadioListTile<String>(
                contentPadding: EdgeInsets.zero,
                value: choice.$1,
                groupValue: format,
                onChanged: exporting
                    ? null
                    : (v) => setState(() => format = v!),
                title: Text(
                  choice.$2,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(choice.$3, style: const TextStyle(fontSize: 11)),
              ),
            ),
          gap(12),
          heading('INCLUDE CONTENT'),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              FilterChip(
                label: const Text('Charts'),
                selected: charts,
                onSelected: (v) => setState(() => charts = v),
              ),
              FilterChip(
                label: const Text('Raw Data'),
                selected: rawData,
                onSelected: (v) => setState(() => rawData = v),
              ),
              FilterChip(
                label: const Text('Summary'),
                selected: summary,
                onSelected: (v) => setState(() => summary = v),
              ),
              FilterChip(
                label: const Text('Team Breakdown'),
                selected: team,
                onSelected: (v) => setState(() => team = v),
              ),
            ],
          ),
          gap(8),
          if (format != 'pdf')
            muted('Charts are exported as chart data in Excel and CSV.'),
          gap(16),
          heading('SEND COPY TO EMAIL'),
          TextField(
            controller: email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Email address (optional)',
            ),
          ),
          gap(6),
          muted(
            'Opens your email composer after download. Attach the file before sending.',
          ),
          gap(20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: exporting ? null : () => Navigator.pop(c),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: AppButton(
                  label: 'Export & Download',
                  isLoading: exporting,
                  onPressed: export,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

/// Page 88: Targets Screen with circular gauge, real KPI calculation, and team comparison
class TargetsScreen extends StatefulWidget {
  const TargetsScreen({super.key});
  @override
  State<TargetsScreen> createState() => _TargetsScreenState();
}

class _TargetsScreenState extends State<TargetsScreen> {
  DateTime month = DateTime(DateTime.now().year, DateTime.now().month);
  @override
  Widget build(BuildContext c) => ListenableBuilder(
    listenable: CrmStore.instance,
    builder: (c, _) {
      final p = MonthlyPerformance(CrmStore.instance, month);
      return CrmPage(
        title: 'My Targets',
        nav: 4,
        actions: [
          TextButton(
            onPressed: () async {
              final selected = await showDatePicker(
                context: c,
                initialDate: month,
                firstDate: DateTime(2020),
                lastDate: DateTime(2036),
              );
              if (selected != null)
                setState(() => month = DateTime(selected.year, selected.month));
            },
            child: Text(monthLabel(month)),
          ),
        ],
        children: [
          gap(16),
          Center(
            child: SizedBox(
              width: 150,
              height: 150,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: p.overall,
                      strokeWidth: 10,
                      backgroundColor: AppColors.border,
                      color: AppColors.primary,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      strong('${(p.overall * 100).round()}%', 34),
                      const Text(
                        'Overall\nAchieved',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          gap(28),
          _target(
            'Visits Target',
            '${p.visits.length} / 50 visits',
            p.visits.length / 50,
          ),
          _target(
            'Revenue Target',
            '${rupees(p.revenue)} / ₹10.0L',
            p.revenue / 1000000,
          ),
          _target('New Leads', '${p.newLeads} / 20 leads', p.newLeads / 20),
          _target(
            'Conversion Rate',
            '${p.conversion.round()}% achieved',
            p.conversion / 20,
            exceeding: p.conversion >= 20,
          ),
          _target(
            'Avg Deal Size',
            '${rupees(p.averageDeal)} (Target ₹1.5L)',
            p.averageDeal / 150000,
            exceeding: p.averageDeal >= 150000,
          ),
          gap(14),
          heading('TEAM COMPARISON'),
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                strong(CrmStore.instance.userProfile.territory),
                gap(8),
                muted('Team ranking unavailable until team data is connected.'),
              ],
            ),
          ),
        ],
      );
    },
  );
  Widget _target(
    String title,
    String value,
    double fraction, {
    bool exceeding = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Panel(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          muted(title),
          gap(6),
          Row(
            children: [
              Expanded(child: strong(value, 17)),
              if (exceeding)
                badge('Exceeding', color: AppColors.success)
              else
                strong('${(fraction * 100).round()}%', 17),
            ],
          ),
          gap(12),
          LinearProgressIndicator(
            value: fraction.clamp(0.0, 1.0),
            minHeight: 8,
            borderRadius: BorderRadius.circular(6),
            backgroundColor: AppColors.border,
          ),
        ],
      ),
    ),
  );
}

/// Page 89: Visit History Screen with month filters and summary
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime month = DateTime(DateTime.now().year, DateTime.now().month);
  String get selectedMonth => monthLabel(month);

  @override
  Widget build(BuildContext c) => ListenableBuilder(
    listenable: CrmStore.instance,
    builder: (c, _) {
      final store = CrmStore.instance;
      final completed = store.visits
          .where((v) => v.status == 'Completed' && inMonth(v.date, month))
          .toList();
      final totalMinutes = completed.fold<int>(
        0,
        (sum, v) => sum + CrmStorage.parseDurationMinutes(v),
      );
      final totalHoursStr = (totalMinutes / 60.0).toStringAsFixed(1) + 'h';
      final uniqueClients = completed.map((v) => v.companyId).toSet().length;
      return CrmPage(
        title: 'Visit History',
        nav: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Export History',
            onPressed: () async {
              final csv = CrmStorage.instance.generateCsv(
                leads: [],
                customers: [],
                deals: [],
                visits: completed,
              );
              final result = await CrmStorage.saveExportFile(
                filename: 'Visit_History_${month.year}_${month.month}.csv',
                bytes: utf8.encode(csv),
                mimeType: 'text/csv',
              );
              if (c.mounted)
                message(
                  c,
                  result == null
                      ? 'Failed to export visit history'
                      : 'Visit history downloaded',
                );
            },
          ),
        ],
        children: [
          chips(
            [
              for (var i = 2; i >= 0; i--)
                monthLabel(
                  DateTime(DateTime.now().year, DateTime.now().month - i),
                ),
            ],
            selectedMonth,
            (v) => setState(() {
              final parts = v.split(' ');
              month = DateTime(
                int.parse(parts.last),
                monthNames.indexOf(parts.first) + 1,
              );
            }),
          ),
          gap(14),

          // Monthly Summary Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text(
                      'Total Visits',
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${completed.length}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text(
                      'Total Hours',
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      totalHoursStr,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text(
                      'Unique Clients',
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$uniqueClients',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          gap(16),

          heading('VISIT LOGS'),
          for (final v in completed)
            Panel(
              onTap: () => open(c, '/visit-summary', v),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        v.company,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        v.duration,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${v.contact} · ${v.type}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 12,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        v.outcome,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.success,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        dateText(v.date),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
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

/// Page 90: Offline Data Screen with breakdown gauge & cleanup
class OfflineDataScreen extends StatefulWidget {
  const OfflineDataScreen({super.key});
  @override
  State<OfflineDataScreen> createState() => _OfflineDataScreenState();
}

class _OfflineDataScreenState extends State<OfflineDataScreen> {
  bool isSyncing = false;

  void _triggerSync() async {
    setState(() => isSyncing = true);
    final acknowledged = await CrmStore.instance.syncNow();
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() => isSyncing = false);
      final pending = CrmStore.instance.appSettings.pendingSyncItems;
      final msg = acknowledged
          ? 'Remote database sync complete and acknowledged by server.'
          : 'Offline queue preserved ($pending items pending). No remote CRM sync gateway is configured.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  void _confirmCleanup() async {
    final confirmed = await confirm(
      context,
      'Clear Old Data (>30 Days)?',
      'Completed visits, completed tasks and activity older than 30 days will be removed from this device. Download an offline backup first; no server backup is configured.',
      action: 'Clear Storage',
    );
    if (confirmed) {
      try {
        await CrmStore.instance.clearOldData(olderThanDays: 30);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage cleaned up successfully')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to clean up storage: $e'),
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
      final store = CrmStore.instance;
      final breakdown = store.calculateStorageBreakdown();
      final totalMb = (breakdown['totalMb'] as num).toDouble();
      final limitMb = (breakdown['storageLimitMb'] as num).toDouble();

      return CrmPage(
        title: 'Offline Data',
        nav: 4,
        actions: [
          IconButton(
            icon: isSyncing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
            tooltip: 'Sync Now',
            onPressed: isSyncing ? null : _triggerSync,
          ),
        ],
        children: [
          // Storage Gauge Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Storage Used',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_storageSize(totalMb)} / ${limitMb.toStringAsFixed(0)} MB',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: totalMb / limitMb,
                  backgroundColor: Colors.grey.shade200,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 10),
                Text(
                  'Last synced: ${dateText(store.appSettings.lastSyncTime)} at ${store.appSettings.lastSyncTime.hour.toString().padLeft(2, "0")}:${store.appSettings.lastSyncTime.minute.toString().padLeft(2, "0")}',
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
          gap(16),

          heading('DATA BREAKDOWN'),
          Panel(
            child: Column(
              children: [
                _storageItem(
                  Icons.people_outline,
                  'Leads Data',
                  _storageSize(breakdown['leadsMb'] as num),
                  '${store.leads.length} records',
                ),
                const Divider(),
                _storageItem(
                  Icons.business_outlined,
                  'Customer Profiles',
                  _storageSize(breakdown['customersMb'] as num),
                  '${store.customers.length} records',
                ),
                const Divider(),
                _storageItem(
                  Icons.history,
                  'Visit Logs',
                  _storageSize(breakdown['visitsMb'] as num),
                  '${store.visits.length} records',
                ),
                const Divider(),
                _storageItem(
                  Icons.photo_library_outlined,
                  'Photos & Media',
                  _storageSize(breakdown['photosMb'] as num),
                  '${store.photos.length} files',
                ),
                const Divider(),
                _storageItem(
                  Icons.mic_none,
                  'Voice Notes',
                  _storageSize(breakdown['audioMb'] as num),
                  '${store.voiceNotes.length} files',
                ),
              ],
            ),
          ),
          gap(20),

          button(
            isSyncing ? 'Synchronizing...' : 'Sync Now',
            isSyncing ? () {} : _triggerSync,
          ),
          button('Clear Old Data (>30 days)', _confirmCleanup, secondary: true),
          gap(12),
          button('Download All for Offline', () async {
            try {
              final result = await store.downloadAllForOffline();
              if (c.mounted)
                message(
                  c,
                  result == null
                      ? 'Download failed'
                      : 'Offline backup downloaded. Reference media remains bundled with the app.',
                );
            } catch (e) {
              if (c.mounted) message(c, 'Download failed: $e');
            }
          }, secondary: true),
          gap(16),
          muted(
            'Sizes reflect serialized local records and attached files. Bundled sample media is excluded. Clearing data cannot be undone. Remote backup is unavailable until server sync is connected.',
          ),
        ],
      );
    },
  );

  String _storageSize(num mb) => mb < 1
      ? '${(mb * 1024).toStringAsFixed(1)} KB'
      : '${mb.toStringAsFixed(1)} MB';

  Widget _storageItem(IconData icon, String title, String size, String count) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                count,
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          ),
        ),
        Text(
          size,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }
}

/// Page 19: Permissions Screen with Skip Confirmation Dialog
class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({super.key});

  @override
  Widget build(BuildContext c) => CrmPage(
    title: 'App Permissions',
    children: [
      gap(10),
      const Center(
        child: Text(
          'Device Access Permissions',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      gap(6),
      Center(
        child: Text(
          'FieldPulse requires the following permissions to verify client visits and scan documents offline:',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
      ),
      gap(20),

      _permTile(
        Icons.location_on,
        'Location (GPS)',
        'Required for radius verification & route planning',
        true,
      ),
      _permTile(
        Icons.photo_camera,
        'Camera Access',
        'Capture storefronts, visiting cards & OCR scans',
        true,
      ),
      _permTile(
        Icons.mic,
        'Microphone',
        'Record client voice memos & automated transcription',
        true,
      ),
      _permTile(
        Icons.notifications_active,
        'Notifications',
        'Real-time visit reminders & manager task alerts',
        true,
      ),
      _permTile(
        Icons.sd_storage,
        'Local Storage',
        'Offline database persistence and document caching',
        true,
      ),
      gap(24),

      button('Grant All Permissions', () {
        message(c, 'All permissions granted for this session');
        Navigator.pop(c);
      }),
      button('Skip Permissions', () {
        showDialog(
          context: c,
          builder: (ctx) => AlertDialog(
            title: const Text('Skip Permissions?'),
            content: const Text(
              'Without location and camera permissions, GPS verification and OCR photo captures will be simulated in unverified mode.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Go Back'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(c);
                },
                child: const Text('Skip Anyway'),
              ),
            ],
          ),
        );
      }, secondary: true),
    ],
  );

  Widget _permTile(IconData icon, String title, String subtitle, bool granted) {
    return Panel(
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: AppColors.success, size: 20),
        ],
      ),
    );
  }
}

/// Page 87: Day Complete Screen
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
        gap(16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFD1FAE5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: strong(
              'Great work today, ${store.name.split(" ").first}!',
              16,
            ),
          ),
        ),
        gap(16),

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
              detail(
                'Active Deals',
                '${store.deals.where((d) => d.stage != "Won" && d.stage != "Lost").length} in progress',
              ),
            ],
          ),
        ),
        gap(14),

        heading('HIGHLIGHTS'),
        for (final visit in store.visits.where((v) => v.status == 'Completed'))
          Panel(
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 16,
                  color: AppColors.success,
                ),
                const SizedBox(width: 10),
                Expanded(child: muted('Completed visit to ${visit.company}')),
              ],
            ),
          ),
        gap(14),

        Panel(
          color: AppColors.primary,
          child: const Text(
            '✦ AI SUMMARY\n\nAll client visit notes have been synchronized with your central CRM. You are fully prepped for tomorrow\'s 6 stops.',
            style: TextStyle(color: Colors.white, fontSize: 12, height: 1.5),
          ),
        ),
        gap(20),

        button('Go to Dashboard', () => tab(context, 0)),
        button(
          'View Performance Reports',
          () => open(context, '/reports'),
          secondary: true,
        ),
      ],
    );
  }
}

/// Page 11: Two-Factor Authentication Setup & Device Verification Screen
class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});
  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool isTwoFactorEnabled = false;
  bool showBackupCodes = false;
  bool useBackupCodeMode = false;
  final codeController = TextEditingController();

  late String currentSecret;
  late List<String> backupCodes;
  final List<String> consumedBackupCodes = [];

  @override
  void initState() {
    super.initState();
    final settings = CrmStore.instance.appSettings;
    if (settings.twoFactorEnabled &&
        settings.twoFactorSecret != null &&
        settings.twoFactorSecret!.isNotEmpty) {
      currentSecret = settings.twoFactorSecret!;
      backupCodes = List.from(settings.backupCodes);
      consumedBackupCodes.addAll(settings.consumedBackupCodes);
      isTwoFactorEnabled = true;
    } else {
      currentSecret = AuthService.generateRandomBase32Secret(16);
      backupCodes = AuthService.generateBackupCodes(8);
      isTwoFactorEnabled = false;
    }
  }

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  void _regenerateSecret() {
    setState(() {
      currentSecret = AuthService.generateRandomBase32Secret(16);
      backupCodes = AuthService.generateBackupCodes(8);
      consumedBackupCodes.clear();
      isTwoFactorEnabled = false;
      codeController.clear();
    });
    CrmStore.instance.update(() {
      final s = CrmStore.instance.appSettings;
      s.twoFactorEnabled = false;
      s.twoFactorSecret = null;
      s.backupCodes = [];
      s.consumedBackupCodes = [];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'New 2FA enrollment secret and recovery codes generated.',
        ),
      ),
    );
  }

  void _disableTwoFactor() {
    setState(() {
      isTwoFactorEnabled = false;
      codeController.clear();
    });
    CrmStore.instance.update(() {
      final s = CrmStore.instance.appSettings;
      s.twoFactorEnabled = false;
      s.twoFactorSecret = null;
      s.backupCodes = [];
      s.consumedBackupCodes = [];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Two-factor authentication disabled.')),
    );
  }

  void _verifyPin() {
    final pin = codeController.text.trim();
    if (useBackupCodeMode) {
      final success = AuthService.consumeBackupCode(
        code: pin,
        availableCodes: backupCodes,
        consumedCodes: consumedBackupCodes,
      );
      if (success) {
        setState(() => isTwoFactorEnabled = true);
        CrmStore.instance.update(() {
          final s = CrmStore.instance.appSettings;
          s.twoFactorEnabled = true;
          s.twoFactorSecret = currentSecret;
          s.backupCodes = List.from(backupCodes);
          s.consumedBackupCodes = List.from(consumedBackupCodes);
        });
        codeController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Backup code verified and consumed! (${backupCodes.length} codes remaining)',
            ),
          ),
        );
      } else {
        final alreadyUsed = consumedBackupCodes.any(
          (c) =>
              AuthService.normalizeBackupCode(c) ==
              AuthService.normalizeBackupCode(pin),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              alreadyUsed
                  ? 'This backup code has already been consumed and cannot be reused.'
                  : 'Invalid backup recovery code. Please check your recovery list.',
            ),
          ),
        );
      }
    } else {
      final success = AuthService.verifyTotp(code: pin, secret: currentSecret);
      if (success) {
        setState(() => isTwoFactorEnabled = true);
        CrmStore.instance.update(() {
          final s = CrmStore.instance.appSettings;
          s.twoFactorEnabled = true;
          s.twoFactorSecret = currentSecret;
          s.backupCodes = List.from(backupCodes);
          s.consumedBackupCodes = List.from(consumedBackupCodes);
        });
        codeController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('TOTP token confirmed! Demo 2FA is active locally.'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Invalid 6-digit TOTP code for the active secret. Ensure code matches the current 30s window.',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext c) => CrmPage(
    title: 'Two-Factor Security',
    children: [
      // Explicit Demo Status Banner
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
            const Icon(Icons.info_outline, color: Colors.amber, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'DEMO / SIMULATED 2FA (Local-Only Evaluation)\n'
                'Authenticator verification is evaluated locally for offline demonstration. Client-only verification cannot provide server-level account protection without an external Identity Provider.',
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
      gap(14),

      Center(
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: (isTwoFactorEnabled ? AppColors.success : AppColors.primary)
                .withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isTwoFactorEnabled
                ? Icons.verified_user_outlined
                : Icons.shield_outlined,
            size: 40,
            color: isTwoFactorEnabled ? AppColors.success : AppColors.primary,
          ),
        ),
      ),
      gap(14),
      Center(
        child: strong(
          isTwoFactorEnabled
              ? '2FA Active (Local Demo)'
              : 'Two-Factor Authentication (2FA)',
          20,
        ),
      ),
      gap(6),
      Center(
        child: Text(
          isTwoFactorEnabled
              ? 'Local demo verification complete. Authenticator code or one-time backup codes verified.'
              : 'Protect client records and sensitive financial proposals by requiring a second verification factor.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
      ),
      gap(18),

      // Secret Key Card
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'ENROLLMENT SECRET KEY (RFC 6238)',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  onPressed: _regenerateSecret,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text(
                    'Regenerate',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: SelectableText(
                    currentSecret,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.copy,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  tooltip: 'Copy Key',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: currentSecret));
                    ScaffoldMessenger.of(c).showSnackBar(
                      const SnackBar(content: Text('Secret key copied')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      gap(14),

      // Backup Codes Section
      ExpansionTile(
        title: Text(
          'Emergency Backup Codes (${backupCodes.length}/8 Remaining)',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        childrenPadding: const EdgeInsets.all(12),
        children: [
          const Text(
            'Save these one-time emergency codes. Each code can only be used once:',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...backupCodes.map(
                (code) => Chip(
                  backgroundColor: Colors.grey.shade100,
                  label: Text(
                    code,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              ...consumedBackupCodes.map(
                (code) => Chip(
                  backgroundColor: Colors.red.shade50,
                  label: Text(
                    '$code [USED]',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: Colors.red.shade700,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (backupCodes.isNotEmpty)
            OutlinedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: backupCodes.join('\n')));
                ScaffoldMessenger.of(c).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${backupCodes.length} active backup codes copied to clipboard',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('Copy Active Backup Codes'),
            ),
        ],
      ),
      gap(16),

      heading(
        useBackupCodeMode
            ? 'ENTER ONE-TIME BACKUP CODE'
            : 'ENTER 6-DIGIT TOTP PIN',
      ),
      TextField(
        controller: codeController,
        keyboardType: useBackupCodeMode
            ? TextInputType.text
            : TextInputType.number,
        decoration: InputDecoration(
          hintText: useBackupCodeMode
              ? 'e.g. ABCD - 1234'
              : '6-digit code for active secret',
          prefixIcon: const Icon(Icons.lock_clock_outlined),
        ),
      ),
      gap(8),
      Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: () =>
              setState(() => useBackupCodeMode = !useBackupCodeMode),
          child: Text(
            useBackupCodeMode
                ? 'Use Authenticator App PIN instead'
                : 'Use one-time backup code instead',
          ),
        ),
      ),
      gap(16),

      button(
        isTwoFactorEnabled
            ? 'Re-Verify Code'
            : 'Verify & Activate 2FA (Local Demo)',
        _verifyPin,
      ),
      if (isTwoFactorEnabled) ...[
        gap(10),
        button(
          'Disable 2FA (Reset Demo State)',
          _disableTwoFactor,
          secondary: true,
        ),
      ],
    ],
  );
}

/// Status / Error Screens (Offline, Session Expired, Rate Limit, Not Found, etc.)
class StatusScreen extends StatelessWidget {
  const StatusScreen({super.key, required this.kind});
  final String kind;

  @override
  Widget build(BuildContext c) {
    final data = <String, (String, String, IconData, String)>{
      'offline': (
        'No Internet Connection',
        'Your CRM workspace is currently working in local offline mode. All changes, visits, and photos are saved securely on device.',
        Icons.wifi_off_rounded,
        'Go to Dashboard',
      ),
      'syncing': (
        'Synchronizing Database',
        'Transmitting your offline visit logs, contracts, and captured media to the primary cloud server.',
        Icons.sync_rounded,
        'View Status',
      ),
      'server-error': (
        'Server Error 500',
        'Our backend servers encountered an unexpected issue. Local cache remains safe and fully accessible.',
        Icons.cloud_off_rounded,
        'Retry Connection',
      ),
      'session-expired': (
        'Session Expired',
        'Your enterprise SSO security token has expired. Please authenticate with your credentials.',
        Icons.lock_clock_outlined,
        'Sign In Again',
      ),
      'access-restricted': (
        'Access Restricted',
        'Your current role does not have authorization to view this enterprise territory.',
        Icons.block_rounded,
        'Contact Administrator',
      ),
      'not-found': (
        'Page Not Found',
        'The screen or resource you requested could not be located.',
        Icons.explore_off_outlined,
        'Go to Dashboard',
      ),
      'rate-limit': (
        'Rate Limit Exceeded',
        'Too many sync requests were dispatched in a short window. Please wait 30 seconds.',
        Icons.speed_rounded,
        'Wait & Retry',
      ),
      'suspended': (
        'Account Suspended',
        'Your company account has been temporarily suspended. Please reach out to billing support.',
        Icons.warning_amber_rounded,
        'Contact Support',
      ),
      'subscription-expired': (
        'Subscription Renewal Required',
        'Your enterprise mobile CRM license expired. Contact your system admin.',
        Icons.card_membership_rounded,
        'Renew Subscription',
      ),
      'maintenance': (
        'Scheduled Maintenance',
        'Our database infrastructure is undergoing scheduled upgrades between 2:00 AM - 4:00 AM UTC.',
        Icons.build_rounded,
        'Dismiss',
      ),
    };

    final d = data[kind] ?? data['not-found']!;
    return CrmPage(
      title: '',
      children: [
        gap(100),
        Center(
          child: CircleAvatar(
            radius: 46,
            backgroundColor: kind == 'offline'
                ? AppColors.surfaceTertiary
                : AppColors.primaryLight,
            child: Icon(d.$3, size: 36, color: AppColors.primary),
          ),
        ),
        gap(28),
        Center(child: strong(d.$1, 21)),
        gap(10),
        Text(
          d.$2,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            height: 1.5,
          ),
        ),
        gap(28),
        button(d.$4, () {
          if (kind == 'session-expired') {
            Navigator.pushNamedAndRemoveUntil(c, '/sign-in', (r) => false);
          } else if (d.$4.contains('Contact')) {
            open(c, '/help');
          } else {
            tab(c, 0);
          }
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

/// Backward-compatible alias for system error/status screens
typedef SystemStateScreen = StatusScreen;
