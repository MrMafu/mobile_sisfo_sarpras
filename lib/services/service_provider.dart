import 'api_service.dart';
import 'category_service.dart';
import 'item_details_service.dart';
import 'item_service.dart';

class ServiceProvider {
  final ApiService apiService;
  late final CategoryService categoryService;
  late final ItemService itemService;
  late final ItemDetailsService itemDetailsService;

  ServiceProvider({required this.apiService}) {
    categoryService = CategoryService(apiService);
    itemService = ItemService(apiService);
    itemDetailsService = ItemDetailsService(apiService);
  }
}