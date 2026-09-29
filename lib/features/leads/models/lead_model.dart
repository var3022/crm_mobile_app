/// Lead model representing a prospective client in CRM Pro Field Sales
enum LeadTemperature { hot, warm, cold }

enum LeadStage { newLead, contacted, qualified, proposal, negotiation, won, lost }

class LeadModel {
  final String id;
  final String companyName;
  final String contactName;
  final String contactRole;
  final double distanceKm;
  final String locationArea;
  final String lastActive;
  final int aiScore;
  final LeadStage stage;
  final LeadTemperature temperature;
  final bool isFlagged;
  final String phoneNumber;
  final String email;
  final bool hasSwipeActionTip;
  final String? notes;

  const LeadModel({
    required this.id,
    required this.companyName,
    required this.contactName,
    required this.contactRole,
    required this.distanceKm,
    required this.locationArea,
    required this.lastActive,
    required this.aiScore,
    required this.stage,
    required this.temperature,
    this.isFlagged = false,
    required this.phoneNumber,
    required this.email,
    this.hasSwipeActionTip = false,
    this.notes,
  });

  LeadModel copyWith({
    String? id,
    String? companyName,
    String? contactName,
    String? contactRole,
    double? distanceKm,
    String? locationArea,
    String? lastActive,
    int? aiScore,
    LeadStage? stage,
    LeadTemperature? temperature,
    bool? isFlagged,
    String? phoneNumber,
    String? email,
    bool? hasSwipeActionTip,
    String? notes,
  }) {
    return LeadModel(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      contactName: contactName ?? this.contactName,
      contactRole: contactRole ?? this.contactRole,
      distanceKm: distanceKm ?? this.distanceKm,
      locationArea: locationArea ?? this.locationArea,
      lastActive: lastActive ?? this.lastActive,
      aiScore: aiScore ?? this.aiScore,
      stage: stage ?? this.stage,
      temperature: temperature ?? this.temperature,
      isFlagged: isFlagged ?? this.isFlagged,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      hasSwipeActionTip: hasSwipeActionTip ?? this.hasSwipeActionTip,
      notes: notes ?? this.notes,
    );
  }

  String get stageLabel {
    switch (stage) {
      case LeadStage.newLead:
        return 'New';
      case LeadStage.contacted:
        return 'Contacted';
      case LeadStage.qualified:
        return 'Qualified';
      case LeadStage.proposal:
        return 'Proposal';
      case LeadStage.negotiation:
        return 'Negotiation';
      case LeadStage.won:
        return 'Won';
      case LeadStage.lost:
        return 'Lost';
    }
  }

  String get temperatureLabel {
    switch (temperature) {
      case LeadTemperature.hot:
        return 'Hot';
      case LeadTemperature.warm:
        return 'Warm';
      case LeadTemperature.cold:
        return 'Cold';
    }
  }

  factory LeadModel.fromJson(Map<String, dynamic> json) {
    LeadStage parseStage(String? s) {
      switch (s?.toLowerCase()) {
        case 'contacted': return LeadStage.contacted;
        case 'qualified': return LeadStage.qualified;
        case 'proposal': return LeadStage.proposal;
        case 'negotiation': return LeadStage.negotiation;
        case 'won': return LeadStage.won;
        case 'lost': return LeadStage.lost;
        default: return LeadStage.newLead;
      }
    }

    LeadTemperature parseTemperature(String? s) {
      switch (s?.toLowerCase()) {
        case 'hot': return LeadTemperature.hot;
        case 'warm': return LeadTemperature.warm;
        case 'cold': return LeadTemperature.cold;
        default: return LeadTemperature.cold;
      }
    }

    return LeadModel(
      id: json['id']?.toString() ?? '',
      companyName: json['companyName'] ?? '',
      contactName: json['contactName'] ?? '',
      contactRole: json['contactRole'] ?? '',
      distanceKm: (json['distanceKm'] ?? 0).toDouble(),
      locationArea: json['locationArea'] ?? '',
      lastActive: json['lastActive'] ?? '',
      aiScore: json['aiScore'] ?? 0,
      stage: parseStage(json['stage']),
      temperature: parseTemperature(json['temperature']),
      isFlagged: json['isFlagged'] ?? false,
      phoneNumber: json['phoneNumber'] ?? '',
      email: json['email'] ?? '',
      hasSwipeActionTip: json['hasSwipeActionTip'] ?? false,
      notes: json['notes'],
    );
  }
}
