// lib/screens/payment/payment_success_screen.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../state/product_store.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final double totalAmount;
  final double originalAmount;
  final double savings;
  final int itemsCount;
  final String paymentMethod;
  final List<String>? purchasedItemIds;

  const PaymentSuccessScreen({
    super.key,
    required this.totalAmount,
    required this.originalAmount,
    required this.savings,
    required this.itemsCount,
    required this.paymentMethod,
    this.purchasedItemIds,
  });

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  @override
  void initState() {
    super.initState();
    // Record the purchase the moment this screen appears, i.e. the moment
    // payment actually succeeds -- not tied to whether the user later taps
    // "Back to Home". This is what "write a review" is gated on.
    final ids = (widget.purchasedItemIds != null && widget.purchasedItemIds!.isNotEmpty)
        ? widget.purchasedItemIds!
        : ProductStore.instance.cartItems.map((i) => i.product.id).toList();
    ProductStore.instance.recordPurchase(ids);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Payment Successful'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Success Icon
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

            // Payment Details Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDetailRow('Payment Method', widget.paymentMethod),
                    const Divider(),
                    _buildDetailRow('Items', '${widget.itemsCount} item(s)'),
                    const Divider(),
                    _buildDetailRow('Subtotal', 'RM${widget.originalAmount.toStringAsFixed(2)}'),
                    const Divider(),
                    _buildDetailRow('Savings', '-RM${widget.savings.toStringAsFixed(2)}'),
                    const Divider(),
                    _buildDetailRow(
                      'Total Paid',
                      'RM${widget.totalAmount.toStringAsFixed(2)}',
                      isBold: true,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Delivery Info Card
            Card(
              color: AppColors.primary.withValues(alpha: 0.05),
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

            // Back to Home Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _removePurchasedItemsFromCart();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Back to Home',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _removePurchasedItemsFromCart() {
    if (widget.purchasedItemIds != null && widget.purchasedItemIds!.isNotEmpty) {
      // Remove each purchased item individually using your removeFromCart method
      for (final productId in widget.purchasedItemIds!) {
        ProductStore.instance.removeFromCart(productId);
      }
    } else {
      // If no specific IDs provided, clear all items using your clearCart method
      ProductStore.instance.clearCart();
    }
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isBold ? null : AppColors.textSecondary,
              fontWeight: isBold ? FontWeight.bold : null,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : null,
              color: isBold ? AppColors.primary : null,
            ),
          ),
        ],
      ),
    );
  }
}