import 'package:daymark/core/constants/app_colors.dart';
import 'package:daymark/core/constants/app_typography.dart';
import 'package:daymark/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class ProfileEditDialog extends StatefulWidget {
  final String currentName;
  final String currentBio;

  const ProfileEditDialog({
    super.key,
    required this.currentName,
    required this.currentBio,
  });

  @override
  State<ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends State<ProfileEditDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _bioController = TextEditingController(text: widget.currentBio);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;

    return AlertDialog(
      backgroundColor: colors.surface,
      title: Text(l10n.editProfile, style: typo.headlineMedium),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.name.toUpperCase(), style: typo.monoLabel),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              style: typo.bodyMedium.copyWith(color: colors.textPrimary),
              decoration: InputDecoration(
                hintText: l10n.isIndonesian ? 'Nama atau panggilan Anda' : 'Your name or moniker',
                hintStyle: typo.bodyMedium.copyWith(color: colors.textMuted),
              ),
            ),
            const SizedBox(height: 16),
            Text(l10n.bio.toUpperCase(), style: typo.monoLabel),
            const SizedBox(height: 6),
            TextField(
              controller: _bioController,
              style: typo.bodyMedium.copyWith(color: colors.textPrimary),
              decoration: InputDecoration(
                hintText: 'e.g. ${l10n.tagline}',
                hintStyle: typo.bodyMedium.copyWith(color: colors.textMuted),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel, style: typo.labelMedium),
        ),
        ElevatedButton(
          onPressed: () {
            final name = _nameController.text.trim();
            final bio = _bioController.text.trim();
            if (name.isNotEmpty) {
              Navigator.pop(context, {'name': name, 'bio': bio});
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.black,
          ),
          child: Text(l10n.save, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}
