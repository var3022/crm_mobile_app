import 'package:flutter/material.dart';
import 'crm_store.dart';
import 'crm_ui.dart';
import 'accounts_screens.dart';
import 'tasks_deals_screens.dart';
import 'visits_screens.dart';
import 'profile_screens.dart';
import 'media_screens.dart';

/// Named routes for the PDF's account, deal, visit, task and profile workflows.
/// Arguments carry the selected record; there is no hidden global selection.
Route<dynamic>? crmRoute(RouteSettings settings) {
  final store = CrmStore.instance;
  final arg = settings.arguments;
  Account account() {
    if (arg is Account) return arg;
    final company = arg is Visit
        ? arg.company
        : arg is Deal
        ? arg.company
        : null;
    if (company != null)
      return [...store.leads, ...store.customers].firstWhere(
        (a) => a.company == company,
        orElse: () => Account(company, arg is Visit ? arg.contact : 'John Doe'),
      );
    return store.leads.isNotEmpty
        ? store.leads.first
        : Account('Acme Corp', 'John Doe');
  }

  Visit visit() => arg is Visit
      ? arg
      : store.visits.isNotEmpty
      ? store.visits.first
      : Visit('Acme Corp', 'John Doe', '10:00 AM', 'First Meeting');
  CrmTask task() => arg is CrmTask
      ? arg
      : store.tasks.isNotEmpty
      ? store.tasks.first
      : CrmTask('Follow up with Acme Corp', 'Acme Corp');
  Deal deal() => arg is Deal
      ? arg
      : store.deals.isNotEmpty
      ? store.deals.first
      : Deal('Enterprise CRM Suite', 'Acme Corp', 250000, 'Proposal');
  Widget? page;
  switch (settings.name) {
    case '/leads':
    case '/leads-list':
    case '/screen-leads-list':
      page = const AccountsScreen();
      break;
    case '/empty-leads':
    case '/screen-empty-leads':
      page = const AccountsScreen(empty: true);
      break;
    case '/customers':
      page = const AccountsScreen(customers: true);
      break;
    case '/empty-customers':
      page = const AccountsScreen(customers: true, empty: true);
      break;
    case '/lead-details':
      page = AccountDetailsScreen(account: account());
      break;
    case '/customer-details':
      page = AccountDetailsScreen(account: account(), customer: true);
      break;
    case '/new-lead':
      page = accountForm(null);
      break;
    case '/edit-lead':
      page = accountForm(account());
      break;
    case '/filter-leads':
      page = const LeadFiltersScreen();
      break;
    case '/log-call':
      page = logCallForm(account());
      break;
    case '/convert-customer':
      page = convertForm(account());
      break;
    case '/add-note':
      page = noteForm(account());
      break;
    case '/activity':
      page = ActivityScreen(account: account());
      break;
    case '/pipeline':
      page = const PipelineScreen();
      break;
    case '/empty-deals':
      page = const PipelineScreen(empty: true);
      break;
    case '/new-deal':
      page = dealForm(null, arg is Account ? arg : null);
      break;
    case '/update-deal':
      page = dealForm(deal());
      break;
    case '/deal-details':
      page = DealDetailsScreen(deal: deal());
      break;
    case '/deal-won':
      page = DealResultScreen(deal: deal(), won: true);
      break;
    case '/deal-lost':
      page = DealResultScreen(deal: deal(), won: false);
      break;
    case '/visits':
      page = const VisitsScreen();
      break;
    case '/empty-visits':
      page = const VisitsScreen(empty: true);
      break;
    case '/schedule-visit':
      page = visitForm(null, arg is Account ? arg : null);
      break;
    case '/reschedule-visit':
      page = visitForm(visit());
      break;
    case '/visit-details':
      page = VisitDetailsScreen(visit: visit());
      break;
    case '/check-in':
      page = CheckInScreen(visit: visit());
      break;
    case '/check-in-error':
      page = CheckInScreen(visit: visit(), mode: 'error');
      break;
    case '/check-in-far':
      page = CheckInScreen(visit: visit(), mode: 'far');
      break;
    case '/active-visit':
      page = ActiveVisitScreen(visit: visit());
      break;
    case '/visit-notes':
      page = VisitNotesScreen(visit: visit());
      break;
    case '/visit-checklist':
      page = VisitChecklistScreen(visit: visit());
      break;
    case '/signature':
      page = SignatureScreen(visit: visit());
      break;
    case '/visit-summary':
      page = VisitSummaryScreen(visit: visit());
      break;
    case '/nearby-leads':
      page = const NearbyScreen();
      break;
    case '/plan-route':
    case '/todays-route':
      page = const NearbyScreen(routeMode: true);
      break;
    case '/tasks':
      page = const TasksScreen();
      break;
    case '/empty-tasks':
      page = const TasksScreen(empty: true);
      break;
    case '/new-task':
      page = taskForm(null);
      break;
    case '/edit-task':
      page = taskForm(task());
      break;
    case '/task-details':
      page = TaskDetailsScreen(task: task());
      break;
    case '/task-completed':
      page = CompletionScreen(title: 'Task Completed!', subtitle: task().title);
      break;
    case '/profile':
      page = const ProfileScreen();
      break;
    case '/edit-profile':
      page = profileForm();
      break;
    case '/settings':
      page = const SettingsScreen();
      break;
    case '/permissions':
      page = const SettingsScreen(permissions: true);
      break;
    case '/notification-settings':
      page = const SettingsScreen(notifications: true);
      break;
    case '/change-password':
      page = const ChangePasswordScreen();
      break;
    case '/reports':
      page = const ReportsScreen();
      break;
    case '/targets':
      page = const ReportsScreen(targets: true);
      break;
    case '/visit-history':
      page = const HistoryScreen();
      break;
    case '/offline-data':
      page = const OfflineDataScreen();
      break;
    case '/help':
      page = const HelpScreen();
      break;
    case '/security':
      page = const SecurityScreen();
      break;
    case '/photos':
      page = const PhotoGalleryScreen();
      break;
    case '/camera':
      page = const CameraPreviewScreen();
      break;
    case '/voice-note':
      page = VoiceNoteScreen(visit: visit());
      break;
    case '/day-complete':
      page = const DayCompleteScreen();
      break;
    case '/about':
      page = Builder(
        builder: (context) => CrmPage(
          title: 'About',
          children: [
            gap(40),
            avatar('LP', radius: 40),
            gap(24),
            Center(child: strong('CRM Pro Field Sales', 24)),
            gap(12),
            Center(child: muted('Your field. Your leads. Your wins.')),
            gap(24),
            const Panel(
              child: Text(
                'v1.0.0\nLocal UI preview based on the supplied CRM mobile design.',
              ),
            ),
            button('Design Screen Index', () => openScreenIndex(context)),
          ],
        ),
      );
      break;
    case '/screen-index':
      page = Builder(builder: screenIndex);
      break;
    default:
      if ([
        'offline',
        'syncing',
        'server-error',
        'session-expired',
        'access-restricted',
        'not-found',
        'rate-limit',
        'suspended',
        'subscription-expired',
        'maintenance',
      ].contains(settings.name?.replaceFirst('/', '')))
        page = SystemStateScreen(kind: settings.name!.substring(1));
  }
  return page == null
      ? null
      : MaterialPageRoute(settings: settings, builder: (_) => page!);
}

