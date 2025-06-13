import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';
import 'package:provider/provider.dart';
import '../app_router.dart';
import '../models/item.dart';
import '../services/service_provider.dart';

class CategoryItemsPage extends StatefulWidget {
  final int categoryId;
  final String categoryName;
  
  const CategoryItemsPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryItemsPage> createState() => _CategoryItemsPageState();
}

class _CategoryItemsPageState extends State<CategoryItemsPage> {
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
      final items = await context.read<ServiceProvider>().itemService.fetch(
        categoryId: widget.categoryId,
      );
      setState(() => _items.addAll(items));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.categoryName)),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _items.length,
            itemBuilder: (_, i) {
              final item = _items[i];
              return ListTile(
                onTap: () {
                  Navigator.of(context).pushNamed(
                    Routes.itemDetails,
                    arguments: {'id': item.id},
                  );
                },
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                leading: SizedBox(
                  width: 40,
                  height: 40,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: ImageNetwork(
                      image: item.image,
                      height: 40,
                      width: 40,
                      fitAndroidIos: BoxFit.cover,
                      onLoading: const CircularProgressIndicator(),
                    ),
                  ),
                ),
                title: Text(item.name),
                subtitle: Text('Stock: ${item.stock}'),
              );
            },
          ),
    );
  }
}