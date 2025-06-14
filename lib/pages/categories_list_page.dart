import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_router.dart';
import '../constants/app_constants.dart';
import '../models/category.dart';
import '../services/service_provider.dart';

class CategoriesListPage extends StatefulWidget {
  const CategoriesListPage({super.key});

  @override
  State<CategoriesListPage> createState() => _CategoriesListPageState();
}

class _CategoriesListPageState extends State<CategoriesListPage> {
  List<Category> _categories = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _loading = true);
    try {
      final categories = await context.read<ServiceProvider>().categoryService.fetch();
      setState(() => _categories = categories);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Categories')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                'Categories',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.accentColor,
                ),
              ),
            ),
            
            // Categories grid
            Expanded(
              child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _categories.isEmpty
                  ? const Center(
                      child: Text(
                        'No categories found',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: _categories.length,
                      itemBuilder: (_, index) {
                        final category = _categories[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: AppConstants.defaultBorderRadius,
                          ),
                          elevation: AppConstants.cardElevation,
                          child: InkWell(
                            borderRadius: AppConstants.defaultBorderRadius,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                Routes.categoryItems,
                                arguments: {
                                  'id': category.id,
                                  'name': category.name,
                                },
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.category,
                                    size: 40,
                                    color: AppConstants.accentColor,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    category.name,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 16),
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