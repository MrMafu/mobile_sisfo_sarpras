import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';
import 'package:provider/provider.dart';
import '../app_router.dart';
import '../constants/app_constants.dart';
import '../models/item.dart';
import '../services/service_provider.dart';

class ItemsListPage extends StatefulWidget {
  const ItemsListPage({super.key});

  @override
  State<ItemsListPage> createState() => _ItemsListPageState();
}

class _ItemsListPageState extends State<ItemsListPage> {
  final List<Item> _items = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _loading = true);
    try {
      final items = await context.read<ServiceProvider>().itemService.fetch();
      setState(() => _items.addAll(items));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Items')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                'Items',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.accentColor,
                ),
              ),
            ),
            
            // Items list
            Expanded(
              child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                  ? const Center(
                      child: Text(
                        'No items found',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _items.length,
                      itemBuilder: (_, i) {
                        final item = _items[i];
                        return Card(
                          elevation: AppConstants.cardElevation,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppConstants.defaultBorderRadius,
                          ),
                          margin: const EdgeInsets.only(bottom: 16),
                          child: InkWell(
                            borderRadius: AppConstants.defaultBorderRadius,
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                Routes.itemDetails,
                                arguments: {'id': item.id},
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  // Item Image
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: AppConstants.defaultBorderRadius,
                                      color: Colors.grey[100],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: AppConstants.defaultBorderRadius,
                                      child: ImageNetwork(
                                        image: item.image,
                                        height: 60,
                                        width: 60,
                                        fitAndroidIos: BoxFit.cover,
                                        onLoading: const CircularProgressIndicator(strokeWidth: 2),
                                        onError: const Icon(Icons.inventory_2_outlined),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  
                                  // Item Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Stock: ${item.stock}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
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
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}