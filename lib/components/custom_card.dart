import 'package:flutter/material.dart';
import 'package:flutter_flip_card/flutter_flip_card.dart';
import 'package:prep_words/consts.dart';
import 'package:prep_words/models/word.dart';

class CustomFlipCard extends StatefulWidget {
  final WordModel word;
  final ValueChanged<WordStatus>? onStatusChanged;

  const CustomFlipCard({
    super.key,
    required this.word,
    this.onStatusChanged,
  });

  @override
  CustomFlipCardState createState() => CustomFlipCardState();
}

class CustomFlipCardState extends State<CustomFlipCard> {
  late FlipCardController flipCardController;

  @override
  void initState() {
    super.initState();
    flipCardController = FlipCardController();
  }

  @override
  Widget build(BuildContext context) {
    return FlipCard(
      rotateSide: RotateSide.right,
      onTapFlipping: true,
      axis: FlipAxis.vertical,
      controller: flipCardController,
      frontWidget: _buildFrontCard(),
      backWidget: _buildBackCard(),
    );
  }

  Widget _buildFrontCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: getFrontColor(widget.word.wordType),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: getFrontColor(widget.word.wordType).withAlpha(40),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Spacer(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.word.englishWord,
                        style: headingLarge.copyWith(
                          color: textWhiteColor,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: textWhiteColor.withAlpha(30),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.word.wordType,
                          style: bodySmall.copyWith(
                            color: textWhiteColor,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  widget.word.turkishMeaning,
                  textAlign: TextAlign.center,
                  style: headingMedium.copyWith(
                    color: textWhiteColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Spacer(),
            Column(
              children: [
                Icon(
                  Icons.touch_app_rounded,
                  color: textWhiteColor.withAlpha(200),
                  size: 32,
                ),
                SizedBox(height: 8),
                Text(
                  'Tap to turn the card.',
                  style: bodySmall.copyWith(
                    color: textWhiteColor.withAlpha(200),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: getBackColor(widget.word.wordType),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: getBackColor(widget.word.wordType).withAlpha(40),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Spacer(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Example',
                  style: headingSmall.copyWith(
                    color: textGreyColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  widget.word.exampleSentence,
                  textAlign: TextAlign.center,
                  style: bodyLarge.copyWith(
                    color: textGreyColor,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 24),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: textWhiteColor.withAlpha(50),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    widget.word.exampleTranslation,
                    textAlign: TextAlign.center,
                    style: bodyLarge.copyWith(
                      color: textGreyColor,
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
            Spacer(),
            Column(
              children: [
                Icon(
                  Icons.touch_app_rounded,
                  color: textGreyColor.withAlpha(150),
                  size: 32,
                ),
                SizedBox(height: 8),
                Text(
                  'Tap to turn the card',
                  style: bodySmall.copyWith(
                    color: textGreyColor.withAlpha(150),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
