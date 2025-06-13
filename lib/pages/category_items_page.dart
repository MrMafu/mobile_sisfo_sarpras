import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';
import 'package:mobile_sisfo_sarpras/services/service_provider.dart';
import 'package:provider/provider.dart';
import '../models/item.dart';
import '../app_router.dart';

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
                onTap: () {
                  Navigator.of(context).pushNamed(
                    Routes.itemDetails,
                    arguments: {'id': it.id},
                  );
                },
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                leading: SizedBox(
                  width: 40,
                  height: 40,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: ImageNetwork(
                      image: it.image,
                      height: 40,
                      width: 40,
                      fitAndroidIos: BoxFit.cover,
                      onLoading: CircularProgressIndicator(),
                    ),
                  ),
                ),
                title: Text(it.name),
                subtitle: Text('Stock: ${it.stock}'),
              );
            },
          ),
    );
  }
}