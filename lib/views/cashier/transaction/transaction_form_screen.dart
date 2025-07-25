import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/transaction_service.dart';
import '../../../models/product_model.dart';
import '../../../models/category_model.dart';
import '../../../services/product_service.dart';
import '../../../services/category_service.dart';

class TransactionFormScreen extends StatefulWidget {
  final String token;

  const TransactionFormScreen({super.key, required this.token});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  late TransactionService transactionService;
  late ProductService productService;
  late CategoryService categoryService;

  List<CategoryModel> categories = [];
  List<ProductModel> products = [];

  CategoryModel? selectedCategory;
  ProductModel? selectedProduct;
  int quantity = 1;

  List<Map<String, dynamic>> cart = [];

  double get totalPrice =>
      cart.fold(0, (sum, item) => sum + (item['subtotal'] as double));

  final paymentMethodOptions = ['cash', 'transfer', 'ewallet', 'qris'];
  String selectedPaymentMethod = 'cash';

  DateTime? selectedDate;
  final TextEditingController dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    transactionService = TransactionService(widget.token);
    productService = ProductService(widget.token);
    categoryService = CategoryService(widget.token);
    fetchCategories();

    selectedDate = DateTime.now();
    dateController.text =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedDate!);
  }

  Future<void> fetchCategories() async {
    try {
      final data = await categoryService.fetchCategories();
      setState(() {
        categories = data;
        selectedCategory = data.isNotEmpty ? data[0] : null;
      });
      if (selectedCategory != null) fetchProducts();
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  Future<void> fetchProducts() async {
    try {
      final data =
          await productService.fetchProductsByCategory(selectedCategory!.id);
      setState(() {
        products = data;
        selectedProduct = data.isNotEmpty ? data[0] : null;
      });
    } catch (e) {
      print('Error loading products: $e');
    }
  }

  void addToCart() {
    if (selectedProduct == null || quantity < 1) return;

    final existingItem = cart.firstWhere(
      (item) => item['product_id'] == selectedProduct!.id,
      orElse: () => {},
    );
    final existingQty = existingItem.isNotEmpty ? existingItem['quantity'] : 0;
    final totalRequestedQty = quantity + (existingQty ?? 0);

    if (totalRequestedQty > selectedProduct!.stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Stok tidak mencukupi. Maksimum tersedia: ${selectedProduct!.stock}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final subtotal = selectedProduct!.price * quantity;

    setState(() {
      if (existingItem.isNotEmpty) {
        existingItem['quantity'] += quantity;
        existingItem['subtotal'] =
            existingItem['quantity'] * selectedProduct!.price;
      } else {
        cart.add({
          'product_id': selectedProduct!.id,
          'product_name': selectedProduct!.productName,
          'price': selectedProduct!.price,
          'quantity': quantity,
          'subtotal': subtotal,
        });
      }
    });
  }

  void removeFromCart(int index) {
    setState(() => cart.removeAt(index));
  }

  Future<void> submitTransaction() async {
    try {
      final formattedDate =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedDate!);

      final trxId = await transactionService.createTransaction({
        'user_id': '2',
        'total_price': totalPrice.toString(),
        'payment_method': selectedPaymentMethod,
        'payment_status': 'pending',
        'transaction_date': formattedDate,
      });

      for (var item in cart) {
        await transactionService.addTransactionDetail({
          'transaction_id': trxId.toString(),
          'product_id': item['product_id'].toString(),
          'quantity': item['quantity'].toString(),
          'price': item['price'].toString(),
          'subtotal': item['subtotal'].toString(),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Transaksi berhasil disimpan!'),
        backgroundColor: Colors.green,
      ));

      Navigator.pop(context, true);
    } catch (e) {
      print('Gagal menyimpan transaksi: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Gagal menyimpan transaksi'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDate ?? DateTime.now()),
      );

      if (pickedTime != null) {
        final combined = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        setState(() {
          selectedDate = combined;
          dateController.text =
              DateFormat('yyyy-MM-dd HH:mm:ss').format(combined);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');

    return Scaffold(
      appBar: AppBar(title: Text('Tambah Transaksi')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: dateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Tanggal Transaksi',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: pickDateTime,
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Metode Pembayaran'),
              value: selectedPaymentMethod,
              items: paymentMethodOptions
                  .map((method) =>
                      DropdownMenuItem(value: method, child: Text(method)))
                  .toList(),
              onChanged: (val) => setState(() {
                selectedPaymentMethod = val!;
              }),
            ),
            SizedBox(height: 16),
            if (categories.isNotEmpty)
              DropdownButtonFormField<CategoryModel>(
                decoration: InputDecoration(labelText: 'Kategori'),
                value: selectedCategory,
                items: categories
                    .map((cat) => DropdownMenuItem(
                        value: cat, child: Text(cat.categoryName)))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    selectedCategory = val;
                    selectedProduct = null;
                    products = [];
                    fetchProducts();
                  });
                },
              ),
            SizedBox(height: 16),
            if (products.isNotEmpty)
              DropdownButtonFormField<ProductModel>(
                decoration: InputDecoration(labelText: 'Produk'),
                value: selectedProduct,
                items: products
                    .map((prod) => DropdownMenuItem(
                          value: prod,
                          child:
                              Text('${prod.productName} (Stok: ${prod.stock})'),
                        ))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    selectedProduct = val;
                  });
                },
              ),
            if (selectedProduct != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Stok tersedia: ${selectedProduct!.stock}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
              ),
            Row(
              children: [
                Text('Qty:'),
                SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: '1',
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      quantity = int.tryParse(val) ?? 1;
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: addToCart,
                  child: Text('Tambah Produk'),
                ),
              ],
            ),
            SizedBox(height: 24),
            Divider(),
            Text('Produk dalam Transaksi',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            ...cart.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return ListTile(
                title: Text(item['product_name']),
                subtitle: Text(
                    'Qty: ${item['quantity']} • Harga: ${currency.format(item['price'])}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(currency.format(item['subtotal'])),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => removeFromCart(index),
                    ),
                  ],
                ),
              );
            }),
            Divider(),
            ListTile(
              title: Text('Total Belanja'),
              trailing: Text(
                currency.format(totalPrice),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: cart.isEmpty ? null : submitTransaction,
              icon: Icon(Icons.payment),
              label: Text('Proses Pembayaran'),
            ),
          ],
        ),
      ),
    );
  }
}
