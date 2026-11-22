import 'package:daymark/core/constants/app_colors.dart';
import 'package:daymark/core/constants/app_typography.dart';
import 'package:flutter/material.dart';

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
            GestureDetector(
              onTap: () => setState(() => _provider = 'local'),
              child: Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: _provider == 'local' ? AppColors.primary.withValues(alpha: 0.12) : AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _provider == 'local' ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _provider == 'local' ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: _provider == 'local' ? AppColors.primary : AppColors.textMuted,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Local Heuristic Engine', style: AppTypography.titleMedium),
                          Text('100% offline, privacy guaranteed, zero hallucination', style: AppTypography.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _provider = 'gemini'),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _provider == 'gemini' ? AppColors.primary.withValues(alpha: 0.12) : AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _provider == 'gemini' ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _provider == 'gemini' ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: _provider == 'gemini' ? AppColors.primary : AppColors.textMuted,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Google Gemini API', style: AppTypography.titleMedium),
                          Text('Contextual LLM intelligence via REST API', style: AppTypography.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
                initialValue: _model,
                dropdownColor: AppColors.surfaceElevated,
                items: const [
                  DropdownMenuItem(value: 'gemini-1.5-flash', child: Text('Gemini 1.5 Flash (Fast)')),
                  DropdownMenuItem(value: 'gemini-1.5-pro', child: Text('Gemini 1.5 Pro (Deep)')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _model = val);
                  }
                },
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
