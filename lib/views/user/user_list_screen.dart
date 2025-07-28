import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../services/user_services.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../utils/app_theme.dart'; // ⬅️ untuk tema
import 'user_form_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({Key? key}) : super(key: key);

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<UserModel> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final auth = Provider.of<AuthViewModel>(context, listen: false);
    try {
      final result = await UserService().getUsers(auth.token!);
      setState(() {
        users = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching users: $e');
    }
  }

  void _confirmDelete(int userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus User'),
        content: const Text('Yakin ingin menghapus user ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await UserService().deleteUser(userId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User berhasil dihapus')),
        );
        fetchUsers();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menghapus user')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthViewModel>(context);
    final isPemilik = auth.user?.role == 'pemilik';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppTheme.themedAppBar('Daftar User'),
      body: Container(
        decoration: AppTheme.mainBackground(),
        padding: const EdgeInsets.only(top: kToolbarHeight + 20),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : users.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada user.',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : ListView.separated(
                    itemCount: users.length,
                    separatorBuilder: (_, __) => const Divider(color: Colors.white24),
                    itemBuilder: (_, index) {
                      final user = users[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.white24,
                          child: Text(user.name[0].toUpperCase()),
                        ),
                        title: Text(
                          user.name,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${user.email} • ${user.role}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: isPemilik
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.lightBlueAccent),
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => FormUserScreen(user: user),
                                        ),
                                      );
                                      if (result == true) {
                                        fetchUsers();
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                                    onPressed: () => _confirmDelete(user.id),
                                  ),
                                ],
                              )
                            : null,
                      );
                    },
                  ),
      ),
      floatingActionButton: isPemilik
          ? FloatingActionButton(
              backgroundColor: Colors.deepPurpleAccent,
              child: const Icon(Icons.add),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FormUserScreen(),
                  ),
                );
                if (result == true) {
                  fetchUsers();
                }
              },
            )
          : null,
    );
  }
}
