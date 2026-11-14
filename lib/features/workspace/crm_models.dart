import 'dart:math';
import 'package:flutter/material.dart';

/// Stable ID generator for CRM records.
String generateId([String prefix = 'rec']) {
  final random = Random();
  final ts = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
  final rand = random.nextInt(0xFFFFFF).toRadixString(36).padLeft(4, '0');
  return '${prefix}_$ts$rand';
}

/// An Account represents either a Lead or a Converted Customer.
class Account {
  Account(
    this.company,
    this.contact, {
    String? id,
    this.role = 'CTO',
    this.score = 85,
    this.stage = 'New',
    this.area = 'Nariman Point, South Mumbai',
    this.distance = 0.8,
    this.phone = '+91 98765 43210',
    this.email = 'john.doe@acme.com',
    this.notes = '',
    this.industry = 'Technology',
    this.companySize = '100-500',
    this.source = 'Referral',
    this.priority = 'High',
    this.customerType = 'Enterprise',
    this.owner = 'Arjun Mehta',
    this.territory = 'South Mumbai',
    this.verifiedAddress = '12th Floor, Maker Chambers, Nariman Point, Mumbai',
    this.flagged = false,
    this.isCustomer = false,
    this.accountValue = 1250000,
    DateTime? createdAt,
    DateTime? lastVisited,
  }) : id = id ?? generateId('acc'),
       createdAt = createdAt ?? DateTime.now(),
       lastVisited =
           lastVisited ?? DateTime.now().subtract(const Duration(days: 2));

  final String id;
  String company;
  String contact;
  String role;
  int score;
  String stage;
  String area;
  double distance;
  String phone;
  String email;
  String notes;
  String industry;
  String companySize;
  String source;
  String priority;
  String customerType;
  String owner;
  String territory;
  String verifiedAddress;
  bool flagged;
  bool isCustomer;
  double accountValue;
  DateTime createdAt;
  DateTime? lastVisited;

  String get initials {
    final parts = company.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'AC';
    if (parts.length == 1)
      return parts.first.substring(0, min(2, parts.first.length)).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'company': company,
    'contact': contact,
    'role': role,
    'score': score,
    'stage': stage,
    'area': area,
    'distance': distance,
    'phone': phone,
    'email': email,
    'notes': notes,
    'industry': industry,
    'companySize': companySize,
    'source': source,
    'priority': priority,
    'customerType': customerType,
    'owner': owner,
    'territory': territory,
    'verifiedAddress': verifiedAddress,
    'flagged': flagged,
    'isCustomer': isCustomer,
    'accountValue': accountValue,
    'createdAt': createdAt.toIso8601String(),
    'lastVisited': lastVisited?.toIso8601String(),
  };

  factory Account.fromJson(Map<String, dynamic> j) => Account(
    j['company'] as String? ?? 'Acme Corp',
    j['contact'] as String? ?? 'John Doe',
    id: j['id'] as String?,
    role: j['role'] as String? ?? 'CTO',
    score: (j['score'] as num?)?.toInt() ?? 85,
    stage: j['stage'] as String? ?? 'New',
    area: j['area'] as String? ?? 'Nariman Point, South Mumbai',
    distance: (j['distance'] as num?)?.toDouble() ?? 0.8,
    phone: j['phone'] as String? ?? '+91 98765 43210',
    email: j['email'] as String? ?? 'john.doe@acme.com',
    notes: j['notes'] as String? ?? '',
    industry: j['industry'] as String? ?? 'Technology',
    companySize: j['companySize'] as String? ?? '100-500',
    source: j['source'] as String? ?? 'Referral',
    priority: j['priority'] as String? ?? 'High',
    customerType: j['customerType'] as String? ?? 'Enterprise',
    owner: j['owner'] as String? ?? 'Arjun Mehta',
    territory: j['territory'] as String? ?? 'South Mumbai',
    verifiedAddress:
        j['verifiedAddress'] as String? ??
        '12th Floor, Maker Chambers, Nariman Point, Mumbai',
    flagged: j['flagged'] as bool? ?? false,
    isCustomer: j['isCustomer'] as bool? ?? false,
    accountValue: (j['accountValue'] as num?)?.toDouble() ?? 1250000,
    createdAt: j['createdAt'] != null
        ? DateTime.tryParse(j['createdAt'] as String)
        : null,
    lastVisited: j['lastVisited'] != null
        ? DateTime.tryParse(j['lastVisited'] as String)
        : null,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Account && other.id == id);

