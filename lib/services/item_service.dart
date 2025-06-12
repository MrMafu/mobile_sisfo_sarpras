import '../models/item.dart';
import 'api_service.dart';
import 'package:flutter/foundation.dart' show compute;

class ItemService {
  final ApiService _api;

  ItemService(this._api);

  List<Item> _parseItems(dynamic jsonList) {
    final list = jsonList as List;
    return list.map((j) => Item.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<List<Item>> fetch({String? search, int? categoryId}) async {
    final query = <String, dynamic>{};
    if (search?.isNotEmpty == true) query['search'] = search;
    if (categoryId != null) query['category_id'] = categoryId.toString();
    
    final resp = await _api.get('/items', query: query.isEmpty ? null : query);
    return compute(_parseItems, resp.data['data']);
  }
}