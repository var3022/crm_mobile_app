class DashboardStats {
  final int todayVisitsCompleted;
  final int todayVisitsTotal;
  final int checkIns;
  final double distanceKm;
  final double revenue;
  final double monthlyTarget;
  final double monthlyAchieved;
  final int daysRemaining;

  DashboardStats({
    required this.todayVisitsCompleted,
    required this.todayVisitsTotal,
    required this.checkIns,
    required this.distanceKm,
    required this.revenue,
    required this.monthlyTarget,
    required this.monthlyAchieved,
    required this.daysRemaining,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      todayVisitsCompleted: json['todayVisitsCompleted'] ?? 0,
      todayVisitsTotal: json['todayVisitsTotal'] ?? 0,
      checkIns: json['checkIns'] ?? 0,
      distanceKm: (json['distanceKm'] ?? 0).toDouble(),
      revenue: (json['revenue'] ?? 0).toDouble(),
      monthlyTarget: (json['monthlyTarget'] ?? 0).toDouble(),
      monthlyAchieved: (json['monthlyAchieved'] ?? 0).toDouble(),
      daysRemaining: json['daysRemaining'] ?? 0,
    );
  }
}
