import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String keyUserName = 'user_name';
  static const String keyUserBio = 'user_bio';
  static const String keyThemeMode = 'theme_mode'; // 'dark', 'light', 'system'
  static const String keyDateFormat = 'date_format'; // 'dd MMM yyyy', 'yyyy-MM-dd', 'EEEE, dd MMMM yyyy'
  static const String keyPinEnabled = 'pin_enabled';
  static const String keyPinCode = 'pin_code';
  static const String keyHidePreview = 'hide_preview';
  static const String keyAiProvider = 'ai_provider'; // 'local', 'gemini'
  static const String keyGeminiApiKey = 'gemini_api_key';
  static const String keyGeminiModel = 'gemini_model';

  final SharedPreferences _prefs;

  PreferencesService(this._prefs);

  static Future<PreferencesService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return PreferencesService(prefs);
  }

  String getUserName() => _prefs.getString(keyUserName) ?? 'Journaler';
  Future<bool> setUserName(String name) => _prefs.setString(keyUserName, name);

  String getUserBio() => _prefs.getString(keyUserBio) ?? 'Every day leaves a mark.';
  Future<bool> setUserBio(String bio) => _prefs.setString(keyUserBio, bio);

  String getThemeMode() => _prefs.getString(keyThemeMode) ?? 'dark';
  Future<bool> setThemeMode(String mode) => _prefs.setString(keyThemeMode, mode);

  String getDateFormat() => _prefs.getString(keyDateFormat) ?? 'dd MMM yyyy';
  Future<bool> setDateFormat(String format) => _prefs.setString(keyDateFormat, format);

  bool isPinEnabled() => _prefs.getBool(keyPinEnabled) ?? false;
  Future<bool> setPinEnabled(bool enabled) => _prefs.setBool(keyPinEnabled, enabled);

  String? getPinCode() => _prefs.getString(keyPinCode);
  Future<bool> setPinCode(String? pin) => pin != null ? _prefs.setString(keyPinCode, pin) : _prefs.remove(keyPinCode);

  bool isHidePreview() => _prefs.getBool(keyHidePreview) ?? false;
  Future<bool> setHidePreview(bool hide) => _prefs.setBool(keyHidePreview, hide);

  String getAiProvider() => _prefs.getString(keyAiProvider) ?? 'local';
  Future<bool> setAiProvider(String provider) => _prefs.setString(keyAiProvider, provider);

  String getGeminiApiKey() => _prefs.getString(keyGeminiApiKey) ?? '';
  Future<bool> setGeminiApiKey(String key) => _prefs.setString(keyGeminiApiKey, key);

  String getGeminiModel() => _prefs.getString(keyGeminiModel) ?? 'gemini-1.5-flash';
  Future<bool> setGeminiModel(String model) => _prefs.setString(keyGeminiModel, model);
}
