// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:prep_words/models/word.dart';
import 'package:prep_words/components/multiple_choice_widget.dart';
import 'package:prep_words/components/matching_page.dart';
import 'package:prep_words/consts.dart';
import 'package:prep_words/data/practice_stats.dart';

class PracticeExercisePage extends StatefulWidget {
  const PracticeExercisePage({
    super.key,
    required this.allWords,
    required this.practiceNumber,
  });

  final List<WordModel> allWords;
  final int practiceNumber;

  @override
  State<PracticeExercisePage> createState() => _PracticeExercisePageState();
}

class _PracticeExercisePageState extends State<PracticeExercisePage> {
  late List<Map<String, dynamic>> pages;
  int earnedXp = 0;
  int matchingCorrect = 0;
  Map<int, Map<String, String>> matchingGroupState = {};
  late List<List<WordModel>> matchingGroups;
  int matchingWrong = 0;
  int mcqCorrect = 0;
  late List<WordModel> mcqWords;
  int mcqWrong = 0;
  // Matching cevabı için state kontrolü
  Map<int, Map<String, String>> previousMatchingState = {};

  double score = 0.0;
  Map<int, String?> selectedOptions = {};
  bool showFinalScore = false;

  late PageController _controller;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    widget.allWords.shuffle();

    // 10 MCQ kelimesi seç
    mcqWords = widget.allWords.take(10).toList();

    // Matching için kalan kelimeleri al
    List<WordModel> remaining = widget.allWords.skip(10).toList();

    // 30 kelimelik 6 grup (5'erli)
    matchingGroups = [];
    for (int i = 0; i < 30; i += 5) {
      matchingGroups.add(remaining.skip(i).take(5).toList());
    }

    // 🔀 Tüm sayfaları bir listede topla (MCQ + Matching) ve karıştır
    pages = [
      ...mcqWords.map((w) => {'type': 'mcq', 'word': w}),
      ...List.generate(matchingGroups.length,
          (i) => {'type': 'matching', 'group': matchingGroups[i], 'index': i}),
    ]..shuffle();

