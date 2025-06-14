import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../app_router.dart';
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

  Widget _buildHistoryItemTile(HistoryItem item) {
    final isBorrowing = item.type == 'borrowing';
    final data = item.data;
    
    String itemName;
    String quantityText;
    IconData icon;
    String status;
    DateTime date;
    
    if (isBorrowing) {
      final borrowing = data as Borrowing;
      itemName = borrowing.item?['name'] ?? 'Item';
      quantityText = 'Quantity: ${borrowing.quantity}';
      icon = Icons.inventory;
      status = borrowing.status;
      date = borrowing.createdAt;
    } else {
      final returning = data as Returning;
      itemName = returning.borrowing?['item']?['name'] ?? 'Item';
      quantityText = 'Returned: ${returning.returnedQuantity}';
      icon = Icons.check_circle;
      status = returning.status;
      date = returning.createdAt;
    }
    
    return Card(
      elevation: AppConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: AppConstants.defaultBorderRadius,
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: AppConstants.defaultBorderRadius,
        onTap: () {
          if (isBorrowing) {
            Navigator.of(context).pushNamed(
              Routes.borrowingDetail,
              arguments: {'id': (data as Borrowing).id},
            );
          } else {
            Navigator.of(context).pushNamed(
              Routes.returningDetail,
              arguments: {'id': (data as Returning).id},
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon with status color
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: _getStatusColor(status)),
              ),
              const SizedBox(width: 16),
              
              // Item Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          itemName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      quantityText,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat.yMMMd().add_jm().format(date),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              Chip(
                label: Text(
                  _getStatusText(status),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
                backgroundColor: _getStatusColor(status),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),

              const SizedBox(width: 8),
              
              // Arrow Icon
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppConstants.accentColor,
              ),
            ],
          ),
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
        child: Text(
          'No history found',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return _buildHistoryItemTile(items[index]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History Requests'),
        centerTitle: true,
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