import 'package:flutter/material.dart';
import '/models/category_model.dart';
import '/services/category_service.dart';
import 'category_form_screen.dart';

class CategoryListScreen extends StatefulWidget {
  final String token;
  const CategoryListScreen({super.key, required this.token});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  late CategoryService service;
  List<CategoryModel> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    service = CategoryService(widget.token);
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final data = await service.fetchCategories();
      setState(() {
        categories = data;
        isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() => isLoading = false);
    }
  }

  void deleteCategory(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Hapus Kategori"),
        content: Text("Yakin ingin menghapus kategori ini?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text("Batal")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text("Hapus")),
        ],
      ),
    );

    if (confirm == true) {
      await service.deleteCategory(id);
      fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kategori')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CategoryFormScreen(token: widget.token)),
          );
          fetchData();
        },
        child: Icon(Icons.add),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: categories.length,
              itemBuilder: (ctx, i) {
                final c = categories[i];
                return Card(
                  child: ListTile(
                    title: Text(c.categoryName),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CategoryFormScreen(token: widget.token, category: c),
                              ),
                            );
                            fetchData();
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => deleteCategory(c.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
