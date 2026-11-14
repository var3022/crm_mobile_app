import 'dart:async';
import 'package:flutter/material.dart';
import 'crm_models.dart';
import 'crm_storage.dart';
import 'crm_storage_adapter.dart';

export 'crm_models.dart';

/// Central Reactive Store for the CRM workspace.
/// Coordinates in-memory state, relational lookup integrity,
/// persistent timer across navigation, duplicate checks, merge, and storage serialization.
class CrmStore extends ChangeNotifier {
  CrmStore({StorageAdapter? storageAdapter})
    : _storage = CrmStorage(adapter: storageAdapter) {
    _seedDefaultData();
    _hydrationFuture = _loadFromStorage();
  }

  static CrmStore _instance = CrmStore();
  static CrmStore get instance => _instance;
  static set instance(CrmStore store) => _instance = store;
  static void setInstanceForTesting(CrmStore store) => _instance = store;
  final CrmStorage _storage;
  late final Future<void> _hydrationFuture;
  bool _isHydrated = false;
  bool _isDisposed = false;
  String? lastStorageError;
  DateTime? lastStorageErrorTime;
  bool get isHydrated => _isHydrated;
  Future<void> ensureHydrated() => _hydrationFuture;

  /// Asynchronously executes a mutation after guaranteeing storage hydration has finished.
  /// Executes the mutation exactly once against hydrated records, notifies listeners, and persists.
  Future<void> mutate(FutureOr<void> Function() mutation) => update(mutation);

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  final List<Account> _leads = [];
  final List<Account> _customers = [];
  final List<Deal> _deals = [];
  final List<Visit> _visits = [];
  final List<CrmTask> _tasks = [];
  final List<CrmNote> _notes = [];
  final List<CrmActivity> _activities = [];
  final List<PhotoRecord> _photos = [];
  final List<VoiceNoteRecord> _voiceNotes = [];
  final List<String> _recentSearches = [
    'TechVista Solutions',
    'Enterprise Cloud Deals',
    'Lower Parel clients',
    'Acme Corp',
  ];

  final Map<String, bool> preferences = {};
  UserProfile userProfile = UserProfile(
    name: 'Arjun Mehta',
    email: 'arjun@acme.com',
    phone: '+91 99876 54321',
    designation: 'Field Sales Executive',
    territory: 'South Mumbai',
    manager: 'Rajesh Singhania',
  );
  AppSettings appSettings = AppSettings();

  // Active visit persistent timer
  String? activeVisitId;
  DateTime? activeVisitStart;

  // Public getters
  List<Account> get leads => _leads;
  List<Account> get customers => _customers;
  List<Deal> get deals => _deals;
  List<Visit> get visits => _visits;
  List<CrmTask> get tasks => _tasks;
  List<CrmNote> get notes => _notes;
  List<CrmActivity> get activities => _activities;
  List<PhotoRecord> get photos => _photos;
  List<VoiceNoteRecord> get voiceNotes => _voiceNotes;
  List<String> get recentSearches => _recentSearches;

  // Backward compatible user getters & setters
  String get name => userProfile.name;
  set name(String val) => userProfile.name = val;
  String get email => userProfile.email;
  set email(String val) => userProfile.email = val;
  String get phone => userProfile.phone;
  set phone(String val) => userProfile.phone = val;

  // Backward compatible note dictionary
  final Map<String, List<String>> accountNotes = {};

  List<String> notesFor(String company) {
    final direct = accountNotes[company] ?? [];
    final fromNotes = _notes
        .where((n) => n.company.toLowerCase() == company.toLowerCase())
        .map((n) => n.body)
        .toList();
    final combined = <String>{...direct, ...fromNotes}.toList();
    return combined;
  }

  Future<void> addNote(String company, String note) async {
    if (!_isHydrated) {
      await ensureHydrated();
    }
    accountNotes.putIfAbsent(company, () => []).insert(0, note);
    _notes.insert(
      0,
      CrmNote(
        companyId: company,
        company: company,
        title: 'Meeting Takeaway',
        body: note,
        category: 'Meeting',
      ),
    );
    _activities.insert(
      0,
      CrmActivity(
        companyId: company,
        company: company,
        type: 'Note',
        title: 'Note Added',
        description: note,
      ),
    );
    notifyListeners();
    await _saveToStorage();
  }

  /// Executes a mutation after guaranteeing storage hydration has finished.
  /// Executes the mutation exactly once against hydrated records, notifies listeners, and persists.
  Future<void> update(FutureOr<void> Function() mutation) {
    if (!_isHydrated) {
      return ensureHydrated().then((_) async {
        await mutation();
        notifyListeners();
        await _saveToStorage();
      });
    }
    final res = mutation();
    notifyListeners();
    if (res is Future) {
      return res.then((_) => _saveToStorage());
    }
    return _saveToStorage();
  }

  /// Updates a lead by ID after ensuring hydration.
  Future<void> updateLead(String id, void Function(Account lead) updateFn) =>
      update(() {
        final index = _leads.indexWhere((l) => l.id == id);
        if (index != -1) updateFn(_leads[index]);
      });

  /// Deletes a lead by ID after ensuring hydration.
  Future<void> deleteLead(String id) => update(() {
    _leads.removeWhere((l) => l.id == id);
  });

  /// Updates a task by ID after ensuring hydration.
  Future<void> updateTask(String id, void Function(CrmTask task) updateFn) =>
      update(() {
        final index = _tasks.indexWhere((t) => t.id == id);
        if (index != -1) updateFn(_tasks[index]);
      });