  @override
  int get hashCode => id.hashCode;
}

/// A Deal in the pipeline.
class Deal {
  Deal(
    this.title,
    this.company,
    this.value,
    this.stage, {
    String? id,
    String? companyId,
    DateTime? closeDate,
    this.probability = '75',
    this.products =
        'Enterprise SaaS Suite, Cloud Storage Add-on, Premium Support SLA',
    this.notes =
        'Client interested in bulk license discount. To discuss proposal in next follow-up.',
    this.owner = 'Alex M.',
    this.competitors = 'SalesSphere Corp, LeadPulse Systems',
    this.decisionMakers = 'Sarah Johnson (VP), Marcus Vance (CIO)',
    this.nextAction = 'Send Final Proposal Document',
    this.reasonForLoss = '',
    this.durationDays = 18,
    DateTime? createdAt,
  }) : id = id ?? generateId('deal'),
       companyId = companyId ?? company,
       closeDate = closeDate ?? DateTime.now().add(const Duration(days: 30)),
       createdAt = createdAt ?? DateTime.now();

  final String id;
  String title;
  String companyId;
  String company;
  double value;
  String stage;
  DateTime? closeDate;
  String probability;
  String products;
  String notes;
  String owner;
  String competitors;
  String decisionMakers;
  String nextAction;
  String reasonForLoss;
  int durationDays;
  DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'companyId': companyId,
    'company': company,
    'value': value,
    'stage': stage,
    'closeDate': closeDate?.toIso8601String(),
    'probability': probability,
    'products': products,
    'notes': notes,
    'owner': owner,
    'competitors': competitors,
    'decisionMakers': decisionMakers,
    'nextAction': nextAction,
    'reasonForLoss': reasonForLoss,
    'durationDays': durationDays,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Deal.fromJson(Map<String, dynamic> j) => Deal(
    j['title'] as String? ?? 'Enterprise Deal',
    j['company'] as String? ?? 'Acme Corp',
    (j['value'] as num?)?.toDouble() ?? 0,
    j['stage'] as String? ?? 'Proposal',
    id: j['id'] as String?,
    companyId: j['companyId'] as String? ?? '',
    closeDate: j['closeDate'] != null
        ? DateTime.tryParse(j['closeDate'] as String)
        : null,
    probability: j['probability'] as String? ?? '75',
    products: j['products'] as String? ?? '',
    notes: j['notes'] as String? ?? '',
    owner: j['owner'] as String? ?? 'Alex M.',
    competitors: j['competitors'] as String? ?? '',
    decisionMakers: j['decisionMakers'] as String? ?? '',
    nextAction: j['nextAction'] as String? ?? 'Send Proposal',
    reasonForLoss: j['reasonForLoss'] as String? ?? '',
    durationDays: (j['durationDays'] as num?)?.toInt() ?? 18,
    createdAt: j['createdAt'] != null
        ? DateTime.tryParse(j['createdAt'] as String)
        : null,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Deal && other.id == id);

  @override
  int get hashCode => id.hashCode;
}

