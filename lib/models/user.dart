// lib/models/user.dart
class User {
  String name;
  String phone;
  String address;
  double balance;
  String pin;

  User({
    required this.name,
    required this.phone,
    required this.address,
    this.balance = 0.0,
    this.pin = '123456',
  });

  // Add toJson/fromJson if needed
  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    'address': address,
    'balance': balance,
    'pin': pin,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    name: json['name'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    address: json['address'] as String? ?? '',
    balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
    pin: json['pin'] as String? ?? '123456',
  );
}