import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

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
    return AlertDialog(
      backgroundColor: AppColors.surfaceElevated,
      title: Text('Edit Profile', style: AppTypography.headlineMedium),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('NAME', style: AppTypography.monoLabel),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'Your name or moniker'),
            ),
            const SizedBox(height: 16),
            Text('BIO / MOTTO', style: AppTypography.monoLabel),
            const SizedBox(height: 6),
            TextField(
              controller: _bioController,
              decoration: const InputDecoration(hintText: 'e.g. Every day leaves a mark.'),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: AppTypography.labelMedium),
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
          child: const Text('Save'),
        ),
      ],
    );
  }
}
