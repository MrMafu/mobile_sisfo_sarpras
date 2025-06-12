import 'package:flutter/material.dart';
import '../widgets/bottom_navbar.dart';
import 'home_page.dart';
import 'search_page.dart';
// TODO: import your HistoryPage and ProfilePage when ready

class RootPage extends StatefulWidget {
  const RootPage({super.key});
  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int _currentIndex = 0;
  static const _pages = [
    HomePage(),
    SearchPage(),
    Placeholder(),
    Placeholder(),
  ];

  void _onTap(int idx) => setState(() => _currentIndex = idx);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
      ),
    );
  }
}