  /// Toggles a task completion status by ID after ensuring hydration.
  Future<void> toggleTask(String id) => update(() {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index].completed = !_tasks[index].completed;
    }
  });

  /// Deletes a task by ID after ensuring hydration.
  Future<void> deleteTask(String id) => update(() {
    _tasks.removeWhere((t) => t.id == id);
  });

  /// Deletes a deal by ID after ensuring hydration.
  Future<void> deleteDeal(String id) => update(() {
    _deals.removeWhere((d) => d.id == id);
  });

  /// Creates a deal ensuring unique ID after hydration.
  Future<void> createDeal(Deal deal) => update(() {
    _deals.removeWhere((d) => d.id == deal.id);
    _deals.insert(0, deal);
  });

  /// Creates a visit ensuring unique ID after hydration.
  Future<void> createVisit(Visit visit) => update(() {
    _visits.removeWhere((v) => v.id == visit.id);
    _visits.insert(0, visit);
  });

  /// Deletes a visit by ID after ensuring hydration.
  Future<void> deleteVisit(String id) => update(() {
    _visits.removeWhere((v) => v.id == id);
  });

  /// Creates a task ensuring unique ID after hydration.
  Future<void> createTask(CrmTask task) => update(() {
    _tasks.removeWhere((t) => t.id == task.id);
    _tasks.insert(0, task);
  });

  /// Adds a photo record after ensuring hydration.
  Future<void> addPhoto(PhotoRecord photo) => update(() {
    _photos.removeWhere((p) => p.id == photo.id);
    _photos.insert(0, photo);
  });

  /// Deletes a photo by ID after ensuring hydration.
  Future<void> deletePhoto(String id) => update(() {
    _photos.removeWhere((p) => p.id == id);
  });

  /// Deletes multiple photos by ID after ensuring hydration.
  Future<void> deletePhotos(Iterable<String> ids) => update(() {
    final set = ids.toSet();
    _photos.removeWhere((p) => set.contains(p.id));
  });

  /// Adds a voice note record after ensuring hydration.
  Future<void> addVoiceNote(VoiceNoteRecord note) => update(() {
    _voiceNotes.removeWhere((v) => v.id == note.id);
    _voiceNotes.insert(0, note);
  });

  /// Deletes a voice note by ID after ensuring hydration.
  Future<void> deleteVoiceNote(String id) => update(() {
    _voiceNotes.removeWhere((v) => v.id == id);
  });

  /// Adds a recent search term after ensuring hydration.
  Future<void> addRecentSearch(String term) => update(() {
    if (term.isNotEmpty && !_recentSearches.contains(term)) {
      _recentSearches.insert(0, term);
      if (_recentSearches.length > 8) _recentSearches.removeLast();
    }
  });

  /// Removes a recent search term after ensuring hydration.
  Future<void> removeRecentSearch(String term) => update(() {
    _recentSearches.remove(term);
  });

  /// Clears recent searches after ensuring hydration.
  Future<void> clearRecentSearches() => update(() {
    _recentSearches.clear();
  });

  /// Updates profile fields after ensuring hydration.
  Future<void> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? designation,
    String? territory,
    String? reportingManager,
  }) => update(() {
    if (name != null) userProfile.name = name;
    if (email != null) userProfile.email = email;
    if (phone != null) userProfile.phone = phone;
    if (designation != null) userProfile.designation = designation;
    if (territory != null) userProfile.territory = territory;
    if (reportingManager != null) {
      userProfile.reportingManager = reportingManager;
    }
  });

  /// Deletes a note by ID after ensuring hydration.
  Future<void> deleteNoteById(String id) => update(() {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index != -1) {
      final n = _notes.removeAt(index);
      accountNotes[n.company]?.remove(n.body);
    }
  });

  /// Deletes a note by company and index after ensuring hydration.
  Future<void> deleteNote(String company, int index) => update(() {
    final list = accountNotes[company];
    if (list != null && index >= 0 && index < list.length) {
      final text = list.removeAt(index);
      _notes.removeWhere(
        (n) =>
            n.company.toLowerCase() == company.toLowerCase() && n.body == text,
      );
    }
  });

  /// Creates a lead ensuring unique ID after hydration.
  Future<void> createLead(Account lead) => update(() {
    _leads.removeWhere((l) => l.id == lead.id);
    _leads.insert(0, lead);
    _activities.insert(
      0,
      CrmActivity(
        companyId: lead.id,
        company: lead.company,
        type: 'Lead',
        title: 'Lead Created',
        description: 'Added ${lead.company} to active leads',
      ),
    );
  });

  // Active Visit Tracking & Timer
  Visit? get activeVisit {
    if (activeVisitId == null) {
      return _visits.cast<Visit?>().firstWhere(
        (v) => v?.status == 'In Progress',
        orElse: () => null,
      );
    }
    return _visits.cast<Visit?>().firstWhere(
      (v) => v?.id == activeVisitId,
      orElse: () => _visits.cast<Visit?>().firstWhere(
        (v) => v?.status == 'In Progress',
        orElse: () => null,
      ),
    );
  }

  int get activeVisitElapsedSeconds {
    final start = activeVisitStart ?? activeVisit?.startedAt;
    if (start == null) return 45 * 60; // fallback to 45m
    final diff = DateTime.now().difference(start).inSeconds;
    return diff > 0 ? diff : 0;
  }

  Future<void> startVisit(Visit visit) async {
    if (!_isHydrated) {
      await ensureHydrated();
    }
    final target = _visits.firstWhere(
      (v) => v.id == visit.id,
      orElse: () => visit,
    );
    target.status = 'In Progress';
    target.startedAt = DateTime.now();
    visit.status = target.status;
    visit.startedAt = target.startedAt;
    activeVisitId = target.id;
    activeVisitStart = target.startedAt;
    _activities.insert(
      0,
      CrmActivity(
        companyId: target.companyId,
        company: target.company,
        type: 'Visit',
        title: 'Checked in for Visit',
        description: 'Verified check-in at ${target.locationAddress}',
      ),
    );
    notifyListeners();
    await _saveToStorage();
  }

  Future<void> finishActiveVisit(
    Visit visit, {
    String? outcome,
    String? summary,
    String? nextSteps,
    DateTime? followUpDate,
  }) async {
    if (!_isHydrated) {
      await ensureHydrated();
    }
    final target = _visits.firstWhere(
      (v) => v.id == visit.id,
      orElse: () => visit,
    );
    final elapsedSec = activeVisitElapsedSeconds;
    final mins = (elapsedSec / 60).round();
    target.status = 'Completed';
    target.duration = mins < 60 ? '$mins min' : '${mins ~/ 60}h ${mins % 60}m';
    target.durationMinutes = mins;
    if (outcome != null) target.outcome = outcome;
    if (summary != null) target.summary = summary;
    if (nextSteps != null) target.nextSteps = nextSteps;
    if (followUpDate != null) target.followUpDate = followUpDate;

    visit.status = target.status;
    visit.duration = target.duration;
    visit.durationMinutes = target.durationMinutes;
    if (outcome != null) visit.outcome = outcome;
    if (summary != null) visit.summary = summary;
    if (nextSteps != null) visit.nextSteps = nextSteps;
    if (followUpDate != null) visit.followUpDate = followUpDate;

    if (activeVisitId == target.id || activeVisitId == visit.id) {
      activeVisitId = null;
      activeVisitStart = null;
    }

    _activities.insert(
      0,
      CrmActivity(
        companyId: target.companyId,
        company: target.company,
        type: 'Visit',
        title: 'Visit Completed',
        description: '${target.outcome} · Duration: ${target.duration}',
      ),
    );

    notifyListeners();
    await _saveToStorage();
  }

  // Duplicate Lead Detection
  List<Account> findDuplicateLeads({
    required String company,
    String? email,
    String? phone,
  }) {
    final cleanComp = company.trim().toLowerCase();
    final cleanEmail = (email ?? '').trim().toLowerCase();
    final cleanPhone = (phone ?? '').replaceAll(RegExp(r'\D'), '');

    return [..._leads, ..._customers].where((acc) {
      final accComp = acc.company.trim().toLowerCase();
      final accEmail = acc.email.trim().toLowerCase();
      final accPhone = acc.phone.replaceAll(RegExp(r'\D'), '');

      final compMatch =
          accComp.isNotEmpty &&
          (accComp == cleanComp ||
              accComp.contains(cleanComp) ||
              cleanComp.contains(accComp));
      final emailMatch = cleanEmail.isNotEmpty && accEmail == cleanEmail;
      final phoneMatch =
          cleanPhone.length > 6 &&
          accPhone.length > 6 &&
          accPhone.endsWith(cleanPhone.substring(cleanPhone.length - 7));

      return compMatch || emailMatch || phoneMatch;
    }).toList();
  }

  // Merge Duplicate Account into Primary
  Future<void> mergeAccounts(Account primary, Account duplicate) async {
    if (!_isHydrated) {
      await ensureHydrated();
    }
    if (primary.id == duplicate.id) return;

    final targetPrimary = [
      ..._leads,
      ..._customers,
    ].firstWhere((a) => a.id == primary.id, orElse: () => primary);

    final targetDuplicate = [
      ..._leads,
      ..._customers,
    ].firstWhere((a) => a.id == duplicate.id, orElse: () => duplicate);

    final dupPhone = duplicate.phone.isNotEmpty
        ? duplicate.phone
        : targetDuplicate.phone;
    final dupEmail = duplicate.email.isNotEmpty
        ? duplicate.email
        : targetDuplicate.email;
    final dupNotes = duplicate.notes.isNotEmpty
        ? duplicate.notes
        : targetDuplicate.notes;

    // Merge missing fields
    if (targetPrimary.phone.isEmpty && dupPhone.isNotEmpty) {
      targetPrimary.phone = dupPhone;
    }
    if (targetPrimary.email.isEmpty && dupEmail.isNotEmpty) {
      targetPrimary.email = dupEmail;
    }
    if (targetPrimary.notes.isEmpty && dupNotes.isNotEmpty) {
      targetPrimary.notes = dupNotes;
    } else if (dupNotes.isNotEmpty && !targetPrimary.notes.contains(dupNotes)) {
      targetPrimary.notes = '${targetPrimary.notes}\n[Merged Note]: $dupNotes';
    }
    primary.phone = targetPrimary.phone;
    primary.email = targetPrimary.email;
    primary.notes = targetPrimary.notes;

    // Re-link deals, visits, tasks, notes, activities
    for (final d in _deals.where(
      (d) => d.companyId == duplicate.id || d.company == duplicate.company,
    )) {
      d.companyId = targetPrimary.id;
      d.company = targetPrimary.company;
    }
    for (final v in _visits.where(
      (v) => v.companyId == duplicate.id || v.company == duplicate.company,
    )) {
      v.companyId = targetPrimary.id;
      v.company = targetPrimary.company;
    }
    for (final t in _tasks.where(
      (t) => t.companyId == duplicate.id || t.company == duplicate.company,
    )) {
      t.companyId = targetPrimary.id;
      t.company = targetPrimary.company;
    }
    for (final n in _notes.where(
      (n) => n.companyId == duplicate.id || n.company == duplicate.company,
    )) {
      n.companyId = targetPrimary.id;
      n.company = targetPrimary.company;
    }
    for (final a in _activities.where(
      (a) => a.companyId == duplicate.id || a.company == duplicate.company,
    )) {
      a.companyId = targetPrimary.id;
      a.company = targetPrimary.company;
    }

    _leads.removeWhere((a) => a.id == duplicate.id);
    _customers.removeWhere((a) => a.id == duplicate.id);

    _activities.insert(
      0,
      CrmActivity(
        companyId: targetPrimary.id,
        company: targetPrimary.company,
        type: 'System',
        title: 'Account Merged',
        description:
            'Merged duplicate record ${duplicate.company} (${duplicate.contact}) into ${targetPrimary.company}',
      ),
    );

    notifyListeners();
    await _saveToStorage();
  }

  // Convert Lead to Customer
  Future<void> convertToCustomer(
    Account lead, {
    Deal? welcomeDeal,
    String? customerType,
  }) async {
    if (!_isHydrated) {
      await ensureHydrated();
    }
    final targetLead = [
      ..._leads,
      ..._customers,
    ].firstWhere((a) => a.id == lead.id, orElse: () => lead);

    targetLead.isCustomer = true;
    if (customerType != null) targetLead.customerType = customerType;
    targetLead.stage = 'Healthy';

    lead.isCustomer = targetLead.isCustomer;
    lead.customerType = targetLead.customerType;
    lead.stage = targetLead.stage;

    if (!_customers.any((c) => c.id == targetLead.id)) {
      _customers.insert(0, targetLead);
    }
    _leads.removeWhere((l) => l.id == targetLead.id);

    if (welcomeDeal != null) {
      welcomeDeal.companyId = targetLead.id;
      welcomeDeal.company = targetLead.company;
      _deals.insert(0, welcomeDeal);
    }

    _activities.insert(
      0,
      CrmActivity(
        companyId: targetLead.id,
        company: targetLead.company,
        type: 'Deal',
        title: 'Converted to Customer 🎉',
        description:
            'Lead converted with ${targetLead.customerType} tier.${welcomeDeal != null ? " Welcome deal created: \$${welcomeDeal.value.toStringAsFixed(0)}" : ""}',
      ),
    );

    notifyListeners();
    await _saveToStorage();
  }

  // Storage breakdown & offline cleanup
  Map<String, dynamic> calculateStorageBreakdown() {
    final accCount = _leads.length + _customers.length;
    final dealCount = _deals.length;
    final visCount = _visits.length;
    final photoCount = _photos.length;
    final audioCount = _voiceNotes.length;

    // Approximate size in MB
    final accSize = accCount * 0.004;
    final photoSize = photoCount * 1.85;
    final audioSize = audioCount * 1.2;
    final dbSize =
        (dealCount + visCount + _tasks.length + _notes.length) * 0.002;
    final total = accSize + photoSize + audioSize + dbSize;

    return {
      'totalMb': total > 0 ? total : 48.6,
      'accountsMb': accSize > 0 ? accSize : 3.4,
      'photosMb': photoSize > 0 ? photoSize : 32.1,
      'audioMb': audioSize > 0 ? audioSize : 11.2,
      'dbMb': dbSize > 0 ? dbSize : 1.9,
      'accountsCount': accCount,
      'photosCount': photoCount,
      'audioCount': audioCount,
      'visitsCount': visCount,
      'storageLimitMb': 512.0,
    };
  }

  Future<void> clearOldData({int olderThanDays = 30}) async {
    if (!_isHydrated) {
      await ensureHydrated();
    }
    final threshold = DateTime.now().subtract(Duration(days: olderThanDays));
    _visits.removeWhere(
      (v) => v.status == 'Completed' && v.date.isBefore(threshold),
    );
    _activities.removeWhere((a) => a.timestamp.isBefore(threshold));
    _tasks.removeWhere((t) => t.completed && t.due.isBefore(threshold));
    notifyListeners();
    await _saveToStorage();
  }

  Future<bool> syncNow({bool hasServerAcknowledgement = false}) async {
    if (!_isHydrated) {
      await ensureHydrated();
    }
    appSettings.lastSyncTime = DateTime.now();
    if (hasServerAcknowledgement) {
      appSettings.pendingSyncItems = 0;
    }
    notifyListeners();
    await _saveToStorage();
    return hasServerAcknowledgement;
  }

  // Persistence helpers
  Future<void> _saveToStorage() async {
    if (!_isHydrated) {
      await _hydrationFuture;
    }
    try {
      final uniqueLeads = <Account>[];
      final seenLeads = <String>{};
      for (final l in _leads) {
        if (seenLeads.add(l.id)) uniqueLeads.add(l);
      }
      final uniqueCustomers = <Account>[];
      final seenCustomers = <String>{};
      for (final c in _customers) {
        if (seenCustomers.add(c.id)) uniqueCustomers.add(c);
      }
      final uniqueDeals = <Deal>[];
      final seenDeals = <String>{};
      for (final d in _deals) {
        if (seenDeals.add(d.id)) uniqueDeals.add(d);
      }
      final uniqueVisits = <Visit>[];
      final seenVisits = <String>{};
      for (final v in _visits) {
        if (seenVisits.add(v.id)) uniqueVisits.add(v);
      }
      final uniqueTasks = <CrmTask>[];
      final seenTasks = <String>{};
      for (final t in _tasks) {
        if (seenTasks.add(t.id)) uniqueTasks.add(t);
      }
      final uniqueNotes = <CrmNote>[];
      final seenNotes = <String>{};
      for (final n in _notes) {
        if (seenNotes.add(n.id)) uniqueNotes.add(n);
      }
      final uniqueActivities = <CrmActivity>[];
      final seenActivities = <String>{};
      for (final a in _activities) {
        if (seenActivities.add(a.id)) uniqueActivities.add(a);
      }
      final uniquePhotos = <PhotoRecord>[];
      final seenPhotos = <String>{};
      for (final p in _photos) {
        if (seenPhotos.add(p.id)) uniquePhotos.add(p);
      }
      final uniqueVoiceNotes = <VoiceNoteRecord>[];
      final seenVoiceNotes = <String>{};
      for (final vn in _voiceNotes) {
        if (seenVoiceNotes.add(vn.id)) uniqueVoiceNotes.add(vn);
      }

      await _storage.saveDatabase(
        leads: uniqueLeads,
        customers: uniqueCustomers,
        deals: uniqueDeals,
        visits: uniqueVisits,
        tasks: uniqueTasks,
        notes: uniqueNotes,
        activities: uniqueActivities,
        photos: uniquePhotos,
        voiceNotes: uniqueVoiceNotes,
        profile: userProfile,
        settings: appSettings,
        recentSearches: _recentSearches,
        activeVisitStart: activeVisitStart,
        activeVisitId: activeVisitId,
      );
      lastStorageError = null;
    } catch (e) {
      lastStorageError = e.toString();
      lastStorageErrorTime = DateTime.now();
      debugPrint('[CrmStore Storage Error] $lastStorageError');
      rethrow;
    }
  }

  void _reconcileAccounts(List<Account> list, List<dynamic>? storedJson) {
    if (storedJson == null) return;
    final map = <String, Account>{for (final a in list) a.id: a};
    final seenIds = <String>{};
    final reconciled = <Account>[];

    for (final raw in storedJson) {
      if (raw is! Map<String, dynamic>) continue;
      final id = raw['id'] as String?;
      if (id != null && !seenIds.add(id)) continue;

      if (id != null && map.containsKey(id)) {
        final existing = map[id]!;
        _updateAccountFields(existing, raw);
        reconciled.add(existing);
      } else {
        reconciled.add(Account.fromJson(raw));
      }
    }

    list.clear();
    list.addAll(reconciled);
  }

  void _reconcileDeals(List<Deal> list, List<dynamic>? storedJson) {
    if (storedJson == null) return;
    final map = <String, Deal>{for (final d in list) d.id: d};
    final seenIds = <String>{};
    final reconciled = <Deal>[];

    for (final raw in storedJson) {
      if (raw is! Map<String, dynamic>) continue;
      final id = raw['id'] as String?;
      if (id != null && !seenIds.add(id)) continue;

      if (id != null && map.containsKey(id)) {
        final existing = map[id]!;
        _updateDealFields(existing, raw);
        reconciled.add(existing);
      } else {
        reconciled.add(Deal.fromJson(raw));
      }
    }

    list.clear();
    list.addAll(reconciled);
  }

  void _reconcileVisits(List<Visit> list, List<dynamic>? storedJson) {
    if (storedJson == null) return;
    final map = <String, Visit>{for (final v in list) v.id: v};
    final seenIds = <String>{};
    final reconciled = <Visit>[];

    for (final raw in storedJson) {
      if (raw is! Map<String, dynamic>) continue;
      final id = raw['id'] as String?;
      if (id != null && !seenIds.add(id)) continue;

      if (id != null && map.containsKey(id)) {
        final existing = map[id]!;
        _updateVisitFields(existing, raw);
        reconciled.add(existing);
      } else {
        reconciled.add(Visit.fromJson(raw));
      }
    }

    list.clear();
    list.addAll(reconciled);
  }

  void _reconcileTasks(List<CrmTask> list, List<dynamic>? storedJson) {
    if (storedJson == null) return;
    final map = <String, CrmTask>{for (final t in list) t.id: t};
    final seenIds = <String>{};
    final reconciled = <CrmTask>[];

    for (final raw in storedJson) {
      if (raw is! Map<String, dynamic>) continue;
      final id = raw['id'] as String?;
      if (id != null && !seenIds.add(id)) continue;

      if (id != null && map.containsKey(id)) {
        final existing = map[id]!;
        _updateTaskFields(existing, raw);
        reconciled.add(existing);
      } else {
        reconciled.add(CrmTask.fromJson(raw));
      }
    }

    list.clear();
    list.addAll(reconciled);
  }

  void _reconcileNotes(List<CrmNote> list, List<dynamic>? storedJson) {
    if (storedJson == null) return;
    final map = <String, CrmNote>{for (final n in list) n.id: n};
    final seenIds = <String>{};
    final reconciled = <CrmNote>[];

    for (final raw in storedJson) {
      if (raw is! Map<String, dynamic>) continue;
      final id = raw['id'] as String?;
      if (id != null && !seenIds.add(id)) continue;

      if (id != null && map.containsKey(id)) {
        final existing = map[id]!;
        _updateNoteFields(existing, raw);
        reconciled.add(existing);
      } else {
        reconciled.add(CrmNote.fromJson(raw));
      }
    }

    list.clear();
    list.addAll(reconciled);
  }

  void _reconcileActivities(List<CrmActivity> list, List<dynamic>? storedJson) {
    if (storedJson == null) return;
    final map = <String, CrmActivity>{for (final a in list) a.id: a};
    final seenIds = <String>{};
    final reconciled = <CrmActivity>[];

    for (final raw in storedJson) {
      if (raw is! Map<String, dynamic>) continue;
      final id = raw['id'] as String?;
      if (id != null && !seenIds.add(id)) continue;

      if (id != null && map.containsKey(id)) {
        reconciled.add(map[id]!);
      } else {
        reconciled.add(CrmActivity.fromJson(raw));
      }
    }

    list.clear();
    list.addAll(reconciled);
  }

  void _reconcilePhotos(List<PhotoRecord> list, List<dynamic>? storedJson) {
    if (storedJson == null) return;
    final map = <String, PhotoRecord>{for (final p in list) p.id: p};
    final seenIds = <String>{};
    final reconciled = <PhotoRecord>[];

    for (final raw in storedJson) {
      if (raw is! Map<String, dynamic>) continue;
      final id = raw['id'] as String?;
      if (id != null && !seenIds.add(id)) continue;

      if (id != null && map.containsKey(id)) {
        reconciled.add(map[id]!);
      } else {
        reconciled.add(PhotoRecord.fromJson(raw));
      }
    }

    list.clear();
    list.addAll(reconciled);
  }

  void _reconcileVoiceNotes(
    List<VoiceNoteRecord> list,
    List<dynamic>? storedJson,
  ) {
    if (storedJson == null) return;
    final map = <String, VoiceNoteRecord>{for (final v in list) v.id: v};
    final seenIds = <String>{};
    final reconciled = <VoiceNoteRecord>[];

    for (final raw in storedJson) {
      if (raw is! Map<String, dynamic>) continue;
      final id = raw['id'] as String?;
      if (id != null && !seenIds.add(id)) continue;

      if (id != null && map.containsKey(id)) {
        reconciled.add(map[id]!);
      } else {
        reconciled.add(VoiceNoteRecord.fromJson(raw));
      }
    }

    list.clear();
    list.addAll(reconciled);
  }

  static void _updateAccountFields(Account target, Map<String, dynamic> j) {
    target.company = j['company'] as String? ?? target.company;
    target.contact = j['contact'] as String? ?? target.contact;
    target.role = j['role'] as String? ?? target.role;
    target.score = (j['score'] as num?)?.toInt() ?? target.score;
    target.stage = j['stage'] as String? ?? target.stage;
    target.area = j['area'] as String? ?? target.area;
    target.distance = (j['distance'] as num?)?.toDouble() ?? target.distance;
    target.phone = j['phone'] as String? ?? target.phone;
    target.email = j['email'] as String? ?? target.email;
    target.notes = j['notes'] as String? ?? target.notes;
    target.industry = j['industry'] as String? ?? target.industry;
    target.companySize = j['companySize'] as String? ?? target.companySize;
    target.source = j['source'] as String? ?? target.source;
    target.priority = j['priority'] as String? ?? target.priority;
    target.customerType = j['customerType'] as String? ?? target.customerType;
    target.owner = j['owner'] as String? ?? target.owner;
    target.territory = j['territory'] as String? ?? target.territory;
    target.verifiedAddress =
        j['verifiedAddress'] as String? ?? target.verifiedAddress;
    target.flagged = j['flagged'] as bool? ?? target.flagged;
    target.isCustomer = j['isCustomer'] as bool? ?? target.isCustomer;
    target.accountValue =
        (j['accountValue'] as num?)?.toDouble() ?? target.accountValue;
    if (j['createdAt'] != null) {
      target.createdAt =
          DateTime.tryParse(j['createdAt'] as String) ?? target.createdAt;
    }
    if (j['lastVisited'] != null) {
      target.lastVisited = DateTime.tryParse(j['lastVisited'] as String);
    }
  }

  static void _updateDealFields(Deal target, Map<String, dynamic> j) {
    target.title = j['title'] as String? ?? target.title;
    target.companyId = j['companyId'] as String? ?? target.companyId;
    target.company = j['company'] as String? ?? target.company;
    target.value = (j['value'] as num?)?.toDouble() ?? target.value;
    target.stage = j['stage'] as String? ?? target.stage;
    if (j['closeDate'] != null) {
      target.closeDate = DateTime.tryParse(j['closeDate'] as String);
    }
    target.probability = j['probability'] as String? ?? target.probability;
    target.products = j['products'] as String? ?? target.products;
    target.notes = j['notes'] as String? ?? target.notes;
    target.owner = j['owner'] as String? ?? target.owner;
    target.competitors = j['competitors'] as String? ?? target.competitors;
    target.decisionMakers =
        j['decisionMakers'] as String? ?? target.decisionMakers;
    target.nextAction = j['nextAction'] as String? ?? target.nextAction;
    target.reasonForLoss =
        j['reasonForLoss'] as String? ?? target.reasonForLoss;
    target.durationDays =
        (j['durationDays'] as num?)?.toInt() ?? target.durationDays;
    if (j['createdAt'] != null) {
      target.createdAt =
          DateTime.tryParse(j['createdAt'] as String) ?? target.createdAt;
    }
  }

  static void _updateTaskFields(CrmTask target, Map<String, dynamic> j) {
    target.title = j['title'] as String? ?? target.title;
    target.companyId = j['companyId'] as String? ?? target.companyId;
    target.company = j['company'] as String? ?? target.company;
    target.dealId = j['dealId'] as String? ?? target.dealId;
    target.dealTitle = j['dealTitle'] as String? ?? target.dealTitle;
    target.source = j['source'] as String? ?? target.source;
    target.priority = j['priority'] as String? ?? target.priority;
    target.description = j['description'] as String? ?? target.description;
    if (j['due'] != null) {
      target.due = DateTime.tryParse(j['due'] as String) ?? target.due;
    }
    target.overdue = j['overdue'] as bool? ?? target.overdue;
    target.completed = j['completed'] as bool? ?? target.completed;
    target.assignee = j['assignee'] as String? ?? target.assignee;
    target.type = j['type'] as String? ?? target.type;
    target.reminderEnabled =
        j['reminderEnabled'] as bool? ?? target.reminderEnabled;
    target.reminderMinutesBefore =
        (j['reminderMinutesBefore'] as num?)?.toInt() ??
        target.reminderMinutesBefore;
    if (j['checklist'] is List) {
      target.checklist = (j['checklist'] as List)
          .map((e) => e == true)
          .toList();
    }
    if (j['checklistLabels'] is List) {
      target.checklistLabels = (j['checklistLabels'] as List)
          .map((e) => e.toString())
          .toList();
    }
  }

  static void _updateVisitFields(Visit target, Map<String, dynamic> j) {
    target.company = j['company'] as String? ?? target.company;
    target.contact = j['contact'] as String? ?? target.contact;
    target.time = j['time'] as String? ?? target.time;
    target.type = j['type'] as String? ?? target.type;
    target.companyId = j['companyId'] as String? ?? target.companyId;
    target.status = j['status'] as String? ?? target.status;
    if (j['date'] != null) {
      target.date = DateTime.tryParse(j['date'] as String) ?? target.date;
    }
    target.purpose = j['purpose'] as String? ?? target.purpose;
    target.duration = j['duration'] as String? ?? target.duration;
    target.durationMinutes =
        (j['durationMinutes'] as num?)?.toInt() ?? target.durationMinutes;
    target.signerName = j['signerName'] as String? ?? target.signerName;
    target.signerDesignation =
        j['signerDesignation'] as String? ?? target.signerDesignation;
    if (j['signerTimestamp'] != null) {
      target.signerTimestamp =
          DateTime.tryParse(j['signerTimestamp'] as String) ??
          target.signerTimestamp;
    }
    target.outcome = j['outcome'] as String? ?? target.outcome;
    target.summary = j['summary'] as String? ?? target.summary;
    target.nextSteps = j['nextSteps'] as String? ?? target.nextSteps;
    if (j['followUpDate'] != null) {
      target.followUpDate =
          DateTime.tryParse(j['followUpDate'] as String) ?? target.followUpDate;
    }
    target.isLocationVerified =
        j['isLocationVerified'] as bool? ?? target.isLocationVerified;
    target.checkInMode = j['checkInMode'] as String? ?? target.checkInMode;
    target.checkInReason =
        j['checkInReason'] as String? ?? target.checkInReason;
    target.locationAddress =
        j['locationAddress'] as String? ?? target.locationAddress;
    if (j['startedAt'] != null) {
      target.startedAt = DateTime.tryParse(j['startedAt'] as String);
    }
  }

  static void _updateNoteFields(CrmNote target, Map<String, dynamic> j) {
    target.companyId = j['companyId'] as String? ?? target.companyId;
    target.company = j['company'] as String? ?? target.company;
    target.visitId = j['visitId'] as String? ?? target.visitId;
    target.title = j['title'] as String? ?? target.title;
    target.body =
        j['body'] as String? ?? j['content'] as String? ?? target.body;
    target.category = j['category'] as String? ?? target.category;
    target.isPinned = j['isPinned'] as bool? ?? target.isPinned;
    if (j['timestamp'] != null) {
      target.timestamp =
          DateTime.tryParse(j['timestamp'] as String) ?? target.timestamp;
    }
  }

  Future<void> _loadFromStorage() async {
    try {
      final data = await _storage.loadDatabase();

      if (data != null) {
        if (data['leads'] is List) {
          _reconcileAccounts(_leads, data['leads'] as List);
        }
        if (data['customers'] is List) {
          _reconcileAccounts(_customers, data['customers'] as List);
        }
        if (data['deals'] is List) {
          _reconcileDeals(_deals, data['deals'] as List);
        }
        if (data['visits'] is List) {
          _reconcileVisits(_visits, data['visits'] as List);
        }
        if (data['tasks'] is List) {
          _reconcileTasks(_tasks, data['tasks'] as List);
        }
        if (data['notes'] is List) {
          _reconcileNotes(_notes, data['notes'] as List);
          accountNotes.clear();
          for (final n in _notes) {
            final list = accountNotes.putIfAbsent(n.company, () => []);
            if (!list.contains(n.body)) {
              list.add(n.body);
            }
          }
        }
        if (data['activities'] is List) {
          _reconcileActivities(_activities, data['activities'] as List);
        }
        if (data['photos'] is List) {
          _reconcilePhotos(_photos, data['photos'] as List);
        }
        if (data['voiceNotes'] is List) {
          _reconcileVoiceNotes(_voiceNotes, data['voiceNotes'] as List);
        }
        if (data['profile'] is Map) {
          userProfile = UserProfile.fromJson(
            data['profile'] as Map<String, dynamic>,
          );
        }
        if (data['settings'] is Map) {
          appSettings = AppSettings.fromJson(
            data['settings'] as Map<String, dynamic>,
          );
        }
        if (data['recentSearches'] is List) {
          _recentSearches.clear();
          _recentSearches.addAll(
            (data['recentSearches'] as List).cast<String>(),
          );
        }
        if (data['activeVisitId'] != null) {
          activeVisitId = data['activeVisitId'] as String?;
        }
        if (data['activeVisitStart'] != null) {
          activeVisitStart = DateTime.tryParse(
            data['activeVisitStart'] as String,
          );
        }
      }
    } catch (_) {
    } finally {
      _isHydrated = true;
      notifyListeners();
    }
  }

  void _seedDefaultData() {
    _leads.addAll([
      Account(
        'Acme Corp',
        'John Doe',
        id: 'acc_acme_001',
        role: 'CTO',
        score: 94,
        stage: 'Qualified',
        area: 'Nariman Point, South Mumbai',
        distance: 0.8,
        phone: '+91 98765 43210',
        email: 'john.doe@acme.com',
        industry: 'Enterprise Software',
        companySize: '500-1000',
        priority: 'High',
        accountValue: 1850000,
        notes:
            'Inquired regarding enterprise multi-year SLAs and compliance data residency.',
      ),
      Account(
        'TechVista Ltd',
        'Priya Sharma',
        id: 'acc_techvista_002',
        role: 'HR Director',
        score: 88,
        stage: 'Contacted',
        area: 'Lower Parel, Mumbai',
        distance: 1.2,
        phone: '+91 98200 12345',
        email: 'priya.sharma@techvista.io',
        industry: 'Human Resources Tech',
        companySize: '100-500',
        priority: 'High',
        accountValue: 1250000,
        notes:
            'Needs automated field rep timesheet approval and live GPS check-in verification.',
      ),
      Account(
        'DataFlow Systems',
        'Karan Malhotra',
        id: 'acc_dataflow_003',
        role: 'Managing Director',
        score: 45,
        stage: 'New',
        area: 'Andheri East, Mumbai',
        distance: 2.5,
        phone: '+91 98111 88990',
        email: 'karan@dataflowsys.com',
        industry: 'Financial Data Analytics',
        companySize: '50-100',
        priority: 'Medium',
        accountValue: 750000,
        notes:
            'Evaluating cloud sync latency and field mobile offline storage capabilities.',
      ),
      Account(
        'Stellar Logistics',
        'Vikram Rathore',
        id: 'acc_stellar_004',
        role: 'VP Operations',
        score: 62,
        stage: 'Qualified',
        area: 'Bandra Kurla Complex, Mumbai',
        distance: 4.1,
        phone: '+91 99300 77412',
        email: 'v.rathore@stellarlog.in',
        industry: 'Supply Chain & Freight',
        companySize: '1000+',
        priority: 'High',
        accountValue: 3200000,
      ),
      Account(
        'CloudMatrix Corp',
        'Ananya Iyer',
        id: 'acc_cloudmatrix_005',
        role: 'Head of Infrastructure',
        score: 58,
        stage: 'Proposal',
        area: 'Powai, Mumbai',
        distance: 6.3,
        phone: '+91 98450 33211',
        email: 'ananya@cloudmatrix.com',
        industry: 'Cloud Infrastructure',
        companySize: '250-500',
        priority: 'High',
        accountValue: 2400000,
      ),
    ]);

    _customers.addAll([
      Account(
        'Acme Corp',
        'John Doe',
        id: 'acc_acme_cust',
        role: 'CTO',
        stage: 'Healthy',
        area: 'Nariman Point, South Mumbai',
        isCustomer: true,
        accountValue: 1850000,
        customerType: 'Enterprise',
      ),
      Account(
        'TechVista Ltd',
        'Priya Sharma',
        id: 'acc_techvista_cust',
        role: 'HR Director',
        stage: 'At Risk',
        area: 'Lower Parel, Mumbai',
        isCustomer: true,
        accountValue: 1250000,
        customerType: 'Mid-Market',
      ),
      Account(
        'DataFlow Systems',
        'Karan Malhotra',
        id: 'acc_dataflow_cust',
        role: 'MD',
        stage: 'Healthy',
        area: 'Andheri East, Mumbai',
        isCustomer: true,
        accountValue: 750000,
        customerType: 'Growth',
      ),
      Account(
        'Apex Retail',
        'Rahul Patel',
        id: 'acc_apex_cust',
        role: 'Head of Retail Ops',
        stage: 'Critical',
        area: 'Thane West',
        isCustomer: true,
        accountValue: 920000,
        customerType: 'Enterprise',
      ),
    ]);

    _deals.addAll([
      Deal(
        'Alpha CRM Migration',
        'Alpha Tech',
        45000,
        'Qualified',
        id: 'deal_alpha_01',
        probability: '65',
        products: 'Migration Utility, Core SaaS Rep Seats',
        owner: 'Arjun Mehta',
      ),
      Deal(
        'Sales Storage Hub',
        'Acme Corp',
        75000,
        'Qualified',
        id: 'deal_acme_02',
        probability: '85',
        products: 'High-Volume Document Archive, OCR Engine',
        owner: 'Arjun Mehta',
      ),
      Deal(
        'TechVista Enterprise Plan',
        'TechVista Solutions',
        125000,
        'Proposal',
        id: 'deal_techvista_03',
        probability: '75',
        products: '150 Field Agent Seats, Route Optimization Pack',
        owner: 'Arjun Mehta',
      ),
      Deal(
        'Quantum Loyalty Pack',
        'Quantum Retail',
        76000,
        'Proposal',
        id: 'deal_quantum_04',
        probability: '70',
        products: 'Loyalty API Connector, Scanner App',
        owner: 'Arjun Mehta',
      ),
      Deal(
        'Stellar Logistics Fleet Suite',
        'Stellar Logistics',
        185000,
        'Negotiation',
        id: 'deal_stellar_05',
        probability: '90',
        products: 'Full Custom Telematics & CRM Integration',
        owner: 'Arjun Mehta',
      ),
    ]);

    _visits.addAll([
      Visit(
        'Acme Corp',
        'John Doe',
        '10:00 AM',
        'First Meeting',
        id: 'vis_001',
        status: 'Completed',
        duration: '1 hr',
        durationMinutes: 60,
        outcome: 'Positive — Deal progressing',
        summary:
            'Met with John Doe and IT leads. Clarified on-premise cloud gateway security.',
        locationAddress: 'Maker Chambers, Nariman Point, Mumbai',
      ),
      Visit(
        'TechVista Solutions',
        'Priya Sharma',
        '11:30 AM',
        'Follow-up',
        id: 'vis_002',
        status: 'In Progress',
        duration: '45 min',
        durationMinutes: 45,
        startedAt: DateTime.now().subtract(const Duration(minutes: 25)),
        purpose: 'Demonstrate route planner and attendance checklist',
        locationAddress: 'One Indiabulls Centre, Lower Parel, Mumbai',
      ),
      Visit(
        'DataFlow Inc',
        'Karan Malhotra',
        '02:00 PM',
        'Demo',
        id: 'vis_003',
        status: 'Scheduled',
        purpose: 'Deep dive into offline database sync and data exports',
        locationAddress: 'Solitaire Corporate Park, Andheri East, Mumbai',
      ),
      Visit(
        'Apex Global Logistics',
        'Vikram Rathore',
        '04:15 PM',
        'Negotiation',
        id: 'vis_004',
        status: 'Scheduled',
        purpose: 'Final review of enterprise SLA contract and pricing terms',
        locationAddress: 'BKC Tower 3, Bandra Kurla Complex, Mumbai',
      ),
      Visit(
        'Nexus Health Tech',
        'Dr. Sneha Roy',
        '05:30 PM',
        'Contract Signing',
        id: 'vis_005',
        status: 'Scheduled',
        purpose: 'Digital signature collection and onboarding kickoff',
        locationAddress: 'Hiranandani Business Park, Powai, Mumbai',
      ),
      Visit(
        'BlueWave Analytics',
        'Sameer Deshmukh',
        'Tomorrow, 10:30 AM',
        'Discovery Call',
        id: 'vis_006',
        status: 'Scheduled',
        purpose: 'Initial requirements capture for 80 field representatives',
        locationAddress: 'Mindspace Malad West, Mumbai',
      ),
    ]);

    _tasks.addAll([
      CrmTask(
        'Follow up with Acme Corp',
        'Acme Corp',
        id: 'tsk_001',
        source: 'AI Suggested',
        overdue: true,
        priority: 'High',
        description:
            'Send revised multi-year enterprise quote with 12% upfront incentive discount.',
      ),
      CrmTask(
        'Send proposal to TechVista',
        'TechVista Ltd',
        id: 'tsk_002',
        source: 'Manager Assigned',
        overdue: true,
        priority: 'High',
        description:
            'Attach executive deck and ROI projection spreadsheet for 150 licenses.',
      ),
      CrmTask(
        'Schedule demo for DataFlow',
        'DataFlow Systems',
        id: 'tsk_003',
        source: 'Self-Created',
        priority: 'Medium',
        description:
            'Book technical solutions architect for live offline-sync verification demo.',
      ),
      CrmTask(
        'Log survey response details',
        'Apex Enterprises',
        id: 'tsk_004',
        source: 'System',
        priority: 'Low',
        description:
            'Record field survey response data into CRM customer profile notes.',
      ),
    ]);

    _notes.addAll([
      CrmNote(
        companyId: 'acc_acme_001',
        company: 'Acme Corp',
        title: 'Enterprise Security Compliance Review',
        body:
            'Client inquired about multi-year SLAs and SOC2 Type II audit logs. Need to align with enterprise legal template before Friday.',
        category: 'Legal',
        isPinned: true,
      ),
      CrmNote(
        companyId: 'acc_techvista_002',
        company: 'TechVista Solutions',
        title: 'Field Mapping UI Feedback',
        body:
            'Demonstrated the new field mapping dashboard. HR director loved the automatic audit log trail and digital signature verification.',
        category: 'Demo Feedback',
        isPinned: true,
      ),
    ]);

    accountNotes['Acme Corp'] = [
      'Client inquired about multi-year SLAs. Need to align with enterprise legal template.',
    ];
    accountNotes['TechVista Solutions'] = [
      'Demonstrated the new field mapping dashboard. HR director loved the automatic audit log trail.',
    ];

    _photos.addAll([
      PhotoRecord(
        id: 'photo_001',
        title: 'TechVista Front Reception & Signboard',
        category: 'Storefront',
        company: 'TechVista Solutions',
        fileSizeMb: 1.8,
        resolution: '4032 x 3024',
        location: 'Lower Parel, Mumbai (18.9986° N, 72.8258° E)',
        ocrText:
            'TECHVISTA ENTERPRISE SOLUTIONS\nTower 2, Floor 14, One Indiabulls\nVisitor Registration & Security Clearance Required',
      ),
      PhotoRecord(
        id: 'photo_002',
        title: 'John Doe Visiting Card Scan',
        category: 'Visiting Card',
        company: 'Acme Corp',
        fileSizeMb: 1.2,
        resolution: '3024 x 1890',
        location: 'Maker Chambers, Nariman Point, Mumbai',
        ocrText:
            'JOHN DOE\nChief Technology Officer\nAcme Corp International\nDirect: +91 98765 43210\nEmail: john.doe@acme.com',
      ),
      PhotoRecord(
        id: 'photo_003',
        title: 'Signed Master Services Agreement NDA',
        category: 'Document',
        company: 'Acme Corp',
        fileSizeMb: 2.4,
        resolution: '2480 x 3508',
        location: 'Maker Chambers, Nariman Point, Mumbai',
        ocrText:
            'CONFIDENTIAL NON-DISCLOSURE AGREEMENT\nExecuted between Acme Corp & FieldPulse CRM\nSigned by: John Doe, CTO\nDate: 14-Aug-2026',
      ),
      PhotoRecord(
        id: 'photo_004',
        title: 'DataFlow Server Rack Facility Inspection',
        category: 'Site Inspection',
        company: 'DataFlow Systems',
        fileSizeMb: 2.1,
        resolution: '4032 x 3024',
        location: 'Solitaire Park, Andheri East, Mumbai',
        ocrText:
            'SERVER ROOM 04\nDUAL UPS POWER REDUNDANT\nTEMPERATURE: 21°C\nAUDIT PASS STAMP 2026',
      ),
    ]);

    _voiceNotes.addAll([
      VoiceNoteRecord(
        id: 'rec_001',
        title: 'TechVista Post-Demo Discovery Debrief',
        company: 'TechVista Solutions',
        category: 'Debrief',
        durationDisplay: '2:34',
        durationSeconds: 154,
        transcriptionStatus: 'Transcribed',
        transcript:
            'Met with Priya Sharma and the regional HR heads. Main requirement is seamless offline clock-in and daily PDF visit report generation. If we provide digital signature capture and route map summaries out of the box, they are ready to sign a 3-year term for 150 field agents.',
      ),
      VoiceNoteRecord(
        id: 'rec_002',
        title: 'Acme Corp Legal SLA Caveats',
        company: 'Acme Corp',
        category: 'Legal',
        durationDisplay: '1:15',
        durationSeconds: 75,
        transcriptionStatus: 'Transcribed',
        transcript:
            'John Doe specifically highlighted that all visit reports must retain GPS coordinates and tamper-proof timestamps. Legal team will not accept reports without explicit signer designation and timestamp metadata.',
      ),
      VoiceNoteRecord(
        id: 'rec_003',
        title: 'DataFlow Security Architecture Q&A',
        company: 'DataFlow Systems',
        category: 'Technical',
        durationDisplay: '3:45',
        durationSeconds: 225,
        transcriptionStatus: 'Transcribed',
        transcript:
            'Karan Malhotra asked about local database encryption and whether field reps can clear storage cache without losing unsynced pending deals. Confirmed that local files use sandboxed storage with automatic sync status tracking.',
      ),
    ]);

    _activities.addAll([
      CrmActivity(
        companyId: 'acc_acme_001',
        company: 'Acme Corp',
        type: 'Visit',
        title: 'Completed In-Person Visit',
        description:
            'Product demo conducted with CTO. Client agreed to review enterprise quote.',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      CrmActivity(
        companyId: 'acc_techvista_002',
        company: 'TechVista Solutions',
        type: 'Call',
        title: 'Outbound Call with Priya Sharma',
        description:
            'Duration 18 min. Discussed route optimization integration and custom checklists.',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      CrmActivity(
        companyId: 'acc_stellar_004',
        company: 'Stellar Logistics',
        type: 'Deal',
        title: 'Deal Moved to Negotiation Stage',
        description:
            'Fleet Suite deal value \$185,000 moved to 90% probability.',
        timestamp: DateTime.now().subtract(const Duration(hours: 8)),
      ),
    ]);
  }
}
