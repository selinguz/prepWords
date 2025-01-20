import 'package:flutter/material.dart';
import 'package:prep_words/components/custom_appbar.dart';
import 'package:prep_words/consts.dart';
import 'package:prep_words/pages/words_page.dart';

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
  late List<String> unitNames;

  @override
  void initState() {
    super.initState();
    unitNames = List.generate(widget.unitCount, (index) {
      if (widget.levelName == 'Başlangıç Seviyesi') {
        return 'Ünite ${index + 1}';
      } else if (widget.levelName == 'Orta Seviye') {
        return 'Ünite ${index + 7}';
      } else if (widget.levelName == 'İleri Seviye') {
        return 'Ünite ${index + 29}';
      } else {
        return 'Üniteler listelenemiyor';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.levelName,
        showBackButton: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 18.0),
        itemCount: unitNames.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WordsPage(
                    unit: index + 1,
                  ),
                ),
              );
            },
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
                          color: primary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(''),
                        ),
                      ),
                      SizedBox(width: 16),
                      // Orta kısım
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              unitNames[index],
                              style: headingMedium.copyWith(
                                color: textGreyColor.withAlpha(179),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '20 Kelime',
                              style: bodySmall.copyWith(
                                color: textGreyColor.withAlpha(135),
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
                          color: primary,
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
