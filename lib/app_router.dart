import 'package:flutter/material.dart';
import 'pages/root_page.dart';
import 'pages/login_page.dart';
import 'pages/category_items_page.dart';

abstract class Routes {
  static const login         = '/login';
  static const root          = '/';
  static const categoryItems = '/category-items';
}

class AppRouter {
  static Route onGenerateRoute(RouteSettings s) {
    switch (s.name) {
      case Routes.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case Routes.categoryItems:
        final args = s.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => CategoryItemsPage(
            categoryId: args['id'],
            categoryName: args['name'],
          ),
        );
      case Routes.root:
      default:
        return MaterialPageRoute(builder: (_) => const RootPage());
    }
  }
}