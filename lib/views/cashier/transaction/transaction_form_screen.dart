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
          'Tambah Transaksi',
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final minHeight = constraints.maxHeight;
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: minHeight),
                  child: IntrinsicHeight(
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: dateController,
                              readOnly: true,
                              style: const TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
                              decoration: InputDecoration(
                                labelText: 'Tanggal Transaksi',
                                labelStyle: TextStyle(color: Colors.white.withOpacity(0.85)),
                                suffixIcon: const Icon(Icons.calendar_today, color: Colors.white70),
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
                              onTap: pickDateTime,
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Metode Pembayaran',
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
                              dropdownColor: const Color(0xFF4E342E),
                              style: const TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
                              value: selectedPaymentMethod,
                              items: paymentMethodOptions
                                  .map((method) =>
                                      DropdownMenuItem(value: method, child: Text(method, style: const TextStyle(color: Colors.white))))
                                  .toList(),
                              onChanged: (val) => setState(() {
                                selectedPaymentMethod = val!;
                              }),
                            ),
                            const SizedBox(height: 16),
                            if (categories.isNotEmpty)
                              DropdownButtonFormField<CategoryModel>(
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
                                dropdownColor: const Color(0xFF4E342E),
                                style: const TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
                                value: selectedCategory,
                                items: categories
                                    .map((cat) => DropdownMenuItem(
                                        value: cat, child: Text(cat.categoryName, style: const TextStyle(color: Colors.white))))
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
                            const SizedBox(height: 16),
                            if (products.isNotEmpty)
                              DropdownButtonFormField<ProductModel>(
                                decoration: InputDecoration(
                                  labelText: 'Produk',
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
                                dropdownColor: const Color(0xFF4E342E),
                                style: const TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
                                value: selectedProduct,
                                items: products
                                    .map((prod) => DropdownMenuItem(
                                          value: prod,
                                          child:
                                              Text('${prod.productName} (Stok: ${prod.stock})', style: const TextStyle(color: Colors.white)),
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
                                    style: const TextStyle(color: Colors.white70, fontFamily: 'Montserrat'),
                                  ),
                                ),
                              ),
                            Row(
                              children: [
                                const Text('Qty:', style: TextStyle(color: Colors.white, fontFamily: 'Montserrat')),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    initialValue: '1',
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
                                    decoration: InputDecoration(
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
                                    onChanged: (val) {
                                      quantity = int.tryParse(val) ?? 1;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF795548),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    textStyle: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: addToCart,
                                  child: const Text('Tambah Produk'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            const Divider(color: Colors.white24),
                            const Text('Produk dalam Transaksi',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Montserrat')),
                            const SizedBox(height: 8),
                            ...cart.asMap().entries.map((entry) {
                              final index = entry.key;
                              final item = entry.value;
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.10),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ListTile(
                                  title: Text(item['product_name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Montserrat')),
                                  subtitle: Text('Qty: ${item['quantity']} • Harga: ${currency.format(item['price'])}', style: const TextStyle(color: Colors.white70, fontFamily: 'Montserrat')),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(currency.format(item['subtotal']), style: const TextStyle(color: Color(0xFFFFD54F), fontWeight: FontWeight.bold)),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => removeFromCart(index),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                            const Divider(color: Colors.white24),
                            ListTile(
                              title: const Text('Total Belanja', style: TextStyle(color: Colors.white, fontFamily: 'Montserrat')),
                              trailing: Text(
                                currency.format(totalPrice),
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFD54F), fontFamily: 'Montserrat'),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton.icon(
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
                                onPressed: cart.isEmpty ? null : submitTransaction,
                                icon: const Icon(Icons.payment),
                                label: const Text('Proses Pembayaran'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
