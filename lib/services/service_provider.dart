import 'api_service.dart';
import 'auth_provider.dart';
import 'category_service.dart';
import 'item_service.dart';
import 'item_details_service.dart';

class ServiceProvider {
  final ApiService apiService;
  final AuthProvider authProvider;
  late final CategoryService categoryService;
  late final ItemService itemService;
  late final ItemDetailsService itemDetailsService;

  ServiceProvider({
    required this.apiService,
    required this.authProvider,
  }) {
    categoryService = CategoryService(apiService);
    itemService = ItemService(apiService);
    itemDetailsService = ItemDetailsService(apiService);
  }
}