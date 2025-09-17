import 'package:flutter/material.dart';
import 'package:prep_words/models/word.dart';
import 'package:prep_words/services/firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WordStatusProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  Map<int, int> knownWordsCount = {};

  Future<void> loadKnownWords(int unit) async {
    final prefs = await SharedPreferences.getInstance();
    List<WordModel> words = await _firebaseService.fetchWordsByUnit(unit);

    int count = 0;
    for (var word in words) {
      final status = prefs.getString("word_status_${word.englishWord}") ?? "";
      if (status == WordStatus.known.toString()) count++;
    }

    knownWordsCount[unit] = count;
    notifyListeners();
  }

  Future<void> loadAllKnownWords(int startUnit, int unitCount) async {
    for (int i = 0; i < unitCount; i++) {
      int globalUnit = startUnit + i;
      await loadKnownWords(globalUnit);
    }
  }

  Future<void> incrementKnownWord(int unit) async {
    knownWordsCount[unit] = (knownWordsCount[unit] ?? 0) + 1;
    notifyListeners();
  }
}
