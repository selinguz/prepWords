import 'package:flutter/material.dart';
import 'package:prep_words/components/custom_appbar.dart';
import 'package:prep_words/pages/words_page.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Choose Word Type to Study'),
      body: Column(
        children: [
          Text('Verbs'),
          Text('Nouns'),
          Text('Adjectives'),
          Text('Adverbs'),
          ElevatedButton(
            child: Text('Words Page'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WordsPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
