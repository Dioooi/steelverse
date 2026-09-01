// lib/widgets/payment_summary_card.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PaymentSummaryCard extends StatelessWidget {
  final double subtotal;
  final double originalAmount;
  final double savings;

  const PaymentSummaryCard({
    super.key,
    required this.subtotal,
    required this.originalAmount,
    required this.savings,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _buildRow('Subtotal', 'RM${originalAmount.toStringAsFixed(2)}'),
            const Divider(height: 16),
            _buildRow('Savings', '-RM${savings.toStringAsFixed(2)}', isSavings: true),
            const Divider(height: 16),
            _buildRow(
              'Total',
              'RM${subtotal.toStringAsFixed(2)}',
              isBold: true,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {
    bool isBold = false,
    bool isSavings = false,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : null,
              color: isSavings ? Colors.red : null,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : null,
              color: isSavings ? Colors.red : isTotal ? AppColors.primary : null,
            ),
          ),
        ],
      ),
    );
  }
}