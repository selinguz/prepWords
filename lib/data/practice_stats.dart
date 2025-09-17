import 'package:shared_preferences/shared_preferences.dart';

class PracticeStats {
  /// Sonuç kaydet
  static Future<void> savePracticeResult(
      int practiceId, int xp, double successRate) async {
    final prefs = await SharedPreferences.getInstance();

    // XP kaydı
    final xpKey = 'practice_${practiceId}_xp';
    final xpResults = prefs.getStringList(xpKey) ?? [];
    xpResults.add(xp.toString());
    await prefs.setStringList(xpKey, xpResults);

    // Başarı yüzdesi kaydı
    final successKey = 'practice_${practiceId}_success';
    final successResults = prefs.getStringList(successKey) ?? [];
    successResults.add(successRate.toStringAsFixed(2));
    await prefs.setStringList(successKey, successResults);
  }

  /// Sonuçları getir
  static Future<List<int>> getPracticeResults(int practiceId) async {
    final prefs = await SharedPreferences.getInstance();
    final xpKey = 'practice_${practiceId}_xp';
    final results = prefs.getStringList(xpKey) ?? [];
    return results.map((e) => int.parse(e)).toList();
  }

  static Future<List<double>> getPracticeSuccessRates(int practiceId) async {
    final prefs = await SharedPreferences.getInstance();
    final successKey = 'practice_${practiceId}_success';
    final results = prefs.getStringList(successKey) ?? [];
    return results.map((e) => double.parse(e)).toList();
  }

  static Future<Map<int, List<int>>> getAllXpStats(int practiceCount) async {
    Map<int, List<int>> all = {};
    for (int i = 1; i <= practiceCount; i++) {
      all[i] = await getPracticeResults(i);
    }
    return all;
  }

  static Future<Map<int, List<double>>> getAllSuccessRates(int practiceCount) async {
    Map<int, List<double>> all = {};
    for (int i = 1; i <= practiceCount; i++) {
      all[i] = await getPracticeSuccessRates(i);
    }
    return all;
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
