import 'package:flutter/material.dart';
import 'package:prep_words/components/custom_appbar.dart';
import 'package:prep_words/consts.dart';
import 'package:prep_words/models/word.dart';
import 'package:prep_words/services/firebase_service.dart';

class WordsPage extends StatefulWidget {
  const WordsPage({super.key});

  @override
  State<WordsPage> createState() => _WordsPageState();
}

class _WordsPageState extends State<WordsPage> {
  final firebaseService = FirebaseService();

  Future<void> getWords() async {
    try {
      List<WordModel> words = await firebaseService.fetchWords();
      for (var word in words) {
        print('${word.englishWord} - ${word.turkishMeaning}');
      }
    } catch (e) {
      print('Hata: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Learn New Words'),
      backgroundColor: backgrnd,
      body: FutureBuilder<List<WordModel>>(
        future: firebaseService.fetchWords(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Hiç kelime bulunamadı.'));
          }

          final words = snapshot.data!;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.60,
                  height: MediaQuery.of(context).size.height * 0.10,
                  color: cardFrontColor,
                  child: Center(
                    child: Text(
                      words[0].englishWord,
                      style: TextStyle(fontSize: 22.0, color: textWhiteColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.60,
                  height: MediaQuery.of(context).size.height * 0.10,
                  color: secondaryOrange,
                  child: Center(
                    child: Text(
                      words[0].turkishMeaning,
                      style: TextStyle(fontSize: 22.0, color: textGreyColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
