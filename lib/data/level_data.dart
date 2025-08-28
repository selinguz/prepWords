class LevelData {
  static const Map<String, Map<String, String>> levels = {
    "Explorer": {
      "range": "0-6",
      "motto": "Every big journey starts with a single word."
    },
    "Beginner": {
      "range": "7-12",
      "motto": "The basics are the foundation of mastery."
    },
    "Learner": {
      "range": "13-18",
      "motto": "Step by step, you’re building strong skills."
    },
    "Adventurer": {
      "range": "19-24",
      "motto": "Your curiosity takes you further every day."
    },
    "Skilled": {
      "range": "25-30",
      "motto": "Practice turns knowledge into power."
    },
    "Advanced": {
      "range": "31-36",
      "motto": "You’ve come far — keep aiming higher."
    },
    "Expert": {
      "range": "37-42",
      "motto": "Your skills inspire others — you’re almost there."
    },
    "Master": {
      "range": "43-48",
      "motto": "You’ve reached the peak — now you lead the way."
    },
  };

  /// Kullanıcının level numarasına göre level ismini döndürür
  static String getLevelName(int level) {
    for (var entry in levels.entries) {
      final range = entry.value["range"] as String;
      final parts = range.split("-");
      final start = int.parse(parts[0]);
      final end = int.parse(parts[1]);

      if (level >= start && level <= end) {
        return entry.key;
      }
    }
    return "Unknown";
  }

  /// Kullanıcının level numarasına göre mottosunu döndürür
  static String getLevelMotto(int level) {
    for (var entry in levels.entries) {
      final range = entry.value["range"] as String;
      final parts = range.split("-");
      final start = int.parse(parts[0]);
      final end = int.parse(parts[1]);

      if (level >= start && level <= end) {
        return entry.value["motto"] as String;
      }
    }
    return "";
  }
}
