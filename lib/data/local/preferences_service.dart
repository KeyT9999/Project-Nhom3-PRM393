import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _keyRecentSearches = 'recent_searches';

  Future<List<String>> getRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyRecentSearches) ?? [];
  }

  Future<void> saveRecentSearches(List<String> keywords) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyRecentSearches, keywords);
  }
}
