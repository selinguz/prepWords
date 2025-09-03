import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:prep_words/models/word.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'word_list';

  Future<List<WordModel>> fetchWords() async {
    try {
      final snapshot = await _firestore.collection(collectionName).get();
      return snapshot.docs.map((doc) => WordModel.fromMap(doc.data())).toList();
    } catch (e) {
      throw Exception('An error occurred while retrieving the word list: $e');
    }
  }

  Future<List<WordModel>> fetchWordsByUnit(int unitNumber) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('word_list')
          .where('unit', isEqualTo: unitNumber)
          .get();

      return querySnapshot.docs
          .map((doc) => WordModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error Detail: $e');
      rethrow;
    }
  }

  Future<List<String>> getWordTypes() async {
    try {
      final QuerySnapshot snapshot =
          await _firestore.collection('word_list').get();

      // Benzersiz kelime türlerini topla
      Set<String> wordTypes = {};
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        wordTypes.add(data['wordType'] as String);
      }

      return wordTypes.toList()..sort();
    } catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

  Future<List<WordModel>> getWordsByType(String wordType) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('word_list')
          .where('wordType', isEqualTo: wordType)
          .get();

      return snapshot.docs
          .map((doc) => WordModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }
}
