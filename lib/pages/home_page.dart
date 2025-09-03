import 'package:flutter/material.dart';
import 'package:prep_words/consts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prep_words/data/level_data.dart';
import 'package:prep_words/pages/levels_page.dart';
import 'package:prep_words/pages/categories_content.dart';
import 'package:prep_words/pages/profile_content.dart';
import 'package:prep_words/pages/statistics_content.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prep_words/models/word.dart'; // WordStatus için

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String _userName = '';
  int _knownWords = 0;
  final int _totalWords = 960;

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();

    int count = 0;
    for (var key in prefs.getKeys()) {
      if (key.startsWith("word_status_")) {
        final status = prefs.getString(key);
        if (status == WordStatus.known.toString()) {
          count++;
        }
      }
    }

    setState(() {
      _knownWords = count;
    });
  }

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      user.reload().then((_) {
        setState(() {
          _userName = user.displayName ?? 'User';
        });
      });
    }

    _loadProgress();
  }

  // 🔹 ProfileContent’den çağırılacak callback
  void _updateUserName(String newName) {
    setState(() {
      _userName = newName;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 🔹 Progress yüzdesi
    final double levelProgress = _knownWords / _totalWords;

    // 🔹 Level hesaplama: her 20 kelime 1 level
    final int userLevel = (_knownWords / 20).ceil().clamp(1, 48);

    // 🔹 Level name ve motto
    final levelName = LevelData.getLevelName(userLevel);
    final motto = LevelData.getLevelMotto(userLevel);

    return Scaffold(
      backgroundColor: backgrnd,
      body: _buildBody(
        levelProgress,
        userLevel,
        levelName,
        motto,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              primary,
              secondaryOrange.withValues(alpha: 0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: BottomNavigationBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          selectedItemColor: textWhiteColor,
          unselectedItemColor: textGreyColor,
          selectedLabelStyle: bodySmall.copyWith(fontWeight: FontWeight.w600),
          unselectedLabelStyle: bodySmall,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.category_rounded),
              label: 'Categories',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.stacked_bar_chart),
              label: 'Statistics',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
      double levelProgress, int userLevel, String levelName, String motto) {
    if (_selectedIndex == 0) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              // ------------------ Profil Kartı ------------------
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primary, secondaryOrange.withValues(alpha: 0.6)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: textWhiteColor,
                          child: Text(
                            _userName.isNotEmpty
                                ? _userName[0].toUpperCase()
                                : 'U',
                            style: headingMedium.copyWith(color: primary),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _userName,
                                style: headingMedium.copyWith(
                                    color: textWhiteColor),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                levelName,
                                style:
                                    bodyMedium.copyWith(color: textWhiteColor),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: textWhiteColor.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 20),
                              SizedBox(width: 6),
                              Text(
                                'Level $userLevel',
                                style: TextStyle(
                                  color: warnOrange,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      motto,
                      style: bodyMedium.copyWith(color: textWhiteColor),
                      softWrap: true,
                    ),
                    SizedBox(height: 16),
                    Text('Progress',
                        style: bodySmall.copyWith(color: textWhiteColor)),
                    SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: levelProgress,
                      backgroundColor: Colors.white24,
                      color: Colors.orangeAccent,
                      minHeight: 10,
                    ),
                    SizedBox(height: 4),
                    Text('${(levelProgress * 100).round()}% Complete',
                        style: bodySmall.copyWith(color: textWhiteColor)),
                  ],
                ),
              ),

              /* Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: textWhiteColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.1),
                              blurRadius: 5,
                              offset: Offset(0, 3))
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Icon(Icons.local_fire_department,
                              color: secondaryOrange),
                          SizedBox(height: 8),
                          Text('Current Streak', style: bodySmall),
                          Text('1', style: headingMedium),
                          Text('Keep it up! 👍',
                              style: bodySmall.copyWith(color: secondaryBlue)) 
                        ],
                      ),
                    ),
                  ),
                ],
              ),
 */

              // ------------------ Quick Actions ------------------
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text('Quick Actions', style: headingMedium),
              ),
              SizedBox(height: 12),

// Kartları sarmalayan Wrap
              Wrap(
                spacing: 22,
                runSpacing: 12,
                alignment: WrapAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: _levelCard(
                        'Beginner', '6 Units', Icons.star, Colors.green, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LevelsPage(
                              level: 1, levelName: 'Beginner', unitCount: 6),
                        ),
                      );
                    }),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: _levelCard(
                        'Intermediate', '22 Units', Icons.star, Colors.orange,
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LevelsPage(
                              level: 2,
                              levelName: 'Intermediate',
                              unitCount: 22),
                        ),
                      );
                    }),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: _levelCard(
                        'Advanced', '20 Units', Icons.star, Colors.red, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LevelsPage(
                              level: 3, levelName: 'Advanced', unitCount: 20),
                        ),
                      );
                    }),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      );
    } else if (_selectedIndex == 1) {
      return CategoriesContent();
    } else if (_selectedIndex == 2) {
      return StatisticsContent();
    } else {
      return ProfileContent(
        onNameUpdated: (newName) {
          _updateUserName(newName);
        },
      );
    }
  }

  Widget _levelCard(String title, String subtitle, IconData icon, Color color,
      VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.sizeOf(context)
            .width, // sabit genişlik, ekran dışına taşmasın
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.2), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(
                title == 'Beginner'
                    ? 1
                    : title == 'Intermediate'
                        ? 2
                        : 3, 
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Icon(
                    icon,
                    color: color,
                    size: 30,
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),
            Text(title, style: headingMedium.copyWith(fontSize: 18)),
            SizedBox(height: 4),
            Text(subtitle, style: bodySmall),
          ],
        ),
      ),
    );
  }
}
