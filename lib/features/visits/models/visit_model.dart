/// Status of a field sales visit
enum VisitStatus {
  completed,
  inProgress,
  upcoming,
  cancelled,
}

/// Data model representing a customer/lead visit for field sales
class VisitModel {
  final String id;
  final String time;
  final VisitStatus status;
  final String meetingType; // e.g. "First Meeting", "Follow-up", "Demo", "Proposal"
  final String companyName;
  final String contactName;
  final String contactRole;
  final String locationAddress;
  final int dayOfMonth; // e.g. 8 for Thursday 8th
  final double distanceKm;
  final String? duration;
  final String? notes;

  const VisitModel({
    required this.id,
    required this.time,
    required this.status,
    required this.meetingType,
    required this.companyName,
    required this.contactName,
    required this.contactRole,
    required this.locationAddress,
    this.dayOfMonth = 8,
    this.distanceKm = 1.8,
    this.duration,
    this.notes,
  });

  VisitModel copyWith({
    String? id,
    String? time,
    VisitStatus? status,
    String? meetingType,
    String? companyName,
    String? contactName,
    String? contactRole,
    String? locationAddress,
    int? dayOfMonth,
    double? distanceKm,
    String? duration,
    String? notes,
  }) {
    return VisitModel(
      id: id ?? this.id,
      time: time ?? this.time,
      status: status ?? this.status,
      meetingType: meetingType ?? this.meetingType,
      companyName: companyName ?? this.companyName,
      contactName: contactName ?? this.contactName,
      contactRole: contactRole ?? this.contactRole,
      locationAddress: locationAddress ?? this.locationAddress,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      distanceKm: distanceKm ?? this.distanceKm,
      duration: duration ?? this.duration,
      notes: notes ?? this.notes,
    );
  }

  factory VisitModel.fromJson(Map<String, dynamic> json) {
    VisitStatus parseStatus(String? s) {
      switch (s?.toLowerCase()) {
        case 'completed': return VisitStatus.completed;
        case 'inprogress':
        case 'in-progress':
        case 'in_progress':
          return VisitStatus.inProgress;
        case 'upcoming': return VisitStatus.upcoming;
        case 'cancelled': return VisitStatus.cancelled;
        default: return VisitStatus.upcoming;
      }
    }

    return VisitModel(
      id: json['id']?.toString() ?? '',
      time: json['time'] ?? '',
      status: parseStatus(json['status']),
      meetingType: json['meetingType'] ?? '',
      companyName: json['companyName'] ?? '',
      contactName: json['contactName'] ?? '',
      contactRole: json['contactRole'] ?? '',
      locationAddress: json['locationAddress'] ?? '',
      dayOfMonth: json['dayOfMonth'] ?? 8,
      distanceKm: (json['distanceKm'] ?? 0).toDouble(),
      duration: json['duration'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    String formatStatus(VisitStatus s) {
      switch (s) {
        case VisitStatus.completed: return 'completed';
        case VisitStatus.inProgress: return 'in-progress';
        case VisitStatus.upcoming: return 'upcoming';
        case VisitStatus.cancelled: return 'cancelled';
      }
    }

    return {
      'id': id,
      'time': time,
      'status': formatStatus(status),
      'meetingType': meetingType,
      'companyName': companyName,
      'contactName': contactName,
      'contactRole': contactRole,
      'locationAddress': locationAddress,
      'dayOfMonth': dayOfMonth,
      'distanceKm': distanceKm,
      'duration': duration,
      'notes': notes,
    };
  }
}
