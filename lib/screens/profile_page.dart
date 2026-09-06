import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../login/database_helper.dart';
import '../login/welcome_page.dart';

class ProfilePage extends StatefulWidget {
  final String username;
  final String? userId;

  const ProfilePage({
    super.key,
    required this.username,
    this.userId,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _address = '';
  String _phone = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await DatabaseHelper.instance.getUserByUsername(widget.username);
      if (userData != null) {
        setState(() {
          _address = userData['address'] as String? ?? '';
          _phone = userData['phone'] as String? ?? '';
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout(BuildContext context) async {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomePage()),
          (route) => false,
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Delete Account', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete account "${widget.username}"? This action cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (widget.userId != null) {
        await DatabaseHelper.instance.deleteUserById(widget.userId!);
      } else {
        await DatabaseHelper.instance.deleteUserById(widget.username);
      }

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Account "${widget.username}" deleted.'),
          backgroundColor: Colors.redAccent,
        ),
      );

      _logout(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('User Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/pic store.webp',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.75),
            ),
          ),
          SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.orangeAccent))
                : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  constraints: const BoxConstraints(maxWidth: 400),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.orangeAccent, width: 2),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          size: 64,
                          color: Colors.orangeAccent,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.username,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Account Details',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.person_outline, color: Colors.orangeAccent, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  'Logged in as ${widget.username}',
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            if (_address.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, color: Colors.orangeAccent, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _address,
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (_phone.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.phone, color: Colors.orangeAccent, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    _phone,
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EditProfilePage(),
                              settings: RouteSettings(arguments: widget.username),
                            ),
                          ).then((_) => _loadUserData());
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.edit_outlined, color: Colors.orangeAccent),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Edit Profile',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      'Update address, phone and PIN',
                                      style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right_rounded, color: Colors.white54),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PurchaseHistoryPage(username: widget.username),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.history_rounded, color: Colors.orangeAccent),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Purchase History',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      'View past orders and receipts',
                                      style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right_rounded, color: Colors.white54),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          onPressed: () => _deleteAccount(context),
                          icon: const Icon(Icons.delete_forever_rounded, size: 20),
                          label: const Text(
                            'Delete Account',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white38),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          onPressed: () => _logout(context),
                          icon: const Icon(Icons.logout_rounded, size: 20),
                          label: const Text(
                            'Logout',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _currentPinController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  bool _obscureCurrentPin = true;
  bool _obscureNewPin = true;
  bool _obscureConfirmPin = true;
  bool _isLoading = true;
  bool _isSaving = false;

  String? _username;
  String? _currentAddress;
  String? _currentPhone;
  String? _currentPin;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _currentPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final args = ModalRoute.of(context)?.settings.arguments as String? ?? '';
      final userData = await DatabaseHelper.instance.getUserByUsername(args);

      if (userData != null) {
        setState(() {
          _username = userData['username'] as String? ?? '';
          _currentAddress = userData['address'] as String? ?? '';
          _currentPhone = userData['phone'] as String? ?? '';
          _currentPin = userData['pin'] as String? ?? '123456';
          _addressController.text = _currentAddress ?? '';
          _phoneController.text = _currentPhone ?? '';
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final username = ModalRoute.of(context)?.settings.arguments as String? ?? '';

      if (username.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not found'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isSaving = false);
        return;
      }

      final address = _addressController.text.trim();
      final phone = _phoneController.text.trim();
      final currentPin = _currentPinController.text.trim();
      final newPin = _newPinController.text.trim();

      if (newPin.isNotEmpty) {
        if (currentPin.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter your current PIN to change it'),
              backgroundColor: Colors.orange,
            ),
          );
          setState(() => _isSaving = false);
          return;
        }

        final userData = await DatabaseHelper.instance.getUserByUsername(username);
        final storedPin = userData?['pin'] as String? ?? '123456';

        if (currentPin != storedPin) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Current PIN is incorrect'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => _isSaving = false);
          return;
        }

        await DatabaseHelper.instance.updateUserPin(username, newPin);
      }

      if (address.isNotEmpty && address != _currentAddress) {
        await DatabaseHelper.instance.updateUserAddress(username, address);
      }

      if (phone.isNotEmpty && phone != _currentPhone) {
        await DatabaseHelper.instance.updateUserPhone(username, phone);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final username = ModalRoute.of(context)?.settings.arguments as String? ?? '';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/pic store.webp',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.75),
            ),
          ),
          SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.orangeAccent))
                : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(24),
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.orangeAccent, width: 2),
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            size: 50,
                            color: Colors.orangeAccent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          username,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Delivery Address',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _addressController,
                        style: const TextStyle(color: Colors.white),
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Enter your delivery address',
                          hintStyle: const TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.05),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white24),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.orangeAccent),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Phone Number',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _phoneController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: 'Enter your phone number',
                          hintStyle: const TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.05),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white24),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.orangeAccent),
                          ),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Divider(color: Colors.white24),
                      const SizedBox(height: 16),
                      const Text(
                        'Change PIN',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _currentPinController,
                        obscureText: _obscureCurrentPin,
                        style: const TextStyle(color: Colors.white),
                        maxLength: 6,
                        decoration: InputDecoration(
                          labelText: 'Current PIN',
                          labelStyle: const TextStyle(color: Colors.white70),
                          hintText: 'Enter current 6-digit PIN',
                          hintStyle: const TextStyle(color: Colors.white38),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureCurrentPin ? Icons.visibility_off : Icons.visibility,
                              color: Colors.white54,
                            ),
                            onPressed: () {
                              setState(() => _obscureCurrentPin = !_obscureCurrentPin);
                            },
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.05),
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
                          final newPin = _newPinController.text;
                          if (newPin.isNotEmpty && (value == null || value.isEmpty)) {
                            return 'Please enter current PIN';
                          }
                          if (value != null && value.isNotEmpty && value.length != 6) {
                            return 'PIN must be 6 digits';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _newPinController,
                        obscureText: _obscureNewPin,
                        style: const TextStyle(color: Colors.white),
                        maxLength: 6,
                        decoration: InputDecoration(
                          labelText: 'New PIN',
                          labelStyle: const TextStyle(color: Colors.white70),
                          hintText: 'Enter new 6-digit PIN (optional)',
                          hintStyle: const TextStyle(color: Colors.white38),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureNewPin ? Icons.visibility_off : Icons.visibility,
                              color: Colors.white54,
                            ),
                            onPressed: () {
                              setState(() => _obscureNewPin = !_obscureNewPin);
                            },
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.05),
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
                          if (value != null && value.isNotEmpty && value.length != 6) {
                            return 'PIN must be 6 digits';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _confirmPinController,
                        obscureText: _obscureConfirmPin,
                        style: const TextStyle(color: Colors.white),
                        maxLength: 6,
                        decoration: InputDecoration(
                          labelText: 'Confirm New PIN',
                          labelStyle: const TextStyle(color: Colors.white70),
                          hintText: 'Confirm new 6-digit PIN',
                          hintStyle: const TextStyle(color: Colors.white38),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPin ? Icons.visibility_off : Icons.visibility,
                              color: Colors.white54,
                            ),
                            onPressed: () {
                              setState(() => _obscureConfirmPin = !_obscureConfirmPin);
                            },
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.05),
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
                          final newPin = _newPinController.text;
                          if (newPin.isNotEmpty && value != newPin) {
                            return 'PINs do not match';
                          }
                          if (value != null && value.isNotEmpty && value.length != 6) {
                            return 'PIN must be 6 digits';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orangeAccent,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          onPressed: _isSaving ? null : _saveChanges,
                          child: _isSaving
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                            ),
                          )
                              : const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white38),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PurchaseHistoryPage extends StatefulWidget {
  final String? username;

  const PurchaseHistoryPage({super.key, this.username});

  @override
  State<PurchaseHistoryPage> createState() => _PurchaseHistoryPageState();
}

