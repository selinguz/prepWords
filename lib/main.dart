import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:prep_words/models/word.dart';
import 'package:prep_words/services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: FutureBuilder<List<WordModel>>(
          future: firebaseService.fetchWords(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Hata: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('Hiç kelime bulunamadı.'));
            }

            final words = snapshot.data!;
            return ListView.builder(
              itemCount: words.length,
              itemBuilder: (context, index) {
                final word = words[index];
                return Card(
                  child: Column(
                    children: [
                      Text(word.englishWord),
                      Text(word.turkishMeaning),
                      Text(word.wordType),
                      Text(word.exampleSentence),
                      Text(word.exampleTranslation),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

final firebaseService = FirebaseService();

Future<void> getWords() async {
  try {
    List<WordModel> words = await firebaseService.fetchWords();
    for (var word in words) {
      print('${word.englishWord} - ${word.turkishMeaning}');
    }
  } catch (e) {
    print('Hata: $e');
  }
}
