import 'package:shared_preferences/shared_preferences.dart';

class UnitStorage {
  static const _key = 'unlocked_units';

  static Future<List<int>> getUnlockedUnits() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key)?.map(int.parse).toList() ?? [1];
  }

  static Future<void> unlockUnit(int unit) async {
    final prefs = await SharedPreferences.getInstance();
    List<int> unlocked = await getUnlockedUnits();
    if (!unlocked.contains(unit)) {
      unlocked.add(unit);
      unlocked.sort();
      prefs.setStringList(_key, unlocked.map((e) => e.toString()).toList());
    }
  }
}
