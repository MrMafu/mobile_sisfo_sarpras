import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/returning.dart';

class ReturningService {
  final ApiService _api;

  ReturningService(this._api);

  Future<List<Returning>> fetch() async {
    final response = await _api.get('/returnings');
    return (response.data['data'] as List)
      .map((j) => Returning.fromJson(j as Map<String, dynamic>))
      .toList();
  }

  Future<List<Returning>> fetchRecent({int limit = 5}) async {
    final response = await _api.get('/returnings', query: {
      'limit': limit.toString(),
      'sort': 'created_at',
      'direction': 'desc'
    });
    return (response.data['data'] as List)
      .map((j) => Returning.fromJson(j as Map<String, dynamic>))
      .toList();
  }

  Future<void> createReturning(int borrowingId, int quantity) async {
    await _api.post('/returnings', {
      'borrowing_id': borrowingId,
      'returned_quantity': quantity,
    });
  }
}