import '../../../core/network/api_client.dart';
import '../models/dashboard_stats.dart';

class DashboardRepository {
  final ApiClient _apiClient;

  DashboardRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<DashboardStats> getStats() async {
    final response = await _apiClient.get('/api/v1/field-sales/stats');
    return DashboardStats.fromJson(response.data ?? {});
  }
}
