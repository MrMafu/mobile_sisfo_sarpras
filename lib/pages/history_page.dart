import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../constants/app_constants.dart';
import '../models/borrowing.dart';
import '../models/history_item.dart';
import '../models/returning.dart';
import '../services/service_provider.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<HistoryItem> _allItems = [];
  List<Borrowing> _borrowings = [];
  List<Returning> _returnings = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() => _loading = true);
    try {
      final serviceProvider = context.read<ServiceProvider>();
      final results = await Future.wait([
        serviceProvider.borrowingService.fetch(),
        serviceProvider.returningService.fetch(),
      ]);
      
      _borrowings = results[0] as List<Borrowing>;
      _returnings = results[1] as List<Returning>;
      
      _allItems = [
        ..._borrowings.map((b) => HistoryItem(
          type: 'borrowing',
          data: b,
          date: b.createdAt,
        )),
        ..._returnings.map((r) => HistoryItem(
          type: 'returning',
          data: r,
          date: r.createdAt,
        )),
      ]..sort((a, b) => b.date.compareTo(a.date));
      
    } finally {
      setState(() => _loading = false);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'approved': return Colors.green;
      case 'rejected': return Colors.red;
      case 'overdue': return Colors.red;
      case 'returned': return Colors.green;
      default: return Colors.blue;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return 'Pending';
      case 'approved': return 'Approved';
      case 'rejected': return 'Rejected';
      case 'overdue': return 'Overdue';
      case 'returned': return 'Returned';
      default: return status;
    }
  }

  Widget _buildBorrowingItem(Borrowing borrowing) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  borrowing.item?['name'] ?? 'Item',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text(
                    _getStatusText(borrowing.status),
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: _getStatusColor(borrowing.status),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Quantity: ${borrowing.quantity}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            Text(
              'Due: ${DateFormat.yMMMd().format(borrowing.due)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            Text(
              'Requested: ${DateFormat.yMMMd().add_jm().format(borrowing.createdAt)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReturningItem(Returning returning) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  returning.borrowing?['item']?['name'] ?? 'Item',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text(
                    _getStatusText(returning.status),
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: _getStatusColor(returning.status),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Quantity: ${returning.returnedQuantity}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            Text(
              'Requested: ${DateFormat.yMMMd().add_jm().format(returning.createdAt)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(List<HistoryItem> items) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (items.isEmpty) {
      return const Center(
        child: Text('No history found'),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          if (item.type == 'borrowing') {
            return _buildBorrowingItem(item.data as Borrowing);
          } else {
            return _buildReturningItem(item.data as Returning);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History Requests'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppConstants.accentColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppConstants.accentColor,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Borrows'),
            Tab(text: 'Returns'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // All Tab
          _buildHistoryList(_allItems),
          
          // Borrows Tab
          _buildHistoryList(_borrowings
            .map((b) => HistoryItem(
              type: 'borrowing',
              data: b,
              date: b.createdAt,
            ))
            .toList()
          ),
          
          // Returns Tab
          _buildHistoryList(_returnings
            .map((r) => HistoryItem(
              type: 'returning',
              data: r,
              date: r.createdAt,
            ))
            .toList()
          ),
        ],
      ),
    );
  }
}