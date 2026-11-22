import 'package:daymark/core/constants/app_colors.dart';
import 'package:daymark/core/constants/app_typography.dart';
import 'package:flutter/material.dart';

class PinLockDialog extends StatefulWidget {
  final bool isEnabling;

  const PinLockDialog({super.key, required this.isEnabling});

  @override
  State<PinLockDialog> createState() => _PinLockDialogState();
}

class _PinLockDialogState extends State<PinLockDialog> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    final pin = _pinController.text.trim();
    if (widget.isEnabling) {
      final confirm = _confirmController.text.trim();
      if (pin.length < 4) {
        setState(() => _errorMessage = 'PIN must be at least 4 digits');
        return;
      }
      if (pin != confirm) {
        setState(() => _errorMessage = 'PINs do not match');
        return;
      }
      Navigator.pop(context, pin);
    } else {
      Navigator.pop(context, pin);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;

    return AlertDialog(
      backgroundColor: colors.surface,
      title: Text(widget.isEnabling ? 'Set Security PIN' : 'Enter Current PIN', style: typo.headlineMedium),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isEnabling
                ? 'Create a 4-digit PIN to lock your personal journal.'
                : 'Enter your PIN to disable security lock.',
            style: typo.bodySmall,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _pinController,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 6,
            style: typo.headlineMedium.copyWith(color: colors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Enter PIN',
              hintStyle: typo.bodyMedium.copyWith(color: colors.textMuted),
            ),
          ),
          if (widget.isEnabling) ...[
            const SizedBox(height: 10),
            TextField(
              controller: _confirmController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              style: typo.headlineMedium.copyWith(color: colors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Confirm PIN',
                hintStyle: typo.bodyMedium.copyWith(color: colors.textMuted),
              ),
            ),
          ],
          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(_errorMessage!, style: typo.monoLabel.copyWith(color: AppColors.error)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: typo.labelMedium),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.black,
          ),
          child: Text(widget.isEnabling ? 'Enable PIN' : 'Verify'),
        ),
      ],
    );
  }
}
