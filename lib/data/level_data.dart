class LevelData {
  static const Map<String, Map<String, String>> levels = {
    "Explorer": {
      "range": "0-199",
      "motto": "Every big journey starts with a single word."
    },
    "Beginner": {
      "range": "200-599",
      "motto": "The basics are the foundation of mastery."
    },
    "Learner": {
      "range": "600-999",
      "motto": "Step by step, you’re building strong skills."
    },
    "Adventurer": {
      "range": "1000-1499",
      "motto": "Your curiosity takes you further every day."
    },
    "Skilled": {
      "range": "1500-2099",
      "motto": "Practice turns knowledge into power."
    },
    "Advanced": {
      "range": "2100-2799",
      "motto": "You’ve come far — keep aiming higher."
    },
    "Expert": {
      "range": "2800-3599",
      "motto": "Your skills inspire others — you’re almost there."
    },
    "Master": {
      "range": "3600-9999",
      "motto": "You’ve reached the peak — now you lead the way."
    },
  };

  static String getLevelName(int xp) {
    for (var entry in levels.entries) {
      final range = entry.value["range"] as String;
      final parts = range.split("-");
      final start = int.parse(parts[0]);
      final end = int.parse(parts[1]);

      if (xp >= start && xp <= end) {
        return entry.key;
      }
    }
    return "Unknown";
  }

  static String getLevelMotto(int xp) {
    for (var entry in levels.entries) {
      final range = entry.value["range"] as String;
      final parts = range.split("-");
      final start = int.parse(parts[0]);
      final end = int.parse(parts[1]);

      if (xp >= start && xp <= end) {
        return entry.value["motto"] as String;
      }
    }
    return "";
  }
}
