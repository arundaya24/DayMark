import 'package:daymark/core/constants/app_colors.dart';
import 'package:daymark/core/constants/app_typography.dart';
import 'package:daymark/l10n/app_localizations.dart';
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
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;

    return AlertDialog(
      backgroundColor: colors.surface,
      title: Text(l10n.isIndonesian ? 'Pengaturan Layanan AI' : 'AI Provider Settings', style: typo.headlineMedium),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.isIndonesian
                  ? 'DAYMARK mendukung AI heuristik offline lokal dan API cloud Google Gemini.'
                  : 'DAYMARK supports both local offline heuristic AI and cloud Google Gemini API.',
              style: typo.bodySmall,
            ),
            const SizedBox(height: 16),
            Text(l10n.summaryEngine.toUpperCase(), style: typo.monoLabel),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => setState(() => _provider = 'local'),
              child: Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: _provider == 'local' ? AppColors.primary.withValues(alpha: 0.12) : colors.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _provider == 'local' ? AppColors.primary : colors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _provider == 'local' ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: _provider == 'local' ? AppColors.primary : colors.textMuted,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.isIndonesian ? 'Mesin Heuristik Lokal' : 'Local Heuristic Engine', style: typo.titleMedium),
                          Text(l10n.isIndonesian ? '100% offline, privasi terjamin' : '100% offline, privacy guaranteed', style: typo.bodySmall),
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
                  color: _provider == 'gemini' ? AppColors.primary.withValues(alpha: 0.12) : colors.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _provider == 'gemini' ? AppColors.primary : colors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _provider == 'gemini' ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: _provider == 'gemini' ? AppColors.primary : colors.textMuted,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Google Gemini API', style: typo.titleMedium),
                          Text(l10n.isIndonesian ? 'Kecerdasan LLM kontekstual via REST API' : 'Contextual LLM intelligence via REST API', style: typo.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_provider == 'gemini') ...[
              const SizedBox(height: 14),
              Text('GEMINI API KEY', style: typo.monoLabel),
              const SizedBox(height: 6),
              TextField(
                controller: _apiKeyController,
                obscureText: true,
                style: typo.bodyMedium.copyWith(color: colors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Enter AI Studio Gemini API Key',
                  hintStyle: typo.bodyMedium.copyWith(color: colors.textMuted),
                ),
              ),
              const SizedBox(height: 12),
              Text('MODEL', style: typo.monoLabel),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _model,
                dropdownColor: colors.surfaceElevated,
                style: typo.bodyMedium.copyWith(color: colors.textPrimary),
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
          child: Text(l10n.cancel, style: typo.labelMedium),
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
          child: Text(l10n.save, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}
