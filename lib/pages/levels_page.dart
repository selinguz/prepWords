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
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: primary,
                child: Text(
                  '',
                  style: TextStyle(color: textWhiteColor),
                ),
              ),
              title: Text(unitNames[index]),
              trailing: Icon(Icons.arrow_forward_ios, color: textGreyColor),
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
            ),
          );
        },
      ),
    );
  }
}
