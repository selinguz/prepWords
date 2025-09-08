import 'package:flutter/material.dart';
import 'package:prep_words/models/word.dart';
import 'package:prep_words/components/multiple_choice_widget.dart';
import 'package:prep_words/components/matching_page.dart';
import 'package:prep_words/consts.dart';

class PracticeExercisePage extends StatefulWidget {
  final List<WordModel> allWords;
  final int practiceNumber;

  const PracticeExercisePage({
    super.key,
    required this.allWords,
    required this.practiceNumber,
  });

  @override
  State<PracticeExercisePage> createState() => _PracticeExercisePageState();
}

class _PracticeExercisePageState extends State<PracticeExercisePage> {
  int score = 0;
  late List<WordModel> mcqWords; // 10 çoktan seçmeli
  late List<List<WordModel>> matchingGroups; // 5’li gruplar
  late PageController _controller;

  @override
  void initState() {
    super.initState();

    widget.allWords.shuffle();

    mcqWords = widget.allWords.take(10).toList();
    List<WordModel> remaining = widget.allWords.skip(10).toList();
    matchingGroups = [];
    for (int i = 0; i < remaining.length; i += 5) {
      matchingGroups.add(remaining.skip(i).take(5).toList());
    }

    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int totalPages =
        mcqWords.length + matchingGroups.length + 1; // +1 skor sayfası

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: kToolbarHeight * 1.2,
        backgroundColor: primary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Practice ${widget.practiceNumber}",
          style: headingLarge,
        ),
      ),
      body: Column(
        children: [
          // Sayfa göstergesi
          Container(
            padding: const EdgeInsets.all(8),
            alignment: Alignment.center,
            child: Text(
              "Page ${(_controller.hasClients ? (_controller.page?.round() ?? 0) + 1 : 1)} / $totalPages",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: totalPages,
              itemBuilder: (context, index) {
                if (index < mcqWords.length) {
                  // Çoktan seçmeli
                  WordModel word = mcqWords[index];
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        MultipleChoiceQuestionWidget(
                          word: word,
                          allWords: mcqWords,
                          onAnswered: (correct) {
                            if (correct) score++;
                          },
                        ),
                        const SizedBox(height: 24),
                        Text("Score: $score",
                            style: const TextStyle(fontSize: 20)),
                      ],
                    ),
                  );
                } else if (index < mcqWords.length + matchingGroups.length) {
                  // 5’li eşleştirme grubu
                  int matchingIndex = index - mcqWords.length;
                  List<WordModel> group = matchingGroups[matchingIndex];
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        MatchingQuestionWidget(
                          words: group,
                          onCompleted: (correctCount) {
                            score += correctCount;
                          },
                        ),
                        const SizedBox(height: 24),
                        Text("Score: $score",
                            style: const TextStyle(fontSize: 20)),
                      ],
                    ),
                  );
                } else {
                  // Son skor sayfası
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Final Score",
                          style: headingLarge.copyWith(fontSize: 32),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "$score",
                          style: const TextStyle(
                              fontSize: 48, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }
              },
              onPageChanged: (index) {
                setState(() {}); // Sayfa göstergesini güncellemek için
              },
            ),
          ),
        ],
      ),
    );
  }
}
