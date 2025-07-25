import 'package:flutter/material.dart';
import '/models/category_model.dart';
import '/services/category_service.dart';

class CategoryFormScreen extends StatefulWidget {
  final String token;
  final CategoryModel? category;

  const CategoryFormScreen({super.key, required this.token, this.category});

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late CategoryService service;

  @override
  void initState() {
    super.initState();
    service = CategoryService(widget.token);
    if (widget.category != null) {
      _nameController.text = widget.category!.categoryName;
    }
  }

    void save() async {
    if (_formKey.currentState!.validate()) {
      try {
        final category = CategoryModel(
          id: widget.category?.id ?? 0, // id diisi saat edit
          categoryName: _nameController.text,
        );

        if (widget.category == null) {
          await service.createCategory(category);
        } else {
          await service.updateCategory(category);
        }

        Navigator.pop(context);
      } catch (e) {
        print('Error: $e');
      }
    }
  }


  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.category != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Kategori' : 'Tambah Kategori')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nama Kategori'),
                validator: (value) => value == null || value.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: save,
                child: Text(isEdit ? 'Update' : 'Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
