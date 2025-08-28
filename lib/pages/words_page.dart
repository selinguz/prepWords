import 'package:flutter/material.dart';
import 'package:prep_words/components/custom_appbar.dart';
import 'package:prep_words/components/custom_card.dart';
import 'package:prep_words/consts.dart';
import 'package:prep_words/models/word.dart';
import 'package:prep_words/services/firebase_service.dart';
import 'package:prep_words/services/unit_storage.dart';
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

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void onUnitCompleted() async {
    final nextUnit = widget.unit + 1;
    await UnitStorage.unlockUnit(nextUnit);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text('Tüm kelimeleri tamamladınız! Ünite $nextUnit açıldı.')),
    );
  }

  void _onUnitCompleted() async {
    final prefs = await SharedPreferences.getInstance();

    // Üniteyi tamamlandı olarak kaydet
    prefs.setBool('unit_${widget.unit}_completed', true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text('Tebrikler! Bu ünitenin tüm kelimelerini tamamladınız.')),
    );

    // Burada isteğe bağlı olarak bir sonraki üniteyi açmak için
    int nextUnit = widget.unit + 1;
    prefs.setBool('unit_${nextUnit}_unlocked', true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Ünite ${widget.unit}',
      ),
      backgroundColor: backgrnd,
      body: FutureBuilder<List<WordModel>>(
        future: firebaseService.fetchWordsByUnit(widget.unit),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Bu ünitede kelime bulunamadı.'));
          }

          final words = snapshot.data!;
          final totalWords = words.length;
          int knownCount =
              words.where((w) => w.status == WordStatus.known).length;

          return Column(
            children: [
              Expanded(
                flex: 80,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: words.length,
                  physics: ClampingScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CustomFlipCard(
                        key: ValueKey(words[index].englishWord),
                        word: words[currentPage],
                        onStatusChanged: (status) {
                          setState(() {
                            words[currentPage].status = status;
                          });
                          // Tüm kelimeler biliniyorsa üniteyi tamamla
                          if (words
                              .every((w) => w.status == WordStatus.known)) {
                            onUnitCompleted();
                          }
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
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () =>
                            _markCurrentWord(WordStatus.known, words),
                        child: Text('Biliyorum',
                            style: TextStyle(color: textWhiteColor)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () =>
                            _markCurrentWord(WordStatus.unsure, words),
                        child: Text('Emin Değilim',
                            style: TextStyle(color: textWhiteColor)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () =>
                            _markCurrentWord(WordStatus.unknown, words),
                        child: Text('Bilmiyorum',
                            style: TextStyle(color: textWhiteColor)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _markCurrentWord(WordStatus status, List<WordModel> words) {
    setState(() {
      words[currentPage].status = status;

      // Eğer sayfanın sonundayız
      if (currentPage < words.length - 1) {
        currentPage++;
        _pageController.animateToPage(
          currentPage,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        // Ünite tamamlandı mı kontrol et
        if (words.every((w) => w.status == WordStatus.known)) {
          _onUnitCompleted();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tüm kelimeleri tamamladınız!')),
          );
        }
      }
    });
  }
}
