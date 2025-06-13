import '../models/item_details.dart';
import 'api_service.dart';

class ItemDetailsService {
  final ApiService _api;

  ItemDetailsService(this._api);

  Future<ItemDetails> fetch(int itemId) async {
    final response = await _api.get('/items/$itemId');
    return ItemDetails.fromJson(response.data);
  }
}