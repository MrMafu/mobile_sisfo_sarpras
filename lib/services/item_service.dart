import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/item.dart';

class ItemService {
  final ApiService _api;

  ItemService(this._api);

  Future<List<Item>> fetch({
    String? search,
    int? categoryId,
    CancelToken? cancelToken,
  }) async {
    final query = <String, dynamic>{};
    if (search?.isNotEmpty == true) query['search'] = search;
    if (categoryId != null) query['category_id'] = categoryId.toString();
    
    final resp = await _api.get(
      '/items',
      query: query.isEmpty ? null : query,
      cancelToken: cancelToken,
    );
    
    return (resp.data['data'] as List)
      .map((j) => Item.fromJson(j as Map<String, dynamic>))
      .toList();
  }
}