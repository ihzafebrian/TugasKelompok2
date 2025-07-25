import 'package:flutter/material.dart';
import '/models/supplier_model.dart';
import '/services/supplier_service.dart';
import 'supplier_form_screen.dart';

class SupplierListScreen extends StatefulWidget {
  final String token;
  const SupplierListScreen({super.key, required this.token});

  @override
  State<SupplierListScreen> createState() => _SupplierListScreenState();
}

class _SupplierListScreenState extends State<SupplierListScreen> {
  late SupplierService service;
  List<SupplierModel> suppliers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    service = SupplierService(widget.token);
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final data = await service.fetchSuppliers();
      setState(() {
        suppliers = data;
        isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() => isLoading = false);
    }
  }

  void deleteSupplier(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Hapus Supplier"),
        content: Text("Yakin ingin menghapus supplier ini?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text("Batal")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text("Hapus")),
        ],
      ),
    );

    if (confirm == true) {
      await service.deleteSupplier(id);
      fetchData();
    }
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
          'Kelola Supplier',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: 1.2,
            fontFamily: 'Montserrat',
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF795548),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SupplierFormScreen(token: widget.token),
            ),
          );
          fetchData();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: themeGradient),
        child: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF795548)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  itemCount: suppliers.length,
                  itemBuilder: (ctx, i) {
                    final s = suppliers[i];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.13),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.10),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        title: Text(s.supplierName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Montserrat')),
                        subtitle: Text('${s.phone} 2 ${s.address}', style: const TextStyle(color: Colors.white70, fontFamily: 'Montserrat')),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Color(0xFFFFD54F)),
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SupplierFormScreen(token: widget.token, supplier: s),
                                  ),
                                );
                                fetchData();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => deleteSupplier(s.id),
                            ),
                          ],
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