/// A Visit to a client location.
class Visit {
  Visit(
    this.company,
    this.contact,
    this.time,
    this.type, {
    String? id,
    String? companyId,
    this.status = 'Scheduled',
    DateTime? date,
    this.purpose = 'Product demo & setup verification',
    this.duration = '45 min',
    this.durationMinutes = 45,
    List<bool>? checklist,
    List<String>? customChecklist,
    List<Offset?>? signature,
    this.signerName = 'John Doe',
    this.signerDesignation = 'CTO',
    DateTime? signerTimestamp,
    this.outcome = 'Positive — Deal progressing',
    this.summary =
        'Product demo went exceptionally well. CTO requested a custom volume discount proposal.',
    this.nextSteps = 'Send Proposal',
    DateTime? followUpDate,
    this.isLocationVerified = true,
    this.checkInMode = 'verified',
    this.checkInReason = '',
    this.locationAddress = '12th Floor, Maker Chambers, Nariman Point, Mumbai',
    DateTime? startedAt,
  }) : id = id ?? generateId('vis'),
       companyId = companyId ?? company,
       date = date ?? DateTime.now(),
       checklist = checklist ?? List.filled(8, false),
       customChecklist = customChecklist ?? [],
       signature = signature ?? [],
       signerTimestamp = signerTimestamp ?? DateTime.now(),
       followUpDate =
           followUpDate ?? DateTime.now().add(const Duration(days: 6)),
       startedAt = startedAt;

