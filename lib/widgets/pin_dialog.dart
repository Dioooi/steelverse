// lib/widgets/pin_dialog.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PinDialog extends StatefulWidget {
  final void Function(String pin) onPinEntered;
  final VoidCallback onCancel;

  const PinDialog({
    super.key,
    required this.onPinEntered,
    required this.onCancel,
  });

  @override
  State<PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<PinDialog> {
  String _pin = '';
  bool _showError = false;

  void _addDigit(String digit) {
    setState(() {
      if (_pin.length < 6) {
        _pin += digit;
        _showError = false;
      }

      if (_pin.length == 6) {
        Future.delayed(const Duration(milliseconds: 300), () {
          widget.onPinEntered(_pin);
        });
      }
    });
  }

  void _deleteDigit() {
    setState(() {
      if (_pin.isNotEmpty) {
        _pin = _pin.substring(0, _pin.length - 1);
        _showError = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter Payment PIN',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please enter your 6-digit PIN to confirm payment',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),

            // PIN Dots - REDUCED SIZE
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4), // Reduced from 8
                  width: 32, // Reduced from 40
                  height: 40, // Reduced from 48
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _showError ? Colors.red : AppColors.primary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: index < _pin.length
                        ? Container(
                      width: 12, // Reduced from 16
                      height: 12, // Reduced from 16
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    )
                        : null,
                  ),
                );
              }),
            ),

            if (_showError) ...[
              const SizedBox(height: 8),
              const Text(
                'Incorrect PIN, please try again',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ],

            const SizedBox(height: 24),

            // PIN Pad
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(3, (index) => _buildPinButton(index + 1)),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(3, (index) => _buildPinButton(index + 4)),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPinButton(7),
                    _buildPinButton(8),
                    _buildPinButton(9),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const SizedBox(width: 60),
                    _buildPinButton(0),
                    _buildDeleteButton(),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinButton(int number) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _addDigit(number.toString()),
          borderRadius: BorderRadius.circular(30),
          child: Center(
            child: Text(
              number.toString(),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return SizedBox(
      width: 60,
      height: 60,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _deleteDigit,
          borderRadius: BorderRadius.circular(30),
          child: const Center(
            child: Icon(Icons.backspace_outlined, size: 24),
          ),
        ),
      ),
    );
  }
}