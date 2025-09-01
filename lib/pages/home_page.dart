import 'package:flutter/material.dart';
import 'package:prep_words/consts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prep_words/data/level_data.dart';
import 'package:prep_words/pages/levels_page.dart';
import 'package:prep_words/pages/categories_content.dart';
import 'package:prep_words/pages/profile_content.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String _userName = '';
  //final int _userLevel = 0; // Başlangıçta 0
  //final double _levelProgress = 0; // Başlangıçta %0

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      user.reload().then((_) {
        // güncel bilgiyi al
        setState(() {
          _userName = user.displayName ?? 'Kullanıcı';
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgrnd,
      // 🔽 body artık aktif sekmeye göre değişiyor
      body: _buildBody(),
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

  Widget _buildBody() {
    // 🔹 Toplam kelime sayısı
    final int totalWords = 960;

    // 🔹 Kullanıcının işaretlediği bilinen kelime sayısı
    // Burayı veri tabanından veya state'ten alman gerekiyor
    int knownWords = 0; // Örnek değer, dinamik olarak değiştirilecek

    // 🔹 Progress yüzdesi
    final double levelProgress = knownWords / totalWords;

    // 🔹 Level hesaplama: her 20 kelime bir level artıyor
    final int userLevel = (knownWords / 20).ceil().clamp(1, 48);

    // 🔹 Level name ve motto
    final levelName = LevelData.getLevelName(userLevel);
    final motto = LevelData.getLevelMotto(userLevel);

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
                        // 🔹 Kullanıcı avatarı
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

                        // 🔹 Kullanıcı adı ve level bilgisi
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
                                "Level: $levelName",
                                style:
                                    bodyMedium.copyWith(color: textWhiteColor),
                              ),
                            ],
                          ),
                        ),

                        // 🔹 Yıldızlı level container
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

                    // 🔹 Motto: tüm satır gösterilsin, level name ile aynı hizada başlasın
                    Text(
                      motto,
                      style: bodyMedium.copyWith(color: textWhiteColor),
                      softWrap: true,
                    ),

                    SizedBox(height: 16),

                    // 🔹 Progress bar
                    Text('Progress',
                        style: bodySmall.copyWith(color: textWhiteColor)),
                    SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: levelProgress, // 0.0 - 1.0
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

              SizedBox(height: 20),

              // ------------------ İstatistik Kartları ------------------
              Row(
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

              SizedBox(height: 20),

              // ------------------ Quick Actions ------------------
              Text('Quick Actions', style: headingMedium),
              SizedBox(height: 8),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _levelCard('Başlangıç', '6 Ünite', Icons.school, Colors.green,
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LevelsPage(
                            level: 1, levelName: 'Başlangıç', unitCount: 6),
                      ),
                    );
                  }),
                  _levelCard('Orta', '22 Ünite', Icons.school, Colors.orange,
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LevelsPage(
                            level: 2, levelName: 'Orta', unitCount: 22),
                      ),
                    );
                  }),
                  _levelCard('İleri', '20 Ünite', Icons.school, Colors.red, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LevelsPage(
                            level: 3, levelName: 'İleri', unitCount: 20),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      );
    } else if (_selectedIndex == 1) {
      return CategoriesContent();
    } else {
      return ProfileContent();
    }
  }

  Widget _levelCard(String title, String subtitle, IconData icon, Color color,
      VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 30),
            SizedBox(height: 12),
            Text(title, style: headingMedium),
            SizedBox(height: 4),
            Text(subtitle, style: bodySmall),
          ],
        ),
      ),
    );
  }
}
