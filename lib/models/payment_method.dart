// lib/models/payment_method.dart
import 'package:flutter/material.dart';

class PaymentMethod {
  final String id;
  final String name;
  final IconData icon;
  final double? balance;
  final bool isInternal;
  final String subtitle;
  final List<InstallmentOption>? installmentOptions;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.icon,
    this.balance,
    required this.isInternal,
    required this.subtitle,
    this.installmentOptions,
  });
}

class InstallmentOption {
  final int months;
  final double monthlyPayment;
  final String interest;
  final String? discount;

  InstallmentOption({
    required this.months,
    required this.monthlyPayment,
    required this.interest,
    this.discount,
  });
}