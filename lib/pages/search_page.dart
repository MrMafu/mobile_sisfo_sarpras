import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../app_router.dart';
import '../models/category.dart';
import '../models/item.dart';
import '../services/service_provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final List<Category> _categories = [];
  final List<Item> _items = [];
  bool _loading = false;
  
  Timer? _debounceTimer;
  CancelToken? _currentCancelToken;
  final Duration _debounceDuration = const Duration(milliseconds: 300);
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _currentCancelToken?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final serviceProvider = context.read<ServiceProvider>();

      final Future<List<Category>> categoriesFuture = 
          serviceProvider.categoryService.fetch();
      
      final Future<List<Item>> itemsFuture = 
          serviceProvider.itemService.fetch();
      
      final results = await Future.wait([categoriesFuture, itemsFuture]);
      
      setState(() {
        _categories
          ..clear()
          ..addAll(results[0] as List<Category>);
        _items
          ..clear()
          ..addAll(results[1] as List<Item>);
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _currentCancelToken?.cancel();
    _currentCancelToken = null;

    _debounceTimer = Timer(_debounceDuration, () {
      if (query.isEmpty) {
        _resetItems();
      } else {
        _performSearch(query);
      }
    });
  }

  Future<void> _resetItems() async {
    setState(() => _loading = true);
    try {
      final items = await context.read<ServiceProvider>().itemService.fetch();
      setState(() => _items
        ..clear()
        ..addAll(items));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _performSearch(String query) async {
    final cancelToken = CancelToken();
    _currentCancelToken = cancelToken;
    
    setState(() => _loading = true);
    
    try {
      final items = await context.read<ServiceProvider>().itemService.fetch(
        search: query,
        cancelToken: cancelToken,
      );
      
      if (!cancelToken.isCancelled) {
        setState(() => _items
          ..clear()
          ..addAll(items));
      }
    } on DioException catch (e) {
      if (e.type != DioExceptionType.cancel) {
        print('Search error: ${e.message}');
      }
    } finally {
      if (!cancelToken.isCancelled) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search items…',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _onSearchChanged,
            ),
            const SizedBox(height: 16),

            SizedBox(
              height: 50,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final category = _categories[i];
                  return ActionChip(
                    label: Text(category.name),
                    onPressed: () => Navigator.of(context).pushNamed(
                      Routes.categoryItems,
                      arguments: {'id': category.id, 'name': category.name},
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
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
            ),
          ],
        ),
      ),
    );
  }
}