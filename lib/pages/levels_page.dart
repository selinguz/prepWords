import 'package:flutter/material.dart';
import 'package:prep_words/components/custom_appbar.dart';

class LevelsPage extends StatefulWidget {
  final String selectedLevel;

  const LevelsPage({super.key, required this.selectedLevel});

  @override
  State<LevelsPage> createState() => _LevelsPageState();
}

class _LevelsPageState extends State<LevelsPage> {
  List<String> unitNames = [
    "Ünite 1",
    "Ünite 2",
    "Ünite 3",
    "Ünite 4",
    "Ünite 5",
    "Ünite 6"
  ]; 
  
  String selectedLevel = "Başlangıç";

  void updateLevel(String level) {
    setState(() {
      this.selectedLevel = level;
      if (level == "Başlangıç") {
        unitNames = [
          "Ünite 1",
          "Ünite 2",
          "Ünite 3",
          "Ünite 4",
          "Ünite 5",
          "Ünite 6"
        ];
      } else if (level == "Orta") {
        unitNames = List.generate(22, (index) => "Ünite ${index + 1}");
      } else if (level == "İleri") {
        unitNames = List.generate(20, (index) => "Ünite ${index + 1}");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: '$selectedLevel Seviyesi'),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.star),
                onPressed: () => updateLevel("Başlangıç"),
              ),
              IconButton(
                icon: Icon(Icons.adjust),
                onPressed: () => updateLevel("Orta"),
              ),
              IconButton(
                icon: Icon(Icons.arrow_upward),
                onPressed: () => updateLevel("İleri"),
              ),
            ],
          ),
          Divider(),
          // Ünitelere ait liste.
          Expanded(
            child: ListView.builder(
              itemCount: unitNames.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(unitNames[index]),
                  onTap: () {
                    // Tıklanabilir ünite.
                    print("${unitNames[index]} seçildi.");
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
