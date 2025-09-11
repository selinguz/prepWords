import 'package:flutter/material.dart';
import 'package:prep_words/components/custom_appbar.dart';
import 'package:prep_words/consts.dart';
import 'package:prep_words/models/word.dart';
import 'package:prep_words/services/firebase_service.dart';
import 'package:prep_words/pages/word_type_detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      appBar: CustomAppBar(title: 'Categories'),
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
                wordTypes
                    .sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

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

  Future<List<WordModel>> _loadWordsWithStatus(String wordType) async {
    final words = await FirebaseService().getWordsByType(wordType);
    final prefs = await SharedPreferences.getInstance();

    for (var w in words) {
      final saved = prefs.getString('word_status_${w.englishWord}');
      if (saved != null) {
        w.status = WordStatus.values.firstWhere(
          (s) => s.toString() == saved,
          orElse: () => WordStatus.none,
        );
      } else {
        w.status = WordStatus.none;
      }
    }
    return words;
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
              future: _loadWordsWithStatus(wordType), // <-- burayı değiştirdik
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
                words.sort((a, b) => a.englishWord
                    .toLowerCase()
                    .compareTo(b.englishWord.toLowerCase()));
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
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
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                      title: Text(word.englishWord, style: bodyLarge),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(word.turkishMeaning, style: bodyMedium),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildWordStatusIndicator(
                              word.status), // 🔹 Durum ikonu + tooltip
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(Icons.search, color: primary),
                            onPressed: () => _showWordDetails(context, word),
                          ),
                        ],
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
            const Divider(height: 20),
            _buildDetailRow('Meaning:', word.turkishMeaning),
            _buildDetailRow('Type:', word.wordType),
            _buildDetailRow('Unit:', word.unit.toString()),
            _buildDetailRow('Example:', word.exampleSentence, isItalic: true),
            _buildDetailRow('Translation:', word.exampleTranslation),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                Text('Close', style: greyButtonText.copyWith(color: primary)),
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
          Text(label,
              style: bodyLarge.copyWith(
                  color: Colors.deepOrangeAccent, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
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

  Widget _buildWordStatusIndicator(WordStatus status) {
    switch (status) {
      case WordStatus.known:
        return const Tooltip(
          message: 'I know',
          child: Icon(Icons.check_circle, color: Colors.green, size: 24),
        );
      case WordStatus.unknown:
        return const Tooltip(
          message: 'I don\'t know',
          child: Icon(Icons.cancel_rounded, color: Colors.red, size: 24),
        );
      case WordStatus.unsure:
        return const Tooltip(
          message: 'I am not sure',
          child:
              Icon(Icons.remove_circle_rounded, color: Colors.orange, size: 24),
        );
      case WordStatus.none:
        return const Tooltip(
          message: 'I haven\'t studied yet',
          child: Icon(Icons.help_outline, color: Colors.grey, size: 24),
        );
    }
  }
}
