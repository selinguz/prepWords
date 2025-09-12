// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:prep_words/components/custom_appbar.dart';
import 'package:prep_words/components/custom_card.dart';
import 'package:prep_words/consts.dart';
import 'package:prep_words/models/word.dart';
import 'package:prep_words/services/firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WordsPage extends StatefulWidget {
  final int unit;
  final VoidCallback? onComplete;

  const WordsPage({super.key, required this.unit, this.onComplete});

  @override
  State<WordsPage> createState() => _WordsPageState();
}

class _WordsPageState extends State<WordsPage> {
  final firebaseService = FirebaseService();
  late PageController _pageController;
  int currentPage = 0;
  List<WordModel> words = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _loadWords();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// 🔹 Kelimenin durumunu kaydet
  Future<void> _saveWordStatus(String word, WordStatus status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('word_status_$word', status.toString());
  }

  /// 🔹 SharedPreferences’tan kelime durumunu al
  Future<WordStatus> _loadWordStatus(String word) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('word_status_$word');
    if (saved == null) return WordStatus.none;
    return WordStatus.values.firstWhere(
      (s) => s.toString() == saved,
      orElse: () => WordStatus.none,
    );
  }

  /// 🔹 Kelimeleri Firebase’den al ve durumlarını yükle
  Future<void> _loadWords() async {
    final fetchedWords = await firebaseService.fetchWordsByUnit(widget.unit);

    for (var w in fetchedWords) {
      w.status = await _loadWordStatus(w.englishWord);
    }

    setState(() {
      words = fetchedWords;
      isLoading = false;
    });
  }

  /// 🔹 Ünite tamamlandığında SharedPreferences ve UI bildirimi
  void _onUnitCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    int knownCount = words.where((w) => w.status == WordStatus.known).length;
    int total = words.length;

    if (knownCount >= (total * 0.9).floor()) {
      prefs.setBool('unit_${widget.unit}_completed', true);
      prefs.setBool('unit_${widget.unit + 1}_unlocked', true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Congratulations! You unlocked the next unit 🎉'),
        ),
      );

      widget.onComplete?.call();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You need to know at least 90% of the words.'),
        ),
      );
    }
  }

  /// 🔹 Sonraki kelimeye geç
  void _nextPage() {
    if (currentPage < words.length - 1) {
      setState(() => currentPage++);
      _pageController.animateToPage(
        currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// 🔹 Kelimeyi işaretle ve kaydet
  void _markWord(WordStatus status) {
    setState(() {
      words[currentPage].status = status;
    });
    _saveWordStatus(words[currentPage].englishWord, status);

    if (currentPage < words.length - 1) {
      _nextPage();
    } else {
      _onUnitCompleted();
    }
  }

  /// 🔹 Buton renklerini belirle
  Color getWordButtonColor(WordStatus status, WordStatus buttonType) {
    if (status == WordStatus.none) {
      switch (buttonType) {
        case WordStatus.known:
          return Colors.green;
        case WordStatus.unsure:
          return Colors.orange;
        case WordStatus.unknown:
          return Colors.red;
        default:
          return Colors.blueAccent;
      }
    } else {
      return status == buttonType
          ? (buttonType == WordStatus.known
              ? Colors.green
              : buttonType == WordStatus.unsure
                  ? Colors.orange
                  : Colors.red)
          : Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: CustomAppBar(title: 'Unit ${widget.unit}'),
        backgroundColor: backgrnd,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final totalWords = words.length;

    return Scaffold(
      appBar: CustomAppBar(title: 'Unit ${widget.unit}'),
      backgroundColor: backgrnd,
      body: Column(
        children: [
          Expanded(
            flex: 80,
            child: PageView.builder(
              controller: _pageController,
              itemCount: totalWords,
              physics: const ClampingScrollPhysics(),
              onPageChanged: (index) {
                setState(() => currentPage = index);
              },
              itemBuilder: (context, index) {
                final word = words[index];
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CustomFlipCard(
                    key: ValueKey('${word.englishWord}_${word.status}'),
                    word: word,
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              '${currentPage + 1} / $totalWords',
              style: TextStyle(
                color: textGreyColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 20,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: getWordButtonColor(
                          words[currentPage].status, WordStatus.known),
                    ),
                    onPressed: () => _markWord(WordStatus.known),
                    child: Text('I know',
                        style: bodyMedium.copyWith(color: Colors.white)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: getWordButtonColor(
                          words[currentPage].status, WordStatus.unsure),
                    ),
                    onPressed: () => _markWord(WordStatus.unsure),
                    child: Text('Not sure',
                        style: bodyMedium.copyWith(color: Colors.white)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: getWordButtonColor(
                          words[currentPage].status, WordStatus.unknown),
                    ),
                    onPressed: () => _markWord(WordStatus.unknown),
                    child: Text('I don\'t know',
                        style: bodyMedium.copyWith(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.03),
        ],
      ),
    );
  }
}
