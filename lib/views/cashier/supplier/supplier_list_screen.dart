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
    return Scaffold(
      appBar: AppBar(title: Text('Supplier')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SupplierFormScreen(token: widget.token),
            ),
          );
          fetchData();
        },
        child: Icon(Icons.add),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: suppliers.length,
              itemBuilder: (ctx, i) {
                final s = suppliers[i];
                return Card(
                  child: ListTile(
                    title: Text(s.supplierName),
                    subtitle: Text('${s.phone} • ${s.address}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
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
                          icon: Icon(Icons.delete),
                          onPressed: () => deleteSupplier(s.id),
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
