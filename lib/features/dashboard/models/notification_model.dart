class NotificationModel {
  final String id;
  final String title;
  final String time;
  final String category;
  final bool isUnread;
  final Map<String, dynamic>? metadata;

  NotificationModel({
    required this.id,
    required this.title,
    required this.time,
    required this.category,
    required this.isUnread,
    this.metadata,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      time: json['time'] ?? '',
      category: json['category'] ?? 'general',
      isUnread: json['isUnread'] ?? false,
      metadata: json['metadata'],
    );
  }
}