/// A development-only route browser makes empty and error states reviewable.
Widget screenIndex(BuildContext context) => CrmPage(
  title: 'Design Screen Index',
  children: [
    for (final group in <String, List<String>>{
      'Authentication': [
        'splash',
        'sign-in',
        'sign-up',
        'verify-email',
        'forgot-password',
        'otp-verification',
        'reset-password',
        'password-reset-success',
        'biometric-login',
        'biometric-fail',
        'logout-confirmation',
      ],
      'Onboarding': [
        'onboarding-welcome',
        'onboarding-location',
        'onboarding-camera',
        'onboarding-microphone',
        'onboarding-notifications',
        'onboarding-offline-setup',
        'onboarding-complete',
        'onboarding-skip-confirmation',
        'app-intro-walkthrough',
        'intro-slide-two',
        'intro-slide-three',
      ],
      'Dashboard': ['dashboard', 'notifications', 'empty-notifications'],
      'Accounts': [
        'leads',
        'empty-leads',
        'nearby-leads',
        'new-lead',
        'lead-details',
        'edit-lead',
        'filter-leads',
        'log-call',
        'convert-customer',
        'customers',
        'empty-customers',
        'customer-details',
        'add-note',
        'activity',
      ],
      'Deals': [
        'pipeline',
        'empty-deals',
        'new-deal',
        'deal-details',
        'update-deal',
        'deal-won',
        'deal-lost',
      ],
      'Visits': [
        'visits',
        'empty-visits',
        'schedule-visit',
        'reschedule-visit',
        'visit-details',
        'plan-route',
        'todays-route',
        'check-in',
        'check-in-error',
        'check-in-far',
        'active-visit',
        'visit-notes',
        'visit-checklist',
        'signature',
        'visit-summary',
      ],
      'Tasks': [
        'tasks',
        'empty-tasks',
        'new-task',
        'task-details',
        'edit-task',
        'task-completed',
      ],
      'Profile & Reports': [
        'profile',
        'edit-profile',
        'settings',
        'change-password',
        'notification-settings',
        'security',
        'permissions',
        'reports',
        'targets',
        'visit-history',
        'offline-data',
        'help',
        'day-complete',
        'photos',
        'camera',
        'voice-note',
      ],
      'System States': [
        'offline',
        'syncing',
        'server-error',
        'session-expired',
        'access-restricted',
        'not-found',
        'rate-limit',
        'suspended',
        'subscription-expired',
        'maintenance',
      ],
    }.entries) ...[
      heading(group.key),
      for (final r in group.value)
        linkRow(
          r.replaceAll('-', ' '),
          Icons.phone_android,
          () => open(context, '/$r'),
        ),
    ],
  ],
);
// The index is opened from an explicit widget route, not a global navigator.
void openScreenIndex(BuildContext? context) {
  if (context != null)
    Navigator.push(context, MaterialPageRoute(builder: screenIndex));
}
