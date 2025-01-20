import 'package:flutter/material.dart';
import 'package:prep_words/components/custom_appbar.dart';
import 'package:prep_words/components/custom_card.dart';
import 'package:prep_words/consts.dart';
import 'package:prep_words/models/word.dart';
import 'package:prep_words/services/firebase_service.dart';

class WordTypeDetailPage extends StatelessWidget {
  final String wordType;

  const WordTypeDetailPage({
    super.key,
    required this.wordType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: wordType,
      ),
      backgroundColor: backgrnd,
      body: FutureBuilder<List<WordModel>>(
        future: FirebaseService().getWordsByType(wordType),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

          final words = snapshot.data ?? [];

          return Column(
            children: [
              Expanded(
                child: PageView.builder(
                  itemCount: words.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CustomFlipCard(word: words[index]),
                    );
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Bu türde ${words.length} kelime bulunuyor',
                  style: bodyMedium.copyWith(color: textGreyColor),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
