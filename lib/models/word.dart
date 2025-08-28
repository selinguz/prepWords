enum WordStatus { unknown, unsure, known }

class WordModel {
  final String englishWord;
  final String turkishMeaning;
  final String wordType;
  final String exampleSentence;
  final String exampleTranslation;
  final int unit;
  
  // UI durumunu tutacak
  WordStatus status;

  WordModel({
    required this.englishWord,
    required this.turkishMeaning,
    required this.wordType,
    required this.exampleSentence,
    required this.exampleTranslation,
    required this.unit,
    this.status = WordStatus.unknown,
  });

  factory WordModel.fromMap(Map<String, dynamic> map) {
    return WordModel(
      englishWord: map['englishWord'] ?? '',
      turkishMeaning: map['turkishMeaning'] ?? '',
      wordType: map['wordType'] ?? '',
      exampleSentence: map['exampleSentence'] ?? '',
      exampleTranslation: map['exampleTranslation'] ?? '',
      unit: map['unit'] ?? 0,
      status: WordStatus.unknown, // yeni eklenen default durum
    );
  }
}
