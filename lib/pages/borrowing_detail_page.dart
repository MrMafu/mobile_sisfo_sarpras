import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';
import '../services/service_provider.dart';
import '../models/borrowing.dart';

class BorrowingDetailPage extends StatefulWidget {
  final int borrowingId;

  const BorrowingDetailPage({super.key, required this.borrowingId});

  @override
  State<BorrowingDetailPage> createState() => _BorrowingDetailPageState();
}

class _BorrowingDetailPageState extends State<BorrowingDetailPage> {
  Borrowing? _borrowing;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBorrowing();
  }

  Future<void> _loadBorrowing() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final serviceProvider = context.read<ServiceProvider>();
      final borrowing = await serviceProvider.borrowingService.fetchById(widget.borrowingId);
      setState(() => _borrowing = borrowing);
    } catch (e) {
      setState(() => _error = e.toString());
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
      case 'returned': return Colors.blue;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Borrowing Details')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
            ? Center(child: Text('Error: $_error'))
            : _borrowing == null
              ? const Center(child: Text('Borrowing not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Banner
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getStatusColor(_borrowing!.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info, color: _getStatusColor(_borrowing!.status)),
                            const SizedBox(width: 8),
                            Text(
                              'Status: ${_borrowing!.status.toUpperCase()}',
                              style: TextStyle(
                                color: _getStatusColor(_borrowing!.status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Borrowing Overview
                      _buildSection(
                        title: 'Borrowing Overview',
                        icon: Icons.description,
                        children: [
                          _buildInfoRow('Item', _borrowing!.item?['name'] ?? 'N/A'),
                          _buildInfoRow('Quantity', _borrowing!.quantity.toString()),
                          _buildInfoRow('Status', _borrowing!.status),
                          _buildInfoRow('Due Date', DateFormat.yMMMd().add_jm().format(_borrowing!.due)),
                          _buildInfoRow('Created', DateFormat.yMMMd().add_jm().format(_borrowing!.createdAt)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Borrower Information
                      _buildSection(
                        title: 'Borrower Information',
                        icon: Icons.person,
                        children: [
                          _buildInfoRow('Username', _borrowing!.user?['username'] ?? 'N/A'),
                          _buildInfoRow('Role', _borrowing!.user?['role']?.toString().toUpperCase() ?? 'N/A'),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Borrowed Units
                      _buildSection(
                        title: 'Borrowed Units',
                        icon: Icons.inventory,
                        children: [
                          if (_borrowing!.borrowingDetails != null && _borrowing!.borrowingDetails!.isNotEmpty)
                            ..._borrowing!.borrowingDetails!.map((detail) => 
                              ListTile(
                                leading: const Icon(Icons.shopping_bag, color: AppConstants.accentColor),
                                title: Text('SKU: ${detail['item_unit']['sku']}'),
                                subtitle: Text('Status: ${detail['item_unit']['status']}'),
                              )
                            ).toList()
                          else
                            const Text('No units assigned yet', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Return Status
                      _buildSection(
                        title: 'Return Status',
                        icon: Icons.assignment_return,
                        children: [
                          if (_borrowing!.returning != null)
                            ...[
                              _buildInfoRow('Status', _borrowing!.returning?['status'] ?? 'N/A'),
                              _buildInfoRow('Returned Quantity', _borrowing!.returning?['returned_quantity']?.toString() ?? '0'),
                              _buildInfoRow('Returned At', _borrowing!.returning?['returned_at'] != null 
                                ? DateFormat.yMMMd().add_jm().format(DateTime.parse(_borrowing!.returning!['returned_at'])) 
                                : 'N/A'),
                            ]
                          else
                            const Text('No return request registered', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSection({required String title, required IconData icon, required List<Widget> children}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppConstants.accentColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}