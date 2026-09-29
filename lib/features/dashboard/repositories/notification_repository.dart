import '../../../core/network/api_client.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final ApiClient _apiClient;

  NotificationRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<List<NotificationModel>> getNotifications() async {
    final response = await _apiClient.get('/api/v1/notifications');
    final data = response.data;
    if (data is List) {
      return data.map((e) => NotificationModel.fromJson(e)).toList();
    } else if (data is Map && data['data'] is List) {
      return (data['data'] as List).map((e) => NotificationModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<void> markAllAsRead() async {
    await _apiClient.patch('/api/v1/notifications/read-all');
  }
}
