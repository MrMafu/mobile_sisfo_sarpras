import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';
import 'package:provider/provider.dart';
import 'package:mobile_sisfo_sarpras/services/service_provider.dart';
import '../models/category.dart';
import '../models/item.dart';
import '../app_router.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Category> _cats = [];
  List<Item> _items = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _reloadAll();
  }

  Future<void> _reloadAll() async {
    final serviceProvider = context.read<ServiceProvider>();
    
    setState(() => _loading = true);
    final results = await Future.wait([
      serviceProvider.categoryService.fetch(),
      serviceProvider.itemService.fetch(),
    ]);
    setState(() {
      _cats  = results[0] as List<Category>;
      _items = results[1] as List<Item>;
      _loading = false;
    });
  }

  Future<void> _onSearch(String q) async {
    final serviceProvider = context.read<ServiceProvider>();
    
    setState(() => _loading = true);
    final items = await serviceProvider.itemService.fetch(search: q);
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext _) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- Search Bar ---
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search items…',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onSubmitted: _onSearch,
            ),
            const SizedBox(height: 16),

            // --- Categories Row ---
            SizedBox(
              height: 50,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _cats.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final c = _cats[i];
                  return ActionChip(
                    label: Text(c.name),
                    onPressed: () => Navigator.of(context).pushNamed(
                      Routes.categoryItems,
                      arguments: {'id': c.id, 'name': c.name},
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // --- Item List ---
            Expanded(
              child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
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
            ),
          ],
        ),
      ),
    );
  }
}