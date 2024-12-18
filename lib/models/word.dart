class WordModel {
  final String englishWord;
  final String turkishMeaning;
  final String wordType;
  final String exampleSentence;
  final String exampleTranslation;

  WordModel({
    required this.englishWord,
    required this.turkishMeaning,
    required this.wordType,
    required this.exampleSentence,
    required this.exampleTranslation,
  });

  factory WordModel.fromMap(Map<String, dynamic> map) {
    return WordModel(
      englishWord: map['englishWord'] ?? '',
      turkishMeaning: map['turkishMeaning'] ?? '',
      wordType: map['wordType'] ?? '',
      exampleSentence: map['exampleSentence'] ?? '',
      exampleTranslation: map['exampleTranslation'] ?? '',
    );
  }
}
