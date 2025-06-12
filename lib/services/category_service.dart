import '../models/category.dart';
import 'api_service.dart';
import 'package:flutter/foundation.dart' show compute;

class CategoryService {
  final ApiService _api;

  CategoryService(this._api);

  List<Category> _parseCategories(dynamic jsonList) {
    return (jsonList as List)
      .map((j) => Category.fromJson(j as Map<String, dynamic>))
      .toList();
  }

  Future<List<Category>> fetch({String? search}) async {
  final resp = await _api.get('/categories', query: search != null ? {'search': search} : null);
  return compute(_parseCategories, resp.data['data']);
}
}