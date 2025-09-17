// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:prep_words/components/custom_appbar.dart';
import 'package:prep_words/consts.dart';
import 'package:prep_words/data/practice_stats.dart';
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

  Map<int, List<int>> practiceStats = {};

  @override
  void initState() {
    super.initState();
    _loadStatistics();
    _loadPracticeStats();
  }

  Future<void> _loadPracticeStats() async {
    final stats = await PracticeStats.getAllSuccessRates(24);

    setState(() {
      // sadece deneme yapılmış (liste boş olmayan) practicle’lar kalsın
      practiceStats = stats
          .map((k, v) => MapEntry(k, v.map((d) => d.toInt()).toList()))
        ..removeWhere((key, value) => value.isEmpty);
    });
  }

  Future<void> _loadStatistics() async {
    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();

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
        if (type.startsWith('adjective')) {
          adj++;
        } else if (type.startsWith('adverb'))
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
  }

  Widget _buildPracticeStatCard(int practiceId, List<int> successList) {
    final attemptCount = successList.length;

    // Kümülatif başarı = ortalama
    final avgSuccessRate = successList.isNotEmpty
        ? successList.reduce((a, b) => a + b) / successList.length
        : 0.0;

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (_) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Practice $practiceId Details', style: headingLarge),
                  const SizedBox(height: 12),
                  Text("Average Success: ${avgSuccessRate.toStringAsFixed(1)}%",
                      style: bodyMedium),
                  const SizedBox(height: 12),
                  ...successList.asMap().entries.map((e) {
                    return Text(
                      'Attempt ${e.key + 1}: ${e.value}%',
                      style: bodyMedium,
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.indigo.shade100, width: 1),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.indigo,
              child: Text(
                "$practiceId",
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Practice $practiceId",
                      style: bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text("$attemptCount attempts",
                      style: bodyMedium.copyWith(
                          color: Colors.grey[600], fontSize: 13)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("${avgSuccessRate.toStringAsFixed(1)}% success",
                    style: bodyMedium.copyWith(
                        color: avgSuccessRate >= 50
                            ? Colors.green[700]
                            : Colors.red[700],
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, color: Colors.indigo),
          ],
        ),
      ),
    );
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
                    style: headingMedium.copyWith(fontWeight: FontWeight.bold),
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
                  style: bodyMedium,
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
                      style: bodySmall,
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

  Widget _buildAppUsageCard(IconData icon, String? text, Color color,
      {Widget? richText}) {
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
            child: richText ??
                Text(
                  text ?? "",
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
      appBar: CustomAppBar(
        title: "Statistics",
        onBackPressed: () => Navigator.pushReplacementNamed(context, '/home'),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildAppUsageCard(
                  Icons.calendar_today,
                  null,
                  Colors.teal,
                  richText: Text.rich(
                    TextSpan(
                      style: bodyMedium,
                      children: [
                        const TextSpan(text: "You have been working for "),
                        TextSpan(
                          text: "$totalDays",
                          style: bodyLarge.copyWith(
                              fontWeight: FontWeight.bold, color: Colors.teal),
                        ),
                        const TextSpan(text: " Days"),
                      ],
                    ),
                  ),
                ),
                _buildAppUsageCard(
                  Icons.bar_chart,
                  null,
                  Colors.indigo,
                  richText: Text.rich(
                    TextSpan(
                      style: bodyMedium,
                      children: [
                        const TextSpan(text: "You've learned an average of "),
                        TextSpan(
                          text: dailyAverage.toStringAsFixed(1),
                          style: bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo),
                        ),
                        const TextSpan(text: " words every day, that's great!"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text("Practice Stats", style: headingMedium),
            const SizedBox(height: 12),
            ...practiceStats.entries.map(
              (e) => _buildPracticeStatCard(e.key, e.value),
            ),
          ],
        ),
      ),
    );
  }
}
