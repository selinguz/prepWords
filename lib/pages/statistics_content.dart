import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prep_words/consts.dart';
import 'package:prep_words/models/word.dart';
import 'package:prep_words/services/firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StatisticsContent extends StatefulWidget {
  const StatisticsContent({
    super.key,
  });

  @override
  State<StatisticsContent> createState() => _StatisticsContentState();
}

class _StatisticsContentState extends State<StatisticsContent> {
  final FirebaseService firebaseService = FirebaseService();
  bool isLoading = true;
  Map<String, int> wordStats = {};
  int totalDays = 1;
  double dailyAverage = 0.0;

  // Kelime türleri
  int adjectives = 0;
  int adverbs = 0;
  int nouns = 0;
  int verbs = 0;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    int known = 0;
    int unknown = 0;
    int unsure = 0;
    int unmarked = 0;

    List<WordModel> allWords = [];

    // Tüm üniteleri alıp WordModel listesini oluştur
    // Burada FirebaseService.fetchWordsByUnit kullanılabilir
    // Örnek: toplam 48 ünite
    for (int i = 1; i <= 48; i++) {
      final words = await firebaseService.fetchWordsByUnit(i);
      allWords.addAll(words);
    }

    for (var key in prefs.getKeys()) {
      if (key.startsWith('word_status_')) {
        final statusStr = prefs.getString(key);
        if (statusStr == WordStatus.known.toString()) {
          known++;
        } else if (statusStr == WordStatus.unsure.toString()) {
          unsure++;
        } else if (statusStr == WordStatus.unknown.toString()) {
          unknown++;
        }
      }
    }
    int totalWords = 960;

    unmarked = totalWords - (known + unsure + unknown);
    final user = FirebaseAuth.instance.currentUser;
    final creationTime = user?.metadata.creationTime ?? DateTime.now();
    final now = DateTime.now();
    totalDays = now.difference(creationTime).inDays + 1;

    dailyAverage = known / totalDays;

    setState(() {
      wordStats = {
        'known': known,
        'unknown': unknown,
        'unsure': unsure,
        'unmarked': unmarked,
      };
      isLoading = false;
      adjectives = adjectives;
      adverbs = adverbs;
      nouns = nouns;
      verbs = verbs;
    });
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Align(
        alignment: Alignment.center,
        child: Row(
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    textAlign: TextAlign.center,
                    title,
                    style: headingSmall.copyWith(
                        color: color, fontWeight: FontWeight.bold),
                    maxLines: 3,
                    //overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeStatCard(String title, int value, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 🔹 Sol renk şeridi
          Container(
            width: 8,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 12),

          // 🔹 Başlık + Değer (responsive)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: headingSmall.copyWith(
                        color: color, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    softWrap: false,
                  ),
                ),
                const SizedBox(height: 6),
                Flexible(
                  child: Text(
                    '$value',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    softWrap: false,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppUsageCard(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(12),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              text,
              style: bodyMedium,
              maxLines: 4,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: kToolbarHeight * 1.2,
          backgroundColor: primary,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: textGreyColor),
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          title: Text(
            'Statistics',
            style: headingLarge.copyWith(fontSize: 30),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Total Words Statistics", style: headingMedium),
              const SizedBox(height: 12),
              // 1. Genel Bilgiler
              GridView.count(
                mainAxisSpacing: 2.0,
                crossAxisSpacing: 18.0,
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.0,
                children: [
                  _buildStatCard("I know", '${wordStats['known']}',
                      Icons.check_circle, Colors.green),
                  _buildStatCard("I don't know", '${wordStats['unknown']}',
                      Icons.cancel_rounded, Colors.red),
                  _buildStatCard("I am not sure", '${wordStats['unsure']}',
                      Icons.remove_circle_rounded, Colors.orange),
                  _buildStatCard("Not studied", '${wordStats['unmarked']}',
                      Icons.help_outline_rounded, Colors.grey),
                ],
              ),

              const SizedBox(height: 24),

              // 2. Kelime Türleri
              Text("Words I Know (By Type)", style: headingMedium),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.4,
                children: [
                  _buildTypeStatCard("Adjectives", adjectives, adjsFront),
                  _buildTypeStatCard("Adverbs", adverbs, advsFront),
                  _buildTypeStatCard("Nouns", nouns, nounsFront),
                  _buildTypeStatCard("Verbs", verbs, verbsFront),
                ],
              ),

              const SizedBox(height: 24),

              // 3. Kullanım Bilgileri
              Text("App Usage Info", style: headingMedium),
              const SizedBox(height: 12),
              GridView.count(
                mainAxisSpacing: 2.0,
                crossAxisSpacing: 22.0,
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.0,
                children: [
                  _buildAppUsageCard(Icons.calendar_today,
                      "You have been working for $totalDays Days", Colors.teal),
                  _buildAppUsageCard(
                      Icons.bar_chart,
                      "You've learned an average of ${dailyAverage.toStringAsFixed(1)} words every day, that's great!",
                      Colors.indigo),
                  //_buildStatCard("Time Spent", totalTimeSpent,
                  //  Icons.access_time, Colors.brown),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
