import 'package:flutter/material.dart';
import 'package:prep_words/consts.dart';
import '../models/word.dart';

class MultipleChoiceQuestionWidget extends StatefulWidget {
  final WordModel word;
  final List<WordModel> allWords;
  final void Function(bool correct) onAnswered;

  const MultipleChoiceQuestionWidget({
    super.key,
    required this.word,
    required this.allWords,
    required this.onAnswered,
  });

  @override
  State<MultipleChoiceQuestionWidget> createState() =>
      _MultipleChoiceQuestionWidgetState();
}

class _MultipleChoiceQuestionWidgetState
    extends State<MultipleChoiceQuestionWidget> {
  List<String> options = [];
  String? selectedOption;
  bool answered = false;

  @override
  void initState() {
    super.initState();

    List<String> allMeanings =
        widget.allWords.map((w) => w.turkishMeaning).toList();
    allMeanings.remove(widget.word.turkishMeaning);
    allMeanings.shuffle();
    List<String> fakeOptions = allMeanings.take(3).toList();

    options = [...fakeOptions, widget.word.turkishMeaning]..shuffle();
  }

  void _selectOption(String option) {
    if (answered) return;
    setState(() {
      selectedOption = option;
      answered = true;
    });
    widget.onAnswered(option == widget.word.turkishMeaning);
  }

  Color _getOptionColor(String option) {
    if (!answered) return Colors.grey.shade200;
    if (option == widget.word.turkishMeaning) return Colors.green;
    if (option == selectedOption) return Colors.red;
    return Colors.grey.shade200;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Kelime ve türü
            Text(
              '${widget.word.englishWord} (${widget.word.wordType})',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: cardFrontColor,
              ),
            ),
            const SizedBox(height: 16),
            // 🔹 Şıklar
            Column(
              children: options.map((option) {
                return GestureDetector(
                  onTap: () => _selectOption(option),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 18),
                    decoration: BoxDecoration(
                      color: _getOptionColor(option),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            option,
                            style: TextStyle(
                              fontSize: 18,
                              color: textGreyColor,
                            ),
                          ),
                        ),
                        if (answered)
                          Icon(
                            option == widget.word.turkishMeaning
                                ? Icons.check_circle
                                : option == selectedOption
                                    ? Icons.cancel
                                    : null,
                            color: option == widget.word.turkishMeaning
                                ? secondaryGreen
                                : option == selectedOption
                                    ? warnOrange
                                    : Colors.transparent,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
