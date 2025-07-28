import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../services/user_services.dart';

class FormUserScreen extends StatefulWidget {
  final UserModel? user;

  const FormUserScreen({Key? key, this.user}) : super(key: key);

  @override
  State<FormUserScreen> createState() => _FormUserScreenState();
}

class _FormUserScreenState extends State<FormUserScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String email = '';
  String password = '';
  String role = 'kasir';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      name = widget.user!.name;
      email = widget.user!.email;
      role = widget.user!.role;
    }
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => isLoading = true);

    final auth = Provider.of<AuthViewModel>(context, listen: false);

    if (auth.user?.role != 'pemilik') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hanya pemilik yang boleh mengubah data.')),
      );
      setState(() => isLoading = false);
      return;
    }

    bool success;
    if (widget.user != null) {
      success = await UserService().updateUser(
        id: widget.user!.id,
        name: name,
        email: email,
        role: role,
      );
    } else {
      success = await UserService().createUser(
        name: name,
        email: email,
        password: password,
        role: role,
      );
    }

    setState(() => isLoading = false);

    if (success) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.user != null
              ? 'User berhasil diubah'
              : 'User berhasil ditambahkan'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal ${widget.user != null ? 'mengubah' : 'menambahkan'} user'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.user != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit User' : 'Tambah User'),
        elevation: 0,
        backgroundColor: const Color(0xFFFAF1F9),
        foregroundColor: Colors.black,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3D1B10), Color(0xFF9C6B4D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildInputField(
                label: 'Nama',
                initialValue: name,
                onSaved: (val) => name = val!,
              ),
              const SizedBox(height: 12),
              _buildInputField(
                label: 'Email',
                initialValue: email,
                onSaved: (val) => email = val!,
              ),
              const SizedBox(height: 12),
              _buildInputField(
                label: isEdit ? 'Password (opsional)' : 'Password',
                obscure: true,
                validator: (value) {
                  if (!isEdit && (value == null || value.length < 6)) {
                    return 'Minimal 6 karakter';
                  }
                  return null;
                },
                onSaved: (val) => password = val ?? '',
              ),
              const SizedBox(height: 12),
              IgnorePointer(
                ignoring: isEdit, // jika edit, role tidak bisa diubah
                child: DropdownButtonFormField<String>(
                  value: role,
                  decoration: _inputDecoration('Role'),
                  dropdownColor: const Color(0xFF3D1B10),
                  style: const TextStyle(color: Colors.white),
                  iconEnabledColor: Colors.white,
                  items: ['kasir', 'pemilik']
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (value) => setState(() => role = value!),
                ),
              ),
              const SizedBox(height: 30),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        backgroundColor: const Color(0xFFFAF1F9),
                        foregroundColor: Colors.deepPurple,
                        elevation: 5,
                      ),
                      child: Text(
                        isEdit ? 'Simpan Perubahan' : 'Simpan',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    String? initialValue,
    bool obscure = false,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
  }) {
    return TextFormField(
      initialValue: initialValue,
      obscureText: obscure,
      validator: validator ?? (val) => val == null || val.isEmpty ? '$label tidak boleh kosong' : null,
      onSaved: onSaved,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(label),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white),
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.white54),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.white),
      ),
    );
  }
}