class _PurchaseHistoryPageState extends State<PurchaseHistoryPage> {
  List<Map<String, dynamic>> _purchases = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPurchaseHistory();
  }

  Future<void> _loadPurchaseHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final purchases = await DatabaseHelper.instance.getPurchaseHistory(
          widget.username ?? 'guest'
      );
      setState(() {
        _purchases = purchases;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading purchases: $e';
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading purchases: $e')),
        );
      }
    }
  }

  Future<void> _refreshPurchases() async {
    await _loadPurchaseHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Purchase History', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshPurchases,
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/pic store.webp',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.75),
            ),
          ),
          SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.orangeAccent))
                : _error != null
                ? _buildErrorState()
                : _purchases.isEmpty
                ? _buildEmptyState()
                : _buildPurchaseList(),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          padding: const EdgeInsets.all(32),
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 16),
              const Text(
                'Something went wrong',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error ?? 'Failed to load purchase history',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _refreshPurchases,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          padding: const EdgeInsets.all(32),
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.receipt_long_rounded,
                size: 64,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              const Text(
                'No Purchases Yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your completed order history will appear here once you make a purchase.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white54,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Go Shopping'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPurchaseList() {
    return RefreshIndicator(
      onRefresh: _refreshPurchases,
      color: Colors.orangeAccent,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _purchases.length,
        itemBuilder: (context, index) {
          final purchase = _purchases[index];
          final date = DateTime.parse(purchase['purchase_date'] as String);
          final productNames = (purchase['product_names'] as String).split(',');
          final totalAmount = (purchase['total_amount'] as num).toDouble();
          final originalAmount = (purchase['original_amount'] as num).toDouble();
          final savings = (purchase['savings'] as num).toDouble();
          final itemsCount = purchase['items_count'] as int;
          final paymentMethod = purchase['payment_method'] as String;
          final status = purchase['status'] as String? ?? 'completed';
          final orderId = purchase['order_id'] as String;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: Colors.white.withValues(alpha: 0.08),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ExpansionTile(
              leading: const Icon(Icons.receipt, color: Colors.orangeAccent),
              title: Text(
                'Order #${orderId.length > 15 ? orderId.substring(0, 15) + '...' : orderId}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Total: RM${totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.greenAccent, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: status == 'completed'
                              ? Colors.green.withValues(alpha: 0.2)
                              : Colors.orange.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: status == 'completed'
                                ? Colors.green
                                : Colors.orange,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withValues(alpha: 0.3),
                size: 16,
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                                  'Order Details',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Items: $itemsCount',
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Divider(color: Colors.white12),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Subtotal',
                                  style: TextStyle(color: Colors.white54, fontSize: 12),
                                ),
                                Text(
                                  'RM${originalAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ],
                            ),
                            if (savings > 0) ...[
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Savings',
                                    style: TextStyle(color: Colors.green, fontSize: 12),
                                  ),
                                  Text(
                                    '-RM${savings.toStringAsFixed(2)}',
                                    style: const TextStyle(color: Colors.green, fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total Paid',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'RM${totalAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.greenAccent,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Divider(color: Colors.white12),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Payment Method',
                                  style: TextStyle(color: Colors.white54, fontSize: 12),
                                ),
                                Text(
                                  paymentMethod,
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Items Purchased:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...productNames.asMap().entries.map((entry) {
                        final index = entry.key;
                        final name = entry.value.trim();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.shopping_bag_outlined,
                                size: 14,
                                color: Colors.orangeAccent.withValues(alpha: 0.7),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${index + 1}. $name',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
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