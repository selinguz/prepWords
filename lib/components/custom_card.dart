import 'package:flutter/material.dart';
import 'package:flutter_flip_card/flutter_flip_card.dart';
import 'package:prep_words/consts.dart';
import 'package:prep_words/models/word.dart';

class CustomFlipCard extends StatelessWidget {
  final WordModel word;
  final FlipCardController flipCardController = FlipCardController();

  CustomFlipCard({
    super.key,
    required this.word,
  });

  @override
  Widget build(BuildContext context) {
    return FlipCard(
      rotateSide: RotateSide.right,
      onTapFlipping: true, // true = tıklama ile döndürme aktif
      axis: FlipAxis.horizontal,
      controller: flipCardController,
      frontWidget: _buildFrontCard(),
      backWidget: _buildBackCard(),
    );
  }

  Widget _buildFrontCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: primary,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              word.englishWord,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textWhiteColor,
              ),
            ),
            SizedBox(height: 10),
            Text(
              word.turkishMeaning,
              style: TextStyle(
                fontSize: 20,
                color: textWhiteColor,
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: secondaryOrange,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                word.wordType,
                style: TextStyle(
                  fontSize: 16,
                  color: textWhiteColor,
                ),
              ),
            ),
            SizedBox(height: 20),
            Icon(
              Icons.touch_app,
              color: textWhiteColor,
              size: 30,
            ),
            Text(
              'Kartı çevirmek için dokun',
              style: TextStyle(
                color: textWhiteColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: secondaryOrange,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Örnek Cümle:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textWhiteColor,
              ),
            ),
            SizedBox(height: 10),
            Text(
              word.exampleSentence,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: textWhiteColor,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Çeviri:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textWhiteColor,
              ),
            ),
            SizedBox(height: 10),
            Text(
              word.turkishMeaning,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: textWhiteColor,
              ),
            ),
            SizedBox(height: 20),
            Icon(
              Icons.touch_app,
              color: textWhiteColor,
              size: 30,
            ),
            Text(
              'Kartı çevirmek için dokun',
              style: TextStyle(
                color: textWhiteColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
