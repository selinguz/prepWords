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
  const WordsPage({super.key, required this.unit});

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

  /// 🔹 SharedPreferences’a kelime durumunu kaydet
  Future<void> _saveWordStatus(String word, WordStatus status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('word_status_$word', status.toString());
  }

  /// 🔹 SharedPreferences’tan kelime durumunu al
  Future<WordStatus> _loadWordStatus(String word) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('word_status_$word');
    if (saved == null) return WordStatus.unknown;
    return WordStatus.values.firstWhere(
      (s) => s.toString() == saved,
      orElse: () => WordStatus.unknown,
    );
  }

  /// 🔹 Kelimeleri yükle ve durumları uygula
  Future<void> _loadWords() async {
    final fetchedWords = await firebaseService.fetchWordsByUnit(widget.unit);

    // Her kelimenin durumu SharedPreferences'ta varsa onu al, yoksa unknown ata
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
    prefs.setBool('unit_${widget.unit}_completed', true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text('Tebrikler! Bu ünitenin tüm kelimelerini tamamladınız.')),
    );

    int nextUnit = widget.unit + 1;
    prefs.setBool('unit_${nextUnit}_unlocked', true);
  }

  /// 🔹 Sonraki kelimeye geç (kaydırma veya buton)
  void _nextPage({bool markUnknownIfEmpty = false}) {
    if (markUnknownIfEmpty) {
      if (words[currentPage].status == WordStatus.unknown) {
        _saveWordStatus(words[currentPage].englishWord, WordStatus.unknown);
      }
    }

    if (currentPage < words.length - 1) {
      setState(() {
        currentPage++;
      });
      _pageController.animateToPage(
        currentPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      if (words.every((w) => w.status == WordStatus.known)) {
        _onUnitCompleted();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tüm kelimeleri tamamladınız!')),
        );
      }
    }
  }

  /// 🔹 Kelimeyi işaretle ve sonraki sayfaya geç
  void _markWord(WordStatus status) {
    setState(() {
      words[currentPage].status = status;
    });
    _saveWordStatus(words[currentPage].englishWord, status);
    _nextPage();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: CustomAppBar(title: 'Ünite ${widget.unit}'),
        backgroundColor: backgrnd,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final totalWords = words.length;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Ünite ${widget.unit}',
      ),
      backgroundColor: backgrnd,
      body: Column(
        children: [
          Expanded(
            flex: 80,
            child: PageView.builder(
              controller: _pageController,
              itemCount: words.length,
              physics: ClampingScrollPhysics(),
              onPageChanged: (index) {
                // Kullanıcı kaydırma yaparsa önceki kelimeyi kaydet
                if (index > currentPage) {
                  _nextPage(markUnknownIfEmpty: true);
                } else {
                  setState(() {
                    currentPage = index;
                  });
                }
              },
              itemBuilder: (context, index) {
                final word = words[index];
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CustomFlipCard(
                    key: ValueKey('${word.englishWord}_${word.status}'),
                    word: word,
                    onStatusChanged: (status) {
                      setState(() {
                        word.status = status;
                      });
                      _saveWordStatus(word.englishWord, status);
                    },
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          words[currentPage].status == WordStatus.known
                              ? Colors.green
                              : Colors.grey,
                    ),
                    onPressed: () => _markWord(WordStatus.known),
                    child: Text('Biliyorum',
                        style: TextStyle(color: textWhiteColor)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          words[currentPage].status == WordStatus.unsure
                              ? Colors.orange
                              : Colors.grey,
                    ),
                    onPressed: () => _markWord(WordStatus.unsure),
                    child: Text('Emin Değilim',
                        style: TextStyle(color: textWhiteColor)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          words[currentPage].status == WordStatus.unknown
                              ? Colors.red
                              : Colors.grey,
                    ),
                    onPressed: () => _markWord(WordStatus.unknown),
                    child: Text('Bilmiyorum',
                        style: TextStyle(color: textWhiteColor)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
