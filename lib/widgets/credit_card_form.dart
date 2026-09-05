// lib/widgets/credit_card_form.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CreditCardForm extends StatefulWidget {
  final Function(Map<String, String> cardData) onDataChanged;

  const CreditCardForm({
    super.key,
    required this.onDataChanged,
  });

  @override
  CreditCardFormState createState() => CreditCardFormState();
}

// Make the State class public by removing the underscore
class CreditCardFormState extends State<CreditCardForm> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvcController = TextEditingController();
  final _cardHolderController = TextEditingController();
  bool _saveCard = false;
  bool _agreeConsent = false;

  @override
  void initState() {
    super.initState();
    // Add listeners to update parent when data changes
    _cardNumberController.addListener(_notifyDataChanged);
    _expiryController.addListener(_notifyDataChanged);
    _cvcController.addListener(_notifyDataChanged);
    _cardHolderController.addListener(_notifyDataChanged);
  }

  @override
  void dispose() {
    _cardNumberController.removeListener(_notifyDataChanged);
    _expiryController.removeListener(_notifyDataChanged);
    _cvcController.removeListener(_notifyDataChanged);
    _cardHolderController.removeListener(_notifyDataChanged);
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    _cardHolderController.dispose();
    super.dispose();
  }

  void _notifyDataChanged() {
    widget.onDataChanged({
      'cardNumber': _cardNumberController.text,
      'expiry': _expiryController.text,
      'cvc': _cvcController.text,
      'cardHolder': _cardHolderController.text,
      'saveCard': _saveCard.toString(),
      'agreeConsent': _agreeConsent.toString(),
    });
  }

  void _formatCardNumber(String value) {
    String cleaned = value.replaceAll(RegExp(r'\D'), '');
    String formatted = '';
    for (int i = 0; i < cleaned.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formatted += ' ';
      }
      formatted += cleaned[i];
    }
    _cardNumberController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
    _notifyDataChanged();
  }

  void _formatExpiry(String value) {
    String cleaned = value.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length >= 2) {
      String month = cleaned.substring(0, 2);
      String year = cleaned.substring(2);
      String formatted = '$month/${year.substring(0, year.length > 2 ? 2 : year.length)}';
      _expiryController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    _notifyDataChanged();
  }

  // Luhn Algorithm to validate card number
  bool _isValidCardNumber(String cardNumber) {
    // Remove all spaces
    String cleaned = cardNumber.replaceAll(RegExp(r'\s+'), '');

    // Check if it contains only digits and has valid length (16 for most cards)
    if (!RegExp(r'^[0-9]{13,19}$').hasMatch(cleaned)) {
      return false;
    }

    // Luhn Algorithm
    int sum = 0;
    bool alternate = false;

    // Start from the rightmost digit
    for (int i = cleaned.length - 1; i >= 0; i--) {
      int digit = int.parse(cleaned[i]);

      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit = digit - 9;
        }
      }

      sum += digit;
      alternate = !alternate;
    }

    return sum % 10 == 0;
  }

  bool _isValidExpiry(String expiry) {
    // Check format MM/YY
    if (!RegExp(r'^[0-9]{2}/[0-9]{2}$').hasMatch(expiry)) {
      return false;
    }

    String monthStr = expiry.substring(0, 2);
    String yearStr = expiry.substring(3, 5);

    int month = int.parse(monthStr);
    int year = int.parse(yearStr) + 2000; // Convert YY to YYYY

    // Validate month (1-12)
    if (month < 1 || month > 12) {
      return false;
    }

    // Get current date
    DateTime now = DateTime.now();
    int currentYear = now.year;
    int currentMonth = now.month;

    // Check if expiry date is in the future
    if (year < currentYear) {
      return false;
    } else if (year == currentYear && month < currentMonth) {
      return false;
    }

    return true;
  }

  bool validateForm() {
    return _formKey.currentState?.validate() ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Credit / Debit Card',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Image.network(
                        'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Visa_Inc._logo.svg/120px-Visa_Inc._logo.svg.png',
                        height: 20,
                        errorBuilder: (_, __, ___) => const Icon(Icons.credit_card, size: 20),
                      ),
                      const SizedBox(width: 8),
                      Image.network(
                        'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/American_Express_logo_%282018%29.svg/120px-American_Express_logo_%282018%29.svg.png',
                        height: 20,
                        errorBuilder: (_, __, ___) => const Icon(Icons.credit_card, size: 20),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // AM EX indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'AM EX',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Card Number
              TextFormField(
                controller: _cardNumberController,
                decoration: const InputDecoration(
                  labelText: 'Card number',
                  hintText: '0000 0000 0000 0000',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.credit_card),
                ),
                keyboardType: TextInputType.number,
                maxLength: 19,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a card number';
                  }

                  String cleaned = value.replaceAll(RegExp(r'\s+'), '');
                  if (cleaned.length < 16) {
                    return 'Please enter a valid 16-digit card number';
                  }

                  if (!_isValidCardNumber(value)) {
                    return 'Invalid card number. Please check and try again.';
                  }

                  return null;
                },
                onChanged: _formatCardNumber,
              ),
              const SizedBox(height: 16),

              // MM/YY and CVC Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expiryController,
                      decoration: const InputDecoration(
                        labelText: 'MM/YY',
                        hintText: 'MM/YY',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter expiry date';
                        }

                        if (value.length < 5) {
                          return 'Invalid expiry date format';
                        }

                        if (!_isValidExpiry(value)) {
                          return 'Card has expired or invalid date';
                        }

                        return null;
                      },
                      onChanged: _formatExpiry,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _cvcController,
                      decoration: const InputDecoration(
                        labelText: 'CVC',
                        hintText: '000',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter CVC';
                        }

                        String cleaned = value.replaceAll(RegExp(r'\s+'), '');
                        if (cleaned.length < 3 || cleaned.length > 4) {
                          return 'CVC must be 3 or 4 digits';
                        }

                        if (!RegExp(r'^[0-9]+$').hasMatch(cleaned)) {
                          return 'CVC must contain only numbers';
                        }

                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Card Holder Name
              TextFormField(
                controller: _cardHolderController,
                decoration: const InputDecoration(
                  labelText: 'Name of the card holder',
                  hintText: 'John Doe',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter card holder name';
                  }

                  if (value.length < 3) {
                    return 'Please enter a valid name';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Save card checkbox
              Row(
                children: [
                  Checkbox(
                    value: _saveCard,
                    onChanged: (value) {
                      setState(() {
                        _saveCard = value ?? false;
                      });
                      _notifyDataChanged();
                    },
                  ),
                  const Expanded(
                    child: Text(
                      'Save this card for a faster checkout next time',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),

              // Consent checkbox
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _agreeConsent,
                    onChanged: (value) {
                      setState(() {
                        _agreeConsent = value ?? false;
                      });
                      _notifyDataChanged();
                    },
                  ),
                  const Expanded(
                    child: Text(
                      'By saving your card you grant us your consent to store your payment method for future orders. You can withdraw consent at any time.',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),

              // Privacy policy link
              Padding(
                padding: const EdgeInsets.only(left: 40),
                child: TextButton(
                  onPressed: () {
                    // Navigate to privacy policy
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'For more information, please visit the Privacy policy.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}