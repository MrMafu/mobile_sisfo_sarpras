import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';
import '../models/borrowing.dart';
import '../services/borrowing_service.dart';
import '../services/service_provider.dart';
import '../services/returning_service.dart';

class ReturnRequestPage extends StatefulWidget {
  const ReturnRequestPage({super.key});

  @override
  State<ReturnRequestPage> createState() => _ReturnRequestPageState();
}

class _ReturnRequestPageState extends State<ReturnRequestPage> {
  final List<Borrowing> _borrowings = [];
  Borrowing? _selectedBorrowing;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBorrowings();
  }

  Future<void> _loadBorrowings() async {
    setState(() => _loading = true);
    try {
      final borrowings = await context.read<ServiceProvider>().borrowingService.fetchMyBorrowings();
      setState(() => _borrowings
        ..clear()
        ..addAll(borrowings.where((b) => 
          b.status == 'approved' || b.status == 'overdue')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    if (_selectedBorrowing == null) {
      setState(() => _error = 'Please select a borrowing to return');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final serviceProvider = context.read<ServiceProvider>();
      await serviceProvider.returningService.createReturning(
        _selectedBorrowing!.id,
        _selectedBorrowing!.quantity,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Return request submitted successfully')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Return Request')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Borrowing selection
                  const Text('Select Borrowing', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<Borrowing>(
                    value: _selectedBorrowing,
                    items: _borrowings.map((borrowing) {
                      return DropdownMenuItem<Borrowing>(
                        value: borrowing,
                        child: Text(
                          '${borrowing.item?['name'] ?? 'Item'} (Qty: ${borrowing.quantity})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedBorrowing = value),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                  ),
                  
                  if (_selectedBorrowing != null) ...[
                    const SizedBox(height: 24),
                    // Borrowing details
                    Flexible(
                      child: Card(
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedBorrowing!.item?['name'] ?? 'Item',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Text('Quantity: ', style: TextStyle(fontWeight: FontWeight.w500)),
                                  Text(_selectedBorrowing!.quantity.toString()),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Text('Borrowed: ', style: TextStyle(fontWeight: FontWeight.w500)),
                                  Text(DateFormat.yMMMd().format(_selectedBorrowing!.createdAt)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Text('Due: ', style: TextStyle(fontWeight: FontWeight.w500)),
                                  Text(
                                    DateFormat.yMMMd().format(_selectedBorrowing!.due),
                                    style: TextStyle(
                                      color: _selectedBorrowing!.due.isBefore(DateTime.now())
                                        ? Colors.red
                                        : null,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Text('Status: ', style: TextStyle(fontWeight: FontWeight.w500)),
                                  Text(
                                    _selectedBorrowing!.status,
                                    style: TextStyle(
                                      color: _getStatusColor(_selectedBorrowing!.status),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                  
                  const Spacer(),
                  
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.accentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Submit Return Request'),
                    ),
                  ),
                  
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved': return Colors.green;
      case 'pending': return Colors.orange;
      case 'rejected': return Colors.red;
      case 'overdue': return Colors.red;
      case 'returned': return Colors.green;
      default: return Colors.blue;
    }
  }
}