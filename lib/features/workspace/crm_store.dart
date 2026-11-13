import 'package:flutter/material.dart';

/// Local demo data. All mutations are shared across routes for this app session.
/// This is deliberately separate from device permissions and server services.
class CrmStore extends ChangeNotifier {
  static final instance = CrmStore();
  final List<Account> leads = [
    Account(
      'Acme Corp',
      'John Doe',
      role: 'CTO',
      score: 94,
      stage: 'Qualified',
      area: 'Nariman Point, South Mumbai',
      distance: 0.8,
    ),
    Account(
      'TechVista Ltd',
      'Priya Sharma',
      role: 'HR Director',
      score: 76,
      stage: 'Contacted',
      area: 'Lower Parel, Mumbai',
      distance: 1.2,
    ),
    Account(
      'DataFlow Systems',
      'Karan Malhotra',
      role: 'MD',
      score: 45,
      stage: 'New',
      area: 'Andheri East, Mumbai',
      distance: 2.5,
    ),
  ];
  final List<Account> customers = [
    Account('Acme Corp', 'John Doe', role: 'CTO', stage: 'Healthy'),
    Account('TechVista Ltd', 'Priya Sharma', stage: 'At Risk'),
    Account('DataFlow Systems', 'Karan Malhotra', stage: 'Healthy'),
    Account('Apex Retail', 'Rahul Patel', stage: 'Critical'),
  ];
  final List<Deal> deals = [
    Deal('Alpha CRM Migration', 'Alpha Tech', 45000, 'Qualified'),
    Deal('Sales Storage Hub', 'Acme Corp', 75000, 'Qualified'),
    Deal(
      'TechVista Enterprise Plan',
      'TechVista Solutions',
      125000,
      'Proposal',
    ),
    Deal('Quantum Loyalty Pack', 'Quantum Retail', 76000, 'Proposal'),
  ];
  final List<Visit> visits = [
    Visit(
      'Acme Corp',
      'John Doe',
      '10:00 AM',
      'First Meeting',
      status: 'Completed',
    ),
    Visit(
      'TechVista Solutions',
      'Priya Sharma',
      '11:30 AM',
      'Follow-up',
      status: 'In Progress',
    ),
    Visit('DataFlow Inc', 'Karan Malhotra', '02:00 PM', 'Demo'),
  ];
  final List<CrmTask> tasks = [
    CrmTask(
      'Follow up with Acme Corp',
      'Acme Corp',
      source: 'AI Suggested',
      overdue: true,
    ),
    CrmTask(
      'Send proposal to TechVista',
      'TechVista Ltd',
      source: 'Manager Assigned',
      overdue: true,
    ),
    CrmTask('Schedule demo for DataFlow', 'DataFlow Systems'),
    CrmTask(
      'Log survey response details',
      'Apex Enterprises',
      source: 'System',
    ),
  ];
  final Map<String, List<String>> accountNotes = {
    'Acme Corp': [
      'Client inquired about multi-year SLAs. Need to align with enterprise legal template.',
    ],
    'TechVista Solutions': [
      'Demonstrated the new field mapping dashboard. HR director loved the automatic audit log trail.',
    ],
  };
  List<String> notesFor(String company) => accountNotes[company] ?? const [];
  void addNote(String company, String note) =>
      update(() => accountNotes.putIfAbsent(company, () => []).insert(0, note));
  final Map<String, bool> preferences = {};
  String name = 'Arjun Mehta',
      email = 'arjun@acme.com',
      phone = '+91 99876 54321';
  void update(VoidCallback mutation) {
    mutation();
    notifyListeners();
  }
}

class Account {
  Account(
    this.company,
    this.contact, {
    this.role = 'CTO',
    this.score = 85,
    this.stage = 'New',
    this.area = 'South Mumbai',
    this.distance = 0.8,
    this.phone = '+91 98765 43210',
    this.email = 'john.doe@acme.com',
    this.notes = '',
  });
  String company, contact, role, stage, area, phone, email, notes;
  int score;
  double distance;
  bool flagged = false;
  String source = 'Referral',
      priority = 'High',
      customerType = 'Enterprise',
      owner = 'Arjun Mehta',
      territory = 'South Mumbai';
  String get initials =>
      company.split(' ').take(2).map((s) => s.isEmpty ? '' : s[0]).join();
}

class Deal {
  Deal(this.title, this.company, this.value, this.stage);
  String title, company, stage;
  double value;
  DateTime? closeDate;
  String probability = '75', products = '', notes = '';
}

class Visit {
  Visit(
    this.company,
    this.contact,
    this.time,
    this.type, {
    this.status = 'Scheduled',
    DateTime? date,
    this.purpose = '',
  }) : date = date ?? DateTime.now();
  String company, contact, time, type, status, purpose;
  DateTime date;
  final List<bool> checklist = List.filled(8, false);
  final List<Offset?> signature = [];
  String outcome = 'Positive — Deal progressing', summary = '';
  String duration = '1 hr';
}

class CrmTask {
  CrmTask(
    this.title,
    this.company, {
    this.source = 'Self-Created',
    this.overdue = false,
    this.priority = 'High',
    this.description = '',
    DateTime? due,
  }) : due = due ?? DateTime.now().add(const Duration(hours: 3));
  String title, company, source, priority, description;
  DateTime due;
  bool overdue, completed = false;
  String assignee = 'Arjun Mehta', type = 'Follow-up';
  final List<bool> checklist = List.filled(3, false);
}
