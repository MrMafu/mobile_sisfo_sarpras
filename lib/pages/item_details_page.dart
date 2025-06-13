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
      appBar: AppBar(title: const Text('Item Details')),
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
                          Center(
                            child: Column(
                              children: [
                                SizedBox(
                                  width: 200,
                                  height: 200,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: ImageNetwork(
                                      image: _item!.image,
                                      height: 200,
                                      width: 200,
                                      fitAndroidIos: BoxFit.cover,
                                      onLoading: const CircularProgressIndicator(),
                                      onError: const Icon(Icons.broken_image, size: 40),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _item!.name,
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Stock: ${_item!.stock}',
                                  style: const TextStyle(fontSize: 18),
                                ),
                                if (_item!.category != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Category: ${_item!.category!['name']}',
                                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          const Text(
                            'Item Units',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _item!.units.length,
                            itemBuilder: (_, index) {
                              final unit = _item!.units[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  title: Text(unit.sku, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text('ID: ${unit.id}'),
                                  trailing: Chip(
                                    label: Text(
                                      unit.status.toUpperCase(),
                                      style: const TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                    backgroundColor: _getStatusColor(unit.status),
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