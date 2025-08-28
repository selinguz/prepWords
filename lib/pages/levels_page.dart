import 'package:flutter/material.dart';
import 'package:prep_words/components/custom_appbar.dart';
import 'package:prep_words/components/custom_card.dart';
import 'package:prep_words/consts.dart';
import 'package:prep_words/pages/words_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  State<LevelsPage> createState() => _LevelsPageState();
}

class _LevelsPageState extends State<LevelsPage> {
  late List<bool> unlockedUnits;

  @override
  void initState() {
    super.initState();
    _loadUnlockedUnits();
  }

  Future<void> _loadUnlockedUnits() async {
    final prefs = await SharedPreferences.getInstance();
    unlockedUnits = List.generate(widget.unitCount, (index) {
      // İlk ünite her zaman açık, diğerlerini cihaz hafızasından oku
      if (index == 0) return true;
      return prefs.getBool('unit_${index + 1}_unlocked') ?? false;
    });
    setState(() {});
  }

  Future<void> _unlockNextUnit(int currentUnit) async {
    final prefs = await SharedPreferences.getInstance();
    int nextUnitIndex = currentUnit;
    if (nextUnitIndex < widget.unitCount) {
      unlockedUnits[nextUnitIndex] = true;
      await prefs.setBool('unit_${nextUnitIndex + 1}_unlocked', true);
      setState(() {});
    }
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
          bool isUnlocked =
              unlockedUnits.isNotEmpty ? unlockedUnits[index] : (index == 0);

          return InkWell(
            onTap: isUnlocked
                ? () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WordsPage(
                          unit: index + 1,
                        ),
                      ),
                    );
                    // Ünite tamamlandıysa bir sonraki ünitenin kilidini aç
                    await _unlockNextUnit(index + 1);
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
                              'Ünite ${index + 1}',
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
                      // Sağ taraftaki ok ikonu
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
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
