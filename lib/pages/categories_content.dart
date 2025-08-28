import 'package:flutter/material.dart';
import 'package:prep_words/components/custom_appbar.dart';
import 'package:prep_words/consts.dart';
import 'package:prep_words/models/word.dart';
import 'package:prep_words/services/firebase_service.dart';
import 'package:prep_words/pages/word_type_detail_page.dart';

class CategoriesContent extends StatefulWidget {
  const CategoriesContent({super.key});

  @override
  State<CategoriesContent> createState() => _CategoriesContentState();
}

class _CategoriesContentState extends State<CategoriesContent> {
  bool isListView = true;
  Map<String, bool> expandedMap = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Kategoriler'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.list,
                      color: isListView ? primary : textGreyColor),
                  onPressed: () => setState(() => isListView = true),
                ),
                IconButton(
                  icon: Icon(Icons.grid_view,
                      color: !isListView ? primary : textGreyColor),
                  onPressed: () => setState(() => isListView = false),
                ),
              ],
            ),
          ),
          // Kelime türleri listesi
          Expanded(
            child: FutureBuilder<List<String>>(
              future: FirebaseService().getWordTypes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Hata: ${snapshot.error}'));
                }

                final wordTypes = snapshot.data ?? [];
                return isListView
                    ? _buildListView(wordTypes)
                    : _buildGridView(wordTypes);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(List<String> wordTypes) {
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.3,
      ),
      itemCount: wordTypes.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WordTypeDetailPage(
                  wordType: wordTypes[index],
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: getFrontColor(wordTypes[index]),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: getFrontColor(wordTypes[index]).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getIconForWordType(wordTypes[index]),
                  color: textWhiteColor,
                  size: 32,
                ),
                SizedBox(height: 12),
                Text(
                  wordTypes[index],
                  style: headingSmall.copyWith(
                    color: textWhiteColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getIconForWordType(String wordType) {
    switch (wordType.toLowerCase()) {
      case 'noun':
        return Icons.category;
      case 'verb':
        return Icons.run_circle;
      case 'adjective':
        return Icons.color_lens;
      case 'adverb':
        return Icons.speed;
      default:
        return Icons.text_fields;
    }
  }

  Widget _buildListView(List<String> wordTypes) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: wordTypes.length,
      itemBuilder: (context, index) {
        final wordType = wordTypes[index];
        return _buildExpandableWordType(wordType);
      },
    );
  }

  Widget _buildExpandableWordType(String wordType) {
    expandedMap.putIfAbsent(wordType, () => false);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(wordType, style: headingSmall),
            trailing: Icon(
              expandedMap[wordType]!
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              color: primary,
            ),
            onTap: () {
              setState(() {
                expandedMap[wordType] = !expandedMap[wordType]!;
              });
            },
          ),
          if (expandedMap[wordType]!)
            FutureBuilder<List<WordModel>>(
              future: FirebaseService().getWordsByType(wordType),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final words = snapshot.data ?? [];
                return ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: words.length,
                  separatorBuilder: (context, index) => Divider(
                    color: Colors.grey.withValues(alpha: 0.2),
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                  ),
                  itemBuilder: (context, index) {
                    final word = words[index];
                    return ListTile(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      title: Text(word.englishWord, style: bodyLarge),
                      subtitle: Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(word.turkishMeaning, style: bodyMedium),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.search, color: primary),
                        onPressed: () => _showWordDetails(context, word),
                      ),
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  void _showWordDetails(BuildContext context, WordModel word) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(word.englishWord,
                style: headingLarge.copyWith(color: primary)),
            Divider(height: 20),
            _buildDetailRow('Anlam:', word.turkishMeaning),
            _buildDetailRow('Tür:', word.wordType),
            _buildDetailRow('Örnek:', word.exampleSentence, isItalic: true),
            _buildDetailRow('Çeviri:', word.exampleTranslation),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                Text('Kapat', style: greyButtonText.copyWith(color: primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isItalic = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: bodyMedium.copyWith(color: textGreyColor)),
          SizedBox(height: 4),
          Text(
            value,
            style: bodyLarge.copyWith(
              fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ],
      ),
    );
  }
}
