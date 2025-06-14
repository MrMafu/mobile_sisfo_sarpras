// pages/returning_detail_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';
import '../services/service_provider.dart';
import '../models/returning.dart';

class ReturningDetailPage extends StatefulWidget {
  final int returningId;

  const ReturningDetailPage({super.key, required this.returningId});

  @override
  State<ReturningDetailPage> createState() => _ReturningDetailPageState();
}

class _ReturningDetailPageState extends State<ReturningDetailPage> {
  Returning? _returning;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReturning();
  }

  Future<void> _loadReturning() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final serviceProvider = context.read<ServiceProvider>();
      final returning = await serviceProvider.returningService.fetchById(widget.returningId);
      setState(() => _returning = returning);
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
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Returning Details')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
            ? Center(child: Text('Error: $_error'))
            : _returning == null
              ? const Center(child: Text('Returning not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Banner
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getStatusColor(_returning!.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info, color: _getStatusColor(_returning!.status)),
                            const SizedBox(width: 8),
                            Text(
                              'Status: ${_returning!.status.toUpperCase()}',
                              style: TextStyle(
                                color: _getStatusColor(_returning!.status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Returning Overview
                      _buildSection(
                        title: 'Returning Overview',
                        icon: Icons.description,
                        children: [
                          _buildInfoRow('ID', _returning!.id.toString()),
                          _buildInfoRow('Returned Quantity', _returning!.returnedQuantity.toString()),
                          _buildInfoRow('Status', _returning!.status),
                          _buildInfoRow('Created', DateFormat.yMMMd().add_jm().format(_returning!.createdAt)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Borrower Information
                      _buildSection(
                        title: 'Borrower Information',
                        icon: Icons.person,
                        children: [
                          if (_returning!.borrowing?['user'] != null)
                            ...[
                              _buildInfoRow('Username', _returning!.borrowing!['user']['username'] ?? 'N/A'),
                              _buildInfoRow('Role', _returning!.borrowing!['user']['role']?.toString().toUpperCase() ?? 'N/A'),
                            ]
                          else
                            const Text('Borrower information not available', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Assigned Borrowing
                      _buildSection(
                        title: 'Assigned Borrowing',
                        icon: Icons.book,
                        children: [
                          if (_returning!.borrowing != null)
                            ...[
                              _buildInfoRow('Borrowing ID', _returning!.borrowing!['id']?.toString() ?? 'N/A'),
                              _buildInfoRow('Item', _returning!.borrowing!['item']['name'] ?? 'N/A'),
                              _buildInfoRow('Quantity', _returning!.borrowing!['quantity']?.toString() ?? '0'),
                              _buildInfoRow('Due Date', _returning!.borrowing!['due'] != null 
                                ? DateFormat.yMMMd().add_jm().format(DateTime.parse(_returning!.borrowing!['due'])) 
                                : 'N/A'),
                              _buildInfoRow('Status', _returning!.borrowing!['status'] ?? 'N/A'),
                            ]
                          else
                            const Text('Borrowing information not available', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Returned Units
                      _buildSection(
                        title: 'Returned Units',
                        icon: Icons.check_circle,
                        children: [
                          if (_returning!.borrowing?['borrowing_detail'] != null)
                            ..._returning!.borrowing!['borrowing_detail'].take(_returning!.returnedQuantity).map((detail) => 
                              ListTile(
                                leading: const Icon(Icons.check, color: Colors.green),
                                title: Text('SKU: ${detail['item_unit']['sku']}'),
                                subtitle: Text('Status: ${detail['item_unit']['status']}'),
                              )
                            ).toList()
                          else
                            const Text('No units returned yet', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Not Returned Units
                      if (_returning!.borrowing?['borrowing_detail'] != null &&
                          _returning!.borrowing!['borrowing_detail'].length > _returning!.returnedQuantity)
                        _buildSection(
                          title: 'Not Returned Units',
                          icon: Icons.cancel,
                          children: [
                            ..._returning!.borrowing!['borrowing_detail'].skip(_returning!.returnedQuantity).map((detail) => 
                              ListTile(
                                leading: const Icon(Icons.close, color: Colors.red),
                                title: Text('SKU: ${detail['item_unit']['sku']}'),
                                subtitle: Text('Status: ${detail['item_unit']['status']}'),
                              )
                            ).toList()
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