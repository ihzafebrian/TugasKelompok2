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
    final themeGradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF8D6E63), // coklat muda
        Color(0xFF4E342E), // coklat tua
        Color(0xFFD7CCC8), // cream
      ],
    );
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          isEdit ? 'Edit Produk' : 'Tambah Produk',
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: 1.2,
            fontFamily: 'Montserrat',
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: themeGradient),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF795548)))
            : SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.13),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.10),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _nameController,
                              style: const TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
                              decoration: InputDecoration(
                                labelText: 'Nama Produk',
                                labelStyle: TextStyle(color: Colors.white.withOpacity(0.85)),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Colors.white.withOpacity(0.25)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Colors.white),
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.07),
                              ),
                              validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                            ),
                            const SizedBox(height: 18),
                            TextFormField(
                              controller: _priceController,
                              style: const TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
                              decoration: InputDecoration(
                                labelText: 'Harga',
                                labelStyle: TextStyle(color: Colors.white.withOpacity(0.85)),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Colors.white.withOpacity(0.25)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Colors.white),
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.07),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                            ),
                            const SizedBox(height: 18),
                            TextFormField(
                              controller: _stockController,
                              style: const TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
                              decoration: InputDecoration(
                                labelText: 'Stok',
                                labelStyle: TextStyle(color: Colors.white.withOpacity(0.85)),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Colors.white.withOpacity(0.25)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Colors.white),
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.07),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                            ),
                            const SizedBox(height: 18),
                            DropdownButtonFormField<CategoryModel>(
                              value: _selectedCategory,
                              dropdownColor: const Color(0xFF4E342E),
                              style: const TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
                              items: _categories.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(category.categoryName, style: const TextStyle(color: Colors.white)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategory = value;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Kategori',
                                labelStyle: TextStyle(color: Colors.white.withOpacity(0.85)),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Colors.white.withOpacity(0.25)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Colors.white),
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.07),
                              ),
                              validator: (value) => value == null ? 'Wajib dipilih' : null,
                            ),
                            const SizedBox(height: 18),
                            DropdownButtonFormField<SupplierModel>(
                              value: _selectedSupplier,
                              dropdownColor: const Color(0xFF4E342E),
                              style: const TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
                              items: _suppliers.map((supplier) {
                                return DropdownMenuItem(
                                  value: supplier,
                                  child: Text(supplier.supplierName, style: const TextStyle(color: Colors.white)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedSupplier = value;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Supplier',
                                labelStyle: TextStyle(color: Colors.white.withOpacity(0.85)),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Colors.white.withOpacity(0.25)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Colors.white),
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.07),
                              ),
                              validator: (value) => value == null ? 'Wajib dipilih' : null,
                            ),
                            const SizedBox(height: 22),
                            Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.10),
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(10),
                                child: _imageFile != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.file(_imageFile!, height: 120, width: 120, fit: BoxFit.cover),
                                      )
                                    : widget.product?.imageUrl != null
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: Image.network(widget.product!.imageUrl!, height: 120, width: 120, fit: BoxFit.cover),
                                          )
                                        : const Icon(Icons.image, color: Colors.white54, size: 60),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: const Color(0xFF795548),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                textStyle: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
                              ),
                              onPressed: _pickImage,
                              icon: const Icon(Icons.image, color: Colors.white),
                              label: const Text('Pilih Gambar'),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  backgroundColor: const Color(0xFF795548),
                                  foregroundColor: Colors.white,
                                  textStyle: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                                onPressed: _submit,
                                child: Text(isEdit ? 'Update' : 'Simpan'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}