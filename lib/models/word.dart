
enum WordStatus { unknown, unsure, known, none }

extension WordStatusLabel on WordStatus {
  String get display {
    switch (this) {
      case WordStatus.known:
        return 'Biliyorum';
      case WordStatus.unsure:
        return 'Emin değilim';
      case WordStatus.unknown:
        return 'Bilmiyorum';
      case WordStatus.none:
        return '—';
    }
  }
}

String statusToLabel(dynamic status) {
  if (status == null) return '—';

  if (status is WordStatus) return status.display;

  if (status is String) {
    final s = status.toLowerCase();
    if (s.contains('known')) return 'Biliyorum';
    if (s.contains('unsure')) return 'Emin değilim';
    if (s.contains('unknown')) return 'Bilmiyorum';
    if (s.contains('none')) return '—';
    return status;
  }

  return status.toString();
}

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
      status: _parseStatus(map['status']),
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

  static WordStatus _parseStatus(dynamic raw) {
    if (raw == null) return WordStatus.none;

    if (raw is int) {
      if (raw >= 0 && raw < WordStatus.values.length) {
        return WordStatus.values[raw];
      }
      return WordStatus.none;
    }

    if (raw is String) {
      final s = raw.toLowerCase();
      if (s.contains('known')) return WordStatus.known;
      if (s.contains('unsure')) return WordStatus.unsure;
      if (s.contains('unknown')) return WordStatus.unknown;
      return WordStatus.none;
    }

    return WordStatus.none;
  }
}
