enum WordStatus { unknown, unsure, known, none }

class WordModel {
  final String englishWord;
  final String turkishMeaning;
  final String wordType;
  final String exampleSentence;
  final String exampleTranslation;
  final int unit;

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
      status: WordStatus.unknown,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'englishWord': englishWord,
      'turkishMeaning': turkishMeaning,
      'wordType': wordType,
      'exampleSentence': exampleSentence,
      'exampleTranslation': exampleTranslation,
      'unit': unit,
      'status': status.index, // SharedPref için int olarak saklıyoruz
    };
  }
}
