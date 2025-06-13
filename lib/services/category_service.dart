import 'api_service.dart';
import '../models/category.dart';

class CategoryService {
  final ApiService _api;

  CategoryService(this._api);

  Future<List<Category>> fetch({String? search}) async {
    final resp = await _api.get('/categories', query: search != null ? {'search': search} : null);
    return (resp.data['data'] as List)
      .map((j) => Category.fromJson(j as Map<String, dynamic>))
      .toList();
  }
}