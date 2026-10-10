import 'package:shared_preferences/shared_preferences.dart';
import '../models/day_entry.dart';

class LocalStorageService {
  static const String _keyPrefix = 'daynote_entry_';
  static const String _indexKey = 'daynote_saved_dates_index';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<void> initSeedIfFirstRun() async {
    // Fresh start: no seeded data
  }

  Future<DayEntry?> getEntry(String dateKey) async {
    final prefs = await _prefs;
    final jsonStr = prefs.getString('$_keyPrefix$dateKey');
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      return DayEntry.fromJson(jsonStr);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveEntry(DayEntry entry) async {
    final prefs = await _prefs;
    final dateKey = entry.dateKey;
    final index = await getDatesWithContent();

    if (entry.isEmpty) {
      await prefs.remove('$_keyPrefix$dateKey');
      if (index.contains(dateKey)) {
        index.remove(dateKey);
        await prefs.setStringList(_indexKey, index.toList());
      }
    } else {
      await prefs.setString('$_keyPrefix$dateKey', entry.toJson());
      if (!index.contains(dateKey)) {
        index.add(dateKey);
        await prefs.setStringList(_indexKey, index.toList());
      }
    }
  }

  Future<Set<String>> getDatesWithContent() async {
    final prefs = await _prefs;
    final list = prefs.getStringList(_indexKey) ?? [];
    return list.toSet();
  }
}
