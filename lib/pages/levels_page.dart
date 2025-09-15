// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:prep_words/components/custom_appbar.dart';
import 'package:prep_words/consts.dart';
import 'package:prep_words/models/word.dart';
import 'package:prep_words/pages/exercise_page.dart';
import 'package:prep_words/pages/words_page.dart';
import 'package:prep_words/provider/word_status_provider.dart';
import 'package:prep_words/services/firebase_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum LevelItemType { unit, practice }

class LevelItem {
  final LevelItemType type;
  final int? unitNumber; // Unit numarası veya practice numarası
  LevelItem({required this.type, this.unitNumber});
}

class LevelsPage extends StatefulWidget {
  final int level;
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
  final FirebaseService _firebaseService = FirebaseService();
  List<bool> unlockedUnits = [];
  List<LevelItem> levelItems = [];

  @override
  void initState() {
    super.initState();
    _loadUnlockedUnits();
    _buildLevelItems();
  }

  void _buildLevelItems() {
    levelItems.clear();
    int totalUnits = widget.unitCount;
    int practiceOffset;

    switch (widget.level) {
      case 1: // Beginner
        practiceOffset = 1;
        break;
      case 2: // Intermediate
        practiceOffset = 4;
        break;
      case 3: // Advanced
        practiceOffset = 15;
        break;
      default:
        practiceOffset = 1;
    }

    int practiceCounter = 0;

    for (int i = 0; i < totalUnits; i++) {
      int globalUnit = widget.startUnit + i;
      levelItems
          .add(LevelItem(type: LevelItemType.unit, unitNumber: globalUnit));

      // Her 2 unit’ten sonra practice ekle
      if ((i + 1) % 2 == 0) {
        practiceCounter++;
        levelItems.add(LevelItem(
            type: LevelItemType.practice,
            unitNumber: practiceOffset + practiceCounter - 1));
      }
    }
  }

  Future<void> _loadUnlockedUnits() async {
    final prefs = await SharedPreferences.getInstance();
    unlockedUnits = List.generate(widget.unitCount, (index) {
      int globalUnit = widget.startUnit + index;
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

  Future<int> _getKnownWordsCount(int unit) async {
    final prefs = await SharedPreferences.getInstance();
    List<WordModel> words = await _firebaseService.fetchWordsByUnit(unit);

    int count = 0;
    for (var word in words) {
      final status = prefs.getString("word_status_${word.englishWord}") ?? "";
      if (status == WordStatus.known.toString()) count++;
    }
    return count;
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
          title: Text(word.englishWord, style: bodyMedium), trailing: icon);
    }).toList();

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Text('Unit $globalUnit Words', style: headingMedium),
              SizedBox(height: 16),
              Expanded(child: ListView(children: wordWidgets)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUnitCard(int globalUnit, bool isUnlocked, int index) {
    return Consumer<WordStatusProvider>(
      builder: (context, provider, child) {
        int knownCount = provider.knownWordsCount[globalUnit] ?? 0;

        return InkWell(
          onTap: isUnlocked
              ? () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WordsPage(
                        unit: globalUnit,
                        onComplete: () {
                          provider.loadKnownWords(
                              globalUnit); // geri dönünce güncelle
                          _unlockNextUnit(index);
                        },
                      ),
                    ),
                  );
                }
              : null,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isUnlocked ? primary : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(isUnlocked ? Icons.check : Icons.lock,
                            color: textWhiteColor),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Unit $globalUnit',
                            style: headingMedium.copyWith(
                              color: isUnlocked
                                  ? textGreyColor.withAlpha(179)
                                  : textGreyColor.withAlpha(100),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '20 Words / $knownCount Known',
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
                        if (isUnlocked)
                          GestureDetector(
                            onTap: () => _showUnitPreview(globalUnit),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: adjsFront.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.visibility,
                                  color: textWhiteColor, size: 20),
                            ),
                          ),
                        SizedBox(width: 8),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isUnlocked ? primary : Colors.grey,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.arrow_forward_ios,
                              color: textWhiteColor, size: 18),
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
    );
  }

  Widget _buildPracticeCard(int practiceNumber, int index) {
    return FutureBuilder<bool>(
      future: _areUnitsEnoughForPractice(practiceNumber),
      builder: (context, snapshot) {
        bool bothUnitsUnlocked = snapshot.data ?? false;

        return InkWell(
          onTap: bothUnitsUnlocked
              ? () async {
                  List<WordModel> words = [];
                  int startUnitIndex = (practiceNumber - 1) * 2;
                  for (int i = 0; i < 2; i++) {
                    int globalUnit = widget.startUnit + startUnitIndex + i;
                    words.addAll(
                        await _firebaseService.fetchWordsByUnit(globalUnit));
                  }
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PracticeExercisePage(
                        allWords: words,
                        practiceNumber: practiceNumber,
                      ),
                    ),
                  );
                }
              : null,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Card(
              color: bothUnitsUnlocked
                  ? Colors.blueGrey.shade50
                  : Colors.grey.shade300,
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Container(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        bothUnitsUnlocked ? Icons.school : Icons.lock,
                        color:
                            bothUnitsUnlocked ? Colors.blueAccent : Colors.grey,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Practice $practiceNumber',
                        style: headingMedium.copyWith(
                          color: bothUnitsUnlocked
                              ? Colors.blueAccent
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool> _areUnitsEnoughForPractice(int practiceNumber) async {
    int startUnitIndex = (practiceNumber - 1) * 2;
    if (unlockedUnits.length <= startUnitIndex + 1) return false;

    int count1 = await _getKnownWordsCount(widget.startUnit + startUnitIndex);
    int count2 =
        await _getKnownWordsCount(widget.startUnit + startUnitIndex + 1);

    return count1 >= 18 && count2 >= 18;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.levelName,
        onBackPressed: () => Navigator.pushReplacementNamed(context, '/home'),
      ),
      backgroundColor: backgrnd,
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 18.0),
        itemCount: levelItems.length,
        itemBuilder: (context, index) {
          final item = levelItems[index];
          if (item.type == LevelItemType.unit) {
            int globalUnit = item.unitNumber!;
            bool isUnlocked = unlockedUnits.isNotEmpty
                ? unlockedUnits[globalUnit - widget.startUnit]
                : (globalUnit == 1);
            return _buildUnitCard(globalUnit, isUnlocked, index);
          } else {
            int practiceNumber = item.unitNumber!;
            return _buildPracticeCard(practiceNumber, index);
          }
        },
      ),
    );
  }
}
