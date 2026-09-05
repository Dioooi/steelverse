import 'package:flutter/material.dart';
import '../login/database_helper.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final users = await DatabaseHelper.instance.getAllUsers();
    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  Future<void> _toggleBlockUser(int userId, int currentBlockStatus) async {
    final newStatus = currentBlockStatus == 1 ? 0 : 1;
    await DatabaseHelper.instance.updateUserBlockStatus(userId, newStatus);
    await _loadUsers();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newStatus == 1 ? 'User has been blocked.' : 'User has been unblocked.'),
          backgroundColor: newStatus == 1 ? Colors.redAccent : Colors.green,
        ),
      );
    }
  }

  Future<void> _deleteUser(int userId, String username) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Delete User', style: TextStyle(color: Colors.white)),
        content: Text('Are you sure you want to delete "$username"?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.deleteUser(userId);
      await _loadUsers();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User "$username" deleted successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orangeAccent))
          : _users.isEmpty
          ? const Center(
        child: Text('No registered users found.', style: TextStyle(color: Colors.white54)),
      )
          : ListView.builder(
        itemCount: _users.length,
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, index) {
          final user = _users[index];
          final userId = user['id'] as int;
          final username = user['username'] ?? 'Unknown';
          final email = user['email'] ?? '';
          final isBlocked = (user['is_blocked'] ?? 0) == 1;

          if (username.toLowerCase() == 'admin') return const SizedBox.shrink();

          return Card(
            color: Colors.white.withValues(alpha: 0.08),
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isBlocked ? Colors.redAccent.withValues(alpha: 0.5) : Colors.white12,
              ),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isBlocked ? Colors.redAccent : Colors.orangeAccent,
                child: Text(
                  username.isNotEmpty ? username[0].toUpperCase() : 'U',
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                username,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  decoration: isBlocked ? TextDecoration.lineThrough : null,
                ),
              ),
              subtitle: Text(
                email,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      isBlocked ? Icons.lock_open : Icons.block,
                      color: isBlocked ? Colors.greenAccent : Colors.orangeAccent,
                    ),
                    tooltip: isBlocked ? 'Unblock User' : 'Block User',
                    onPressed: () => _toggleBlockUser(userId, isBlocked ? 1 : 0),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    tooltip: 'Delete User',
                    onPressed: () => _deleteUser(userId, username),
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