import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

class AiConfigDialog extends StatefulWidget {
  final String currentProvider;
  final String currentApiKey;
  final String currentModel;

  const AiConfigDialog({
    super.key,
    required this.currentProvider,
    required this.currentApiKey,
    required this.currentModel,
  });

  @override
  State<AiConfigDialog> createState() => _AiConfigDialogState();
}

class _AiConfigDialogState extends State<AiConfigDialog> {
  late String _provider;
  late final TextEditingController _apiKeyController;
  late String _model;

  @override
  void initState() {
    super.initState();
    _provider = widget.currentProvider;
    _apiKeyController = TextEditingController(text: widget.currentApiKey);
    _model = widget.currentModel;
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceElevated,
      title: Text('AI Provider Settings', style: AppTypography.headlineMedium),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DAYMARK supports both local zero-hallucination offline heuristic AI and cloud Google Gemini API.',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: 16),
            Text('SUMMARY PROVIDER', style: AppTypography.monoLabel),
            const SizedBox(height: 8),
            RadioListTile<String>(
              value: 'local',
              groupValue: _provider,
              activeColor: AppColors.primary,
              title: Text('Local Heuristic Engine', style: AppTypography.titleMedium),
              subtitle: Text('100% offline, privacy guaranteed, zero hallucination', style: AppTypography.bodySmall),
              contentPadding: EdgeInsets.zero,
              onChanged: (val) => setState(() => _provider = val!),
            ),
            RadioListTile<String>(
              value: 'gemini',
              groupValue: _provider,
              activeColor: AppColors.primary,
              title: Text('Google Gemini API', style: AppTypography.titleMedium),
              subtitle: Text('Contextual LLM intelligence via REST API', style: AppTypography.bodySmall),
              contentPadding: EdgeInsets.zero,
              onChanged: (val) => setState(() => _provider = val!),
            ),
            if (_provider == 'gemini') ...[
              const SizedBox(height: 14),
              Text('GEMINI API KEY', style: AppTypography.monoLabel),
              const SizedBox(height: 6),
              TextField(
                controller: _apiKeyController,
                obscureText: true,
                decoration: const InputDecoration(hintText: 'Enter AI Studio Gemini API Key'),
              ),
              const SizedBox(height: 12),
              Text('MODEL', style: AppTypography.monoLabel),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _model,
                dropdownColor: AppColors.surfaceElevated,
                items: const [
                  DropdownMenuItem(value: 'gemini-1.5-flash', child: Text('Gemini 1.5 Flash (Fast)')),
                  DropdownMenuItem(value: 'gemini-1.5-pro', child: Text('Gemini 1.5 Pro (Deep)')),
                ],
                onChanged: (val) => setState(() => _model = val!),
              ),
            ],
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
            Navigator.pop(context, {
              'provider': _provider,
              'apiKey': _apiKeyController.text.trim(),
              'model': _model,
            });
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
