import 'package:flutter/material.dart';
import 'package:prep_words/components/custom_appbar.dart';
import 'package:prep_words/consts.dart';
import 'package:auto_size_text/auto_size_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'exaMate'),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  decoration:
                      BoxDecoration(shape: BoxShape.circle, color: primary),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      'SG',
                      style: TextStyle(fontSize: 40),
                    ),
                  ),
                ),
                AutoSizeText(
                  maxLines: 2,
                  'Hoş Geldin Selin',
                  style: TextStyle(fontSize: 24),
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    12.0,
                  ),
                  color: secondaryOrange),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: AutoSizeText(
                  maxLines: 2,
                  'Seviyelerine Göre Bölümler',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
            levelRows(
              levelNumber: 1,
              levelName: 'Başlangıç Seviyesi',
              unitNumber: 6,
            ),
            levelRows(
              levelNumber: 2,
              levelName: 'Orta Seviye',
              unitNumber: 22,
            ),
            levelRows(
              levelNumber: 3,
              levelName: 'İleri Seviye',
              unitNumber: 20,
            ),
          ],
        ),
      ),

      /*  Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  AutoSizeText(
                    'Bugüne kadar \nöğrenilen kelime sayısı: ',
                    softWrap: true,
                    maxLines: 3,
                    textAlign: TextAlign.center,
                  ),
                  Container(
                    decoration:
                        BoxDecoration(shape: BoxShape.circle, color: primary),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        '15',
                        style: TextStyle(fontSize: 40),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.1,
              ),
              Column(
                children: [
                  AutoSizeText(
                    'Bugün öğrenilen \nkelime sayısı: ',
                    softWrap: true,
                    maxLines: 3,
                    textAlign: TextAlign.center,
                  ),
                  Container(
                    decoration:
                        BoxDecoration(shape: BoxShape.circle, color: primary),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        '5',
                        style: TextStyle(fontSize: 40),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SimpleCircularProgressBar(
            maxValue: 960,
            size: 100,
            valueNotifier: valueNotifier,
            progressStrokeWidth: 24,
            backStrokeWidth: 24,
            mergeMode: true,
            onGetText: (value) {
              return Text(
                '${value.toInt()}',
              );
            },
            progressColors: const [Colors.cyan, Colors.purple],
            backColor: Colors.black87,
          ),
          const SizedBox(
            height: 50,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 40, right: 40),
            child: TextField(
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              keyboardAppearance: Brightness.dark,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.black,
                hintText: 'Enter value (max 100)',
                hintStyle: TextStyle(color: Colors.black),
              ),
              style: const TextStyle(fontSize: 25, color: Colors.white),
              onSubmitted: (inputText) {
                final double newValue = double.parse(inputText);

                // As soon as we change the value of the valueNotifier
                // parameter, the function ValueListenableBuilder within
                // SimpleCircularProgressBar is called.
                valueNotifier.value = newValue;
              },
            ),
          )
           
          
          
         */
    );
  }
}

class levelRows extends StatelessWidget {
  final int levelNumber;
  final String levelName;
  final int unitNumber;

  const levelRows({
    super.key,
    required this.levelNumber,
    required this.levelName,
    required this.unitNumber,
  });

  @override
  Widget build(BuildContext context) {
    double indicatorValue = ((100 * 3) / unitNumber) / 100;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
          width: 80.0,
          height: 80.0,
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(12.0),
              color: primary),
          child: Center(
            child: Text(
              levelNumber.toString(),
              style: TextStyle(fontSize: 40, color: textWhiteColor),
            ),
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.05,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              levelName,
              style: TextStyle(fontSize: 24, color: textGreyColor),
            ),
            Text(
              '3 / $unitNumber Ünite',
              style: TextStyle(fontSize: 12),
            ),
            SizedBox(
              height: 30.0,
              width: MediaQuery.of(context).size.width * 0.50,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 20.0, // Progress bar yüksekliği.
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(8.0), // Kenarları yuvarlama.
                      color: Colors.grey[300], // Arka plan rengi.
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: LinearProgressIndicator(
                        value: indicatorValue,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(primary),
                      ),
                    ),
                  ),
                  Text(
                    '%${(indicatorValue * 100).toInt()}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black, // Metnin rengi.
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Spacer(),
        IconButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/levels');
          },
          icon: Icon(
            Icons.arrow_forward,
            size: 40,
            color: textGreyColor,
          ),
        ),
      ],
    );
  }
}
