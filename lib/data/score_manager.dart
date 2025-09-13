// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:prep_words/data/practice_stats.dart';
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
  int earnedXp = 0; // Kazanılan XP
  bool showFinalScore = false;

  late List<WordModel> mcqWords; // 10 çoktan seçmeli
  late List<List<WordModel>> matchingGroups; // 5’li gruplar
  late PageController _controller;

  // UI state’ini korumak için
  Map<int, String?> selectedOptions = {};
  Map<int, Map<String, String>> matchingGroupState = {};

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

  void _finishPractice() async {
    earnedXp = score * 10; // XP hesapla
    await PracticeStats.savePracticeResult(widget.practiceNumber, earnedXp);

    setState(() {
      showFinalScore = true;
    });

    _controller.animateToPage(
      mcqWords.length + matchingGroups.length,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalPages = mcqWords.length + matchingGroups.length;

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
          PageView.builder(
            controller: _controller,
            itemCount: showFinalScore ? totalPages + 1 : totalPages,
            itemBuilder: (context, index) {
              if (showFinalScore && index == totalPages) {
                // Final Score ekranı
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
                      const SizedBox(height: 24),
                      Text(
                        "XP Earned",
                        style: headingLarge.copyWith(fontSize: 32),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "$earnedXp",
                        style: const TextStyle(
                            fontSize: 48, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: secondary,
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 28),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Back",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Çoktan seçmeli sorular
              if (index < mcqWords.length) {
                WordModel word = mcqWords[index];
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      MultipleChoiceQuestionWidget(
                        word: word,
                        allWords: mcqWords,
                        initialSelectedOption:
                            selectedOptions[index], // Önceki seçimi göster
                        onAnswered: (correct, selected) {
                          setState(() {
                            if (correct) score++;
                            selectedOptions[index] = selected; // Kaydet
                          });
                        },
                      ),
                    ],
                  ),
                );
              }

              // Matching sorular
              if (index < mcqWords.length + matchingGroups.length) {
                int matchingIndex = index - mcqWords.length;
                List<WordModel> group = matchingGroups[matchingIndex];

                Map<String, String> initialMatched =
                    matchingGroupState[matchingIndex] ?? {};

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      MatchingQuestionWidget(
                        words: group,
                        initialMatched: initialMatched,
                        onCompleted: (correctCount, updatedMatched) {
                          setState(() {
                            score += correctCount;
                            matchingGroupState[matchingIndex] = updatedMatched;
                          });
                        },
                      ),
                    ],
                  ),
                );
              }

              return const SizedBox.shrink();
            },
            onPageChanged: (index) {
              setState(() {}); // Sayfa göstergesini güncelle
            },
          ),

          // Sayfa göstergesi
          Positioned(
            top: 8,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              alignment: Alignment.center,
              child: Text(
                "Page ${(_controller.hasClients ? (_controller.page?.round() ?? 0) + 1 : 1)} / ${totalPages + (showFinalScore ? 1 : 0)}",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // Finish butonu sadece son soru sayfasında
          if (!showFinalScore)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Builder(builder: (context) {
                int currentIndex =
                    _controller.hasClients ? _controller.page?.round() ?? 0 : 0;
                bool isLastQuestionPage = currentIndex == totalPages - 1;

                if (!isLastQuestionPage) return const SizedBox.shrink();

                return ElevatedButton(
                  onPressed: _finishPractice,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondary,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 28),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Finish",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }
}
