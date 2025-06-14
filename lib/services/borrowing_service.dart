import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'api_service.dart';
import '../models/borrowing.dart';

class BorrowingService {
  final ApiService _api;

  BorrowingService(this._api);

  Future<List<Borrowing>> fetch() async {
    final response = await _api.get('/borrowings');
    return (response.data['data'] as List)
      .map((j) => Borrowing.fromJson(j as Map<String, dynamic>))
      .toList();
  }

  Future<List<Borrowing>> fetchMyBorrowings() async {
    final response = await _api.get('/borrowings');
    return (response.data['data'] as List)
      .map((j) => Borrowing.fromJson(j as Map<String, dynamic>))
      .toList();
  }

  Future<List<Borrowing>> fetchRecent({int limit = 5}) async {
    final response = await _api.get('/borrowings', query: {
      'limit': limit.toString(),
      'sort': 'created_at',
      'direction': 'desc'
    });
    return (response.data['data'] as List)
      .map((j) => Borrowing.fromJson(j as Map<String, dynamic>))
      .toList();
  }

  Future<void> createBorrowing(int itemId, int quantity, DateTime due) async {
    final formattedDue = DateFormat('yyyy-MM-dd HH:mm:ss').format(due);
    await _api.post('/borrowings', {
      'item_id': itemId,
      'quantity': quantity,
      'due': formattedDue,
    });
  }
}