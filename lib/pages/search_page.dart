import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../app_router.dart';
import '../constants/app_constants.dart';
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
      appBar: AppBar(
        title: const Text('Search'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Field
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search items…',
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: AppConstants.accentColor),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppConstants.accentColor),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              onChanged: _onSearchChanged,
            ),
            const SizedBox(height: 24),

            // Categories Section
            const Text(
              'Categories',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppConstants.accentColor,
              ),
            ),
            const SizedBox(height: 12),
            
            SizedBox(
              height: 50,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) {
                  final category = _categories[i];
                  return Card(
                    elevation: AppConstants.cardElevation,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppConstants.defaultBorderRadius,
                    ),
                    child: InkWell(
                      borderRadius: AppConstants.defaultBorderRadius,
                      onTap: () => Navigator.of(context).pushNamed(
                        Routes.categoryItems,
                        arguments: {'id': category.id, 'name': category.name},
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Center(
                          child: Text(
                            category.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Results Section
            const Text(
              'List of Items',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppConstants.accentColor,
              ),
            ),
            const SizedBox(height: 12),
            
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