import 'package:flutter/material.dart';
import 'package:frontend_vaporate/models/product_model.dart';
import 'package:frontend_vaporate/services/product_service.dart';
import 'product_form_screen.dart';

class ProductListScreen extends StatefulWidget {
  final String token;
  const ProductListScreen({super.key, required this.token});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late ProductService _productService;
  late Future<List<ProductModel>> _futureProducts;

  @override
  void initState() {
    super.initState();
    _productService = ProductService(widget.token);
    _loadProducts();
  }

  void _loadProducts() {
    setState(() {
      _futureProducts = _productService.fetchProducts();
    });
  }

  void _deleteProduct(int id) async {
    try {
      await _productService.deleteProduct(id);
      _loadProducts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus produk: $e')),
      );
    }
  }

  void _navigateToForm({ProductModel? product}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductFormScreen(token: widget.token, product: product),
      ),
    );
    _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Produk')),
      body: FutureBuilder<List<ProductModel>>(
        future: _futureProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada produk.'));
          }

          final products = snapshot.data!;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                leading: product.imageUrl != null
                    ? Image.network(product.imageUrl!, width: 50, height: 50, fit: BoxFit.cover)
                    : const Icon(Icons.image_not_supported),
                title: Text(product.productName),
                subtitle: Text('Harga: Rp${product.price} | Stok: ${product.stock}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _navigateToForm(product: product),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteProduct(product.id!),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
