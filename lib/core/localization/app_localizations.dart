class AppLocalizations {
  static const Map<String, String> _englishStrings = {
    'app_name': 'BÜTHE',
    'welcome': 'Welcome',
    'logout': 'Logout',
  };

  static String getString(String key) {
    return _englishStrings[key] ?? key;
  }
}
