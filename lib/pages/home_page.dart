import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_router.dart';
import '../constants/app_constants.dart';
import '../services/auth_provider.dart';
import '../widgets/action_button.dart';
import '../widgets/logout_dialog.dart';
import '../widgets/quick_access_card.dart';
import '../widgets/recent_activities_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => LogoutConfirmationDialog(
        onConfirm: () async {
          await context.read<AuthProvider>().logout();
          if (context.mounted) {
            Navigator.of(context).pushReplacementNamed(Routes.login);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('SISFO SARPRAS'),
      ),
      extendBodyBehindAppBar: true,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 70, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome,',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    Text(
                      user?.username ?? 'User',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.accentColor,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.red),
                  onPressed: () => _showLogoutDialog(context),
                  tooltip: 'Log Out',
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Quick Access
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    QuickAccessCard(
                      icon: Icons.category,
                      title: 'Categories',
                      onTap: () {},
                    ),
                    QuickAccessCard(
                      icon: Icons.inventory,
                      title: 'Items',
                      onTap: () {},
                    ),
                    QuickAccessCard(
                      icon: Icons.history,
                      title: 'History',
                      onTap: () {
                        Navigator.of(context).pushNamed(Routes.history);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                ActionButton(
                  text: 'Make a Borrow Request',
                  icon: Icons.add,
                  onPressed: () => Navigator.of(context).pushNamed(Routes.borrowRequest),
                ),
                const SizedBox(height: 16),
                ActionButton(
                  text: 'Make a Return Request',
                  icon: Icons.reply,
                  color: AppConstants.accentColor,
                  onPressed: () => Navigator.of(context).pushNamed(Routes.returnRequest),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          
          // Recent Activities Section
          const RecentActivitiesSection(), // Use the new widget
          
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}