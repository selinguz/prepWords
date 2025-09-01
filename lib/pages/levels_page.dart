import 'package:flutter/material.dart';
import 'package:prep_words/components/custom_appbar.dart';
import 'package:prep_words/consts.dart';
import 'package:prep_words/pages/words_page.dart';
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

  /// 🔹 Level’e göre global unit başlangıcı
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
