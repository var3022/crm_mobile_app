import '../../../core/network/api_client.dart';
import '../models/visit_model.dart';

class VisitsRepository {
  final ApiClient _apiClient;

  VisitsRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<List<VisitModel>> getVisits() async {
    final response = await _apiClient.get('/api/v1/field-sales/visits');
    final data = response.data;
    if (data is List) {
      return data.map((e) => VisitModel.fromJson(e)).toList();
    } else if (data is Map && data['data'] is List) {
      return (data['data'] as List).map((e) => VisitModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<void> scheduleVisit(VisitModel visit) async {
    await _apiClient.post('/api/v1/field-sales/visits', data: visit.toJson());
  }

  Future<void> checkin(String id) async {
    await _apiClient.post('/api/v1/field-sales/checkin', data: {'visitId': id});
  }

  Future<void> checkout(String id) async {
    await _apiClient.post('/api/v1/field-sales/checkout', data: {'visitId': id});
  }
}
