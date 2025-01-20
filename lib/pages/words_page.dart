import 'package:flutter/material.dart';
import 'package:prep_words/components/custom_appbar.dart';
import 'package:prep_words/components/custom_card.dart';
import 'package:prep_words/consts.dart';
import 'package:prep_words/models/word.dart';
import 'package:prep_words/services/firebase_service.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Ünite ${widget.unit}',
        showBackButton: true,
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
          print('Mevcut kelime: ${words[currentPage].englishWord}');

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
                      print('Sayfa değişti. Yeni index: $index');
                    });
                  },
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CustomFlipCard(
                        key:
                            ValueKey(words[index].englishWord), // Benzersiz key
                        word: words[currentPage],
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  '${currentPage + 1} / ${words.length}',
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
                        onPressed: () {
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('Tüm kelimeleri tamamladınız!')),
                            );
                          }
                        },
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
                        onPressed: () {
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('Tüm kelimeleri tamamladınız!')),
                            );
                          }
                        },
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
                        onPressed: () {
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('Tüm kelimeleri tamamladınız!')),
                            );
                          }
                        },
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
}
