import '../../../core/network/api_client.dart';
import '../models/lead_model.dart';

class LeadsRepository {
  final ApiClient _apiClient;

  LeadsRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<List<LeadModel>> getLeads() async {
    final response = await _apiClient.get('/api/v1/leads');
    final data = response.data;
    if (data is List) {
      return data.map((e) => LeadModel.fromJson(e)).toList();
    } else if (data is Map && data['data'] is List) {
      return (data['data'] as List).map((e) => LeadModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<void> updateLeadStatus(String id, String status) async {
    await _apiClient.patch('/api/v1/leads/$id/status', data: {
      'status': status,
    });
  }
}
