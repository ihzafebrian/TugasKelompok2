import 'package:flutter/material.dart';
import '/models/supplier_model.dart';
import '/services/supplier_service.dart';

class SupplierFormScreen extends StatefulWidget {
  final String token;
  final SupplierModel? supplier;

  const SupplierFormScreen({super.key, required this.token, this.supplier});

  @override
  State<SupplierFormScreen> createState() => _SupplierFormScreenState();
}

class _SupplierFormScreenState extends State<SupplierFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  late SupplierService service;

  @override
  void initState() {
    super.initState();
    service = SupplierService(widget.token);
    if (widget.supplier != null) {
      _nameController.text = widget.supplier!.supplierName;
      _phoneController.text = widget.supplier!.phone;
      _addressController.text = widget.supplier!.address;
    }
  }

  void save() async {
    if (_formKey.currentState!.validate()) {
      final body = {
        'supplier_name': _nameController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
      };

      try {
        if (widget.supplier == null) {
          await service.createSupplier(body);
        } else {
          await service.updateSupplier(widget.supplier!.id, body);
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
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.supplier != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Supplier' : 'Tambah Supplier')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nama Supplier'),
                validator: (value) => value == null || value.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Telepon'),
                validator: (value) => value == null || value.isEmpty ? 'Telepon tidak boleh kosong' : null,
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Alamat'),
                validator: (value) => value == null || value.isEmpty ? 'Alamat tidak boleh kosong' : null,
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
