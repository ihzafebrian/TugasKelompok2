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
        title: const Text(
          'Kelola Produk',
          style: TextStyle(
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
        child: SafeArea(
          child: FutureBuilder<List<ProductModel>>(
            future: _futureProducts,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF795548)));
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Tidak ada produk.', style: TextStyle(color: Colors.white70)));
              }

              final products = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.13),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.10),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.brown.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: product.imageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(
                                    product.imageUrl!,
                                    width: 64,
                                    height: 64,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.image_not_supported, color: Colors.white, size: 36),
                                  ),
                                )
                              : const Icon(Icons.inventory_2, color: Colors.white, size: 36),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                product.productName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Montserrat',
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Harga: Rp${product.price} | Stok: ${product.stock}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontFamily: 'Montserrat',
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Color(0xFFFFD54F)),
                              onPressed: () => _navigateToForm(product: product),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => _deleteProduct(product.id!),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF795548),
        onPressed: () => _navigateToForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
