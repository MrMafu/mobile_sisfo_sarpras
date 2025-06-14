import 'package:flutter/material.dart';
import 'pages/root_page.dart';
import 'pages/login_page.dart';
import 'pages/category_items_page.dart';
import 'pages/item_details_page.dart';
import 'pages/history_page.dart';
import 'pages/borrow_request_page.dart';
import 'pages/return_request_page.dart';
import 'pages/borrowing_detail_page.dart';
import 'pages/returning_detail_page.dart';

abstract class Routes {
  static const root = '/';
  static const login = '/login';
  static const categoryItems = '/category-items';
  static const itemDetails = '/item-details';
  static const history = '/history';
  static const borrowRequest = '/borrow-request';
  static const returnRequest = '/return-request';
  static const borrowingDetail = '/borrowing-detail';
  static const returningDetail = '/returning-detail';
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
      case Routes.history:
        return MaterialPageRoute(builder: (_) => const HistoryPage());
      case Routes.borrowRequest:
        return MaterialPageRoute(builder: (_) => const BorrowRequestPage());
      case Routes.returnRequest:
        return MaterialPageRoute(builder: (_) => const ReturnRequestPage());
      case Routes.borrowingDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => BorrowingDetailPage(borrowingId: args['id']),
        );
      case Routes.returningDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ReturningDetailPage(returningId: args['id']),
        );
      case Routes.root:
      default:
        return MaterialPageRoute(builder: (_) => const RootPage());
    }
  }
}