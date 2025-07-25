import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend_vaporate/models/product_model.dart';
import 'package:frontend_vaporate/models/category_model.dart';
import 'package:frontend_vaporate/models/supplier_model.dart';
import 'package:frontend_vaporate/services/product_service.dart';
import 'package:frontend_vaporate/services/category_service.dart';
import 'package:frontend_vaporate/services/supplier_service.dart';

class ProductFormScreen extends StatefulWidget {
  final String token;
  final ProductModel? product;

  const ProductFormScreen({super.key, required this.token, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  File? _imageFile;
  final _picker = ImagePicker();

  List<CategoryModel> _categories = [];
  List<SupplierModel> _suppliers = [];
  CategoryModel? _selectedCategory;
  SupplierModel? _selectedSupplier;
  bool _isLoading = true;

  bool get isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.productName ?? '');
    _priceController = TextEditingController(text: widget.product?.price.toString() ?? '');
    _stockController = TextEditingController(text: widget.product?.stock.toString() ?? '');
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    try {
      final categoryService = CategoryService(widget.token);
      final supplierService = SupplierService(widget.token);

      final fetchedCategories = await categoryService.fetchCategories();
      final fetchedSuppliers = await supplierService.fetchSuppliers();

      setState(() {
        _categories = fetchedCategories;
        _suppliers = fetchedSuppliers;

        if (isEdit) {
          _selectedCategory = _categories.firstWhere(
            (cat) => cat.id == widget.product!.categoryId,
            orElse: () => _categories.first,
          );
          _selectedSupplier = _suppliers.firstWhere(
            (sup) => sup.id == widget.product!.supplierId,
            orElse: () => _suppliers.first,
          );
        }

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null || _selectedSupplier == null) return;

    final product = ProductModel(
      id: widget.product?.id,
      productName: _nameController.text,
      price: double.tryParse(_priceController.text) ?? 0,
      stock: int.tryParse(_stockController.text) ?? 0,
      categoryId: _selectedCategory!.id,
      supplierId: _selectedSupplier!.id,
      image: _imageFile?.path ?? widget.product?.image,
    );

    final service = ProductService(widget.token);
    try {
      if (isEdit) {
        await service.updateProduct(product, imageFile: _imageFile);
      } else {
        await service.createProduct(product, imageFile: _imageFile);
      }
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan produk: $e')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Produk' : 'Tambah Produk')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Nama Produk'),
                      validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Harga'),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    TextFormField(
                      controller: _stockController,
                      decoration: const InputDecoration(labelText: 'Stok'),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<CategoryModel>(
                      value: _selectedCategory,
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category.categoryName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                      decoration: const InputDecoration(labelText: 'Kategori'),
                      validator: (value) => value == null ? 'Wajib dipilih' : null,
                    ),
                    DropdownButtonFormField<SupplierModel>(
                      value: _selectedSupplier,
                      items: _suppliers.map((supplier) {
                        return DropdownMenuItem(
                          value: supplier,
                          child: Text(supplier.supplierName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSupplier = value;
                        });
                      },
                      decoration: const InputDecoration(labelText: 'Supplier'),
                      validator: (value) => value == null ? 'Wajib dipilih' : null,
                    ),
                    const SizedBox(height: 16),
                    _imageFile != null
                        ? Image.file(_imageFile!, height: 150)
                        : widget.product?.imageUrl != null
                            ? Image.network(widget.product!.imageUrl!, height: 150)
                            : const Text('Tidak ada gambar'),
                    TextButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image),
                      label: const Text('Pilih Gambar'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _submit,
                      child: Text(isEdit ? 'Update' : 'Simpan'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}