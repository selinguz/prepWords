import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prep_words/models/word.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'word_list'; // Firebase'deki koleksiyon adı

  Future<List<WordModel>> fetchWords() async {
    try {
      final snapshot = await _firestore.collection(collectionName).get();
      return snapshot.docs.map((doc) => WordModel.fromMap(doc.data())).toList();
    } catch (e) {
      throw Exception('Kelime listesi alınırken hata oluştu: $e');
    }
  }

  Future<List<WordModel>> fetchWordsByUnit(int unitNumber) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('words')
          .where('unit', isEqualTo: unitNumber)
          .get();

      return querySnapshot.docs
          .map((doc) => WordModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Hata: $e');
      rethrow;
    }
  }
}
