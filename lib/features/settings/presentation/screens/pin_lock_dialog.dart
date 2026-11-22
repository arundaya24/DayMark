import 'package:daymark/core/constants/app_colors.dart';
import 'package:daymark/core/constants/app_typography.dart';
import 'package:daymark/l10n/app_localizations.dart';
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

  void _submit(AppLocalizations l10n) {
    final pin = _pinController.text.trim();
    if (widget.isEnabling) {
      final confirm = _confirmController.text.trim();
      if (pin.length < 4) {
        setState(() => _errorMessage = l10n.isIndonesian ? 'PIN minimal 4 digit' : 'PIN must be at least 4 digits');
        return;
      }
      if (pin != confirm) {
        setState(() => _errorMessage = l10n.isIndonesian ? 'PIN tidak cocok' : 'PINs do not match');
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
    final l10n = context.l10n;

    final title = widget.isEnabling
        ? (l10n.isIndonesian ? 'Atur PIN Keamanan' : 'Set Security PIN')
        : (l10n.isIndonesian ? 'Masukkan PIN Saat Ini' : 'Enter Current PIN');

    final subtitle = widget.isEnabling
        ? (l10n.isIndonesian ? 'Buat 4-digit PIN untuk mengunci jurnal pribadi Anda.' : 'Create a 4-digit PIN to lock your personal journal.')
        : (l10n.isIndonesian ? 'Masukkan PIN untuk menonaktifkan kunci keamanan.' : 'Enter your PIN to disable security lock.');

    return AlertDialog(
      backgroundColor: colors.surface,
      title: Text(title, style: typo.headlineMedium),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subtitle, style: typo.bodySmall),
          const SizedBox(height: 16),
          TextField(
            controller: _pinController,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 6,
            style: typo.headlineMedium.copyWith(color: colors.textPrimary),
            decoration: InputDecoration(
              hintText: l10n.isIndonesian ? 'Masukkan PIN' : 'Enter PIN',
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
                hintText: l10n.isIndonesian ? 'Konfirmasi PIN' : 'Confirm PIN',
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
          child: Text(l10n.cancel, style: typo.labelMedium),
        ),
        ElevatedButton(
          onPressed: () => _submit(l10n),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.black,
          ),
          child: Text(widget.isEnabling ? (l10n.isIndonesian ? 'Aktifkan PIN' : 'Enable PIN') : (l10n.isIndonesian ? 'Verifikasi' : 'Verify')),
        ),
      ],
    );
  }
}
