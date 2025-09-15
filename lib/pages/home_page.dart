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

  int beginnerUnlocked = 0;
  int intermediateUnlocked = 0;
  int advancedUnlocked = 0;

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

    int beginner = 0;
    int intermediate = 0;
    int advanced = 0;

    // Beginner → 1–6
    for (int i = 1; i <= 6; i++) {
      if (i == 1 || prefs.getBool('unit_${i}_unlocked') == true) {
        beginner++;
      }
    }

    // Intermediate → 7–28 (22 unit)
    for (int i = 7; i <= 28; i++) {
      if (prefs.getBool('unit_${i}_unlocked') == true) {
        intermediate++;
      }
    }

    // Advanced → 29–48 (20 unit)
    for (int i = 29; i <= 48; i++) {
      if (prefs.getBool('unit_${i}_unlocked') == true) {
        advanced++;
      }
    }

    setState(() {
      _knownWords = count;
      beginnerUnlocked = beginner;
      intermediateUnlocked = intermediate;
      advancedUnlocked = advanced;
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
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        backgroundColor: yellowGreen, // 🔹 gradient yerine tek renk
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
                  color: yellowGreen, // 🔹 gradient yerine tek renk
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
                                    color: textGreyColor),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                levelName,
                                style:
                                    bodyMedium.copyWith(color: textGreyColor),
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
                      style: bodyMedium.copyWith(
                          color: textGreyColor.withValues(alpha: 0.7)),
                      softWrap: true,
                    ),
                    SizedBox(height: 16),
                    Text('Progress',
                        style: bodySmall.copyWith(color: textGreyColor)),
                    SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: levelProgress,
                      backgroundColor: Colors.white24,
                      color: primary,
                      minHeight: 10,
                    ),
                    SizedBox(height: 4),
                    Text('${(levelProgress * 100).round()}% Complete',
                        style: bodySmall.copyWith(
                            color: textGreyColor.withValues(alpha: 0.6))),
                  ],
                ),
              ),

              // ------------------ Quick Actions ------------------
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text('Quick Actions', style: headingMedium),
              ),
              SizedBox(height: 12),

              Wrap(
                spacing: 22,
                runSpacing: 12,
                alignment: WrapAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: _levelCard(
                      'Beginner',
                      6,
                      beginnerUnlocked,
                      Icons.star,
                      Color(0xFF0A7029), // Icon rengi (koyu yeşil)
                      Color(0xFFD8F0D8), // Kart arka planı (hafif yeşil)
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LevelsPage(
                              level: 1,
                              levelName: 'Beginner',
                              unitCount: 6,
                            ),
                          ),
                        ).then((_) => _loadProgress());
                      },
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: _levelCard(
                      'Intermediate',
                      22,
                      intermediateUnlocked,
                      Icons.star,
                      Color(0xFFFFA500), // Icon rengi (koyu turuncu)
                      Color(0xFFFFE5CC), // Kart arka planı (hafif turuncu)
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LevelsPage(
                              level: 2,
                              levelName: 'Intermediate',
                              unitCount: 22,
                            ),
                          ),
                        ).then((_) => _loadProgress());
                      },
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: _levelCard(
                      'Advanced',
                      20,
                      advancedUnlocked,
                      Icons.star,
                      Color(0xFFFF0000), // Icon rengi (koyu kırmızı)
                      Color(0xFFFFD6D6), // Kart arka planı (hafif kırmızı)
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LevelsPage(
                              level: 3,
                              levelName: 'Advanced',
                              unitCount: 20,
                            ),
                          ),
                        ).then((_) => _loadProgress());
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/examCalendar'),
                child: Card(
                  color: Colors.green[50],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("📅 Upcoming Exams",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        Icon(Icons.arrow_forward_ios,
                            size: 16, color: Colors.grey[600]),
                      ],
                    ),
                  ),
                ),
              )
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

  Widget _levelCard(
    String title,
    int totalUnits,
    int unlockedUnits,
    IconData icon,
    Color iconColor, // 🔹 ikon ve progress rengi
    Color backgroundColor, // 🔹 kart arka planı
    VoidCallback onTap,
  ) {
    final double progress = totalUnits > 0 ? unlockedUnits / totalUnits : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.sizeOf(context).width,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor, // 🔹 arka plan rengi
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
                  child:
                      Icon(icon, color: iconColor, size: 28), // 🔹 ikon rengi
                ),
              ),
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: headingMedium.copyWith(
                  fontSize: 18, color: iconColor), // 🔹 başlık rengi
            ),
            SizedBox(height: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.grey.withValues(alpha: 0.2),
                  color: iconColor, // 🔹 progress rengi
                ),
                SizedBox(height: 6),
                Text(
                  "$unlockedUnits / $totalUnits Units Unlocked",
                  style: bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: textGreyColor,
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
