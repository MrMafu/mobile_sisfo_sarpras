import 'package:flutter/material.dart';
import 'pages/category_items_page.dart';
import 'pages/item_details_page.dart';
import 'pages/login_page.dart';
import 'pages/root_page.dart';

abstract class Routes {
  static const login = '/login';
  static const root = '/';
  static const categoryItems = '/category-items';
  static const itemDetails = '/item-details';
}

class AppRouter {
  static Route onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case Routes.categoryItems:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => CategoryItemsPage(
            categoryId: args['id'],
            categoryName: args['name'],
          ),
        );
      case Routes.itemDetails:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ItemDetailsPage(itemId: args['id']),
        );
      case Routes.root:
      default:
        return MaterialPageRoute(builder: (_) => const RootPage());
    }
  }
}