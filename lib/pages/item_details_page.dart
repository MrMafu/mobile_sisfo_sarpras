import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../models/item_details.dart';
import '../services/service_provider.dart';

class ItemDetailsPage extends StatefulWidget {
  final int itemId;
  const ItemDetailsPage({super.key, required this.itemId});

  @override
  State<ItemDetailsPage> createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  ItemDetails? _item;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItemDetails();
  }

  Future<void> _loadItemDetails() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    
    try {
      final item = await context.read<ServiceProvider>().itemDetailsService.fetch(widget.itemId);
      setState(() => _item = item);
    } catch (e) {
      setState(() => _error = 'Failed to load item details');
    } finally {
      setState(() => _loading = false);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available': return Colors.green;
      case 'borrowed': return Colors.orange;
      case 'overdue': return Colors.red;
      case 'lost': return Colors.grey;
      default: return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _item == null
                  ? const Center(child: Text('Item not found'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Item Header Card
                          Card(
                            elevation: AppConstants.cardElevation,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppConstants.defaultBorderRadius,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Item Image
                                  Container(
                                    width: 180,
                                    height: 180,
                                    decoration: BoxDecoration(
                                      borderRadius: AppConstants.defaultBorderRadius,
                                      color: Colors.grey[100],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: AppConstants.defaultBorderRadius,
                                      child: ImageNetwork(
                                        image: _item!.image,
                                        height: 180,
                                        width: 180,
                                        fitAndroidIos: BoxFit.cover,
                                        onLoading: const CircularProgressIndicator(),
                                        onError: const Icon(Icons.inventory_2_outlined, size: 40),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Item Name
                                  Text(
                                    _item!.name,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  
                                  // Stock Information
                                  Text(
                                    'Stock: ${_item!.stock}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: AppConstants.accentColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  
                                  // Category
                                  if (_item!.category != null)
                                    Text(
                                      'Category: ${_item!.category!['name']}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Units Section Header
                          const Text(
                            'Item Units',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.accentColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Units List
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _item!.units.length,
                            itemBuilder: (_, index) {
                              final unit = _item!.units[index];
                              return Card(
                                elevation: AppConstants.cardElevation,
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppConstants.defaultBorderRadius,
                                ),
                                margin: const EdgeInsets.only(bottom: 16),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      // Status Indicator
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(unit.status).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.qr_code_2,
                                          color: _getStatusColor(unit.status),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      
                                      // Unit Info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              unit.sku,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'ID: ${unit.id}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      // Status Chip
                                      Chip(
                                        label: Text(
                                          unit.status.toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        backgroundColor: _getStatusColor(unit.status),
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
    );
  }
}