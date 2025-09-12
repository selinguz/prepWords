import 'package:shared_preferences/shared_preferences.dart';

class PracticeStats {
  /// Sonuç kaydet
  static Future<void> savePracticeResult(int practiceId, int xp) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'practice_$practiceId';
    final results = prefs.getStringList(key) ?? [];
    results.add(xp.toString());
    await prefs.setStringList(key, results);
  }

  /// Sonuçları getir
  static Future<List<int>> getPracticeResults(int practiceId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'practice_$practiceId';
    final results = prefs.getStringList(key) ?? [];
    return results.map((e) => int.parse(e)).toList();
  }

  /// Tüm practice istatistiklerini getir
  static Future<Map<int, List<int>>> getAllStats(int practiceCount) async {
    Map<int, List<int>> all = {};
    for (int i = 1; i <= practiceCount; i++) {
      all[i] = await getPracticeResults(i);
    }
    return all;
  }
}
