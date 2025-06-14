import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';
import '../models/item.dart';
import '../services/service_provider.dart';
import '../services/borrowing_service.dart';

class BorrowRequestPage extends StatefulWidget {
  const BorrowRequestPage({super.key});

  @override
  State<BorrowRequestPage> createState() => _BorrowRequestPageState();
}

class _BorrowRequestPageState extends State<BorrowRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final List<Item> _items = [];
  Item? _selectedItem;
  int _quantity = 1;
  DateTime? _dueDate;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _loading = true);
    try {
      final items = await context.read<ServiceProvider>().itemService.fetch();
      setState(() => _items
        ..clear()
        ..addAll(items.where((item) => item.stock > 0)));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();

    final ThemeData customTheme = Theme.of(context).copyWith(
      colorScheme: ColorScheme.light(
        primary: AppConstants.accentColor,
        onPrimary: Colors.white,
        onSurface: Colors.black,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppConstants.accentColor,
        ),
      ),
      textTheme: const TextTheme(
        titleMedium: TextStyle(fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(fontSize: 16),
        labelLarge: TextStyle(color: Colors.black),
      ),
    );

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: customTheme,
          child: child!,
        );
      },
    );
    
    if (pickedDate != null) {
      TimeOfDay initialTime = const TimeOfDay(hour: 17, minute: 0);

      if (pickedDate.year == now.year &&
          pickedDate.month == now.month &&
          pickedDate.day == now.day) {
        initialTime = TimeOfDay(
          hour: now.hour,
          minute: now.minute,
        ).replacing(minute: (now.minute ~/ 10) * 10 + 10);
      }

      final pickedTime = await showTimePicker(
        context: context,
        initialTime: initialTime,
        builder: (context, child) {
          return Theme(
            data: customTheme.copyWith(
              colorScheme: customTheme.colorScheme.copyWith(
                primary: AppConstants.accentColor,
              ),
            ),
            child: child!,
          );
        },
      );
      
      if (pickedTime != null) {
        setState(() {
          _dueDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedItem == null) {
      setState(() => _error = 'Please select an item');
      return;
    }

    if (_dueDate == null) {
      setState(() => _error = 'Please select date and time');
      return;
    }

    if (_dueDate!.isBefore(DateTime.now())) {
      setState(() => _error = 'Due date must be in the future');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final serviceProvider = context.read<ServiceProvider>();
      await serviceProvider.borrowingService.createBorrowing(
        _selectedItem!.id,
        _quantity,
        _dueDate!,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Borrow request submitted successfully')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      final msg = e.toString();
      setState(() => _error = msg);
      debugPrint('Error: $msg');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Borrow Request')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Item selection
                    const Text('Select Item', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<Item>(
                      value: _selectedItem,
                      items: _items.map((item) {
                        return DropdownMenuItem<Item>(
                          value: item,
                          child: Text('${item.name} (Stock: ${item.stock})'),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedItem = value),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                      validator: (value) => value == null ? 'Please select an item' : null,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Quantity
                    const Text('Quantity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: _quantity.toString(),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                      onChanged: (value) {
                        final qty = int.tryParse(value) ?? 1;
                        setState(() => _quantity = qty.clamp(1, _selectedItem?.stock ?? 1));
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter quantity';
                        final qty = int.tryParse(value) ?? 0;
                        if (qty <= 0) return 'Quantity must be at least 1';
                        if (_selectedItem != null && qty > _selectedItem!.stock) {
                          return 'Exceeds available stock';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Due Date & Time
                    const Text('Due Date & Time', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _dueDate != null 
                                ? '${DateFormat.yMMMd().format(_dueDate!)} ${DateFormat.Hm().format(_dueDate!)}' 
                                : 'Select date and time',
                            ),
                            const Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
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
                        child: const Text('Submit Request'),
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
            ),
    );
  }
}