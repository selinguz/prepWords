import 'package:flutter/material.dart';
import 'package:prep_words/models/word.dart';
import 'package:prep_words/services/firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WordStatusProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  // unit -> known count
  final Map<int, int> _knownWordsCount = {};

  Map<int, int> get knownWordsCount => _knownWordsCount;

  Future<void> loadKnownWords(int unit) async {
    final prefs = await SharedPreferences.getInstance();
    List<WordModel> words = await _firebaseService.fetchWordsByUnit(unit);
    int count = words.where((w) {
      final status = prefs.getString("word_status_${w.englishWord}") ?? "";
      return status == WordStatus.known.toString();
    }).length;

    _knownWordsCount[unit] = count;
    notifyListeners();
  }

  Future<void> incrementKnownWord(int unit) async {
    _knownWordsCount[unit] = (_knownWordsCount[unit] ?? 0) + 1;
    notifyListeners();
  }
}
