import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../models/borrowing.dart';
import '../models/returning.dart';
import '../services/service_provider.dart';
import 'recent_activity_item.dart';

class RecentActivitiesSection extends StatefulWidget {
  const RecentActivitiesSection({super.key});

  @override
  State<RecentActivitiesSection> createState() => _RecentActivitiesSectionState();
}

class _RecentActivitiesSectionState extends State<RecentActivitiesSection> {
  List<dynamic> _activities = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadRecentActivities();
  }

  Future<void> _loadRecentActivities() async {
    setState(() => _loading = true);
    try {
      final serviceProvider = context.read<ServiceProvider>();
      
      final borrowings = await serviceProvider.borrowingService.fetchRecent(limit: 3);
      final returnings = await serviceProvider.returningService.fetchRecent(limit: 3);
      
      final activities = [
        ...borrowings,
        ...returnings,
      ]..sort((a, b) {
          final aDate = a is Borrowing ? a.createdAt : (a as Returning).createdAt;
          final bDate = b is Borrowing ? b.createdAt : (b as Returning).createdAt;
          return bDate.compareTo(aDate);
        });
      
      setState(() => _activities = activities.take(3).toList());
    } finally {
      setState(() => _loading = false);
    }
  }

  String _getActionText(dynamic activity) {
    if (activity is Borrowing) {
      switch (activity.status.toLowerCase()) {
        case 'approved': return 'Approved';
        case 'pending': return 'Requested';
        case 'rejected': return 'Rejected';
        case 'returned': return 'Returned';
        case 'overdue': return 'Overdue';
        default: return 'Borrowed';
      }
    } else if (activity is Returning) {
      switch (activity.status.toLowerCase()) {
        case 'approved': return 'Return approved';
        case 'pending': return 'Return requested';
        case 'rejected': return 'Return rejected';
        default: return 'Return processed';
      }
    }
    return 'Activity';
  }

  String _getItemName(dynamic activity) {
    if (activity is Borrowing) {
      return activity.item?['name'] ?? 'Item';
    } else if (activity is Returning) {
      return activity.borrowing?['item']?['name'] ?? 'Item';
    }
    return 'Item';
  }

  IconData _getIcon(dynamic activity) {
    if (activity is Borrowing) {
      return Icons.inventory;
    } else if (activity is Returning) {
      return Icons.check_circle;
    }
    return Icons.history;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        
        if (_loading)
          const Center(child: CircularProgressIndicator())
        else if (_activities.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('No recent activities'),
          )
        else
          Column(
            children: [
              ..._activities.map((activity) {
                return RecentActivityItem(
                  title: '${_getActionText(activity)}: ${_getItemName(activity)}',
                  subtitle: activity is Borrowing 
                    ? 'Quantity: ${activity.quantity}' 
                    : 'Quantity: ${activity.returnedQuantity}',
                  icon: _getIcon(activity),
                  date: activity is Borrowing 
                    ? activity.createdAt 
                    : activity.createdAt,
                  onTap: () {
                    // Handle navigation to details if needed
                  },
                );
              }).toList(),
            ],
          ),
      ],
    );
  }
}