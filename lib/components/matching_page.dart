import 'package:flutter/material.dart';
import 'package:prep_words/consts.dart';
import 'package:prep_words/models/word.dart';

class MatchingQuestionWidget extends StatefulWidget {
  final List<WordModel> words;
  final void Function(int correctCount) onCompleted;

  const MatchingQuestionWidget({
    super.key,
    required this.words,
    required this.onCompleted,
  });

  @override
  State<MatchingQuestionWidget> createState() => _MatchingQuestionWidgetState();
}

class _MatchingQuestionWidgetState extends State<MatchingQuestionWidget> {
  String? selectedEnglish;
  Map<String, String> matched = {}; // eşleşenler
  Map<String, Color> pairColors = {}; // eşleşme sonrası renkler
  late List<String> turkishWords;

  // 5 sabit renk
  final List<Color> softColors = [
    Colors.red.shade100,
    Colors.orange.shade100,
    Colors.blue.shade100,
    Colors.green.shade100,
    Colors.purple.shade100,
  ];

  @override
  void initState() {
    super.initState();
    // Türkçeleri karıştır ama sabit tut
    turkishWords = widget.words.map((w) => w.turkishMeaning).toList()
      ..shuffle();
  }

  void handleSelect(String english, String turkish) {
    final word = widget.words.firstWhere((w) => w.englishWord == english);
    final isCorrect = word.turkishMeaning == turkish;

    if (matched.containsKey(english)) return; // zaten doğru eşleşme yapılmış

    if (isCorrect) {
      // Doğru cevap
      setState(() {
        matched[english] = turkish;
        pairColors[english] = Colors.green;
        pairColors[turkish] = Colors.green;
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        final index = widget.words.indexOf(word);
        setState(() {
          pairColors[english] = softColors[index];
          pairColors[turkish] = softColors[index];
        });
        widget.onCompleted(1); // skor +1
      });
    } else {
      // Yanlış cevap
      setState(() {
        pairColors[english] = Colors.red;
        pairColors[turkish] = Colors.red;
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          pairColors.remove(english);
          pairColors.remove(turkish);
        });
        widget.onCompleted(0); // skor kaydı, yanlış
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          for (int groupStart = 0;
              groupStart < widget.words.length;
              groupStart += 5)
            Column(
              children: [
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: List.generate(
                          (groupStart + 5 <= widget.words.length)
                              ? 5
                              : widget.words.length - groupStart, (i) {
                        final word = widget.words[groupStart + i];
                        final turkish = turkishWords[groupStart + i];
                        final matchedEnglish = matched.entries
                            .firstWhere((e) => e.value == turkish,
                                orElse: () => const MapEntry('', ''))
                            .key;
                        final englishColor =
                            matched.containsKey(word.englishWord)
                                ? pairColors[word.englishWord]
                                : Colors.white;
                        final turkishColor = matchedEnglish.isNotEmpty
                            ? pairColors[matchedEnglish]
                            : Colors.white;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // İngilizce
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedEnglish = word.englishWord;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14, horizontal: 12),
                                      decoration: BoxDecoration(
                                        color: englishColor,
                                        border: Border.all(
                                            color: selectedEnglish ==
                                                    word.englishWord
                                                ? secondary
                                                : Colors.grey.shade300),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          )
                                        ],
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        word.englishWord,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: textGreyColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Türkçe
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      if (selectedEnglish != null &&
                                          !matched
                                              .containsKey(selectedEnglish)) {
                                        handleSelect(selectedEnglish!, turkish);
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14, horizontal: 12),
                                      decoration: BoxDecoration(
                                        color: turkishColor,
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          )
                                        ],
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        turkish,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: textGreyColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                if (groupStart + 5 < widget.words.length)
                  const SizedBox(height: 12),
              ],
            ),
        ],
      ),
    );
  }
}
