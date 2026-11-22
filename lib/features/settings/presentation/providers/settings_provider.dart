import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/storage/preferences_service.dart';
import '../../domain/entities/app_settings.dart';

final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  throw UnimplementedError('preferencesServiceProvider must be overridden in main()');
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  final PreferencesService _prefs;

  SettingsNotifier(this._prefs)
      : super(AppSettings(
          userName: _prefs.getUserName(),
          userBio: _prefs.getUserBio(),
          themeMode: _prefs.getThemeMode(),
          dateFormat: _prefs.getDateFormat(),
          languageCode: _prefs.getLanguageCode(),
          pinEnabled: _prefs.isPinEnabled(),
          pinCode: _prefs.getPinCode(),
          hidePreview: _prefs.isHidePreview(),
          aiProvider: _prefs.getAiProvider(),
          geminiApiKey: _prefs.getGeminiApiKey(),
          geminiModel: _prefs.getGeminiModel(),
        ));

  Future<void> updateProfile({required String name, required String bio}) async {
    await _prefs.setUserName(name);
    await _prefs.setUserBio(bio);
    state = state.copyWith(userName: name, userBio: bio);
  }

  Future<void> setThemeMode(String mode) async {
    await _prefs.setThemeMode(mode);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> setDateFormat(String format) async {
    await _prefs.setDateFormat(format);
    state = state.copyWith(dateFormat: format);
  }

  Future<void> setLanguage(String code) async {
    await _prefs.setLanguageCode(code);
    state = state.copyWith(languageCode: code);
  }

  Future<void> setPinLock({required bool enabled, String? pin}) async {
    await _prefs.setPinEnabled(enabled);
    await _prefs.setPinCode(pin);
    state = state.copyWith(pinEnabled: enabled, pinCode: pin);
  }

  Future<void> setHidePreview(bool hide) async {
    await _prefs.setHidePreview(hide);
    state = state.copyWith(hidePreview: hide);
  }

  Future<void> setAiConfig({
    required String provider,
    required String apiKey,
    required String model,
  }) async {
    await _prefs.setAiProvider(provider);
    await _prefs.setGeminiApiKey(apiKey);
    await _prefs.setGeminiModel(model);
    state = state.copyWith(
      aiProvider: provider,
      geminiApiKey: apiKey,
      geminiModel: model,
    );
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  final prefs = ref.watch(preferencesServiceProvider);
  return SettingsNotifier(prefs);
});
