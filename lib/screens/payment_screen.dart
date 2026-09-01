// lib/screens/payment/payment_screen.dart
import 'package:flutter/material.dart';
import '../../models/cart_item.dart';
import '../../models/user.dart';
import '../../models/payment_method.dart';
import '../../theme/app_theme.dart';
import '../../widgets/payment_method_card.dart';
import '../../widgets/payment_summary_card.dart';
import '../../widgets/pin_dialog.dart';
import 'payment_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  final List<CartItem> selectedItems;
  final double totalAmount;
  final double originalAmount;
  final double savings;
  final User user;

  const PaymentScreen({
    super.key,
    required this.selectedItems,
    required this.totalAmount,
    required this.originalAmount,
    required this.savings,
    required this.user,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentMethod? _selectedMethod;
  final List<PaymentMethod> _paymentMethods = [];

  @override
  void initState() {
    super.initState();
    _initializePaymentMethods();
  }

  void _initializePaymentMethods() {
    _paymentMethods.addAll([
      PaymentMethod(
        id: 'wallet',
        name: 'ShopeePay',
        icon: Icons.wallet,
        balance: widget.user.balance,
        isInternal: true,
        subtitle: 'Wallet Balance (RM${widget.user.balance.toStringAsFixed(2)})',
      ),
      PaymentMethod(
        id: 'spaylater',
        name: 'SPayLater',
        icon: Icons.credit_card,
        isInternal: true,
        subtitle: 'Activate to get RM200 voucher package',
        installmentOptions: [
          InstallmentOption(months: 1, monthlyPayment: 8.50, interest: '0%'),
          InstallmentOption(months: 3, monthlyPayment: 8.50, interest: '0%', discount: 'RM5 OFF'),
        ],
      ),
      PaymentMethod(
        id: 'credit_card',
        name: 'Credit / Debit Card',
        icon: Icons.payment,
        isInternal: false,
        subtitle: 'Add Card',
      ),
    ]);
  }

  void _proceedToPayment() {
    if (_selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method')),
      );
      return;
    }

    if (_selectedMethod!.isInternal) {
      _showPinDialog();
    } else {
      _showExternalPayment();
    }
  }

  void _showPinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PinDialog(
        onPinEntered: (pin) {
          _verifyPin(pin);
        },
        onCancel: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  void _verifyPin(String pin) {
    Navigator.pop(context);

    if (pin == widget.user.pin) {
      if (widget.user.balance >= widget.totalAmount) {
        widget.user.balance -= widget.totalAmount;

        // Get IDs of purchased items
        final purchasedIds = widget.selectedItems.map((item) => item.product.id).toList();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentSuccessScreen(
              totalAmount: widget.totalAmount,
              originalAmount: widget.originalAmount,
              savings: widget.savings,
              itemsCount: widget.selectedItems.length,
              paymentMethod: _selectedMethod!.name,
              purchasedItemIds: purchasedIds, // Pass purchased item IDs
            ),
          ),
        );
      } else {
        _showErrorDialog('Insufficient Balance', 'Your balance is insufficient. Please choose another payment method.');
      }
    } else {
      _showErrorDialog('Incorrect PIN', 'The PIN you entered is incorrect. Please try again.');
    }
  }

  void _showExternalPayment() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Processing payment...'),
              ],
            ),
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);

      // Get IDs of purchased items
      final purchasedIds = widget.selectedItems.map((item) => item.product.id).toList();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentSuccessScreen(
            totalAmount: widget.totalAmount,
            originalAmount: widget.originalAmount,
            savings: widget.savings,
            itemsCount: widget.selectedItems.length,
            paymentMethod: _selectedMethod!.name,
            purchasedItemIds: purchasedIds, // Pass purchased item IDs
          ),
        ),
      );
    });
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDeliveryAddress(),
                  const SizedBox(height: 16),
                  _buildProductSummary(),
                  const SizedBox(height: 16),
                  const Text(
                    'Payment Methods',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ..._paymentMethods.map((method) => PaymentMethodCard(
                    method: method,
                    isSelected: _selectedMethod?.id == method.id,
                    onTap: () {
                      setState(() {
                        _selectedMethod = method;
                      });
                    },
                  )),
                  const SizedBox(height: 16),
                  PaymentSummaryCard(
                    subtotal: widget.totalAmount,
                    originalAmount: widget.originalAmount,
                    savings: widget.savings,
                  ),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    Text(
                      'RM${widget.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  width: 120,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _proceedToPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Checkout',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddress() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${widget.user.name} ${widget.user.phone}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 28),
              child: Text(
                widget.user.address,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${widget.selectedItems.length} item(s)',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  'RM${widget.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...widget.selectedItems.map((item) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.product.name,
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    'x${item.quantity}',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}