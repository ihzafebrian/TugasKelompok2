import 'package:flutter/material.dart';
import '../../../models/product_model.dart';
import '../../../models/transaction_detail_model.dart';
import '../../../services/transaction_service.dart';
import 'transaction_list_screen.dart';

class TransactionScreen extends StatefulWidget {
  final String token;

  const TransactionScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  List<TransactionDetailModel> items = [];
  double total = 0.0;
  late final TransactionService service;

  @override
  void initState() {
    super.initState();
    service = TransactionService(widget.token);
  }

  void addItem(ProductModel product) {
    final existing = items.where((e) => e.productId == product.id).toList();
    if (existing.isNotEmpty) {
      setState(() {
        existing[0].quantity++;
        existing[0].subtotal = existing[0].quantity * existing[0].price;
        calculateTotal();
      });
    } else {
      setState(() {
        items.add(TransactionDetailModel(
          id: 0,
          productId: product.id!, // ✅ Gunakan null check (!) karena ProductModel.id bertipe int?
          productName: product.productName,
          quantity: 1,
          price: product.price,
          subtotal: product.price,
        ));
        calculateTotal();
      });
    }
  }

  void calculateTotal() {
    total = items.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  void removeItem(int index) {
    setState(() {
      items.removeAt(index);
      calculateTotal();
    });
  }

  void submitTransaction() async {
    try {
      await service.createTransactionWithDetails(
        items,
        supplierId: 1, // Ganti sesuai kebutuhanmu
        image: '',      // Ganti jika ada upload image
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transaksi berhasil')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TransactionListScreen(token: widget.token),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan transaksi')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Form Transaksi')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              child: Text('Tambah Produk'),
              onPressed: () async {
                // Produk dummy
                ProductModel sample = ProductModel(
                  id: 1,
                  productName: 'Produk Contoh',
                  price: 10000,
                  categoryId: 1,
                  supplierId: 1,
                  stock: 10,
                  image: '',
                );

                addItem(sample);
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, index) {
                  final item = items[index];
                  return ListTile(
                    title: Text('${item.productName} x${item.quantity}'),
                    subtitle: Text('Rp ${item.subtotal.toStringAsFixed(0)}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => removeItem(index),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Total: Rp ${total.toStringAsFixed(0)}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: submitTransaction,
              child: Text('Bayar'),
            ),
          ],
        ),
      ),
    );
  }
}
