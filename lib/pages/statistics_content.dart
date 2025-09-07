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

  final Map<String, int> totalWordsByType = {
    'adjectives': 194,
    'adverbs': 126,
    'nouns': 384,
    'verbs': 256,
  };

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();

    // 🔹 SharedPreferences'tan tüm kelime durumlarını tek seferde oku
    final Map<String, String> statusMap = {};
    for (var key in prefs.getKeys()) {
      if (key.startsWith('word_status_')) {
        statusMap[key.replaceFirst('word_status_', '')] =
            prefs.getString(key) ?? '';
      }
    }

    // 🔹 Firebase çağrılarını paralel çalıştır
    List<Future<List<WordModel>>> futures = [];
    for (int i = 1; i <= 48; i++) {
      futures.add(firebaseService.fetchWordsByUnit(i));
    }
    final results = await Future.wait(futures);
    final List<WordModel> allWords = results.expand((x) => x).toList();

    // 🔹 WordModel'leri Map olarak tut, hızlı lookup için
    final Map<String, WordModel> wordMap = {
      for (var w in allWords) w.englishWord: w
    };

    // Sayaçlar
    int known = 0;
    int unknown = 0;
    int unsure = 0;
    int unmarked = 0;

    int adj = 0;
    int adv = 0;
    int noun = 0;
    int verb = 0;

    // 🔹 Durumları hızlıca işle
    statusMap.forEach((word, statusStr) {
      final wordModel = wordMap[word];

      if (statusStr == WordStatus.known.toString()) {
        known++;
        final type = wordModel?.wordType.toLowerCase().trim() ?? '';
        if (type.startsWith('adjective'))
          adj++;
        else if (type.startsWith('adverb'))
          adv++;
        else if (type.startsWith('noun'))
          noun++;
        else if (type.startsWith('verb')) verb++;
      } else if (statusStr == WordStatus.unknown.toString()) {
        unknown++;
      } else if (statusStr == WordStatus.unsure.toString()) {
        unsure++;
      }
    });

    // 🔹 Toplam kelime sayısı
    int totalWords = 960;
    unmarked = totalWords - (known + unsure + unknown);

    // 🔹 Gün sayısı ve günlük ortalama
    final user = FirebaseAuth.instance.currentUser;
    final creationTime = user?.metadata.creationTime ?? DateTime.now();
    final now = DateTime.now();
    totalDays = now.difference(creationTime).inDays + 1;

    dailyAverage = known / totalDays;

    // 🔹 State güncelle
    setState(() {
      wordStats = {
        'known': known,
        'unknown': unknown,
        'unsure': unsure,
        'unmarked': unmarked,
      };
      adjectives = adj;
      adverbs = adv;
      nouns = noun;
      verbs = verb;

      isLoading = false;
    });

    debugPrint(
        "Word types: adj=$adjectives, adv=$adverbs, noun=$nouns, verb=$verbs");
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

  Widget _buildTypeStatCard(
      String title, int learnedCount, int totalCount, Color color) {
    double percentage = totalCount > 0 ? (learnedCount / totalCount) * 100 : 0;
    String percentageText = '${percentage.toStringAsFixed(0)}%';

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
      child: Column(
        children: [
          Text(
            title,
            style: headingSmall.copyWith(
                color: color, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🔹 Circle avatar yüzde için
              CircleAvatar(
                backgroundColor: color,
                radius: 24, // daire boyutu
                child: Text(
                  percentageText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 🔹 Başlık + Değerler
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$learnedCount / $totalCount',
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ],
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
    return Scaffold(
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

            const SizedBox(height: 20),

            // 2. Kelime Türleri
            Text("Words I Know (By Type)", style: headingMedium),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisSpacing: 1.5,
              mainAxisSpacing: 1.5,
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.4,
              children: [
                _buildTypeStatCard("Adjectives", adjectives, 194, adjsFront),
                _buildTypeStatCard("Adverbs", adverbs, 126, advsFront),
                _buildTypeStatCard("Nouns", nouns, 384, nounsFront),
                _buildTypeStatCard("Verbs", verbs, 256, verbsFront),
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
    );
  }
}
