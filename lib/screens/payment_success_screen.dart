import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../state/product_store.dart';
import '../main.dart';
import '../../login/database_helper.dart';
import '../screens/profile_page.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final double totalAmount;
  final double originalAmount;
  final double savings;
  final int itemsCount;
  final String paymentMethod;
  final List<String>? purchasedItemIds;
  final String? username;
  final String? address;
  final String? phone;

  const PaymentSuccessScreen({
    super.key,
    required this.totalAmount,
    required this.originalAmount,
    required this.savings,
    required this.itemsCount,
    required this.paymentMethod,
    this.purchasedItemIds,
    this.username,
    this.address,
    this.phone,
  });

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  bool _isSaving = false;
  bool _saveError = false;
  String? _errorMessage;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _savePurchaseToHistory();
    });
    _recordProductPurchases();
    _updateUserInfo();
  }

  Future<void> _updateUserInfo() async {
    if (widget.username == null || widget.username!.isEmpty) return;
    if (widget.address == null && widget.phone == null) return;

    try {
      final db = await DatabaseHelper.instance.database;

      Map<String, dynamic> updates = {};
      if (widget.address != null && widget.address!.isNotEmpty) {
        updates['address'] = widget.address;
      }
      if (widget.phone != null && widget.phone!.isNotEmpty) {
        updates['phone'] = widget.phone;
      }

      if (updates.isNotEmpty) {
        await db.update(
          'users',
          updates,
          where: 'username = ?',
          whereArgs: [widget.username],
        );
      }
    } catch (e) {}
  }

  Future<void> _savePurchaseToHistory() async {
    if (widget.username == null || widget.username!.isEmpty) {
      setState(() {
        _isSaved = true;
        _saveError = true;
        _errorMessage = 'Username not found - using default';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _saveError = false;
      _errorMessage = null;
    });

    try {
      final productIds = widget.purchasedItemIds ??
          ProductStore.instance.cartItems.map((i) => i.product.id).toList();

      final productNames = widget.purchasedItemIds != null
          ? ProductStore.instance.cartItems
          .where((item) => widget.purchasedItemIds!.contains(item.product.id))
          .map((item) => item.product.name)
          .toList()
          : ProductStore.instance.cartItems.map((item) => item.product.name).toList();

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final userPrefix = widget.username!.length >= 3
          ? widget.username!.substring(0, 3).toUpperCase()
          : widget.username!.toUpperCase().padRight(3, 'X');
      final orderId = 'ORD-$timestamp-$userPrefix';

      await DatabaseHelper.instance.savePurchase(
        username: widget.username!,
        orderId: orderId,
        productIds: productIds,
        productNames: productNames,
        totalAmount: widget.totalAmount,
        originalAmount: widget.originalAmount,
        savings: widget.savings,
        itemsCount: widget.itemsCount,
        paymentMethod: widget.paymentMethod,
        purchaseDate: DateTime.now(),
        status: 'completed',
      );

      await DatabaseHelper.instance.getPurchaseHistory(widget.username!);

      setState(() {
        _isSaved = true;
        _isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Purchase recorded successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e, stackTrace) {
      setState(() {
        _saveError = true;
        _errorMessage = e.toString();
        _isSaving = false;
        _isSaved = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving purchase: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _recordProductPurchases() {
    try {
      final ids = (widget.purchasedItemIds != null && widget.purchasedItemIds!.isNotEmpty)
          ? widget.purchasedItemIds!
          : ProductStore.instance.cartItems.map((i) => i.product.id).toList();
      ProductStore.instance.recordPurchase(ids);
    } catch (e) {}
  }

  Future<void> _removePurchasedItemsFromCart() async {
    try {
      final purchasedIds = widget.purchasedItemIds ??
          ProductStore.instance.cartItems.map((i) => i.product.id).toList();

      for (final productId in purchasedIds) {
        ProductStore.instance.removeFromCart(productId);
      }

      if (widget.username != null && widget.username!.isNotEmpty) {
        await DatabaseHelper.instance.saveUserCart(
          widget.username!,
          ProductStore.instance.cartItems,
        );
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Payment Successful'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 80,
              color: AppColors.success,
            ),
            const SizedBox(height: 16),
            const Text(
              'Payment Successful!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You have successfully paid RM${widget.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),

            if (_isSaving)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Saving purchase record...',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

            if (_saveError && !_isSaving)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Could not save purchase record',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_errorMessage != null)
                            Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: Colors.red.withValues(alpha: 0.8),
                                fontSize: 11,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDetailRow('Payment Method', widget.paymentMethod),
                    const Divider(),
                    _buildDetailRow('Items', '${widget.itemsCount} item(s)'),
                    const Divider(),
                    _buildDetailRow('Subtotal', 'RM${widget.originalAmount.toStringAsFixed(2)}'),
                    if (widget.savings > 0) ...[
                      const Divider(),
                      _buildDetailRow('Savings', '-RM${widget.savings.toStringAsFixed(2)}', isGreen: true),
                    ],
                    const Divider(),
                    _buildDetailRow(
                      'Total Paid',
                      'RM${widget.totalAmount.toStringAsFixed(2)}',
                      isBold: true,
                      isGreen: true,
                    ),
                    if (widget.username != null) ...[
                      const Divider(),
                      _buildDetailRow('Customer', widget.username!),
                    ],
                    if (widget.address != null && widget.address!.isNotEmpty) ...[
                      const Divider(),
                      _buildDetailRow('Delivery Address', widget.address!),
                    ],
                    if (widget.phone != null && widget.phone!.isNotEmpty) ...[
                      const Divider(),
                      _buildDetailRow('Phone', widget.phone!),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            Card(
              color: AppColors.primary.withValues(alpha: 0.05),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.local_shipping, color: AppColors.primary),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Your items will be delivered within 3-5 business days',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const SizedBox(width: 40),
                        const Expanded(
                          child: Text(
                            'Thank you for your patience. Your order is being processed.',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : () async {
                  await _removePurchasedItemsFromCart();
                  if (mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => HomeScreen(
                          username: widget.username ?? 'User',
                        ),
                      ),
                      (route) => false,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _isSaving ? 'Saving...' : 'Back to Main Menu',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            if (widget.username != null && !_isSaving)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    final currentUsername = widget.username;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PurchaseHistoryPage(username: currentUsername),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'View Purchase History',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {
    bool isBold = false,
    bool isGreen = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
              fontSize: isBold ? 15 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isGreen ? AppColors.success : (isBold ? AppColors.textPrimary : null),
              fontSize: isBold ? 15 : 14,
            ),
          ),
        ],
      ),
    );
  }
}