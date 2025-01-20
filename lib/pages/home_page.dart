import 'package:flutter/material.dart';
import 'package:prep_words/components/custom_appbar.dart';
import 'package:prep_words/consts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: CustomAppBar(title: 'exaMate'),
      backgroundColor: backgrnd,
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            // Profil Bölümü
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: textWhiteColor,
                    child: Text(
                      'SG',
                      style: headingLarge.copyWith(color: primary),
                    ),
                  ),
                  SizedBox(width: 16),
                  Text(
                    'Hoş Geldin Selin',
                    style: headingLarge.copyWith(color: textWhiteColor),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Başlık
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: secondaryOrange,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                'Bir Yerden Başla!',
                style: headingMedium,
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: 24),

            // Seviye Kartları
            Expanded(
              child: ListView(
                children: [
                  _buildLevelCard(
                    levelNumber: 1,
                    levelName: 'Başlangıç Seviyesi',
                    unitNumber: 6,
                    context: context,
                  ),
                  SizedBox(height: 16),
                  _buildLevelCard(
                    levelNumber: 2,
                    levelName: 'Orta Seviye',
                    unitNumber: 22,
                    context: context,
                  ),
                  SizedBox(height: 16),
                  _buildLevelCard(
                    levelNumber: 3,
                    levelName: 'İleri Seviye',
                    unitNumber: 20,
                    context: context,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelCard({
    required int levelNumber,
    required String levelName,
    required int unitNumber,
    required BuildContext context,
  }) {
    double indicatorValue = ((100 * 3) / unitNumber) / 100;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: textWhiteColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(25),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                levelNumber.toString(),
                style: headingLarge.copyWith(color: textWhiteColor),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(levelName, style: headingMedium),
                SizedBox(height: 4),
                Text(
                  '3 / $unitNumber Ünite',
                  style: bodyMedium,
                ),
                SizedBox(height: 8),
                Stack(
                  children: [
                    Container(
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Container(
                      height: 20,
                      width: MediaQuery.of(context).size.width *
                          0.4 *
                          indicatorValue,
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Center(
                      child: Text(
                        '%${(indicatorValue * 100).toInt()}',
                        style: bodySmall.copyWith(color: textWhiteColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.pushReplacementNamed(
                context,
                '/levels',
                arguments: {
                  'level': levelNumber,
                  'levelName': levelName,
                  'unitCount': unitNumber,
                },
              );
            },
            icon: Icon(Icons.arrow_forward_ios, color: textGreyColor),
          ),
        ],
      ),
    );
  }
}
