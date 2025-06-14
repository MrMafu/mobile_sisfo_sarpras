import 'api_service.dart';
import 'auth_provider.dart';
import 'borrowing_service.dart';
import 'category_service.dart';
import 'item_details_service.dart';
import 'item_service.dart';
import 'returning_service.dart';

class ServiceProvider {
  final ApiService apiService;
  late final CategoryService categoryService;
  late final ItemService itemService;
  late final ItemDetailsService itemDetailsService;
  late final BorrowingService borrowingService;
  late final ReturningService returningService;

  ServiceProvider({required this.apiService}) {
    categoryService = CategoryService(apiService);
    itemService = ItemService(apiService);
    itemDetailsService = ItemDetailsService(apiService);
    borrowingService = BorrowingService(apiService);
    returningService = ReturningService(apiService);
  }
}