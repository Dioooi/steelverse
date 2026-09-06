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

  Future<void> _updateUserBalance(int userId, String username, double currentBalance) async {
    final balanceController = TextEditingController(text: currentBalance.toStringAsFixed(2));

    final bool? updated = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.white24),
        ),
        title: Row(
          children: [
            const Icon(Icons.account_balance_wallet, color: Colors.orangeAccent),
            const SizedBox(width: 8),
            const Text('Update Balance', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'User: $username',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: balanceController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'New Balance (RM)',
                labelStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.money, color: Colors.orangeAccent),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.orangeAccent),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a balance';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orangeAccent,
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              final balance = double.tryParse(balanceController.text);
              if (balance != null && balance >= 0) {
                Navigator.pop(context, true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid balance amount'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );

    if (updated == true) {
      final newBalance = double.parse(balanceController.text);
      await DatabaseHelper.instance.updateUserBalance(username, newBalance);
      await _loadUsers();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Balance updated to RM${newBalance.toStringAsFixed(2)}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _updateUserPin(int userId, String username, String currentPin) async {
    final pinController = TextEditingController(text: currentPin);
    final confirmPinController = TextEditingController(text: currentPin);

    final bool? updated = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.white24),
        ),
        title: Row(
          children: [
            const Icon(Icons.lock_outline, color: Colors.orangeAccent),
            const SizedBox(width: 8),
            const Text('Update PIN', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'User: $username',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'New PIN (6 digits)',
                labelStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.lock, color: Colors.orangeAccent),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.orangeAccent),
                ),
                counterText: '',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a PIN';
                }
                if (value.length != 6) {
                  return 'PIN must be exactly 6 digits';
                }
                if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                  return 'PIN must contain only numbers';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: confirmPinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Confirm PIN',
                labelStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.lock_outline, color: Colors.orangeAccent),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.orangeAccent),
                ),
                counterText: '',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your PIN';
                }
                if (value != pinController.text) {
                  return 'PINs do not match';
                }
                return null;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orangeAccent,
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              if (pinController.text.length == 6 &&
                  confirmPinController.text == pinController.text) {
                Navigator.pop(context, true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid 6-digit PIN'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            child: const Text('Update PIN'),
          ),
        ],
      ),
    );

    if (updated == true) {
      final newPin = pinController.text;
      await DatabaseHelper.instance.updateUserPin(username, newPin);
      await _loadUsers();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PIN updated successfully'),
            backgroundColor: Colors.green,
          ),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadUsers,
          ),
        ],
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
          final balance = (user['balance'] as num?)?.toDouble() ?? 0.0;
          final pin = user['pin'] as String? ?? '123456';

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
            child: ExpansionTile(
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
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    email,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  Text(
                    'Balance: RM${balance.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.orangeAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.lock_outline,
                      color: Colors.blueAccent,
                      size: 20,
                    ),
                    tooltip: 'Update PIN',
                    onPressed: () => _updateUserPin(userId, username, pin),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.account_balance_wallet,
                      color: Colors.orangeAccent,
                      size: 20,
                    ),
                    tooltip: 'Update Balance',
                    onPressed: () => _updateUserBalance(userId, username, balance),
                  ),
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
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'User Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Username',
                                  style: TextStyle(color: Colors.white54, fontSize: 12),
                                ),
                                Text(
                                  username,
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Email',
                                  style: TextStyle(color: Colors.white54, fontSize: 12),
                                ),
                                Text(
                                  email,
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Balance',
                                  style: TextStyle(color: Colors.white54, fontSize: 12),
                                ),
                                Text(
                                  'RM${balance.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.orangeAccent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'PIN',
                                  style: TextStyle(color: Colors.white54, fontSize: 12),
                                ),
                                Text(
                                  '••••••',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Status',
                                  style: TextStyle(color: Colors.white54, fontSize: 12),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isBlocked
                                        ? Colors.red.withValues(alpha: 0.2)
                                        : Colors.green.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    isBlocked ? 'Blocked' : 'Active',
                                    style: TextStyle(
                                      color: isBlocked ? Colors.red : Colors.green,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.blueAccent,
                              side: const BorderSide(color: Colors.blueAccent),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () => _updateUserPin(userId, username, pin),
                            icon: const Icon(Icons.lock_outline, size: 16),
                            label: const Text('Update PIN'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.orangeAccent,
                              side: const BorderSide(color: Colors.orangeAccent),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () => _updateUserBalance(userId, username, balance),
                            icon: const Icon(Icons.account_balance_wallet, size: 16),
                            label: const Text('Update Balance'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}