  final String id;
  String companyId;
  String company;
  String contact;
  String time;
  String type;
  String status; // 'Scheduled', 'In Progress', 'Completed', 'Cancelled'
  DateTime date;
  String purpose;
  String duration;
  int durationMinutes;
  List<bool> checklist;
  List<String> customChecklist;
  List<Offset?> signature;
  String signerName;
  String signerDesignation;
  DateTime signerTimestamp;
  String outcome;
  String summary;
  String nextSteps;
  DateTime followUpDate;
  bool isLocationVerified;
  String checkInMode; // 'verified', 'manual', 'far'
  String checkInReason;
  String locationAddress;
  DateTime? startedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'companyId': companyId,
    'company': company,
    'contact': contact,
    'time': time,
    'type': type,
    'status': status,
    'date': date.toIso8601String(),
    'purpose': purpose,
    'duration': duration,
    'durationMinutes': durationMinutes,
    'checklist': checklist,
    'customChecklist': customChecklist,
    'signaturePoints': signature
        .map((o) => o == null ? null : [o.dx, o.dy])
        .toList(),
    'signerName': signerName,
    'signerDesignation': signerDesignation,
    'signerTimestamp': signerTimestamp.toIso8601String(),
    'outcome': outcome,
    'summary': summary,
    'nextSteps': nextSteps,
    'followUpDate': followUpDate.toIso8601String(),
    'isLocationVerified': isLocationVerified,
    'checkInMode': checkInMode,
    'checkInReason': checkInReason,
    'locationAddress': locationAddress,
    'startedAt': startedAt?.toIso8601String(),
  };

  factory Visit.fromJson(Map<String, dynamic> j) {
    final rawSig = j['signaturePoints'] as List<dynamic>?;
    final sig = <Offset?>[];
    if (rawSig != null) {
      for (final pt in rawSig) {
        if (pt is List && pt.length >= 2) {
          sig.add(Offset((pt[0] as num).toDouble(), (pt[1] as num).toDouble()));
        } else {
          sig.add(null);
        }
      }
    }
    return Visit(
      j['company'] as String? ?? 'Acme Corp',
      j['contact'] as String? ?? 'John Doe',
      j['time'] as String? ?? '10:00 AM',
      j['type'] as String? ?? 'First Meeting',
      id: j['id'] as String?,
      companyId: j['companyId'] as String? ?? '',
      status: j['status'] as String? ?? 'Scheduled',
      date: j['date'] != null ? DateTime.tryParse(j['date'] as String) : null,
      purpose: j['purpose'] as String? ?? '',
      duration: j['duration'] as String? ?? '45 min',
      durationMinutes: (j['durationMinutes'] as num?)?.toInt() ?? 45,
      checklist:
          (j['checklist'] as List<dynamic>?)?.map((e) => e == true).toList() ??
          List.filled(8, false),
      customChecklist:
          (j['customChecklist'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      signature: sig,
      signerName: j['signerName'] as String? ?? 'John Doe',
      signerDesignation: j['signerDesignation'] as String? ?? 'CTO',
      signerTimestamp: j['signerTimestamp'] != null
          ? DateTime.tryParse(j['signerTimestamp'] as String)
          : null,
      outcome: j['outcome'] as String? ?? 'Positive — Deal progressing',
      summary: j['summary'] as String? ?? '',
      nextSteps: j['nextSteps'] as String? ?? 'Send Proposal',
      followUpDate: j['followUpDate'] != null
          ? DateTime.tryParse(j['followUpDate'] as String)
          : null,
      isLocationVerified: j['isLocationVerified'] as bool? ?? true,
      checkInMode: j['checkInMode'] as String? ?? 'verified',
      checkInReason: j['checkInReason'] as String? ?? '',
      locationAddress:
          j['locationAddress'] as String? ??
          '12th Floor, Maker Chambers, Nariman Point, Mumbai',
      startedAt: j['startedAt'] != null
          ? DateTime.tryParse(j['startedAt'] as String)
          : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Visit && other.id == id);

  @override
  int get hashCode => id.hashCode;
}

/// A Task to be done by the field agent.
class CrmTask {
  CrmTask(
    this.title,
    this.company, {
    String? id,
    String? companyId,
    this.dealId = '',
    this.dealTitle = '',
    this.source = 'Self-Created',
    this.priority = 'High',
    this.description = '',
    DateTime? due,
    this.overdue = false,
    this.completed = false,
    this.assignee = 'Arjun Mehta',
    this.type = 'Follow-up',
    this.status = 'In Progress',
    List<bool>? checklist,
    List<String>? checklistLabels,
    this.reminderEnabled = true,
    this.reminderMinutesBefore = 15,
  }) : id = id ?? generateId('tsk'),
       companyId = companyId ?? company,
       due = due ?? DateTime.now().add(const Duration(hours: 3)),
       checklist = checklist ?? List.filled(3, false),
       checklistLabels =
           checklistLabels ??
           [
             'Print physical enterprise catalogs',
             'Carry physical copy of NDA template',
             'Obtain client signature on document',
           ];

  final String id;
  String title;
  String companyId;
  String company;
  String dealId;
  String dealTitle;
  String source;
  String priority;
  String description;
  DateTime due;
  bool overdue;
  bool completed;
  String assignee;
  String type;
  String status; // 'In Progress', 'Pending', 'Completed', 'Cancelled'
  List<bool> checklist;
  List<String> checklistLabels;
  bool reminderEnabled;
  int reminderMinutesBefore;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'companyId': companyId,
    'company': company,
    'dealId': dealId,
    'dealTitle': dealTitle,
    'source': source,
    'priority': priority,
    'description': description,
    'due': due.toIso8601String(),
    'overdue': overdue,
    'completed': completed,
    'assignee': assignee,
    'type': type,
    'status': status,
    'checklist': checklist,
    'checklistLabels': checklistLabels,
    'reminderEnabled': reminderEnabled,
    'reminderMinutesBefore': reminderMinutesBefore,
  };

  factory CrmTask.fromJson(Map<String, dynamic> j) => CrmTask(
    j['title'] as String? ?? 'Follow up',
    j['company'] as String? ?? 'Acme Corp',
    id: j['id'] as String?,
    companyId: j['companyId'] as String? ?? '',
    dealId: j['dealId'] as String? ?? '',
    dealTitle: j['dealTitle'] as String? ?? '',
    source: j['source'] as String? ?? 'Self-Created',
    priority: j['priority'] as String? ?? 'High',
    description: j['description'] as String? ?? '',
    due: j['due'] != null ? DateTime.tryParse(j['due'] as String) : null,
    overdue: j['overdue'] as bool? ?? false,
    completed: j['completed'] as bool? ?? false,
    assignee: j['assignee'] as String? ?? 'Arjun Mehta',
    type: j['type'] as String? ?? 'Follow-up',
    status: j['status'] as String? ?? 'In Progress',
    checklist:
        (j['checklist'] as List<dynamic>?)?.map((e) => e == true).toList() ??
        List.filled(3, false),
    checklistLabels: (j['checklistLabels'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList(),
    reminderEnabled: j['reminderEnabled'] as bool? ?? true,
    reminderMinutesBefore: (j['reminderMinutesBefore'] as num?)?.toInt() ?? 15,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is CrmTask && other.id == id);

  @override
  int get hashCode => id.hashCode;
}

/// A Note attached to an account or visit.
class CrmNote {
  CrmNote({
    String? id,
    required this.companyId,
    required this.company,
    this.visitId = '',
    required this.title,
    String? content,
    String? body,
    this.category = 'General',
    DateTime? timestamp,
    this.isPinned = false,
    this.notifyTeam = false,
    List<String>? attachments,
  }) : id = id ?? generateId('note'),
       content = content ?? body ?? '',
       timestamp = timestamp ?? DateTime.now(),
       attachments = attachments ?? [];

  final String id;
  String companyId;
  String company;
  String visitId;
  String title;
  String content;
  String get body => content;
  set body(String val) => content = val;
  String category;
  DateTime timestamp;
  bool isPinned;
  bool notifyTeam;
  List<String> attachments;

  Map<String, dynamic> toJson() => {
    'id': id,
    'companyId': companyId,
    'company': company,
    'visitId': visitId,
    'title': title,
    'content': content,
    'category': category,
    'timestamp': timestamp.toIso8601String(),
    'isPinned': isPinned,
    'notifyTeam': notifyTeam,
    'attachments': attachments,
  };

  factory CrmNote.fromJson(Map<String, dynamic> j) => CrmNote(
    id: j['id'] as String?,
    companyId: j['companyId'] as String? ?? '',
    company: j['company'] as String? ?? 'Acme Corp',
    visitId: j['visitId'] as String? ?? '',
    title: j['title'] as String? ?? 'Meeting Note',
    content:
        j['content'] as String? ??
        j['body'] as String? ??
        j['text'] as String? ??
        '',
    category: j['category'] as String? ?? 'General',
    timestamp: j['timestamp'] != null
        ? DateTime.tryParse(j['timestamp'] as String)
        : null,
    isPinned: j['isPinned'] as bool? ?? false,
    notifyTeam: j['notifyTeam'] as bool? ?? false,
    attachments:
        (j['attachments'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [],
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is CrmNote && other.id == id);

  @override
  int get hashCode => id.hashCode;
}

/// An Activity event on the timeline.
class CrmActivity {
  CrmActivity({
    String? id,
    required this.companyId,
    required this.company,
    required this.title,
    required this.description,
    DateTime? timestamp,
    this.type = 'visit', // 'visit', 'call', 'email', 'note', 'deal'
    this.duration = '45 min',
    this.outcome = 'Positive',
    this.isAiAutomated = false,
  }) : id = id ?? generateId('act'),
       timestamp = timestamp ?? DateTime.now();

  final String id;
  String companyId;
  String company;
  String title;
  String description;
  DateTime timestamp;
  String type;
  String duration;
  String outcome;
  bool isAiAutomated;

  Map<String, dynamic> toJson() => {
    'id': id,
    'companyId': companyId,
    'company': company,
    'title': title,
    'description': description,
    'timestamp': timestamp.toIso8601String(),
    'type': type,
    'duration': duration,
    'outcome': outcome,
    'isAiAutomated': isAiAutomated,
  };

  factory CrmActivity.fromJson(Map<String, dynamic> j) => CrmActivity(
    id: j['id'] as String?,
    companyId: j['companyId'] as String? ?? '',
    company: j['company'] as String? ?? 'Acme Corp',
    title: j['title'] as String? ?? '',
    description: j['description'] as String? ?? '',
    timestamp: j['timestamp'] != null
        ? DateTime.tryParse(j['timestamp'] as String)
        : null,
    type: j['type'] as String? ?? 'visit',
    duration: j['duration'] as String? ?? '45 min',
    outcome: j['outcome'] as String? ?? 'Positive',
    isAiAutomated: j['isAiAutomated'] as bool? ?? false,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is CrmActivity && other.id == id);

  @override
  int get hashCode => id.hashCode;
}

/// A photo in the media library with OCR metadata.
class PhotoRecord {
  PhotoRecord({
    String? id,
    this.assetPath = 'assets/images/office.png',
    required this.category,
    String? caption,
    String? title,
    this.companyId = '',
    this.company = 'Acme Corp',
    this.visitId = '',
    DateTime? timestamp,
    String? fileSize,
    double? fileSizeMb,
    this.resolution = '4032 x 3024',
    this.location = 'Nariman Point, South Mumbai',
    this.ocrText =
        'ALEX MORGAN\nChief Technology Officer\nAcme Corp\nPhone: +91 98765 43210\nEmail: alex@acme.com',
    this.hasOcr = true,
  }) : id = id ?? generateId('pho'),
       caption = caption ?? title ?? 'Visit Photo',
       fileSize =
           fileSize ??
           (fileSizeMb != null
               ? '${fileSizeMb.toStringAsFixed(1)} MB'
               : '2.4 MB'),
       timestamp =
           timestamp ?? DateTime.now().subtract(const Duration(days: 1));

  final String id;
  String assetPath;
  String category;
  String caption;
  String get title => caption;
  set title(String val) => caption = val;
  String companyId;
  String company;
  String visitId;
  DateTime timestamp;
  String fileSize;
  String resolution;
  String location;
  String ocrText;
  bool hasOcr;

  Map<String, dynamic> toJson() => {
    'id': id,
    'assetPath': assetPath,
    'category': category,
    'caption': caption,
    'companyId': companyId,
    'company': company,
    'visitId': visitId,
    'timestamp': timestamp.toIso8601String(),
    'fileSize': fileSize,
    'resolution': resolution,
    'location': location,
    'ocrText': ocrText,
    'hasOcr': hasOcr,
  };

  factory PhotoRecord.fromJson(Map<String, dynamic> j) => PhotoRecord(
    id: j['id'] as String?,
    assetPath: j['assetPath'] as String? ?? 'assets/images/office.png',
    category: j['category'] as String? ?? 'General',
    caption: j['caption'] as String? ?? j['title'] as String? ?? 'Visit Photo',
    companyId: j['companyId'] as String? ?? '',
    company: j['company'] as String? ?? 'Acme Corp',
    visitId: j['visitId'] as String? ?? '',
    timestamp: j['timestamp'] != null
        ? DateTime.tryParse(j['timestamp'] as String)
        : null,
    fileSize: j['fileSize'] as String? ?? '2.4 MB',
    resolution: j['resolution'] as String? ?? '4032 x 3024',
    location: j['location'] as String? ?? 'Nariman Point, South Mumbai',
    ocrText: j['ocrText'] as String? ?? '',
    hasOcr: j['hasOcr'] as bool? ?? false,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is PhotoRecord && other.id == id);

  @override
  int get hashCode => id.hashCode;
}

/// A voice recording with transcription metadata.
class VoiceNoteRecord {
  VoiceNoteRecord({
    String? id,
    required this.title,
    this.companyId = '',
    required this.company,
    this.visitId = '',
    DateTime? timestamp,
    String? duration,
    String? durationDisplay,
    this.durationSeconds = 154,
    this.category = 'Meeting Notes',
    this.transcriptionStatus =
        'Transcribed', // 'Transcribed', 'Processing', 'Failed'
    String? transcriptText,
    String? transcript,
    this.audioSpeed = '1x',
  }) : id = id ?? generateId('vno'),
       duration = duration ?? durationDisplay ?? '2:34',
       transcriptText =
           transcriptText ??
           transcript ??
           '"The client John Doe mentioned that they are extremely interested in our pricing options. We should follow up with a solid volume discount proposal by tomorrow morning..."',
       timestamp =
           timestamp ?? DateTime.now().subtract(const Duration(hours: 4));

  final String id;
  String title;
  String companyId;
  String company;
  String visitId;
  DateTime timestamp;
  String duration;
  String get durationDisplay => duration;
  int durationSeconds;
  String category;
  String transcriptionStatus;
  String transcriptText;
  String get transcript => transcriptText;
  set transcript(String val) => transcriptText = val;
  String audioSpeed;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'companyId': companyId,
    'company': company,
    'visitId': visitId,
    'timestamp': timestamp.toIso8601String(),
    'duration': duration,
    'durationSeconds': durationSeconds,
    'category': category,
    'transcriptionStatus': transcriptionStatus,
    'transcriptText': transcriptText,
    'audioSpeed': audioSpeed,
  };

  factory VoiceNoteRecord.fromJson(Map<String, dynamic> j) => VoiceNoteRecord(
    id: j['id'] as String?,
    title: j['title'] as String? ?? 'Voice Note',
    companyId: j['companyId'] as String? ?? '',
    company: j['company'] as String? ?? 'Acme Corp',
    visitId: j['visitId'] as String? ?? '',
    timestamp: j['timestamp'] != null
        ? DateTime.tryParse(j['timestamp'] as String)
        : null,
    duration: j['duration'] as String? ?? '2:34',
    durationSeconds: (j['durationSeconds'] as num?)?.toInt() ?? 154,
    category: j['category'] as String? ?? 'Meeting Notes',
    transcriptionStatus: j['transcriptionStatus'] as String? ?? 'Transcribed',
    transcriptText:
        j['transcriptText'] as String? ?? j['transcript'] as String? ?? '',
    audioSpeed: j['audioSpeed'] as String? ?? '1x',
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is VoiceNoteRecord && other.id == id);

  @override
  int get hashCode => id.hashCode;
}

/// User profile and settings models.
class UserProfile {
  UserProfile({
    this.name = 'Arjun Mehta',
    this.email = 'arjun@acme.com',
    this.phone = '+91 99876 54321',
    this.designation = 'Field Sales Executive',
    this.territory = 'South Mumbai',
    String? reportingManager,
    String? manager,
    this.avatarInitials = 'AM',
    this.avatarAsset,
  }) : reportingManager = reportingManager ?? manager ?? 'Priya Sharma';

  String name;
  String email;
  String phone;
  String designation;
  String territory;
  String reportingManager;
  String get manager => reportingManager;
  set manager(String val) => reportingManager = val;
  String avatarInitials;
  String? avatarAsset;

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
    'designation': designation,
    'territory': territory,
    'reportingManager': reportingManager,
    'avatarInitials': avatarInitials,
    'avatarAsset': avatarAsset,
  };

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
    name: j['name'] as String? ?? 'Arjun Mehta',
    email: j['email'] as String? ?? 'arjun@acme.com',
    phone: j['phone'] as String? ?? '+91 99876 54321',
    designation: j['designation'] as String? ?? 'Field Sales Executive',
    territory: j['territory'] as String? ?? 'South Mumbai',
    reportingManager: j['reportingManager'] as String? ?? 'Priya Sharma',
    avatarInitials: j['avatarInitials'] as String? ?? 'AM',
    avatarAsset: j['avatarAsset'] as String?,
  );
}

class AppSettings {
  AppSettings({
    this.pushNotifications = true,
    this.visitReminders = true,
    this.taskDueNotifications = true,
    this.dealUpdates = true,
    this.teamMessages = true,
    this.nearbyLeadsAlert = true,
    this.dailySummary = true,
    this.weeklyReport = false,
    this.leadActivityAlerts = false,
    this.dealStageChanges = true,
    this.quietHoursEnabled = true,
    this.quietHoursFrom = '10:00 PM',
    this.quietHoursTo = '7:00 AM',
    this.quietHoursAllowUrgent = true,
    this.biometricLogin = true,
    this.twoFactorEnabled = false,
    this.twoFactorSecret,
    List<String>? backupCodes,
    List<String>? consumedBackupCodes,
    this.locationTracking = true,
    this.trackingHours = '8 AM - 8 PM',
    this.wifiOnlySync = false,
    this.aiAssistant = true,
    this.dailyBriefing = true,
    DateTime? lastSyncedAt,
  }) : backupCodes = backupCodes ?? [],
       consumedBackupCodes = consumedBackupCodes ?? [],
       lastSyncedAt =
           lastSyncedAt ?? DateTime.now().subtract(const Duration(minutes: 2));

  bool pushNotifications;
  bool visitReminders;
  bool taskDueNotifications;
  bool dealUpdates;
  bool teamMessages;
  bool nearbyLeadsAlert;
  bool dailySummary;
  bool weeklyReport;
  bool leadActivityAlerts;
  bool dealStageChanges;
  bool quietHoursEnabled;
  String quietHoursFrom;
  String quietHoursTo;
  bool quietHoursAllowUrgent;
  bool biometricLogin;
  bool twoFactorEnabled;
  String? twoFactorSecret;
  List<String> backupCodes;
  List<String> consumedBackupCodes;
  bool locationTracking;
  String trackingHours;
  bool wifiOnlySync;
  bool aiAssistant;
  bool dailyBriefing;
  DateTime lastSyncedAt;
  DateTime get lastSyncTime => lastSyncedAt;
  set lastSyncTime(DateTime val) => lastSyncedAt = val;
  int pendingSyncItems = 0;

  Map<String, dynamic> toJson() => {
    'pushNotifications': pushNotifications,
    'visitReminders': visitReminders,
    'taskDueNotifications': taskDueNotifications,
    'dealUpdates': dealUpdates,
    'teamMessages': teamMessages,
    'nearbyLeadsAlert': nearbyLeadsAlert,
    'dailySummary': dailySummary,
    'weeklyReport': weeklyReport,
    'leadActivityAlerts': leadActivityAlerts,
    'dealStageChanges': dealStageChanges,
    'quietHoursEnabled': quietHoursEnabled,
    'quietHoursFrom': quietHoursFrom,
    'quietHoursTo': quietHoursTo,
    'quietHoursAllowUrgent': quietHoursAllowUrgent,
    'biometricLogin': biometricLogin,
    'twoFactorEnabled': twoFactorEnabled,
    'twoFactorSecret': twoFactorSecret,
    'backupCodes': backupCodes,
    'consumedBackupCodes': consumedBackupCodes,
    'locationTracking': locationTracking,
    'trackingHours': trackingHours,
    'wifiOnlySync': wifiOnlySync,
    'aiAssistant': aiAssistant,
    'dailyBriefing': dailyBriefing,
    'lastSyncedAt': lastSyncedAt.toIso8601String(),
    'pendingSyncItems': pendingSyncItems,
  };

  factory AppSettings.fromJson(Map<String, dynamic> j) => AppSettings(
    pushNotifications: j['pushNotifications'] as bool? ?? true,
    visitReminders: j['visitReminders'] as bool? ?? true,
    taskDueNotifications: j['taskDueNotifications'] as bool? ?? true,
    dealUpdates: j['dealUpdates'] as bool? ?? true,
    teamMessages: j['teamMessages'] as bool? ?? true,
    nearbyLeadsAlert: j['nearbyLeadsAlert'] as bool? ?? true,
    dailySummary: j['dailySummary'] as bool? ?? true,
    weeklyReport: j['weeklyReport'] as bool? ?? false,
    leadActivityAlerts: j['leadActivityAlerts'] as bool? ?? false,
    dealStageChanges: j['dealStageChanges'] as bool? ?? true,
    quietHoursEnabled: j['quietHoursEnabled'] as bool? ?? true,
    quietHoursFrom: j['quietHoursFrom'] as String? ?? '10:00 PM',
    quietHoursTo: j['quietHoursTo'] as String? ?? '7:00 AM',
    quietHoursAllowUrgent: j['quietHoursAllowUrgent'] as bool? ?? true,
    biometricLogin: j['biometricLogin'] as bool? ?? true,
    twoFactorEnabled: j['twoFactorEnabled'] as bool? ?? false,
    twoFactorSecret: j['twoFactorSecret'] as String?,
    backupCodes: (j['backupCodes'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList(),
    consumedBackupCodes: (j['consumedBackupCodes'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList(),
    locationTracking: j['locationTracking'] as bool? ?? true,
    trackingHours: j['trackingHours'] as String? ?? '8 AM - 8 PM',
    wifiOnlySync: j['wifiOnlySync'] as bool? ?? false,
    aiAssistant: j['aiAssistant'] as bool? ?? true,
    dailyBriefing: j['dailyBriefing'] as bool? ?? true,
    lastSyncedAt: j['lastSyncedAt'] != null
        ? DateTime.tryParse(j['lastSyncedAt'] as String)
        : null,
  )..pendingSyncItems = j['pendingSyncItems'] as int? ?? 0;
}