    _controller = PageController();
  }

  void _handleMCQAnswer(bool isCorrect) {
    setState(() {
      if (isCorrect) {
        mcqCorrect++;
        score += (2.5);
      } else {
        mcqWrong++;
        score -= 1;
      }

      earnedXp = score.toInt() * 3; //
      debugPrint(
          "MCQ -> Correct: $mcqCorrect, Wrong: $mcqWrong, Score: $score, XP: $earnedXp");
    });
  }

  void _handleMatchingAnswer(bool isCorrect) {
    setState(() {
      if (isCorrect) {
        matchingCorrect++;
        score += (2.5);
      } else {
        matchingWrong++;
        score -= 1;
      }

      earnedXp = score.toInt() * 3; // XP
    });

    debugPrint(
        'Matching -> Correct: $matchingCorrect, Wrong: $matchingWrong, Score: $score, XP: $earnedXp');
  }

  bool get allAnswered {
    // MCQ’lar: null olmayanlar cevaplanmış
    bool mcqDone =
        selectedOptions.values.whereType<String>().length == mcqWords.length;

    // Matching: her grubun matched map’i boş değilse cevaplanmış sayılır
    bool matchingDone = matchingGroupState.length == matchingGroups.length &&
        matchingGroupState.values.every((m) => m.isNotEmpty);

    return mcqDone && matchingDone;
  }

  @override
  Widget build(BuildContext context) {
    int totalPages = mcqWords.length + matchingGroups.length;
    int totalPagesWithFinal = showFinalScore ? totalPages + 1 : totalPages;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: kToolbarHeight * 1.2,
        backgroundColor: yellowGreen,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Practice ${widget.practiceNumber}",
          style: headingLarge,
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/greenBackground.png',
              opacity: const AlwaysStoppedAnimation<double>(0.3),
              fit: BoxFit.cover,
            ),
          ),
          PageView.builder(
            controller: _controller,
            itemCount: totalPagesWithFinal,
            itemBuilder: (context, index) {
              if (showFinalScore && index == totalPages) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Final Score",
                          style: headingLarge.copyWith(fontSize: 32)),
                      const SizedBox(height: 24),
                      Text("$score", style: headingLarge),
                      const SizedBox(height: 24),
                      Text("XP Earned",
                          style: headingLarge.copyWith(fontSize: 32)),
                      const SizedBox(height: 24),
                      Text("$earnedXp", style: headingLarge),
                      const SizedBox(height: 32),

                      // 🔽 Finish butonu sadece tüm sorular cevaplandığında görünür
                      if (allAnswered)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("Finish"),
                        ),
                    ],
                  ),
                );
              }

              final page = pages[index];

              if (page['type'] == 'mcq') {
                WordModel word = page['word'];
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: MultipleChoiceQuestionWidget(
                    word: word,
                    allWords: mcqWords,
                    initialSelectedOption: selectedOptions[index],
                    onAnswered: (correct, selected) {
                      selectedOptions[index] = selected;
                      _handleMCQAnswer(correct);

                      if (correct) {
                        if (_controller.hasClients && index < totalPages - 1) {
                          Future.delayed(const Duration(milliseconds: 500), () {
                            _controller.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          });
                        }
                      }
                    },
                  ),
                );
              } else {
                int matchingIndex = page['index'];
                List<WordModel> group = page['group'];

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: MatchingQuestionWidget(
                    words: group,
                    initialMatched: matchingGroupState[matchingIndex] ?? {},
                    onCompleted: (isCorrect, matched) {
                      _handleMatchingAnswer(isCorrect);
                      setState(() {
                        matchingGroupState[matchingIndex] = matched;
                      });

                      // Tüm eşleşmeler tamamlandıysa
                      int requiredMatches =
                          matchingGroups[matchingIndex].length;
                      if (matched.length == requiredMatches) {
                        if (_controller.hasClients && index < totalPages - 1) {
                          Future.delayed(const Duration(milliseconds: 500), () {
                            _controller.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          });
                        }
                      }
                    },
                  ),
                );
              }
            },
            onPageChanged: (index) {
              setState(() {});
            },
          ),
          Positioned(
            top: 8,
            left: 0,
            right: 0,
            child: Container(
              alignment: Alignment.center,
              child: Text(
                "Question ${(_controller.hasClients ? (_controller.page?.round() ?? 0) + 1 : 1)} / $totalPagesWithFinal",
                style: headingMedium,
              ),
            ),
          ),
          if (!showFinalScore)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Builder(
                builder: (context) {
                  int currentIndex = _controller.hasClients
                      ? _controller.page?.round() ?? 0
                      : 0;
                  bool isLastQuestionPage = currentIndex == totalPages - 1;

                  // 🔹 Sadece son sayfada göster
                  if (!isLastQuestionPage) return const SizedBox.shrink();

                  return ElevatedButton(
                    onPressed: () async {
                      // MCQ ve Matching kontrolü
                      bool mcqDone =
                          selectedOptions.values.whereType<String>().length ==
                              mcqWords.length;

                      bool matchingDone =
                          matchingGroups.asMap().entries.every((e) {
                        final requiredMatches = e.value.length;
                        final matched = matchingGroupState[e.key] ?? {};
                        return matched.length == requiredMatches;
                      });

                      if (!mcqDone || !matchingDone) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: yellowGreen,
                            behavior: SnackBarBehavior.fixed,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            content: Text(
                                "Testte cevaplanmamış soru/sorular var.",
                                textAlign: TextAlign.center,
                                style: bodyLarge),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                        return;
                      }

                      // Tüm sorular tamamlandıysa final skor ekranına geç
                      int totalCorrect = mcqCorrect + matchingCorrect;
                      double successRate = (totalCorrect / 40) * 100;

                      debugPrint(
                          "✅ Success Rate: ${successRate.toStringAsFixed(2)}%");

                      await PracticeStats.savePracticeResult(
                          widget.practiceNumber, earnedXp, successRate);

                      setState(() => showFinalScore = true);
                      _controller.animateToPage(
                        totalPages,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondary,
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 28),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Finish", style: whiteButtonText),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
