import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_router.dart';
import '../constants/app_constants.dart';
import '../services/auth_provider.dart';
import '../widgets/action_button.dart';
import '../widgets/logout_dialog.dart';
import '../widgets/quick_access_card.dart';

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
                  tooltip: 'Logout',
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
                      onTap: () {},
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
                  onPressed: () {},
                ),
                const SizedBox(height: 16),
                ActionButton(
                  text: 'Make a Return Request',
                  icon: Icons.reply,
                  color: AppConstants.accentColor,
                  onPressed: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Recent Activities
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Recent Activities',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppConstants.accentColor,
              ),
            ),
          ),
          const SizedBox(height: 16),

          ListTile(
            leading: CircleAvatar(
              backgroundColor: AppConstants.accentColor.withOpacity(0.1),
              child: const Icon(Icons.inventory, color: AppConstants.accentColor),
            ),
            title: const Text('Item borrowed: Projector'),
            subtitle: const Text('July 12, 2023 - 10:30 AM'),
            textColor: Colors.grey[600],
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppConstants.accentColor,
            ),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: AppConstants.accentColor.withOpacity(0.1),
              child: const Icon(Icons.check_circle, color: AppConstants.accentColor),
            ),
            title: const Text('Return approved: Laptop'),
            subtitle: const Text('July 11, 2023 - 03:15 PM'),
            textColor: Colors.grey[600],
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppConstants.accentColor,
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}