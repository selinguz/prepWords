import 'package:flutter/material.dart';
import 'package:prep_words/components/custom_appbar.dart';
import 'package:prep_words/consts.dart';
import 'package:prep_words/pages/categories_content.dart';
import 'package:prep_words/pages/profile_content.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0
          ? CustomAppBar(
              title: 'exaMate',
              onBackPressed: null,
            )
          : null,
      backgroundColor: backgrnd,
      body: _selectedIndex == 0
          ? _buildHomePage()
          : _selectedIndex == 1
              ? const CategoriesContent()
              : const ProfileContent(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.deepOrange.withAlpha(120),
              spreadRadius: 1,
              blurRadius: 10,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          backgroundColor: primary,
          selectedItemColor: textWhiteColor,
          unselectedItemColor: textGreyColor,
          selectedLabelStyle: bodySmall.copyWith(fontWeight: FontWeight.w600),
          unselectedLabelStyle: bodySmall,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Ana Sayfa',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.category_rounded),
              label: 'Kategoriler',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomePage() {
    return Padding(
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
                    style: headingMedium.copyWith(color: primary),
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  'Hoş Geldin Selin',
                  style: headingMedium.copyWith(color: textWhiteColor),
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
