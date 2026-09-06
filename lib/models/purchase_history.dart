// models/purchase_history.dart

class PurchaseHistory {
  final int? id;
  final String username;
  final String orderId;
  final List<String> productIds;
  final List<String> productNames;
  final double totalAmount;
  final double originalAmount;
  final double savings;
  final int itemsCount;
  final String paymentMethod;
  final DateTime purchaseDate;
  final String status;

  PurchaseHistory({
    this.id,
    required this.username,
    required this.orderId,
    required this.productIds,
    required this.productNames,
    required this.totalAmount,
    required this.originalAmount,
    required this.savings,
    required this.itemsCount,
    required this.paymentMethod,
    required this.purchaseDate,
    this.status = 'completed',
  });

  factory PurchaseHistory.fromMap(Map<String, dynamic> map) {
    return PurchaseHistory(
      id: map['id'] as int?,
      username: map['username'] as String,
      orderId: map['order_id'] as String,
      productIds: (map['product_ids'] as String).split(','),
      productNames: (map['product_names'] as String).split(','),
      totalAmount: (map['total_amount'] as num).toDouble(),
      originalAmount: (map['original_amount'] as num).toDouble(),
      savings: (map['savings'] as num).toDouble(),
      itemsCount: map['items_count'] as int,
      paymentMethod: map['payment_method'] as String,
      purchaseDate: DateTime.parse(map['purchase_date'] as String),
      status: map['status'] as String? ?? 'completed',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'order_id': orderId,
      'product_ids': productIds.join(','),
      'product_names': productNames.join(','),
      'total_amount': totalAmount,
      'original_amount': originalAmount,
      'savings': savings,
      'items_count': itemsCount,
      'payment_method': paymentMethod,
      'purchase_date': purchaseDate.toIso8601String(),
      'status': status,
    };
  }
}