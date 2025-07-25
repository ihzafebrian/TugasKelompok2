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
          isEdit ? 'Edit Supplier' : 'Tambah Supplier',
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
        child: SafeArea(
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
                          labelText: 'Nama Supplier',
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
                        validator: (value) => value == null || value.isEmpty ? 'Nama tidak boleh kosong' : null,
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _phoneController,
                        style: const TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
                        decoration: InputDecoration(
                          labelText: 'Telepon',
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
                        validator: (value) => value == null || value.isEmpty ? 'Telepon tidak boleh kosong' : null,
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _addressController,
                        style: const TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
                        decoration: InputDecoration(
                          labelText: 'Alamat',
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
                        validator: (value) => value == null || value.isEmpty ? 'Alamat tidak boleh kosong' : null,
                      ),
                      const SizedBox(height: 28),
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
                          onPressed: save,
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
