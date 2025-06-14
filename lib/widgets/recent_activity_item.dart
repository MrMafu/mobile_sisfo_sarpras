import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class RecentActivityItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final DateTime date;
  final VoidCallback? onTap;

  const RecentActivityItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.date,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: AppConstants.accentColor.withOpacity(0.1),
        child: Icon(icon, color: AppConstants.accentColor),
      ),
      title: Text(title),
      subtitle: Text('${DateFormat.yMMMd().add_jm().format(date)} - $subtitle'),
      textColor: Colors.grey[600],
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppConstants.accentColor,
      ),
    );
  }
}