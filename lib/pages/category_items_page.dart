import 'package:flutter/material.dart';
import 'package:mobile_sisfo_sarpras/services/service_provider.dart';
import 'package:provider/provider.dart';
import '../models/item.dart';

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
  List<Item> _items = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadByCategory();
  }

  Future<void> _loadByCategory() async {
    final serviceProvider = context.read<ServiceProvider>();
    
    setState(() => _loading = true);
    final items = await serviceProvider.itemService.fetch(
      categoryId: widget.categoryId,
    );
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext _) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.categoryName)),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _items.length,
            itemBuilder: (_, i) {
              final it = _items[i];
              return ListTile(
                leading: it.image.isNotEmpty
                  ? Image.network(it.image, width: 40, height: 40, fit: BoxFit.cover)
                  : const Icon(Icons.inventory),
                title: Text(it.name),
                subtitle: Text('Stock: ${it.stock}'),
              );
            },
          ),
    );
  }
}