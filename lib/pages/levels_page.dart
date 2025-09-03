import 'package:flutter/material.dart';
import 'package:prep_words/components/custom_appbar.dart';
import 'package:prep_words/consts.dart';
import 'package:prep_words/models/word.dart';
import 'package:prep_words/pages/words_page.dart';
import 'package:prep_words/services/firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LevelsPage extends StatefulWidget {
  final int level; // 1: Başlangıç, 2: Orta, 3: İleri
  final String levelName;
  final int unitCount;

  const LevelsPage({
    super.key,
    required this.level,
    required this.levelName,
    required this.unitCount,
  });

  int get startUnit {
    switch (level) {
      case 1:
        return 1;
      case 2:
        return 7;
      case 3:
        return 29;
      default:
        return 1;
    }
  }

  @override
  State<LevelsPage> createState() => _LevelsPageState();
}

class _LevelsPageState extends State<LevelsPage> {
  late List<bool> unlockedUnits;
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _loadUnlockedUnits();
  }

  Future<void> _loadUnlockedUnits() async {
    final prefs = await SharedPreferences.getInstance();
    unlockedUnits = List.generate(widget.unitCount, (index) {
      int globalUnit = widget.startUnit + index;
      // İlk global unit her zaman açık
      if (globalUnit == 1) return true;
      return prefs.getBool('unit_${globalUnit}_unlocked') ?? false;
    });
    setState(() {});
  }

  Future<void> _unlockNextUnit(int currentIndex) async {
    final prefs = await SharedPreferences.getInstance();
    int nextIndex = currentIndex + 1;
    if (nextIndex < widget.unitCount) {
      int globalNextUnit = widget.startUnit + nextIndex;
      unlockedUnits[nextIndex] = true;
      await prefs.setBool('unit_${globalNextUnit}_unlocked', true);
      setState(() {});
    }
  }

  void _showUnitPreview(int globalUnit) async {
    final prefs = await SharedPreferences.getInstance();
    List<WordModel> words = await _firebaseService.fetchWordsByUnit(globalUnit);

    List<Widget> wordWidgets = words.map((word) {
      String status =
          prefs.getString("word_status_${word.englishWord}") ?? "unknown";

      Icon icon;
      switch (status) {
        case "WordStatus.known":
          icon = Icon(Icons.check, color: Colors.green);
          break;
        case "WordStatus.unknown":
          icon = Icon(Icons.close, color: Colors.red);
          break;
        case "WordStatus.unsure":
          icon = Icon(Icons.remove, color: Colors.amber);
          break;
        default:
          icon = Icon(Icons.help_outline, color: Colors.grey);
      }

      return ListTile(
        title: Text(word.englishWord, style: bodyMedium),
        trailing: icon,
      );
    }).toList();

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Unit $globalUnit Words',
                style: headingMedium,
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: wordWidgets,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.levelName,
        onBackPressed: () {
          Navigator.pushReplacementNamed(context, '/home');
        },
      ),
      backgroundColor: backgrnd,
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 18.0),
        itemCount: widget.unitCount,
        itemBuilder: (context, index) {
          int globalUnit = widget.startUnit + index;
          bool isUnlocked =
              unlockedUnits.isNotEmpty ? unlockedUnits[index] : (index == 0);

          return InkWell(
            onTap: isUnlocked
                ? () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WordsPage(
                          unit: globalUnit,
                        ),
                      ),
                    );
                    // Ünite tamamlandıysa bir sonraki ünitenin kilidini aç
                    await _unlockNextUnit(index);
                  }
                : null,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Sol taraftaki daire
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isUnlocked ? primary : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            isUnlocked ? Icons.check : Icons.lock,
                            color: textWhiteColor,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ünite $globalUnit',
                              style: headingMedium.copyWith(
                                color: isUnlocked
                                    ? textGreyColor.withAlpha(179)
                                    : textGreyColor.withAlpha(100),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '20 Kelime',
                              style: bodySmall.copyWith(
                                color: isUnlocked
                                    ? textGreyColor.withAlpha(135)
                                    : textGreyColor.withAlpha(80),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          // 🔹 Yeni önizleme ikonu
                          if (isUnlocked)
                            GestureDetector(
                              onTap: () {
                                _showUnitPreview(globalUnit);
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: adjsFront.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.visibility,
                                  color: textWhiteColor,
                                  size: 20,
                                ),
                              ),
                            ),

                          SizedBox(width: 8),
                          // Ok ikonu (eski)
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isUnlocked ? primary : Colors.grey,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios,
                              color: textWhiteColor,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
