class AppSettings {
  final String userName;
  final String userBio;
  final String themeMode; // 'dark', 'light', 'system'
  final String dateFormat;
  final String languageCode; // 'id', 'en'
  final bool pinEnabled;
  final String? pinCode;
  final bool hidePreview;
  final String aiProvider; // 'local', 'gemini'
  final String geminiApiKey;
  final String geminiModel;

  const AppSettings({
    required this.userName,
    required this.userBio,
    required this.themeMode,
    required this.dateFormat,
    this.languageCode = 'id',
    required this.pinEnabled,
    this.pinCode,
    required this.hidePreview,
    required this.aiProvider,
    required this.geminiApiKey,
    required this.geminiModel,
  });

  AppSettings copyWith({
    String? userName,
    String? userBio,
    String? themeMode,
    String? dateFormat,
    String? languageCode,
    bool? pinEnabled,
    String? pinCode,
    bool? hidePreview,
    String? aiProvider,
    String? geminiApiKey,
    String? geminiModel,
  }) {
    return AppSettings(
      userName: userName ?? this.userName,
      userBio: userBio ?? this.userBio,
      themeMode: themeMode ?? this.themeMode,
      dateFormat: dateFormat ?? this.dateFormat,
      languageCode: languageCode ?? this.languageCode,
      pinEnabled: pinEnabled ?? this.pinEnabled,
      pinCode: pinCode ?? this.pinCode,
      hidePreview: hidePreview ?? this.hidePreview,
      aiProvider: aiProvider ?? this.aiProvider,
      geminiApiKey: geminiApiKey ?? this.geminiApiKey,
      geminiModel: geminiModel ?? this.geminiModel,
    );
  }
}
